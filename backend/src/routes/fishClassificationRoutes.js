/**
 * Routes pour la classification des poissons
 */
const express = require('express');
const router = express.Router();
const fishClassificationService = require('../services/fishClassificationService');
const { auth } = require('../middleware/auth');
const { BadRequestError } = require('../middleware/errorHandler');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Configuration de multer pour le stockage des images
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const uploadsDir = path.join(__dirname, '../../uploads/fish');
    
    // Créer le répertoire s'il n'existe pas
    if (!fs.existsSync(uploadsDir)) {
      fs.mkdirSync(uploadsDir, { recursive: true });
    }
    
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, 'fish-' + uniqueSuffix + ext);
  }
});

const upload = multer({ 
  storage,
  limits: {
    fileSize: 10 * 1024 * 1024 // 10 MB
  },
  fileFilter: (req, file, cb) => {
    // Accepter uniquement les images
    if (!file.mimetype.startsWith('image/')) {
      return cb(new Error('Seules les images sont acceptées'), false);
    }
    cb(null, true);
  }
});

/**
 * @route POST /api/fish-classification/classify
 * @desc Classifier un poisson à partir de son nom
 * @access Public
 */
router.post('/classify', async (req, res, next) => {
  try {
    const { nom } = req.body;
    
    if (!nom) {
      throw new BadRequestError('Nom du poisson requis');
    }
    
    const result = await fishClassificationService.classifyFish(nom);
    
    res.success(result, 'Poisson classifié avec succès');
  } catch (error) {
    next(error);
  }
});

/**
 * @route POST /api/fish-classification/classify-image
 * @desc Classifier un poisson à partir d'une image
 * @access Public
 */
router.post('/classify-image', upload.single('image'), async (req, res, next) => {
  try {
    if (!req.file) {
      throw new BadRequestError('Image requise');
    }
    
    // Lire l'image
    const imageBuffer = fs.readFileSync(req.file.path);
    const imageBase64 = imageBuffer.toString('base64');
    
    // Classifier l'image
    const result = await fishClassificationService.classifyFishImage(imageBase64);
    
    // Ajouter l'URL de l'image
    result.imageUrl = `/uploads/fish/${path.basename(req.file.path)}`;
    
    res.success(result, 'Poisson classifié avec succès');
  } catch (error) {
    // Supprimer l'image en cas d'erreur
    if (req.file) {
      fs.unlink(req.file.path, (err) => {
        if (err) console.error('Erreur lors de la suppression de l\'image:', err);
      });
    }
    
    next(error);
  }
});

/**
 * @route GET /api/fish-classification/species
 * @desc Récupérer la liste des espèces de poissons
 * @access Public
 */
router.get('/species', async (req, res, next) => {
  try {
    const data = await fishClassificationService.loadClassificationData();
    
    // Fusionner les listes d'espèces
    const allSpecies = [...new Set([...data.mediterraneanSpecies, ...data.additionalSpecies])].sort();
    
    res.success({
      species: allSpecies,
      count: allSpecies.length
    }, 'Liste des espèces récupérée avec succès');
  } catch (error) {
    next(error);
  }
});

module.exports = router;
