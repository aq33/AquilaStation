// AQUILA - Anomalia bioprzetasowania: co 15 s zamienia losową rękę albo nogę istot w pobliżu na kończynę innej rasy (port z BeeStation code/modules/events/anomaly_bioscrambler.dm + code/game/objects/effects/anomalies/anomaly_bioscrambler.dm)
// Bee's bioscrambler is the tg rename of the delimber anomaly, which we already have (code/game/objects/effects/anomalies.dm,
// "anomalia odczłonkowująca"), so this one is kept apart: only humans are hit and only arms and legs are swapped (never
// heads or chests), always for an organic limb of another roundstart species (GLOB.roundstart_races, so no golem,
// shadow, skeleton, zombie or darkspawn parts; no robotic, monkey or alien ones, never the same species). Whatever was
// stuck in the old limb falls on the floor before it is deleted. Bio armour protects gradually like in Bee (none at 30,
// always at 90) instead of only at 100. Bee's own sprite is not in our icons, so it is a recoloured shield state.

/datum/round_event_control/aquila_hex_anomaly_bioscrambler
	name = "Anomalia bioprzetasowania"
	typepath = /datum/round_event/aquila_hex_anomaly/bioscrambler
	weight = 10
	min_players = 10
	max_occurrences = 3

/datum/round_event/aquila_hex_anomaly/bioscrambler
	anomaly_path = /obj/effect/anomaly/aquila_hex_bioscrambler
	announce_kind = "bioscrambler"

/obj/effect/anomaly/aquila_hex_bioscrambler
	name = "anomalia bioprzetasowania"
	desc = "Pulsująca chmura cudzego DNA. Kto stanie za blisko, może wrócić z cudzą ręką."
	icon_state = "shield2"
	color = "#d070ff"
	COOLDOWN_DECLARE(pulse_cooldown)
	/// Czas między impulsami
	var/pulse_interval = 15 SECONDS
	/// Zasięg impulsu
	var/range = 5

/obj/effect/anomaly/aquila_hex_bioscrambler/Initialize(mapload, new_lifespan)
	. = ..()
	COOLDOWN_START(src, pulse_cooldown, pulse_interval) // czas na reakcję

/obj/effect/anomaly/aquila_hex_bioscrambler/anomalyEffect(delta_time)
	. = ..()
	if(!COOLDOWN_FINISHED(src, pulse_cooldown))
		return
	COOLDOWN_START(src, pulse_cooldown, pulse_interval)
	aquila_hex_bioscrambler_pulse(src, range)

/// Zamienia jedną kończynę każdej istoty w zasięgu na kończynę innej rasy. Zwraca listę trafionych.
/proc/aquila_hex_bioscrambler_pulse(atom/owner, range = 5)
	var/list/mob/living/carbon/human/affected = list()
	for(var/mob/living/carbon/human/target in range(range, owner))
		if(target.stat == DEAD)
			continue
		// Ochrona rośnie liniowo: brak przy 30 bio, pewna przy 90 (jak w Bee)
		var/protection_chance = (target.getarmor(null, "bio") - 30) * (100 / (90 - 30))
		if(prob(protection_chance))
			to_chat(target, "<span class='notice'>Twój pancerz chroni cię przed [owner]!</span>")
			continue
		if(aquila_hex_bioscramble_limb(target))
			affected += target
	if(length(affected))
		log_game("[owner] caused a bioscrambler pulse at [AREACOORD(owner)] affecting [english_list(affected)].")
	return affected

/// Kończyny ras grywalnych od startu rundy dla strefy ciała (bez robotycznych, zwierzęcych i pseudokończyn)
/proc/aquila_hex_bioscrambler_limbs(zone)
	var/static/list/limbs_by_zone
	if(!limbs_by_zone)
		limbs_by_zone = list()
		for(var/species_id in GLOB.roundstart_races)
			var/datum/species/species_type = GLOB.species_list[species_id]
			if(!species_type)
				continue
			var/list/species_limbs = list(
				BODY_ZONE_L_ARM = initial(species_type.species_l_arm),
				BODY_ZONE_R_ARM = initial(species_type.species_r_arm),
				BODY_ZONE_L_LEG = initial(species_type.species_l_leg),
				BODY_ZONE_R_LEG = initial(species_type.species_r_leg),
			)
			for(var/limb_zone in species_limbs)
				var/obj/item/bodypart/limb = species_limbs[limb_zone]
				if(!ispath(limb, /obj/item/bodypart) || initial(limb.animal_origin) || initial(limb.is_pseudopart) || !(initial(limb.bodytype) & BODYTYPE_ORGANIC))
					continue
				if(!limbs_by_zone[limb_zone])
					limbs_by_zone[limb_zone] = list()
				limbs_by_zone[limb_zone] |= limb
	return limbs_by_zone[zone]

/// Zamienia losową rękę albo nogę celu na organiczną kończynę innej rasy. Zwraca nową kończynę.
/proc/aquila_hex_bioscramble_limb(mob/living/carbon/human/target)
	var/static/list/zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	if(!ishuman(target))
		return null
	for(var/zone in shuffle(zones.Copy()))
		var/obj/item/bodypart/old_part = target.get_bodypart(zone)
		if(!old_part)
			continue
		var/list/options = list()
		for(var/obj/item/bodypart/candidate as anything in aquila_hex_bioscrambler_limbs(zone))
			if(initial(candidate.limb_id) != old_part.limb_id)
				options += candidate
		if(!length(options))
			continue
		var/new_type = pick(options)
		var/obj/item/bodypart/new_part = new new_type()
		var/old_name = old_part.name
		new_part.replace_limb(target, TRUE, is_creating = TRUE)
		// Wbite przedmioty i wszystko inne ze starej kończyny spada na podłogę, zanim ją usuniemy
		var/atom/drop_spot = target.drop_location()
		for(var/atom/movable/stuck as anything in old_part)
			stuck.forceMove(drop_spot)
		qdel(old_part)
		target.update_body(TRUE)
		to_chat(target, "<span class='warning'>Coś jest inaczej... [new_part.name] nie wygląda na twoją.</span>")
		target.log_message("had their [old_name] turned into [new_part.type] by a bioscrambler pulse.", LOG_ATTACK)
		return new_part
