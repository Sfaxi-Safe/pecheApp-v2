const mongoose = require('mongoose');

const lotSchema = new mongoose.Schema({
  numero: {
    type: String,
    required: true,
    unique: true
  },
  pecheur: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Pecheur',
    required: true
  },
  datePeche: {
    type: Date,
    required: true
  },
  lieuPeche: {
    type: String,
    required: true
  },
  poids: {
    type: Number,
    required: true,
    min: 0
  },
  especes: [{
    espece: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Espece',
      required: true
    },
    quantite: {
      type: Number,
      required: true,
      min: 0
    },
    poids: {
      type: Number,
      required: true,
      min: 0
    }
  }],
  temperature: {
    type: Number,
    required: true
  },
  qualite: {
    type: String,
    enum: ['EXCELLENTE', 'BONNE', 'MOYENNE', 'MAUVAISE'],
    required: true
  },
  statut: {
    type: String,
    enum: ['EN_ATTENTE', 'VERIFIE', 'VALIDE', 'REJETE'],
    default: 'EN_ATTENTE'
  },
  notes: String,
  photos: [String]
}, {
  timestamps: true
});

const Lot = mongoose.model('Lot', lotSchema);

module.exports = Lot;