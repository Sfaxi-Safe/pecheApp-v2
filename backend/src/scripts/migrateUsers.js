/**
 * Script de migration des utilisateurs
 * Ce script transfère les utilisateurs de la collection 'users' vers les collections spécifiques
 * ('clients', 'veterinaires') en fonction de leur rôle.
 */

require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const Client = require('../models/Client');
const Veterinaire = require('../models/Veterinaire');

// Connexion à MongoDB
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connexion à MongoDB établie');
  } catch (error) {
    console.error('Erreur de connexion à MongoDB:', error.message);
    process.exit(1);
  }
};

// Migration des utilisateurs
const migrateUsers = async () => {
  try {
    console.log('Début de la migration des utilisateurs...');

    // Récupérer tous les utilisateurs de la collection 'users'
    const users = await User.find({});
    console.log(`${users.length} utilisateurs trouvés dans la collection 'users'`);

    // Compteurs pour les statistiques
    let clientCount = 0;
    let veterinaireCount = 0;
    let adminCount = 0;
    let errorCount = 0;

    // Traiter chaque utilisateur
    for (const user of users) {
      try {
        // Déterminer le type d'utilisateur
        let userType = 'client';
        if (user.roles && typeof user.roles === 'string') {
          if (user.roles.includes('ROLE_VETERINAIRE')) userType = 'veterinaire';
          else if (user.roles.includes('ROLE_ADMIN')) userType = 'admin';
        }

        // Créer un nouvel objet avec les données de l'utilisateur
        const userData = {
          id: user.id || user._id.toString(),
          email: user.email,
          password: user.password, // Déjà haché
          roles: user.roles,
          nom: user.nom,
          prenom: user.prenom,
          telephone: user.telephone,
          isValidated: user.isValidated || false,
          isBlocked: user.isBlocked || false,
          photo: user.photo
        };

        // Migrer l'utilisateur vers la collection appropriée
        if (userType === 'client') {
          // Ajouter les champs spécifiques aux clients
          userData.service = user.service;
          userData.fonction = user.fonction;

          // Vérifier si le client existe déjà
          const existingClient = await Client.findOne({ email: user.email });
          if (!existingClient) {
            // Créer un nouveau client
            const client = new Client(userData);
            await client.save();
            clientCount++;
            console.log(`Client migré: ${user.email}`);
          } else {
            console.log(`Client déjà existant: ${user.email}`);
          }
        } else if (userType === 'veterinaire') {
          // Ajouter les champs spécifiques aux vétérinaires
          userData.specialite = user.specialite;
          userData.certification = user.certification;
          userData.matricule = user.matricule;
          userData.cin = user.cin;
          userData.port = user.port;
          userData.pays = user.pays;

          // Vérifier si le vétérinaire existe déjà
          const existingVeterinaire = await Veterinaire.findOne({ email: user.email });
          if (!existingVeterinaire) {
            // Créer un nouveau vétérinaire
            const veterinaire = new Veterinaire(userData);
            await veterinaire.save();
            veterinaireCount++;
            console.log(`Vétérinaire migré: ${user.email}`);
          } else {
            console.log(`Vétérinaire déjà existant: ${user.email}`);
          }
        } else if (userType === 'admin') {
          // Garder les administrateurs dans la collection 'users'
          adminCount++;
          console.log(`Administrateur conservé: ${user.email}`);
        }
      } catch (error) {
        console.error(`Erreur lors de la migration de l'utilisateur ${user.email}:`, error.message);
        errorCount++;
      }
    }

    // Afficher les statistiques
    console.log('\nMigration terminée avec succès!');
    console.log(`Clients migrés: ${clientCount}`);
    console.log(`Vétérinaires migrés: ${veterinaireCount}`);
    console.log(`Administrateurs conservés: ${adminCount}`);
    console.log(`Erreurs: ${errorCount}`);

  } catch (error) {
    console.error('Erreur lors de la migration:', error.message);
  } finally {
    // Fermer la connexion à MongoDB
    mongoose.connection.close();
    console.log('Connexion à MongoDB fermée');
  }
};

// Exécuter la migration
connectDB()
  .then(() => migrateUsers())
  .catch(error => {
    console.error('Erreur:', error.message);
    process.exit(1);
  });
