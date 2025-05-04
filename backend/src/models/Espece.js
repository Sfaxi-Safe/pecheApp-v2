const mongoose = require('mongoose');

const especeSchema = new mongoose.Schema({
  nom: {
    type: String,
    required: true,
    trim: true
  },
  imageUrl: {
    type: String,
    required: true
  },
  description: {
    type: String,
    trim: true
  },
  nomScientifique: {
    type: String,
    trim: true
  },
  prixMinimal: {
    type: Number,
    default: 0
  },
  prixMoyen: {
    type: Number,
    default: 0
  },
  isActive: {
    type: Boolean,
    default: true
  },
  // Nouvelles propriétés pour la classification des poissons
  confiance: {
    type: Number,
    default: 1.0
  },
  source: {
    type: String,
    enum: ['manuel', 'api', 'tensorflow', 'google_vision'],
    default: 'manuel'
  },
  alternatives: [{
    nom: String,
    nomScientifique: String,
    confiance: Number
  }],
  // Propriétés pour la traçabilité
  saison: {
    type: String,
    trim: true
  },
  habitat: {
    type: String,
    trim: true
  },
  methodePeche: {
    type: String,
    trim: true
  }
}, {
  timestamps: true
});

// Ajouter un index texte pour améliorer les performances de recherche
especeSchema.index({ nom: 'text', nomScientifique: 'text' });

// Ajouter des index pour les champs fréquemment utilisés dans les requêtes
especeSchema.index({ nom: 1 });
especeSchema.index({ isActive: 1 });
especeSchema.index({ prixMinimal: 1 });
especeSchema.index({ prixMoyen: 1 });

const Espece = mongoose.model('Espece', especeSchema);

module.exports = Espece;