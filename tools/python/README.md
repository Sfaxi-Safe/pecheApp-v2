# Module de classification des poissons

Ce dossier contient les scripts Python pour la classification des espèces de poissons utilisés dans l'application SeaTrace.

## Prérequis

Pour exécuter ces scripts, vous aurez besoin des bibliothèques Python suivantes :

```bash
pip install tensorflow pillow numpy argparse
```

## Utilisation

Le script principal `predict.py` permet d'identifier l'espèce d'un poisson à partir d'une image :

```bash
python predict.py <chemin_image> [--model <chemin_modele>] [--labels <chemin_labels>] [--top <nombre>]
```

### Arguments

- `<chemin_image>` : Chemin vers l'image à analyser (obligatoire)
- `--model` : Chemin vers le fichier du modèle (.h5) (optionnel, par défaut : `../../assets/models/keras_model.h5`)
- `--labels` : Chemin vers le fichier des labels (.txt) (optionnel, par défaut : `../../assets/models/labels.txt`)
- `--top` : Nombre de prédictions à afficher (optionnel, par défaut : 3)

### Exemple

```bash
python predict.py ../../test_images/thon.jpg
```

## Intégration avec Flutter

Ce script est utilisé comme référence pour l'implémentation Dart dans l'application SeaTrace. Le code Dart correspondant se trouve dans :

- `lib/services/tensorflow_service.dart` : Service pour l'intégration du modèle TensorFlow Lite
- `lib/services/fish_recognition_service.dart` : Service pour la reconnaissance des poissons

## Modèle

Le modèle utilisé est un modèle Keras entraîné pour reconnaître 31 espèces de poissons méditerranéens :

- baliste
- bou kachech
- boumessk
- bouri
- calamr
- chevrette
- choubay
- crevettes
- djej
- espadon
- far bhar
- ghzel
- jaghali
- kalb bhar
- karnit
- karous
- karradh
- khadhraya
- mankous
- mannani
- mbellem
- meeza
- morjan
- msalla
- sardouk
- sbares
- scorpaena
- serdina
- thon
- trillia
- wrata

## Remarques

- Le modèle a été entraîné sur des images de poissons méditerranéens et peut ne pas être précis pour d'autres espèces.
- Pour de meilleurs résultats, utilisez des images claires et bien éclairées, avec le poisson bien visible et centré.
- L'application mobile utilise également l'API Google Cloud Vision pour une meilleure précision lorsqu'une connexion internet est disponible.
