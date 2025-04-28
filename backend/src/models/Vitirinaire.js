const mongoose = require('mongoose');

const vitirinaireSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Utilisateur est requis']
  },
  numero_ordre: {
    type: String,
    required: [true, 'Numéro d\'ordre est requis'],
    unique: true
  },
  specialite: {
    type: String,
    required: [true, 'Spécialité est requise']
  },
  zone_intervention: {
    type: String,
    required: [true, 'Zone d\'intervention est requise']
  },
  disponibilite: {
    type: Boolean,
    default: true
  },
  lots_inspectes: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Lot'
  }],
  rapports: [{
    date: Date,
    description: String,
    lot: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Lot'
    }
  }],
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const Vitirinaire = mongoose.model('Vitirinaire', vitirinaireSchema);

module.exports = Vitirinaire;