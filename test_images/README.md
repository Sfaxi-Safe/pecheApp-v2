# Images de test pour la reconnaissance de poissons

Ce dossier est destiné à contenir des images de poissons pour tester le module de reconnaissance d'espèces.

## Comment utiliser ce dossier

1. Ajoutez des images de différentes espèces de poissons dans ce dossier
2. Utilisez ces images pour tester le script Python de reconnaissance :

```bash
cd tools/python
python predict.py ../../test_images/votre_image.jpg
```

## Espèces recommandées

Pour tester efficacement le modèle, essayez d'inclure des images des espèces suivantes :

- Thon (thon)
- Dorade (sbares)
- Sardine (serdina)
- Espadon (espadon)
- Et d'autres espèces méditerranéennes listées dans le fichier `assets/models/labels.txt`

## Sources d'images

Vous pouvez obtenir des images de poissons à partir de :
- Photos que vous avez prises vous-même
- Images libres de droits trouvées sur internet
- Images générées par IA (si vous n'avez pas d'images réelles)

## Remarques

- Pour de meilleurs résultats, utilisez des images claires et bien éclairées
- Le poisson doit être bien visible et centré dans l'image
- Évitez les images avec plusieurs poissons ou d'autres objets qui pourraient perturber la reconnaissance
