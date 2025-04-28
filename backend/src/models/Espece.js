const mongoose = require('mongoose');

const especeSchema = new mongoose.Schema({
  nom: {
    type: String,
    required: true,
    unique: true
  },
  nomScientifique: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  caracteristiques: {
    tailleMoyenne: {
      type: Number,
      required: true
    },
    poidsMoyen: {
      type: Number,
      required: true
    },
    saisonPeche: [{
      type: String,
      enum: ['PRINTEMPS', 'ETE', 'AUTOMNE', 'HIVER']
    }]
  },
  zonesPeche: [{
    type: String,
    required: true
  }],
  reglementation: {
    tailleMinimaleLegale: Number,
    periodeInterdite: {
      debut: Date,
      fin: Date
    },
    quotaJournalier: Number
  },
  photo: String,
  statut: {
    type: String,
    enum: ['AUTORISE', 'RESTREINT', 'INTERDIT'],
    default: 'AUTORISE'
  },
  prixMoyen: {
    type: Number,
    required: true
  }
}, {
  timestamps: true
});

const Espece = mongoose.model('Espece', especeSchema);

module.exports = Espece;