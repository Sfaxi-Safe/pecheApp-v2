/**
 * Service de classification des poissons
 * Fournit des méthodes pour classifier les poissons
 */
const Espece = require('../models/Espece');
const notificationService = require('./notificationService');
const cacheService = require('./cacheService');
const path = require('path');
const fs = require('fs');

/**
 * Charge les données de classification des poissons
 * @returns {Promise<Object>} Les données de classification
 */
const loadClassificationData = async () => {
  try {
    // Chemin vers le fichier de données
    const dataPath = path.join(__dirname, '../data/fish_species.json');
    
    // Vérifier si le fichier existe
    if (!fs.existsSync(dataPath)) {
      console.warn('Fichier de données de classification non trouvé:', dataPath);
      return {
        mediterraneanSpecies: [],
        additionalSpecies: [],
        englishToFrench: {},
        frenchToScientific: {}
      };
    }
    
    // Lire le fichier
    const data = fs.readFileSync(dataPath, 'utf8');
    
    // Parser les données
    return JSON.parse(data);
  } catch (error) {
    console.error('Erreur lors du chargement des données de classification:', error);
    return {
      mediterraneanSpecies: [],
      additionalSpecies: [],
      englishToFrench: {},
      frenchToScientific: {}
    };
  }
};

/**
 * Classifie un poisson à partir de son nom
 * @param {string} fishName - Nom du poisson
 * @returns {Promise<Object>} Résultat de la classification
 */
const classifyFish = async (fishName) => {
  try {
    if (!fishName) {
      throw new Error('Nom du poisson requis');
    }
    
    // Normaliser le nom du poisson (minuscules, sans accents)
    const normalizedName = fishName.toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '');
    
    // Charger les données de classification
    const classificationData = await loadClassificationData();
    
    // Chercher dans les mappings
    let frenchName = normalizedName;
    let scientificName = '';
    
    // Vérifier si le nom est en anglais
    if (classificationData.englishToFrench[normalizedName]) {
      frenchName = classificationData.englishToFrench[normalizedName];
    }
    
    // Récupérer le nom scientifique
    if (classificationData.frenchToScientific[frenchName]) {
      scientificName = classificationData.frenchToScientific[frenchName];
    }
    
    // Chercher l'espèce dans la base de données
    let espece = await Espece.findOne({ 
      $or: [
        { nom: { $regex: new RegExp(frenchName, 'i') } },
        { nomScientifique: { $regex: new RegExp(scientificName, 'i') } }
      ]
    });
    
    // Si l'espèce n'existe pas, la créer
    if (!espece) {
      espece = new Espece({
        nom: frenchName,
        nomScientifique: scientificName,
        description: `Espèce de poisson: ${frenchName}`,
        imageUrl: '/images/default-fish.jpg',
        confiance: 1.0,
        source: 'api'
      });
      
      await espece.save();
      
      // Invalider le cache
      cacheService.invalidate('especes:all');
      
      // Notifier les administrateurs
      try {
        const Admin = require('../models/Admin');
        const admins = await Admin.find();
        
        for (const admin of admins) {
          await notificationService.notifierAdmin(
            admin._id,
            'Nouvelle espèce détectée',
            `Une nouvelle espèce de poisson a été détectée: ${frenchName}`,
            'info',
            {
              reference: espece._id,
              referenceModel: 'Espece',
              urlAction: `/admin/especes/${espece._id}`
            }
          );
        }
      } catch (notifError) {
        console.error('Erreur lors de l\'envoi des notifications:', notifError);
      }
    }
    
    return {
      id: espece._id,
      nom: espece.nom,
      nomScientifique: espece.nomScientifique,
      confiance: 1.0,
      source: 'api'
    };
  } catch (error) {
    console.error('Erreur lors de la classification du poisson:', error);
    throw error;
  }
};

/**
 * Classifie un poisson à partir d'une image
 * @param {string} imageBase64 - Image en base64
 * @returns {Promise<Object>} Résultat de la classification
 */
const classifyFishImage = async (imageBase64) => {
  // Cette fonction serait implémentée avec TensorFlow.js ou une API externe
  // Pour l'instant, elle retourne un résultat fictif
  return {
    nom: 'Thon',
    nomScientifique: 'Thunnus thynnus',
    confiance: 0.85,
    source: 'tensorflow',
    alternatives: [
      { nom: 'Dorade', nomScientifique: 'Sparus aurata', confiance: 0.10 },
      { nom: 'Bar', nomScientifique: 'Dicentrarchus labrax', confiance: 0.05 }
    ]
  };
};

module.exports = {
  classifyFish,
  classifyFishImage,
  loadClassificationData
};
