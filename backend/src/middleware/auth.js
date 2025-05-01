const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');
const User = require('../models/User');
const Pecheur = require('../models/Pecheur');
const Veterinaire = require('../models/Veterinaire');
const Maryeur = require('../models/Maryeur');

/**
 * Middleware d'authentification
 * Vérifie le token JWT et charge l'utilisateur correspondant
 *
 * Ce middleware effectue les opérations suivantes :
 * 1. Récupère le token JWT depuis l'en-tête Authorization
 * 2. Vérifie la validité du token
 * 3. Recherche l'utilisateur correspondant dans la base de données
 * 4. Vérifie si l'utilisateur est validé et non bloqué
 * 5. Ajoute l'utilisateur et le token à l'objet request
 *
 * @param {Object} req - L'objet request Express
 * @param {Object} res - L'objet response Express
 * @param {Function} next - La fonction middleware suivante
 */
const auth = async (req, res, next) => {
  try {
    // Récupérer le token depuis l'en-tête Authorization
    const token = req.header('Authorization')?.replace('Bearer ', '');
    if (!token) {
      return res.error('Token d\'authentification manquant', 401);
    }

    // Vérifier et décoder le token
    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (err) {
      if (err.name === 'TokenExpiredError') {
        return res.error('Session expirée, veuillez vous reconnecter', 401);
      }
      return res.error('Token d\'authentification invalide', 401);
    }

    // Rechercher l'utilisateur dans la base de données
    let user;

    // Vérifier dans chaque collection selon le rôle
    // Adapter pour fonctionner avec roles en tant que string
    const roles = typeof decoded.roles === 'string' ? decoded.roles : '';

    // Essayer de trouver l'utilisateur par ID MongoDB ou ID personnalisé
    const findUserById = async (Model, id) => {
      let foundUser = null;

      // Essayer d'abord avec l'ID MongoDB
      if (mongoose.Types.ObjectId.isValid(id)) {
        foundUser = await Model.findById(id);
      }

      // Si non trouvé, essayer avec l'ID personnalisé
      if (!foundUser) {
        foundUser = await Model.findOne({ id: id });
      }

      return foundUser;
    };

    if (roles.includes('ROLE_CLIENT') || roles.includes('ROLE_ADMIN')) {
      user = await findUserById(User, decoded._id);
    } else if (roles.includes('ROLE_PECHEUR')) {
      user = await findUserById(Pecheur, decoded._id);
    } else if (roles.includes('ROLE_VETERINAIRE')) {
      user = await findUserById(Veterinaire, decoded._id);
    } else if (roles.includes('ROLE_MARYEUR')) {
      user = await findUserById(Maryeur, decoded._id);
    }

    // Vérifier si l'utilisateur existe
    if (!user) {
      return res.error('Utilisateur non trouvé', 401);
    }

    // Vérifier si l'utilisateur est validé
    const isAdmin = typeof decoded.roles === 'string' ? decoded.roles.includes('ROLE_ADMIN') : false;
    if (!(user.isValidated || user.isValid) && !isAdmin) {
      return res.error('Votre compte est en attente de validation', 403);
    }

    // Vérifier si l'utilisateur est bloqué
    if (user.isBlocked) {
      return res.error('Votre compte a été bloqué', 403);
    }

    // Ajouter l'utilisateur et le token à la requête
    req.token = token;
    req.user = user;
    next();
  } catch (error) {
    console.error('Erreur d\'authentification:', error);
    res.error('Erreur d\'authentification', 401);
  }
};

/**
 * Middleware pour vérifier les rôles
 * Vérifie si l'utilisateur authentifié possède au moins un des rôles requis
 *
 * Ce middleware effectue les opérations suivantes :
 * 1. Vérifie si l'utilisateur est authentifié
 * 2. Vérifie si l'utilisateur possède au moins un des rôles requis
 * 3. Renvoie une erreur 403 si l'utilisateur n'a pas les autorisations nécessaires
 *
 * @param {Array|String} roles - Rôle(s) autorisé(s)
 * @returns {Function} Middleware Express
 */
const checkRole = (roles) => {
  // Convertir en tableau si c'est une chaîne
  const roleArray = Array.isArray(roles) ? roles : [roles];

  return (req, res, next) => {
    // Vérifier si l'utilisateur existe
    if (!req.user) {
      return res.error('Utilisateur non authentifié', 401);
    }

    // Vérifier si l'utilisateur a au moins un des rôles requis
    // Adapter pour fonctionner avec roles en tant que string
    const userRoles = req.user.roles || '';

    if (typeof userRoles === 'string') {
      // Si roles est une chaîne, vérifier si elle contient l'un des rôles requis
      if (!roleArray.some(role => userRoles.includes(role))) {
        return res.error(`Accès réservé aux rôles: ${roleArray.join(', ')}`, 403);
      }
    } else {
      return res.error('Format de rôle invalide', 403);
    }

    next();
  };
};

module.exports = {
  auth,
  checkRole
};