#!/bin/bash
# AQUILA: instalacja pakietów i386 na runnerze CI.
# Runnery GitHuba pobierają pakiety z lustra azure.archive.ubuntu.com. Gdy DNS runnera nie rozwiązuje
# domen Ubuntu (awaria 11.11.2026), apt nie ściąga list i instalacja pada. Wtedy ustawiamy publiczne
# serwery DNS, w ostateczności lustro archive.ubuntu.com, i próbujemy kilka razy.
# Użycie: bash tools/ci/apt_install.sh pakiet1 pakiet2 ...
#
# Zmienna APT_DEB_CACHE (folder z actions/cache): pobrane paczki .deb zostają w nim po instalacji, a następny
# przebieg na tym samym obrazie runnera instaluje je przez dpkg bez apt-get update i pobierania (ok. 20 s na job).
# Klucz cache musi zawierać wersję obrazu: paczki i386 muszą mieć te same wersje co biblioteki amd64 z obrazu.
set -u

sudo dpkg --add-architecture i386

# Czy każdy z podanych pakietów jest zainstalowany
all_installed() {
	local pkg
	for pkg in "$@"; do
		[ "$(dpkg-query -W -f='${Status}' "$pkg" 2> /dev/null)" = "install ok installed" ] || return 1
	done
}

if [ -n "${APT_DEB_CACHE:-}" ] && ls "$APT_DEB_CACHE"/*.deb > /dev/null 2>&1; then
	# Sam sukces dpkg nie wystarcza: niepełny cache zainstalowałby tylko część pakietów
	if sudo dpkg -i "$APT_DEB_CACHE"/*.deb && all_installed "$@"; then
		echo "Zainstalowano z cache: $(ls "$APT_DEB_CACHE" | wc -l) paczek"
		exit 0
	fi
	echo "Instalacja z cache nie dała wszystkich pakietów, pobieram paczki od nowa"
	rm -f "$APT_DEB_CACHE"/*.deb
fi

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

# Puste archiwum apt przed instalacją: po niej leżą w nim dokładnie paczki tej instalacji, więc cache jest pełny
# (paczka, która leżała tam wcześniej, nie zostałaby pobrana ponownie i brakowałoby jej w cache)
sudo apt-get clean

for attempt in 1 2 3; do
	sudo apt-get update -qq || true
	if sudo apt-get install -y --no-install-recommends -o APT::Keep-Downloaded-Packages=true "$@"; then
		if [ -n "${APT_DEB_CACHE:-}" ]; then
			mkdir -p "$APT_DEB_CACHE"
			cp /var/cache/apt/archives/*.deb "$APT_DEB_CACHE"/ 2> /dev/null || true
		fi
		exit 0
	fi
	echo "Instalacja nie wyszła (próba $attempt), ponawiam za 15 s"
	sleep 15
done
exit 1
