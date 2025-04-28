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
  roles: [{
    type: String,
    required: true,
    enum: ['ROLE_PECHEUR']
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
  telephone: String,
  isValid: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
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

const Pecheur = mongoose.model('Pecheur', pecheurSchema);

module.exports = Pecheur;