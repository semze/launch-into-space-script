@echo off
title Mini Adventure Game
color 0a
cls

echo Welcome to the Mini Adventure Game!
echo -----------------------------------
echo You find yourself in a dark room with two doors.
echo Choose wisely, adventurer!
echo.

:choice
echo What do you want to do?
echo 1. Open the door to your left.
echo 2. Open the door to your right.
echo 3. Sit down and cry.
set /p choice=Enter your choice (1, 2, or 3): 

if "%choice%"=="1" goto left
if "%choice%"=="2" goto right
if "%choice%"=="3" goto cry
echo Invalid choice. Try again.
goto choice

:left
cls
echo You open the door to your left and find a treasure chest!
echo Inside is a pile of gold coins and a strange-looking key.
echo Congratulations, adventurer! You are rich!
pause
exit

:right
cls
echo You open the door to your right and encounter a sleeping dragon!
echo The dragon wakes up, looks at you, and... sneezes fire!
echo You barely escape with your life. Better luck next time!
pause
exit

:cry
cls
echo You sit down and cry. Suddenly, a secret trapdoor opens beneath you!
echo You fall into a room filled with treasure. Your tears saved the day!
pause
exit
