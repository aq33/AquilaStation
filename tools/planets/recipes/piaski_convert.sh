#!/bin/sh
# Konwersja ruin i greebli planet skalistych i białych piasków z Shiptesta (partia „piaski” PR aq33/AquilaStation#639).
# Z katalogu repo: SHIPTEST=<klon Shiptesta> MSYS_NO_PATHCONV=1 sh tools/planets/recipes/piaski_convert.sh
# Kolejność: konwersja (convert_maps.py + mappings/piaski.py), kable (smartwires), naprawa instalacji (prune_pipes.py),
# warianty pożyczone przez pustynię i planetę mglistą (piaski_retheme.sh), kontrola instalacji jak w CI.
set -e
: "${SHIPTEST:?ustaw SHIPTEST na folder klonu Shiptesta}"
R=aquila/_maps/RandomRuins
OUT=tools/planets/.out/piaski_convert
rm -rf "$OUT"
ARGS=""
for f in "$SHIPTEST"/_maps/RandomRuins/RockRuins/*.dmm; do
	n=$(basename "$f" .dmm)
	ARGS="$ARGS $f=planet_rock_${n#rockplanet_}"
done
for f in "$SHIPTEST"/_maps/RandomRuins/SandRuins/*.dmm; do
	n=$(basename "$f" .dmm)
	n=${n#whitesands_surface_}
	n=${n#whitesands_}
	ARGS="$ARGS $f=planet_sand_$n"
done
python tools/planets/convert_maps.py --out "$OUT" --mappings piaski $ARGS
mkdir -p $R/PlanetRock $R/PlanetSand
cp "$OUT"/planet_rock_*.dmm $R/PlanetRock/
cp "$OUT"/planet_sand_*.dmm $R/PlanetSand/
python tools/smartwires/convert.py . --only PlanetRock PlanetSand
python tools/planets/prune_pipes.py $R/PlanetRock/*.dmm $R/PlanetSand/*.dmm
sh tools/planets/recipes/piaski_retheme.sh
GARGS=""
for f in "$SHIPTEST"/_maps/templates/greebles/whitesands/*.dmm; do
	GARGS="$GARGS $f=$(basename "$f" .dmm)"
done
python tools/planets/convert_maps.py --out aquila/_maps/greebles/whitesands --mappings piaski $GARGS
python tools/ci/check_map_connections.py $R/PlanetRock/*.dmm $R/PlanetSand/*.dmm $R/PlanetDesert/*.dmm $R/PlanetShrouded/*.dmm aquila/_maps/greebles/whitesands/*.dmm
