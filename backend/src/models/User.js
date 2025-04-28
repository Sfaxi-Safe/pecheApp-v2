const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const validator = require('validator');

const userSchema = new mongoose.Schema({
  email: {
    type: String,
    required: [true, 'Email est requis'],
    unique: true,
    lowercase: true,
    validate: [validator.isEmail, 'Email invalide']
  },
  password: {
    type: String,
    required: [true, 'Mot de passe est requis'],
    minlength: [8, 'Le mot de passe doit contenir au moins 8 caractères']
  },
  role: {
    type: String,
    enum: ['admin', 'pecheur', 'maryeur', 'vitirinaire'],
    default: 'pecheur'
  },
  nom: {
    type: String,
    required: [true, 'Nom est requis']
  },
  prenom: {
    type: String,
    required: [true, 'Prénom est requis']
  },
  telephone: {
    type: String,
    required: [true, 'Numéro de téléphone est requis']
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Crypter le mot de passe avant de sauvegarder
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

// Méthode pour vérifier le mot de passe
userSchema.methods.comparePassword = async function(candidatePassword) {
  return await bcrypt.compare(candidatePassword, this.password);
};

const User = mongoose.model('User', userSchema);

module.exports = User;