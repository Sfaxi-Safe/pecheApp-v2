/**
 * Tests unitaires pour les routes des lots
 */
const request = require('supertest');
const express = require('express');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const Lot = require('../../src/models/Lot');
const lotRoutes = require('../../src/routes/lotRoutes');
const { auth, checkRole } = require('../../src/middleware/auth');
const responseFormatter = require('../../src/middleware/responseFormatter');

// Mock des middlewares
jest.mock('../../src/middleware/auth', () => ({
  auth: jest.fn((req, res, next) => next()),
  checkRole: jest.fn(() => (req, res, next) => next())
}));

let app;
let mongoServer;

// Configuration avant les tests
beforeAll(async () => {
  // Créer une instance MongoDB en mémoire pour les tests
  mongoServer = await MongoMemoryServer.create();
  const uri = mongoServer.getUri();
  await mongoose.connect(uri);
  
  // Créer une application Express pour les tests
  app = express();
  app.use(express.json());
  app.use(responseFormatter);
  app.use('/api/lots', lotRoutes);
});

// Nettoyage après les tests
afterAll(async () => {
  await mongoose.disconnect();
  await mongoServer.stop();
});

// Nettoyage après chaque test
afterEach(async () => {
  await Lot.deleteMany({});
  jest.clearAllMocks();
});

describe('Routes des lots', () => {
  describe('GET /api/lots', () => {
    it('devrait renvoyer une liste vide si aucun lot n\'existe', async () => {
      const response = await request(app).get('/api/lots');
      
      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toEqual([]);
    });
    
    it('devrait renvoyer tous les lots existants', async () => {
      // Créer quelques lots de test
      const lot1 = new Lot({
        identifiant: 'LOT-TEST-001',
        espece: new mongoose.Types.ObjectId(),
        prise: new mongoose.Types.ObjectId()
      });
      
      const lot2 = new Lot({
        identifiant: 'LOT-TEST-002',
        espece: new mongoose.Types.ObjectId(),
        prise: new mongoose.Types.ObjectId()
      });
      
      await lot1.save();
      await lot2.save();
      
      const response = await request(app).get('/api/lots');
      
      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.length).toBe(2);
      expect(response.body.data[0].identifiant).toBe('LOT-TEST-001');
      expect(response.body.data[1].identifiant).toBe('LOT-TEST-002');
    });
    
    it('devrait filtrer les lots par statut de vente', async () => {
      // Créer des lots avec différents statuts de vente
      const lot1 = new Lot({
        identifiant: 'LOT-TEST-003',
        espece: new mongoose.Types.ObjectId(),
        prise: new mongoose.Types.ObjectId(),
        vendu: true
      });
      
      const lot2 = new Lot({
        identifiant: 'LOT-TEST-004',
        espece: new mongoose.Types.ObjectId(),
        prise: new mongoose.Types.ObjectId(),
        vendu: false
      });
      
      await lot1.save();
      await lot2.save();
      
      const response = await request(app).get('/api/lots?vendu=true');
      
      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.length).toBe(1);
      expect(response.body.data[0].identifiant).toBe('LOT-TEST-003');
    });
  });
  
  describe('POST /api/lots', () => {
    it('devrait créer un nouveau lot', async () => {
      const especeId = new mongoose.Types.ObjectId();
      const priseId = new mongoose.Types.ObjectId();
      
      const lotData = {
        identifiant: 'LOT-TEST-005',
        espece: especeId.toString(),
        prise: priseId.toString(),
        quantite: 100,
        poids: 50.5,
        prixInitial: 1000
      };
      
      const response = await request(app)
        .post('/api/lots')
        .send(lotData);
      
      expect(response.status).toBe(201);
      expect(response.body.success).toBe(true);
      expect(response.body.data.identifiant).toBe('LOT-TEST-005');
      expect(response.body.data.quantite).toBe(100);
      expect(response.body.data.poids).toBe(50.5);
      expect(response.body.data.prixInitial).toBe(1000);
      
      // Vérifier que le lot a été créé dans la base de données
      const lot = await Lot.findOne({ identifiant: 'LOT-TEST-005' });
      expect(lot).not.toBeNull();
      expect(lot.identifiant).toBe('LOT-TEST-005');
    });
    
    it('devrait renvoyer une erreur si les champs requis sont manquants', async () => {
      const lotData = {
        identifiant: 'LOT-TEST-006'
        // espece et prise manquants
      };
      
      const response = await request(app)
        .post('/api/lots')
        .send(lotData);
      
      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('Espèce et prise sont requises');
    });
  });
  
  describe('GET /api/lots/:id', () => {
    it('devrait renvoyer un lot spécifique par ID', async () => {
      // Créer un lot de test
      const lot = new Lot({
        identifiant: 'LOT-TEST-007',
        espece: new mongoose.Types.ObjectId(),
        prise: new mongoose.Types.ObjectId()
      });
      
      await lot.save();
      
      const response = await request(app).get(`/api/lots/${lot._id}`);
      
      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.identifiant).toBe('LOT-TEST-007');
    });
    
    it('devrait renvoyer un lot spécifique par identifiant', async () => {
      // Créer un lot de test
      const lot = new Lot({
        identifiant: 'LOT-TEST-008',
        espece: new mongoose.Types.ObjectId(),
        prise: new mongoose.Types.ObjectId()
      });
      
      await lot.save();
      
      const response = await request(app).get('/api/lots/LOT-TEST-008');
      
      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.identifiant).toBe('LOT-TEST-008');
    });
    
    it('devrait renvoyer une erreur si le lot n\'existe pas', async () => {
      const response = await request(app).get('/api/lots/nonexistent');
      
      expect(response.status).toBe(404);
      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('Lot non trouvé');
    });
  });
  
  describe('PATCH /api/lots/:id', () => {
    it('devrait mettre à jour un lot existant', async () => {
      // Créer un lot de test
      const lot = new Lot({
        identifiant: 'LOT-TEST-009',
        espece: new mongoose.Types.ObjectId(),
        prise: new mongoose.Types.ObjectId(),
        quantite: 100,
        poids: 50
      });
      
      await lot.save();
      
      const updateData = {
        quantite: 150,
        poids: 75
      };
      
      const response = await request(app)
        .patch(`/api/lots/${lot._id}`)
        .send(updateData);
      
      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.quantite).toBe(150);
      expect(response.body.data.poids).toBe(75);
      
      // Vérifier que le lot a été mis à jour dans la base de données
      const updatedLot = await Lot.findById(lot._id);
      expect(updatedLot.quantite).toBe(150);
      expect(updatedLot.poids).toBe(75);
    });
    
    it('devrait renvoyer une erreur si le lot n\'existe pas', async () => {
      const nonExistentId = new mongoose.Types.ObjectId();
      
      const response = await request(app)
        .patch(`/api/lots/${nonExistentId}`)
        .send({ quantite: 200 });
      
      expect(response.status).toBe(404);
      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('Lot non trouvé');
    });
  });
  
  describe('DELETE /api/lots/:id', () => {
    it('devrait supprimer un lot existant', async () => {
      // Créer un lot de test
      const lot = new Lot({
        identifiant: 'LOT-TEST-010',
        espece: new mongoose.Types.ObjectId(),
        prise: new mongoose.Types.ObjectId()
      });
      
      await lot.save();
      
      const response = await request(app).delete(`/api/lots/${lot._id}`);
      
      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('Lot supprimé avec succès');
      
      // Vérifier que le lot a été supprimé de la base de données
      const deletedLot = await Lot.findById(lot._id);
      expect(deletedLot).toBeNull();
    });
    
    it('devrait renvoyer une erreur si le lot n\'existe pas', async () => {
      const nonExistentId = new mongoose.Types.ObjectId();
      
      const response = await request(app).delete(`/api/lots/${nonExistentId}`);
      
      expect(response.status).toBe(404);
      expect(response.body.success).toBe(false);
      expect(response.body.error).toBe('Lot non trouvé');
    });
  });
});
