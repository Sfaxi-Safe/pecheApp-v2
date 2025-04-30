const path = require('path');
const fs = require('fs');

// Télécharger une image
const uploadImage = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'Aucun fichier téléchargé' });
    }

    // Construire l'URL de l'image
    const imageUrl = `/api/images/${req.file.filename}`;
    
    res.status(201).json({
      success: true,
      imageUrl: imageUrl,
      filename: req.file.filename,
      size: req.file.size
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
