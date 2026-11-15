// AQUILA - spawnery anomalii planetarnych: port z Shiptesta (code/game/objects/effects/spawners/random/anomaly.dm,
// /obj/effect/spawner/random/anomaly/lava i /lava/cave, licencja AGPLv3; ikona spawnera z Shiptesta, CC BY-SA 3.0).
// U nas nie ma /obj/effect/spawner/random, więc spawnery stoją na /obj/effect/spawner/lootdrop (losuje jedną pozycję
// z listy z wagami). Listy jak w Shiptescie, z równymi wagami. Do tabel biomów wpina je właściciel planety.

/obj/effect/spawner/lootdrop/planetary_anomaly
	name = "losowa anomalia planetarna"
	icon = 'aquila/icons/planets/anomalies.dmi'
	icon_state = "anomaly_spawner"

/// Planeta wulkaniczna, powierzchnia
/obj/effect/spawner/lootdrop/planetary_anomaly/lava
	name = "losowa anomalia planety wulkanicznej"
	loot = list(
		/obj/effect/anomaly/bluespace/planetary = 1,
		/obj/effect/anomaly/flux/planetary = 1,
		/obj/effect/anomaly/grav/planetary = 1,
		/obj/effect/anomaly/hallucination/planetary = 1,
		/obj/effect/anomaly/pyro/planetary = 1,
		/obj/effect/anomaly/plasmasoul/planetary = 1,
	)

/// Planeta wulkaniczna, jaskinie (bez anomalii, które źle działają w ciasnych korytarzach)
/obj/effect/spawner/lootdrop/planetary_anomaly/lava/cave
	name = "losowa anomalia jaskiń planety wulkanicznej"
	loot = list(
		/obj/effect/anomaly/flux/planetary = 1,
		/obj/effect/anomaly/hallucination/planetary = 1,
		/obj/effect/anomaly/pyro/planetary = 1,
		/obj/effect/anomaly/plasmasoul/planetary = 1,
	)

// Spawnery pozostałych planet i ruin (Shiptest anomaly.dm, te same listy, równe wagi). /cave: biomy jaskiń, bez
// anomalii, które źle działają w ciasnych korytarzach.

/// Dowolna anomalia planetarna (Shiptest /obj/effect/spawner/random/anomaly)
/obj/effect/spawner/lootdrop/planetary_anomaly/any
	name = "losowa anomalia planetarna"
	loot = list(
		/obj/effect/anomaly/bluespace/planetary = 1,
		/obj/effect/anomaly/flux/planetary = 1,
		/obj/effect/anomaly/grav/planetary = 1,
		/obj/effect/anomaly/hallucination/planetary = 1,
		/obj/effect/anomaly/pyro/planetary = 1,
		/obj/effect/anomaly/grav/high/planetary = 1,
		/obj/effect/anomaly/heartbeat/planetary = 1,
		/obj/effect/anomaly/sparkler/planetary = 1,
		/obj/effect/anomaly/tvstatic/planetary = 1,
		/obj/effect/anomaly/veins/planetary = 1,
		/obj/effect/anomaly/plasmasoul/planetary = 1,
		/obj/effect/anomaly/phantom/planetary = 1,
		/obj/effect/anomaly/melter/planetary = 1,
		/obj/effect/anomaly/transfusion/planetary = 1,
	)

/// Względnie bezpieczna anomalia
/obj/effect/spawner/lootdrop/planetary_anomaly/safe
	name = "losowa względnie bezpieczna anomalia planetarna"
	loot = list(
		/obj/effect/anomaly/hallucination/planetary = 1,
		/obj/effect/anomaly/pyro/planetary = 1,
		/obj/effect/anomaly/sparkler/planetary = 1,
		/obj/effect/anomaly/veins/planetary = 1,
		/obj/effect/anomaly/phantom/planetary = 1,
		/obj/effect/anomaly/transfusion/planetary = 1,
	)

/// Względnie groźna anomalia
/obj/effect/spawner/lootdrop/planetary_anomaly/dangerous
	name = "losowa groźna anomalia planetarna"
	loot = list(
		/obj/effect/anomaly/bluespace/planetary = 1,
		/obj/effect/anomaly/flux/planetary = 1,
		/obj/effect/anomaly/grav/planetary = 1,
		/obj/effect/anomaly/grav/high/planetary = 1,
		/obj/effect/anomaly/heartbeat/planetary = 1,
		/obj/effect/anomaly/tvstatic/planetary = 1,
		/obj/effect/anomaly/plasmasoul/planetary = 1,
		/obj/effect/anomaly/melter/planetary = 1,
	)

/// Duża anomalia (planeta skalista)
/obj/effect/spawner/lootdrop/planetary_anomaly/big
	name = "losowa ogromna anomalia planetarna"
	icon_state = "big_anomaly_spawner"
	loot = list(
		/obj/effect/anomaly/bluespace/big/planetary = 1,
		/obj/effect/anomaly/flux/big/planetary = 1,
		/obj/effect/anomaly/grav/high/big/planetary = 1,
		/obj/effect/anomaly/pyro/big/planetary = 1,
	)

/// Planeta dżunglowa
/obj/effect/spawner/lootdrop/planetary_anomaly/jungle
	name = "losowa anomalia planety dżunglowej"
	loot = list(
		/obj/effect/anomaly/transfusion/planetary = 1,
		/obj/effect/anomaly/hallucination/planetary = 1,
		/obj/effect/anomaly/heartbeat/planetary = 1,
		/obj/effect/anomaly/tvstatic/planetary = 1,
		/obj/effect/anomaly/veins/planetary = 1,
		/obj/effect/anomaly/phantom/planetary = 1,
	)

/obj/effect/spawner/lootdrop/planetary_anomaly/jungle/cave
	name = "losowa anomalia jaskiń planety dżunglowej"

/// Planeta oceaniczna (w Shiptest zdefiniowany, ale biomy plaży go nie używają)
/obj/effect/spawner/lootdrop/planetary_anomaly/beach
	name = "losowa anomalia planety oceanicznej"
	loot = list(
		/obj/effect/anomaly/hallucination/planetary = 1,
		/obj/effect/anomaly/sparkler/planetary = 1,
		/obj/effect/anomaly/veins/planetary = 1,
		/obj/effect/anomaly/phantom/planetary = 1,
	)

/obj/effect/spawner/lootdrop/planetary_anomaly/beach/cave
	name = "losowa anomalia jaskiń planety oceanicznej"

/// Planeta białych piasków
/obj/effect/spawner/lootdrop/planetary_anomaly/sand
	name = "losowa anomalia planety białych piasków"
	loot = list(
		/obj/effect/anomaly/bluespace/planetary = 1,
		/obj/effect/anomaly/flux/planetary = 1,
		/obj/effect/anomaly/sparkler/planetary = 1,
		/obj/effect/anomaly/tvstatic/planetary = 1,
		/obj/effect/anomaly/veins/planetary = 1,
		/obj/effect/anomaly/phantom/planetary = 1,
		/obj/effect/anomaly/melter/planetary = 1,
	)

/obj/effect/spawner/lootdrop/planetary_anomaly/sand/cave
	name = "losowa anomalia jaskiń planety białych piasków"
	loot = list(
		/obj/effect/anomaly/flux/planetary = 1,
		/obj/effect/anomaly/pyro/planetary = 1,
		/obj/effect/anomaly/sparkler/planetary = 1,
		/obj/effect/anomaly/tvstatic/planetary = 1,
		/obj/effect/anomaly/veins/planetary = 1,
		/obj/effect/anomaly/phantom/planetary = 1,
		/obj/effect/anomaly/melter/planetary = 1,
	)

/// Planeta skalista
/obj/effect/spawner/lootdrop/planetary_anomaly/rock
	name = "losowa anomalia planety skalistej"
	loot = list(
		/obj/effect/anomaly/bluespace/planetary = 1,
		/obj/effect/anomaly/flux/planetary = 1,
		/obj/effect/anomaly/grav/planetary = 1,
		/obj/effect/anomaly/hallucination/planetary = 1,
		/obj/effect/anomaly/pyro/planetary = 1,
		/obj/effect/anomaly/grav/high/planetary = 1,
		/obj/effect/anomaly/heartbeat/planetary = 1,
		/obj/effect/anomaly/sparkler/planetary = 1,
		/obj/effect/anomaly/tvstatic/planetary = 1,
		/obj/effect/anomaly/veins/planetary = 1,
		/obj/effect/anomaly/plasmasoul/planetary = 1,
		/obj/effect/anomaly/phantom/planetary = 1,
		/obj/effect/anomaly/melter/planetary = 1,
	)

/obj/effect/spawner/lootdrop/planetary_anomaly/rock/cave
	name = "losowa anomalia jaskiń planety skalistej"
	loot = list(
		/obj/effect/anomaly/flux/planetary = 1,
		/obj/effect/anomaly/hallucination/planetary = 1,
		/obj/effect/anomaly/pyro/planetary = 1,
		/obj/effect/anomaly/heartbeat/planetary = 1,
		/obj/effect/anomaly/sparkler/planetary = 1,
		/obj/effect/anomaly/veins/planetary = 1,
		/obj/effect/anomaly/plasmasoul/planetary = 1,
		/obj/effect/anomaly/phantom/planetary = 1,
		/obj/effect/anomaly/melter/planetary = 1,
	)

/// Planeta lodowa
/obj/effect/spawner/lootdrop/planetary_anomaly/ice
	name = "losowa anomalia planety lodowej"
	loot = list(
		/obj/effect/anomaly/bluespace/planetary = 1,
		/obj/effect/anomaly/grav/planetary = 1,
		/obj/effect/anomaly/hallucination/planetary = 1,
		/obj/effect/anomaly/grav/high/planetary = 1,
		/obj/effect/anomaly/plasmasoul/planetary = 1,
		/obj/effect/anomaly/chronograph/planetary = 1,
	)

/obj/effect/spawner/lootdrop/planetary_anomaly/ice/cave
	name = "losowa anomalia jaskiń planety lodowej"
	loot = list(
		/obj/effect/anomaly/hallucination/planetary = 1,
		/obj/effect/anomaly/grav/high/planetary = 1,
		/obj/effect/anomaly/plasmasoul/planetary = 1,
		/obj/effect/anomaly/chronograph/planetary = 1,
	)

/// Planeta-śmietnisko
/obj/effect/spawner/lootdrop/planetary_anomaly/waste
	name = "losowa anomalia planety-śmietniska"
	loot = list(
		/obj/effect/anomaly/heartbeat/planetary = 1,
		/obj/effect/anomaly/veins/planetary = 1,
		/obj/effect/anomaly/plasmasoul/planetary = 1,
		/obj/effect/anomaly/melter/planetary = 1,
	)

/obj/effect/spawner/lootdrop/planetary_anomaly/waste/cave
	name = "losowa anomalia jaskiń planety-śmietniska"
