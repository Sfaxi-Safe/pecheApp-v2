const mongoose = require('mongoose');
const validator = require('validator');
const bcrypt = require('bcryptjs');


const pecheurSchema = new mongoose.Schema(
  {
    mail: {
      type: String,
      required: [true, 'Le mail est obligatoire.'],
      trim: true,
      minlength: [2, 'Le mail doit contenir au moins 2 caractères.'],
    },
    password: {
      type: String,
      required: [true, 'Le password est obligatoire.'],
      trim: true,
      minlength: [2, 'Le password doit contenir au moins 2 caractères.'],
    },
    nom: {
      type: String,
      required: [true, 'Le nom est obligatoire.'],
      trim: true,
      minlength: [2, 'Le nom doit contenir au moins 2 caractères.'],
    },
    prenom: {
      type: String,
      required: [true, 'Le prénom est obligatoire.'],
      trim: true,
      minlength: [2, 'Le prénom doit contenir au moins 2 caractères.'],
    },
  },
  {
    timestamps: true, // Ajoute createdAt et updatedAt
  }
);

const Pecheur = mongoose.model('Pecheur', pecheurSchema);

module.exports = Pecheur;
