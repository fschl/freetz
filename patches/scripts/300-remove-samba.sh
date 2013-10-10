
# if nas, mediaserv und samba are removed -> remove_nas deletes menu item Heimnetz > Speicher (NAS)  

if [ "$FREETZ_AVM_HAS_USB_HOST" == "y" -a "$FREETZ_PACKAGE_SAMBA_SMBD" == "y" ]; then
	sed -i -e "/killall smbd*$/d" -e "s/pidof smbd/pidof/g" "${FILESYSTEM_MOD_DIR}/etc/hotplug/storage"
fi

if [ "$FREETZ_PACKAGE_SAMBA_SMBD" == "y" -o "$FREETZ_REMOVE_SAMBA" == "y" ]; then
	echo1 "remove AVM samba config"
	rm_files \
	  "${FILESYSTEM_MOD_DIR}/bin/inetdsamba" \
	  "${FILESYSTEM_MOD_DIR}/sbin/samba_config_gen" \
	  "${FILESYSTEM_MOD_DIR}/etc/samba_config.tar"

	echo1 "patching rc.net: renaming sambastart()"
	modsed 's/^\(sambastart *()\)/\1{ return; }\n_\1/' "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.net"
		
	# patcht Heimnetz > Speicher (NAS)
	sedfile="${HTML_LANG_MOD_DIR}/storage/settings.lua"
	if [ -e "$sedfile" ]; then
		echo1 "patching ${sedfile##*/}"
		sedrows=$(cat $sedfile |nl| sed -n 's/^ *\([0-9]*\).*<div id="page_bottom">.*$/\1/p')
		sedrowe=$(cat $sedfile |nl| sed -n 's/^ *\([0-9]*\).*<div id="btn_form_foot">.*$/\1/p')
		modsed "$((sedrows)),$((sedrowe-1))d" $sedfile
	fi
	
	echo1 "patching rc.conf"
	modsed "s/CONFIG_SAMBA=.*$/CONFIG_SAMBA=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
fi


if [ "$FREETZ_REMOVE_SAMBA" == "y" ] || \
  [ "$FREETZ_PACKAGE_SAMBA_SMBD" == "y" -a "$FREETZ_PACKAGE_SAMBA_NMBD" != "y" ]; then
	echo1 "remove AVM's nmbd"
	rm_files "${FILESYSTEM_MOD_DIR}/sbin/nmbd"
fi

if [ "$FREETZ_REMOVE_SAMBA" == "y" ]; then
	echo1 "remove AVM samba files"
	rm_files \
	  "${FILESYSTEM_MOD_DIR}/etc/samba_control" \
	  "${FILESYSTEM_MOD_DIR}/sbin/smbd" \
	  "${FILESYSTEM_MOD_DIR}/sbin/smbpasswd"
fi