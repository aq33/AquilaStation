#!/bin/sh
# Ruiny pożyczone: pustynia (z białych piasków) i planeta mglista (z białych piasków i skał). Z katalogu NSV13-planety-piaski.
set -e
R=aquila/_maps/RandomRuins
mkdir -p $R/PlanetDesert $R/PlanetShrouded
SAND_GAS='o2=16;n2=21;co2=11;TEMP=248'
ROCK_GAS='co2=86;n2=17;TEMP=263'
DESERT_GAS='o2=20;n2=80;TEMP=313.15'
SHROUDED_GAS='o2=24;n2=74;co2=3;TEMP=273'
for n in camp_saloon nomads_stop e11_manufactory settlement_raid; do
	python tools/planets/retheme_map.py $R/PlanetSand/planet_sand_$n.dmm $R/PlanetDesert/planet_desert_$n.dmm \
		--path '/turf/open/floor/plating/asteroid/whitesands/dried=>/turf/open/floor/plating/asteroid/desert/dry_seafloor' \
		--path '/turf/open/floor/plating/asteroid/whitesands/grass/dead=>/turf/open/floor/plating/asteroid/desert' \
		--path '/turf/open/floor/plating/asteroid/whitesands/grass=>/turf/open/floor/plating/asteroid/desert' \
		--path '/turf/open/floor/plating/asteroid/whitesands=>/turf/open/floor/plating/asteroid/desert' \
		--path '/turf/open/floor/plating/asteroid/snow/whitesands=>/turf/open/floor/plating/asteroid/desert' \
		--path '/turf/closed/mineral/random/whitesands=>/turf/closed/mineral/random/desert' \
		--path '/turf/open/water/planet/acid=>/turf/open/water/planet/oasis' \
		--text "$SAND_GAS=>$DESERT_GAS" \
		--text '/area/ruin/unpowered/planet_sand/=>/area/ruin/unpowered/planet_desert/'
done
for n in cave_base brazillianlab; do
	python tools/planets/retheme_map.py $R/PlanetSand/planet_sand_$n.dmm $R/PlanetShrouded/planet_shrouded_$n.dmm \
		--path '/turf/open/floor/plating/asteroid/whitesands/dried=>/turf/open/floor/plating/asteroid/shrouded' \
		--path '/turf/open/floor/plating/asteroid/whitesands/grass/dead=>/turf/open/floor/plating/asteroid/shrouded' \
		--path '/turf/open/floor/plating/asteroid/whitesands/grass=>/turf/open/floor/plating/asteroid/shrouded' \
		--path '/turf/open/floor/plating/asteroid/whitesands=>/turf/open/floor/plating/asteroid/shrouded' \
		--path '/turf/open/floor/plating/asteroid/snow/whitesands=>/turf/open/floor/plating/asteroid/shrouded' \
		--path '/turf/closed/mineral/random/whitesands=>/turf/closed/mineral/random/shrouded' \
		--text "$SAND_GAS=>$SHROUDED_GAS" \
		--text '/area/ruin/unpowered/planet_sand/=>/area/ruin/unpowered/planet_shrouded/'
done
for n in rustbase; do
	python tools/planets/retheme_map.py $R/PlanetRock/planet_rock_$n.dmm $R/PlanetShrouded/planet_shrouded_$n.dmm \
		--path '/turf/open/floor/plating/asteroid/rockplanet/cracked=>/turf/open/floor/plating/asteroid/shrouded' \
		--path '/turf/open/floor/plating/asteroid/rockplanet/wet=>/turf/open/floor/plating/asteroid/shrouded' \
		--path '/turf/open/floor/plating/asteroid/rockplanet=>/turf/open/floor/plating/asteroid/shrouded' \
		--path '/turf/open/floor/plating/asteroid/snow/rockplanet=>/turf/open/floor/plating/asteroid/shrouded' \
		--path '/turf/closed/mineral/random/rockplanet=>/turf/closed/mineral/random/shrouded' \
		--path '/turf/open/water/planet/rockplanet=>/turf/open/water/planet/acid' \
		--path '/obj/structure/flora/rock/rockplanet=>/obj/structure/flora/rock/desert' \
		--path '/obj/structure/flora/rock/pile/rockplanet=>/obj/structure/flora/rock/pile/desert' \
		--path '/obj/structure/flora/grass/rockplanet/dead=>/obj/structure/flora/rock/pile/desert' \
		--text "$ROCK_GAS=>$SHROUDED_GAS" \
		--text '/area/ruin/unpowered/planet_rock/=>/area/ruin/unpowered/planet_shrouded/'
done
grep -l "whitesands\|rockplanet\|planet_sand/\|planet_rock/" $R/PlanetDesert/*.dmm $R/PlanetShrouded/*.dmm || echo "brak resztek"
