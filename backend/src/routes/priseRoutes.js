/**
 * Routes pour la gestion des prises de pêche
 * Implémentation avec gestion d'erreurs standardisée
 */
const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const Prise = require('../models/Prise');
const { auth, checkRole } = require('../middleware/auth');
const { NotFoundError, BadRequestError } = require('../middleware/errorHandler');

/**
 * @route GET /api/prises
 * @desc Récupérer toutes les prises
 * @access Public
 */
router.get('/', async (req, res, next) => {
  try {
    // Filtres optionnels
    const filter = {};

    // Filtrer par pêcheur si spécifié
    if (req.query.pecheur) {
      filter.pecheur = req.query.pecheur;
    }

    // Filtrer par mareyeur si spécifié
    if (req.query.maryeur) {
      filter.maryeur = req.query.maryeur;
    }

    // Filtrer par date de début si spécifiée
    if (req.query.dateDebut) {
      filter.debut = { $gte: new Date(req.query.dateDebut) };
    }

    // Filtrer par date de fin si spécifiée
    if (req.query.dateFin) {
      filter.fin = { $lte: new Date(req.query.dateFin) };
    }

    const prises = await Prise.find(filter)
      .populate('pecheur', 'nom prenom bateau matricule')
      .populate('maryeur', 'nom prenom matricule');

    res.success(prises, 'Liste des prises récupérée avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route POST /api/prises
 * @desc Créer une nouvelle prise
 * @access Private (Pêcheur, Mareyeur ou Admin)
 */
router.post('/', auth, checkRole(['ROLE_PECHEUR', 'ROLE_MARYEUR', 'ROLE_ADMIN']), async (req, res, next) => {
  try {
    // Validation des données
    if (!req.body.pecheur || !req.body.maryeur || !req.body.nom) {
      throw new BadRequestError('Pêcheur, mareyeur et nom sont requis');
    }

    // Ajouter le vétérinaire si fourni
    if (req.body.veterinaire) {
      console.log(`[${new Date().toISOString()}] INFO [PRISE] Vétérinaire spécifié pour la prise: ${req.body.veterinaire}`);
    }

    // Vérifier que les dates sont valides
    if (req.body.debut && req.body.fin) {
      const debut = new Date(req.body.debut);
      const fin = new Date(req.body.fin);

      if (isNaN(debut.getTime()) || isNaN(fin.getTime())) {
        throw new BadRequestError('Dates de début et de fin invalides');
      }

      if (debut > fin) {
        throw new BadRequestError('La date de début doit être antérieure à la date de fin');
      }
    } else {
      throw new BadRequestError('Dates de début et de fin requises');
    }

    // Définir les dates d'affectation et de débarquement si non fournies
    if (!req.body.affectationDate) {
      req.body.affectationDate = new Date();
    }

    if (!req.body.dateDebarquement) {
      req.body.dateDebarquement = new Date();
    }

    // Convertir les coordonnées en nombres si elles sont fournies
    if (req.body.latitude) {
      req.body.latitude = parseFloat(req.body.latitude);
    }

    if (req.body.longitude) {
      req.body.longitude = parseFloat(req.body.longitude);
    }

    const prise = new Prise(req.body);
    const newPrise = await prise.save();

    // Récupérer la prise avec les relations peuplées
    const populatedPrise = await Prise.findById(newPrise._id)
      .populate('pecheur', 'nom prenom bateau matricule')
      .populate('maryeur', 'nom prenom matricule')
      .populate('veterinaire', 'nom prenom matricule');

    res.created(populatedPrise, 'Prise créée avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route GET /api/prises/:id
 * @desc Récupérer une prise spécifique
 * @access Public
 */
router.get('/:id', async (req, res, next) => {
  try {
    let prise;

    // Essayer de trouver par ObjectId (MongoDB ID)
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      prise = await Prise.findById(req.params.id)
        .populate('pecheur', 'nom prenom bateau matricule')
        .populate('maryeur', 'nom prenom matricule')
        .populate('veterinaire', 'nom prenom matricule');
    }

    if (!prise) {
      throw new NotFoundError('Prise non trouvée');
    }

    res.success(prise, 'Prise récupérée avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route PATCH /api/prises/:id
 * @desc Mettre à jour une prise
 * @access Private (Pêcheur, Mareyeur ou Admin)
 */
router.patch('/:id', auth, checkRole(['ROLE_PECHEUR', 'ROLE_MARYEUR', 'ROLE_ADMIN']), async (req, res, next) => {
  try {
    // Vérifier que les dates sont valides si elles sont fournies
    if (req.body.debut && req.body.fin) {
      const debut = new Date(req.body.debut);
      const fin = new Date(req.body.fin);

      if (isNaN(debut.getTime()) || isNaN(fin.getTime())) {
        throw new BadRequestError('Dates de début et de fin invalides');
      }

      if (debut > fin) {
        throw new BadRequestError('La date de début doit être antérieure à la date de fin');
      }
    }

    let prise;

    // Essayer de mettre à jour par ObjectId (MongoDB ID)
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      prise = await Prise.findByIdAndUpdate(req.params.id, req.body, {
        new: true,
        runValidators: true
      });
    }

    if (!prise) {
      throw new NotFoundError('Prise non trouvée');
    }

    // Récupérer la prise mise à jour avec les relations peuplées
    const populatedPrise = await Prise.findById(prise._id)
      .populate('pecheur', 'nom prenom bateau matricule')
      .populate('maryeur', 'nom prenom matricule')
      .populate('veterinaire', 'nom prenom matricule');

    res.success(populatedPrise, 'Prise mise à jour avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route DELETE /api/prises/:id
 * @desc Supprimer une prise
 * @access Private (Admin uniquement)
 */
router.delete('/:id', auth, checkRole('ROLE_ADMIN'), async (req, res, next) => {
  try {
    let prise;

    // Essayer de supprimer par ObjectId (MongoDB ID)
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      prise = await Prise.findByIdAndDelete(req.params.id);
    }

    if (!prise) {
      throw new NotFoundError('Prise non trouvée');
    }

    res.success(null, 'Prise supprimée avec succès');
  } catch (error) {
    next(error);
  }
});

module.exports = router;