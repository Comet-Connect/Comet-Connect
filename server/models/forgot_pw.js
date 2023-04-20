// Packages
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const nodemailer = require('nodemailer');
const crypto = require('crypto');

// Config
const config = require('../comet_connect_app/assets/config/config.json')

const forgotPwSchema = new mongoose.Schema({
    email: {
        type: String,
        unique: true,
        required: true,
    },
    reset_code: {
        type: String,
        required: true,
    },
    expireAt: {
        type: Date,
        default: Date.now(),
        // time in seconds, after which the entry will be deleted.
        expires: 30}
})

forgotPwSchema.statics.generateVerificationCode = function() {
    return crypto.randomBytes(8).toString('hex');
};

forgotPwSchema.statics.sendVerificationEmail = function() {
    var transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
            user: config.email.user,
            pass: config.email.password
        }
    })

    var verificationCode = forgotPwSchema.generateVerificationCode()
    var emailBody = config.email.forog_pw_email_body + verificationCode
    var email = {
        from: config.email.user,
        to: this.email,
        subject: config.email.forog_pw_subject_line,
        text: emailBody
    };

    transporter.sendMail(email, function(error, info) {
        if (error) {
            console.log(error);
        } else {
            console.log('Email sent: ' + info.response);
        }
    })
};

const ForgotPassword = mongoose.model('forgotPassword', forgotPwSchema);
module.exports = ForgotPassword;