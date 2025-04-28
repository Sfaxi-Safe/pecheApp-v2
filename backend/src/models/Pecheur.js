const mongoose = require('mongoose');

const pecheurSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  matricule: {
    type: String,
    required: true,
    unique: true
  },
  dateNaissance: {
    type: Date,
    required: true
  },
  lieuNaissance: {
    type: String,
    required: true
  },
  nationalite: {
    type: String,
    required: true
  },
  typePiece: {
    type: String,
    required: true,
    enum: ['CIN', 'PASSPORT', 'CARTE_SEJOUR']
  },
  numeroPiece: {
    type: String,
    required: true,
    unique: true
  },
  dateDelivrance: {
    type: Date,
    required: true
  },
  lieuDelivrance: {
    type: String,
    required: true
  },
  adresse: {
    type: String,
    required: true
  },
  ville: {
    type: String,
    required: true
  },
  pays: {
    type: String,
    required: true
  },
  telephone: {
    type: String,
    required: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true
  },
  status: {
    type: String,
    enum: ['ACTIF', 'INACTIF', 'SUSPENDU'],
    default: 'ACTIF'
  },
  photo: String,
  documents: [{
    type: String
  }]
}, {
  timestamps: true
});

const Pecheur = mongoose.model('Pecheur', pecheurSchema);

module.exports = Pecheur;