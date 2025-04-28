const express = require('express');
const router = express.Router();
const Pecheur = require('../models/Pecheur');

// Route pour obtenir tous les pêcheurs
router.get('/', async (req, res) => {
  try {
    const pecheurs = await Pecheur.find().populate('prises');
    res.json(pecheurs);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Route pour créer un nouveau pêcheur
router.post('/', async (req, res) => {
  const pecheur = new Pecheur(req.body);
  try {
    const newPecheur = await pecheur.save();
    res.status(201).json(newPecheur);
  } catch (error) {
    res.status(400).json({ message: error.message });
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