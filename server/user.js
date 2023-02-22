// Creating User Schema
const mongoose = require('mongoose');  // Using Mongoose
const Schema = mongoose.Schema;

const userSchema = new Schema({
    email: {
        type: String,
        required: true
    },
    username: {
        type: String
    },
    password: {
        type: String,
        required: true
    },
}, {timestamps: true})

const User = mongoose.model('users', userSchema);
module.exports = User;

