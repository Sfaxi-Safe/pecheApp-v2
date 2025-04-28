const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Pecheur = require('../models/Pecheur');
const Vitirinaire = require('../models/Vitirinaire');
const Maryeur = require('../models/Maryeur');

// Générer le token JWT
const generateToken = (user) => {
  return jwt.sign(
    { _id: user._id, roles: user.roles },
    process.env.JWT_SECRET,
    { expiresIn: '24h' }
  );
};

// Inscription
const register = async (req, res) => {
  try {
    const { email, password, role, ...userData } = req.body;

    // Vérifier si l'email existe déjà
    const emailExists = await Promise.all([
      User.findOne({ email }),
      Pecheur.findOne({ email }),
      Vitirinaire.findOne({ email }),
      Maryeur.findOne({ email })
    ]);

    if (emailExists.some(user => user !== null)) {
      return res.status(400).json({ error: 'Cet email est déjà utilisé' });
    }

    let user;
    const userDataWithRole = {
      ...userData,
      email,
      password,
      roles: [role]
    };

    switch (role) {
      case 'ROLE_CLIENT':
        user = new User(userDataWithRole);
        break;
      case 'ROLE_PECHEUR':
        user = new Pecheur(userDataWithRole);
        break;
      case 'ROLE_VETERINAIRE':
        user = new Vitirinaire(userDataWithRole);
        break;
      case 'ROLE_MARYEUR':
        user = new Maryeur(userDataWithRole);
        break;
      default:
        return res.status(400).json({ error: 'Rôle invalide' });
    }

    await user.save();
    const token = generateToken(user);

    res.status(201).json({
      user: {
        _id: user._id,
        email: user.email,
        roles: user.roles,
        nom: user.nom,
        prenom: user.prenom
      },
      token
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

// Connexion
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Chercher l'utilisateur dans toutes les collections
    const userPromises = [
      User.findOne({ email }),
      Pecheur.findOne({ email }),
      Vitirinaire.findOne({ email }),
      Maryeur.findOne({ email })
    ];

    const users = await Promise.all(userPromises);
    const user = users.find(u => u !== null);

    if (!user) {
      return res.status(401).json({ error: 'Email ou mot de passe incorrect' });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ error: 'Email ou mot de passe incorrect' });
    }

    const token = generateToken(user);

    res.json({
      user: {
        _id: user._id,
        email: user.email,
        roles: user.roles,
        nom: user.nom,
        prenom: user.prenom
      },
      token
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

// Obtenir le profil de l'utilisateur connecté
const getProfile = async (req, res) => {
  try {
    const user = req.user;
    res.json({
      _id: user._id,
      email: user.email,
      roles: user.roles,
      nom: user.nom,
      prenom: user.prenom,
      telephone: user.telephone,
      // Ajouter d'autres champs selon le type d'utilisateur
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

module.exports = {
  register,
  login,
  getProfile
};