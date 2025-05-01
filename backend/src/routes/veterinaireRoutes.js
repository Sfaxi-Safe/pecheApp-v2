/**
 * Routes pour les vétérinaires
 */
const express = require('express');
const router = express.Router();
const Veterinaire = require('../models/Veterinaire');
const { auth, checkRole } = require('../middleware/auth');

/**
 * @route GET /api/veterinaires
 * @desc Récupérer tous les vétérinaires
 * @access Public
 */
router.get('/', async (req, res, next) => {
  try {
    const veterinaires = await Veterinaire.find();
    res.success(veterinaires, 'Liste des vétérinaires récupérée avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route POST /api/veterinaires
 * @desc Créer un nouveau vétérinaire
 * @access Private (Admin)
 */
router.post('/', auth, checkRole('ROLE_ADMIN'), async (req, res, next) => {
  try {
    // Assurer que le rôle est correctement défini
    if (!req.body.roles) {
      req.body.roles = 'ROLE_VETERINAIRE';
    }

    const veterinaire = new Veterinaire(req.body);
    const newVeterinaire = await veterinaire.save();
    res.created(newVeterinaire, 'Vétérinaire créé avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route GET /api/veterinaires/:id
 * @desc Récupérer un vétérinaire spécifique
 * @access Public
 */
router.get('/:id', async (req, res, next) => {
  try {
    const veterinaire = await Veterinaire.findById(req.params.id);
    if (!veterinaire) {
      return res.error('Vétérinaire non trouvé', 404);
    }
    res.success(veterinaire, 'Vétérinaire récupéré avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route PATCH /api/veterinaires/:id
 * @desc Mettre à jour un vétérinaire
 * @access Private (Admin ou le vétérinaire lui-même)
 */
router.patch('/:id', auth, async (req, res, next) => {
  try {
    // Vérifier si l'utilisateur est autorisé à modifier ce vétérinaire
    if (!req.user.isAdmin() && req.user._id.toString() !== req.params.id) {
      return res.error('Non autorisé à modifier ce vétérinaire', 403);
    }

    // Empêcher la modification du rôle par un non-admin
    if (!req.user.isAdmin() && req.body.roles) {
      delete req.body.roles;
    }

    const veterinaire = await Veterinaire.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });

    if (!veterinaire) {
      return res.error('Vétérinaire non trouvé', 404);
    }

    res.success(veterinaire, 'Vétérinaire mis à jour avec succès');
  } catch (error) {
    next(error);
  }
});

module.exports = router;
