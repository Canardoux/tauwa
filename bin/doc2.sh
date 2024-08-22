#!/bin/bash

echo "**** doc2.sh *****"
rm -rf /var/www/canardoux.xyz/tau/doc /var/www/canardoux.xyz/tau/live 2>/dev/null
mkdir -v /var/www/canardoux.xyz/tau/doc 2>/tmp/null
mkdir -v /var/www/canardoux.xyz/tau/live 2>/tmp/null
tar xvzf _toto.tgz   -C /var/www/canardoux.xyz/tau/doc 
tar xvzf _toto3.tgz  -C /var/www/canardoux.xyz/tau/live
tar xvzf _toto2.tgz  -C /var/www/canardoux.xyz/tau/live 
echo "***** end of doc2.sh ******"
rm _toto.tgz _toto3.tgz _toto2.tgz doc2.sh