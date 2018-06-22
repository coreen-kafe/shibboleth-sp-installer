#!/bin/bash

SCRIPTDIR=$(dirname "$0")
DATE=$( date +%d-%m-%y )

###################################
#
# Carefully configure the below
#
###################################
CONNECTOR="AJP"
DOMAINNAME="1.7.1.4"
DISCOVERY="EDS"

###################################
#
# Check environment
#
###################################

# Check if root
if ! [ $(id -u) = 0 ]; then
   echo "You need root permissions to run this."
   exit 1
fi

# Check if yum installed
if ! [ $( which yum ) ]; then
   echo "Yum Package Manager not found. Weird."
   exit 1
fi

# Is this CentOS 6?
if ! [ -f "/etc/centos-release" ]; then
    echo "Warning: This seems not to be a CentOS environment."
else
    CENTOS_VER=$( grep -o "release [0-9]*" "/etc/centos-release"| grep -o "[0-9]*" )
    if ! [ $CENTOS_VER = 6 ]; then
        echo "Warning: This scripts is meant to be used with CentOs version 6."
        echo "This seems to be CentOs version $CENTOS_VER."
    fi
fi


###################################
#
# Set up OS, install basics
#
###################################

# Clean all cached metadata. Update the repos & packages
yum clean metadata
yum clean all
yum check-update
yum update

# Install needed packages
yum -y install \
    httpd \
    php \
    wget \
    yum-plugin-priorities \
    deltarpm \
    curl \
    git


###################################
#
# Set up Shibboleth
#
###################################

# Set up repository
sudo curl -o /etc/yum.repos.d/security:shibboleth.repo  http://download.opensuse.org/repositories/security:/shibboleth/CentOS_CentOS-6/security:shibboleth.repo

# Install shibboleth
yum -y install shibboleth.x86_64


# Shibboleth is using some custom versions of a couple of
# libraries. Make sure they get used.
if ( shibd -t | grep "libcurl lacks OpenSSL-specific options" )
then
    echo "Include Shibboleth's custom libraries."
    echo "/opt/shibboleth/lib64" | tee "/etc/ld.so.conf.d/opt-shibboleth.conf"
    ldconfig

    shibd -t | grep "libcurl lacks OpenSSL-specific options" \
        && echo "Including libraries failed. Continuing anyway."
fi

openssl req -newkey rsa:4096 -sha256 -new -x509 -days 3650 -nodes -text -out shibsp.crt -keyout shibsp.key
chmod 644 shibsp.*
mv shibsp.* /etc/shibboleth


cp $(pwd)/conf/shibboleth2.xml $(pwd)/conf/shibboleth2.xml.back

if [ "$CONNECTOR" != "AJP" ]
then
    sed -i 's/attributePrefix=\"AJP_\"//g' $(pwd)/conf/shibboleth2.xml.back
fi 

sed -i "s/sp.example.org/$DOMAINNAME/g" $(pwd)/conf/shibboleth2.xml.back

wget https://fedinfo.kreonet.net/cert/kafe-fed.crt
mv kafe-fed.crt /etc/shibboleth

if [ "$DISCOVERY" == "EDS" ]
then
    sed -i "s|https://ds.kreonet.net/kafe|https://$DOMAINNAME/shibboleth-ds/index.html|g" $SCRIPTDIR/conf/shibboleth2.xml.back

    wget https://shibboleth.net/downloads/embedded-discovery-service/1.2.0/shibboleth-embedded-ds-1.2.0.tar.gz -O shibboleth-eds.tar.gz
    tar xzf shibboleth-eds.tar.gz
    cd ./shibboleth-embedded-ds-1.2.0
    make
    make install
    if grep -q 'shibboleth-ds' /etc/httpd/conf/httpd.conf 
    then
	echo "Found existing one"
    else
        cat shibboleth-ds.conf >> /etc/httpd/conf/httpd.conf
    fi
    cd ..
    rm -rf shibboleth-eds.tar.gz shibboleth-embedded-ds-1.2.0
fi

# Create a backup of the config files we will change
cp "/etc/shibboleth/shibboleth2.xml" "/etc/shibboleth/shibboleth2.backup-$DATE.xml"
cp "/etc/shibboleth/attribute-map.xml" "/etc/shibboleth/attribute-map.xml.backup-$DATE.xml"

# Overwrite the config files with our settings
mv "$SCRIPTDIR/conf/shibboleth2.xml.back"  "/etc/shibboleth/shibboleth2.xml"
cp "$SCRIPTDIR/conf/attribute-map.xml"  "/etc/shibboleth/attribute-map.xml"


###################################
#
# Set up SSL for Apache
#
###################################

# Install Apache's mod_ssl
yum -y install mod_ssl openssl


# Make a test folter
mkdir -p "/var/www/html/secure"
cp html/main.php /var/www/html/index.php
cp html/sub.php /var/www/html/secure/index.php

###################################
#
# Restart the services
#
###################################

# Start the services
service httpd restart
service shibd restart

# Set up daemons so they start on reboot
chkconfig httpd on
chkconfig shibd on
