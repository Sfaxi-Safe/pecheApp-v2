const express = require('express');
const especeController = require('../controllers/especeController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

// Routes protégées pour les espèces
router.use(authMiddleware);

// Obtenir toutes les espèces
router.get('/', especeController.getAllEspeces);

// Obtenir une espèce par ID
router.get('/:id', especeController.getEspeceById);

// Créer une nouvelle espèce
router.post('/', especeController.createEspece);

// Mettre à jour une espèce
router.put('/:id', especeController.updateEspece);

// Supprimer une espèce
router.delete('/:id', especeController.deleteEspece);

// Obtenir les statistiques d'une espèce
router.get('/:id/stats', especeController.getEspeceStats);

// Obtenir le prix moyen d'une espèce
router.get('/:id/prix-moyen', especeController.getAveragePrice);

module.exports = router;