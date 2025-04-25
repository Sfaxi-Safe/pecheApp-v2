@echo off
echo ===== NETTOYAGE COMPLET DU CACHE GRADLE =====
cd C:\Users\safes\SeaTrace

echo Suppression du cache Gradle...
rmdir /s /q "%USERPROFILE%\.gradle\caches"
rmdir /s /q "%USERPROFILE%\.gradle\daemon"
rmdir /s /q "%USERPROFILE%\.gradle\wrapper"

echo Suppression des dossiers build...
rmdir /s /q android\build
rmdir /s /q android\app\build
rmdir /s /q build

echo Nettoyage de Flutter...
call flutter clean

echo Modification du fichier settings.gradle.kts...
echo Veuillez patienter...

echo Récupération des dépendances...
call flutter pub get

echo Exécution de flutter doctor...
call flutter doctor -v

echo ===== TERMINÉ =====
echo Maintenant, essayez d'exécuter: flutter run --debug
pause
