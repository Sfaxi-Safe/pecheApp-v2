const mongoose = require('mongoose');

const maryeurSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Utilisateur est requis']
  },
  certification: {
    type: String,
    required: [true, 'Numéro de certification est requis']
  },
  zone_travail: {
    type: String,
    required: [true, 'Zone de travail est requise']
  },
  experience: {
    type: Number,
    required: [true, 'Années d\'expérience sont requises']
  },
  disponibilite: {
    type: Boolean,
    default: true
  },
  lots_verifies: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Lot'
  }],
  notes: {
    type: String
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const Maryeur = mongoose.model('Maryeur', maryeurSchema);

module.exports = Maryeur;