const mongoose = require('mongoose');

const lotSchema = new mongoose.Schema({
  rfid: {
    type: String,
    unique: true
  },
  vitirinaire: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Vitirinaire'
  },
  identifiant: {
    type: String,
    required: true,
    unique: true
  },
  photo: String,
  quantite: Number,
  poids: Number,
  espece: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Espece',
    required: true
  },
  temperature: Number,
  prixInitial: Number,
  prixMinimal: Number,
  prixFinal: Number,
  dateTest: Date,
  test: {
    type: Boolean,
    default: false
  },
  status: {
    type: Boolean,
    default: false
  },
  vendu: {
    type: Boolean,
    default: false
  },
  prise: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Prise',
    required: true
  },
  acheteur: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  dateSoumission: Date,
  poidsEstimatif: Number,
  typeEnchere: String,
  current: String,
  online: String,
  isProduit: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

const Lot = mongoose.model('Lot', lotSchema);

module.exports = Lot;