#!/usr/bin/env bash

scriptsUrl=http://ssgo.isstar.com/scripts/

echo -e "[\033[35mSmart Service Go\033[0m]"
mkdir -p /tmp/ssgo-start
cd /tmp/ssgo-start

cmds=`echo -e "
install go sdk or golang package
creat a new case
deploy to server
" | sed 's/ /_/g' | sed 's/\n/ /g'`

cmd=$1
if [ $cmd"x" = "x" ]; then
	for line in ${cmds[@]}; do
		echo -e "  \033[36m`echo $line | cut -c1`\033[0m`echo $line | cut -c2- | sed 's/_/ /g'`"
	done
	echo ""
	echo -ne "  Please choose: "
	read cmd
fi

for line in ${cmds[@]}; do
	if [[ $cmd = `echo $line | cut -c1` || $cmd = `echo $line | cut -d_ -f1` ]];then
		subcmd=`echo $line | cut -d_ -f1`
		if [ ! -e $subcmd".sh" ]; then
			echo -e "    \033[33mchecking\033[0m $scriptsUrl$subcmd.sh ..."
			if [ `curl -s -I $scriptsUrl$subcmd.sh | grep '200 OK' -c` = "0" ]; then
				echo -e "    \033[31m$scriptsUrl$subcmd.sh NOT EXISTS\033[0m"
				exit
			fi
			echo -e "  \033[33mdownloading\033[0m $subcmd.sh ..."
			curl -O $scriptsUrl$subcmd.sh
		fi
		echo -e "  >> \033[33m$subcmd $2 $3 $4 $5 $6 $7 $8 $9\033[0m"
		/usr/bin/env bash ./$subcmd.sh $2 $3 $4 $5 $6 $7 $8 $9
		break
	fi
done
