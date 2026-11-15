// AQUILA - pole bitwy: turfy i martwe pnącza z Shiptesta (shiptest-ss13/Shiptest, kod AGPLv3, ikony CC BY-SA 3.0):
// code/game/turfs/open/floor/plating/battlefield.dm i battlefield_generator.dm. Atmosfera zwykła (oddychalna), warianty
// "/lit" pominięte (obszar planety ma stałe, mgliste światło). Skażona woda truje jak w Shiptest, ale przez nasz
// toksyczny odczynnik i bez blokowania wrogich mobów (u nas nie ma ishostile dla basic mobów).

/// Spękane pustkowie
/turf/open/floor/plating/asteroid/battlefield_wasteland
	name = "pustkowie"
	desc = "Sucha ziemia bez składników odżywczych popękała na kawałki."
	icon = 'aquila/icons/planets/turf/battlefield.dmi'
	icon_state = "wasteland"
	environment_type = "wasteland"
	turf_type = /turf/open/floor/plating/asteroid/battlefield_wasteland
	floor_variance = 88
	digResult = /obj/item/stack/ore/glass
	baseturfs = /turf/open/floor/plating/asteroid/battlefield_wasteland
	planetary_atmos = TRUE
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/// Rozjeżdżone błoto pola bitwy
/turf/open/floor/plating/asteroid/dirt/battlefield
	name = "zryta ziemia"
	desc = "Ziemia rozjeżdżona gąsienicami i poorana lejami po pociskach."
	baseturfs = /turf/open/floor/plating/asteroid/dirt/battlefield
	planetary_atmos = TRUE

/// Skażona woda: każdy, kto w nią wejdzie albo w niej stoi, dostaje trochę trucizny
/turf/open/water/planet/battlefield
	name = "„woda”"
	desc = "Lepiej tego nie pić... ani nawet w to nie wchodzić."
	color = "#c24850"
	baseturfs = /turf/open/water/planet/battlefield
	reagent_to_extract = /datum/reagent/toxin

/turf/open/water/planet/battlefield/Entered(atom/movable/arrived, atom/old_loc)
	. = ..()
	if(iscarbon(arrived) && poison_tile())
		START_PROCESSING(SSobj, src)

/turf/open/water/planet/battlefield/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	return ..()

/turf/open/water/planet/battlefield/process(delta_time)
	if(!poison_tile())
		return PROCESS_KILL

/// Truje stojących w wodzie; FALSE, gdy nikogo już tu nie ma
/turf/open/water/planet/battlefield/proc/poison_tile()
	. = FALSE
	for(var/mob/living/carbon/victim in src)
		if("toxic" in victim.weather_immunities)
			continue
		victim.reagents?.add_reagent(/datum/reagent/toxin, 0.2)
		. = TRUE

// Martwe pnącza (/obj/structure/spacevine/dead) są w shiptest_flora/jungle.dm razem z gęstymi i kruchymi

/// Skała jaskiń pola bitwy: po wykopaniu zostaje zryta ziemia
/turf/closed/mineral/random/jungle/battlefield
	turf_type = /turf/open/floor/plating/asteroid/dirt/battlefield
	baseturfs = /turf/open/floor/plating/asteroid/dirt/battlefield
