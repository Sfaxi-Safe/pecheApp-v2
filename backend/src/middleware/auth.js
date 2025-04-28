const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Pecheur = require('../models/Pecheur');
const Vitirinaire = require('../models/Vitirinaire');
const Maryeur = require('../models/Maryeur');

const auth = async (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    if (!token) {
      throw new Error();
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    let user;

    // Vérifier dans chaque collection selon le rôle
    if (decoded.roles.includes('ROLE_CLIENT') || decoded.roles.includes('ROLE_ADMIN')) {
      user = await User.findById(decoded._id);
    } else if (decoded.roles.includes('ROLE_PECHEUR')) {
      user = await Pecheur.findById(decoded._id);
    } else if (decoded.roles.includes('ROLE_VETERINAIRE')) {
      user = await Vitirinaire.findById(decoded._id);
    } else if (decoded.roles.includes('ROLE_MARYEUR')) {
      user = await Maryeur.findById(decoded._id);
    }

    if (!user) {
      throw new Error();
    }

    req.token = token;
    req.user = user;
    next();
  } catch (error) {
    res.status(401).send({ error: 'Veuillez vous authentifier.' });
  }
};

// Middleware pour vérifier les rôles
const checkRole = (roles) => {
  return (req, res, next) => {
    if (!req.user.roles.some(role => roles.includes(role))) {
      return res.status(403).send({ error: 'Accès non autorisé' });
    }
    next();
  };
};

module.exports = {
  auth,
  checkRole
};