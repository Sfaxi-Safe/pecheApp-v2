const mongoose = require('mongoose');

const priseSchema = new mongoose.Schema({
  pecheur: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Pecheur',
    required: [true, 'Pêcheur est requis']
  },
  espece: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Espece',
    required: [true, 'Espèce est requise']
  },
  quantite: {
    type: Number,
    required: [true, 'Quantité est requise'],
    min: [0, 'La quantité ne peut pas être négative']
  },
  poids: {
    type: Number,
    required: [true, 'Poids est requis'],
    min: [0, 'Le poids ne peut pas être négatif']
  },
  date_peche: {
    type: Date,
    required: [true, 'Date de pêche est requise'],
    default: Date.now
  },
  zone_peche: {
    type: String,
    required: [true, 'Zone de pêche est requise']
  },
  methode_peche: {
    type: String,
    required: [true, 'Méthode de pêche est requise']
  },
  qualite: {
    type: String,
    enum: ['excellente', 'bonne', 'moyenne', 'mauvaise'],
    default: 'bonne'
  },
  lot: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Lot'
  },
  notes: String,
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const Prise = mongoose.model('Prise', priseSchema);

module.exports = Prise;