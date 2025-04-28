const mongoose = require('mongoose');

const especeSchema = new mongoose.Schema({
  nom: {
    type: String,
    required: true,
    trim: true
  },
  imageUrl: {
    type: String,
    required: true
  }
}, {
  timestamps: true
});

const Espece = mongoose.model('Espece', especeSchema);

module.exports = Espece;