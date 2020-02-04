#!/bin/bash
#This is an X_In_A_Row game.
#Input parameters: 1- the size of the table 2- the winning conditions

#This function counts the identical shapes which directly follow each other in a direction and returns the number of consequent shapes. The maximum number it returns is the winning condition.
#It also sets the two "occupied" variables, which tells whether the end of the road is still free to continue the row
#1 who we check
#2 3 hor and ver direction parameters
#4 starting checker value
#5 6 where we start checking from; x and y coordinates
function check {
local curx=$5
local cury=$6
checker=$4
occupied1=0
occupied2=0
h=$2
v=$3
out=0
while [ $((curx+h)) -lt $((tablesize)) -a $((curx+h)) -gt -1 -a $((cury+v)) -lt $((tablesize)) -a $((cury+v)) -gt -1 -a $out -ne 1 ]; do
	if [ ${coor[$(((cury+v)*tablesize+curx+h))]} -eq $1 ]; then
		((checker++))
		if [ $checker -eq $wincond ]; then
			return $checker
		fi
		h=$((h+$2))
		v=$((v+$3))
	else
		out=1
		if [ ${coor[$(((cury+v)*tablesize+curx+h))]} -ne 0 ]; then
			occupied1=1
		fi
	fi
done
h=$(($2*(-1)))
v=$(($3*(-1)))
out=0
if [ $checker -eq $wincond ]; then
	return $checker
fi
while [ $((curx+h)) -lt $((tablesize)) -a $((curx+h)) -gt -1 -a $((cury+v)) -lt $((tablesize)) -a $((cury+v)) -gt -1 -a $out -ne 1 ]; do
	if [ ${coor[$(((cury+v)*tablesize+curx+h))]} -eq $1 ]; then
		((checker++))
		if [ $checker -eq $wincond ]; then
			return $checker
		fi
		h=$((h-($2)))
		v=$((v-($3)))
	else
		if [ ${coor[$(((cury+v)*tablesize+curx+h))]} -ne 0 ]; then
			occupied2=1
		fi
		out=1
	fi
done
return $checker
}

#It checks whether there is already a winner and returns who it is.
#1 who we check
function wincheck {
check $1 1 0 1 $curx $cury
if [ $? -eq $2 ]; then
	return $1
fi
check $1 1 1 1 $curx $cury
if [ $? -eq $2 ]; then
	return $1
fi
check $1 0 1 1 $curx $cury
if [ $? -eq $2 ]; then
	return $1
fi
check $1 -1 1 1 $curx $cury
if [ $? -eq $2 ]; then
	return $1
fi
return 0
}

#It sets starting from a point, the point which is most probably affected by the onput shape on the other point. The input parameters determine the direction of the choice
#The so called borders inputs are there to say how far at maximum could the choosing go. It is not optimally used at this point, but could be useful in further development.
#It is also the right place, where the priority is zeroed.
#The function returns 1 if it found a point, whose priority is to be set, and return -1 if the borders stopped the search.
#1 player
#2 3 x y directions
#4 5 borders; -ne
function setcheckpoints {
tempx=$curx
tempy=$cury
while [ $tempx -ne $4 -a $tempy -ne $5 ]; do
	if [ ${coor[$((tempy*tablesize+tempx))]} -ne 0 ]; then
		tempx=$((tempx+$2))
		tempy=$((tempy+$3))
	else
		priorities[$((tempy*tablesize+tempx))]=0
		return 1
	fi
done
return -1
}
#This function raises the priority of a single point
#1 who we check
function setmath {
if [ $temp -gt 0 ]; then
	mod2=1
	if [ $temp -lt $((wincond/2)) ]; then
		mod1=0
	else
		mod1=1
	fi
	mod2=$((occupied1*4+occupied2*4+1))
	((priorities[$((tempy*tablesize+tempx))]+=$((2**((temp*5-5)+(mod1*($1-1)))/mod2))))
fi
}

#This function raises the priority of a single point, based on a single direction, counting, counting both players.
#1 who we check
#2 3 x y direction
function partset {
count 1 $2 $3
if [ $? -eq $wincond ]; then
	check 1 $2 $3 0 $tempx $tempy
	temp=$?
	setmath 1
fi
count 2 $2 $3
if [ $? -eq $wincond ]; then
	check 2 $2 $3 0 $tempx $tempy
	temp=$?
	setmath 2
fi
}

#This function counts whether in a road there is enough free space for one of the players to complete a winning condition set.
#It returns the number free or player controlled points on the road (player could be either the computer or the human)
#1 for whom we count
#2 3 x y directions
function count {
counter=1
if [ $1 -eq 1 ]; then
	border=2
else
	border=1
fi
h=$2
v=$3
out=0
while [ $((tempx+h)) -lt $tablesize -a $((tempx+h)) -gt -1 -a $((tempy+v)) -lt $tablesize -a $((tempy+v)) -gt -1 -a $out -eq 0 -a $counter -lt $wincond ]; do
	if [ ${coor[$(((tempy+v)*tablesize+tempx+h))]} -ne $border ]; then
		((h+=$2))
		((v+=$3))
		((counter++))
	else
		out=1
	fi
done
h=$(($2*(-1)))
v=$(($3*(-1)))
out=0
while [ $((tempx+h)) -lt $tablesize -a $((tempx+h)) -gt -1 -a $((tempy+v)) -lt $tablesize -a $((tempy+v)) -gt -1 -a $out -eq 0 -a $counter -lt $wincond ]; do
	if [ ${coor[$(((tempy+v)*tablesize+tempx+h))]} -ne $border ]; then
		((h-=$2))
		((v-=$3))
		((counter++))
	else
		out=1
	fi
done
return $counter
}

#This function in a single direction, chooses a point (by function call), then sets its priority based on all directions.
#Input parameters are carried on to setcheckpoints. Possible optimization.
#1 who we check
#2 3 x y mods
#4 5 borders
function fullset {
setcheckpoints $1 $2 $3 $4 $5
ok=$?
if [ $ok -eq 1 ]; then
	partset $1 1 0
	partset $1 0 1
	partset $1 1 1
	partset $1 1 -1
fi
}

#Completes all priority changes caused by a single downput shape
#1 who we check
function setpriority {
fullset $1 1 0 $tablesize -1
fullset $1 0 1 -1 $tablesize
fullset $1 1 1 $tablesize $tablesize
fullset $1 1 -1 $tablesize -1
fullset $1 -1 0 -1 -1
fullset $1 0 -1 -1 -1
fullset $1 -1 -1 -1 -1
fullset $1 -1 1 -1 $tablesize
}


#Starting main program

tablesize=${1:-30}
wincond=${2:-5}
if [ $tablesize -lt 1 ]; then
	echo "The tablesize is too small."
	exit
fi
if [ $wincond -lt 1 ]; then
	echo "Winning condition is too small."
	exit
fi
limit=$((tablesize*tablesize))
tput clear
players=0
until [ $players == "1" -o $players == "2" ]; do
read -p "Press the 1 button for 1 player game, the 2 for 2 players!" -n 1 players
tput cup 0
done

#initialize array

declare -a coor
for((i=0;i<tablesize*tablesize;i++)); do
	coor[$i]=0
done
if [ $players -eq 1 ]; then
	declare -a priorities
	for((i=0; i<tablesize*tablesize; i++)); do
		priorities[i]=0
	done
fi

#create table

tput cup 1
for((i=0;i<tablesize;i++)); do
	printf " _"
done
for((i=0;i<tablesize;i++)); do
	tput cup $((i+2))
	printf "|"
	for((ii=0;ii<tablesize;ii++)); do
		printf "_|"
	done
done

#initilize conditions

winner=0
curx=0
cury=0
turn=1

#main loop

#echo -e "\e[101m_"
i=1
while [ $winner -eq 0 ]; do
	tput cup $((cury+2)) $((curx*2+1))
	read -n 1 -s -r inp
	case $inp in
		"s")
		if [ $tablesize -ne $((cury+1)) ]; then
			cury=$((cury+1))
		fi
		;;
		"a")
		if [ $curx -ne 0 ]; then
			curx=$((curx-1))
		fi
		;;
		"w")
		if [ $cury -ne 0 ]; then
			cury=$((cury-1))
		fi
		;;
		"d")
		if [ $tablesize -ne $((curx+1)) ]; then
			curx=$((curx+1))
		fi
		;;
		"o")
		if [ ${coor[$((cury*tablesize+curx))]} -eq 0 ]; then
			((limit--))
			if [ $turn -eq 1 ]; then
				printf "X"
				coor[$((cury*tablesize+curx))]=1
				wincheck 1 $wincond
				if [ $? -eq 1 ]; then
					winner=1
				fi
				if [ $players -eq 2 ]; then
					turn=2
				else
					priorities[((cury*tablesize+curx))]=-1
				fi
			else
				printf "O"
				coor[$((cury*tablesize+curx))]=2
				turn=1
				wincheck 2 $wincond
				if [ $? -eq 2 ]; then
					winner=2
				fi
			fi
			#Computer's turn
			if [ $players -eq 1 -a $winner -eq 0 -a $limit -gt 0 ]; then
				((limit--))
				setpriority 1
				max=0
				for((i=1;i<tablesize*tablesize;i++)); do
					if [ ${priorities[$max]} -lt ${priorities[$i]} ]; then
						max=$i
					fi
				done
				coor[$max]=2
				priorities[$max]=-1
				curx=$((max-((max/tablesize)*tablesize)))
				cury=$((max/tablesize))
				setpriority 2
				tput cup $((cury+2)) $((curx*2+1))
				printf "O"
				wincheck 2 $wincond
				if [ $? -eq 2 ]; then
					winner=2
				fi
			fi
		fi
		if [ $limit -eq 0 -a $winner -eq 0 ]; then
			winner=3
		fi
		;;
	esac
done

#announce winner

tput cup $((tablesize+3))
case $winner in
	1)
	echo "Mr. X wins."
	;;
	2)
	echo "Mr. O wins."
	;;
	3)
	echo "It is a draw."
	;;
esac
