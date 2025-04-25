@echo off
echo ===== NETTOYAGE COMPLET =====
cd C:\Users\safes\SeaTrace

echo Suppression du dossier .gradle...
rmdir /s /q android\.gradle

echo Suppression du dossier .dart_tool...
rmdir /s /q .dart_tool

echo Suppression du dossier build...
rmdir /s /q build

echo Nettoyage de Flutter...
call flutter clean

echo Récupération des dépendances...
call flutter pub get

echo Construction de l'application...
call flutter build apk --debug

echo ===== TERMINÉ =====
pause
