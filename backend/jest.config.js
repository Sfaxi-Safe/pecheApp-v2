/**
 * Configuration Jest pour les tests unitaires
 */
module.exports = {
  // Répertoire racine pour la recherche des tests
  rootDir: '.',
  
  // Motifs de fichiers pour les tests
  testMatch: [
    '**/tests/**/*.test.js'
  ],
  
  // Environnement de test
  testEnvironment: 'node',
  
  // Couverture de code
  collectCoverage: true,
  coverageDirectory: 'coverage',
  collectCoverageFrom: [
    'src/**/*.js',
    '!src/index.js',
    '!src/config/**/*.js'
  ],
  
  // Timeout pour les tests
  testTimeout: 30000,
  
  // Afficher les détails des tests
  verbose: true
};
