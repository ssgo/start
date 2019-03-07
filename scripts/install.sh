
#!/usr/bin/env bash

echo -e "[\033[35minstall go sdk or golang package\033[0m]"

#sdkUrl=https://dl.google.com/go/
sdkUrl=http://ssgo.isstar.com/gosdk/
modUrl=http://ssgo.isstar.com/mod/

osBitsTag=amd64
if [ `uname -a | grep _64 -c` = "0" ]; then
	osBitsTag=386
fi

if [ `uname` = "Darwin" ]; then
	osTag=darwin
elif [ `uname | cut -c1-5` = "Linux" ]; then
	osTag=linux
elif [ `uname | cut -c1-7` = "FreeBSD" ]; then
	osTag=freebsd
elif [ `uname | cut -c1-7` = "MINGW32" ]; then
	osTag=windows
fi

sdkVersions=`curl -s {$sdkUrl}list | grep $osTag | grep $osBitsTag | awk -F'.' '{print $1"."$2}' | cut -c3-`
modList=`curl -s {$modUrl}list | sed 's/.zip//g' | sed 's/org-x/org\/x/g' | sed 's/\n/ /g'`

cmd=$1
ver=$2
for sdkLastVersion in ${sdkVersions[@]}; do
	echo -e "  install \033[36msdk $sdkLastVersion\033[0m"
done

for modStr in ${modList[@]}; do
	modPath=`echo $modStr | cut -d- -f1`
	modName=`echo $modStr | cut -d- -f2`
	modVer=`echo $modStr | cut -d- -f3`
	echo -e "  install $modPath/\033[36m$modName $modVer\033[0m"
done
echo ""

if [ $cmd"x" = "x" ]; then
	echo -ne "  Please enter witch one to install: "
	read line
	cmds=($line)
	cmd=${cmds[0]}
	if [ ${#cmds[@]} -gt 1 ]; then
		ver=${cmds[1]}
	fi
fi

echo -e "  >> \033[33m$cmd $ver\033[0m"
if [ $cmd = "sdk" ]; then
	if [ $ver"x" = "x" ]; then
		ver=$sdkLastVersion
	fi

	if [ `uname` = "Darwin" ]; then
		sdkFile=go1.12.darwin-amd64.pkg
	elif [ `uname | cut -c1-5` = "Linux" ]; then
		sdkFile=go1.12.linux-$osBitsTag.tar.gz
	elif [ `uname | cut -c1-7` = "FreeBSD" ]; then
		sdkFile=go1.12.freebsd-$osBitsTag.tar.gz
	elif [ `uname | cut -c1-7` = "MINGW32" ]; then
		sdkFile=go1.12.windows-$osBitsTag.msi
	fi

	echo -e "    \033[33mdownloading\033[0m $sdkUrl$sdkFile ..."
	curl -O $sdkUrl$sdkFile

	echo -e "    \033[33minstalling\033[0m $sdkFile ..."
	if [ `uname` = "Darwin" ]; then
		open $sdkFile
	elif [ `uname | cut -c1-5` = "Linux" -o `uname | cut -c1-7` = "FreeBSD" ]; then
		tar -C /usr/local -zxf $sdkFile
		if [ `grep -c GOROOT /etc/profile` = "0" ]; then
			echo "" >> /etc/profile
			echo "export GOROOT=/usr/local/go" >> /etc/profile
			echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile
			source /etc/profile
		fi
	elif [ `uname | cut -c1-7` = "MINGW32" ]; then
		`$sdkFile`
	fi

	echo -e "    \033[32mDONE\033[0m"
else
	if [ $ver"x" = "x" ]; then
		ver=v0.0.0
	fi
	found=0
	for modStr in ${modList[@]}; do
		modPath=`echo $modStr | cut -d- -f1`
		modName=`echo $modStr | cut -d- -f2`
		modVer=`echo $modStr | cut -d- -f3`
		if [ $modName = $cmd -a $modVer = $ver ]; then
			found=1
			break
		fi		
	done

	if [ $found = "0" ]; then
		echo -e "    \033[31m$cmd $ver NOT EXISTS\033[0m"
		exit
	fi

	modFile=`echo $modPath | sed 's/\//-/g'`-$modName-$modVer.zip
	echo -e "    \033[33mchecking\033[0m $modUrl$modFile ..."
	if [ `curl -s -I $modUrl$modFile | grep '200 OK' -c` = "0" ]; then
		echo -e "    \033[31m$modUrl$modFile NOT EXISTS\033[0m"
	else
		if [ $GOPATH"x" = "x" ]; then
			GOPATH=`go env GOPATH`
		fi

		mkdir -p $GOPATH/pkg/mod/cache/download
		cd $GOPATH/pkg/mod/cache/download
		echo -e "    \033[33mdownloading\033[0m $modUrl$modFile ..."
		curl -O $modUrl$modFile
		unzip -u $modFile

		# mkdir -p $GOPATH/src/golang.org/x/
		# cd $GOPATH/src/golang.org/x/
		# echo -e "    \033[33mdownloading\033[0m https://github.com/golang/$cmd ..."
		# git clone https://github.com/golang/$cmd
		echo -e "    \033[32mDONE\033[0m"
	fi
fi
