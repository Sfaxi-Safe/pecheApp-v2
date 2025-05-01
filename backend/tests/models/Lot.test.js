/**
 * Tests unitaires pour le modèle Lot
 */
const mongoose = require('mongoose');
const Lot = require('../../src/models/Lot');

// Mock de mongoose
jest.mock('mongoose', () => {
  const originalModule = jest.requireActual('mongoose');

  return {
    ...originalModule,
    connect: jest.fn(),
    disconnect: jest.fn(),
    Types: {
      ObjectId: jest.fn(() => 'mock-object-id')
    }
  };
});

// Mock du modèle Lot
jest.mock('../../src/models/Lot', () => {
  return jest.fn().mockImplementation((data) => {
    return {
      ...data,
      _id: 'mock-id',
      save: jest.fn().mockImplementation(function() {
        return Promise.resolve(this);
      })
    };
  });
});

// Configuration avant les tests
beforeAll(() => {
  // Réinitialiser les mocks
  jest.clearAllMocks();
});

// Nettoyage après chaque test
afterEach(() => {
  jest.clearAllMocks();
});

describe('Modèle Lot', () => {
  it('devrait créer et sauvegarder un lot avec succès', async () => {
    // Créer un lot de test
    const lotData = {
      identifiant: 'LOT-TEST-001',
      rfid: 'RFID-TEST-001',
      quantite: 100,
      poids: 50.5,
      espece: new mongoose.Types.ObjectId(),
      prise: new mongoose.Types.ObjectId(),
      prixInitial: 1000,
      prixMinimal: 800
    };

    const lot = new Lot(lotData);
    const savedLot = await lot.save();

    // Vérifier que le lot a été sauvegardé avec les bonnes valeurs
    expect(savedLot._id).toBeDefined();
    expect(savedLot.identifiant).toBe(lotData.identifiant);
    expect(savedLot.rfid).toBe(lotData.rfid);
    expect(savedLot.quantite).toBe(lotData.quantite);
    expect(savedLot.poids).toBe(lotData.poids);
    expect(savedLot.espece.toString()).toBe(lotData.espece.toString());
    expect(savedLot.prise.toString()).toBe(lotData.prise.toString());
    expect(savedLot.prixInitial).toBe(lotData.prixInitial);
    expect(savedLot.prixMinimal).toBe(lotData.prixMinimal);
    expect(savedLot.vendu).toBe(false); // Valeur par défaut
    expect(savedLot.test).toBe(false); // Valeur par défaut
    expect(savedLot.status).toBe(false); // Valeur par défaut
  });

  it('devrait échouer à la validation si les champs requis sont manquants', async () => {
    // Créer un lot sans les champs requis
    const lot = new Lot({
      identifiant: 'LOT-TEST-002',
      rfid: 'RFID-TEST-002'
      // espece et prise manquants
    });

    // Vérifier que la validation échoue
    await expect(lot.save()).rejects.toThrow();
  });

  it('devrait échouer si identifiant est dupliqué', async () => {
    // Créer un premier lot
    const lot1 = new Lot({
      identifiant: 'LOT-TEST-003',
      rfid: 'RFID-TEST-003',
      espece: new mongoose.Types.ObjectId(),
      prise: new mongoose.Types.ObjectId()
    });
    await lot1.save();

    // Créer un deuxième lot avec le même identifiant
    const lot2 = new Lot({
      identifiant: 'LOT-TEST-003', // Même identifiant
      rfid: 'RFID-TEST-004',
      espece: new mongoose.Types.ObjectId(),
      prise: new mongoose.Types.ObjectId()
    });

    // Vérifier que la sauvegarde échoue à cause de la contrainte d'unicité
    await expect(lot2.save()).rejects.toThrow();
  });

  it('devrait mettre à jour un lot avec succès', async () => {
    // Créer un lot
    const lot = new Lot({
      identifiant: 'LOT-TEST-004',
      rfid: 'RFID-TEST-005',
      espece: new mongoose.Types.ObjectId(),
      prise: new mongoose.Types.ObjectId(),
      prixInitial: 1000
    });
    await lot.save();

    // Mettre à jour le lot
    lot.prixInitial = 1200;
    lot.prixFinal = 1300;
    lot.vendu = true;
    const updatedLot = await lot.save();

    // Vérifier que les mises à jour ont été appliquées
    expect(updatedLot.prixInitial).toBe(1200);
    expect(updatedLot.prixFinal).toBe(1300);
    expect(updatedLot.vendu).toBe(true);
  });
});
