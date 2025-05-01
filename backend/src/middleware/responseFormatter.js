/**
 * Middleware pour formater les réponses API de manière cohérente
 */

// Middleware pour formater les réponses
const responseFormatter = (req, res, next) => {
  // Sauvegarder les méthodes originales
  const originalJson = res.json;
  const originalSend = res.send;

  // Remplacer res.json
  res.json = function(data) {
    // Si la réponse est déjà formatée (contient success), ne pas la reformater
    if (data && (data.success === true || data.success === false)) {
      return originalJson.call(this, data);
    }

    // Formater la réponse
    const formattedData = {
      success: true,
      data: data
    };

    // Ajouter un message si le statut est 201 (Created)
    if (res.statusCode === 201) {
      formattedData.message = 'Ressource créée avec succès';
    }

    return originalJson.call(this, formattedData);
  };

  // Remplacer res.send pour les réponses non-JSON
  res.send = function(data) {
    // Si c'est une chaîne ou un buffer, ne pas formater
    if (typeof data === 'string' || Buffer.isBuffer(data)) {
      return originalSend.call(this, data);
    }
    
    // Sinon, utiliser json pour formater
    return res.json(data);
  };

  // Ajouter des méthodes utilitaires
  res.success = function(data, message, statusCode = 200) {
    return res.status(statusCode).json({
      success: true,
      message: message,
      data: data
    });
  };

  res.created = function(data, message = 'Ressource créée avec succès') {
    return res.status(201).json({
      success: true,
      message: message,
      data: data
    });
  };

  res.error = function(message, statusCode = 400, details = null) {
    const response = {
      success: false,
      error: message
    };
    
    if (details) {
      response.details = details;
    }
    
    return res.status(statusCode).json(response);
  };

  next();
};

module.exports = responseFormatter;
