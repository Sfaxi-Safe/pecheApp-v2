/**
 * Routes pour les maryeurs (mareyeurs)
 */
const express = require('express');
const router = express.Router();
const Maryeur = require('../models/Maryeur');
const { auth, checkRole } = require('../middleware/auth');

/**
 * @route GET /api/maryeurs
 * @desc Récupérer tous les mareyeurs
 * @access Public
 */
router.get('/', async (req, res, next) => {
  try {
    const maryeurs = await Maryeur.find();
    res.success(maryeurs, 'Liste des mareyeurs récupérée avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route POST /api/maryeurs
 * @desc Créer un nouveau mareyeur
 * @access Private (Admin)
 */
router.post('/', auth, checkRole('ROLE_ADMIN'), async (req, res, next) => {
  try {
    // Assurer que le rôle est correctement défini
    if (!req.body.roles) {
      req.body.roles = 'ROLE_MARYEUR';
    }

    const maryeur = new Maryeur(req.body);
    const newMaryeur = await maryeur.save();
    res.created(newMaryeur, 'Mareyeur créé avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route GET /api/maryeurs/:id
 * @desc Récupérer un mareyeur spécifique
 * @access Public
 */
router.get('/:id', async (req, res, next) => {
  try {
    const maryeur = await Maryeur.findById(req.params.id);
    if (!maryeur) {
      return res.error('Mareyeur non trouvé', 404);
    }
    res.success(maryeur, 'Mareyeur récupéré avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route PATCH /api/maryeurs/:id
 * @desc Mettre à jour un mareyeur
 * @access Private (Admin ou le mareyeur lui-même)
 */
router.patch('/:id', auth, async (req, res, next) => {
  try {
    // Vérifier si l'utilisateur est autorisé à modifier ce mareyeur
    if (!req.user.isAdmin() && req.user._id.toString() !== req.params.id) {
      return res.error('Non autorisé à modifier ce mareyeur', 403);
    }

    // Empêcher la modification du rôle par un non-admin
    if (!req.user.isAdmin() && req.body.roles) {
      delete req.body.roles;
    }

    const maryeur = await Maryeur.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });

    if (!maryeur) {
      return res.error('Mareyeur non trouvé', 404);
    }

    res.success(maryeur, 'Mareyeur mis à jour avec succès');
  } catch (error) {
    next(error);
  }
});

module.exports = router;