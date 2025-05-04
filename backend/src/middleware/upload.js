const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Assurez-vous que le dossier uploads existe avec les bonnes permissions
const uploadDir = path.join(__dirname, '../../uploads');
try {
  if (!fs.existsSync(uploadDir)) {
    console.log(`Création du dossier d'upload depuis le middleware: ${uploadDir}`);
    fs.mkdirSync(uploadDir, { recursive: true });
    // Définir les permissions (0755 = rwxr-xr-x)
    fs.chmodSync(uploadDir, 0o755);
  }
} catch (error) {
  console.error('Erreur lors de la création du dossier d\'upload:', error);
}

// Configuration du stockage
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    console.log(`Traitement de l'upload pour le fichier: ${file.originalname}`);

    // Vérifier à nouveau que le dossier existe au moment de l'upload
    if (!fs.existsSync(uploadDir)) {
      console.error(`Le dossier d'upload n'existe pas: ${uploadDir}`);
      try {
        // Tenter de créer le dossier s'il n'existe pas
        fs.mkdirSync(uploadDir, { recursive: true });
        console.log(`Dossier d'upload créé: ${uploadDir}`);
      } catch (mkdirError) {
        console.error(`Impossible de créer le dossier d'upload:`, mkdirError);
        return cb(new Error(`Impossible de créer le dossier d'upload: ${mkdirError.message}`), null);
      }
    }

    // Vérifier les permissions d'écriture
    try {
      fs.accessSync(uploadDir, fs.constants.W_OK);
      console.log(`Permissions d'écriture OK sur le dossier: ${uploadDir}`);
      cb(null, uploadDir);
    } catch (error) {
      console.error(`Erreur de permission sur le dossier d'upload:`, error);

      // Tenter de corriger les permissions
      try {
        fs.chmodSync(uploadDir, 0o755);
        console.log(`Permissions du dossier mises à jour à 0755`);
        cb(null, uploadDir);
      } catch (chmodError) {
        console.error(`Impossible de modifier les permissions:`, chmodError);
        cb(new Error(`Pas de permission d'écriture sur le dossier d'upload: ${error.message}`), null);
      }
    }
  },
  filename: (req, file, cb) => {
    try {
      // Nettoyer le nom de fichier original
      const originalName = path.basename(file.originalname).replace(/[^a-zA-Z0-9.]/g, '_');
      console.log(`Nom de fichier original nettoyé: ${originalName}`);

      // Générer un nom de fichier unique avec l'extension d'origine
      const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
      const ext = path.extname(originalName).toLowerCase();
      console.log(`Extension détectée: ${ext}`);

      // Vérifier que l'extension est valide
      const validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
      if (!validExtensions.includes(ext)) {
        console.error(`Extension de fichier non supportée: ${ext}`);
        return cb(new Error(`Extension de fichier non supportée: ${ext}. Utilisez JPG, PNG, GIF ou WebP.`), null);
      }

      // Vérifier le type MIME
      const validMimeTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
      if (!validMimeTypes.includes(file.mimetype)) {
        console.error(`Type MIME non supporté: ${file.mimetype}`);
        return cb(new Error(`Type de fichier non supporté: ${file.mimetype}. Utilisez JPG, PNG, GIF ou WebP.`), null);
      }

      const filename = `profile_${uniqueSuffix}${ext}`;
      console.log(`Nom de fichier généré: ${filename}`);
      cb(null, filename);
    } catch (error) {
      console.error('Erreur lors de la génération du nom de fichier:', error);
      cb(error, null);
    }
  }
});

// Filtre pour n'accepter que les images
const fileFilter = (req, file, cb) => {
  // Liste des types MIME autorisés
  const allowedMimeTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];

  if (allowedMimeTypes.includes(file.mimetype)) {
    console.log(`Type MIME accepté: ${file.mimetype}`);
    cb(null, true);
  } else {
    console.error(`Type MIME rejeté: ${file.mimetype}`);
    cb(new Error(`Type de fichier non supporté: ${file.mimetype}. Utilisez JPG, PNG, GIF ou WebP.`), false);
  }
};

// Gestion des erreurs de multer
const handleMulterError = (err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    // Erreur Multer spécifique
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        error: 'La taille du fichier dépasse la limite de 5 MB'
      });
    }
    return res.status(400).json({ error: `Erreur d'upload: ${err.message}` });
  } else if (err) {
    // Autre erreur
    return res.status(500).json({ error: err.message });
  }
  next();
};

// Configuration de multer
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024 // Limite à 5MB
  }
});

// Exporter à la fois le middleware d'upload et le gestionnaire d'erreurs
module.exports = upload;
