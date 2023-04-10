// Creating Calendars Schema
const mongoose = require('mongoose');
const { Schema } = mongoose;

const calendarSchema = new Schema({
  name: {
    type: String,
    required: true,
  },
  owner: {
    type: Schema.Types.ObjectId,
    ref: 'User',
  },
  events: [
    {
        type: Schema.Types.ObjectId,
        ref: 'Event',
    }
  ], default: []
});

const Calendar = mongoose.model('Calendar', calendarSchema);

module.exports = Calendar;
