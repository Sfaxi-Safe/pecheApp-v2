const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const { auth, checkRole } = require('../middleware/auth');
const { validateUser, toggleUserBlock, getPendingUsers } = require('../controllers/authController');

// Routes protégées par le middleware auth et checkRole
router.use(auth, checkRole('ROLE_ADMIN'));

// Obtenir la liste des utilisateurs en attente de validation
router.get('/pending-users', getPendingUsers);

// Valider un compte utilisateur
router.post('/validate/:userId', validateUser);

// Bloquer/débloquer un compte utilisateur
router.post('/toggle-block/:userId', toggleUserBlock);

/**
 * @route GET /api/admins
 * @desc Récupérer tous les administrateurs
 * @access Private (Admin uniquement)
 */
router.get('/', async (req, res, next) => {
  try {
    // Retourner une liste d'administrateurs fictive pour le moment
    const admins = [
      {
        id: 'admin1',
        nom: 'Admin',
        prenom: 'Principal',
        email: 'admin@seatrace.com',
        roles: ['ROLE_ADMIN']
      },
      {
        id: 'admin2',
        nom: 'Admin',
        prenom: 'Secondaire',
        email: 'admin2@seatrace.com',
        roles: ['ROLE_ADMIN']
      }
    ];

    res.success(admins, 'Liste des administrateurs récupérée avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route GET /api/admins/:id
 * @desc Récupérer un administrateur spécifique
 * @access Private (Admin uniquement)
 */
router.get('/:id', async (req, res, next) => {
  try {
    // Retourner un administrateur fictif pour le moment
    const admin = {
      id: req.params.id,
      nom: 'Admin',
      prenom: 'Principal',
      email: 'admin@seatrace.com',
      roles: ['ROLE_ADMIN']
    };

    res.success(admin, 'Administrateur récupéré avec succès');
  } catch (error) {
    next(error);
  }
});

module.exports = router;