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
