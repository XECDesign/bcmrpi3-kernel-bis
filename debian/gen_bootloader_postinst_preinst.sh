#!/bin/sh

if ! [ -d ../boot ]; then
  printf "Can't find boot dir. Run from debian subdir\n"
  exit 1
fi

version=`ls ../lib/modules/ | head -n1`

printf "#!/bin/sh\n" > bcmrpi3-kernel-bis.postinst
printf "#!/bin/sh\n" > bcmrpi3-kernel-bis.preinst

printf "mkdir -p /usr/share/rpikernelhack/overlays\n" >> bcmrpi3-kernel-bis.preinst
printf "mkdir -p /boot/overlays\n" >> bcmrpi3-kernel-bis.preinst

for FN in ../boot/COPYING.linux ../boot/*.map ../boot/*.dtb ../boot/config ../boot/kernel*.img ../boot/overlays/*; do
  if ! [ -d "$FN" ]; then
    FN=${FN#../boot/}
    printf "if [ -f /usr/share/rpikernelhack/$FN ]; then\n" >> bcmrpi3-kernel-bis.postinst
    printf "	rm -f /boot/$FN\n" >> bcmrpi3-kernel-bis.postinst
    printf "	dpkg-divert --package rpikernelhack --remove --rename /boot/$FN\n" >> bcmrpi3-kernel-bis.postinst
    printf "	sync\n" >> bcmrpi3-kernel-bis.postinst
    printf "fi\n" >> bcmrpi3-kernel-bis.postinst

    printf "dpkg-divert --package rpikernelhack --divert /usr/share/rpikernelhack/$FN /boot/$FN\n" >> bcmrpi3-kernel-bis.preinst
  fi
done

cat <<EOF >> bcmrpi3-kernel-bis.preinst
INITRD=\${INITRD:-"No"}
export INITRD
if [ -d "/etc/kernel/preinst.d" ]; then
  run-parts -v --report --exit-on-error --arg=${version} --arg=/boot/kernel8.img /etc/kernel/preinst.d
fi
if [ -d "/etc/kernel/preinst.d/${version}" ]; then
  run-parts -v --report --exit-on-error --arg=${version} --arg=/boot/kernel8.img /etc/kernel/preinst.d/${version}
fi
EOF

cat <<EOF >> bcmrpi3-kernel-bis.postinst
INITRD=\${INITRD:-"No"}
export INITRD
if [ -d "/etc/kernel/postinst.d" ]; then
  run-parts -v --report --exit-on-error --arg=${version} --arg=/boot/kernel8.img /etc/kernel/postinst.d
fi
if [ -d "/etc/kernel/postinst.d/${version}" ]; then
  run-parts -v --report --exit-on-error --arg=${version} --arg=/boot/kernel8.img /etc/kernel/postinst.d/${version}
fi
EOF

printf "#DEBHELPER#\n" >> bcmrpi3-kernel-bis.postinst
printf "#DEBHELPER#\n" >> bcmrpi3-kernel-bis.preinst

printf "#!/bin/sh\n" > bcmrpi3-kernel-bis.prerm
printf "#!/bin/sh\n" > bcmrpi3-kernel-bis.postrm

cat <<EOF >> bcmrpi3-kernel-bis.prerm
INITRD=\${INITRD:-"No"}
export INITRD
if [ -d "/etc/kernel/prerm.d" ]; then
  run-parts -v --report --exit-on-error --arg=${version} --arg=/boot/kernel8.img /etc/kernel/prerm.d
fi
if [ -d "/etc/kernel/prerm.d/${version}" ]; then
  run-parts -v --report --exit-on-error --arg=${version} --arg=/boot/kernel8.img /etc/kernel/prerm.d/${version}
fi
EOF

cat <<EOF >> bcmrpi3-kernel-bis.postrm
INITRD=\${INITRD:-"No"}
export INITRD
if [ -d "/etc/kernel/postrm.d" ]; then
  run-parts -v --report --exit-on-error --arg=${version} --arg=/boot/kernel8.img /etc/kernel/postrm.d
fi
if [ -d "/etc/kernel/postrm.d/${version}" ]; then
  run-parts -v --report --exit-on-error --arg=${version} --arg=/boot/kernel8.img /etc/kernel/postrm.d/${version}
fi
EOF

printf "#DEBHELPER#\n" >> bcmrpi3-kernel-bis.prerm
printf "#DEBHELPER#\n" >> bcmrpi3-kernel-bis.postrm
