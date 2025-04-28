const express = require('express');
const veterinaireController = require('../controllers/veterinaireController');
const authMiddleware = require('../middleware/authMiddleware');

const router = express.Router();

// Routes protégées pour les vétérinaires
router.use(authMiddleware);

// Obtenir tous les vétérinaires
router.get('/', veterinaireController.getAllVeterinaires);

// Obtenir un vétérinaire par ID
router.get('/:id', veterinaireController.getVeterinaireById);

// Mettre à jour un vétérinaire
router.put('/:id', veterinaireController.updateVeterinaire);

// Supprimer un vétérinaire
router.delete('/:id', veterinaireController.deleteVeterinaire);

// Inspecter un lot
router.post('/lots/:lotId/inspect', veterinaireController.inspectLot);

// Obtenir l'historique des inspections
router.get('/:id/inspections', veterinaireController.getInspections);

// Certifier un lot
router.post('/lots/:lotId/certify', veterinaireController.certifyLot);

// Obtenir les certifications
router.get('/:id/certifications', veterinaireController.getCertifications);

module.exports = router;