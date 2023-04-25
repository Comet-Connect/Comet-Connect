// Current approach (wss)
const mongoose = require('mongoose');
const express = require('express');
const { Server } = require('ws');
const bcrypt = require('bcrypt');

// Schemas 
const User = require('./models/user.js');
const Group = require('./models/group.js');
const Calendar = require('./models/calendar.js');
const Event = require('./models/event.js');
const ForgotPw = require('./models/forgot_pw.js');


// Back up approach (app)
const bodyParser = require('body-parser');
const MongoClient = require('mongodb').MongoClient;
const app = express();
app.use(bodyParser.json());
const JWT_SECRET = 'Y8qKMoPgmy';
const jwt = require('jsonwebtoken');

// Config
const config = require('../comet_connect_app/assets/config/config.json');
const { verify } = require('crypto');

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
      
      // Listens to cmds called by Front-End
      try {

        // Retrieve Data being parsed
        const data = JSON.parse(message);
        
        // Login function                ***Status: Done***
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

        // Signup function               ***Status: Done***
        else if (data.cmd === 'signup' && data.auth === 'chatappauthkey231r4') {
          const matchingUsername = await User.findOne({username: data.username})
          const matchingEmail = await User.findOne({email: data.email})

          // Checks if username already exists 
          if (matchingUsername) {
            ws.send(JSON.stringify({"cmd": "signup", "status": "existing_username"}));
          }
          // Checks if email already exists
          else if (matchingEmail) {
            ws.send(JSON.stringify({"cmd": "signup", "status": "existing_email"}));
          }
          else {
            const newUser = await User.addUser(data.username, data.password, data.first_name, data.last_name, data.email)

            if (newUser) {
              // create a default calendar for the user
              const newCalendar = new Calendar({
                name: `${newUser.first_name}'s Calendar`,
                owner: newUser._id
              });
              // save the new user and calendar
              newUser.calendar = newCalendar._id;
              await newCalendar.save();
              await newUser.save();
                  
              // Send message back to front end for Success
              ws.send(JSON.stringify({"cmd": "signup", "status": "success"}))
            }
            else {
              ws.send(JSON.stringify({"cmd": "signup", "status": "signup_error"}))
            }
          }
        }
        
        // Get Calendar function         ***Status: Done***
        else if (data.cmd === 'get_calendar') {
          const ownerId = data.oid;  // Get user oid
          const calendar = await Calendar.findOne({ owner: ownerId }).populate('events');  // Find it in the Calendar collection

          // Check if calendar does not exist
          if (!calendar) {
            ws.send(JSON.stringify({ cmd: 'get_calendar', status: 'calendar_not_found' }));
          } 
          else {  
            // Calendar Exists
            const events = calendar.events;

            // Send calendar to be displayed in front-end
            ws.send(JSON.stringify({ cmd: 'calendar', events }));
          }
        }
        
        // New Meeting function          ***Status: Done***
        else if (data.cmd === 'new_meeting') {
          const eventData = data.event;  // Get Meeting
          const userId = data.oid;       // Get User oid
        
          // Find the user's calendar
          const calendar = await Calendar.findOne({ owner: userId });
          if (!calendar) {
            ws.send(JSON.stringify({ cmd: 'new_meeting', status: 'calendar_not_found' }));
            return;
          }
        
          // Create a new Event object and save it to the database
          const newEvent = new Event({
            title: eventData.title,
            start: new Date(eventData.start),
            end: new Date(eventData.end),
          });
          await newEvent.save();
        
          // Add the new event to the calendar's events array
          calendar.events.push(newEvent);
          await calendar.save();
        
          // Send a confirmation message to the frontend
          ws.send(JSON.stringify({ cmd: 'new_meeting', status: 'success', event: newEvent }));
        }

        // Deleting Meeting function     ***Status: Done***
        else if (data.cmd === 'delete_meeting') {
          // Meeting Data
          const userId = data.oid;    // User oid
          const title = data.title;   // Title of Meeting
          const start = data.start;   // Start time of Meeting
          const end = data.end;       // End time of Meeting
        
          // Find the user's calendar
          const calendar = await Calendar.findOne({ owner: userId });
        
          // Check if calendar does not exist
          if (!calendar) {
            ws.send(JSON.stringify({ cmd: 'delete_meeting', status: 'calendar_not_found' }));
            return;
          }
        
          // Find the event to be deleted
          const event = await Event.findOne({ title: title, start: start, end: end });
        
          // Check if Event does not exist
          if (!event) {
            ws.send(JSON.stringify({ cmd: 'delete_meeting', status: 'event_not_found' }));
            return;
          }
        
          // Remove the event from the calendar's events array
          const index = calendar.events.indexOf(event._id);
          calendar.events.splice(index, 1);
        
          // Delete the event from the database
          await Event.deleteOne({ _id: event._id });
        
          // Save the updated calendar
          await calendar.save();
        
          // Send a confirmation message to the frontend
          ws.send(JSON.stringify({ cmd: 'delete_meeting', status: 'success' }));
        }
        
        // Group Creation function       ***Status: Done***
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

        // Get Groups function           ***Status: Done***
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

        // Get Group function            ***Status: In Progress  -> Not Currently Being Used***
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
            ws.send(JSON.stringify({
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
            ws.send(JSON.stringify({
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
          ws.send(JSON.stringify({
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

        // Forgot password 
        else if (data.cmd === 'forgot_pw' && data.auth === 'chatappauthkey231r4') {
          const matchingEmail = await User.findOne({email: data.email})

          if (!matchingEmail) {
            ws.send(JSON.stringify({cmd:'forgot_pw', status:'invalid_email'}))
            return;
          }
          else {
            const existingForgotRequest = await ForgotPw.findOne({email: matchingEmail.email})
            if (existingForgotRequest) {
              ws.send(JSON.stringify({cmd:'forgot_pw', status: 'existing_request'}))
              return;
            }
            
            const verificationCode = ForgotPw.generateVerificationCode()
            const forgotPasswordRequest = new ForgotPw({
              email: matchingEmail.email,
              reset_code: verificationCode
            })
            await forgotPasswordRequest.save(function(e) {
              if (e) {print(e)}
            })
            ws.send(JSON.stringify({'cmd': 'forgot_pw', 'status': 'success'}))
          }
        }

        else if (data.cmd === 'verify_code' && data.auth == 'chatappauthkey231r4') {
          const resetRequest = await ForgotPw.findOne({emaill: data.email})

          if (!resetRequest) {
            return;
          }

          if (data.verificationCode === resetRequest.reset_code) {
            ws.send(JSON.stringify({'cmd': 'verify_code', 'status': 'success'}))
          }
          else {
            ws.send(JSON.stringify({'cmd': 'verify_code', 'status': 'no_matching_code'}))
          }
        }
        
        // TODO: merge command with niha's functionality
        else if (data.cmd === 'change_pw' && data.auth == 'chatappauthkey231r4') {
          const userToChange = await User.findOne({email: data.email})
          userToChange.password = data.password
          await userToChange.save()

          // delete forgot password request after fulfilled
          const requestToDelete = await ForgotPw.findOne({email: data.email})
          try {
            requestToDelete.delete()
          } catch (e) {
            console.log(e)
          }

          ws.send(JSON.stringify({'cmd': 'change_pw', 'status': 'success'}))
        }

        //Catching all other Errors
        else {
          ws.send(JSON.stringify({ "cmd": data.cmd, "status": "invalid_auth" }));
        }

      } // End of Try block
      catch (err) {
        console.error('Error parsing WebSocket message: (index.js)', err);
        ws.send(JSON.stringify({ "cmd": "error", "status": "parse_error" }));
      }

      // Closing connections
    });
    ws.on("close", () => {
      console.log("Client disconnected");
    });
    ws.onerror = function () {
        console.log("Some Error occurred");
    }
    
    // Buffer Message
    ws.on("message", (msg) => {
        var buf = Buffer.from(msg);
        console.log('\t' + buf.toString());
    });

  });
}).catch((err) => {  // Error with MongoDB
  console.error('Error connecting to MongoDB:', err);
  process.exit(1);
});


// Function to generate a 6 code session id
function generateSessionId() {
  const length = 6; // Length of session ID
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'; // Characters to use in session ID
  let result = '';

  // Random Generator
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
  