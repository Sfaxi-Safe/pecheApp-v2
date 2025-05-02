/**
 * Modèle Admin
 * Représente un administrateur dans l'application SeaTrace
 * Stocke les informations personnelles et d'authentification de l'administrateur
 */

const mongoose = require('mongoose');
const validator = require('validator');
const bcrypt = require('bcryptjs');

const adminSchema = new mongoose.Schema({
  /**
   * ID personnalisé pour l'administrateur
   * Utilisé pour les requêtes API et la cohérence avec le frontend
   */
  id: {
    type: String,
    unique: true,
    sparse: true // Permet que certains documents n'aient pas ce champ
  },

  /**
   * Adresse email de l'administrateur
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
   * Rôles de l'administrateur
   * Stockés sous forme de chaîne de caractères pour correspondre au frontend
   */
  roles: {
    type: String,
    required: true,
    default: 'ROLE_ADMIN'
  },

  /**
   * Mot de passe de l'administrateur
   * Stocké sous forme hachée pour la sécurité
   */
  password: {
    type: String,
    required: true,
    minlength: 6
  },

  /**
   * Nom de famille de l'administrateur
   */
  nom: {
    type: String,
    required: true,
    trim: true
  },

  /**
   * Prénom de l'administrateur
   */
  prenom: {
    type: String,
    required: true,
    trim: true
  },

  /**
   * Numéro de téléphone de l'administrateur
   */
  telephone: {
    type: String,
    required: false
  },

  /**
   * Indique si le compte a été validé
   * Les administrateurs sont toujours validés par défaut
   */
  isValidated: {
    type: Boolean,
    default: true
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
   * Type d'utilisateur (toujours 'admin' pour ce modèle)
   */
  userType: {
    type: String,
    default: 'admin'
  }
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
adminSchema.pre('save', async function(next) {
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
adminSchema.pre('save', function(next) {
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
adminSchema.methods.comparePassword = async function(password) {
  return bcrypt.compare(password, this.password);
};

/**
 * Méthode: Vérification de rôle
 * Vérifie si l'administrateur possède un rôle spécifique
 * @param {string} role - Le rôle à vérifier
 * @returns {boolean} - True si l'administrateur possède le rôle, false sinon
 */
adminSchema.methods.hasRole = function(role) {
  return this.roles.includes(role);
};

/**
 * Méthode: Vérification du rôle Pêcheur
 * @returns {boolean} - Toujours false pour un administrateur
 */
adminSchema.methods.isPecheur = function() {
  return false;
};

/**
 * Méthode: Vérification du rôle Vétérinaire
 * @returns {boolean} - Toujours false pour un administrateur
 */
adminSchema.methods.isVeterinaire = function() {
  return false;
};

/**
 * Méthode: Vérification du rôle Mareyeur
 * @returns {boolean} - Toujours false pour un administrateur
 */
adminSchema.methods.isMaryeur = function() {
  return false;
};

/**
 * Méthode: Vérification du rôle Client
 * @returns {boolean} - Toujours false pour un administrateur
 */
adminSchema.methods.isClient = function() {
  return false;
};

/**
 * Méthode: Vérification du rôle Administrateur
 * @returns {boolean} - Toujours true pour un administrateur
 */
adminSchema.methods.isAdmin = function() {
  return true;
};

/**
 * Méthode: Obtention du type d'utilisateur
 * @returns {string} - Toujours 'admin' pour ce modèle
 */
adminSchema.methods.getUserType = function() {
  return 'admin';
};

const Admin = mongoose.model('Admin', adminSchema);

module.exports = Admin;
