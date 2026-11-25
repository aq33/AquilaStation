// AQUILA - Bańki gazu bagiennego (plan maszynowni E8): na błotach planet dżungli co jakiś czas wypuszczają porcję metanu.
// Metanu nie ma w initial_gas_mix turfów, bo inna mieszanka na granicy trzymała kafelki aktywne w SSair na stałe
// (komentarz w aquila/code/modules/planets/water/water_turfs.dm). Bańka puszcza gaz tylko, gdy na poziomie są gracze,
// więc na pustej planecie nic nie kosztuje. Metan zbiera się przenośnym skruberem albo pompą, od ognia się zapala.

/// Co ile bańka wypuszcza metan
#define SWAMP_GAS_INTERVAL (40 SECONDS)
/// Ile moli metanu w jednej porcji
#define SWAMP_GAS_MOLES 4
/// Powyżej tylu moli metanu na kafelku bańka czeka (nie napełnia zamkniętej przestrzeni bez końca)
#define SWAMP_GAS_LOCAL_CAP 30

/obj/structure/swamp_gas
	name = "bańka gazu bagiennego"
	desc = "Z błota co chwilę wydobywają się bąble gazu. Pachnie zgnilizną, a gaz bagienny to głównie metan."
	icon = 'icons/obj/lavaland/terrain.dmi'
	icon_state = "geyser"
	color = "#6b7f3a"
	anchored = TRUE
	density = FALSE
	layer = LOW_OBJ_LAYER
	resistance_flags = INDESTRUCTIBLE
	COOLDOWN_DECLARE(next_release)

/obj/structure/swamp_gas/Initialize(mapload)
	. = ..()
	COOLDOWN_START(src, next_release, rand(0, SWAMP_GAS_INTERVAL))
	START_PROCESSING(SSobj, src)

/obj/structure/swamp_gas/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/swamp_gas/process(delta_time)
	if(!COOLDOWN_FINISHED(src, next_release))
		return
	COOLDOWN_START(src, next_release, SWAMP_GAS_INTERVAL)
	if(!length(SSmobs.clients_by_zlevel[z]))
		return
	release_gas()

/// Wypuszcza porcję metanu na kafelek, zwraca TRUE, gdy coś wypuściła
/obj/structure/swamp_gas/proc/release_gas()
	var/turf/open/location = loc
	if(!istype(location) || !location.air)
		return FALSE
	var/datum/gas_mixture/air = location.air
	if(air.get_moles(GAS_METHANE) >= SWAMP_GAS_LOCAL_CAP)
		return FALSE
	air.adjust_moles_temp(GAS_METHANE, SWAMP_GAS_MOLES, air.return_temperature())
	return TRUE

#undef SWAMP_GAS_INTERVAL
#undef SWAMP_GAS_MOLES
#undef SWAMP_GAS_LOCAL_CAP
