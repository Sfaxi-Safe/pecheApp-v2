require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const { errorHandler } = require('./middleware/errorHandler');
const { v4: uuidv4 } = require('uuid');

// Import des routes
const userRoutes = require('./routes/userRoutes');
const pecheurRoutes = require('./routes/pecheurRoutes');
const vitirinaireRoutes = require('./routes/vitirinaireRoutes');
const maryeurRoutes = require('./routes/maryeurRoutes');
const especeRoutes = require('./routes/especeRoutes');
const priseRoutes = require('./routes/priseRoutes');
const lotRoutes = require('./routes/lotRoutes');
const imageRoutes = require('./routes/imageRoutes');

const app = express();

// Import du middleware de transformation
const { standardizeRequest, standardizeResponse, standardizeBooleans } = require('./middleware/dataTransformer');

// Middleware
app.use(cors());
app.use(express.json());

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
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/peche_marketplace')
  .then(() => console.log('Connecté à MongoDB'))
  .catch((err) => console.error('Erreur de connexion à MongoDB:', err));

// Routes
app.use('/api/users', userRoutes);
app.use('/api/pecheurs', pecheurRoutes);
app.use('/api/vitirinaires', vitirinaireRoutes);
app.use('/api/maryeurs', maryeurRoutes);
app.use('/api/especes', especeRoutes);
app.use('/api/prises', priseRoutes);
app.use('/api/lots', lotRoutes);
app.use('/api/images', imageRoutes);

// Gestion des erreurs
app.use(errorHandler);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Serveur démarré sur le port ${PORT}`);
});