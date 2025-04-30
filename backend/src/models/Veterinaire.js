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
  // Autres champs spécifiques aux vétérinaires
}, { timestamps: true });

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
  if (!this.roles.includes('ROLE_VETERINAIRE')) {
    this.roles.push('ROLE_VETERINAIRE');
  }
  next();
});

const Veterinaire = User.discriminator('Veterinaire', veterinaireSchema);

module.exports = Veterinaire;
