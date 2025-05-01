/**
 * Routes pour les vétérinaires
 */
const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
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

    // Si un ID personnalisé est fourni, le stocker dans un champ 'id'
    if (req.body.id) {
      // Créer une copie du corps de la requête pour éviter de modifier l'original
      const bodyWithCustomId = { ...req.body };
      // Supprimer l'ID du corps principal pour éviter les conflits avec MongoDB
      delete bodyWithCustomId._id;

      // Créer le vétérinaire avec l'ID personnalisé stocké dans un champ 'id'
      const veterinaire = new Veterinaire(bodyWithCustomId);
      const newVeterinaire = await veterinaire.save();
      res.created(newVeterinaire, 'Vétérinaire créé avec succès');
    } else {
      // Création normale sans ID personnalisé
      const veterinaire = new Veterinaire(req.body);
      const newVeterinaire = await veterinaire.save();
      res.created(newVeterinaire, 'Vétérinaire créé avec succès');
    }
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
    let veterinaire;

    // Essayer de trouver par ObjectId (MongoDB ID)
    try {
      if (mongoose.Types.ObjectId.isValid(req.params.id)) {
        veterinaire = await Veterinaire.findById(req.params.id);
      }
    } catch (idError) {
      console.log('Erreur lors de la recherche par ObjectId:', idError);
    }

    // Si non trouvé, essayer de trouver par ID personnalisé
    if (!veterinaire) {
      veterinaire = await Veterinaire.findOne({ id: req.params.id });
    }

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

    let veterinaire;

    // Essayer de mettre à jour par ObjectId (MongoDB ID)
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      veterinaire = await Veterinaire.findByIdAndUpdate(req.params.id, req.body, {
        new: true,
        runValidators: true
      });
    }

    // Si non trouvé, essayer de mettre à jour par ID personnalisé
    if (!veterinaire) {
      veterinaire = await Veterinaire.findOneAndUpdate({ id: req.params.id }, req.body, {
        new: true,
        runValidators: true
      });
    }

    if (!veterinaire) {
      return res.error('Vétérinaire non trouvé', 404);
    }

    res.success(veterinaire, 'Vétérinaire mis à jour avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route DELETE /api/veterinaires/:id
 * @desc Supprimer un vétérinaire
 * @access Private (Admin uniquement)
 */
router.delete('/:id', auth, checkRole('ROLE_ADMIN'), async (req, res, next) => {
  try {
    let veterinaire;
    let deleteResult;

    // Essayer de supprimer par ObjectId (MongoDB ID)
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      deleteResult = await Veterinaire.findByIdAndDelete(req.params.id);
      if (deleteResult) {
        veterinaire = deleteResult;
      }
    }

    // Si non trouvé, essayer de supprimer par ID personnalisé
    if (!veterinaire) {
      deleteResult = await Veterinaire.findOneAndDelete({ id: req.params.id });
      if (deleteResult) {
        veterinaire = deleteResult;
      }
    }

    if (!veterinaire) {
      return res.error('Vétérinaire non trouvé', 404);
    }

    res.success(null, 'Vétérinaire supprimé avec succès');
  } catch (error) {
    next(error);
  }
});

module.exports = router;
