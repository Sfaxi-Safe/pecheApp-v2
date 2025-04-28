require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

// Import des routes
const userRoutes = require('./routes/userRoutes');
const pecheurRoutes = require('./routes/pecheurRoutes');
const vitirinaireRoutes = require('./routes/vitirinaireRoutes');
const maryeurRoutes = require('./routes/maryeurRoutes');
const especeRoutes = require('./routes/especeRoutes');
const priseRoutes = require('./routes/priseRoutes');
const lotRoutes = require('./routes/lotRoutes');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

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

// Gestion des erreurs
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Une erreur est survenue!');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Serveur démarré sur le port ${PORT}`);
});