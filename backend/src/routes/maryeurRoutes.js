const express = require('express');
const router = express.Router();
const Maryeur = require('../models/Maryeur');

// Route pour obtenir tous les mareyeurs
router.get('/', async (req, res) => {
  try {
    const maryeurs = await Maryeur.find();
    res.json(maryeurs);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Route pour créer un nouveau mareyeur
router.post('/', async (req, res) => {
  const maryeur = new Maryeur(req.body);
  try {
    const newMaryeur = await maryeur.save();
    res.status(201).json(newMaryeur);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Route pour obtenir un mareyeur spécifique
router.get('/:id', async (req, res) => {
  try {
    const maryeur = await Maryeur.findById(req.params.id);
    if (maryeur) {
      res.json(maryeur);
    } else {
      res.status(404).json({ message: 'Mareyeur non trouvé' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Route pour mettre à jour un mareyeur
router.patch('/:id', async (req, res) => {
  try {
    const maryeur = await Maryeur.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(maryeur);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

module.exports = router;