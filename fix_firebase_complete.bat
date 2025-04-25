@echo off
echo ===== CORRECTION COMPLETE FIREBASE ET GRADLE =====
cd C:\Users\safes\SeaTrace

echo Activation du mode developpeur Windows...
echo Veuillez activer le mode developpeur dans les parametres Windows si ce n'est pas deja fait.
echo Appuyez sur une touche pour continuer...
pause > nul

echo Suppression complete du cache Gradle...
rmdir /s /q "%USERPROFILE%\.gradle\caches"
rmdir /s /q "%USERPROFILE%\.gradle\daemon"
rmdir /s /q "%USERPROFILE%\.gradle\wrapper"
rmdir /s /q android\.gradle
rmdir /s /q android\app\.gradle

echo Suppression des dossiers build...
rmdir /s /q android\build
rmdir /s /q android\app\build
rmdir /s /q build

echo Nettoyage de Flutter...
call flutter clean

echo Suppression du cache pub...
call flutter pub cache clean

echo Mise a jour des packages Flutter...
call flutter pub upgrade

echo Recuperation des dependances...
call flutter pub get

echo Verification de l'installation Flutter...
call flutter doctor -v

echo Execution de flutter pub outdated pour verifier les packages...
call flutter pub outdated

echo ===== TERMINÉ =====
echo.
echo Maintenant, essayez d'executer: flutter run --debug
echo.
echo Si cela ne fonctionne toujours pas, essayez de redemarrer votre ordinateur
echo et d'executer a nouveau ce script.
pause
