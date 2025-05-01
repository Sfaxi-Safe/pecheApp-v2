require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const { errorHandler } = require('./middleware/errorHandler');
const { v4: uuidv4 } = require('uuid');

// Import des routes
const userRoutes = require('./routes/userRoutes');
const pecheurRoutes = require('./routes/pecheurRoutes');
const veterinaireRoutes = require('./routes/veterinaireRoutes');
const maryeurRoutes = require('./routes/maryeurRoutes');
const especeRoutes = require('./routes/especeRoutes');
const priseRoutes = require('./routes/priseRoutes');
const lotRoutes = require('./routes/lotRoutes');
const imageRoutes = require('./routes/imageRoutes');
const authRoutes = require('./routes/authRoutes');

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

// Servir les fichiers statiques
const path = require('path');
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Routes API
app.use('/api/users', userRoutes);
app.use('/api/pecheurs', pecheurRoutes);
app.use('/api/veterinaires', veterinaireRoutes);
app.use('/api/maryeurs', maryeurRoutes);
app.use('/api/especes', especeRoutes);
app.use('/api/prises', priseRoutes);
app.use('/api/lots', lotRoutes);
app.use('/api/images', imageRoutes);
app.use('/api/auth', authRoutes);

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

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Serveur démarré sur le port ${PORT}`);
});