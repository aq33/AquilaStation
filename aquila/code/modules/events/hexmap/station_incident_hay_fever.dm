// AQUILA - Pylenie roślin: dojrzała roślina w hydroponice zaczyna mocno pylić i po pół minuty drażni drogi oddechowe ludzi obok, zbiór albo usunięcie rośliny kończy event (port z BlueMoon-Station code/modules/events/station_incidents.dm, wariant hay fever)
// As in BlueMoon: an announcement names the tray, the pollen starts 30 s later, every 10 s humans within 3 tiles in the
// same area who breathe without a mask get 4 units of histamine (up to 4 people, each once) and the event ends after
// 2 minutes or as soon as the tray has nothing to harvest or is moved. Our botany has plant trays with a harvest light
// instead of hydroponics machines, so a ripe plant is a tray in a hydroponics area with its harvest light on.
// BlueMoon's pollen cloud effect is not in the source we have; the tray shows a yellow haze message instead.

/// How many people the pollen can reach
#define HAY_FEVER_MAX_EXPOSED 4

/datum/round_event_control/aquila_hex_station_incident_hay_fever
	name = "Pylenie roślin"
	typepath = /datum/round_event/aquila_hex_station_incident_hay_fever
	weight = 10
	min_players = 5
	max_occurrences = 1
	earliest_start = 25 MINUTES

/datum/round_event/aquila_hex_station_incident_hay_fever
	fakeable = FALSE
	startWhen = 1
	announceWhen = 1
	endWhen = 60 // 2 minutes
	/// The pollinating tray
	var/datum/weakref/tray_ref
	/// Area of the tray when the pollen started
	var/area/pollen_area
	/// REF() of everyone who got pollen
	var/list/exposed = list()

/datum/round_event/aquila_hex_station_incident_hay_fever/setup()
	var/list/trays = list()
	for(var/area/hydroponics/hydro_area in GLOB.sortedAreas)
		if(!(hydro_area.type in GLOB.the_station_areas))
			continue
		for(var/obj/item/plant_tray/tray in hydro_area)
			if(is_ripe(tray))
				trays += tray
	if(length(trays))
		var/obj/item/plant_tray/tray = pick(trays)
		tray_ref = WEAKREF(tray)
		pollen_area = get_area(tray)

/// A tray on the ship floor with its harvest light on
/datum/round_event/aquila_hex_station_incident_hay_fever/proc/is_ripe(obj/item/plant_tray/tray)
	return !QDELETED(tray) && isturf(tray.loc) && is_station_level(tray.z) && length(tray.harvestable_components)

/datum/round_event/aquila_hex_station_incident_hay_fever/announce(fake)
	var/obj/item/plant_tray/tray = tray_ref?.resolve()
	if(!tray)
		return
	priority_announce("Jedna z dojrzałych roślin w obszarze [get_area_name(tray, TRUE)] wydziela nadmiar pyłku. Zbierzcie plony albo usuńcie roślinę, żeby to zatrzymać. Do tego czasu noście maski, a przy swędzeniu oczu i kichaniu zgłoście się do lekarza.", "Monitoring powietrza hydroponiki")

/datum/round_event/aquila_hex_station_incident_hay_fever/start()
	var/obj/item/plant_tray/tray = pollen_source()
	if(!tray)
		log_game("Pollen Exposure: no ripe plant in hydroponics, cancelling the event.")
		return kill()
	tray.visible_message("<span class='warning'>Nad dojrzałymi roślinami w [tray] unosi się chmurka żółtego pyłku. Chyba czas na zbiory.</span>")
	log_game("Pollen Exposure started at [AREACOORD(tray)].")

/// The tray while it still pollinates: ripe and in the same area
/datum/round_event/aquila_hex_station_incident_hay_fever/proc/pollen_source()
	var/obj/item/plant_tray/tray = tray_ref?.resolve()
	if(!is_ripe(tray) || get_area(tray) != pollen_area)
		return null
	return tray

/// Breathing humans without a mask who did not get pollen yet
/datum/round_event/aquila_hex_station_incident_hay_fever/proc/can_expose(mob/living/carbon/human/target)
	if(QDELETED(target) || !isturf(target.loc) || target.stat != CONSCIOUS || !target.reagents)
		return FALSE
	if((REF(target) in exposed) || target.wear_mask || HAS_TRAIT(target, TRAIT_NOBREATH) || HAS_TRAIT(target, TRAIT_TOXIMMUNE))
		return FALSE
	return !target.reagents.has_reagent(/datum/reagent/toxin/histamine)

/// Gives the human a dose of histamine. Returns TRUE if it did
/datum/round_event/aquila_hex_station_incident_hay_fever/proc/expose(mob/living/carbon/human/target)
	if(length(exposed) >= HAY_FEVER_MAX_EXPOSED || !can_expose(target))
		return FALSE
	if(!target.reagents.add_reagent(/datum/reagent/toxin/histamine, 4))
		return FALSE
	exposed += REF(target)
	to_chat(target, "<span class='warning'>W powietrzu wiruje drobny pyłek. Zaczynają cię swędzieć oczy.</span>")
	return TRUE

/datum/round_event/aquila_hex_station_incident_hay_fever/tick()
	var/obj/item/plant_tray/tray = pollen_source()
	if(!tray)
		log_game("Pollen Exposure ended: the plant was harvested or removed.")
		processing = FALSE
		kill()
		return
	if(activeFor < 15 || activeFor % 5)
		return
	for(var/mob/living/carbon/human/target in view(3, tray))
		if(get_area(target) != pollen_area)
			continue
		expose(target)
		if(length(exposed) >= HAY_FEVER_MAX_EXPOSED)
			break

#undef HAY_FEVER_MAX_EXPOSED
