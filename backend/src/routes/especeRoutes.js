const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const cacheService = require('../services/cacheService');

// Route pour obtenir toutes les espèces
router.get('/', async (req, res, next) => {
  try {
    // Utiliser le cache pour récupérer toutes les espèces
    const Espece = require('../models/Espece');

    // Clé de cache basée sur la requête
    const cacheKey = 'especes:all';

    // Récupérer du cache ou de la base de données avec une durée de vie de 30 minutes
    const especes = await cacheService.getOrSet(
      cacheKey,
      async () => await Espece.find().lean(),
      30 * 60 * 1000 // 30 minutes
    );

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
    const {
      nom,
      description,
      imageUrl,
      nomScientifique,
      prixMinimal,
      prixMoyen,
      confiance,
      source,
      alternatives,
      saison,
      habitat,
      methodePeche
    } = req.body;

    if (!nom) {
      return res.error('Le nom de l\'espèce est requis', 400);
    }

    // Créer une nouvelle espèce
    const Espece = require('../models/Espece');
    const nouvelleEspece = new Espece({
      nom,
      description: description || '',
      imageUrl: imageUrl || '/images/default-fish.jpg',
      nomScientifique: nomScientifique || '',
      prixMinimal: prixMinimal || 0,
      prixMoyen: prixMoyen || 0,
      confiance: confiance || 1.0,
      source: source || 'manuel',
      alternatives: alternatives || [],
      saison: saison || '',
      habitat: habitat || '',
      methodePeche: methodePeche || ''
    });

    // Sauvegarder l'espèce dans la base de données
    const especeSauvegardee = await nouvelleEspece.save();

    // Invalider le cache des espèces
    cacheService.invalidate('especes:all');

    res.success(especeSauvegardee, 'Espèce créée avec succès', 201);
  } catch (error) {
    next(error);
  }
});

// Route pour rechercher une espèce par nom
router.get('/nom/:nom', async (req, res, next) => {
  try {
    const nom = req.params.nom;

    // Rechercher l'espèce dans la base de données en utilisant l'index texte
    const Espece = require('../models/Espece');

    // Utiliser l'index texte si le nom contient plusieurs mots
    let espece;
    if (nom.includes(' ')) {
      // Recherche par index texte pour les requêtes complexes
      espece = await Espece.findOne(
        { $text: { $search: nom } },
        { score: { $meta: "textScore" } }
      ).sort({ score: { $meta: "textScore" } });
    } else {
      // Recherche par regex pour les requêtes simples
      espece = await Espece.findOne({ nom: { $regex: nom, $options: 'i' } });
    }

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
    const id = req.params.id;

    // Clé de cache basée sur l'ID
    const cacheKey = `especes:id:${id}`;

    // Utiliser le cache pour récupérer l'espèce
    const espece = await cacheService.getOrSet(
      cacheKey,
      async () => {
        const Espece = require('../models/Espece');
        let espece;

        // Essayer de trouver par ObjectId (MongoDB ID)
        if (mongoose.Types.ObjectId.isValid(id)) {
          espece = await Espece.findById(id).lean();
        }

        // Si non trouvé, essayer de trouver par ID personnalisé
        if (!espece) {
          espece = await Espece.findOne({ id: id }).lean();
        }

        if (!espece) {
          // Si l'espèce n'est pas trouvée, retourner une espèce par défaut
          return {
            id: id,
            nom: 'Espèce inconnue',
            description: 'Description non disponible'
          };
        }

        return espece;
      },
      15 * 60 * 1000 // 15 minutes
    );

    res.json(espece);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Route pour classifier une espèce de poisson
router.post('/classify', async (req, res, next) => {
  try {
    const { nom, confiance, source, alternatives } = req.body;

    if (!nom) {
      return res.error('Le nom de l\'espèce est requis', 400);
    }

    const Espece = require('../models/Espece');

    // Chercher si l'espèce existe déjà
    let espece = await Espece.findOne({
      $or: [
        { nom: { $regex: new RegExp('^' + nom + '$', 'i') } },
        { 'alternatives.nom': { $regex: new RegExp('^' + nom + '$', 'i') } }
      ]
    });

    // Si l'espèce existe, mettre à jour la confiance et les alternatives
    if (espece) {
      // Mettre à jour seulement si la nouvelle confiance est plus élevée
      if (!espece.confiance || confiance > espece.confiance) {
        espece.confiance = confiance;
        espece.source = source || espece.source;
      }

      // Ajouter les nouvelles alternatives si elles n'existent pas déjà
      if (alternatives && alternatives.length > 0) {
        const existingAlts = espece.alternatives || [];
        const newAlts = alternatives.filter(alt =>
          !existingAlts.some(existing => existing.nom === alt.nom)
        );

        espece.alternatives = [...existingAlts, ...newAlts];
      }

      await espece.save();

      // Invalider le cache
      cacheService.invalidate(`especes:${espece._id}`);
      cacheService.invalidate('especes:all');

      return res.success(espece, 'Espèce mise à jour avec succès');
    }

    // Si l'espèce n'existe pas, créer une nouvelle espèce
    const nouvelleEspece = new Espece({
      nom,
      description: req.body.description || `Espèce de poisson: ${nom}`,
      imageUrl: req.body.imageUrl || '/images/default-fish.jpg',
      nomScientifique: req.body.nomScientifique || '',
      confiance: confiance || 1.0,
      source: source || 'api',
      alternatives: alternatives || [],
      prixMinimal: req.body.prixMinimal || 0,
      prixMoyen: req.body.prixMoyen || 0,
      saison: req.body.saison || '',
      habitat: req.body.habitat || '',
      methodePeche: req.body.methodePeche || ''
    });

    const especeSauvegardee = await nouvelleEspece.save();

    // Invalider le cache
    cacheService.invalidate('especes:all');

    // Créer une notification pour les administrateurs
    try {
      const notificationService = require('../services/notificationService');
      const Admin = require('../models/Admin');

      const admins = await Admin.find();
      for (const admin of admins) {
        await notificationService.notifierAdmin(
          admin._id,
          'Nouvelle espèce détectée',
          `Une nouvelle espèce de poisson a été détectée: ${nom}`,
          'info',
          {
            reference: especeSauvegardee._id,
            referenceModel: 'Espece',
            urlAction: `/admin/especes/${especeSauvegardee._id}`
          }
        );
      }
    } catch (notifError) {
      console.error('Erreur lors de l\'envoi des notifications:', notifError);
      // Ne pas bloquer la création de l'espèce si les notifications échouent
    }

    res.success(especeSauvegardee, 'Nouvelle espèce créée avec succès', 201);
  } catch (error) {
    next(error);
  }
});

module.exports = router;