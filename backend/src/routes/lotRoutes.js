/**
 * Routes pour la gestion des lots
 * Implémentation complète avec interaction avec la base de données
 */
const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const Lot = require('../models/Lot');
const Client = require('../models/Client');
const { auth, checkRole } = require('../middleware/auth');
const { NotFoundError, BadRequestError } = require('../middleware/errorHandler');
const notificationService = require('../services/notificationService');

/**
 * @route GET /api/lots
 * @desc Récupérer tous les lots
 * @access Public
 */
router.get('/', async (req, res, next) => {
  try {
    // Filtres optionnels
    const filter = {};

    // Filtrer par statut de vente si spécifié
    if (req.query.vendu !== undefined) {
      filter.vendu = req.query.vendu === 'true';
    }

    // Filtrer par espèce si spécifiée
    if (req.query.espece) {
      filter.espece = req.query.espece;
    }

    // Filtrer par prise si spécifiée
    if (req.query.prise) {
      filter.prise = req.query.prise;
    }

    const lots = await Lot.find(filter)
      .populate('espece', 'nom imageUrl')
      .populate('veterinaire', 'nom prenom')
      .populate('prise', 'nom debut fin')
      .populate('acheteur', 'nom prenom');

    res.success(lots, 'Liste des lots récupérée avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route POST /api/lots
 * @desc Créer un nouveau lot
 * @access Private (Mareyeur ou Admin)
 */
router.post('/', auth, checkRole(['ROLE_MARYEUR', 'ROLE_ADMIN']), async (req, res, next) => {
  try {
    // Validation des données
    if (!req.body.espece || !req.body.prise) {
      throw new BadRequestError('Espèce et prise sont requises');
    }

    // Générer un identifiant unique si non fourni
    if (!req.body.identifiant) {
      req.body.identifiant = `LOT-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
    }

    const lot = new Lot(req.body);
    const newLot = await lot.save();

    // Récupérer le lot avec les relations peuplées
    const populatedLot = await Lot.findById(newLot._id)
      .populate('espece', 'nom imageUrl')
      .populate('veterinaire', 'nom prenom')
      .populate('prise', 'nom debut fin')
      .populate('acheteur', 'nom prenom')
      .populate({
        path: 'prise',
        populate: { path: 'pecheur', select: 'nom prenom' }
      });

    // Notifier tous les vétérinaires qu'un nouveau lot est disponible pour validation
    try {
      await notificationService.notifierTousVeterinaires(
        'Nouveau lot à valider',
        `Un nouveau lot de ${populatedLot.espece ? populatedLot.espece.nom : 'poisson'} est disponible pour validation.`,
        'info',
        {
          reference: newLot._id,
          referenceModel: 'Lot',
          urlAction: `/veterinaire/lots/${newLot._id}`
        }
      );
    } catch (error) {
      console.error('Erreur lors de l\'envoi des notifications:', error);
      // Ne pas bloquer la création du lot si les notifications échouent
    }

    res.created(populatedLot, 'Lot créé avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route GET /api/lots/:id
 * @desc Récupérer un lot spécifique
 * @access Public
 */
router.get('/:id', async (req, res, next) => {
  try {
    let lot;

    // Essayer de trouver par ObjectId (MongoDB ID)
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      lot = await Lot.findById(req.params.id)
        .populate('espece', 'nom imageUrl')
        .populate('veterinaire', 'nom prenom')
        .populate('prise', 'nom debut fin')
        .populate('acheteur', 'nom prenom');
    }

    // Si non trouvé, essayer de trouver par identifiant
    if (!lot) {
      lot = await Lot.findOne({ identifiant: req.params.id })
        .populate('espece', 'nom imageUrl')
        .populate('veterinaire', 'nom prenom')
        .populate('prise', 'nom debut fin')
        .populate('acheteur', 'nom prenom');
    }

    // Si non trouvé, essayer de trouver par RFID
    if (!lot) {
      lot = await Lot.findOne({ rfid: req.params.id })
        .populate('espece', 'nom imageUrl')
        .populate('veterinaire', 'nom prenom')
        .populate('prise', 'nom debut fin')
        .populate('acheteur', 'nom prenom');
    }

    if (!lot) {
      throw new NotFoundError('Lot non trouvé');
    }

    res.success(lot, 'Lot récupéré avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route PATCH /api/lots/:id
 * @desc Mettre à jour un lot
 * @access Private (Mareyeur, Vétérinaire ou Admin)
 */
router.patch('/:id', auth, checkRole(['ROLE_MARYEUR', 'ROLE_VETERINAIRE', 'ROLE_ADMIN']), async (req, res, next) => {
  try {
    let lot;

    // Essayer de mettre à jour par ObjectId (MongoDB ID)
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      lot = await Lot.findByIdAndUpdate(req.params.id, req.body, {
        new: true,
        runValidators: true
      });
    }

    // Si non trouvé, essayer de mettre à jour par identifiant
    if (!lot) {
      lot = await Lot.findOneAndUpdate({ identifiant: req.params.id }, req.body, {
        new: true,
        runValidators: true
      });
    }

    // Si non trouvé, essayer de mettre à jour par RFID
    if (!lot) {
      lot = await Lot.findOneAndUpdate({ rfid: req.params.id }, req.body, {
        new: true,
        runValidators: true
      });
    }

    if (!lot) {
      throw new NotFoundError('Lot non trouvé');
    }

    // Récupérer le lot mis à jour avec les relations peuplées
    const populatedLot = await Lot.findById(lot._id)
      .populate('espece', 'nom imageUrl')
      .populate('veterinaire', 'nom prenom')
      .populate('prise', 'nom debut fin')
      .populate('acheteur', 'nom prenom');

    res.success(populatedLot, 'Lot mis à jour avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route DELETE /api/lots/:id
 * @desc Supprimer un lot
 * @access Private (Admin uniquement)
 */
router.delete('/:id', auth, checkRole('ROLE_ADMIN'), async (req, res, next) => {
  try {
    let lot;

    // Essayer de supprimer par ObjectId (MongoDB ID)
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      lot = await Lot.findByIdAndDelete(req.params.id);
    }

    // Si non trouvé, essayer de supprimer par identifiant
    if (!lot) {
      lot = await Lot.findOneAndDelete({ identifiant: req.params.id });
    }

    // Si non trouvé, essayer de supprimer par RFID
    if (!lot) {
      lot = await Lot.findOneAndDelete({ rfid: req.params.id });
    }

    if (!lot) {
      throw new NotFoundError('Lot non trouvé');
    }

    res.success(null, 'Lot supprimé avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route PATCH /api/lots/:id/test
 * @desc Valider un lot par un vétérinaire
 * @access Private (Vétérinaire ou Admin)
 */
router.patch('/:id/test', auth, checkRole(['ROLE_VETERINAIRE', 'ROLE_ADMIN']), async (req, res, next) => {
  try {
    // Vérifier que les données nécessaires sont présentes
    if (req.body.test === undefined) {
      throw new BadRequestError('Le résultat du test est requis');
    }

    // Mettre à jour les données du test
    const updateData = {
      test: req.body.test,
      dateTest: new Date(),
      veterinaire: req.user._id,
      temperature: req.body.temperature,
      status: req.body.status !== undefined ? req.body.status : true
    };

    let lot;

    // Essayer de mettre à jour par ObjectId (MongoDB ID)
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      lot = await Lot.findByIdAndUpdate(req.params.id, updateData, {
        new: true,
        runValidators: true
      });
    }

    // Si non trouvé, essayer de mettre à jour par identifiant
    if (!lot) {
      lot = await Lot.findOneAndUpdate({ identifiant: req.params.id }, updateData, {
        new: true,
        runValidators: true
      });
    }

    if (!lot) {
      throw new NotFoundError('Lot non trouvé');
    }

    // Récupérer le lot mis à jour avec les relations peuplées
    const populatedLot = await Lot.findById(lot._id)
      .populate('espece', 'nom imageUrl')
      .populate('veterinaire', 'nom prenom')
      .populate('prise', 'nom debut fin pecheur maryeur')
      .populate('acheteur', 'nom prenom')
      .populate({
        path: 'prise',
        populate: [
          { path: 'pecheur', select: 'nom prenom' },
          { path: 'maryeur', select: 'nom prenom' }
        ]
      });

    // Notifier le mareyeur du résultat du test
    if (populatedLot.prise && populatedLot.prise.maryeur) {
      try {
        const resultat = req.body.test ? 'validé' : 'refusé';
        await notificationService.notifierMaryeur(
          populatedLot.prise.maryeur._id,
          `Lot ${resultat} par le vétérinaire`,
          `Le lot ${populatedLot.identifiant} de ${populatedLot.espece ? populatedLot.espece.nom : 'poisson'} a été ${resultat} par le vétérinaire.`,
          req.body.test ? 'success' : 'warning',
          {
            reference: lot._id,
            referenceModel: 'Lot',
            urlAction: `/maryeur/lots/${lot._id}`
          }
        );
      } catch (error) {
        console.error('Erreur lors de l\'envoi de la notification au mareyeur:', error);
      }
    }

    // Notifier le pêcheur du résultat du test
    if (populatedLot.prise && populatedLot.prise.pecheur) {
      try {
        const resultat = req.body.test ? 'validé' : 'refusé';
        await notificationService.notifierPecheur(
          populatedLot.prise.pecheur._id,
          `Lot ${resultat} par le vétérinaire`,
          `Le lot ${populatedLot.identifiant} de ${populatedLot.espece ? populatedLot.espece.nom : 'poisson'} a été ${resultat} par le vétérinaire.`,
          req.body.test ? 'success' : 'warning',
          {
            reference: lot._id,
            referenceModel: 'Lot',
            urlAction: `/pecheur/lots/${lot._id}`
          }
        );
      } catch (error) {
        console.error('Erreur lors de l\'envoi de la notification au pêcheur:', error);
      }
    }

    res.success(populatedLot, 'Test du lot effectué avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route PATCH /api/lots/:id/vente
 * @desc Marquer un lot comme vendu
 * @access Private (Mareyeur ou Admin)
 */
router.patch('/:id/vente', auth, checkRole(['ROLE_MARYEUR', 'ROLE_ADMIN']), async (req, res, next) => {
  try {
    // Vérifier que les données nécessaires sont présentes
    if (!req.body.acheteur || !req.body.prixFinal) {
      throw new BadRequestError('Acheteur et prix final sont requis');
    }

    // Vérifier que l'acheteur existe dans la collection Client
    let acheteur;
    if (mongoose.Types.ObjectId.isValid(req.body.acheteur)) {
      acheteur = await Client.findById(req.body.acheteur);
    }

    // Si non trouvé dans Client, essayer de trouver dans User (pour compatibilité)
    if (!acheteur) {
      const User = require('../models/User');
      acheteur = await User.findById(req.body.acheteur);
      if (!acheteur) {
        throw new NotFoundError('Acheteur non trouvé');
      }
    }

    // Mettre à jour les données de vente
    const updateData = {
      vendu: true,
      acheteur: req.body.acheteur,
      prixFinal: req.body.prixFinal,
      dateSoumission: new Date()
    };

    let lot;

    // Essayer de mettre à jour par ObjectId (MongoDB ID)
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      lot = await Lot.findByIdAndUpdate(req.params.id, updateData, {
        new: true,
        runValidators: true
      });
    }

    // Si non trouvé, essayer de mettre à jour par identifiant
    if (!lot) {
      lot = await Lot.findOneAndUpdate({ identifiant: req.params.id }, updateData, {
        new: true,
        runValidators: true
      });
    }

    if (!lot) {
      throw new NotFoundError('Lot non trouvé');
    }

    // Récupérer le lot mis à jour avec les relations peuplées
    const populatedLot = await Lot.findById(lot._id)
      .populate('espece', 'nom imageUrl')
      .populate('veterinaire', 'nom prenom')
      .populate('prise', 'nom debut fin pecheur')
      .populate('acheteur', 'nom prenom')
      .populate({
        path: 'prise',
        populate: { path: 'pecheur', select: 'nom prenom' }
      });

    // Notifier le client de l'achat
    if (populatedLot.acheteur) {
      try {
        await notificationService.notifierClient(
          populatedLot.acheteur._id,
          'Achat confirmé',
          `Votre achat du lot ${populatedLot.identifiant} de ${populatedLot.espece ? populatedLot.espece.nom : 'poisson'} a été confirmé pour ${populatedLot.prixFinal} dinars.`,
          'success',
          {
            reference: lot._id,
            referenceModel: 'Lot',
            urlAction: `/client/achats/${lot._id}`
          }
        );
      } catch (error) {
        console.error('Erreur lors de l\'envoi de la notification au client:', error);
      }
    }

    // Notifier le pêcheur de la vente
    if (populatedLot.prise && populatedLot.prise.pecheur) {
      try {
        await notificationService.notifierPecheur(
          populatedLot.prise.pecheur._id,
          'Lot vendu',
          `Votre lot ${populatedLot.identifiant} de ${populatedLot.espece ? populatedLot.espece.nom : 'poisson'} a été vendu pour ${populatedLot.prixFinal} dinars.`,
          'success',
          {
            reference: lot._id,
            referenceModel: 'Lot',
            urlAction: `/pecheur/lots/${lot._id}`
          }
        );
      } catch (error) {
        console.error('Erreur lors de l\'envoi de la notification au pêcheur:', error);
      }
    }

    res.success(populatedLot, 'Lot marqué comme vendu avec succès');
  } catch (error) {
    next(error);
  }
});

module.exports = router;