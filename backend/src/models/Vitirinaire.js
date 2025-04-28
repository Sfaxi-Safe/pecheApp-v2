const mongoose = require('mongoose');
const validator = require('validator');
const bcrypt = require('bcryptjs');

const vitirinaireSchema = new mongoose.Schema({
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
    enum: ['ROLE_VETERINAIRE']
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
  telephone: String,
  isValid: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

// Hash du mot de passe avant sauvegarde
vitirinaireSchema.pre('save', async function(next) {
  if (this.isModified('password')) {
    this.password = await bcrypt.hash(this.password, 8);
  }
  next();
});

// Méthode pour vérifier le mot de passe
vitirinaireSchema.methods.comparePassword = async function(password) {
  return bcrypt.compare(password, this.password);
};

const Vitirinaire = mongoose.model('Vitirinaire', vitirinaireSchema);

module.exports = Vitirinaire;