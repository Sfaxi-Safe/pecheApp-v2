/**
 * Modèle User
 * Représente un utilisateur standard (client ou admin) dans l'application SeaTrace
 * Stocke les informations personnelles et d'authentification de l'utilisateur
 */

const mongoose = require('mongoose');
const validator = require('validator');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  /**
   * ID personnalisé pour l'utilisateur
   * Utilisé pour les requêtes API et la cohérence avec le frontend
   */
  id: {
    type: String,
    unique: true,
    sparse: true // Permet que certains documents n'aient pas ce champ
  },

  /**
   * Adresse email de l'utilisateur
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
   * Rôles de l'utilisateur
   * Stockés sous forme de chaîne de caractères pour correspondre au frontend
   * Utilisés pour la gestion des autorisations
   */
  roles: {
    type: String,
    required: true,
    default: 'ROLE_CLIENT'
  },

  /**
   * Mot de passe de l'utilisateur
   * Stocké sous forme hachée pour la sécurité
   */
  password: {
    type: String,
    required: true,
    minlength: 6
  },

  /**
   * Nom de famille de l'utilisateur
   */
  nom: {
    type: String,
    required: true,
    trim: true
  },

  /**
   * Prénom de l'utilisateur
   */
  prenom: {
    type: String,
    required: true,
    trim: true
  },

  /**
   * Numéro de téléphone de l'utilisateur
   */
  telephone: {
    type: String,
    required: false
  },

  /**
   * Indique si le compte a été validé par un administrateur
   */
  isValidated: {
    type: Boolean,
    default: false
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
   * Service auquel appartient l'utilisateur (pour les clients professionnels)
   */
  service: String,

  /**
   * Fonction de l'utilisateur dans son service
   */
  fonction: String
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
userSchema.pre('save', async function(next) {
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
userSchema.pre('save', function(next) {
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
userSchema.methods.comparePassword = async function(password) {
  return bcrypt.compare(password, this.password);
};

/**
 * Méthode: Vérification de rôle
 * Vérifie si l'utilisateur possède un rôle spécifique
 * @param {string} role - Le rôle à vérifier
 * @returns {boolean} - True si l'utilisateur possède le rôle, false sinon
 */
userSchema.methods.hasRole = function(role) {
  return this.roles.includes(role);
};

/**
 * Méthode: Vérification du rôle Pêcheur
 * @returns {boolean} - True si l'utilisateur est un pêcheur
 */
userSchema.methods.isPecheur = function() {
  return this.hasRole('ROLE_PECHEUR');
};

/**
 * Méthode: Vérification du rôle Vétérinaire
 * @returns {boolean} - True si l'utilisateur est un vétérinaire
 */
userSchema.methods.isVeterinaire = function() {
  return this.hasRole('ROLE_VETERINAIRE');
};

/**
 * Méthode: Vérification du rôle Mareyeur
 * @returns {boolean} - True si l'utilisateur est un mareyeur
 */
userSchema.methods.isMaryeur = function() {
  return this.hasRole('ROLE_MARYEUR');
};

/**
 * Méthode: Vérification du rôle Client
 * @returns {boolean} - True si l'utilisateur est un client
 */
userSchema.methods.isClient = function() {
  return this.hasRole('ROLE_CLIENT');
};

/**
 * Méthode: Vérification du rôle Administrateur
 * @returns {boolean} - True si l'utilisateur est un administrateur
 */
userSchema.methods.isAdmin = function() {
  return this.hasRole('ROLE_ADMIN');
};

/**
 * Méthode: Obtention du type d'utilisateur
 * Détermine le type d'utilisateur en fonction de son rôle
 * @returns {string} - Le type d'utilisateur ('pecheur', 'veterinaire', 'maryeur', 'admin' ou 'client')
 */
userSchema.methods.getUserType = function() {
  if (this.isPecheur()) return 'pecheur';
  if (this.isVeterinaire()) return 'veterinaire';
  if (this.isMaryeur()) return 'maryeur';
  if (this.isAdmin()) return 'admin';
  return 'client';
};

const User = mongoose.model('User', userSchema);

module.exports = User;