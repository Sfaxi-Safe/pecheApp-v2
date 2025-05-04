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
    let pecheurObjectId;
    if (mongoose.Types.ObjectId.isValid(pecheurId)) {
      pecheurObjectId = new mongoose.Types.ObjectId(pecheurId);
    } else {
      // Chercher le pêcheur par ID personnalisé
      const pecheur = await Pecheur.findOne({ id: pecheurId });
      if (!pecheur) {
        return res.error('Pêcheur non trouvé', 404);
      }
      pecheurObjectId = pecheur._id;
    }

    // Utiliser une agrégation pour compter les prises
    const prisesCount = await Prise.countDocuments({ pecheur: pecheurObjectId });

    // Utiliser une agrégation pour obtenir les statistiques des lots en une seule requête
    const lotStats = await Prise.aggregate([
      // Étape 1: Filtrer les prises du pêcheur
      { $match: { pecheur: pecheurObjectId } },

      // Étape 2: Joindre avec la collection des lots
      { $lookup: {
          from: 'lots',
          localField: '_id',
          foreignField: 'prise',
          as: 'lots'
      }},

      // Étape 3: Dérouler les lots pour pouvoir les compter
      { $unwind: { path: '$lots', preserveNullAndEmptyArrays: true } },

      // Étape 4: Grouper et compter les différents types de lots
      { $group: {
          _id: null,
          totalLots: { $sum: 1 },
          pendingValidation: {
            $sum: {
              $cond: [{ $eq: ['$lots.test', false] }, 1, 0]
            }
          },
          validated: {
            $sum: {
              $cond: [
                { $and: [
                  { $eq: ['$lots.test', true] },
                  { $eq: ['$lots.status', true] }
                ]},
                1,
                0
              ]
            }
          },
          rejected: {
            $sum: {
              $cond: [
                { $and: [
                  { $eq: ['$lots.test', true] },
                  { $eq: ['$lots.status', false] }
                ]},
                1,
                0
              ]
            }
          }
      }}
    ]);

    // Préparer les statistiques
    const stats = {
      totalCaptures: prisesCount,
      pendingValidation: lotStats.length > 0 ? lotStats[0].pendingValidation : 0,
      validated: lotStats.length > 0 ? lotStats[0].validated : 0,
      rejected: lotStats.length > 0 ? lotStats[0].rejected : 0
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
    const maryeurId = req.params.id;

    // Vérifier si l'ID est valide
    let maryeurObjectId;
    if (mongoose.Types.ObjectId.isValid(maryeurId)) {
      maryeurObjectId = new mongoose.Types.ObjectId(maryeurId);
    } else {
      // Chercher le maryeur par ID personnalisé
      const maryeur = await Maryeur.findOne({ id: maryeurId });
      if (!maryeur) {
        return res.error('Maryeur non trouvé', 404);
      }
      maryeurObjectId = maryeur._id;
    }

    // Utiliser une agrégation pour obtenir les statistiques en une seule requête
    const pipeline = [
      // Étape 1: Trouver les prises associées au maryeur
      { $match: { maryeur: maryeurObjectId } },

      // Étape 2: Joindre avec la collection des lots
      { $lookup: {
          from: 'lots',
          localField: '_id',
          foreignField: 'prise',
          as: 'lots'
      }},

      // Étape 3: Dérouler les lots pour pouvoir les compter
      { $unwind: { path: '$lots', preserveNullAndEmptyArrays: true } },

      // Étape 4: Grouper et compter les différents types de lots
      { $group: {
          _id: null,
          pendingLots: {
            $sum: {
              $cond: [
                { $and: [
                  { $eq: ['$lots.test', true] },
                  { $eq: ['$lots.status', true] },
                  { $eq: [{ $ifNull: ['$lots.prixInitial', null] }, null] }
                ]},
                1,
                0
              ]
            }
          },
          activeAuctions: {
            $sum: {
              $cond: [
                { $and: [
                  { $eq: ['$lots.test', true] },
                  { $eq: ['$lots.status', true] },
                  { $ne: [{ $ifNull: ['$lots.prixInitial', null] }, null] },
                  { $eq: ['$lots.vendu', false] }
                ]},
                1,
                0
              ]
            }
          },
          completedAuctions: {
            $sum: {
              $cond: [
                { $and: [
                  { $eq: ['$lots.test', true] },
                  { $eq: ['$lots.status', true] },
                  { $eq: ['$lots.vendu', true] }
                ]},
                1,
                0
              ]
            }
          }
      }}
    ];

    const results = await Prise.aggregate(pipeline);

    // Préparer les statistiques
    const stats = {
      pendingLots: results.length > 0 ? results[0].pendingLots : 0,
      activeAuctions: results.length > 0 ? results[0].activeAuctions : 0,
      completedAuctions: results.length > 0 ? results[0].completedAuctions : 0
    };

    res.success(stats, 'Statistiques du maryeur récupérées avec succès');
  } catch (error) {
    next(error);
  }
};
