#!/usr/bin/env sh

scriptsUrl=http://ssgo.isstar.com/scripts/

echo "[Smart Service Go]"
echo "  checking ${scriptsUrl}start.sh ..."
if [ `curl -s -I ${scriptsUrl}start.sh | grep '200 OK' -c` = "0" ]; then
	echo "    \033[31m${scriptsUrl}start.sh NOT EXISTS"
	exit
fi
echo "  downloading ${scriptsUrl}start.sh ..."
curl ${scriptsUrl}start.sh > /usr/local/bin/ssgo
chmod +x /usr/local/bin/ssgo
echo ""

echo "Usage:"
echo "  ssgo"
echo "  ssgo i sdk"
echo "  ssgo install sdk"
echo "  ssgo i net"
echo "  ssgo i text"
echo ""
