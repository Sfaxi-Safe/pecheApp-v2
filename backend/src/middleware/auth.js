const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Pecheur = require('../models/Pecheur');
const Veterinaire = require('../models/Veterinaire');
const Maryeur = require('../models/Maryeur');

/**
 * Middleware d'authentification
 * Vérifie le token JWT et charge l'utilisateur correspondant
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

    if (roles.includes('ROLE_CLIENT') || roles.includes('ROLE_ADMIN')) {
      user = await User.findById(decoded._id);
    } else if (roles.includes('ROLE_PECHEUR')) {
      user = await Pecheur.findById(decoded._id);
    } else if (roles.includes('ROLE_VETERINAIRE')) {
      user = await Veterinaire.findById(decoded._id);
    } else if (roles.includes('ROLE_MARYEUR')) {
      user = await Maryeur.findById(decoded._id);
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