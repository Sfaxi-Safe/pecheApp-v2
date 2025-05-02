/**
 * Routes pour la gestion des notifications
 * Implémentation avec gestion d'erreurs standardisée
 */
const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const Notification = require('../models/Notification');
const { auth } = require('../middleware/auth');
const { NotFoundError, BadRequestError, ForbiddenError } = require('../middleware/errorHandler');

/**
 * @route GET /api/notifications
 * @desc Récupérer les notifications de l'utilisateur connecté
 * @access Private
 */
router.get('/', auth, async (req, res, next) => {
  try {
    // Déterminer le modèle de l'utilisateur connecté
    let destinataireModel;
    if (req.user.roles.includes('ROLE_PECHEUR')) {
      destinataireModel = 'Pecheur';
    } else if (req.user.roles.includes('ROLE_VETERINAIRE')) {
      destinataireModel = 'Veterinaire';
    } else if (req.user.roles.includes('ROLE_MARYEUR')) {
      destinataireModel = 'Maryeur';
    } else if (req.user.roles.includes('ROLE_CLIENT')) {
      destinataireModel = 'Client';
    } else if (req.user.roles.includes('ROLE_ADMIN')) {
      destinataireModel = 'Admin';
    }

    // Filtres optionnels
    const filter = {
      destinataire: req.user._id,
      destinataireModel
    };

    // Filtrer par statut de lecture si spécifié
    if (req.query.lue !== undefined) {
      filter.lue = req.query.lue === 'true';
    }

    // Filtrer par type si spécifié
    if (req.query.type) {
      filter.type = req.query.type;
    }

    // Pagination
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    // Récupérer les notifications
    const notifications = await Notification.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    // Compter le nombre total de notifications
    const total = await Notification.countDocuments(filter);

    // Compter le nombre de notifications non lues
    const nonLues = await Notification.countDocuments({
      ...filter,
      lue: false
    });

    res.success({
      notifications,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      },
      stats: {
        total,
        nonLues
      }
    }, 'Notifications récupérées avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route POST /api/notifications
 * @desc Créer une nouvelle notification
 * @access Private (Admin uniquement)
 */
router.post('/', auth, async (req, res, next) => {
  try {
    // Validation des données
    if (!req.body.destinataire || !req.body.destinataireModel || !req.body.titre || !req.body.contenu) {
      throw new BadRequestError('Destinataire, modèle du destinataire, titre et contenu sont requis');
    }

    // Vérifier que le modèle du destinataire est valide
    const modelsValides = ['Pecheur', 'Veterinaire', 'Maryeur', 'Client', 'Admin'];
    if (!modelsValides.includes(req.body.destinataireModel)) {
      throw new BadRequestError('Modèle du destinataire invalide');
    }

    // Créer la notification
    const notification = new Notification(req.body);
    const newNotification = await notification.save();

    res.created(newNotification, 'Notification créée avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route PATCH /api/notifications/:id/lue
 * @desc Marquer une notification comme lue
 * @access Private
 */
router.patch('/:id/lue', auth, async (req, res, next) => {
  try {
    // Vérifier que l'ID est valide
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      throw new BadRequestError('ID de notification invalide');
    }

    // Récupérer la notification
    const notification = await Notification.findById(req.params.id);
    if (!notification) {
      throw new NotFoundError('Notification non trouvée');
    }

    // Vérifier que l'utilisateur est le destinataire
    if (notification.destinataire.toString() !== req.user._id.toString()) {
      throw new ForbiddenError('Vous n\'êtes pas autorisé à modifier cette notification');
    }

    // Marquer comme lue
    notification.lue = true;
    await notification.save();

    res.success(notification, 'Notification marquée comme lue');
  } catch (error) {
    next(error);
  }
});

/**
 * @route PATCH /api/notifications/lire-tout
 * @desc Marquer toutes les notifications de l'utilisateur comme lues
 * @access Private
 */
router.patch('/lire-tout', auth, async (req, res, next) => {
  try {
    // Déterminer le modèle de l'utilisateur connecté
    let destinataireModel;
    if (req.user.roles.includes('ROLE_PECHEUR')) {
      destinataireModel = 'Pecheur';
    } else if (req.user.roles.includes('ROLE_VETERINAIRE')) {
      destinataireModel = 'Veterinaire';
    } else if (req.user.roles.includes('ROLE_MARYEUR')) {
      destinataireModel = 'Maryeur';
    } else if (req.user.roles.includes('ROLE_CLIENT')) {
      destinataireModel = 'Client';
    } else if (req.user.roles.includes('ROLE_ADMIN')) {
      destinataireModel = 'Admin';
    }

    // Mettre à jour toutes les notifications non lues
    const result = await Notification.updateMany(
      {
        destinataire: req.user._id,
        destinataireModel,
        lue: false
      },
      { lue: true }
    );

    res.success({
      count: result.modifiedCount
    }, `${result.modifiedCount} notifications marquées comme lues`);
  } catch (error) {
    next(error);
  }
});

/**
 * @route DELETE /api/notifications/:id
 * @desc Supprimer une notification
 * @access Private
 */
router.delete('/:id', auth, async (req, res, next) => {
  try {
    // Vérifier que l'ID est valide
    if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
      throw new BadRequestError('ID de notification invalide');
    }

    // Récupérer la notification
    const notification = await Notification.findById(req.params.id);
    if (!notification) {
      throw new NotFoundError('Notification non trouvée');
    }

    // Vérifier que l'utilisateur est le destinataire
    if (notification.destinataire.toString() !== req.user._id.toString()) {
      throw new ForbiddenError('Vous n\'êtes pas autorisé à supprimer cette notification');
    }

    // Supprimer la notification
    await notification.delete();

    res.success(null, 'Notification supprimée avec succès');
  } catch (error) {
    next(error);
  }
});

module.exports = router;
