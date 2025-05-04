/**
 * Routes pour les pêcheurs
 */
const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
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
router.post('/', async (req, res, next) => {
  try {
    // Assurer que le rôle est correctement défini
    if (!req.body.roles) {
      req.body.roles = 'ROLE_PECHEUR';
    }

    // Si un ID personnalisé est fourni, le stocker dans un champ 'id'
    if (req.body.id) {
      // Créer une copie du corps de la requête pour éviter de modifier l'original
      const bodyWithCustomId = { ...req.body };
      // Supprimer l'ID du corps principal pour éviter les conflits avec MongoDB
      delete bodyWithCustomId._id;

      // Créer le pêcheur avec l'ID personnalisé stocké dans un champ 'id'
      const pecheur = new Pecheur(bodyWithCustomId);
      const newPecheur = await pecheur.save();
      res.created(newPecheur, 'Pêcheur créé avec succès');
    } else {
      // Création normale sans ID personnalisé
      const pecheur = new Pecheur(req.body);
      const newPecheur = await pecheur.save();
      res.created(newPecheur, 'Pêcheur créé avec succès');
    }
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
    let pecheur;

    // Essayer de trouver par ObjectId (MongoDB ID)
    try {
      if (mongoose.Types.ObjectId.isValid(req.params.id)) {
        pecheur = await Pecheur.findById(req.params.id).populate('prises');
      }
    } catch (idError) {
      console.log('Erreur lors de la recherche par ObjectId:', idError);
    }

    // Si non trouvé, essayer de trouver par ID personnalisé
    if (!pecheur) {
      pecheur = await Pecheur.findOne({ id: req.params.id }).populate('prises');
    }

    if (!pecheur) {
      return res.error('Pêcheur non trouvé', 404);
    }

    // Créer un objet de réponse avec des valeurs par défaut pour les champs null
    const pecheurResponse = {
      id: pecheur.id || pecheur._id.toString(),
      email: pecheur.email || '',
      roles: pecheur.roles || 'ROLE_PECHEUR',
      nom: pecheur.nom || '',
      prenom: pecheur.prenom || '',
      telephone: pecheur.telephone || '',
      photo: pecheur.photo || '',
      cin: pecheur.cin || '',
      matricule: pecheur.matricule || '',
      bateau: pecheur.bateau || '',
      port: pecheur.port || '',
      pays: pecheur.pays || '',
      capacite: pecheur.capacite || '',
      isValidated: pecheur.isValidated || pecheur.isValid || false,
      isBlocked: pecheur.isBlocked || false,
      prises: pecheur.prises || []
    };

    // Journaliser les informations renvoyées
    console.log(`[${new Date().toISOString()}] INFO [PECHEUR] Détails pêcheur récupérés: ${pecheurResponse.prenom} ${pecheurResponse.nom} (ID: ${pecheurResponse.id})`);

    res.success(pecheurResponse, 'Pêcheur récupéré avec succès');
  } catch (error) {
    console.log(`[${new Date().toISOString()}] ERROR [PECHEUR] Erreur lors de la récupération du pêcheur: ${error.message}`);
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

    let pecheur;

    // Essayer de mettre à jour par ObjectId (MongoDB ID)
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      pecheur = await Pecheur.findByIdAndUpdate(req.params.id, req.body, {
        new: true,
        runValidators: true
      });
    }

    // Si non trouvé, essayer de mettre à jour par ID personnalisé
    if (!pecheur) {
      pecheur = await Pecheur.findOneAndUpdate({ id: req.params.id }, req.body, {
        new: true,
        runValidators: true
      });
    }

    if (!pecheur) {
      return res.error('Pêcheur non trouvé', 404);
    }

    res.success(pecheur, 'Pêcheur mis à jour avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route DELETE /api/pecheurs/:id
 * @desc Supprimer un pêcheur
 * @access Private (Admin uniquement)
 */
router.delete('/:id', auth, checkRole('ROLE_ADMIN'), async (req, res, next) => {
  try {
    let pecheur;
    let deleteResult;

    // Essayer de supprimer par ObjectId (MongoDB ID)
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      deleteResult = await Pecheur.findByIdAndDelete(req.params.id);
      if (deleteResult) {
        pecheur = deleteResult;
      }
    }

    // Si non trouvé, essayer de supprimer par ID personnalisé
    if (!pecheur) {
      deleteResult = await Pecheur.findOneAndDelete({ id: req.params.id });
      if (deleteResult) {
        pecheur = deleteResult;
      }
    }

    if (!pecheur) {
      return res.error('Pêcheur non trouvé', 404);
    }

    res.success(null, 'Pêcheur supprimé avec succès');
  } catch (error) {
    next(error);
  }
});

module.exports = router;