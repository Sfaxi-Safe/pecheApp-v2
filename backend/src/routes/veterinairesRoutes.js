/**
 * Routes pour la gestion des vétérinaires
 * Implémentation complète avec interaction avec la base de données
 */
const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const Veterinaire = require('../models/Veterinaire');
const Prise = require('../models/Prise');
const { auth, checkRole } = require('../middleware/auth');
const { NotFoundError, BadRequestError, ForbiddenError } = require('../middleware/errorHandler');
const notificationService = require('../services/notificationService');

/**
 * @route GET /api/veterinaires
 * @desc Récupérer tous les vétérinaires
 * @access Public
 */
router.get('/', async (req, res, next) => {
  try {
    // Filtres optionnels
    const filter = {};

    // Filtrer par statut de validation si spécifié
    if (req.query.isValidated !== undefined) {
      filter.isValidated = req.query.isValidated === 'true';
    }

    // Filtrer par statut de blocage si spécifié
    if (req.query.isBlocked !== undefined) {
      filter.isBlocked = req.query.isBlocked === 'true';
    }

    const veterinaires = await Veterinaire.find(filter);
    res.success(veterinaires, 'Liste des vétérinaires récupérée avec succès');
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
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      veterinaire = await Veterinaire.findById(req.params.id);
    }

    // Si non trouvé, essayer de trouver par ID personnalisé
    if (!veterinaire) {
      veterinaire = await Veterinaire.findOne({ id: req.params.id });
    }

    // Si non trouvé, essayer de trouver par email
    if (!veterinaire) {
      veterinaire = await Veterinaire.findOne({ email: req.params.id });
    }

    if (!veterinaire) {
      throw new NotFoundError('Vétérinaire non trouvé');
    }

    // Créer un objet de réponse avec des valeurs par défaut pour les champs null
    const veterinaireResponse = {
      id: veterinaire.id || veterinaire._id.toString(),
      email: veterinaire.email || '',
      roles: veterinaire.roles || 'ROLE_VETERINAIRE',
      nom: veterinaire.nom || '',
      prenom: veterinaire.prenom || '',
      telephone: veterinaire.telephone || '',
      photo: veterinaire.photo || '',
      cin: veterinaire.cin || '',
      specialite: veterinaire.specialite || '',
      licence: veterinaire.licence || '',
      matricule: veterinaire.matricule || '',
      etablissement: veterinaire.etablissement || '',
      adresse: veterinaire.adresse || '',
      isValidated: veterinaire.isValidated || false,
      isBlocked: veterinaire.isBlocked || false
    };

    // Journaliser les informations renvoyées
    console.log(`[${new Date().toISOString()}] INFO [VETERINAIRE] Détails vétérinaire récupérés: ${veterinaireResponse.prenom} ${veterinaireResponse.nom} (ID: ${veterinaireResponse.id})`);

    res.success(veterinaireResponse, 'Vétérinaire récupéré avec succès');
  } catch (error) {
    console.log(`[${new Date().toISOString()}] ERROR [VETERINAIRE] Erreur lors de la récupération du vétérinaire: ${error.message}`);
    next(error);
  }
});

/**
 * @route POST /api/veterinaires
 * @desc Créer un nouveau vétérinaire
 * @access Private (Admin uniquement)
 */
router.post('/', auth, checkRole('ROLE_ADMIN'), async (req, res, next) => {
  try {
    // Vérifier si l'email existe déjà
    const existingVeterinaire = await Veterinaire.findOne({ email: req.body.email });
    if (existingVeterinaire) {
      throw new BadRequestError('Un vétérinaire avec cet email existe déjà');
    }

    // Générer un identifiant unique si non fourni
    if (!req.body.id) {
      req.body.id = `VET-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
    }

    const veterinaire = new Veterinaire(req.body);
    const newVeterinaire = await veterinaire.save();

    res.created(newVeterinaire, 'Vétérinaire créé avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route PATCH /api/veterinaires/:id
 * @desc Mettre à jour un vétérinaire
 * @access Private (Vétérinaire ou Admin)
 */
router.patch('/:id', auth, async (req, res, next) => {
  try {
    // Vérifier si l'utilisateur est autorisé à modifier ce vétérinaire
    const isAdmin = req.user.roles.includes('ROLE_ADMIN');
    const isSelf = req.user._id.toString() === req.params.id ||
                  (req.user.id && req.user.id === req.params.id);

    if (!isAdmin && !isSelf) {
      throw new ForbiddenError('Non autorisé à modifier ce vétérinaire');
    }

    // Empêcher la modification du rôle par un non-admin
    if (!isAdmin && req.body.roles) {
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
      throw new NotFoundError('Vétérinaire non trouvé');
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

    // Essayer de supprimer par ObjectId (MongoDB ID)
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      veterinaire = await Veterinaire.findByIdAndDelete(req.params.id);
    }

    // Si non trouvé, essayer de supprimer par ID personnalisé
    if (!veterinaire) {
      veterinaire = await Veterinaire.findOneAndDelete({ id: req.params.id });
    }

    if (!veterinaire) {
      throw new NotFoundError('Vétérinaire non trouvé');
    }

    res.success(null, 'Vétérinaire supprimé avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route PUT /api/veterinaires/:id/assign-maryeur
 * @desc Assigner un mareyeur à une prise
 * @access Private (Vétérinaire ou Admin)
 */
router.put('/:id/assign-maryeur', auth, checkRole(['ROLE_VETERINAIRE', 'ROLE_ADMIN']), async (req, res, next) => {
  try {
    // Vérifier que les données nécessaires sont présentes
    if (!req.body.priseId || !req.body.maryeurId) {
      throw new BadRequestError('ID de la prise et ID du mareyeur sont requis');
    }

    // Vérifier que la prise existe
    let prise;
    if (mongoose.Types.ObjectId.isValid(req.body.priseId)) {
      prise = await Prise.findById(req.body.priseId);
    }

    if (!prise) {
      throw new NotFoundError('Prise non trouvée');
    }

    // Vérifier que le vétérinaire est bien celui associé à la prise
    if (prise.veterinaire && prise.veterinaire.toString() !== req.user._id.toString()) {
      throw new ForbiddenError('Vous n\'êtes pas le vétérinaire associé à cette prise');
    }

    // Mettre à jour la prise avec le nouveau mareyeur
    prise.maryeur = req.body.maryeurId;
    await prise.save();

    // Récupérer la prise mise à jour avec les relations peuplées
    const populatedPrise = await Prise.findById(prise._id)
      .populate('pecheur', 'nom prenom bateau matricule')
      .populate('maryeur', 'nom prenom matricule')
      .populate('veterinaire', 'nom prenom matricule');

    // Notifier le mareyeur qu'une prise lui a été assignée
    try {
      await notificationService.notifierMaryeur(
        req.body.maryeurId,
        'Nouvelle prise assignée',
        `Une prise vous a été assignée par le vétérinaire ${req.user.prenom} ${req.user.nom}`,
        'info',
        {
          reference: prise._id,
          referenceModel: 'Prise',
          urlAction: `/maryeur/prises/${prise._id}`
        }
      );
    } catch (error) {
      console.error('Erreur lors de l\'envoi de la notification au mareyeur:', error);
    }

    // Notifier le pêcheur que sa prise a été assignée à un nouveau mareyeur
    try {
      await notificationService.notifierPecheur(
        prise.pecheur,
        'Prise assignée à un mareyeur',
        `Votre prise a été validée par le vétérinaire et assignée au mareyeur ${populatedPrise.maryeur.prenom} ${populatedPrise.maryeur.nom}`,
        'info',
        {
          reference: prise._id,
          referenceModel: 'Prise',
          urlAction: `/pecheur/prises/${prise._id}`
        }
      );
    } catch (error) {
      console.error('Erreur lors de l\'envoi de la notification au pêcheur:', error);
    }

    res.success(populatedPrise, 'Mareyeur assigné à la prise avec succès');
  } catch (error) {
    next(error);
  }
});

module.exports = router;
