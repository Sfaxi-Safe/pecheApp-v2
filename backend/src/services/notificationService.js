/**
 * Service de gestion des notifications
 * Fournit des méthodes pour créer et gérer les notifications
 */
const Notification = require('../models/Notification');

/**
 * Crée une notification pour un pêcheur
 * @param {string} pecheurId - ID du pêcheur
 * @param {string} titre - Titre de la notification
 * @param {string} contenu - Contenu de la notification
 * @param {string} type - Type de notification (info, success, warning, error)
 * @param {Object} options - Options supplémentaires
 * @returns {Promise<Object>} La notification créée
 */
const notifierPecheur = async (pecheurId, titre, contenu, type = 'info', options = {}) => {
  const notification = new Notification({
    destinataire: pecheurId,
    destinataireModel: 'Pecheur',
    titre,
    contenu,
    type,
    reference: options.reference,
    referenceModel: options.referenceModel,
    urlAction: options.urlAction
  });

  return await notification.save();
};

/**
 * Crée une notification pour un vétérinaire
 * @param {string} veterinaireId - ID du vétérinaire
 * @param {string} titre - Titre de la notification
 * @param {string} contenu - Contenu de la notification
 * @param {string} type - Type de notification (info, success, warning, error)
 * @param {Object} options - Options supplémentaires
 * @returns {Promise<Object>} La notification créée
 */
const notifierVeterinaire = async (veterinaireId, titre, contenu, type = 'info', options = {}) => {
  const notification = new Notification({
    destinataire: veterinaireId,
    destinataireModel: 'Veterinaire',
    titre,
    contenu,
    type,
    reference: options.reference,
    referenceModel: options.referenceModel,
    urlAction: options.urlAction
  });

  return await notification.save();
};

/**
 * Crée une notification pour un mareyeur
 * @param {string} maryeurId - ID du mareyeur
 * @param {string} titre - Titre de la notification
 * @param {string} contenu - Contenu de la notification
 * @param {string} type - Type de notification (info, success, warning, error)
 * @param {Object} options - Options supplémentaires
 * @returns {Promise<Object>} La notification créée
 */
const notifierMaryeur = async (maryeurId, titre, contenu, type = 'info', options = {}) => {
  const notification = new Notification({
    destinataire: maryeurId,
    destinataireModel: 'Maryeur',
    titre,
    contenu,
    type,
    reference: options.reference,
    referenceModel: options.referenceModel,
    urlAction: options.urlAction
  });

  return await notification.save();
};

/**
 * Crée une notification pour un client
 * @param {string} clientId - ID du client
 * @param {string} titre - Titre de la notification
 * @param {string} contenu - Contenu de la notification
 * @param {string} type - Type de notification (info, success, warning, error)
 * @param {Object} options - Options supplémentaires
 * @returns {Promise<Object>} La notification créée
 */
const notifierClient = async (clientId, titre, contenu, type = 'info', options = {}) => {
  const notification = new Notification({
    destinataire: clientId,
    destinataireModel: 'Client',
    titre,
    contenu,
    type,
    reference: options.reference,
    referenceModel: options.referenceModel,
    urlAction: options.urlAction
  });

  return await notification.save();
};

/**
 * Notifie tous les vétérinaires
 * @param {string} titre - Titre de la notification
 * @param {string} contenu - Contenu de la notification
 * @param {string} type - Type de notification (info, success, warning, error)
 * @param {Object} options - Options supplémentaires
 * @returns {Promise<Array>} Les notifications créées
 */
const notifierTousVeterinaires = async (titre, contenu, type = 'info', options = {}) => {
  const Veterinaire = require('../models/Veterinaire');
  const veterinaires = await Veterinaire.find();

  const notifications = [];
  for (const veterinaire of veterinaires) {
    const notification = await notifierVeterinaire(
      veterinaire._id,
      titre,
      contenu,
      type,
      options
    );
    notifications.push(notification);
  }

  return notifications;
};

/**
 * Crée une notification pour un administrateur
 * @param {string} adminId - ID de l'administrateur
 * @param {string} titre - Titre de la notification
 * @param {string} contenu - Contenu de la notification
 * @param {string} type - Type de notification (info, success, warning, error)
 * @param {Object} options - Options supplémentaires
 * @returns {Promise<Object>} La notification créée
 */
const notifierAdmin = async (adminId, titre, contenu, type = 'info', options = {}) => {
  const notification = new Notification({
    destinataire: adminId,
    destinataireModel: 'Admin',
    titre,
    contenu,
    type,
    reference: options.reference,
    referenceModel: options.referenceModel,
    urlAction: options.urlAction
  });

  return await notification.save();
};

/**
 * Notifie tous les administrateurs
 * @param {string} titre - Titre de la notification
 * @param {string} contenu - Contenu de la notification
 * @param {string} type - Type de notification (info, success, warning, error)
 * @param {Object} options - Options supplémentaires
 * @returns {Promise<Array>} Les notifications créées
 */
const notifierTousAdmins = async (titre, contenu, type = 'info', options = {}) => {
  const Admin = require('../models/Admin');
  const admins = await Admin.find();

  const notifications = [];
  for (const admin of admins) {
    const notification = await notifierAdmin(
      admin._id,
      titre,
      contenu,
      type,
      options
    );
    notifications.push(notification);
  }

  return notifications;
};

/**
 * Notifie tous les utilisateurs d'un type spécifique
 * @param {string} userType - Type d'utilisateur (Pecheur, Veterinaire, Maryeur, Client, Admin)
 * @param {string} titre - Titre de la notification
 * @param {string} contenu - Contenu de la notification
 * @param {string} type - Type de notification (info, success, warning, error)
 * @param {Object} options - Options supplémentaires
 * @returns {Promise<Array>} Les notifications créées
 */
const notifierTousUtilisateurs = async (userType, titre, contenu, type = 'info', options = {}) => {
  let Model;
  let notifierFn;

  switch (userType) {
    case 'Pecheur':
      Model = require('../models/Pecheur');
      notifierFn = notifierPecheur;
      break;
    case 'Veterinaire':
      Model = require('../models/Veterinaire');
      notifierFn = notifierVeterinaire;
      break;
    case 'Maryeur':
      Model = require('../models/Maryeur');
      notifierFn = notifierMaryeur;
      break;
    case 'Client':
      Model = require('../models/Client');
      notifierFn = notifierClient;
      break;
    case 'Admin':
      Model = require('../models/Admin');
      notifierFn = notifierAdmin;
      break;
    default:
      throw new Error(`Type d'utilisateur non pris en charge: ${userType}`);
  }

  const users = await Model.find();

  const notifications = [];
  for (const user of users) {
    const notification = await notifierFn(
      user._id,
      titre,
      contenu,
      type,
      options
    );
    notifications.push(notification);
  }

  return notifications;
};

/**
 * Crée une notification pour un utilisateur spécifique
 * @param {string} userId - ID de l'utilisateur
 * @param {string} userType - Type d'utilisateur (Pecheur, Veterinaire, Maryeur, Client, Admin)
 * @param {string} titre - Titre de la notification
 * @param {string} contenu - Contenu de la notification
 * @param {string} type - Type de notification (info, success, warning, error)
 * @param {Object} options - Options supplémentaires
 * @returns {Promise<Object>} La notification créée
 */
const notifierUtilisateur = async (userId, userType, titre, contenu, type = 'info', options = {}) => {
  let notifierFn;

  switch (userType) {
    case 'Pecheur':
      notifierFn = notifierPecheur;
      break;
    case 'Veterinaire':
      notifierFn = notifierVeterinaire;
      break;
    case 'Maryeur':
      notifierFn = notifierMaryeur;
      break;
    case 'Client':
      notifierFn = notifierClient;
      break;
    case 'Admin':
      notifierFn = notifierAdmin;
      break;
    default:
      throw new Error(`Type d'utilisateur non pris en charge: ${userType}`);
  }

  return await notifierFn(userId, titre, contenu, type, options);
};

module.exports = {
  notifierPecheur,
  notifierVeterinaire,
  notifierMaryeur,
  notifierClient,
  notifierAdmin,
  notifierTousVeterinaires,
  notifierTousAdmins,
  notifierTousUtilisateurs,
  notifierUtilisateur
};
