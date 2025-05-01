const mongoose = require('mongoose');
const validator = require('validator');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
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
        return v.every(role => ['ROLE_ADMIN', 'ROLE_CLIENT', 'ROLE_PECHEUR', 'ROLE_MARYEUR', 'ROLE_VETERINAIRE'].includes(role));
      },
      message: props => `${props.value} contient un rôle invalide`
    },
    default: ['ROLE_CLIENT']
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
  adresse: String,
  photo: String,
  // Champs supplémentaires pour correspondre au frontend
  service: String,
  fonction: String,
  userType: {
    type: String,
    enum: ['client', 'pecheur', 'veterinaire', 'maryeur', 'admin'],
    default: 'client'
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
userSchema.pre('save', async function(next) {
  if (this.isModified('password')) {
    this.password = await bcrypt.hash(this.password, 8);
  }
  next();
});

// Méthode pour vérifier le mot de passe
userSchema.methods.comparePassword = async function(password) {
  return bcrypt.compare(password, this.password);
};

// Méthodes pour vérifier les rôles
userSchema.methods.hasRole = function(role) {
  return this.roles.includes(role);
};

userSchema.methods.isPecheur = function() {
  return this.hasRole('ROLE_PECHEUR');
};

userSchema.methods.isVeterinaire = function() {
  return this.hasRole('ROLE_VETERINAIRE');
};

userSchema.methods.isMaryeur = function() {
  return this.hasRole('ROLE_MARYEUR');
};

userSchema.methods.isClient = function() {
  return this.hasRole('ROLE_CLIENT');
};

userSchema.methods.isAdmin = function() {
  return this.hasRole('ROLE_ADMIN');
};

// Méthode pour déterminer le type d'utilisateur
userSchema.methods.getUserType = function() {
  if (this.isPecheur()) return 'pecheur';
  if (this.isVeterinaire()) return 'veterinaire';
  if (this.isMaryeur()) return 'maryeur';
  if (this.isAdmin()) return 'admin';
  return 'client';
};

const User = mongoose.model('User', userSchema);

module.exports = User;