/**
 * Configuration de la base de données MongoDB
 */
const mongoose = require('mongoose');

// Options de connexion
const options = {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  serverSelectionTimeoutMS: 5000, // Timeout après 5 secondes
  socketTimeoutMS: 45000, // Fermer les sockets après 45 secondes d'inactivité
  family: 4 // Utiliser IPv4, éviter les problèmes avec IPv6
};

// Fonction pour se connecter à MongoDB
const connectDB = async () => {
  try {
    const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/peche_marketplace';
    
    console.log(`Tentative de connexion à MongoDB: ${uri}`);
    
    await mongoose.connect(uri, options);
    
    console.log('Connecté à MongoDB avec succès');
    
    // Écouter les événements de connexion
    mongoose.connection.on('error', (err) => {
      console.error('Erreur de connexion MongoDB:', err);
    });
    
    mongoose.connection.on('disconnected', () => {
      console.warn('Déconnecté de MongoDB');
    });
    
    // Gérer les signaux de fermeture de l'application
    process.on('SIGINT', async () => {
      await mongoose.connection.close();
      console.log('Connexion MongoDB fermée suite à l\'arrêt de l\'application');
      process.exit(0);
    });
    
    return mongoose.connection;
  } catch (error) {
    console.error('Erreur de connexion à MongoDB:', error);
    // Ne pas faire planter l'application, mais permettre de continuer sans base de données
    // Utile pour le développement sans MongoDB installé
    return null;
  }
};

module.exports = { connectDB };
