const mongoose = require('mongoose');
const express = require('express');
const { Server } = require('ws');
const bodyParser = require('body-parser');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const User = require('./models/User');
const MongoClient = require('mongodb').MongoClient;
const app = express();
const port = 3000  //process.env.PORT || 3000;
var db_username = encodeURIComponent('admin')
var db_password = encodeURIComponent('bNGtOFxi3UTcv81W')
const url = `mongodb+srv://${db_username}:${db_password}@cometconnect.cuwtjrg.mongodb.net/user_info`
            //'mongodb+srv://admin:bNGtOFxi3UTcv81W@cometconnect.cuwtjrg.mongodb.net/user_info';
app.use(bodyParser.json());

const JWT_SECRET = 'Y8qKMoPgmy';

// Connect to MongoDB
mongoose.connect(url, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(() => {  // Success
  console.log('Connected to MongoDB');
  const server = app.listen(port, () => console.log(`Listening on ${port}`));
  const wss = new Server({ server });
  
  wss.on('connection', function (ws, req) {
    console.log('WebSocket client connected');
    
    ws.on('message', async (message) => {
      console.log('WebSocket message received:\n', JSON.stringify(message, "  "));
      
      try {
        const data = JSON.parse(message);
        // Login function
        if (data.auth === "chatappauthkey231r4" && data.cmd === 'login') {
          // Check if email or username exists
          const user = await User.findOne({ $or: [{ email: data.email }, { username: data.username }] });
          
          if (!user) {
            ws.send(JSON.stringify({ "cmd": "login", "status": "wrong_credentials" }));
          } else {
            // Check if password is correct
            const match = await user.checkPassword(data.password);
            
            if (match) {
              ws.send(JSON.stringify({ "cmd": "login", "username": user.username, "status": "success" }));
            } else {
              ws.send(JSON.stringify({ "cmd": "login", "status": "wrong_credentials" }));
            }
          }
        }  // TODO: Signup function
        
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

        else {
          ws.send(JSON.stringify({ "cmd": data.cmd, "status": "invalid_auth" }));
        }
      } catch (err) {
        console.error('Error parsing WebSocket message: (index.js)', err);
        ws.send(JSON.stringify({ "cmd": "error", "status": "parse_error" }));
      }
    });
  });
}).catch((err) => {
  console.error('Error connecting to MongoDB:', err);
  process.exit(1);
});



// wss.on('connection', function(ws, req) {
//     ws.on('message', message => { // If there is any message
//         var datastring = message.toString();
//         print(datastring);
//         if(datastring.charAt(0) == "{"){ // Check if message starts with '{' to check if it's json
//             datastring = datastring.replace(/\'/g, '"');
//             var data = JSON.parse(datastring)
//             if(data.auth == "chatappauthkey231r4"){
//                 // TODO: Create login function
//                 if (data.cmd === 'login'){
//                   // Check if email exists 
//                   User.findOne({email: data.email}).then((r) => {
//                       // If email doesn't exists it will return null
//                       if (r != null){
//                           const hash = crypto.createHash("md5")
//                           // Hash password to md5
//                           let hexPwd = hash.update(data.hashcode).digest('hex');
//                           // Check if password is correct
//                           if (hexPwd == r.password) {
//                               // Send username to user and status code is succes.
//                               var loginData = '{"username":"'+r.username+'","status":"succes"}';
//                               // Send data back to user
//                               ws.send(loginData);
//                           } else{
//                               // Send error
//                               var loginData = '{"cmd":"'+data.cmd+'","status":"wrong_pass"}';
//                               ws.send(loginData);
//                           }
//                       } else{
//                           // Send error
//                           var loginData = '{"cmd":"'+data.cmd+'","status":"wrong_mail"}';
//                           ws.send(loginData);
//                       }
//                   });
//               } 
//             }
//         }
//     }) 
// })


  app.post('/api/login', async (req, res) => {
    try {
      // Connect to MongoDB
      const client = await MongoClient.connect(url);
      const db = client.db('user_info');
      print(req);
      // Get the user from the database
      const user = await db.collection('UserInfo').findOne({ username: req.body.username });

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


// // Helper function to check if user exists in database
// async function checkUser(username) {
//     const client = new MongoClient(url, { useNewUrlParser: true, useUnifiedTopology: true });
//     try {
//       await client.connect();
//       const db = client.db('user_info');
//       const collection = db.collection('UserInfo');
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
//       const collection = db.collection('UserInfo');
//       const user = await collection.findOne({ username: password });
//       if (!user) {
//         return false;
//       }
//       return await bcrypt.compare(password, user.password);
//     } finally {
//       await client.close();
//     }
//   }

  // // Helper function to add a user to the database
  // async function addUser(username, password, firstName, lastName, email) {
  //   try {
  //     const client = new MongoClient.connect(url);
  //     const database = client.db("CommetConnectText")
  //     const haiku = database.collection("UserInfo");
  //     // create a document to insert
  //     // const doc = {
  //     //   username: username,
  //     //   password: password,
  //     //   first_name: firstName,
  //     //   last_name: lastName,
  //     //   email: email
  //     // }
  //     const doc = {
  //       username: 'jd123',
  //       password: 'password123#$',
  //       first_name: 'john',
  //       last_name: 'doe',
  //       email: 'jd123@example.com'
  //     }
  //     const result = await haiku.insertOne(doc);
  //     console.log(`A document was inserted with the _id: ${result.insertedId}`);
  //     alert('Function called');
  //   } finally {
  //     await client.close();
  //   }
  // }

  // API endpoint to fetch data
  app.get('/api/data', (req, res) => {
    MongoClient.connect(url, (err, client) => {
      if (err) {
        console.error(err);
        res.status(500).send('Error connecting to database');
        return;
      }
      
      const db = client.db('user_info');
      
      db.collection('UserInfo').find().toArray((err, results) => {
        if (err) {
          console.error(err);
          res.status(500).send('Error fetching data from database');
          return;
        }
        
        res.json(results);
      });
    });
  });
  
//   // Start server
// app.listen(port, () => {
//     console.log(`Server started on port ${port}`);
//   });
  