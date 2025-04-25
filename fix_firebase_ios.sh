#!/bin/bash
echo "===== CORRECTION FIREBASE iOS ====="
cd "$(dirname "$0")"

echo "Nettoyage de Flutter..."
flutter clean

echo "Récupération des dépendances..."
flutter pub get

echo "Nettoyage des pods..."
cd ios
rm -rf Pods
rm -f Podfile.lock
pod deintegrate
pod setup
pod install --repo-update
cd ..

echo "Exécution de l'application en mode debug..."
flutter run --debug

echo "===== TERMINÉ ====="
