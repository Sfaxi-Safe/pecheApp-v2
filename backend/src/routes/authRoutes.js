/**
 * Routes d'authentification
 */
const express = require('express');
const router = express.Router();
const { auth } = require('../middleware/auth');
const { register, login, getProfile } = require('../controllers/authController');

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
 * @route GET /api/auth/check
 * @desc Vérification de l'authentification
 * @access Private
 */
router.get('/check', auth, (req, res) => {
  res.success({
    user: {
      _id: req.user._id,
      email: req.user.email,
      roles: req.user.roles,
      userType: req.user.getUserType ? req.user.getUserType() : 'client'
    }
  }, 'Utilisateur authentifié');
});

module.exports = router;