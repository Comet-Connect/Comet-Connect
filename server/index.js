// Current approach (wss)
const mongoose = require('mongoose');
const express = require('express');
const { Server } = require('ws');
const bcrypt = require('bcrypt');
const User = require('./models/User');

// Back up approach (app)
const bodyParser = require('body-parser');
const MongoClient = require('mongodb').MongoClient;
const app = express();
app.use(bodyParser.json());
const JWT_SECRET = 'Y8qKMoPgmy';
const jwt = require('jsonwebtoken');

// URLs & Ports
const port = 3000  //process.env.PORT || 3000;
const url = 'mongodb+srv://admin:bNGtOFxi3UTcv81W@cometconnect.cuwtjrg.mongodb.net/user_info?retryWrites=true&w=majority' 
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
  });
}).catch((err) => {
  console.error('Error connecting to MongoDB:', err);
  process.exit(1);
});


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

  