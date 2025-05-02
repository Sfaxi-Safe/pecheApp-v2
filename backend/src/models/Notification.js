/**
 * Modèle Notification
 * Représente une notification dans l'application SeaTrace
 * Utilisé pour informer les utilisateurs des événements importants
 */

const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  /**
   * Destinataire de la notification
   * Peut être un pêcheur, un vétérinaire, un mareyeur ou un client
   */
  destinataire: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    refPath: 'destinataireModel'
  },

  /**
   * Modèle du destinataire (pour référence dynamique)
   */
  destinataireModel: {
    type: String,
    required: true,
    enum: ['Pecheur', 'Veterinaire', 'Maryeur', 'Client', 'Admin']
  },

  /**
   * Titre de la notification
   */
  titre: {
    type: String,
    required: true,
    trim: true
  },

  /**
   * Contenu de la notification
   */
  contenu: {
    type: String,
    required: true,
    trim: true
  },

  /**
   * Type de notification
   * Utilisé pour le filtrage et l'affichage
   */
  type: {
    type: String,
    required: true,
    enum: ['info', 'success', 'warning', 'error'],
    default: 'info'
  },

  /**
   * Indique si la notification a été lue
   */
  lue: {
    type: Boolean,
    default: false
  },

  /**
   * Référence à l'objet concerné (optionnel)
   * Peut être une prise, un lot, etc.
   */
  reference: {
    type: mongoose.Schema.Types.ObjectId,
    refPath: 'referenceModel'
  },

  /**
   * Modèle de la référence (pour référence dynamique)
   */
  referenceModel: {
    type: String,
    enum: ['Prise', 'Lot', 'Espece']
  },

  /**
   * URL d'action (optionnel)
   * Permet de rediriger l'utilisateur vers une page spécifique
   */
  urlAction: String
}, {
  timestamps: true
});

// Index pour améliorer les performances des requêtes
notificationSchema.index({ destinataire: 1, lue: 1 });
notificationSchema.index({ createdAt: -1 });

const Notification = mongoose.model('Notification', notificationSchema);

module.exports = Notification;
