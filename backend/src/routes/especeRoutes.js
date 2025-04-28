const express = require('express');
const router = express.Router();

// Route pour obtenir toutes les espèces
router.get('/', async (req, res) => {
  try {
    res.json([{
      id: 1,
      nom: 'Thon',
      description: 'Poisson pélagique'
    }, {
      id: 2,
      nom: 'Sardine',
      description: 'Petit poisson pélagique'
    }]);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Route pour créer une nouvelle espèce
router.post('/', async (req, res) => {
  try {
    res.status(201).json(req.body);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

// Route pour obtenir une espèce spécifique
router.get('/:id', async (req, res) => {
  try {
    const espece = {
      id: req.params.id,
      nom: 'Thon',
      description: 'Poisson pélagique'
    };
    res.json(espece);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;