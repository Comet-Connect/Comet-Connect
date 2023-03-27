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

// add a user to the database
userSchema.statics.addUser = async function (username, password, first_name, last_name, email) {
  const newUser = new User({
    username: username,
    password: password,
    email: email,
    first_name: first_name,
    last_name: last_name
  });
  // connection.collection('UserInfo').insert(newUser)
  return newUser.save();
}

const User = mongoose.model('UserInfo', userSchema);
module.exports = User;
