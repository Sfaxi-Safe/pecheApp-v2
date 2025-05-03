/**
 * Routes pour la gestion des clients
 * Implémentation avec gestion d'erreurs standardisée
 */
const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const Client = require('../models/Client');
const { auth, checkRole } = require('../middleware/auth');
const { NotFoundError, BadRequestError, ForbiddenError } = require('../middleware/errorHandler');

/**
 * @route GET /api/clients
 * @desc Récupérer tous les clients
 * @access Private (Admin uniquement)
 */
router.get('/', auth, checkRole('ROLE_ADMIN'), async (req, res, next) => {
  try {
    const clients = await Client.find();
    res.success(clients, 'Liste des clients récupérée avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route GET /api/clients/purchases/me
 * @desc Récupérer les achats du client connecté
 * @access Private (Client uniquement)
 */
router.get('/purchases/me', auth, checkRole('ROLE_CLIENT'), async (req, res, next) => {
  try {
    // Récupérer l'ID du client connecté
    const clientId = req.user._id;

    // Récupérer tous les lots achetés par ce client
    const Lot = require('../models/Lot');
    const lots = await Lot.find({ acheteur: clientId, vendu: true })
      .populate('espece', 'nom imageUrl')
      .populate('veterinaire', 'nom prenom')
      .populate('prise', 'nom debut fin lieu')
      .sort({ dateSoumission: -1 });

    res.success(lots, 'Liste des achats récupérée avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route GET /api/clients/purchases/:id
 * @desc Récupérer les achats d'un client spécifique
 * @access Private (Admin ou le client lui-même)
 */
router.get('/purchases/:id', auth, async (req, res, next) => {
  try {
    let clientId;

    // Vérifier si l'ID est un ObjectId valide
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      clientId = req.params.id;
    } else {
      // Si ce n'est pas un ObjectId, chercher le client par ID personnalisé
      const client = await Client.findOne({ id: req.params.id });

      if (!client) {
        return res.success([], 'Aucun achat trouvé pour ce client');
      }

      clientId = client._id;
    }

    // Vérifier les autorisations (admin ou le client lui-même)
    const isAdmin = req.user.roles.includes('ROLE_ADMIN');
    const isSelf = req.user._id.toString() === clientId.toString() ||
                  (req.user.id && req.user.id === req.params.id);

    if (!isAdmin && !isSelf) {
      throw new ForbiddenError('Vous n\'êtes pas autorisé à accéder à ces achats');
    }

    // Récupérer tous les lots achetés par ce client
    const Lot = require('../models/Lot');
    const lots = await Lot.find({ acheteur: clientId, vendu: true })
      .populate('espece', 'nom imageUrl')
      .populate('veterinaire', 'nom prenom')
      .populate('prise', 'nom debut fin lieu')
      .sort({ dateSoumission: -1 });

    res.success(lots, 'Liste des achats du client récupérée avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route GET /api/clients/:id
 * @desc Récupérer un client spécifique
 * @access Private (Admin ou le client lui-même)
 */
router.get('/:id', auth, async (req, res, next) => {
  try {
    let client;

    // Essayer de trouver par ObjectId (MongoDB ID)
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      client = await Client.findById(req.params.id);
    }

    // Si non trouvé, essayer de trouver par ID personnalisé
    if (!client) {
      client = await Client.findOne({ id: req.params.id });
    }

    if (!client) {
      throw new NotFoundError('Client non trouvé');
    }

    // Vérifier les autorisations (admin ou le client lui-même)
    const isAdmin = req.user.roles.includes('ROLE_ADMIN');
    const isSelf = req.user._id.toString() === client._id.toString() ||
                  (req.user.id && req.user.id === client.id);

    if (!isAdmin && !isSelf) {
      throw new ForbiddenError('Vous n\'êtes pas autorisé à accéder à ce profil');
    }

    res.success(client, 'Client récupéré avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route PATCH /api/clients/:id
 * @desc Mettre à jour un client
 * @access Private (Admin ou le client lui-même)
 */
router.patch('/:id', auth, async (req, res, next) => {
  try {
    let client;

    // Essayer de trouver par ObjectId (MongoDB ID)
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      client = await Client.findById(req.params.id);
    }

    // Si non trouvé, essayer de trouver par ID personnalisé
    if (!client) {
      client = await Client.findOne({ id: req.params.id });
    }

    if (!client) {
      throw new NotFoundError('Client non trouvé');
    }

    // Vérifier les autorisations (admin ou le client lui-même)
    const isAdmin = req.user.roles.includes('ROLE_ADMIN');
    const isSelf = req.user._id.toString() === client._id.toString() ||
                  (req.user.id && req.user.id === client.id);

    if (!isAdmin && !isSelf) {
      throw new ForbiddenError('Vous n\'êtes pas autorisé à modifier ce profil');
    }

    // Empêcher la modification de certains champs par le client lui-même
    if (!isAdmin && isSelf) {
      delete req.body.roles;
      delete req.body.isValidated;
      delete req.body.isBlocked;
    }

    // Mettre à jour le client
    const updatedClient = await Client.findByIdAndUpdate(client._id, req.body, {
      new: true,
      runValidators: true
    });

    res.success(updatedClient, 'Client mis à jour avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route DELETE /api/clients/:id
 * @desc Supprimer un client
 * @access Private (Admin uniquement)
 */
router.delete('/:id', auth, checkRole('ROLE_ADMIN'), async (req, res, next) => {
  try {
    let client;

    // Essayer de supprimer par ObjectId (MongoDB ID)
    if (mongoose.Types.ObjectId.isValid(req.params.id)) {
      client = await Client.findByIdAndDelete(req.params.id);
    }

    // Si non trouvé, essayer de supprimer par ID personnalisé
    if (!client) {
      client = await Client.findOneAndDelete({ id: req.params.id });
    }

    if (!client) {
      throw new NotFoundError('Client non trouvé');
    }

    res.success(null, 'Client supprimé avec succès');
  } catch (error) {
    next(error);
  }
});

module.exports = router;
