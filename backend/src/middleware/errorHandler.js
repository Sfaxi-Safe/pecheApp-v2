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
      success: false,
      error: 'Erreur de validation',
      details: errors,
      code: 'VALIDATION_ERROR'
    });
  }

  // Erreurs de validation personnalisées
  if (err.name === 'CustomValidationError') {
    return res.status(400).json({
      success: false,
      error: err.message,
      details: err.details,
      code: 'CUSTOM_VALIDATION_ERROR'
    });
  }

  // Erreurs d'authentification JWT
  if (err.name === 'JsonWebTokenError' || err.name === 'TokenExpiredError') {
    return res.status(401).json({
      success: false,
      error: 'Session expirée ou token invalide',
      details: 'Veuillez vous reconnecter',
      code: 'AUTH_ERROR'
    });
  }

  // Erreurs de duplication MongoDB
  if (err.name === 'MongoServerError' && err.code === 11000) {
    const field = Object.keys(err.keyPattern)[0];
    const value = err.keyValue ? err.keyValue[field] : 'inconnue';
    return res.status(400).json({
      success: false,
      error: 'Conflit de données',
      details: `La valeur '${value}' pour le champ '${field}' existe déjà`,
      code: 'DUPLICATE_KEY_ERROR',
      field: field
    });
  }

  // Erreurs de ressource non trouvée
  if (err.name === 'NotFoundError' || err.statusCode === 404) {
    return res.status(404).json({
      success: false,
      error: err.message || 'Ressource non trouvée',
      details: err.details,
      code: 'NOT_FOUND_ERROR'
    });
  }

  // Erreurs d'autorisation
  if (err.name === 'ForbiddenError' || err.statusCode === 403) {
    return res.status(403).json({
      success: false,
      error: err.message || 'Accès refusé',
      details: err.details,
      code: 'FORBIDDEN_ERROR'
    });
  }

  // Erreurs de requête incorrecte
  if (err.name === 'BadRequestError' || err.statusCode === 400) {
    return res.status(400).json({
      success: false,
      error: err.message || 'Requête incorrecte',
      details: err.details,
      code: 'BAD_REQUEST_ERROR'
    });
  }

  // Erreurs de connexion à la base de données
  if (err.name === 'MongooseServerSelectionError') {
    console.error('Erreur de connexion à MongoDB:', err);
    return res.status(500).json({
      success: false,
      error: 'Erreur de connexion à la base de données',
      details: 'Impossible de se connecter à MongoDB. Veuillez vérifier que le service est en cours d\'exécution.',
      code: 'DATABASE_CONNECTION_ERROR'
    });
  }

  // Erreurs génériques
  const statusCode = err.statusCode || 500;
  const message = statusCode === 500
    ? 'Erreur serveur interne'
    : (err.message || 'Une erreur est survenue');

  res.status(statusCode).json({
    success: false,
    error: message,
    requestId: req.id, // Pour faciliter le débogage
    code: err.code || 'INTERNAL_SERVER_ERROR'
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
