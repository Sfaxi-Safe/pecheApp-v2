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
  roles: [{
    type: String,
    required: true,
    enum: ['ROLE_CLIENT', 'ROLE_ADMIN']
  }],
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
  isVerified: {
    type: Boolean,
    default: false
  },
  isBlocked: {
    type: Boolean,
    default: false
  },
  civilite: String,
  service: String,
  fonction: String,
  mobile: String,
  linkedin: String,
  facebook: String,
  twitter: String,
  photo: String,
  isValid: {
    type: Boolean,
    default: false
  },
  adresse: String
}, {
  timestamps: true
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

const User = mongoose.model('User', userSchema);

module.exports = User;