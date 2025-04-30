const jwt = require('jsonwebtoken');

// Middleware pour vérifier si l'utilisateur est un administrateur
const isAdmin = async (req, res, next) => {
  try {
    // Vérifier si le token existe dans les headers
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
      return res.status(401).json({ error: 'Token non fourni' });
    }

    // Vérifier et décoder le token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Vérifier si l'utilisateur a le rôle admin
    if (!decoded.roles.includes('ROLE_ADMIN')) {
      return res.status(403).json({ error: 'Accès non autorisé' });
    }

    // Ajouter les informations de l'utilisateur à la requête
    req.user = decoded;
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ error: 'Token invalide' });
    }
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expiré' });
    }
    res.status(500).json({ error: error.message });
  }
};

module.exports = { isAdmin };