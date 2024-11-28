#add to /etc/snmp/snmpd.conf: extend systemd-name /usr/bin/sh -c "(/bin/systemctl is-active name.service || exit 2)"
/usr/bin/sh -c "(/bin/systemctl is-active name.service || exit 2)"
