/**
 * Middleware pour gérer les CORS (Cross-Origin Resource Sharing)
 */
const cors = require('cors');

// Configuration CORS par défaut
const corsOptions = {
  origin: function (origin, callback) {
    // Lire les origines autorisées depuis la variable d'environnement
    const allowedOrigins = (process.env.CORS_ORIGIN || 'http://localhost:5173,http://192.168.3.233:*').split(',');

    // Autoriser les requêtes sans origine (comme les appels API mobiles)
    if (!origin) {
      return callback(null, true);
    }

    // Vérifier si l'origine est autorisée
    // Pour le développement mobile, nous autorisons toutes les origines
    callback(null, true);

    /* Décommentez ce bloc pour une sécurité plus stricte en production
    if (allowedOrigins.indexOf(origin) !== -1 || allowedOrigins.includes('*')) {
      callback(null, true);
    } else {
      callback(new Error('Non autorisé par CORS'));
    }
    */
  },
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  credentials: true,
  maxAge: 86400 // 24 heures
};

// Middleware CORS
const corsMiddleware = cors(corsOptions);

module.exports = corsMiddleware;
