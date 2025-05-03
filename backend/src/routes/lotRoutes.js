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
 * @route GET /api/lots/featured
 * @desc Récupérer les lots en vedette pour la page d'accueil
 * @access Public
 */
router.get('/featured', async (req, res, next) => {
  try {
    // Récupérer les lots qui ont un prix initial, qui sont validés par un vétérinaire et qui ne sont pas vendus
    const filter = {
      prixInitial: { $exists: true, $ne: null },
      test: true,
      status: true,
      vendu: false
    };

    // Limiter à 5 lots maximum, triés par date de soumission (les plus récents d'abord)
    const lots = await Lot.find(filter)
      .sort({ dateSoumission: -1 })
      .limit(5)
      .populate('espece', 'nom imageUrl')
      .populate('veterinaire', 'nom prenom')
      .populate('prise', 'nom debut fin lieu')
      .populate('acheteur', 'nom prenom');

    res.success(lots, 'Liste des lots en vedette récupérée avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route GET /api/lots/available
 * @desc Récupérer tous les lots disponibles pour enchères
 * @access Public
 */
router.get('/available', async (req, res, next) => {
  try {
    // Récupérer les lots qui ont un prix initial, qui sont validés par un vétérinaire et qui ne sont pas vendus
    const filter = {
      prixInitial: { $exists: true, $ne: null },
      test: true,
      status: true,
      vendu: false
    };

    // Trier par date de soumission (les plus récents d'abord)
    const lots = await Lot.find(filter)
      .sort({ dateSoumission: -1 })
      .populate('espece', 'nom imageUrl')
      .populate('veterinaire', 'nom prenom')
      .populate('prise', 'nom debut fin lieu')
      .populate('acheteur', 'nom prenom');

    res.success(lots, 'Liste des lots disponibles récupérée avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route GET /api/lots/pending
 * @desc Récupérer tous les lots en attente de validation par un vétérinaire
 * @access Private (Vétérinaire ou Admin)
 */
router.get('/pending', auth, checkRole(['ROLE_VETERINAIRE', 'ROLE_ADMIN']), async (req, res, next) => {
  try {
    // Récupérer les lots qui n'ont pas encore été testés par un vétérinaire
    const filter = {
      test: false
    };

    // Trier par date de soumission (les plus récents d'abord)
    const lots = await Lot.find(filter)
      .sort({ dateSoumission: -1 })
      .populate('espece', 'nom imageUrl')
      .populate('veterinaire', 'nom prenom')
      .populate('prise', 'nom debut fin lieu')
      .populate({
        path: 'prise',
        populate: { path: 'pecheur', select: 'nom prenom' }
      });

    res.success(lots, 'Liste des lots en attente récupérée avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route GET /api/lots/pending-price
 * @desc Récupérer tous les lots validés par un vétérinaire mais sans prix initial
 * @access Private (Maryeur ou Admin)
 */
router.get('/pending-price', auth, checkRole(['ROLE_MARYEUR', 'ROLE_ADMIN']), async (req, res, next) => {
  try {
    // Récupérer les lots qui ont été validés par un vétérinaire mais qui n'ont pas encore de prix initial
    const filter = {
      test: true,
      status: true,
      prixInitial: { $exists: false },
      vendu: false
    };

    // Trier par date de soumission (les plus récents d'abord)
    const lots = await Lot.find(filter)
      .sort({ dateSoumission: -1 })
      .populate('espece', 'nom imageUrl')
      .populate('veterinaire', 'nom prenom')
      .populate('prise', 'nom debut fin lieu')
      .populate({
        path: 'prise',
        populate: { path: 'pecheur', select: 'nom prenom' }
      });

    res.success(lots, 'Liste des lots en attente de prix récupérée avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route GET /api/lots/maryeur/:id
 * @desc Récupérer tous les lots associés à un maryeur
 * @access Private (Maryeur ou Admin)
 */
router.get('/maryeur/:id', auth, checkRole(['ROLE_MARYEUR', 'ROLE_ADMIN']), async (req, res, next) => {
  try {
    let filter = {};

    // Vérifier si l'ID est un ObjectId valide
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      // Chercher les prises associées à ce maryeur
      const Prise = require('../models/Prise');
      const prises = await Prise.find({ maryeur: req.params.id });

      // Récupérer les IDs des prises
      const priseIds = prises.map(prise => prise._id);

      // Filtrer les lots par ces prises
      filter.prise = { $in: priseIds };
    } else {
      // Si ce n'est pas un ObjectId, chercher le maryeur par ID personnalisé
      const Maryeur = require('../models/Maryeur');
      const maryeur = await Maryeur.findOne({ id: req.params.id });

      if (!maryeur) {
        return res.success([], 'Aucun lot trouvé pour ce maryeur');
      }

      // Chercher les prises associées à ce maryeur
      const Prise = require('../models/Prise');
      const prises = await Prise.find({ maryeur: maryeur._id });

      // Récupérer les IDs des prises
      const priseIds = prises.map(prise => prise._id);

      // Filtrer les lots par ces prises
      filter.prise = { $in: priseIds };
    }

    // Ajouter des filtres supplémentaires si fournis

    // Filtrer par statut de vente si spécifié
    if (req.query.vendu !== undefined) {
      filter.vendu = req.query.vendu === 'true';
    }

    // Filtrer par statut de test si spécifié
    if (req.query.status !== undefined) {
      filter.status = req.query.status === 'true';
    }

    // Filtrer par prix initial si spécifié
    if (req.query.hasPrixInitial !== undefined) {
      if (req.query.hasPrixInitial === 'true') {
        filter.prixInitial = { $exists: true, $ne: null };
      } else {
        filter.prixInitial = { $exists: false };
      }
    }

    // Filtrer par date de soumission
    if (req.query.dateDebut) {
      if (!filter.dateSoumission) filter.dateSoumission = {};
      filter.dateSoumission.$gte = new Date(req.query.dateDebut);
    }

    if (req.query.dateFin) {
      if (!filter.dateSoumission) filter.dateSoumission = {};
      filter.dateSoumission.$lte = new Date(req.query.dateFin);
    }

    // Récupérer tous les lots associés à ce maryeur avec les filtres appliqués
    const lots = await Lot.find(filter)
      .sort({ dateSoumission: -1 }) // Trier par date de soumission (les plus récents d'abord)
      .populate('espece', 'nom imageUrl')
      .populate('veterinaire', 'nom prenom')
      .populate('prise', 'nom debut fin')
      .populate('acheteur', 'nom prenom');

    res.success(lots, 'Liste des lots du maryeur récupérée avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route GET /api/lots/pecheur/:id
 * @desc Récupérer tous les lots associés à un pêcheur
 * @access Public
 */
router.get('/pecheur/:id', async (req, res, next) => {
  try {
    let filter = {};

    // Vérifier si l'ID est un ObjectId valide
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      // Chercher les prises associées à ce pêcheur
      const Prise = require('../models/Prise');
      const prises = await Prise.find({ pecheur: req.params.id });

      // Récupérer les IDs des prises
      const priseIds = prises.map(prise => prise._id);

      // Filtrer les lots par ces prises
      filter.prise = { $in: priseIds };
    } else {
      // Si ce n'est pas un ObjectId, chercher le pêcheur par ID personnalisé
      const Pecheur = require('../models/Pecheur');
      const pecheur = await Pecheur.findOne({ id: req.params.id });

      if (!pecheur) {
        return res.success([], 'Aucun lot trouvé pour ce pêcheur');
      }

      // Chercher les prises associées à ce pêcheur
      const Prise = require('../models/Prise');
      const prises = await Prise.find({ pecheur: pecheur._id });

      // Récupérer les IDs des prises
      const priseIds = prises.map(prise => prise._id);

      // Filtrer les lots par ces prises
      filter.prise = { $in: priseIds };
    }

    // Récupérer tous les lots associés à ce pêcheur
    const lots = await Lot.find(filter)
      .populate('espece', 'nom imageUrl')
      .populate('veterinaire', 'nom prenom')
      .populate('prise', 'nom debut fin')
      .populate('acheteur', 'nom prenom');

    res.success(lots, 'Liste des lots du pêcheur récupérée avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route GET /api/lots/search
 * @desc Rechercher des lots par nom d'espèce
 * @access Public
 */
router.get('/search', async (req, res, next) => {
  try {
    const query = req.query.query;

    if (!query) {
      return res.success([], 'Aucun terme de recherche fourni');
    }

    // Rechercher l'espèce par nom
    const Espece = require('../models/Espece');
    const especes = await Espece.find({
      nom: { $regex: query, $options: 'i' }
    });

    // Récupérer les IDs des espèces trouvées
    const especeIds = especes.map(espece => espece._id);

    // Filtrer les lots par ces espèces et qui sont disponibles pour enchères
    const filter = {
      espece: { $in: especeIds },
      prixInitial: { $exists: true, $ne: null },
      test: true,
      status: true,
      vendu: false
    };

    // Récupérer les lots correspondants
    const lots = await Lot.find(filter)
      .populate('espece', 'nom imageUrl')
      .populate('veterinaire', 'nom prenom')
      .populate('prise', 'nom debut fin lieu')
      .populate('acheteur', 'nom prenom');

    res.success(lots, 'Résultats de recherche récupérés avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route GET /api/auctions/maryeur/:id
 * @desc Récupérer les enchères actives d'un maryeur
 * @access Private (Maryeur ou Admin)
 */
router.get('/auctions/maryeur/:id', auth, checkRole(['ROLE_MARYEUR', 'ROLE_ADMIN']), async (req, res, next) => {
  try {
    let filter = {};

    // Vérifier si l'ID est un ObjectId valide
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      // Chercher les prises associées à ce maryeur
      const Prise = require('../models/Prise');
      const prises = await Prise.find({ maryeur: req.params.id });

      // Récupérer les IDs des prises
      const priseIds = prises.map(prise => prise._id);

      // Filtrer les lots par ces prises, avec prix initial et non vendus
      filter = {
        prise: { $in: priseIds },
        prixInitial: { $exists: true, $ne: null },
        vendu: false,
        test: true,
        status: true
      };
    } else {
      // Si ce n'est pas un ObjectId, chercher le maryeur par ID personnalisé
      const Maryeur = require('../models/Maryeur');
      const maryeur = await Maryeur.findOne({ id: req.params.id });

      if (!maryeur) {
        return res.success([], 'Aucune enchère trouvée pour ce maryeur');
      }

      // Chercher les prises associées à ce maryeur
      const Prise = require('../models/Prise');
      const prises = await Prise.find({ maryeur: maryeur._id });

      // Récupérer les IDs des prises
      const priseIds = prises.map(prise => prise._id);

      // Filtrer les lots par ces prises, avec prix initial et non vendus
      filter = {
        prise: { $in: priseIds },
        prixInitial: { $exists: true, $ne: null },
        vendu: false,
        test: true,
        status: true
      };
    }

    // Récupérer toutes les enchères actives associées à ce maryeur
    const lots = await Lot.find(filter)
      .populate('espece', 'nom imageUrl')
      .populate('veterinaire', 'nom prenom')
      .populate('prise', 'nom debut fin')
      .populate('acheteur', 'nom prenom');

    res.success(lots, 'Liste des enchères actives du maryeur récupérée avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route GET /api/lots/veterinaire/:id
 * @desc Récupérer tous les lots associés à un vétérinaire
 * @access Private (Vétérinaire ou Admin)
 */
router.get('/veterinaire/:id', auth, checkRole(['ROLE_VETERINAIRE', 'ROLE_ADMIN']), async (req, res, next) => {
  try {
    let filter = {};

    // Vérifier si l'ID est un ObjectId valide
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      filter.veterinaire = req.params.id;
    } else {
      // Si ce n'est pas un ObjectId, chercher le vétérinaire par ID personnalisé
      const Veterinaire = require('../models/Veterinaire');
      const veterinaire = await Veterinaire.findOne({ id: req.params.id });

      if (!veterinaire) {
        return res.success([], 'Aucun lot trouvé pour ce vétérinaire');
      }

      filter.veterinaire = veterinaire._id;
    }

    // Ajouter des filtres supplémentaires si fournis

    // Filtrer par statut de test si spécifié
    if (req.query.status !== undefined) {
      filter.status = req.query.status === 'true';
    }

    // Filtrer par date de test
    if (req.query.dateDebut) {
      if (!filter.dateTest) filter.dateTest = {};
      filter.dateTest.$gte = new Date(req.query.dateDebut);
    }

    if (req.query.dateFin) {
      if (!filter.dateTest) filter.dateTest = {};
      filter.dateTest.$lte = new Date(req.query.dateFin);
    }

    // Récupérer tous les lots associés à ce vétérinaire avec les filtres appliqués
    const lots = await Lot.find(filter)
      .sort({ dateTest: -1 }) // Trier par date de test (les plus récents d'abord)
      .populate('espece', 'nom imageUrl')
      .populate('veterinaire', 'nom prenom')
      .populate('prise', 'nom debut fin')
      .populate('acheteur', 'nom prenom');

    res.success(lots, 'Liste des lots du vétérinaire récupérée avec succès');
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
 * @route POST /api/lots/:id/bid
 * @desc Placer une enchère sur un lot
 * @access Private (Client uniquement)
 */
router.post('/:id/bid', auth, checkRole('ROLE_CLIENT'), async (req, res, next) => {
  try {
    const { amount, userId } = req.body;

    if (!amount || amount <= 0) {
      return res.error('Le montant de l\'enchère doit être supérieur à 0', 400);
    }

    // Vérifier que l'utilisateur est bien un client
    const Client = require('../models/Client');
    let client;

    if (mongoose.Types.ObjectId.isValid(userId)) {
      client = await Client.findById(userId);
    } else {
      client = await Client.findOne({ id: userId });
    }

    if (!client) {
      return res.error('Client non trouvé', 404);
    }

    // Récupérer le lot
    let lot;
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      lot = await Lot.findById(req.params.id);
    } else {
      lot = await Lot.findOne({ identifiant: req.params.id });
    }

    if (!lot) {
      return res.error('Lot non trouvé', 404);
    }

    // Vérifier que le lot est disponible pour enchères
    if (!lot.prixInitial || !lot.test || !lot.status || lot.vendu) {
      return res.error('Ce lot n\'est pas disponible pour enchères', 400);
    }

    // Vérifier que l'enchère est supérieure au prix initial ou à l'enchère actuelle
    const prixActuel = lot.prixEnchere || lot.prixInitial;
    if (amount <= prixActuel) {
      return res.error(`L'enchère doit être supérieure au prix actuel (${prixActuel})`, 400);
    }

    // Mettre à jour le lot avec la nouvelle enchère
    lot.prixEnchere = amount;
    lot.acheteur = client._id;
    lot.dateEnchere = new Date();

    await lot.save();

    res.success(lot, 'Enchère placée avec succès');
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
 * @route PUT /api/lots/:id/approve
 * @desc Approuver un lot par un vétérinaire
 * @access Private (Vétérinaire ou Admin)
 */
router.put('/:id/approve', auth, checkRole(['ROLE_VETERINAIRE', 'ROLE_ADMIN']), async (req, res, next) => {
  try {
    // Mettre à jour les données du test
    const updateData = {
      test: true,
      dateTest: new Date(),
      veterinaire: req.user._id,
      status: true
    };

    // Ajouter la température si fournie
    if (req.body.temperature) {
      updateData.temperature = req.body.temperature;
    }

    // Mettre à jour le lot
    let lot = await Lot.findById(req.params.id);

    if (!lot) {
      // Si non trouvé par ID, essayer par identifiant
      lot = await Lot.findOne({ identifiant: req.params.id });
    }

    if (!lot) {
      throw new NotFoundError('Lot non trouvé');
    }

    // Appliquer les mises à jour
    Object.assign(lot, updateData);
    await lot.save();

    // Récupérer le lot mis à jour avec les relations peuplées
    const populatedLot = await Lot.findById(lot._id)
      .populate('espece', 'nom imageUrl')
      .populate('veterinaire', 'nom prenom')
      .populate('prise', 'nom debut fin')
      .populate({
        path: 'prise',
        populate: { path: 'pecheur maryeur', select: 'nom prenom' }
      });

    // Notifier le mareyeur du résultat du test
    if (populatedLot.prise && populatedLot.prise.maryeur) {
      try {
        await notificationService.notifierMaryeur(
          populatedLot.prise.maryeur._id,
          `Lot validé par le vétérinaire`,
          `Le lot ${populatedLot.identifiant} de ${populatedLot.espece ? populatedLot.espece.nom : 'poisson'} a été validé par le vétérinaire.`,
          'success',
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
        await notificationService.notifierPecheur(
          populatedLot.prise.pecheur._id,
          `Lot validé par le vétérinaire`,
          `Le lot ${populatedLot.identifiant} de ${populatedLot.espece ? populatedLot.espece.nom : 'poisson'} a été validé par le vétérinaire.`,
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

    res.success(populatedLot, 'Lot approuvé avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route PUT /api/lots/:id/reject
 * @desc Rejeter un lot par un vétérinaire
 * @access Private (Vétérinaire ou Admin)
 */
router.put('/:id/reject', auth, checkRole(['ROLE_VETERINAIRE', 'ROLE_ADMIN']), async (req, res, next) => {
  try {
    // Mettre à jour les données du test
    const updateData = {
      test: true,
      dateTest: new Date(),
      veterinaire: req.user._id,
      status: false
    };

    // Ajouter la température si fournie
    if (req.body.temperature) {
      updateData.temperature = req.body.temperature;
    }

    // Mettre à jour le lot
    let lot = await Lot.findById(req.params.id);

    if (!lot) {
      // Si non trouvé par ID, essayer par identifiant
      lot = await Lot.findOne({ identifiant: req.params.id });
    }

    if (!lot) {
      throw new NotFoundError('Lot non trouvé');
    }

    // Appliquer les mises à jour
    Object.assign(lot, updateData);
    await lot.save();

    // Récupérer le lot mis à jour avec les relations peuplées
    const populatedLot = await Lot.findById(lot._id)
      .populate('espece', 'nom imageUrl')
      .populate('veterinaire', 'nom prenom')
      .populate('prise', 'nom debut fin')
      .populate({
        path: 'prise',
        populate: { path: 'pecheur maryeur', select: 'nom prenom' }
      });

    // Notifier le mareyeur du résultat du test
    if (populatedLot.prise && populatedLot.prise.maryeur) {
      try {
        await notificationService.notifierMaryeur(
          populatedLot.prise.maryeur._id,
          `Lot refusé par le vétérinaire`,
          `Le lot ${populatedLot.identifiant} de ${populatedLot.espece ? populatedLot.espece.nom : 'poisson'} a été refusé par le vétérinaire.`,
          'warning',
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
        await notificationService.notifierPecheur(
          populatedLot.prise.pecheur._id,
          `Lot refusé par le vétérinaire`,
          `Le lot ${populatedLot.identifiant} de ${populatedLot.espece ? populatedLot.espece.nom : 'poisson'} a été refusé par le vétérinaire.`,
          'warning',
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

    res.success(populatedLot, 'Lot refusé avec succès');
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
 * @route PUT /api/lots/:id/set-price
 * @desc Définir le prix initial et minimal d'un lot
 * @access Private (Mareyeur ou Admin)
 */
router.put('/:id/set-price', auth, checkRole(['ROLE_MARYEUR', 'ROLE_ADMIN']), async (req, res, next) => {
  try {
    // Vérifier que les données nécessaires sont présentes
    if (!req.body.prixMinimal) {
      throw new BadRequestError('Prix minimal requis');
    }

    // Convertir les prix en nombres
    const prixMinimal = parseFloat(req.body.prixMinimal);
    const prixInitial = parseFloat(req.body.prixInitial || req.body.prixMinimal);

    if (isNaN(prixMinimal) || prixMinimal <= 0) {
      throw new BadRequestError('Prix minimal invalide');
    }

    // Mettre à jour le lot
    let lot = await Lot.findById(req.params.id);

    if (!lot) {
      // Si non trouvé par ID, essayer par identifiant
      lot = await Lot.findOne({ identifiant: req.params.id });
    }

    if (!lot) {
      throw new NotFoundError('Lot non trouvé');
    }

    // Vérifier que le lot a été validé par un vétérinaire
    if (!lot.test || !lot.status) {
      throw new BadRequestError('Le lot doit être validé par un vétérinaire avant de définir un prix');
    }

    // Mettre à jour les prix
    lot.prixMinimal = prixMinimal;
    lot.prixInitial = prixInitial;
    lot.current = prixMinimal; // Prix courant initial = prix minimal

    // Ajouter d'autres champs si fournis
    if (req.body.typeEnchere) lot.typeEnchere = req.body.typeEnchere;
    if (req.body.online !== undefined) lot.online = req.body.online;

    await lot.save();

    // Récupérer le lot mis à jour avec les relations peuplées
    const populatedLot = await Lot.findById(lot._id)
      .populate('espece', 'nom imageUrl')
      .populate('veterinaire', 'nom prenom')
      .populate('prise', 'nom debut fin')
      .populate('acheteur', 'nom prenom');

    res.success(populatedLot, 'Prix du lot défini avec succès');
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