/**
 * Contrôleur pour les statistiques
 */
const mongoose = require('mongoose');
const Lot = require('../models/Lot');
const Prise = require('../models/Prise');
const Client = require('../models/Client');
const Pecheur = require('../models/Pecheur');
const Maryeur = require('../models/Maryeur');

/**
 * Récupérer les statistiques générales du tableau de bord
 * @param {Object} req - Requête Express
 * @param {Object} res - Réponse Express
 * @param {Function} next - Middleware suivant
 */
exports.getDashboardStats = async (req, res, next) => {
  try {
    // Récupérer l'utilisateur connecté
    const userId = req.user._id;
    const userRoles = req.user.roles || '';

    // Statistiques par défaut
    let stats = {
      availableAuctions: 0,
      myPurchases: 0
    };

    // Si c'est un client, récupérer les enchères disponibles et les achats
    if (userRoles.includes('ROLE_CLIENT')) {
      // Compter les enchères disponibles
      const availableAuctions = await Lot.countDocuments({ 
        status: true, 
        vendu: false,
        test: true
      });

      // Compter les achats du client
      const myPurchases = await Lot.countDocuments({ 
        acheteur: userId,
        vendu: true
      });

      stats = {
        availableAuctions,
        myPurchases
      };
    }

    res.success(stats, 'Statistiques récupérées avec succès');
  } catch (error) {
    next(error);
  }
};

/**
 * Récupérer les statistiques d'un pêcheur spécifique
 * @param {Object} req - Requête Express
 * @param {Object} res - Réponse Express
 * @param {Function} next - Middleware suivant
 */
exports.getPecheurStats = async (req, res, next) => {
  try {
    const pecheurId = req.params.id;
    
    // Vérifier si l'ID est valide
    let query = {};
    if (mongoose.Types.ObjectId.isValid(pecheurId)) {
      query = { pecheur: pecheurId };
    } else {
      // Chercher le pêcheur par ID personnalisé
      const pecheur = await Pecheur.findOne({ id: pecheurId });
      if (!pecheur) {
        return res.error('Pêcheur non trouvé', 404);
      }
      query = { pecheur: pecheur._id };
    }

    // Récupérer toutes les prises du pêcheur
    const prises = await Prise.find(query);
    
    // Récupérer tous les lots associés à ces prises
    const priseIds = prises.map(prise => prise._id);
    const lots = await Lot.find({ prise: { $in: priseIds } });

    // Calculer les statistiques
    const totalCaptures = prises.length;
    const pendingValidation = lots.filter(lot => !lot.test).length;
    const validated = lots.filter(lot => lot.test && lot.status).length;
    const rejected = lots.filter(lot => lot.test && !lot.status).length;

    const stats = {
      totalCaptures,
      pendingValidation,
      validated,
      rejected
    };

    res.success(stats, 'Statistiques du pêcheur récupérées avec succès');
  } catch (error) {
    next(error);
  }
};

/**
 * Récupérer les statistiques d'un maryeur spécifique
 * @param {Object} req - Requête Express
 * @param {Object} res - Réponse Express
 * @param {Function} next - Middleware suivant
 */
exports.getMaryeurStats = async (req, res, next) => {
  try {
    // Récupérer tous les lots
    const lots = await Lot.find();
    
    // Calculer les statistiques
    const pendingLots = lots.filter(lot => lot.test && lot.status && !lot.prix_initial).length;
    const activeAuctions = lots.filter(lot => lot.test && lot.status && lot.prix_initial && !lot.vendu).length;
    const completedAuctions = lots.filter(lot => lot.test && lot.status && lot.vendu).length;

    const stats = {
      pendingLots,
      activeAuctions,
      completedAuctions
    };

    res.success(stats, 'Statistiques du maryeur récupérées avec succès');
  } catch (error) {
    next(error);
  }
};
