const mongoose = require('mongoose');

const groupMembershipSchema = new mongoose.Schema({
    user_id: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    groups: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Groups'
    }]
})

const groupMembership = mongoose.model('group_membership', groupMembershipSchema);
module.exports = groupMembership