const express = require('express');
const router = express.Router();
const Veterinaire = require('../models/Veterinaire');

// Route pour obtenir tous les vétérinaires
router.get('/', async (req, res) => {
  try {
    const veterinaires = await Veterinaire.find();
    res.json(veterinaires);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Route pour créer un nouveau vétérinaire
router.post('/', async (req, res) => {
  const veterinaire = new Veterinaire(req.body);
  try {
    const newVeterinaire = await veterinaire.save();
    res.status(201).json(newVeterinaire);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Route pour obtenir un vétérinaire spécifique
router.get('/:id', async (req, res) => {
  try {
    const veterinaire = await Veterinaire.findById(req.params.id);
    if (veterinaire) {
      res.json(veterinaire);
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
    const veterinaire = await Veterinaire.findByIdAndUpdate(req.params.id, req.body, { new: true });
    res.json(veterinaire);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

module.exports = router;
