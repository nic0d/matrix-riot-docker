#!/usr/bin/env sh

OPTION="${1}"

case $OPTION in
	"start")
	echo "-=> starting riot.im client"
	(
		if [ -f /data/config.json ]; then
			echo "-=> riot.im config file found, ... rebuild sources"
			cp /data/config.json /riot-web/webapp/config.json

			cd /riot-web
			npm run build
		fi

		CONFFILENAME="/data/riot.im.conf"

		if [ -f /data/vector.im.conf ] && [ ! -f ${CONFFILENAME} ]; then
			echo "please rename your conffile \"/data/vector.im.conf\" to \"${CONFFILENAME}\""
			CONFFILENAME=/data/vector.im.conf
		fi


		if [ -f ${CONFFILENAME} ]; then
			options=""

			while read -r line; do
				[ "${line:0:1}" == "#" ] && continue
				[ "${line:0:1}" == " " ] && continue
				options="${options} ${line}"
			done < ${CONFFILENAME}

			cd /riot-web/webapp
			echo "-=> riot.im options: http-server ${options}"
			http-server ${options}
		else
			echo "You need a conffile /data/riot.im.conf in you conf folder"
			exit 1
		fi
	)
	;;

	"generate")
		breakup="0"
		[[ -z "${SERVER_NAME}" ]] && echo "STOP! environment variable SERVER_NAME must be set" && breakup="1"
		[[ "${breakup}" == "1" ]] && exit 1

		echo "-=> generate riot.im server config"
		echo "# change this option to your needs" >> /data/riot.im.conf
		echo "-p 8080" > /data/riot.im.conf
		echo "-a 0.0.0.0" >> /data/riot.im.conf
		echo "-c 3500" >> /data/riot.im.conf
		echo "--ssl" >> /data/riot.im.conf
		echo "--cert /data/${SERVER_NAME}.tls.crt" >> /data/riot.im.conf
		echo "--key /data/${SERVER_NAME}.tls.key" >> /data/riot.im.conf

		echo "-=> you can now review the generated configuration file riot.im.conf"
		;;
	*)
		echo "-=> unknown \'$OPTION\'"
		;;
esac
