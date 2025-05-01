const mongoose = require('mongoose');
const validator = require('validator');
const bcrypt = require('bcryptjs');

const maryeurSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true,
    validate: [validator.isEmail, 'Email invalide']
  },
  roles: {
    type: String,
    required: true,
    default: 'ROLE_MARYEUR'
  },
  password: {
    type: String,
    required: true,
    minlength: 6
  },
  nom: {
    type: String,
    required: true,
    trim: true
  },
  prenom: {
    type: String,
    required: true,
    trim: true
  },
  cin: {
    type: String,
    required: true,
    unique: true
  },
  matricule: {
    type: String,
    required: true,
    unique: true
  },
  port: String,
  pays: String,
  wallet: String,
  mykeyss: String,
  telephone: {
    type: String,
    required: true
  },
  isValidated: {
    type: Boolean,
    default: false
  },
  isValid: {
    type: Boolean,
    default: false
  },
  isBlocked: {
    type: Boolean,
    default: false
  },
  photo: String,
  signature: String,
  userType: {
    type: String,
    default: 'maryeur'
  }
}, {
  timestamps: true,
  toJSON: {
    virtuals: true,
    transform: function(doc, ret) {
      ret.id = ret._id;
      delete ret._id;
      delete ret.__v;
      delete ret.password;
      return ret;
    }
  }
});

// Hash du mot de passe avant sauvegarde
maryeurSchema.pre('save', async function(next) {
  if (this.isModified('password')) {
    this.password = await bcrypt.hash(this.password, 8);
  }
  next();
});

// Méthode pour vérifier le mot de passe
maryeurSchema.methods.comparePassword = async function(password) {
  return bcrypt.compare(password, this.password);
};

// Méthodes pour vérifier les rôles (adaptées pour roles en tant que string)
maryeurSchema.methods.hasRole = function(role) {
  return this.roles.includes(role);
};

maryeurSchema.methods.isPecheur = function() {
  return this.hasRole('ROLE_PECHEUR');
};

maryeurSchema.methods.isVeterinaire = function() {
  return this.hasRole('ROLE_VETERINAIRE');
};

maryeurSchema.methods.isMaryeur = function() {
  return this.hasRole('ROLE_MARYEUR');
};

maryeurSchema.methods.isClient = function() {
  return this.hasRole('ROLE_CLIENT');
};

maryeurSchema.methods.isAdmin = function() {
  return this.hasRole('ROLE_ADMIN');
};

// Méthode pour déterminer le type d'utilisateur
maryeurSchema.methods.getUserType = function() {
  return 'maryeur';
};

const Maryeur = mongoose.model('Maryeur', maryeurSchema);

module.exports = Maryeur;