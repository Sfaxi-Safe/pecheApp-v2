const mongoose = require('mongoose');

const priseSchema = new mongoose.Schema({
  pecheur: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Pecheur',
    required: true
  },
  maryeur: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Maryeur',
    required: true
  },
  nom: {
    type: String,
    required: true,
    trim: true
  },
  debut: {
    type: Date,
    required: true
  },
  fin: {
    type: Date,
    required: true
  },
  latitude: String,
  longitude: String,
  engin: String,
  zone: String,
  affectationDate: {
    type: Date,
    required: true
  },
  dateDebarquement: {
    type: Date,
    required: true
  }
}, {
  timestamps: true
});

const Prise = mongoose.model('Prise', priseSchema);

module.exports = Prise;