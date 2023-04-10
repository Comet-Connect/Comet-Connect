// Creating User Schema
const mongoose = require('mongoose');
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
  last_name: String,
  calendar: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Calendar'
  }
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
  // connection.collection('user').insert(newUser)
  return newUser.save();
}

const User = mongoose.model('User', userSchema);

// Update an existing user document
// const user = await User.findOne({ email: 'johndoe@example.com' });
// user.password = 'newpassword456';
// await user.save();


// // Query for all user documents
// const allUsers = await User.find();


// // Query for a specific user document by ID
// const userById = await User.findById('1234567890abcdef');


// // Delete a user document
// await User.deleteOne({ email: 'johndoe@example.com' });

module.exports = User;
