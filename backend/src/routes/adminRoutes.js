const express = require('express');
const router = express.Router();
const { isAdmin } = require('../middleware/adminAuth');
const { validateUser, toggleUserBlock, getPendingUsers } = require('../controllers/authController');

// Routes protégées par le middleware isAdmin
router.use(isAdmin);

// Obtenir la liste des utilisateurs en attente de validation
router.get('/pending-users', getPendingUsers);

// Valider un compte utilisateur
router.post('/validate/:userId', validateUser);

// Bloquer/débloquer un compte utilisateur
router.post('/toggle-block/:userId', toggleUserBlock);

module.exports = router;