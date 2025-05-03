const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');

// Route pour obtenir toutes les espèces
router.get('/', async (req, res, next) => {
  try {
    // Récupérer toutes les espèces depuis la base de données
    const Espece = require('../models/Espece');
    const especes = await Espece.find();

    // Si aucune espèce n'est trouvée, retourner des espèces par défaut
    if (!especes || especes.length === 0) {
      const defaultEspeces = [{
        id: 1,
        nom: 'Thon',
        description: 'Poisson pélagique',
        imageUrl: '/images/thon.jpg'
      }, {
        id: 2,
        nom: 'Sardine',
        description: 'Petit poisson pélagique',
        imageUrl: '/images/sardine.jpg'
      }, {
        id: 3,
        nom: 'Dorade',
        description: 'Poisson de mer',
        imageUrl: '/images/dorade.jpg'
      }, {
        id: 4,
        nom: 'Merlu',
        description: 'Poisson de fond',
        imageUrl: '/images/merlu.jpg'
      }];

      return res.success(defaultEspeces, 'Liste des espèces par défaut');
    }

    res.success(especes, 'Liste des espèces récupérée avec succès');
  } catch (error) {
    next(error);
  }
});

// Route pour créer une nouvelle espèce
router.post('/', async (req, res, next) => {
  try {
    const { nom, description, imageUrl } = req.body;

    if (!nom) {
      return res.error('Le nom de l\'espèce est requis', 400);
    }

    // Créer une nouvelle espèce
    const Espece = require('../models/Espece');
    const nouvelleEspece = new Espece({
      nom,
      description: description || '',
      imageUrl: imageUrl || ''
    });

    // Sauvegarder l'espèce dans la base de données
    const especeSauvegardee = await nouvelleEspece.save();

    res.success(especeSauvegardee, 'Espèce créée avec succès', 201);
  } catch (error) {
    next(error);
  }
});

// Route pour rechercher une espèce par nom
router.get('/nom/:nom', async (req, res, next) => {
  try {
    const nom = req.params.nom;

    // Rechercher l'espèce dans la base de données
    const Espece = require('../models/Espece');
    const espece = await Espece.findOne({ nom: { $regex: nom, $options: 'i' } });

    if (!espece) {
      return res.success(null, 'Aucune espèce trouvée avec ce nom');
    }

    res.success(espece, 'Espèce trouvée avec succès');
  } catch (error) {
    next(error);
  }
});

// Route pour obtenir une espèce spécifique
router.get('/:id', async (req, res) => {
  try {
    // Rechercher l'espèce dans la base de données
    const Espece = require('../models/Espece');
    let espece;

    // Essayer de trouver par ObjectId (MongoDB ID)
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      espece = await Espece.findById(req.params.id);
    }

    // Si non trouvé, essayer de trouver par ID personnalisé
    if (!espece) {
      espece = await Espece.findOne({ id: req.params.id });
    }

    if (!espece) {
      // Si l'espèce n'est pas trouvée, retourner une espèce par défaut
      espece = {
        id: req.params.id,
        nom: 'Espèce inconnue',
        description: 'Description non disponible'
      };
    }

    res.json(espece);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;