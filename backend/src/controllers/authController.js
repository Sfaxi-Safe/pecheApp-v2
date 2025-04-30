const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Pecheur = require('../models/Pecheur');
const Veterinaire = require('../models/Veterinaire');
const Maryeur = require('../models/Maryeur');
const {
  NotFoundError,
  ForbiddenError,
  BadRequestError,
  CustomValidationError
} = require('../middleware/errorHandler');

// Générer le token JWT
const generateToken = (user) => {
  return jwt.sign(
    { _id: user._id, roles: user.roles, isValidated: user.isValidated },
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
      Veterinaire.findOne({ email }),
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
      roles: [role],
      isValidated: role === 'ROLE_ADMIN' // Les admins sont automatiquement validés
    };

    switch (role) {
      case 'ROLE_CLIENT':
        user = new User(userDataWithRole);
        break;
      case 'ROLE_PECHEUR':
        user = new Pecheur(userDataWithRole);
        break;
      case 'ROLE_VETERINAIRE':
        user = new Veterinaire(userDataWithRole);
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
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // Valider les données d'entrée
    if (!email || !password) {
      throw new BadRequestError('Email et mot de passe requis');
    }

    // Chercher l'utilisateur dans toutes les collections
    const userPromises = [
      User.findOne({ email }),
      Pecheur.findOne({ email }),
      Veterinaire.findOne({ email }),
      Maryeur.findOne({ email })
    ];

    const users = await Promise.all(userPromises);
    const user = users.find(u => u !== null);

    if (!user) {
      throw new BadRequestError('Email ou mot de passe incorrect');
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      throw new BadRequestError('Email ou mot de passe incorrect');
    }

    if (!user.isValidated) {
      throw new ForbiddenError('Votre compte est en attente de validation par un administrateur');
    }

    if (user.isBlocked) {
      throw new ForbiddenError('Votre compte a été bloqué. Veuillez contacter un administrateur');
    }

    const token = generateToken(user);

    // Journaliser la connexion réussie
    console.log(`[${new Date().toISOString()}] INFO [AUTH] Connexion réussie: ${email}`);

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
    next(error);
  }
};

// Obtenir le profil de l'utilisateur connecté
const getProfile = async (req, res, next) => {
  try {
    const user = req.user;

    if (!user) {
      throw new NotFoundError('Utilisateur non trouvé');
    }

    res.json({
      user: {
        _id: user._id,
        email: user.email,
        roles: user.roles,
        nom: user.nom,
        prenom: user.prenom,
        telephone: user.telephone,
        photo: user.photo,
        // Ajouter d'autres champs selon le type d'utilisateur
      }
    });
  } catch (error) {
    next(error);
  }
};

// Validation d'un compte utilisateur par un admin
const validateUser = async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }

    user.isValidated = true;
    await user.save();

    res.json({ message: 'Compte utilisateur validé avec succès' });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

// Bloquer/débloquer un compte utilisateur
const toggleUserBlock = async (req, res) => {
  try {
    const { userId } = req.params;
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({ error: 'Utilisateur non trouvé' });
    }

    user.isBlocked = !user.isBlocked;
    await user.save();

    res.json({
      message: user.isBlocked ? 'Utilisateur bloqué' : 'Utilisateur débloqué'
    });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

// Obtenir la liste des utilisateurs en attente de validation
const getPendingUsers = async (req, res) => {
  try {
    const pendingUsers = await User.find({ isValidated: false }).select('-password');
    res.json(pendingUsers);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

module.exports = {
  register,
  login,
  getProfile,
  validateUser,
  toggleUserBlock,
  getPendingUsers
};