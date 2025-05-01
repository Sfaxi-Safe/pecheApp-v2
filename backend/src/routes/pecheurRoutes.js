const express = require('express');
const router = express.Router();
const Pecheur = require('../models/Pecheur');

// Route pour obtenir tous les pêcheurs
router.get('/', async (req, res) => {
  try {
    const pecheurs = await Pecheur.find();
    res.json(pecheurs);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Route POST pour ajouter un pêcheur
router.post('/', async (req, res) => {
  try {
    // Validation des données envoyées par le client
    const {mail, password, nom, prenom } = req.body;

    if (!nom || !prenom || !mail || !password) {
      return res.status(400).json({ message: 'Le nom, le prénom, le mail et le password sont obligatoires.' });
    }

    // Création d'une nouvelle instance de Pecheur
    const newPecheur = new Pecheur({
      mail,
      password,
      nom, 
      prenom
    });

    // Enregistrer le pêcheur dans la base de données
    const savedPecheur = await newPecheur.save();

    // Répondre avec les détails du pêcheur ajouté
    res.status(201).json(savedPecheur);
  } catch (error) {
    console.error(error.message);
    res.status(500).json({ message: 'Erreur lors de l\'ajout du pêcheur.' });
  }
});


// Route pour obtenir un pêcheur spécifique
router.get('/:id', async (req, res) => {
  try {
    const pecheur = await Pecheur.findById(req.params.id).populate('prises');
    if (pecheur) {
      res.json(pecheur);
    } else {
      res.status(404).json({ message: 'Pêcheur non trouvé' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Route pour mettre à jour un pêcheur
router.patch('/:id', async (req, res) => {
  try {
    const pecheur = await Pecheur.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(pecheur);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

module.exports = router;