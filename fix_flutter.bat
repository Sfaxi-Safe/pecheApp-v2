@echo off
cd C:\Users\safes\SeaTrace
echo Cleaning Flutter project...
call flutter clean
echo Getting dependencies...
call flutter pub get
echo Building Android app...
call flutter build apk --debug
echo Done!
pause
