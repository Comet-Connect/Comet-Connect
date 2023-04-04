// Current approach (wss)
const mongoose = require('mongoose');
const express = require('express');
const { Server } = require('ws');
const bcrypt = require('bcrypt');

// Schemas 
const User = require('./models/user.js');
const Group = require('./models/group.js');   // Import the Group schema

// Back up approach (app)
const bodyParser = require('body-parser');
const MongoClient = require('mongodb').MongoClient;
const app = express();
app.use(bodyParser.json());
const JWT_SECRET = 'Y8qKMoPgmy';
const jwt = require('jsonwebtoken');

// Config
const config = require('../comet_connect_app/assets/config/config.json')

// URLs & Ports
const port = config.server.port  //process.env.PORT || 3000;
const dbUsername = config.database.username
const dbPassword = config.database.password
const dbUrl = config.database.url
const url = `mongodb+srv://${dbUsername}:${dbPassword}@${dbUrl}?retryWrites=true&w=majority`
            //'mongodb+srv://admin:bNGtOFxi3UTcv81W@cometconnect.cuwtjrg.mongodb.net/user_info';

// Connect to MongoDB
mongoose.connect(url, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(() => {  // Success
  console.log('\nConnected to MongoDB');
  const server = app.listen(port, () => console.log(`Listening on ${port}`));
  const wss = new Server({ server });
  
  // Start up WebSocket Server
  wss.on('connection', function (ws, req) {
    console.log('WebSocket client connected');
    
    ws.on('message', async (message) => {
      // See if WS message is recieved
      console.log('WebSocket message received:')
      
      try {

        // Retrieve Data being parsed
        const data = JSON.parse(message);
        
        // Login function        ***Status: Done***
        if (data.auth === "chatappauthkey231r4" && data.cmd === 'login') {
          // Check if email or username exists
          const user = await User.findOne({ $or: [{ email: data.email }, { username: data.username }] });
          
          if (!user) {
            ws.send(JSON.stringify({ "cmd": "login", "status": "wrong_credentials" }));
          } else {
            // Check if password is correct
            const match = await user.checkPassword(data.password);
            
            if (match) {
              ws.send(JSON.stringify({ "cmd": "login", "username": user.username,"oid": user._id.toString(), "status": "success" }));
            } else {
              ws.send(JSON.stringify({ "cmd": "login", "status": "wrong_credentials" }));
            }
          }
        }  

        // Signup function       ***Status: Done***
        else if (data.cmd === 'signup' && data.auth === 'chatappauthkey231r4') {
          const matchingUsername = await User.findOne({username: data.username})
          const matchingEmail = await User.findOne({email: data.email})

          if (matchingUsername) {
            ws.send(JSON.stringify({"cmd": "signup", "status": "existing_username"}));
          }
          else if (matchingEmail) {
            ws.send(JSON.stringify({"cmd": "signup", "status": "existing_email"}));
          }
          else {
            const added = User.addUser(data.username, data.password, data.first_name, data.last_name, data.email)

            if (added) {
              ws.send(JSON.stringify({"cmd": "signup", "status": "success"}))
            }
            else {
              ws.send(JSON.stringify({"cmd": "signup", "status": "signup_error"}))
            }
          }
        }
        
        // Group Creation        ***Status: Done***
        else if (data.cmd === 'create_group') {
          // Check if all users exist in the database
          const users = await Promise.all(data.users.map(async (username) => {
            const existingUser = await User.findOne({ username: username });
            if (!existingUser) {
              console.log(`User ${username} not found in database`);
              return null;
            }
              return existingUser._id;
            }));
            
            if (users.some(user => !user)) {
              // At least one user doesn't exist in the database
              ws.send(JSON.stringify({ cmd: 'create_group', "status": 'user_not_found' }));
            } else {
              const session_id = generateSessionId();
              const group = new Group({
                name: data.name,
                users: users,
                description: data.description,
                session_id: session_id
              });

              try {
                await group.save();
                // Add the group ID and session ID to the response message
                ws.send(JSON.stringify({ cmd: 'create_group', status: 'success', group_id: group._id, session_id: session_id }));
                
              } catch (err) {
                console.error('Error saving group:', err);
                ws.send(JSON.stringify({ cmd: 'create_group', status: 'error' }));
              }
            }
        }

        // Get Groups function   ***Status: Done***
        else if ( data.cmd === 'get_groups' && data.auth === 'chatappauthkey231r4') {
          // Get user id from data
          const oid = data.oid;

          // Find all groups that the user is a member of
          const groups = await Group.find({ users: oid }).populate('users');

          // Convert _id field to $oid for each group
          const formattedGroups = groups.map((group) => {
            const { _id, ...rest } = group.toObject();
            return { ...rest, id: _id.toString() };
          });


          ws.send(JSON.stringify({ cmd: 'get_groups', status: 'success', data: formattedGroups }));
          // Debug print statement to display the data being sent to the client
          console.log(`Sent get_groups response for user with oid ${oid}:`, formattedGroups);
        }

        // Get Group function    ***Status: In Progress  -> Not Currently Being Used***
        // TODO: Needs work
        else if (data.cmd === 'get_group' && data.auth === 'chatappauthkey231r4') {
          // Check if the group exists
          const group = await Group.findById(data.group_id).populate('users');

          if (!group) {
            ws.send(JSON.stringify({ cmd: 'get_group', status: 'group_not_found' }));
          } else {
            // Convert _id field to $oid
            const { _id, ...rest } = group.toObject();
            const formattedGroup = { ...rest, _id: _id.$oid };

            ws.send(JSON.stringify({ cmd: 'get_group', status: 'success', group: formattedGroup }));
            // Debug print statement to display the data being sent to the client
            console.log(`Sent get_group response for group with oid ${data.group_id}:`, formattedGroup);
          }
        }

        // Join Group Using Session ID   ***Status: Done***
        else if (data.cmd === 'join_group' && data.auth === 'chatappauthkey231r4') {
          const { session_id, user_id } = data;
        
          try {
            // Find the group with the given session ID
            const group = await Group.findOne({ session_id }).populate('users');
        
            if (!group) {
              ws.send(JSON.stringify({ cmd: 'join_group', status: 'group_not_found' }));
            } else if (group.users.some((user) => user._id.toString() === user_id)) {
              ws.send(JSON.stringify({ cmd: 'join_group', status: 'already_joined' }));
            } else {
              // Add the user to the group
              group.users.push(user_id);
              await group.save();
        
              ws.send(JSON.stringify({ cmd: 'join_group', status: 'success', group_id: group._id }));
            }
          } catch (err) {
            console.error('Error joining group:', err);
            ws.send(JSON.stringify({ cmd: 'join_group', status: 'error' }));
          }
        }

        // Leave Group Using group oid and user oid    ***Status: Done***
        else if (data.cmd === 'leave_group' && data.auth === 'chatappauthkey231r4') {
          const groupId = data._id;
          const userId = data.user_oid;
          
          // Find the group with the given ID
          const group = await Group.findById(groupId);
          if (!group) {
            // Group not found
            socket.send(JSON.stringify({
              cmd: 'leave_group',
              auth: 'chatappauthkey231r4',
              status: 'Group not found',
            }));
            return;
          }
        
          // Remove the user from the group
          const userIndex = group.users.findIndex((id) => id.toString() === userId.toString());
          if (userIndex === -1) {
            // User not found in group
            socket.send(JSON.stringify({
              cmd: 'leave_group',
              auth: 'chatappauthkey231r4',
              status: 'User not found in group',
            }));
            return;
          }
          group.users.splice(userIndex, 1);
        
          // Delete the group if no users are left
          if (group.users.length === 0) {
            await Group.findByIdAndDelete(groupId);
          } else {
            await group.save();
          }
        
          // Send confirmation to the client
          socket.send(JSON.stringify({
            cmd: 'leave_group',
            auth: 'chatappauthkey231r4',
            status: 'ok',
          }));
        
          // Notify all users in the group that the user has left
          const message = `${userId} has left the group.`;
          for (const id of group.users) {
            if (id.toString() !== userId.toString()) {
              const userSocket = onlineUsers.get(id.toString());
              if (userSocket) {
                userSocket.send(JSON.stringify({
                  cmd: 'group_message',
                  auth: 'chatappauthkey231r4',
                  group_id: groupId,
                  user_id: userId,
                  message,
                }));
              }
            }
          }
        }
        
        
      
        //Errors
        else {
          ws.send(JSON.stringify({ "cmd": data.cmd, "status": "invalid_auth" }));
        }
      } catch (err) {
        console.error('Error parsing WebSocket message: (index.js)', err);
        ws.send(JSON.stringify({ "cmd": "error", "status": "parse_error" }));
      }
    
    
      // For Meetings 
      const { type, payload } = JSON.parse(message);

      if (type === 'CREATE_MEETING') {
        createMeeting(payload)
          .then((meeting) => {
            wss.clients.forEach((client) => {
              client.send(JSON.stringify({ type: 'MEETING_CREATED', payload: meeting }));
            });
          })
          .catch((err) => {
            console.error(err);
            ws.send(JSON.stringify({ type: 'ERROR', payload: 'Server error' }));
          });
      }
    
    
    
    });
    ws.on("close", () => {
      console.log("Client disconnected");
    });
    ws.onerror = function () {
        console.log("Some Error occurred");
    }
    
    ws.on("message", (msg) => {
        var buf = Buffer.from(msg);
        console.log('\t' + buf.toString());
    });

  });
}).catch((err) => {
  console.error('Error connecting to MongoDB:', err);
  process.exit(1);
});


function generateSessionId() {
  const length = 6; // Length of session ID
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'; // Characters to use in session ID
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
}

//API
  app.post('/api/login', async (req, res) => {
    try {
      // Connect to MongoDB
      const client = await MongoClient.connect(url);
      const db = client.db('user_info');
      print(req);
      // Get the user from the database
      const user = await db.collection('users').findOne({ username: req.body.username });

      // Check if the user exists and the password is correct
      if (!user || !(await bcrypt.compare(req.body.password, user.password))) {
        return res.status(401).json({ error: 'Invalid username or password' });
      }

      // Generate a JWT token and send it to the client
      const token = jwt.sign({ userId: user._id }, JWT_SECRET);
      res.json({ token });

    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Internal server error' });
    }
  });

  app.post('/create_group', async (req, res) => {
    const { name, users, description } = req.body;
  
    const group = new Group({
      name,
      users,
      description,
    });
  
    try {
      await group.save();
      res.status(201).json({ status: 'success', group });
    } catch (err) {
      console.error('Error saving group:', err);
      res.status(500).json({ status: 'error' });
    }
  });
  


// // Helper function to check if user exists in database
// async function checkUser(username) {
//     const client = new MongoClient(url, { useNewUrlParser: true, useUnifiedTopology: true });
//     try {
//       await client.connect();
//       const db = client.db('user_info');
//       const collection = db.collection('users');
//       const user = await collection.findOne({ username: username });
//       return user !== null;
//     } finally {
//       await client.close();
//     }
//   }
  
//   // Helper function to check if password matches hashed password in database
//   async function checkPassword(username, password) {
//     const client = new MongoClient(url, { useNewUrlParser: true, useUnifiedTopology: true });
//     try {
//       await client.connect();
//       const db = client.db('user_info');
//       const collection = db.collection('users');
//       const user = await collection.findOne({ username: password });
//       if (!user) {
//         return false;
//       }
//       return await bcrypt.compare(password, user.password);
//     } finally {
//       await client.close();
//     }
//   }

  // API endpoint to fetch data
  app.get('/api/data', (req, res) => {
    MongoClient.connect(url, (err, client) => {
      if (err) {
        console.error(err);
        res.status(500).send('Error connecting to database');
        return;
      }
      
      const db = client.db('user_info');
      
      db.collection('users').find().toArray((err, results) => {
        if (err) {
          console.error(err);
          res.status(500).send('Error fetching data from database');
          return;
        }
        
        res.json(results);
      });
    });
  });
  

  async function createMeeting(meeting) {
    // const client = await MongoClient.connect(mongoUrl, { useUnifiedTopology: true });
    // const db = client.db(dbName);
    // const collection = db.collection(collectionName);
  
    // const result = await collection.insertOne(meeting);
    // const insertedMeeting = result.ops[0];
  
    // client.close();
  
    // return insertedMeeting;
  }

  