/**
 * Routes pour les pêcheurs
 */
const express = require('express');
const router = express.Router();
const Pecheur = require('../models/Pecheur');
const { auth, checkRole } = require('../middleware/auth');

/**
 * @route GET /api/pecheurs
 * @desc Récupérer tous les pêcheurs
 * @access Public
 */
router.get('/', async (req, res, next) => {
  try {
    const pecheurs = await Pecheur.find().populate('prises');
    res.success(pecheurs, 'Liste des pêcheurs récupérée avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route POST /api/pecheurs
 * @desc Créer un nouveau pêcheur
 * @access Private (Admin)
 */
router.post('/', auth, checkRole('ROLE_ADMIN'), async (req, res, next) => {
  try {
    // Assurer que le rôle est correctement défini
    if (!req.body.roles) {
      req.body.roles = 'ROLE_PECHEUR';
    }

    const pecheur = new Pecheur(req.body);
    const newPecheur = await pecheur.save();
    res.created(newPecheur, 'Pêcheur créé avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route GET /api/pecheurs/:id
 * @desc Récupérer un pêcheur spécifique
 * @access Public
 */
router.get('/:id', async (req, res, next) => {
  try {
    const pecheur = await Pecheur.findById(req.params.id).populate('prises');
    if (!pecheur) {
      return res.error('Pêcheur non trouvé', 404);
    }
    res.success(pecheur, 'Pêcheur récupéré avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route PATCH /api/pecheurs/:id
 * @desc Mettre à jour un pêcheur
 * @access Private (Admin ou le pêcheur lui-même)
 */
router.patch('/:id', auth, async (req, res, next) => {
  try {
    // Vérifier si l'utilisateur est autorisé à modifier ce pêcheur
    if (!req.user.isAdmin() && req.user._id.toString() !== req.params.id) {
      return res.error('Non autorisé à modifier ce pêcheur', 403);
    }

    // Empêcher la modification du rôle par un non-admin
    if (!req.user.isAdmin() && req.body.roles) {
      delete req.body.roles;
    }

    const pecheur = await Pecheur.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });

    if (!pecheur) {
      return res.error('Pêcheur non trouvé', 404);
    }

    res.success(pecheur, 'Pêcheur mis à jour avec succès');
  } catch (error) {
    next(error);
  }
});

module.exports = router;