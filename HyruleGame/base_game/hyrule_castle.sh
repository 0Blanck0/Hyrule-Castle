#!/bin/bash

#Déclaration des variables global de base
basic_heal=0
heal=$basic_heal
strength=0
mob_basic_heal=0
mob_heal=$mob_basic_heal
mob_strength=0
fight_count=1
mob_name=""
player_name=""
loop_game=1
win=0

csv_player=players.csv
csv_mob=enemies.csv

#Déclaration de la fonction de mise a jour des variables
#Cette fonction va mettre a jours les varibles des monstres et du joueur
#Cette fonction prend un argument servant a définir le stade du jeu
function Set_var {

    if [[ $1 == 3 ]]; then
	csv_mob=bosses.csv
	f=1
    else
	csv_mod=enemies.csv
	f=12
    fi
	
    
    while IFS="," read -r id name hp mp str int def res spd luck race class rarity
    do
	
	if [[ ($id == 1) && ($1 == 1) ]]; then
	    basic_heal=$hp
	    heal=$basic_heal
	    strength=$str
	    player_name=$name
	fi
	
    done < $csv_player
    
    while IFS="," read -r id name hp mp str int def res spd luck race class rarity
    do
	    
        if [[ $id == $f ]]; then
	    mob_basic_heal=$hp
	    mob_heal=$mob_basic_heal
	    mob_strength=$str
	    mob_name=$name
        fi
	
    done < $csv_mob
        
}

function Reset_Mob {

    mob_hea=$mob_basic_heal

}

#Déclaration de la fonction d'affichage des HP en combat
#Cette fonction clear l'écran et affiche les bar de vie du monstre et du joueur avec le numéro de l'étage
#Cette fonction prend prend plusieurs arguments
#le $1 correspond au nom de l'ennemi
#le $2 correspond au nom du personnage
#le $3 correspond au booleen de l'affichage des options proposer par le jeu
function Display_HP_Fight {
    
    clear

    echo -e "\e[39m=========== \e[4mFIGHT $fight_count\e[24m ==========="
    echo -e "\e[31m$1"
    echo -ne "\e[39mHP: "

    i=0
    symb="♡"
    
    while [[ $i -lt $mob_basic_heal ]]; do

	if [[ $i -lt $mob_heal ]]; then
	    echo -ne "$symb"
	else
	    echo -ne "_"
	fi
	i=$((i+1))
    done

    echo -ne "   $mob_heal/$mob_basic_heal"

    echo -ne '\n\n'

    echo -e "\e[32m$2"
    echo -ne "\e[39mHP: "

    i=0

    while [[ $i -lt $basic_heal ]]; do

	if [[ $i -lt $heal ]]; then
	    echo -ne "$symb"
	else
	    echo -ne "_"
	fi
	i=$((i+1))
    done
    
    echo -ne "   $heal/$basic_heal"

    echo -ne '\n\n'

    if [[ $3 == 1 ]]; then
	echo "--------Options--------"
	echo "1. Attack  |  2. Heal"
	echo -ne "\n"
    fi
    
}

#Déclaration de la fonction d'affichage des messages de combat
#Cette fonction sert a afficher les différentes phrase possible dans les combat et a la fin des combats
#Cette fonction prend un argument servant a définir la phrase a afficher
function Display_text_fight {

    case $1 in
	-attack)
	    echo -ne "\n"
	    echo -e "You attacked and dealt $strength domages !"
	    ;;
	-domages)
	    echo -ne "\n"
	    echo -e "Enemy attacked and dealt $mob_strength domages !"
	    ;;
	-heal)
	    echo -ne "\n"
	    echo -e "You used heal !"
	    ;;
	-encounter)
	    echo -ne "\n"
            echo -e "You encounter a $mob_name"
	    ;;
	-mobKill)
	    echo -ne "\n"
	    echo -e "$mob_name has been killed"
	    ;;
    esac

}

#Déclaration de la fonction de modification des HP en combat
#Cette fonction va mettre a jours les HP du joueur et du monstre
#Cette fonction prend un argument servant a définir quelle entiter mettre a jour et si il doit augmenter ou diminuer les HP
function Fight_HP_Editor {
    
    case $1 in
	-attack)
	    mob_heal=$((mob_heal-$strength))
	    ;;
	-domages)
	    heal=$((heal-$mob_strength))
	    ;;
	-heal)
	    heal=$basic_heal
	    ;;
    esac

}

#Déclaration de la fonction qui gère les combats
#Cette fonction va gérer les combats et faire le lien entre les différentes fonction d'affichage de combat
#Cette fonction ne prend pas d'arguments
function Run_fight {

    loop=1
    fight_loop=1
    win=0

    Display_HP_Fight $mob_name $player_name 0
    Display_text_fight -encounter
    
    sleep 3

    while [[ $fight_loop -eq 1 ]]; do
    
	while [[ $loop -eq 1 ]]; do
	    
	    Display_HP_Fight $mob_name $player_name 1

	    #Vider le buffer
	    if test -t 0; then
		while read -t 0 notused; do
		    read input
		done
	    fi
	    
	    read player_action

	    if [[ ($player_action == Attack) || ($player_action == attack) ]]; then
		player_action=1
	    elif [[ ($player_action == Heal) || ($player_action == heal) ]]; then
		player_action=2
	    elif [[ $player_action == OverPower ]]; then
		 mob_heal=1
		 player_action=1
	    fi
	    
	    if [[ $player_action -eq 1 ]]; then
		Fight_HP_Editor -attack
		Display_HP_Fight $mob_name $player_name 1
		Display_text_fight -attack
		loop=0
		sleep 3
	    elif [[ $player_action -eq 2 ]]; then
		Fight_HP_Editor -heal
		Display_HP_Fight $mob_name $player_name 1
		Display_text_fight -heal
		loop=0
		sleep 3
	    fi
	    
	done

	if [[ $mob_heal -le 0 ]]; then
	    fight_loop=0
	    win=1
	    Display_HP_Fight $mob_name $player_name 1
	    Display_text_fight -mobKill
	    sleep 3
	else
	    loop=1
            Fight_HP_Editor -domages
	    Display_HP_Fight $mob_name $player_name 1
	    Display_text_fight -domages
	    sleep 3
	fi

	if [[ $heal -le 0 ]]; then
	    fight_loop=0
	    game_loop=0
	    Player_lose
	fi	   
    done
}

#Déclaration de la fonction perte du joueur
#Cette fonction va afficher un message de GameOver si le joueur perd
#Cette fonction ne prend pas d'argument
function Player_lose {

    clear

    win=2

    echo "
      ___           ___           ___           ___                    ___           ___           ___           ___     
     /\  \         /\  \         /\__\         /\  \                  /\  \         /\__\         /\  \         /\  \    
    /::\  \       /::\  \       /::|  |       /::\  \                /::\  \       /:/  /        /::\  \       /::\  \   
   /:/\:\  \     /:/\:\  \     /:|:|  |      /:/\:\  \              /:/\:\  \     /:/  /        /:/\:\  \     /:/\:\  \  
  /:/  \:\  \   /::\~\:\  \   /:/|:|__|__   /::\~\:\  \            /:/  \:\  \   /:/__/  ___   /::\~\:\  \   /::\~\:\  \ 
 /:/__/_\:\__\ /:/\:\ \:\__\ /:/ |::::\__\ /:/\:\ \:\__\          /:/__/ \:\__\  |:|  | /\__\ /:/\:\ \:\__\ /:/\:\ \:\__\
"	       

    echo " \:\  /\ \/__/ \/__\:\/:/  / \/__/~~/:/  / \:\~\:\ \/__/          \:\  \ /:/  /  |:|  |/:/  / \:\~\:\ \/__/ \/_|::\/:/  /
  \:\ \:\__\        \::/  /        /:/  /   \:\ \:\__\             \:\  /:/  /   |:|__/:/  /   \:\ \:\__\      |:|::/  / 
   \:\/:/  /        /:/  /        /:/  /     \:\ \/__/              \:\/:/  /     \::::/__/     \:\ \/__/      |:|\/__/  
    \::/  /        /:/  /        /:/  /       \:\__\                 \::/  /       ~~~~          \:\__\        |:|  |    
     \/__/         \/__/         \/__/         \/__/                  \/__/                       \/__/         \|__|    

"

    sleep 10
    
    clear

}

#Déclaration de la fonction victoire du joueur
#Cette fonction va afficher un message de Victory si le joueur gagne
#Cette fonction ne prend pas d'argument
function Player_win {

    clear

    echo "
 __     __             ____   _____   U  ___ u   ____     __   __ 
 \ \   / /u  ___    U / ___| |_   _|   \/ _ \/U |  _ \ u  \ \ / / 
  \ \ / //  |_ _|   \| | u     | |     | | | | \| |_) |/   \ V /  
  /\ V /_,-. | |     | |/__   /| |\.-,_| |_| |  |  _ <    U_| |_u 
 U  \_/-(_/U/| |\u    \____| u |_|U \_)-\___/   |_| \_\     |_|   
   //   .-,_|___|_,-._// \\  _// \\_     \\     //   \\_.-,//|(_  
  (__)   \_)-' '-(_/(__)(__)(__) (__)   (__)   (__)  (__)\_) (__)

"

    sleep 5

    clear
    
}

#Cette partie du code sert a lancer la partie après que toutes les variables est été déclarer

Set_var 1

while [[ ($fight_count -ne 11) && ($win -ne 2) ]]; do


    if [[ $fight_count == 10 ]]; then
	Set_var 3
	Run_fight
	Player_win
    else
	Run_fight
	Set_var 2
    fi

    fight_count=$((fight_count+1))
    
done
