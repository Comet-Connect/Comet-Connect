// Creating User Schema
const mongoose = require('mongoose');
const crypto = require('crypto');
const express = require('express');
const bodyParser = require('body-parser');
const bcrypt = require('bcrypt');

const userSchema = new mongoose.Schema({
  username: { 
    type: String, 
    required: true, 
    unique: true 
  },
  password: { 
    type: String, 
    required: true 
  },
  email: { 
    type: String, 
    required: true, 
    unique: true 
  },
  first_name: String,
  last_name: String

});

// Hash the password before saving it to the database
userSchema.pre("save", async function (next) {
    const user = this;
    if (user.isModified("password")) {
      user.password = await bcrypt.hash(user.password, 10);
    }
    next();
  });
  
  // Check if the given password matches the user's password
  userSchema.methods.checkPassword = async function (password) {
    return await bcrypt.compare(password, this.password);
  };

const User = mongoose.model('User', userSchema);

// Create a new user
// const newUser = new User({
//     username: "dan",
//     password: "123",
//     email: "da@gmail.com",
//     first_name: "danny",
//     last_name: "vu"
//   });
// newUser.save();

module.exports = User;

