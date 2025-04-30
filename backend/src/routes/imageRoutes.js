const express = require('express');
const router = express.Router();
const upload = require('../middleware/upload');
const { uploadImage, getImage, deleteImage } = require('../controllers/imageController');
const { auth } = require('../middleware/auth');

// Route pour télécharger une image (nécessite authentification)
router.post('/upload', auth, upload.single('image'), uploadImage);

// Route pour récupérer une image par son nom de fichier (publique)
router.get('/:filename', getImage);

// Route pour supprimer une image (nécessite authentification)
router.delete('/:filename', auth, deleteImage);

module.exports = router;
