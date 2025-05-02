const express = require('express');
const router = express.Router();
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

module.exports = router;