/**
 * Service de mise en cache pour améliorer les performances des requêtes fréquentes
 * Implémente un cache en mémoire avec expiration des entrées
 */

class CacheService {
  constructor() {
    this.cache = new Map();
    this.defaultTTL = 5 * 60 * 1000; // 5 minutes en millisecondes
  }

  /**
   * Récupère une valeur du cache
   * @param {string} key - Clé de l'entrée à récupérer
   * @returns {any|null} - Valeur associée à la clé ou null si non trouvée ou expirée
   */
  get(key) {
    if (!this.cache.has(key)) {
      return null;
    }

    const entry = this.cache.get(key);
    
    // Vérifier si l'entrée a expiré
    if (entry.expiry < Date.now()) {
      this.cache.delete(key);
      return null;
    }

    return entry.value;
  }

  /**
   * Stocke une valeur dans le cache
   * @param {string} key - Clé de l'entrée à stocker
   * @param {any} value - Valeur à stocker
   * @param {number} [ttl] - Durée de vie en millisecondes (utilise la valeur par défaut si non spécifiée)
   */
  set(key, value, ttl = this.defaultTTL) {
    const expiry = Date.now() + ttl;
    this.cache.set(key, { value, expiry });
  }

  /**
   * Supprime une entrée du cache
   * @param {string} key - Clé de l'entrée à supprimer
   */
  delete(key) {
    this.cache.delete(key);
  }

  /**
   * Vide complètement le cache
   */
  clear() {
    this.cache.clear();
  }

  /**
   * Nettoie les entrées expirées du cache
   */
  cleanup() {
    const now = Date.now();
    for (const [key, entry] of this.cache.entries()) {
      if (entry.expiry < now) {
        this.cache.delete(key);
      }
    }
  }

  /**
   * Récupère une valeur du cache ou l'y ajoute si elle n'existe pas
   * @param {string} key - Clé de l'entrée
   * @param {Function} fetchFunction - Fonction asynchrone pour récupérer la valeur si non présente dans le cache
   * @param {number} [ttl] - Durée de vie en millisecondes (utilise la valeur par défaut si non spécifiée)
   * @returns {Promise<any>} - Valeur récupérée du cache ou de la fonction
   */
  async getOrSet(key, fetchFunction, ttl = this.defaultTTL) {
    const cachedValue = this.get(key);
    if (cachedValue !== null) {
      return cachedValue;
    }

    const value = await fetchFunction();
    this.set(key, value, ttl);
    return value;
  }
}

// Créer une instance unique du service de cache
const cacheService = new CacheService();

// Nettoyer le cache toutes les 15 minutes
setInterval(() => {
  cacheService.cleanup();
}, 15 * 60 * 1000);

module.exports = cacheService;
