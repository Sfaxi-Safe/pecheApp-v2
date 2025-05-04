require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const { errorHandler } = require('./middleware/errorHandler');
const { v4: uuidv4 } = require('uuid');

// Import des routes
const adminRoutes = require('./routes/adminRoutes');
const clientRoutes = require('./routes/clientRoutes');
const pecheurRoutes = require('./routes/pecheurRoutes');
const veterinaireRoutes = require('./routes/veterinairesRoutes');
const maryeurRoutes = require('./routes/maryeurRoutes');
const especeRoutes = require('./routes/especeRoutes');
const priseRoutes = require('./routes/priseRoutes');
const lotRoutes = require('./routes/lotRoutes');
const imageRoutes = require('./routes/imageRoutes');
const authRoutes = require('./routes/authRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const statsRoutes = require('./routes/statsRoutes');
const fishClassificationRoutes = require('./routes/fishClassificationRoutes');

const app = express();

// Import du middleware de transformation
const { standardizeRequest, standardizeResponse, standardizeBooleans } = require('./middleware/dataTransformer');

// Import des middlewares personnalisés
const corsMiddleware = require('./middleware/corsMiddleware');
const responseFormatter = require('./middleware/responseFormatter');

// Middleware
app.use(corsMiddleware);
app.use(express.json({ limit: '50mb' })); // Augmenter la limite pour les uploads d'images
app.use(express.urlencoded({ extended: true, limit: '50mb' }));
app.use(responseFormatter); // Formater les réponses API

// Ajouter un identifiant unique à chaque requête pour faciliter le débogage
app.use((req, res, next) => {
  req.id = uuidv4();
  next();
});

// Middleware pour standardiser les données
app.use(standardizeRequest);
app.use(standardizeResponse);
app.use(standardizeBooleans);

// Configuration de la connexion MongoDB
const { connectDB } = require('./config/database');
connectDB();

// Vérifier et créer le dossier d'uploads si nécessaire
const path = require('path');
const fs = require('fs');
const uploadsDir = path.join(__dirname, '../uploads');

try {
  if (!fs.existsSync(uploadsDir)) {
    console.log(`Création du dossier d'uploads depuis index.js: ${uploadsDir}`);
    fs.mkdirSync(uploadsDir, { recursive: true });
    // Définir les permissions (0755 = rwxr-xr-x)
    fs.chmodSync(uploadsDir, 0o755);
    console.log(`Dossier d'uploads créé avec succès avec les permissions 0755`);
  } else {
    // Vérifier les permissions
    try {
      const stats = fs.statSync(uploadsDir);
      const currentPermissions = stats.mode & 0o777; // Masque pour obtenir uniquement les permissions
      console.log(`Permissions actuelles du dossier d'uploads: ${currentPermissions.toString(8)}`);

      // Si les permissions ne sont pas suffisantes, les mettre à jour
      if (currentPermissions !== 0o755) {
        fs.chmodSync(uploadsDir, 0o755);
        console.log(`Permissions du dossier d'uploads mises à jour à 0755`);
      }
    } catch (error) {
      console.error(`Erreur lors de la vérification des permissions:`, error);
    }
  }
} catch (error) {
  console.error('Erreur lors de la création du dossier d\'uploads:', error);
}

// Servir les fichiers statiques
app.use('/uploads', express.static(uploadsDir));

// Routes API
app.use('/api/admins', adminRoutes);
app.use('/api/clients', clientRoutes);
app.use('/api/pecheurs', pecheurRoutes);
app.use('/api/veterinaires', veterinaireRoutes);
app.use('/api/maryeurs', maryeurRoutes);
app.use('/api/especes', especeRoutes);
app.use('/api/prises', priseRoutes);
app.use('/api/lots', lotRoutes);
app.use('/api/images', imageRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/stats', statsRoutes);
app.use('/api/fish-classification', fishClassificationRoutes);

// Route de test pour vérifier que le serveur fonctionne
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'Le serveur fonctionne correctement',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development'
  });
});

// Gestion des erreurs
app.use(errorHandler);

// Utiliser le port configuré dans .env ou 3005 par défaut
const PORT = 3005; // Fixer le port à 3005 pour éviter les changements
const HOST = '0.0.0.0'; // Écouter sur toutes les interfaces réseau
console.log(`Port utilisé pour le serveur: ${PORT}`);
console.log(`Adresse d'écoute: ${HOST} (toutes les interfaces réseau)`);
app.listen(PORT, HOST, () => {
  console.log(`Serveur démarré sur http://${HOST}:${PORT}`);
  console.log(`Pour accéder au serveur depuis d'autres appareils, utilisez l'adresse IP de cet ordinateur`);
});