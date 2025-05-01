const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const User = require('../models/User');

// Route pour obtenir tous les utilisateurs
router.get('/', async (req, res) => {
  try {
    const users = await User.find();
    res.json(users);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Route pour créer un nouvel utilisateur
router.post('/', async (req, res) => {
  try {
    // Si un ID personnalisé est fourni, le stocker dans un champ 'id'
    if (req.body.id) {
      // Créer une copie du corps de la requête pour éviter de modifier l'original
      const bodyWithCustomId = { ...req.body };
      // Supprimer l'ID du corps principal pour éviter les conflits avec MongoDB
      delete bodyWithCustomId._id;

      // Créer l'utilisateur avec l'ID personnalisé stocké dans un champ 'id'
      const user = new User(bodyWithCustomId);
      const newUser = await user.save();
      res.status(201).json(newUser);
    } else {
      // Création normale sans ID personnalisé
      const user = new User(req.body);
      const newUser = await user.save();
      res.status(201).json(newUser);
    }
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Route pour obtenir un utilisateur spécifique
router.get('/:id', async (req, res) => {
  try {
    let user;

    // Essayer de trouver par ObjectId (MongoDB ID)
    try {
      if (mongoose.Types.ObjectId.isValid(req.params.id)) {
        user = await User.findById(req.params.id);
      }
    } catch (idError) {
      console.log('Erreur lors de la recherche par ObjectId:', idError);
    }

    // Si non trouvé, essayer de trouver par ID personnalisé
    if (!user) {
      user = await User.findOne({ id: req.params.id });
    }

    if (user) {
      res.json(user);
    } else {
      res.status(404).json({ message: 'Utilisateur non trouvé' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Route pour mettre à jour un utilisateur
router.patch('/:id', async (req, res) => {
  try {
    let user;

    // Essayer de mettre à jour par ObjectId (MongoDB ID)
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      user = await User.findByIdAndUpdate(req.params.id, req.body, {
        new: true,
        runValidators: true
      });
    }

    // Si non trouvé, essayer de mettre à jour par ID personnalisé
    if (!user) {
      user = await User.findOneAndUpdate({ id: req.params.id }, req.body, {
        new: true,
        runValidators: true
      });
    }

    if (user) {
      res.json(user);
    } else {
      res.status(404).json({ message: 'Utilisateur non trouvé' });
    }
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Route pour supprimer un utilisateur
router.delete('/:id', async (req, res) => {
  try {
    let user;
    let deleteResult;

    // Essayer de supprimer par ObjectId (MongoDB ID)
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      deleteResult = await User.findByIdAndDelete(req.params.id);
      if (deleteResult) {
        user = deleteResult;
      }
    }

    // Si non trouvé, essayer de supprimer par ID personnalisé
    if (!user) {
      deleteResult = await User.findOneAndDelete({ id: req.params.id });
      if (deleteResult) {
        user = deleteResult;
      }
    }

    if (user) {
      res.json({ message: 'Utilisateur supprimé avec succès' });
    } else {
      res.status(404).json({ message: 'Utilisateur non trouvé' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;