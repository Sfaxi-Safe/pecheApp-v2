/**
 * Routes pour les maryeurs (mareyeurs)
 */
const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const Maryeur = require('../models/Maryeur');
const { auth, checkRole } = require('../middleware/auth');

/**
 * @route GET /api/maryeurs
 * @desc Récupérer tous les mareyeurs actifs (validés et non bloqués)
 * @access Public
 */
router.get('/', async (req, res, next) => {
  try {
    // Par défaut, ne récupérer que les mareyeurs validés et non bloqués
    let filter = { isValidated: true, isBlocked: false };

    // Si le paramètre all=true est fourni et que l'utilisateur est admin, récupérer tous les mareyeurs
    if (req.query.all === 'true' && req.user && req.user.isAdmin()) {
      filter = {};
    }

    const maryeurs = await Maryeur.find(filter);
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

    // Si un ID personnalisé est fourni, le stocker dans un champ 'id'
    if (req.body.id) {
      // Créer une copie du corps de la requête pour éviter de modifier l'original
      const bodyWithCustomId = { ...req.body };
      // Supprimer l'ID du corps principal pour éviter les conflits avec MongoDB
      delete bodyWithCustomId._id;

      // Créer le mareyeur avec l'ID personnalisé stocké dans un champ 'id'
      const maryeur = new Maryeur(bodyWithCustomId);
      const newMaryeur = await maryeur.save();
      res.created(newMaryeur, 'Mareyeur créé avec succès');
    } else {
      // Création normale sans ID personnalisé
      const maryeur = new Maryeur(req.body);
      const newMaryeur = await maryeur.save();
      res.created(newMaryeur, 'Mareyeur créé avec succès');
    }
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
    let maryeur;

    // Essayer de trouver par ObjectId (MongoDB ID)
    try {
      if (mongoose.Types.ObjectId.isValid(req.params.id)) {
        maryeur = await Maryeur.findById(req.params.id);
      }
    } catch (idError) {
      console.log('Erreur lors de la recherche par ObjectId:', idError);
    }

    // Si non trouvé, essayer de trouver par ID personnalisé
    if (!maryeur) {
      maryeur = await Maryeur.findOne({ id: req.params.id });
    }

    if (!maryeur) {
      return res.error('Mareyeur non trouvé', 404);
    }

    // Créer un objet de réponse avec des valeurs par défaut pour les champs null
    const maryeurResponse = {
      id: maryeur.id || maryeur._id.toString(),
      email: maryeur.email || '',
      roles: maryeur.roles || 'ROLE_MARYEUR',
      nom: maryeur.nom || '',
      prenom: maryeur.prenom || '',
      telephone: maryeur.telephone || '',
      photo: maryeur.photo || '',
      societe: maryeur.societe || '',
      registre: maryeur.registre || '',
      adresse: maryeur.adresse || '',
      cin: maryeur.cin || '',
      matricule: maryeur.matricule || '',
      port: maryeur.port || '',
      pays: maryeur.pays || '',
      isValidated: maryeur.isValidated || maryeur.isValid || false,
      isBlocked: maryeur.isBlocked || false
    };

    // Journaliser les informations renvoyées
    console.log(`[${new Date().toISOString()}] INFO [MARYEUR] Détails mareyeur récupérés: ${maryeurResponse.prenom} ${maryeurResponse.nom} (ID: ${maryeurResponse.id})`);

    res.success(maryeurResponse, 'Mareyeur récupéré avec succès');
  } catch (error) {
    console.log(`[${new Date().toISOString()}] ERROR [MARYEUR] Erreur lors de la récupération du mareyeur: ${error.message}`);
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

    let maryeur;

    // Essayer de mettre à jour par ObjectId (MongoDB ID)
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      maryeur = await Maryeur.findByIdAndUpdate(req.params.id, req.body, {
        new: true,
        runValidators: true
      });
    }

    // Si non trouvé, essayer de mettre à jour par ID personnalisé
    if (!maryeur) {
      maryeur = await Maryeur.findOneAndUpdate({ id: req.params.id }, req.body, {
        new: true,
        runValidators: true
      });
    }

    if (!maryeur) {
      return res.error('Mareyeur non trouvé', 404);
    }

    res.success(maryeur, 'Mareyeur mis à jour avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route DELETE /api/maryeurs/:id
 * @desc Supprimer un mareyeur
 * @access Private (Admin uniquement)
 */
router.delete('/:id', auth, checkRole('ROLE_ADMIN'), async (req, res, next) => {
  try {
    let maryeur;
    let deleteResult;

    // Essayer de supprimer par ObjectId (MongoDB ID)
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      deleteResult = await Maryeur.findByIdAndDelete(req.params.id);
      if (deleteResult) {
        maryeur = deleteResult;
      }
    }

    // Si non trouvé, essayer de supprimer par ID personnalisé
    if (!maryeur) {
      deleteResult = await Maryeur.findOneAndDelete({ id: req.params.id });
      if (deleteResult) {
        maryeur = deleteResult;
      }
    }

    if (!maryeur) {
      return res.error('Mareyeur non trouvé', 404);
    }

    res.success(null, 'Mareyeur supprimé avec succès');
  } catch (error) {
    next(error);
  }
});

module.exports = router;