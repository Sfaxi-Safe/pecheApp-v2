const auth = require('./auth');

const authMiddleware = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Token d\'authentification manquant' });
    }

    const token = authHeader.split(' ')[1];
    const decoded = auth.verifyToken(token);

    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ message: 'Token invalide ou expiré' });
  }
};

module.exports = authMiddleware;