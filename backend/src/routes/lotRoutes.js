const express = require('express');
const router = express.Router();

// Route pour obtenir tous les lots
router.get('/', async (req, res) => {
  try {
    res.json([{
      id: 1,
      prise_id: 1,
      quantite: 100,
      prix: 1500,
      date: new Date()
    }]);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Route pour créer un nouveau lot
router.post('/', async (req, res) => {
  try {
    res.status(201).json(req.body);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Route pour obtenir un lot spécifique
router.get('/:id', async (req, res) => {
  try {
    const lot = {
      id: req.params.id,
      prise_id: 1,
      quantite: 100,
      prix: 1500,
      date: new Date()
    };
    res.json(lot);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;