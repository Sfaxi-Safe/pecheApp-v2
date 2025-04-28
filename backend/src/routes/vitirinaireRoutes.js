const express = require('express');
const router = express.Router();
const Vitirinaire = require('../models/Vitirinaire');

// Route pour obtenir tous les vétérinaires
router.get('/', async (req, res) => {
  try {
    const vitirinaires = await Vitirinaire.find();
    res.json(vitirinaires);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Route pour créer un nouveau vétérinaire
router.post('/', async (req, res) => {
  const vitirinaire = new Vitirinaire(req.body);
  try {
    const newVitirinaire = await vitirinaire.save();
    res.status(201).json(newVitirinaire);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Route pour obtenir un vétérinaire spécifique
router.get('/:id', async (req, res) => {
  try {
    const vitirinaire = await Vitirinaire.findById(req.params.id);
    if (vitirinaire) {
      res.json(vitirinaire);
    } else {
      res.status(404).json({ message: 'Vétérinaire non trouvé' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Route pour mettre à jour un vétérinaire
router.patch('/:id', async (req, res) => {
  try {
    const vitirinaire = await Vitirinaire.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(vitirinaire);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

module.exports = router;