/**
 * Middleware pour standardiser les noms de champs entre le frontend et le backend
 */

// Transforme les noms de champs camelCase en snake_case
const toCamelCase = (str) => {
  return str.replace(/_([a-z])/g, (match, group) => group.toUpperCase());
};

// Transforme les noms de champs snake_case en camelCase
const toSnakeCase = (str) => {
  return str.replace(/[A-Z]/g, (match) => `_${match.toLowerCase()}`);
};

// Transforme un objet en convertissant les noms de champs
const transformObject = (obj, transformer) => {
  if (!obj || typeof obj !== 'object' || Array.isArray(obj)) return obj;
  
  const result = {};
  
  Object.keys(obj).forEach(key => {
    const value = obj[key];
    const transformedKey = transformer(key);
    
    if (value && typeof value === 'object') {
      if (Array.isArray(value)) {
        result[transformedKey] = value.map(item => 
          typeof item === 'object' && item !== null 
            ? transformObject(item, transformer) 
            : item
        );
      } else {
        result[transformedKey] = transformObject(value, transformer);
      }
    } else {
      result[transformedKey] = value;
    }
  });
  
  return result;
};

// Middleware pour standardiser les données entrantes (request)
const standardizeRequest = (req, res, next) => {
  if (req.body && typeof req.body === 'object') {
    req.body = transformObject(req.body, toCamelCase);
  }
  
  if (req.query && typeof req.query === 'object') {
    req.query = transformObject(req.query, toCamelCase);
  }
  
  next();
};

// Middleware pour standardiser les données sortantes (response)
const standardizeResponse = (req, res, next) => {
  const originalJson = res.json;
  
  res.json = function(data) {
    const transformedData = transformObject(data, toCamelCase);
    return originalJson.call(this, transformedData);
  };
  
  next();
};

// Middleware pour standardiser les booléens
const standardizeBooleans = (req, res, next) => {
  if (req.body && typeof req.body === 'object') {
    Object.keys(req.body).forEach(key => {
      const value = req.body[key];
      if (value === '0' || value === 0) {
        req.body[key] = false;
      } else if (value === '1' || value === 1) {
        req.body[key] = true;
      }
    });
  }
  
  next();
};

module.exports = {
  standardizeRequest,
  standardizeResponse,
  standardizeBooleans
};
