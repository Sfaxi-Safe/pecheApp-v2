const mongoose = require('mongoose');

const priseSchema = new mongoose.Schema({
  // Référence au pêcheur qui a effectué la prise
  pecheur: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Pecheur',
    required: true
  },

  // Référence au mareyeur qui gère la prise
  maryeur: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Maryeur',
    required: true
  },

  // Référence au vétérinaire qui validera la prise
  veterinaire: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Veterinaire'
  },

  // Nom de la prise (ex: "Prise du 15/05/2025")
  nom: {
    type: String,
    required: true,
    trim: true
  },

  // Date et heure de début de la pêche
  debut: {
    type: Date,
    required: true
  },

  // Date et heure de fin de la pêche
  fin: {
    type: Date,
    required: true
  },

  // Lieu de la pêche (texte descriptif)
  lieu: {
    type: String,
    trim: true
  },

  // Coordonnées géographiques
  latitude: {
    type: Number
  },
  longitude: {
    type: Number
  },

  // Description supplémentaire de la prise
  description: {
    type: String,
    trim: true
  },

  // URL ou chemin vers une photo de la prise
  photo: String,

  // Informations sur la pêche
  engin: String,  // Type d'engin utilisé
  zone: String,   // Zone de pêche

  // Dates importantes
  affectationDate: {
    type: Date,
    required: true
  },
  dateDebarquement: {
    type: Date,
    required: true
  },

  // Statut de validation
  isValid: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

// Ajouter des index pour améliorer les performances des requêtes
priseSchema.index({ pecheur: 1 });
priseSchema.index({ maryeur: 1 });
priseSchema.index({ veterinaire: 1 });
priseSchema.index({ debut: -1 });
priseSchema.index({ fin: -1 });
priseSchema.index({ isValid: 1 });

const Prise = mongoose.model('Prise', priseSchema);

module.exports = Prise;