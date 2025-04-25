@echo off
cd C:\Users\safes\SeaTrace
echo Nettoyage du cache Gradle...
cd android
call gradlew clean
cd ..
echo Nettoyage de Flutter...
call flutter clean
echo Récupération des dépendances...
call flutter pub get
echo Construction de l'application...
call flutter build apk --debug
echo Terminé !
pause
