// AQUILA - Anomalia mrozu: wypuszcza lodowate powietrze i skuwa lodem podłogi wokół siebie, a na koniec mrozi całe pomieszczenie (port z Monkestation monkestation/code/modules/events/anomaly/anomaly_frost.dm + code/game/objects/effects/anomalies/anomalies_frost.dm)
// Monke turns 2-7 floors around into snowed floor turfs. We cover them with ice for a while instead: our snowed plating has
// planetary atmos (it would keep the ship frozen forever) and the ship structure persistence would carry the snow into
// the next rounds. Freon is not in our atmos, so the cold air is oxygen, nitrogen and a little water vapour.

#define AQUILA_HEX_FROST_MIN_TILES 2
#define AQUILA_HEX_FROST_MAX_TILES 7
#define AQUILA_HEX_FROST_RANGE 7

/datum/round_event_control/aquila_hex_anomaly_frost
	name = "Anomalia mrozu"
	typepath = /datum/round_event/aquila_hex_anomaly/frost
	weight = 10
	min_players = 10
	max_occurrences = 3

/datum/round_event/aquila_hex_anomaly/frost
	anomaly_path = /obj/effect/anomaly/aquila_hex_frost
	announce_kind = "frost"

/obj/effect/anomaly/aquila_hex_frost
	name = "anomalia mrozu"
	desc = "Lodowaty wir, od którego szron osiada na wszystkim dookoła."
	icon_state = "impact_laser_blue"
	light_color = LIGHT_COLOR_BLUE

/obj/effect/anomaly/aquila_hex_frost/anomalyEffect(delta_time)
	..()
	var/turf/open/current = get_turf(src)
	if(!istype(current) || isspaceturf(current))
		return
	current.atmos_spawn_air("o2=2;n2=6;water_vapor=2;TEMP=180")
	freeze_floors(current)

/// Skuwa lodem 2-7 podłóg w zasięgu. Zwraca listę oblodzonych kafli.
/obj/effect/anomaly/aquila_hex_frost/proc/freeze_floors(turf/center)
	var/list/candidates = list()
	for(var/turf/open/floor/T in view(AQUILA_HEX_FROST_RANGE, center))
		if(isspaceturf(T) || istype(T, /turf/open/floor/plating/ice))
			continue
		candidates += T
	. = list()
	for(var/i in 1 to min(rand(AQUILA_HEX_FROST_MIN_TILES, AQUILA_HEX_FROST_MAX_TILES), length(candidates)))
		var/turf/open/floor/frozen = pick_n_take(candidates)
		frozen.MakeSlippery(TURF_WET_ICE, min_wet_time = 20 SECONDS, wet_time_to_add = 10 SECONDS, max_wet_time = 2 MINUTES)
		. += frozen

/obj/effect/anomaly/aquila_hex_frost/detonate()
	var/turf/open/current = get_turf(src)
	if(!istype(current) || isspaceturf(current))
		return
	current.atmos_spawn_air("o2=100;n2=100;water_vapor=50;TEMP=140")

#undef AQUILA_HEX_FROST_MIN_TILES
#undef AQUILA_HEX_FROST_MAX_TILES
#undef AQUILA_HEX_FROST_RANGE
