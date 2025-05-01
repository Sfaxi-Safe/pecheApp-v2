const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('./User');

const veterinaireSchema = new mongoose.Schema({
  // Champs spécifiques aux vétérinaires
  specialite: {
    type: String,
    required: false
  },
  certification: {
    type: String,
    required: false
  },
  matricule: {
    type: String,
    required: true,
    unique: true
  },
  cin: {
    type: String,
    required: true,
    unique: true
  },
  port: String,
  pays: String,
  userType: {
    type: String,
    default: 'veterinaire'
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

// Méthode pour comparer les mots de passe
veterinaireSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

// Avant de sauvegarder, hacher le mot de passe s'il a été modifié
veterinaireSchema.pre('save', async function(next) {
  if (this.isModified('password')) {
    this.password = await bcrypt.hash(this.password, 10);
  }
  next();
});

// Ajouter automatiquement le rôle ROLE_VETERINAIRE
veterinaireSchema.pre('save', function(next) {
  if (!this.roles || !this.roles.includes('ROLE_VETERINAIRE')) {
    this.roles = 'ROLE_VETERINAIRE';
  }
  next();
});

// Méthodes pour vérifier les rôles
veterinaireSchema.methods.hasRole = function(role) {
  return this.roles.includes(role);
};

veterinaireSchema.methods.isPecheur = function() {
  return this.hasRole('ROLE_PECHEUR');
};

veterinaireSchema.methods.isVeterinaire = function() {
  return this.hasRole('ROLE_VETERINAIRE');
};

veterinaireSchema.methods.isMaryeur = function() {
  return this.hasRole('ROLE_MARYEUR');
};

veterinaireSchema.methods.isClient = function() {
  return this.hasRole('ROLE_CLIENT');
};

veterinaireSchema.methods.isAdmin = function() {
  return this.hasRole('ROLE_ADMIN');
};

// Méthode pour déterminer le type d'utilisateur
veterinaireSchema.methods.getUserType = function() {
  return 'veterinaire';
};

const Veterinaire = User.discriminator('Veterinaire', veterinaireSchema);

module.exports = Veterinaire;
