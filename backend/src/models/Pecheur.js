/**
 * Modèle Pecheur
 * Représente un pêcheur dans l'application SeaTrace
 * Stocke les informations personnelles et professionnelles du pêcheur
 * ainsi que ses prises de pêche
 */

const mongoose = require('mongoose');
const validator = require('validator');
const bcrypt = require('bcryptjs');

const pecheurSchema = new mongoose.Schema({
  /**
   * ID personnalisé pour le pêcheur
   * Utilisé pour les requêtes API et la cohérence avec le frontend
   */
  id: {
    type: String,
    unique: true,
    sparse: true // Permet que certains documents n'aient pas ce champ
  },

  /**
   * Liste des prises de pêche associées à ce pêcheur
   * Référence aux documents de la collection Prise
   */
  prises: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Prise'
  }],

  /**
   * Adresse email du pêcheur
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
   * Stockés sous forme de chaîne de caractères
   * Utilisés pour la gestion des autorisations
   */
  roles: {
    type: String,
    required: true,
    default: 'ROLE_PECHEUR'
  },

  /**
   * Mot de passe du pêcheur
   * Stocké sous forme hachée pour la sécurité
   */
  password: {
    type: String,
    required: true,
    minlength: 6
  },

  /**
   * Nom de famille du pêcheur
   */
  nom: {
    type: String,
    required: true,
    trim: true
  },

  /**
   * Prénom du pêcheur
   */
  prenom: {
    type: String,
    required: true,
    trim: true
  },

  /**
   * Numéro de carte d'identité nationale
   * Unique pour chaque pêcheur
   */
  cin: {
    type: String,
    required: true,
    unique: true
  },

  /**
   * Matricule professionnel du pêcheur
   * Unique pour chaque pêcheur
   */
  matricule: {
    type: String,
    required: true,
    unique: true
  },

  // Informations sur le bateau et l'activité de pêche
  capacite: String,     // Capacité de pêche en tonnes
  longeur: String,      // Longueur du bateau en mètres
  largeur: String,      // Largeur du bateau en mètres
  bateau: String,       // Nom du bateau
  pays: String,         // Pays d'origine
  proprietaire: String, // Propriétaire du bateau
  serie: String,        // Numéro de série du bateau
  certification: String,// Certifications obtenues
  port: String,         // Port d'attache
  engin: String,        // Type d'engin de pêche utilisé

  // Informations pour la blockchain
  wallet: String,       // Adresse du portefeuille blockchain
  mykeyss: String,      // Clé privée (à sécuriser davantage)

  /**
   * Numéro de téléphone du pêcheur
   */
  telephone: {
    type: String,
    required: true
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
   * Type d'utilisateur (pour la discrimination)
   */
  userType: {
    type: String,
    default: 'pecheur'
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
pecheurSchema.pre('save', async function(next) {
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
pecheurSchema.pre('save', function(next) {
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
pecheurSchema.methods.comparePassword = async function(password) {
  return bcrypt.compare(password, this.password);
};

/**
 * Méthode: Vérification de rôle
 * Vérifie si l'utilisateur possède un rôle spécifique
 * @param {string} role - Le rôle à vérifier
 * @returns {boolean} - True si l'utilisateur possède le rôle, false sinon
 */
pecheurSchema.methods.hasRole = function(role) {
  return this.roles.includes(role);
};

/**
 * Méthode: Vérification du rôle Pêcheur
 * @returns {boolean} - True si l'utilisateur est un pêcheur
 */
pecheurSchema.methods.isPecheur = function() {
  return this.hasRole('ROLE_PECHEUR');
};

/**
 * Méthode: Vérification du rôle Vétérinaire
 * @returns {boolean} - True si l'utilisateur est un vétérinaire
 */
pecheurSchema.methods.isVeterinaire = function() {
  return this.hasRole('ROLE_VETERINAIRE');
};

/**
 * Méthode: Vérification du rôle Mareyeur
 * @returns {boolean} - True si l'utilisateur est un mareyeur
 */
pecheurSchema.methods.isMaryeur = function() {
  return this.hasRole('ROLE_MARYEUR');
};

/**
 * Méthode: Vérification du rôle Client
 * @returns {boolean} - True si l'utilisateur est un client
 */
pecheurSchema.methods.isClient = function() {
  return this.hasRole('ROLE_CLIENT');
};

/**
 * Méthode: Vérification du rôle Administrateur
 * @returns {boolean} - True si l'utilisateur est un administrateur
 */
pecheurSchema.methods.isAdmin = function() {
  return this.hasRole('ROLE_ADMIN');
};

/**
 * Méthode: Obtention du type d'utilisateur
 * @returns {string} - Le type d'utilisateur ('pecheur')
 */
pecheurSchema.methods.getUserType = function() {
  return 'pecheur';
};

const Pecheur = mongoose.model('Pecheur', pecheurSchema);

module.exports = Pecheur;