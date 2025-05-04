const mongoose = require('mongoose');

const lotSchema = new mongoose.Schema({
  rfid: {
    type: String,
    unique: true
  },
  veterinaire: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Veterinaire'
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
    ref: 'Client'
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

// Ajouter des index pour améliorer les performances des requêtes
lotSchema.index({ veterinaire: 1 });
lotSchema.index({ prise: 1 });
lotSchema.index({ espece: 1 });
lotSchema.index({ acheteur: 1 });
lotSchema.index({ test: 1, status: 1 });
lotSchema.index({ vendu: 1 });
lotSchema.index({ prixInitial: 1 });
lotSchema.index({ dateSoumission: -1 });

const Lot = mongoose.model('Lot', lotSchema);

module.exports = Lot;