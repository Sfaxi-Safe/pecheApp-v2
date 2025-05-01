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
const register = async (req, res, next) => {
  try {
    const { email, password, role, ...userData } = req.body;

    // Validation des données
    if (!email || !password || !role) {
      throw new BadRequestError('Email, mot de passe et rôle sont requis');
    }

    if (!['ROLE_CLIENT', 'ROLE_PECHEUR', 'ROLE_VETERINAIRE', 'ROLE_MARYEUR', 'ROLE_ADMIN'].includes(role)) {
      throw new BadRequestError('Rôle invalide');
    }

    // Vérifier si l'email existe déjà
    const emailExists = await Promise.all([
      User.findOne({ email }),
      Pecheur.findOne({ email }),
      Veterinaire.findOne({ email }),
      Maryeur.findOne({ email })
    ]);

    if (emailExists.some(user => user !== null)) {
      throw new BadRequestError('Cet email est déjà utilisé');
    }

    // Validation des champs obligatoires selon le rôle
    if ((role === 'ROLE_PECHEUR' || role === 'ROLE_VETERINAIRE' || role === 'ROLE_MARYEUR') &&
        (!userData.nom || !userData.prenom || !userData.telephone)) {
      throw new BadRequestError('Nom, prénom et téléphone sont requis');
    }

    // Validation des champs spécifiques pour les pêcheurs
    if (role === 'ROLE_PECHEUR' && (!userData.matricule || !userData.bateau || !userData.port)) {
      throw new BadRequestError('Matricule, bateau et port sont requis pour les pêcheurs');
    }

    // Validation des champs spécifiques pour les vétérinaires et maryeurs
    if ((role === 'ROLE_VETERINAIRE' || role === 'ROLE_MARYEUR') && (!userData.matricule || !userData.port)) {
      throw new BadRequestError(`Matricule et port sont requis pour les ${role === 'ROLE_VETERINAIRE' ? 'vétérinaires' : 'maryeurs'}`);
    }

    let user;
    const userDataWithRole = {
      ...userData,
      email,
      password,
      roles: role, // Changé de [role] à role pour correspondre au frontend
      isValidated: role === 'ROLE_ADMIN' // Les admins sont automatiquement validés
    };

    // Journaliser l'action
    console.log(`[${new Date().toISOString()}] INFO [AUTH] Tentative d'inscription: ${email} (${role})`);

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
      case 'ROLE_ADMIN':
        user = new User(userDataWithRole);
        break;
      default:
        throw new BadRequestError('Rôle invalide');
    }

    await user.save();
    const token = generateToken(user);

    // Journaliser le succès
    console.log(`[${new Date().toISOString()}] INFO [AUTH] Inscription réussie: ${email} (${role})`);

    res.status(201).json({
      success: true,
      message: 'Inscription réussie',
      user: {
        _id: user._id,
        email: user.email,
        roles: user.roles,
        nom: user.nom,
        prenom: user.prenom,
        telephone: user.telephone,
        photo: user.photo,
        isValidated: user.isValidated
      },
      token
    });
  } catch (error) {
    next(error);
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

    // Journaliser la tentative de connexion
    console.log(`[${new Date().toISOString()}] INFO [AUTH] Tentative de connexion: ${email}`);

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
      // Journaliser l'échec
      console.log(`[${new Date().toISOString()}] WARN [AUTH] Échec de connexion (utilisateur non trouvé): ${email}`);
      throw new BadRequestError('Email ou mot de passe incorrect');
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      // Journaliser l'échec
      console.log(`[${new Date().toISOString()}] WARN [AUTH] Échec de connexion (mot de passe incorrect): ${email}`);
      throw new BadRequestError('Email ou mot de passe incorrect');
    }

    if (!user.isValidated && !user.isValid) {
      // Journaliser l'échec
      console.log(`[${new Date().toISOString()}] WARN [AUTH] Échec de connexion (compte non validé): ${email}`);
      throw new ForbiddenError('Votre compte est en attente de validation par un administrateur');
    }

    if (user.isBlocked) {
      // Journaliser l'échec
      console.log(`[${new Date().toISOString()}] WARN [AUTH] Échec de connexion (compte bloqué): ${email}`);
      throw new ForbiddenError('Votre compte a été bloqué. Veuillez contacter un administrateur');
    }

    const token = generateToken(user);

    // Journaliser la connexion réussie
    console.log(`[${new Date().toISOString()}] INFO [AUTH] Connexion réussie: ${email}`);

    // Déterminer le type d'utilisateur
    let userType = 'client';
    if (user.roles && typeof user.roles === 'string') {
      if (user.roles.includes('ROLE_PECHEUR')) userType = 'pecheur';
      else if (user.roles.includes('ROLE_VETERINAIRE')) userType = 'veterinaire';
      else if (user.roles.includes('ROLE_MARYEUR')) userType = 'maryeur';
      else if (user.roles.includes('ROLE_ADMIN')) userType = 'admin';
    }

    res.json({
      success: true,
      message: 'Connexion réussie',
      user: {
        _id: user._id,
        email: user.email,
        roles: user.roles,
        nom: user.nom,
        prenom: user.prenom,
        telephone: user.telephone,
        photo: user.photo,
        userType: userType,
        isValidated: user.isValidated || user.isValid || false
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

    // Déterminer le type d'utilisateur
    let userType = 'client';
    if (user.roles && typeof user.roles === 'string') {
      if (user.roles.includes('ROLE_PECHEUR')) userType = 'pecheur';
      else if (user.roles.includes('ROLE_VETERINAIRE')) userType = 'veterinaire';
      else if (user.roles.includes('ROLE_MARYEUR')) userType = 'maryeur';
      else if (user.roles.includes('ROLE_ADMIN')) userType = 'admin';
    }

    // Construire l'objet de réponse de base
    const userProfile = {
      _id: user._id,
      email: user.email,
      roles: user.roles,
      nom: user.nom,
      prenom: user.prenom,
      telephone: user.telephone,
      photo: user.photo,
      userType: userType,
      isValidated: user.isValidated || user.isValid || false
    };

    // Ajouter des champs spécifiques selon le type d'utilisateur
    if (userType === 'pecheur') {
      userProfile.bateau = user.bateau;
      userProfile.port = user.port;
      userProfile.matricule = user.matricule;
      userProfile.capacite = user.capacite;
    } else if (userType === 'veterinaire') {
      userProfile.specialite = user.specialite;
      userProfile.certification = user.certification;
      userProfile.matricule = user.matricule;
      userProfile.port = user.port;
    } else if (userType === 'maryeur') {
      userProfile.matricule = user.matricule;
      userProfile.port = user.port;
      userProfile.signature = user.signature;
    }

    res.json({
      success: true,
      user: userProfile
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