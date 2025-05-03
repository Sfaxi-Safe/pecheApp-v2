const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');
const Admin = require('../models/Admin');
const Client = require('../models/Client');
const Pecheur = require('../models/Pecheur');
const Veterinaire = require('../models/Veterinaire');
const Maryeur = require('../models/Maryeur');
const {
  NotFoundError,
  ForbiddenError,
  BadRequestError
} = require('../middleware/errorHandler');

/**
 * Génère un token JWT pour l'authentification
 * @param {Object} user - L'utilisateur pour lequel générer le token
 * @returns {String} Le token JWT généré
 */
const generateToken = (user) => {
  // Utiliser l'ID personnalisé s'il existe, sinon utiliser l'ID MongoDB
  const userId = user.id || user._id.toString();

  return jwt.sign(
    {
      _id: userId,
      roles: user.roles,
      isValidated: user.isValidated || user.isValid || false
    },
    process.env.JWT_SECRET,
    { expiresIn: '24h' }
  );
};

/**
 * Contrôleur pour l'inscription d'un nouvel utilisateur
 *
 * Cette fonction effectue les opérations suivantes :
 * 1. Valide les données d'entrée (email, mot de passe, rôle)
 * 2. Vérifie si l'email existe déjà dans la base de données
 * 3. Crée un nouvel utilisateur selon le rôle spécifié
 * 4. Génère un token JWT pour l'authentification
 * 5. Renvoie les informations de l'utilisateur et le token
 *
 * @param {Object} req - L'objet request Express
 * @param {Object} res - L'objet response Express
 * @param {Function} next - La fonction middleware suivante
 */
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
    let emailExists = false;

    // Vérifier dans chaque collection
    if (await Client.findOne({ email })) emailExists = true;
    if (!emailExists && await Pecheur.findOne({ email })) emailExists = true;
    if (!emailExists && await Veterinaire.findOne({ email })) emailExists = true;
    if (!emailExists && await Maryeur.findOne({ email })) emailExists = true;
    if (!emailExists && await Admin.findOne({ email })) emailExists = true;

    if (emailExists) {
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
        user = new Client(userDataWithRole);
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
        user = new Admin(userDataWithRole);
        break;
      default:
        throw new BadRequestError('Rôle invalide');
    }

    await user.save();
    const token = generateToken(user);

    // Journaliser le succès
    console.log(`[${new Date().toISOString()}] INFO [AUTH] Inscription réussie: ${email} (${role})`);

    // Déterminer le type d'utilisateur
    let userType = 'client';
    if (role === 'ROLE_PECHEUR') userType = 'pecheur';
    else if (role === 'ROLE_VETERINAIRE') userType = 'veterinaire';
    else if (role === 'ROLE_MARYEUR') userType = 'maryeur';
    else if (role === 'ROLE_ADMIN') userType = 'admin';

    // Utiliser l'ID personnalisé s'il existe, sinon utiliser l'ID MongoDB
    const userId = user.id || user._id.toString();

    // Construire l'objet utilisateur avec tous les champs nécessaires
    const userResponse = {
      id: userId,
      email: user.email,
      roles: user.roles,
      nom: user.nom,
      prenom: user.prenom,
      telephone: user.telephone,
      photo: user.photo,
      userType: userType,
      isValidated: user.isValidated || user.isValid || false,
      isBlocked: user.isBlocked || false
    };

    // Ajouter les champs spécifiques selon le type d'utilisateur
    if (userType === 'pecheur') {
      userResponse.cin = user.cin;
      userResponse.matricule = user.matricule;
      userResponse.bateau = user.bateau;
      userResponse.pays = user.pays;
      userResponse.port = user.port;
    } else if (userType === 'maryeur') {
      userResponse.cin = user.cin;
      userResponse.matricule = user.matricule;
      userResponse.port = user.port;
      userResponse.pays = user.pays;
      userResponse.signature = user.signature;
    } else if (userType === 'veterinaire') {
      userResponse.cin = user.cin;
      userResponse.matricule = user.matricule;
      userResponse.specialite = user.specialite;
      userResponse.certification = user.certification;
    } else if (userType === 'client') {
      userResponse.service = user.service;
      userResponse.fonction = user.fonction;
    }

    res.status(201).json({
      success: true,
      message: 'Inscription réussie',
      user: userResponse,
      token
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Contrôleur pour la connexion d'un utilisateur
 *
 * Cette fonction effectue les opérations suivantes :
 * 1. Valide les données d'entrée (email, mot de passe)
 * 2. Recherche l'utilisateur dans toutes les collections
 * 3. Vérifie le mot de passe
 * 4. Vérifie si le compte est validé et non bloqué
 * 5. Génère un token JWT pour l'authentification
 * 6. Renvoie les informations de l'utilisateur et le token
 *
 * @param {Object} req - L'objet request Express
 * @param {Object} res - L'objet response Express
 * @param {Function} next - La fonction middleware suivante
 */
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
    let user = null;

    // Essayer de trouver l'utilisateur dans les collections spécifiques
    user = await Client.findOne({ email });
    if (!user) user = await Pecheur.findOne({ email });
    if (!user) user = await Veterinaire.findOne({ email });
    if (!user) user = await Maryeur.findOne({ email });
    if (!user) user = await Admin.findOne({ email });

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

    // Préparer les données utilisateur pour le frontend
    // Utiliser l'ID personnalisé s'il existe, sinon utiliser l'ID MongoDB
    const userId = user.id || user._id.toString();

    // Construire l'objet utilisateur avec tous les champs nécessaires
    const userData = {
      id: userId,
      email: user.email,
      roles: user.roles,
      nom: user.nom,
      prenom: user.prenom,
      telephone: user.telephone,
      photo: user.photo,
      userType: userType,
      isValidated: user.isValidated || user.isValid || false,
      isBlocked: user.isBlocked || false
    };

    // Ajouter les champs spécifiques selon le type d'utilisateur
    if (userType === 'pecheur') {
      userData.cin = user.cin;
      userData.matricule = user.matricule;
      userData.bateau = user.bateau;
      userData.pays = user.pays;
      userData.port = user.port;
    } else if (userType === 'maryeur') {
      userData.cin = user.cin;
      userData.matricule = user.matricule;
      userData.port = user.port;
      userData.pays = user.pays;
      userData.signature = user.signature;
    } else if (userType === 'veterinaire') {
      userData.cin = user.cin;
      userData.matricule = user.matricule;
      userData.specialite = user.specialite;
      userData.certification = user.certification;
    } else if (userType === 'client') {
      userData.service = user.service;
      userData.fonction = user.fonction;
    }

    res.json({
      success: true,
      message: 'Connexion réussie',
      user: userData,
      token
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Contrôleur pour obtenir le profil de l'utilisateur connecté
 *
 * Cette fonction effectue les opérations suivantes :
 * 1. Récupère l'utilisateur depuis l'objet request (ajouté par le middleware auth)
 * 2. Détermine le type d'utilisateur
 * 3. Construit un objet de réponse avec les informations de l'utilisateur
 * 4. Ajoute des champs spécifiques selon le type d'utilisateur
 * 5. Renvoie les informations du profil
 *
 * @param {Object} req - L'objet request Express
 * @param {Object} res - L'objet response Express
 * @param {Function} next - La fonction middleware suivante
 */
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

    // Utiliser l'ID personnalisé s'il existe, sinon utiliser l'ID MongoDB
    const userId = user.id || user._id.toString();

    // Construire l'objet de réponse de base
    const userProfile = {
      id: userId,
      email: user.email,
      roles: user.roles,
      nom: user.nom,
      prenom: user.prenom,
      telephone: user.telephone,
      photo: user.photo,
      userType: userType,
      isValidated: user.isValidated || user.isValid || false,
      isBlocked: user.isBlocked || false
    };

    // Ajouter des champs spécifiques selon le type d'utilisateur
    if (userType === 'pecheur') {
      userProfile.cin = user.cin;
      userProfile.matricule = user.matricule;
      userProfile.bateau = user.bateau;
      userProfile.pays = user.pays;
      userProfile.port = user.port;
      userProfile.capacite = user.capacite;
    } else if (userType === 'veterinaire') {
      userProfile.cin = user.cin;
      userProfile.specialite = user.specialite;
      userProfile.certification = user.certification;
      userProfile.matricule = user.matricule;
      userProfile.port = user.port;
    } else if (userType === 'maryeur') {
      userProfile.cin = user.cin;
      userProfile.matricule = user.matricule;
      userProfile.port = user.port;
      userProfile.pays = user.pays;
      userProfile.signature = user.signature;
    } else if (userType === 'client') {
      userProfile.service = user.service;
      userProfile.fonction = user.fonction;
    }

    res.json({
      success: true,
      user: userProfile
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Contrôleur pour valider un compte utilisateur par un administrateur
 *
 * Cette fonction effectue les opérations suivantes :
 * 1. Récupère l'ID de l'utilisateur à valider
 * 2. Recherche l'utilisateur dans la base de données
 * 3. Définit le champ isValidated à true
 * 4. Sauvegarde les modifications
 * 5. Renvoie un message de succès
 *
 * @param {Object} req - L'objet request Express
 * @param {Object} res - L'objet response Express
 */
const validateUser = async (req, res, next) => {
  try {
    const { userId } = req.params;

    // Chercher l'utilisateur dans toutes les collections
    let user = null;

    // Essayer de trouver l'utilisateur dans les collections spécifiques
    if (mongoose.Types.ObjectId.isValid(userId)) {
      user = await Client.findById(userId);
      if (!user) user = await Pecheur.findById(userId);
      if (!user) user = await Veterinaire.findById(userId);
      if (!user) user = await Maryeur.findById(userId);
      if (!user) user = await Admin.findById(userId);
    }

    // Si non trouvé par ID, essayer par ID personnalisé
    if (!user) {
      user = await Client.findOne({ id: userId });
      if (!user) user = await Pecheur.findOne({ id: userId });
      if (!user) user = await Veterinaire.findOne({ id: userId });
      if (!user) user = await Maryeur.findOne({ id: userId });
      if (!user) user = await Admin.findOne({ id: userId });
    }

    if (!user) {
      throw new NotFoundError('Utilisateur non trouvé');
    }

    user.isValidated = true;
    await user.save();

    res.success(null, 'Compte utilisateur validé avec succès');
  } catch (error) {
    next(error);
  }
};

/**
 * Contrôleur pour bloquer ou débloquer un compte utilisateur
 *
 * Cette fonction effectue les opérations suivantes :
 * 1. Récupère l'ID de l'utilisateur à bloquer/débloquer
 * 2. Recherche l'utilisateur dans la base de données
 * 3. Inverse la valeur du champ isBlocked
 * 4. Sauvegarde les modifications
 * 5. Renvoie un message de succès
 *
 * @param {Object} req - L'objet request Express
 * @param {Object} res - L'objet response Express
 */
const toggleUserBlock = async (req, res, next) => {
  try {
    const { userId } = req.params;

    // Chercher l'utilisateur dans toutes les collections
    let user = null;

    // Essayer de trouver l'utilisateur dans les collections spécifiques
    if (mongoose.Types.ObjectId.isValid(userId)) {
      user = await Client.findById(userId);
      if (!user) user = await Pecheur.findById(userId);
      if (!user) user = await Veterinaire.findById(userId);
      if (!user) user = await Maryeur.findById(userId);
      if (!user) user = await Admin.findById(userId);
    }

    // Si non trouvé par ID, essayer par ID personnalisé
    if (!user) {
      user = await Client.findOne({ id: userId });
      if (!user) user = await Pecheur.findOne({ id: userId });
      if (!user) user = await Veterinaire.findOne({ id: userId });
      if (!user) user = await Maryeur.findOne({ id: userId });
      if (!user) user = await Admin.findOne({ id: userId });
    }

    if (!user) {
      throw new NotFoundError('Utilisateur non trouvé');
    }

    user.isBlocked = !user.isBlocked;
    await user.save();

    res.success(null, user.isBlocked ? 'Utilisateur bloqué' : 'Utilisateur débloqué');
  } catch (error) {
    next(error);
  }
};

/**
 * Contrôleur pour obtenir la liste des utilisateurs en attente de validation
 *
 * Cette fonction effectue les opérations suivantes :
 * 1. Recherche tous les utilisateurs dont le champ isValidated est false
 * 2. Exclut le mot de passe des résultats
 * 3. Renvoie la liste des utilisateurs en attente
 *
 * @param {Object} _ - L'objet request Express (non utilisé)
 * @param {Object} res - L'objet response Express
 */
const getPendingUsers = async (_, res, next) => {
  try {
    // Récupérer les utilisateurs en attente de validation dans toutes les collections
    const pendingClients = await Client.find({ isValidated: false }).select('-password');
    const pendingPecheurs = await Pecheur.find({ isValidated: false }).select('-password');
    const pendingVeterinaires = await Veterinaire.find({ isValidated: false }).select('-password');
    const pendingMaryeurs = await Maryeur.find({ isValidated: false }).select('-password');

    // Combiner tous les utilisateurs en attente
    const pendingUsers = [
      ...pendingClients,
      ...pendingPecheurs,
      ...pendingVeterinaires,
      ...pendingMaryeurs
    ];

    res.success(pendingUsers, 'Liste des utilisateurs en attente récupérée avec succès');
  } catch (error) {
    next(error);
  }
};

/**
 * Contrôleur pour demander une réinitialisation de mot de passe
 *
 * Cette fonction effectue les opérations suivantes :
 * 1. Récupère l'email de l'utilisateur
 * 2. Vérifie si l'utilisateur existe
 * 3. Simule l'envoi d'un email de réinitialisation
 * 4. Renvoie un message de succès
 *
 * @param {Object} req - L'objet request Express
 * @param {Object} res - L'objet response Express
 * @param {Function} next - La fonction middleware suivante
 */
const requestPasswordReset = async (req, res, next) => {
  try {
    const { email } = req.body;

    if (!email) {
      throw new BadRequestError('Email requis');
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
      // Pour des raisons de sécurité, ne pas indiquer si l'email existe ou non
      return res.success(null, 'Si votre email est enregistré, vous recevrez un lien de réinitialisation');
    }

    // Dans une application réelle, générer un token et envoyer un email
    // Pour ce projet, on simule simplement l'envoi d'un email
    console.log(`[${new Date().toISOString()}] INFO [AUTH] Demande de réinitialisation de mot de passe: ${email}`);

    res.success(null, 'Si votre email est enregistré, vous recevrez un lien de réinitialisation');
  } catch (error) {
    next(error);
  }
};

/**
 * Contrôleur pour réinitialiser le mot de passe
 *
 * Cette fonction effectue les opérations suivantes :
 * 1. Récupère l'email et le nouveau mot de passe
 * 2. Vérifie si l'utilisateur existe
 * 3. Met à jour le mot de passe
 * 4. Renvoie un message de succès
 *
 * @param {Object} req - L'objet request Express
 * @param {Object} res - L'objet response Express
 * @param {Function} next - La fonction middleware suivante
 */
const resetPassword = async (req, res, next) => {
  try {
    const { email, newPassword } = req.body;

    if (!email || !newPassword) {
      throw new BadRequestError('Email et nouveau mot de passe requis');
    }

    if (newPassword.length < 6) {
      throw new BadRequestError('Le mot de passe doit contenir au moins 6 caractères');
    }

    // Chercher l'utilisateur dans toutes les collections
    let user = null;

    // Essayer de trouver l'utilisateur dans les collections spécifiques
    user = await Client.findOne({ email });
    if (!user) user = await Pecheur.findOne({ email });
    if (!user) user = await Veterinaire.findOne({ email });
    if (!user) user = await Maryeur.findOne({ email });
    if (!user) user = await Admin.findOne({ email });

    if (!user) {
      // Pour des raisons de sécurité, ne pas indiquer si l'email existe ou non
      return res.success(null, 'Instructions de réinitialisation envoyées si l\'email existe');
    }

    // Mettre à jour le mot de passe
    user.password = newPassword;
    await user.save();

    console.log(`[${new Date().toISOString()}] INFO [AUTH] Mot de passe réinitialisé: ${email}`);

    res.success(null, 'Mot de passe réinitialisé avec succès');
  } catch (error) {
    next(error);
  }
};

/**
 * Contrôleur pour changer le mot de passe de l'utilisateur connecté
 *
 * Cette fonction effectue les opérations suivantes :
 * 1. Vérifie que l'utilisateur est connecté
 * 2. Vérifie que l'ancien mot de passe est correct
 * 3. Met à jour le mot de passe
 * 4. Renvoie un message de succès
 *
 * @param {Object} req - L'objet request Express
 * @param {Object} res - L'objet response Express
 * @param {Function} next - La fonction middleware suivante
 */
const changePassword = async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;
    const userId = req.user._id;

    if (!currentPassword || !newPassword) {
      throw new BadRequestError('Mot de passe actuel et nouveau mot de passe requis');
    }

    if (newPassword.length < 6) {
      throw new BadRequestError('Le nouveau mot de passe doit contenir au moins 6 caractères');
    }

    // Récupérer l'utilisateur depuis la base de données
    let user = null;
    const userType = req.user.getUserType();

    // Trouver l'utilisateur dans la collection appropriée
    switch (userType) {
      case 'client':
        user = await Client.findById(userId);
        break;
      case 'pecheur':
        user = await Pecheur.findById(userId);
        break;
      case 'veterinaire':
        user = await Veterinaire.findById(userId);
        break;
      case 'maryeur':
        user = await Maryeur.findById(userId);
        break;
      case 'admin':
        user = await Admin.findById(userId);
        break;
      default:
        throw new BadRequestError('Type d\'utilisateur non reconnu');
    }

    if (!user) {
      throw new NotFoundError('Utilisateur non trouvé');
    }

    // Vérifier que l'ancien mot de passe est correct
    const isMatch = await user.comparePassword(currentPassword);
    if (!isMatch) {
      throw new BadRequestError('Mot de passe actuel incorrect');
    }

    // Mettre à jour le mot de passe
    user.password = newPassword;
    await user.save();

    console.log(`[${new Date().toISOString()}] INFO [AUTH] Mot de passe changé pour l'utilisateur: ${user.email}`);

    res.success(null, 'Mot de passe mis à jour avec succès');
  } catch (error) {
    next(error);
  }
};

module.exports = {
  register,
  login,
  getProfile,
  validateUser,
  toggleUserBlock,
  getPendingUsers,
  requestPasswordReset,
  resetPassword,
  changePassword
};