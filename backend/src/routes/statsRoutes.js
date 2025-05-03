/**
 * Routes pour les statistiques
 */
const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { getDashboardStats, getPecheurStats, getMaryeurStats } = require('../controllers/statsController');
const mongoose = require('mongoose');

/**
 * @route GET /api/stats/dashboard
 * @desc Récupérer les statistiques générales du tableau de bord
 * @access Private
 */
router.get('/dashboard', auth, getDashboardStats);

/**
 * @route GET /api/stats/pecheur/:id
 * @desc Récupérer les statistiques d'un pêcheur spécifique
 * @access Private
 */
router.get('/pecheur/:id', auth, getPecheurStats);

/**
 * @route GET /api/stats/maryeur/:id
 * @desc Récupérer les statistiques d'un maryeur spécifique
 * @access Private
 */
router.get('/maryeur/:id', auth, getMaryeurStats);

/**
 * @route GET /api/stats/veterinaire/:id
 * @desc Récupérer les statistiques d'un vétérinaire spécifique
 * @access Private
 */
router.get('/veterinaire/:id', auth, async (req, res, next) => {
  try {
    // Récupérer l'ID du vétérinaire
    const veterinaireId = req.params.id;

    // Récupérer les lots associés à ce vétérinaire
    const Lot = require('../models/Lot');

    // Compter les lots en attente, approuvés et rejetés
    const pendingLots = await Lot.countDocuments({
      veterinaire: veterinaireId,
      test: { $exists: false }
    });

    const approvedLots = await Lot.countDocuments({
      veterinaire: veterinaireId,
      test: true
    });

    const rejectedLots = await Lot.countDocuments({
      veterinaire: veterinaireId,
      test: false
    });

    // Retourner les statistiques
    res.success({
      pendingLots,
      approvedLots,
      rejectedLots,
      totalLots: pendingLots + approvedLots + rejectedLots
    }, 'Statistiques du vétérinaire récupérées avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route GET /api/stats/client/:id
 * @desc Récupérer les statistiques d'un client spécifique
 * @access Private
 */
router.get('/client/:id', auth, async (req, res, next) => {
  try {
    // Récupérer l'ID du client
    const clientId = req.params.id;

    // Récupérer les lots achetés par ce client
    const Lot = require('../models/Lot');

    // Compter les achats et les enchères actives
    const purchases = await Lot.countDocuments({
      acheteur: clientId,
      vendu: true
    });

    const activeAuctions = await Lot.countDocuments({
      prixInitial: { $exists: true, $ne: null },
      test: true,
      status: true,
      vendu: false
    });

    // Retourner les statistiques
    res.success({
      purchases,
      activeAuctions
    }, 'Statistiques du client récupérées avec succès');
  } catch (error) {
    next(error);
  }
});

module.exports = router;
