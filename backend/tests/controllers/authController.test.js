/**
 * Tests unitaires pour le contrôleur d'authentification
 */
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { register, login, getProfile } = require('../../src/controllers/authController');
const User = require('../../src/models/User');
const Pecheur = require('../../src/models/Pecheur');

// Mock des dépendances
jest.mock('jsonwebtoken');
jest.mock('../../src/models/User');
jest.mock('../../src/models/Pecheur');
jest.mock('../../src/models/Veterinaire');
jest.mock('../../src/models/Maryeur');

let mongoServer;

// Configuration avant les tests
beforeAll(async () => {
  // Créer une instance MongoDB en mémoire pour les tests
  mongoServer = await MongoMemoryServer.create();
  const uri = mongoServer.getUri();
  await mongoose.connect(uri);
  
  // Mock de jwt.sign
  jwt.sign.mockReturnValue('fake-token');
});

// Nettoyage après les tests
afterAll(async () => {
  await mongoose.disconnect();
  await mongoServer.stop();
  jest.clearAllMocks();
});

// Nettoyage après chaque test
afterEach(() => {
  jest.clearAllMocks();
});

describe('Contrôleur d\'authentification', () => {
  describe('register', () => {
    it('devrait créer un nouvel utilisateur et renvoyer un token', async () => {
      // Mocks pour la requête et la réponse
      const req = {
        body: {
          email: 'test@example.com',
          password: 'password123',
          role: 'ROLE_CLIENT',
          nom: 'Test',
          prenom: 'User'
        }
      };
      
      const res = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn()
      };
      
      const next = jest.fn();
      
      // Mock pour User.findOne (vérification d'email existant)
      User.findOne.mockResolvedValue(null);
      Pecheur.findOne.mockResolvedValue(null);
      
      // Mock pour User (création d'utilisateur)
      const mockUser = {
        _id: 'fake-id',
        id: 'fake-id',
        email: 'test@example.com',
        roles: 'ROLE_CLIENT',
        nom: 'Test',
        prenom: 'User',
        save: jest.fn().mockResolvedValue(true)
      };
      
      User.mockImplementation(() => mockUser);
      
      // Appeler la fonction register
      await register(req, res, next);
      
      // Vérifier que les fonctions ont été appelées correctement
      expect(User.findOne).toHaveBeenCalledWith({ email: 'test@example.com' });
      expect(User).toHaveBeenCalledWith(expect.objectContaining({
        email: 'test@example.com',
        password: 'password123',
        roles: 'ROLE_CLIENT',
        nom: 'Test',
        prenom: 'User'
      }));
      expect(mockUser.save).toHaveBeenCalled();
      expect(jwt.sign).toHaveBeenCalled();
      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
        success: true,
        message: 'Inscription réussie',
        token: 'fake-token'
      }));
    });
    
    it('devrait renvoyer une erreur si l\'email existe déjà', async () => {
      // Mocks pour la requête et la réponse
      const req = {
        body: {
          email: 'existing@example.com',
          password: 'password123',
          role: 'ROLE_CLIENT',
          nom: 'Existing',
          prenom: 'User'
        }
      };
      
      const res = {};
      const next = jest.fn();
      
      // Mock pour User.findOne (email existant)
      User.findOne.mockResolvedValue({ email: 'existing@example.com' });
      
      // Appeler la fonction register
      await register(req, res, next);
      
      // Vérifier que next a été appelé avec une erreur
      expect(next).toHaveBeenCalledWith(expect.objectContaining({
        message: 'Cet email est déjà utilisé'
      }));
    });
  });
  
  describe('login', () => {
    it('devrait authentifier un utilisateur et renvoyer un token', async () => {
      // Mocks pour la requête et la réponse
      const req = {
        body: {
          email: 'test@example.com',
          password: 'password123'
        }
      };
      
      const res = {
        json: jest.fn()
      };
      
      const next = jest.fn();
      
      // Mock pour User.findOne
      const mockUser = {
        _id: 'fake-id',
        id: 'fake-id',
        email: 'test@example.com',
        roles: 'ROLE_CLIENT',
        nom: 'Test',
        prenom: 'User',
        isValidated: true,
        comparePassword: jest.fn().mockResolvedValue(true)
      };
      
      User.findOne.mockResolvedValue(mockUser);
      Pecheur.findOne.mockResolvedValue(null);
      
      // Appeler la fonction login
      await login(req, res, next);
      
      // Vérifier que les fonctions ont été appelées correctement
      expect(User.findOne).toHaveBeenCalledWith({ email: 'test@example.com' });
      expect(mockUser.comparePassword).toHaveBeenCalledWith('password123');
      expect(jwt.sign).toHaveBeenCalled();
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
        success: true,
        message: 'Connexion réussie',
        token: 'fake-token'
      }));
    });
    
    it('devrait renvoyer une erreur si l\'utilisateur n\'existe pas', async () => {
      // Mocks pour la requête et la réponse
      const req = {
        body: {
          email: 'nonexistent@example.com',
          password: 'password123'
        }
      };
      
      const res = {};
      const next = jest.fn();
      
      // Mock pour User.findOne (utilisateur non trouvé)
      User.findOne.mockResolvedValue(null);
      Pecheur.findOne.mockResolvedValue(null);
      
      // Appeler la fonction login
      await login(req, res, next);
      
      // Vérifier que next a été appelé avec une erreur
      expect(next).toHaveBeenCalledWith(expect.objectContaining({
        message: 'Email ou mot de passe incorrect'
      }));
    });
  });
  
  describe('getProfile', () => {
    it('devrait renvoyer le profil de l\'utilisateur connecté', async () => {
      // Mocks pour la requête et la réponse
      const req = {
        user: {
          _id: 'fake-id',
          id: 'fake-id',
          email: 'test@example.com',
          roles: 'ROLE_CLIENT',
          nom: 'Test',
          prenom: 'User',
          isValidated: true
        }
      };
      
      const res = {
        json: jest.fn()
      };
      
      const next = jest.fn();
      
      // Appeler la fonction getProfile
      await getProfile(req, res, next);
      
      // Vérifier que les fonctions ont été appelées correctement
      expect(res.json).toHaveBeenCalledWith(expect.objectContaining({
        success: true,
        user: expect.objectContaining({
          id: 'fake-id',
          email: 'test@example.com',
          roles: 'ROLE_CLIENT',
          nom: 'Test',
          prenom: 'User'
        })
      }));
    });
    
    it('devrait renvoyer une erreur si l\'utilisateur n\'est pas trouvé', async () => {
      // Mocks pour la requête et la réponse
      const req = {
        user: null
      };
      
      const res = {};
      const next = jest.fn();
      
      // Appeler la fonction getProfile
      await getProfile(req, res, next);
      
      // Vérifier que next a été appelé avec une erreur
      expect(next).toHaveBeenCalledWith(expect.objectContaining({
        message: 'Utilisateur non trouvé'
      }));
    });
  });
});
