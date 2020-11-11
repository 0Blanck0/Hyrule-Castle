#!/bin/bash

clear

echo -e "Choose your game mode"
echo -ne "\n"
echo "---------------------Options---------------------"
echo "1. Basic  |  2. Dynamic Player | 3. Level and XP"
echo -ne "\n"

read player_action

if [[ ($player_action == Basic) || ($player_action == basic) ]]; then
    player_action=1
elif [[ ($player_action == "dynamic player") || ($player_action == dynamic) || ($player_action == "Dynamic player") || ($player_action == Dynamic) || ($player_action == "Dynamic Player")]]; then
    player_action=2
fi

clear

if [[ $player_action == 1 ]]; then
    cd HyruleGame/base_game/
    echo "Basic game load..."
    sleep 2
elif [[ $player_action == 2 ]]; then
    cd HyruleGame/dynamic_characters/
    echo "Dynamic mode load..."
    sleep 2
else
    cd HyruleGame/level_and_experience/
    echo "Level mode load..."
    sleep 2
fi

source hyrule_castle.sh
