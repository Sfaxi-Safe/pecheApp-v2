@echo off
echo ===== CORRECTION FIREBASE ANDROID =====
cd C:\Users\safes\SeaTrace

echo Suppression du cache Gradle...
cd android
rmdir /s /q .gradle
rmdir /s /q build
cd ..

echo Modification du fichier gradle.properties...
echo kotlin.suppressMissingKotlinMetadataVersionError=true >> android\gradle.properties

echo Nettoyage de Flutter...
call flutter clean

echo Récupération des dépendances...
call flutter pub get

echo Exécution de l'application en mode debug...
call flutter run --debug

echo ===== TERMINÉ =====
pause
