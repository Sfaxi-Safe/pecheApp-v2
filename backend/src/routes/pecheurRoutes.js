const express = require('express');
const pecheurController = require('../controllers/pecheurController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

// Routes protégées pour les pêcheurs
router.use(authMiddleware);

// Obtenir tous les pêcheurs
router.get('/', pecheurController.getAllPecheurs);

// Obtenir un pêcheur par ID
router.get('/:id', pecheurController.getPecheurById);

// Mettre à jour un pêcheur
router.put('/:id', pecheurController.updatePecheur);

// Supprimer un pêcheur
router.delete('/:id', pecheurController.deletePecheur);

// Ajouter une prise
router.post('/:id/prises', pecheurController.addPrise);

// Obtenir les prises d'un pêcheur
router.get('/:id/prises', pecheurController.getPrises);

module.exports = router;