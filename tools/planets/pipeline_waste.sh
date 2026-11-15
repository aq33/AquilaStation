#!/bin/sh
# Ruiny planety-śmietniska i pola bitwy z Shiptesta: konwersja, kable, domknięcie instalacji, sprawdzenie.
# Uruchom z katalogu repo: sh tools/planets/pipeline_waste.sh <folder Shiptesta>
set -e
ST=${1:?podaj folder Shiptesta}
W=$ST/_maps/RandomRuins/WasteRuins
WASTE=aquila/_maps/RandomRuins/PlanetWaste
BATTLE=aquila/_maps/RandomRuins/PlanetBattlefield
python tools/planets/convert_maps.py --mappings waste --out $WASTE \
	$W/wasteplanet_facility.dmm=planet_waste_facility $W/wasteplanet_icwbase.dmm=planet_waste_icwbase \
	$W/wasteplanet_recyclebay.dmm=planet_waste_recyclebay $W/wasteplanet_smugglerbunker.dmm=planet_waste_smugglerbunker \
	$W/wasteplanet_tradepost.dmm=planet_waste_tradepost $W/wasteplanet_yard.dmm=planet_waste_yard
python tools/planets/convert_maps.py --mappings battlefield --out $BATTLE \
	$W/wasteplanet_icwbase.dmm=planet_battlefield_icwbase $W/wasteplanet_smugglerbunker.dmm=planet_battlefield_smugglerbunker \
	$W/wasteplanet_yard.dmm=planet_battlefield_yard
python tools/smartwires/convert.py . --only PlanetWaste PlanetBattlefield
python tools/planets/prune_pipes_waste.py $WASTE/*.dmm $BATTLE/*.dmm
python tools/ci/check_map_connections.py $WASTE/*.dmm $BATTLE/*.dmm
