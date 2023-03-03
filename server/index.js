// Once we Create a new Schema, connect it to our database
const express = require('express');
const { Server } = require('ws');
const mongoose = require('mongoose');
const crypto = require('crypto'); // Used to hash passwords

const User = require('./user.js'); // Locate file

const PORT = process.env.PORT || 3000; //port for https

const server = express()
    .use((req, res) => res.send("Hello, you!"))
    .listen(PORT, () => console.log(`Listening on ${PORT}`));

const wss = new Server({ server });

// TODO: Change connection
mongoose.connect("http://127.0.0.1:57246/")
    .then((_) => console.log("Connected to database."))
    .catch((e) => console.log("Error:", e)); // Open MongoDB.

wss.on('connection', function(ws, req) {
    ws.on('message', message => { // If there is any message
        // // Example usage:
        var loginResult = login(data.username, data.password);
        if (loginResult.success) {
            ws.send("Login successful");
        } else {
            ws.send("Login failed: " + loginResult.message);
        }


        var datastring = message.toString();
        if(datastring.charAt(0) == "{"){ // Check if message starts with '{' to check if it's json
            datastring = datastring.replace(/\'/g, '"');
            var data = JSON.parse(datastring)
            if(data.auth == "chatappauthkey231r4"){
                // TODO: Create login function
                function login(username, password) {
                    // TODO: Add login logic here
                    if (username === "chatuser" && password === "chatpass") {
                        return { success: true, message: "Login successful" };
                    } else {
                        return { success: false, message: "Invalid username or password" };
                    }
                }

                /** Once we create a basic backend, we start signing up users
                 *      -> Create Signup function
                 *          -> checks if the username & email don't already exist and hash user's password
                 * 
                 *      -> Create Login function
                 *          -> a way for users to log in
                 */ 
                    // Signup Function
                    if (data.cmd === 'signup') {  // On Signup, look into database for an email
                        // If mail doesn't exists it will return null
                        User.findOne({email: data.email}).then((mail) => {
                            // Check if email doesn't exist.
                            if (mail == null) {
                                User.findOne({username: data.username}).then((user) => {
                                        // Check if username doesn't exists.
                                        if (user == null) {
                                            const hash = crypto.createHash("md5")
                                            let hexPwd = hash.update(data.hash).digest('hex');
                                            var signupData = "{'cmd':'"+data.cmd+"','status':'succes'}";
                                            const user = new User({
                                                email: data.email,
                                                username: data.username,
                                                password: hexPwd,
                                            });
                                            // Insert new user in db
                                            user.save();
                                            // Send info to user
                                            ws.send(signupData);
                                    } else {
                                        // Send error message to user.
                                        var signupData = "{'cmd':'"+data.cmd+"','status':'user_exists'}";  
                                        ws.send(signupData);  
                                    }
                                });
                            } else{
                                // Send error message to user.
                                var signupData = "{'cmd':'"+data.cmd+"','status':'mail_exists'}";    
                                ws.send(signupData);
                            }
                        });
                    }

                    // Login Function
                    if (data.cmd === 'login') {
                        // Check if email exists 
                        User.findOne({email: data.email}).then((r) => {
                            // If email doesn't exists it will return null
                            if (r != null) {
                                const hash = crypto.createHash("md5")
                                // Hash password to md5
                                let hexPwd = hash.update(data.hashcode).digest('hex');
                                // Check if password is correct
                                if (hexPwd == r.password) {
                                    // Send username to user and status code is succes.
                                    var loginData = '{"username":"'+r.username+'","status":"succes"}';
                                    // Send data back to user
                                    ws.send(loginData);
                                } else{
                                    // Send error
                                    var loginData = '{"cmd":"'+data.cmd+'","status":"wrong_pass"}';
                                    ws.send(loginData);
                                }
                            } else{
                                // Send error
                                var loginData = '{"cmd":"'+data.cmd+'","status":"wrong_mail"}';
                                ws.send(loginData);
                            }
                        });
                    } 
            }
        }
        


    }) 
})

