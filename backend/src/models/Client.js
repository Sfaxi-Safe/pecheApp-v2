/**
 * Modèle Client
 * Représente un client dans l'application SeaTrace
 * Stocke les informations personnelles et d'authentification du client
 */

const mongoose = require('mongoose');
const validator = require('validator');
const bcrypt = require('bcryptjs');

const clientSchema = new mongoose.Schema({
  /**
   * ID personnalisé pour le client
   * Utilisé pour les requêtes API et la cohérence avec le frontend
   */
  id: {
    type: String,
    unique: true,
    sparse: true // Permet que certains documents n'aient pas ce champ
  },

  /**
   * Adresse email du client
   * Utilisée pour l'authentification et les communications
   */
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true,
    validate: [validator.isEmail, 'Email invalide']
  },

  /**
   * Rôles du client
   * Stockés sous forme de chaîne de caractères pour correspondre au frontend
   */
  roles: {
    type: String,
    required: true,
    default: 'ROLE_CLIENT'
  },

  /**
   * Mot de passe du client
   * Stocké sous forme hachée pour la sécurité
   */
  password: {
    type: String,
    required: true,
    minlength: 6
  },

  /**
   * Nom de famille du client
   */
  nom: {
    type: String,
    required: true,
    trim: true
  },

  /**
   * Prénom du client
   */
  prenom: {
    type: String,
    required: true,
    trim: true
  },

  /**
   * Numéro de téléphone du client
   */
  telephone: {
    type: String,
    required: false
  },

  /**
   * Adresse du client
   */
  adresse: {
    type: String,
    required: false
  },

  /**
   * Ville du client
   */
  ville: {
    type: String,
    required: false
  },

  /**
   * Code postal du client
   */
  codePostal: {
    type: String,
    required: false
  },

  /**
   * Pays du client
   */
  pays: {
    type: String,
    required: false
  },

  /**
   * Indique si le compte a été validé par un administrateur
   */
  isValidated: {
    type: Boolean,
    default: true // Les clients sont validés par défaut
  },

  /**
   * Indique si le compte est bloqué
   */
  isBlocked: {
    type: Boolean,
    default: false
  },

  /**
   * URL ou chemin vers la photo de profil
   */
  photo: String,

  /**
   * Type d'utilisateur (toujours 'client' pour ce modèle)
   */
  userType: {
    type: String,
    default: 'client'
  },

  /**
   * Historique des achats du client
   * Référence aux lots achetés
   */
  achats: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Lot'
  }]
}, {
  timestamps: true,
  toJSON: {
    virtuals: true,
    transform: function(_, ret) {
      // Si un ID personnalisé existe, l'utiliser, sinon utiliser l'ID MongoDB
      if (!ret.id) {
        ret.id = ret._id;
      }
      delete ret._id;
      delete ret.__v;
      delete ret.password;
      return ret;
    }
  }
});

/**
 * Middleware: Hash du mot de passe avant sauvegarde
 * Exécuté automatiquement avant chaque sauvegarde du document
 * Hache le mot de passe uniquement s'il a été modifié
 */
clientSchema.pre('save', async function(next) {
  if (this.isModified('password')) {
    this.password = await bcrypt.hash(this.password, 8);
  }
  next();
});

/**
 * Middleware: Gestion de l'ID personnalisé
 * Exécuté automatiquement avant chaque sauvegarde du document
 * Si aucun ID personnalisé n'est fourni, utilise l'ID MongoDB
 */
clientSchema.pre('save', function(next) {
  // Si un ID personnalisé est fourni dans la requête, l'utiliser
  if (this.id) {
    // L'ID personnalisé est déjà défini, ne rien faire
  } else if (this._id) {
    // Sinon, utiliser l'ID MongoDB comme ID personnalisé
    this.id = this._id.toString();
  }
  next();
});

/**
 * Méthode: Vérification du mot de passe
 * Compare le mot de passe fourni avec le mot de passe haché stocké
 * @param {string} password - Mot de passe en clair à vérifier
 * @returns {Promise<boolean>} - True si le mot de passe correspond, false sinon
 */
clientSchema.methods.comparePassword = async function(password) {
  return bcrypt.compare(password, this.password);
};

/**
 * Méthode: Obtention du type d'utilisateur
 * @returns {string} - Toujours 'client' pour ce modèle
 */
clientSchema.methods.getUserType = function() {
  return 'client';
};

const Client = mongoose.model('Client', clientSchema);

module.exports = Client;
