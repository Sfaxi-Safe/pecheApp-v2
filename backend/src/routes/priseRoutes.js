const express = require('express');
const router = express.Router();
const Prise = require('../models/Prise');

// Route pour obtenir toutes les prises
router.get('/', async (req, res) => {
  try {
    const prises = await Prise.find()
      .populate('pecheur')
      .populate('maryeur');
    res.json(prises);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Route pour créer une nouvelle prise
router.post('/', async (req, res) => {
  const prise = new Prise(req.body);
  try {
    const newPrise = await prise.save();
    res.status(201).json(newPrise);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Route pour obtenir une prise spécifique
router.get('/:id', async (req, res) => {
  try {
    const prise = await Prise.findById(req.params.id)
      .populate('pecheur')
      .populate('maryeur');
    if (prise) {
      res.json(prise);
    } else {
      res.status(404).json({ message: 'Prise non trouvée' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Route pour mettre à jour une prise
router.patch('/:id', async (req, res) => {
  try {
    const prise = await Prise.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(prise);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

module.exports = router;