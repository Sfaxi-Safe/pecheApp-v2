const mongoose = require('mongoose');
const validator = require('validator');
const bcrypt = require('bcryptjs');

const pecheurSchema = new mongoose.Schema({
  prises: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Prise'
  }],
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true,
    validate: [validator.isEmail, 'Email invalide']
  },
  roles: {
    type: [String],
    required: true,
    validate: {
      validator: function(v) {
        return v.includes('ROLE_PECHEUR');
      },
      message: 'Le rôle ROLE_PECHEUR est requis'
    },
    default: ['ROLE_PECHEUR']
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
  capacite: String,
  longeur: String,
  largeur: String,
  bateau: String,
  pays: String,
  proprietaire: String,
  serie: String,
  certification: String,
  port: String,
  engin: String,
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
  userType: {
    type: String,
    default: 'pecheur'
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
pecheurSchema.pre('save', async function(next) {
  if (this.isModified('password')) {
    this.password = await bcrypt.hash(this.password, 8);
  }
  next();
});

// Méthode pour vérifier le mot de passe
pecheurSchema.methods.comparePassword = async function(password) {
  return bcrypt.compare(password, this.password);
};

// Méthodes pour vérifier les rôles
pecheurSchema.methods.hasRole = function(role) {
  return this.roles.includes(role);
};

pecheurSchema.methods.isPecheur = function() {
  return this.hasRole('ROLE_PECHEUR');
};

pecheurSchema.methods.isVeterinaire = function() {
  return this.hasRole('ROLE_VETERINAIRE');
};

pecheurSchema.methods.isMaryeur = function() {
  return this.hasRole('ROLE_MARYEUR');
};

pecheurSchema.methods.isClient = function() {
  return this.hasRole('ROLE_CLIENT');
};

pecheurSchema.methods.isAdmin = function() {
  return this.hasRole('ROLE_ADMIN');
};

// Méthode pour déterminer le type d'utilisateur
pecheurSchema.methods.getUserType = function() {
  return 'pecheur';
};

const Pecheur = mongoose.model('Pecheur', pecheurSchema);

module.exports = Pecheur;