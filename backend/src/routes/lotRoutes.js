/**
 * Routes pour la gestion des lots
 * Implémentation complète avec interaction avec la base de données
 */
const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const Lot = require('../models/Lot');
const { auth, checkRole } = require('../middleware/auth');
const { NotFoundError, BadRequestError } = require('../middleware/errorHandler');

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
      .populate('acheteur', 'nom prenom');

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
      .populate('prise', 'nom debut fin')
      .populate('acheteur', 'nom prenom');

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
      .populate('prise', 'nom debut fin')
      .populate('acheteur', 'nom prenom');

    res.success(populatedLot, 'Lot marqué comme vendu avec succès');
  } catch (error) {
    next(error);
  }
});

module.exports = router;