#!/bin/bash
# AQUILA: instalacja pakietów i386 na runnerze CI.
# Runnery GitHuba pobierają pakiety z lustra azure.archive.ubuntu.com. Gdy DNS runnera nie rozwiązuje
# domen Ubuntu (awaria 11.11.2026), apt nie ściąga list i instalacja pada. Wtedy ustawiamy publiczne
# serwery DNS, w ostateczności lustro archive.ubuntu.com, i próbujemy kilka razy.
# Użycie: bash tools/ci/apt_install.sh pakiet1 pakiet2 ...
set -u

sudo dpkg --add-architecture i386

# DNS runnera bywa zepsuty tylko dla domen Ubuntu (pobrania z GitHuba działają): najpierw publiczne serwery DNS
if ! getent hosts azure.archive.ubuntu.com > /dev/null; then
	echo "azure.archive.ubuntu.com się nie rozwiązuje, ustawiam DNS 1.1.1.1 i 8.8.8.8"
	iface=$(ip route | awk '/^default/ {print $5; exit}')
	if [ -n "$iface" ]; then
		sudo resolvectl dns "$iface" 1.1.1.1 8.8.8.8 || true
		sudo resolvectl flush-caches || true
	fi
	sleep 2
fi

if ! getent hosts azure.archive.ubuntu.com > /dev/null; then
	echo "azure.archive.ubuntu.com dalej się nie rozwiązuje, przełączam apt na archive.ubuntu.com"
	for f in /etc/apt/apt-mirrors.txt /etc/apt/sources.list /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources; do
		[ -f "$f" ] && sudo sed -i 's|azure\.archive\.ubuntu\.com|archive.ubuntu.com|g' "$f"
	done
fi

for attempt in 1 2 3; do
	sudo apt-get update -qq || true
	if sudo apt-get install -y --no-install-recommends "$@"; then
		exit 0
	fi
	echo "Instalacja nie wyszła (próba $attempt), ponawiam za 15 s"
	sleep 15
done
exit 1
