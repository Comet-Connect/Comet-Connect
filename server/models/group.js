// Creating Groups Schema
const mongoose = require('mongoose');
const User = require('./user');

const groupSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  users: [
    {
      type: mongoose.Schema.Types.ObjectId,
      ref: User,
      required: true
    }
  ],
  description: {
    type: String,
    required: true
  },
  session_id: {
    type: String,
    required: true,
    unique: true
  }
});

const Group = mongoose.model('Groups', groupSchema);
module.exports = Group;
