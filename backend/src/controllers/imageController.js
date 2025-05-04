const path = require('path');
const fs = require('fs');

// Vérifier et créer le dossier d'upload si nécessaire
const ensureUploadDirExists = () => {
  const uploadDir = path.join(__dirname, '../../uploads');
  if (!fs.existsSync(uploadDir)) {
    console.log(`Création du dossier d'upload: ${uploadDir}`);
    try {
      fs.mkdirSync(uploadDir, { recursive: true });
      // Définir les permissions (0755 = rwxr-xr-x)
      fs.chmodSync(uploadDir, 0o755);
      console.log(`Dossier d'upload créé avec succès avec les permissions 0755`);
    } catch (error) {
      console.error(`Erreur lors de la création du dossier d'upload:`, error);
      throw error;
    }
  } else {
    // Vérifier les permissions
    try {
      const stats = fs.statSync(uploadDir);
      const currentPermissions = stats.mode & 0o777; // Masque pour obtenir uniquement les permissions
      console.log(`Permissions actuelles du dossier d'upload: ${currentPermissions.toString(8)}`);

      // Si les permissions ne sont pas suffisantes, les mettre à jour
      if (currentPermissions !== 0o755) {
        fs.chmodSync(uploadDir, 0o755);
        console.log(`Permissions du dossier d'upload mises à jour à 0755`);
      }
    } catch (error) {
      console.error(`Erreur lors de la vérification des permissions:`, error);
    }
  }
  return uploadDir;
};

// Télécharger une image
const uploadImage = async (req, res) => {
  try {
    // S'assurer que le dossier d'upload existe avec les bonnes permissions
    const uploadDir = ensureUploadDirExists();

    if (!req.file) {
      console.error('Aucun fichier reçu dans la requête');
      return res.status(400).json({ error: 'Aucun fichier téléchargé' });
    }

    console.log(`Fichier reçu: ${req.file.filename}, taille: ${req.file.size} octets, type: ${req.file.mimetype}`);

    // Vérifier que le type MIME est valide
    const validMimeTypes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    if (!validMimeTypes.includes(req.file.mimetype)) {
      // Supprimer le fichier si le type MIME n'est pas valide
      try {
        fs.unlinkSync(path.join(uploadDir, req.file.filename));
      } catch (e) {
        console.error('Erreur lors de la suppression du fichier invalide:', e);
      }

      console.error(`Type de fichier non supporté: ${req.file.mimetype}`);
      return res.status(400).json({
        error: `Type de fichier non supporté: ${req.file.mimetype}. Utilisez JPG, PNG, GIF ou WebP.`
      });
    }

    // Vérifier que le fichier a bien été enregistré
    const filePath = path.join(uploadDir, req.file.filename);
    if (!fs.existsSync(filePath)) {
      console.error(`Le fichier n'a pas été correctement enregistré: ${filePath}`);
      return res.status(500).json({ error: 'Erreur lors de l\'enregistrement du fichier' });
    }

    // Vérifier la taille du fichier
    const stats = fs.statSync(filePath);
    if (stats.size > 5 * 1024 * 1024) { // 5 MB
      // Supprimer le fichier si trop grand
      try {
        fs.unlinkSync(filePath);
      } catch (e) {
        console.error('Erreur lors de la suppression du fichier trop grand:', e);
      }

      console.error(`Fichier trop grand: ${stats.size} octets`);
      return res.status(400).json({
        error: 'La taille du fichier dépasse la limite de 5 MB'
      });
    }

    // Construire l'URL de l'image
    const imageUrl = `/api/images/${req.file.filename}`;
    console.log(`Image téléchargée avec succès: ${imageUrl}`);

    res.status(201).json({
      success: true,
      imageUrl: imageUrl,
      filename: req.file.filename,
      size: req.file.size,
      mimetype: req.file.mimetype
    });
  } catch (error) {
    console.error('Erreur lors du téléchargement de l\'image:', error);
    res.status(500).json({ error: error.message });
  }
};

// Récupérer une image par son nom de fichier
const getImage = async (req, res) => {
  try {
    const filename = req.params.filename;
    const imagePath = path.join(__dirname, '../../uploads', filename);

    // Vérifier si le fichier existe
    if (!fs.existsSync(imagePath)) {
      return res.status(404).json({ error: 'Image non trouvée' });
    }

    // Envoyer le fichier
    res.sendFile(imagePath);
  } catch (error) {
    console.error('Erreur lors de la récupération de l\'image:', error);
    res.status(500).json({ error: error.message });
  }
};

// Supprimer une image
const deleteImage = async (req, res) => {
  try {
    const filename = req.params.filename;
    const imagePath = path.join(__dirname, '../../uploads', filename);

    // Vérifier si le fichier existe
    if (!fs.existsSync(imagePath)) {
      return res.status(404).json({ error: 'Image non trouvée' });
    }

    // Supprimer le fichier
    fs.unlinkSync(imagePath);

    res.status(200).json({ success: true, message: 'Image supprimée avec succès' });
  } catch (error) {
    console.error('Erreur lors de la suppression de l\'image:', error);
    res.status(500).json({ error: error.message });
  }
};

module.exports = {
  uploadImage,
  getImage,
  deleteImage
};
