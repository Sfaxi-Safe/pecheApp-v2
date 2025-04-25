@echo off
echo ===== CORRECTION FIREBASE =====
cd C:\Users\safes\SeaTrace

echo Suppression du cache Gradle...
rmdir /s /q %USERPROFILE%\.gradle\caches\8.10.2\transforms

echo Nettoyage de Flutter...
call flutter clean

echo Récupération des dépendances...
call flutter pub get

echo Construction de l'application...
call flutter build apk --debug

echo ===== TERMINÉ =====
pause
