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

module.exports = {
  notifierPecheur,
  notifierVeterinaire,
  notifierMaryeur,
  notifierClient,
  notifierTousVeterinaires
};
