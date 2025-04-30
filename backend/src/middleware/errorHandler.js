/**
 * Middleware de gestion des erreurs pour l'API
 */

// Journalisation des erreurs
const logError = (err, req) => {
  const timestamp = new Date().toISOString();
  const method = req.method;
  const url = req.originalUrl || req.url;
  const requestId = req.id || 'unknown';
  
  console.error(`[${timestamp}] ERROR [${method} ${url}] [${requestId}]:`);
  console.error(err);
  
  if (err.stack) {
    console.error(err.stack);
  }
};

// Middleware de gestion des erreurs
const errorHandler = (err, req, res, next) => {
  // Journaliser l'erreur
  logError(err, req);
  
  // Erreurs de validation Mongoose
  if (err.name === 'ValidationError') {
    const errors = Object.values(err.errors).map(e => e.message);
    return res.status(400).json({
      error: 'Erreur de validation',
      details: errors
    });
  }
  
  // Erreurs de validation personnalisées
  if (err.name === 'CustomValidationError') {
    return res.status(400).json({
      error: err.message,
      details: err.details
    });
  }
  
  // Erreurs d'authentification JWT
  if (err.name === 'JsonWebTokenError' || err.name === 'TokenExpiredError') {
    return res.status(401).json({
      error: 'Session expirée ou token invalide',
      details: 'Veuillez vous reconnecter'
    });
  }
  
  // Erreurs de duplication MongoDB
  if (err.name === 'MongoError' && err.code === 11000) {
    const field = Object.keys(err.keyValue)[0];
    return res.status(400).json({
      error: 'Conflit de données',
      details: `La valeur '${err.keyValue[field]}' pour le champ '${field}' existe déjà`
    });
  }
  
  // Erreurs de ressource non trouvée
  if (err.name === 'NotFoundError' || err.statusCode === 404) {
    return res.status(404).json({
      error: err.message || 'Ressource non trouvée',
      details: err.details
    });
  }
  
  // Erreurs d'autorisation
  if (err.name === 'ForbiddenError' || err.statusCode === 403) {
    return res.status(403).json({
      error: err.message || 'Accès refusé',
      details: err.details
    });
  }
  
  // Erreurs de requête incorrecte
  if (err.name === 'BadRequestError' || err.statusCode === 400) {
    return res.status(400).json({
      error: err.message || 'Requête incorrecte',
      details: err.details
    });
  }
  
  // Erreurs génériques
  const statusCode = err.statusCode || 500;
  const message = statusCode === 500 
    ? 'Erreur serveur interne' 
    : (err.message || 'Une erreur est survenue');
  
  res.status(statusCode).json({
    error: message,
    requestId: req.id // Pour faciliter le débogage
  });
};

// Classes d'erreurs personnalisées
class NotFoundError extends Error {
  constructor(message, details) {
    super(message || 'Ressource non trouvée');
    this.name = 'NotFoundError';
    this.statusCode = 404;
    this.details = details;
  }
}

class ForbiddenError extends Error {
  constructor(message, details) {
    super(message || 'Accès refusé');
    this.name = 'ForbiddenError';
    this.statusCode = 403;
    this.details = details;
  }
}

class BadRequestError extends Error {
  constructor(message, details) {
    super(message || 'Requête incorrecte');
    this.name = 'BadRequestError';
    this.statusCode = 400;
    this.details = details;
  }
}

class CustomValidationError extends Error {
  constructor(message, details) {
    super(message || 'Erreur de validation');
    this.name = 'CustomValidationError';
    this.details = details;
  }
}

module.exports = {
  errorHandler,
  NotFoundError,
  ForbiddenError,
  BadRequestError,
  CustomValidationError
};
