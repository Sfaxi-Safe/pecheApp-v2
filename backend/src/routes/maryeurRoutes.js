const express = require('express');
const maryeurController = require('../controllers/maryeurController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

// Routes protégées pour les mareyeurs
router.use(authMiddleware);

// Obtenir tous les mareyeurs
router.get('/', maryeurController.getAllMaryeurs);

// Obtenir un mareyeur par ID
router.get('/:id', maryeurController.getMaryeurById);

// Mettre à jour un mareyeur
router.put('/:id', maryeurController.updateMaryeur);

// Supprimer un mareyeur
router.delete('/:id', maryeurController.deleteMaryeur);

// Créer un lot
router.post('/:id/lots', maryeurController.createLot);

// Obtenir les lots d'un mareyeur
router.get('/:id/lots', maryeurController.getLots);

// Mettre à jour un lot
router.put('/:id/lots/:lotId', maryeurController.updateLot);

// Supprimer un lot
router.delete('/:id/lots/:lotId', maryeurController.deleteLot);

module.exports = router;