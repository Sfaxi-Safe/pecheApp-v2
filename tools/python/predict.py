#!/usr/bin/env python3
"""
Script de démonstration pour la classification des espèces de poissons.

Ce script est une version simplifiée qui simule la prédiction d'espèces de poissons.
Pour utiliser la version complète avec TensorFlow, voir les commentaires dans le code.

Utilisation:
    python predict.py <chemin_image>

Exemple:
    python predict.py ../../test_images/thon.jpg

Auteur: Équipe SeaTrace
Date: Mai 2025
"""

import os
import sys
import argparse
import random

# Note: Les imports suivants sont commentés car ils peuvent nécessiter des installations supplémentaires
# from PIL import Image
# import numpy as np
# from tensorflow.keras.models import load_model

def load_labels(labels_path=None):
    """
    Charge les labels.

    Args:
        labels_path (str): Chemin vers le fichier des labels (.txt)

    Returns:
        list: liste des noms de classes
    """
    # Chemin par défaut
    if labels_path is None:
        labels_path = os.path.join(os.path.dirname(__file__), "../../assets/models/labels.txt")

    # Vérifier si le fichier existe
    if not os.path.exists(labels_path):
        raise FileNotFoundError(f"Le fichier des labels n'existe pas: {labels_path}")

    # Charger les labels
    with open(labels_path, "r", encoding="utf-8") as f:
        class_names = f.read().splitlines()

    # Traiter les labels (format: "0 baliste")
    processed_names = []
    for name in class_names:
        if name.strip():
            parts = name.strip().split(" ", 1)
            if len(parts) > 1:
                processed_names.append(parts[1])
            else:
                processed_names.append(name)

    return processed_names

def predict_image(image_path, labels_path=None):
    """
    Simule la prédiction d'une espèce de poisson à partir d'une image.

    Note: Cette version du script ne fait pas de prédiction réelle.
    Elle retourne une espèce aléatoire parmi les labels disponibles.

    Args:
        image_path (str): Chemin vers l'image à analyser
        labels_path (str): Chemin vers le fichier des labels (optionnel)

    Returns:
        tuple: (nom de la classe, confiance, tous les résultats)
    """
    # Charger les labels
    class_names = load_labels(labels_path)

    # Vérifier si l'image existe
    if not os.path.exists(image_path):
        raise FileNotFoundError(f"L'image n'existe pas: {image_path}")

    # Vérifier que le fichier est bien une image (version simplifiée)
    try:
        with open(image_path, 'rb') as f:
            # Vérifier les premiers octets pour s'assurer que c'est une image
            header = f.read(8)
            if not (header.startswith(b'\xff\xd8') or  # JPEG
                   header.startswith(b'\x89PNG') or   # PNG
                   header.startswith(b'GIF') or       # GIF
                   header.startswith(b'BM')):         # BMP
                print("Attention: Le fichier ne semble pas être une image standard.")
    except Exception as e:
        raise ValueError(f"Erreur lors de la lecture du fichier: {e}")

    # Simulation de prédiction
    import random

    # Générer des scores aléatoires pour chaque classe
    fake_predictions = [random.random() for _ in range(len(class_names))]

    # Normaliser pour que la somme soit 1
    total = sum(fake_predictions)
    normalized_predictions = [p/total for p in fake_predictions]

    # Trouver l'indice de la classe avec la plus haute probabilité
    index = normalized_predictions.index(max(normalized_predictions))
    class_name = class_names[index]
    confidence = normalized_predictions[index]

    # Retourner tous les résultats triés par confiance
    all_results = []
    for i, conf in enumerate(normalized_predictions):
        all_results.append((class_names[i], float(conf)))

    # Trier par confiance décroissante
    all_results.sort(key=lambda x: x[1], reverse=True)

    print(f"NOTE: Cette version du script utilise des prédictions aléatoires.")
    print(f"Pour utiliser la version complète avec TensorFlow, voir les commentaires dans le code.")

    return class_name, float(confidence), all_results

def main():
    """Fonction principale pour l'exécution en ligne de commande."""
    parser = argparse.ArgumentParser(description="Prédiction d'espèce de poisson à partir d'une image")
    parser.add_argument("image", nargs='?', help="Chemin vers l'image à analyser")
    parser.add_argument("--labels", help="Chemin vers le fichier des labels (.txt)")
    parser.add_argument("--top", type=int, default=3, help="Nombre de prédictions à afficher")
    args = parser.parse_args()

    if args.image is None:
        print("ERREUR: Vous devez spécifier une image à analyser.")
        print("Exemple: python predict.py ../../test_images/thon.jpg")
        return 1

    try:
        # Prédire l'espèce (version sans TensorFlow)
        class_name, confidence, all_results = predict_image(args.image, args.labels)

        # Afficher le résultat principal
        print(f"\nEspèce détectée : {class_name} ({confidence * 100:.2f}%)")

        # Afficher les N meilleures prédictions
        print(f"\nTop {min(args.top, len(all_results))} prédictions:")
        for i, (name, conf) in enumerate(all_results[:args.top]):
            print(f"{i+1}. {name}: {conf * 100:.2f}%")

    except Exception as e:
        print(f"Erreur: {e}")
        return 1

    return 0

# Exemple d'utilisation
if __name__ == "__main__":
    sys.exit(main())
