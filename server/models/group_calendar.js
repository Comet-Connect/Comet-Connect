const mongoose = require('mongoose');

const groupCalendarSchema = new mongoose.Schema ({
    group: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Groups',
    },
    events: [
        {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Event',
        }
    ],
    default: []
});

const groupCalendar = mongoose.model('group_calendar', groupCalendarSchema);
module.exports = groupCalendar;