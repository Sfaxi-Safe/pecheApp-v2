const express = require('express');
const router = express.Router();
const multer = require('multer');
const upload = require('../middleware/upload');
const { uploadImage, getImage, deleteImage } = require('../controllers/imageController');
const { auth } = require('../middleware/auth');

// Middleware pour gérer les erreurs de multer
const handleMulterError = (err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    // Erreur Multer spécifique
    console.error('Erreur Multer:', err);
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        error: 'La taille du fichier dépasse la limite de 5 MB'
      });
    }
    return res.status(400).json({ error: `Erreur d'upload: ${err.message}` });
  } else if (err) {
    // Autre erreur
    console.error('Erreur lors de l\'upload:', err);
    return res.status(500).json({ error: err.message });
  }
  next();
};

// Route pour télécharger une image (nécessite authentification)
router.post('/upload', auth, (req, res, next) => {
  console.log('Requête d\'upload d\'image reçue');
  upload.single('image')(req, res, (err) => {
    if (err) {
      console.error('Erreur lors de l\'upload:', err);
      if (err instanceof multer.MulterError) {
        // Erreur Multer spécifique
        if (err.code === 'LIMIT_FILE_SIZE') {
          return res.status(400).json({
            error: 'La taille du fichier dépasse la limite de 5 MB'
          });
        }
        return res.status(400).json({ error: `Erreur d'upload: ${err.message}` });
      }
      return res.status(500).json({ error: err.message });
    }
    // Pas d'erreur, continuer vers le contrôleur
    next();
  });
}, uploadImage);

// Route de test pour vérifier la configuration du serveur d'upload
router.get('/test', auth, (req, res) => {
  try {
    const fs = require('fs');
    const path = require('path');
    const uploadDir = path.join(__dirname, '../../uploads');

    // Vérifier si le dossier d'upload existe
    const dirExists = fs.existsSync(uploadDir);

    // Vérifier les permissions d'écriture
    let writePermission = false;
    try {
      fs.accessSync(uploadDir, fs.constants.W_OK);
      writePermission = true;
    } catch (error) {
      console.error('Erreur de permission sur le dossier d\'upload:', error);
    }

    // Tester la création d'un fichier temporaire
    let canCreateFile = false;
    const testFilePath = path.join(uploadDir, `test-${Date.now()}.txt`);
    try {
      fs.writeFileSync(testFilePath, 'Test file');
      canCreateFile = true;
      // Supprimer le fichier de test
      fs.unlinkSync(testFilePath);
    } catch (error) {
      console.error('Erreur lors de la création du fichier de test:', error);
    }

    res.status(200).json({
      success: true,
      message: 'Test de configuration du serveur d\'upload',
      config: {
        dirExists,
        writePermission,
        canCreateFile,
        uploadDir
      }
    });
  } catch (error) {
    console.error('Erreur lors du test de configuration:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Route pour récupérer une image par son nom de fichier (publique)
router.get('/:filename', getImage);

// Route pour supprimer une image (nécessite authentification)
router.delete('/:filename', auth, deleteImage);

module.exports = router;
