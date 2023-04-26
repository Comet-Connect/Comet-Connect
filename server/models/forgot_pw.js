// Packages
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const nodemailer = require('nodemailer');
const crypto = require('crypto');

// Config
const config = require('../../comet_connect_app/assets/config/config.json')

const forgotPwSchema = new mongoose.Schema({
    email: {
        type: String,
        unique: true,
        required: true,
        ref: 'User'
    },
    reset_code: {
        type: String,
        required: true,
    },
    expireAt: {
        type: Date,
        default: Date.now(),
        // time in seconds, after which the entry will be deleted.
        expires: 120}
})

forgotPwSchema.statics.generateVerificationCode = function() {
    return crypto.randomBytes(4).toString('hex');
};

forgotPwSchema.post("save", async function (doc) {
    var transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
            user: config.email.user,
            pass: config.email.password
        }
    })

    var emailBody = config.email.forgot_pw_email_body + this.reset_code
    var email = {
        from: config.email.user,
        to: this.email,
        subject: config.email.forgot_pw_subject_line,
        text: emailBody
    };

    transporter.sendMail(email, function(error, info) {
        if (error) {
            console.log(error);
        } else {
            console.log('Email sent: ' + info.response);
        }
    })
});

const ForgotPassword = mongoose.model('forgot_password', forgotPwSchema);
module.exports = ForgotPassword;