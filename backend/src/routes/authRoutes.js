/**
 * Routes d'authentification
 */
const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const {
  register,
  login,
  getProfile,
  requestPasswordReset,
  resetPassword
} = require('../controllers/authController');

/**
 * @route POST /api/auth/register
 * @desc Inscription d'un nouvel utilisateur
 * @access Public
 */
router.post('/register', register);

/**
 * @route POST /api/auth/login
 * @desc Connexion d'un utilisateur
 * @access Public
 */
router.post('/login', login);

/**
 * @route GET /api/auth/profile
 * @desc Récupération du profil de l'utilisateur connecté
 * @access Private
 */
router.get('/profile', auth, getProfile);

/**
 * @route GET /api/auth/me
 * @desc Récupération du profil de l'utilisateur connecté (alias pour /profile)
 * @access Private
 */
router.get('/me', auth, getProfile);

/**
 * @route GET /api/auth/check
 * @desc Vérification de l'authentification
 * @access Private
 */
/**
 * Route pour vérifier l'authentification
 * Renvoie les informations de base de l'utilisateur connecté
 */
router.get('/check', auth, (req, res) => {
  // Utiliser l'ID personnalisé s'il existe, sinon utiliser l'ID MongoDB
  const userId = req.user.id || req.user._id.toString();

  res.success({
    user: {
      id: userId,
      email: req.user.email,
      roles: req.user.roles,
      userType: req.user.getUserType ? req.user.getUserType() : 'client'
    }
  }, 'Utilisateur authentifié');
});

/**
 * @route POST /api/auth/request-reset
 * @desc Demande de réinitialisation de mot de passe
 * @access Public
 */
router.post('/request-reset', requestPasswordReset);

/**
 * @route POST /api/auth/reset-password
 * @desc Réinitialisation du mot de passe
 * @access Public
 */
router.post('/reset-password', resetPassword);

module.exports = router;