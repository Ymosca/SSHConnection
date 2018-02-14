#!/bin/bash
###
### recupere ladresse ip de la machine
###
###(?!127) permet de de pas prendre le réseau local 127.0.0
adresses=$(ip -f inet addr | grep -Po 'inet \K(?!127)[\d.]+')
choix1=$(echo $adresses | cut -d ' ' -f 1)
choix2=$(echo $adresses | cut -d ' ' -f 2)
###
### Si une seule interface dispo alors les deux cut indique la meme @ip
###
if [ "$choix1" = "$choix2" ];then
	echo "Seul réseau dispo: "$choix1
	adresseIp=$choix1
else
	echo "Les réseaux disponibles sont ceux de "$choix1" ou "$choix2
	echo -n "Veuillez indiquer sur quel réseau travailler 1 ou 2: "
	read -r
        if [ "$REPLY" = "1" ];then
                adresseIp=$choix1
        elif [ "$REPLY" = "2" ];then
                adresseIp=$choix2
	else
		echo $1ou2" n'est pas accepté.Veuillez indiquer seulement 1 ou 2"
	fi
fi

###
### recupere le reseau local
###
reseauLocal=`echo $adresseIp | cut -d . -f 1-3`.0
echo "Le réseau local est "$reseauLocal
echo "Scan du réseau local..."
###
###scan les ports ssh ouvert uniquement et affiche les hostnames+Ip@
###
#nmap -p22 --open $reseauLocal/24 | grep -Po for \K.* &
scan=$(nmap -p22 --open $reseauLocal/24 | grep -Po 'for \K.*')
spinner()
{
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}
echo "La liste des machines dispos: "$scan
machines=$(echo $scan |  wc -w)
echo "Le nombre de machines disponibles sur le réseau est de "$(($machines/2))
###
###animation de chargement
###
#spinner $!
echo -n "Souhaitez vous travailler avec toutes les machines Y/N ?"
read -r
if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ] || [ "$REPLY" = "yes" ] || [ "$REPLY" = "YES" ] || [ "$REPLY" = "ye" ] || [ "$REPLY" = "YE" ]
then
	###effectuer les connexions ssh
elsif [ "$REPLY" = "n" ] || [ "$REPLY" = "N" ] || [ "$REPLY" = "no" ] || [ "$REPLY" = "NO" ]
then
	echo " :( "
else
	echo "Indiquez Y ou N ou même à la limite yes ou no"
