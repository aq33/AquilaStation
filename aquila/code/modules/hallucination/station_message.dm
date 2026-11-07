// AQUILA - fałszywe ogłoszenia z Bee. Nasz priority_announce() nie ma listy odbiorców (Bee: players = list(...))
// i wysyła do gazety, więc ogłoszenie składa hallucination_announce() tylko dla halucynującego.

/// Fałszywe ogłoszenie w stylu priority_announce(), widoczne i słyszalne tylko dla jednej osoby
/proc/hallucination_announce(mob/target, text, title, sound, sender_override)
	var/announcement = "<h1 class='alert'>[sender_override || "Komunikat: [command_name()]"]</h1>"
	if(title)
		announcement += "<br><h2 class='alert'>[html_encode(title)]</h2>"
	announcement += "<br><span class='alert'>[html_encode(text)]</span><br>"
	to_chat(target, announcement)
	if(sound && SSstation.announcer.event_sounds[sound])
		sound = SSstation.announcer.event_sounds[sound]
	if(sound)
		SEND_SOUND(target, sound(sound))

/datum/hallucination/station_message
	abstract_hallucination_parent = /datum/hallucination/station_message
	random_hallucination_weight = 1
	hallucination_tier = HALLUCINATION_TIER_RARE

/datum/hallucination/station_message/start()
	qdel(src) // To be implemented by subtypes, call parent for easy cleanup
	return TRUE

/datum/hallucination/station_message/blob_alert

/datum/hallucination/station_message/blob_alert/start()
	hallucination_announce(hallucinator, "Potwierdzono ognisko zagrożenia biologicznego poziomu 5 na pokładzie [station_name()]. Cały personel musi powstrzymać ognisko.",
		"Alarm biologiczny", ANNOUNCER_OUTBREAK5)
	return ..()

/datum/hallucination/station_message/shuttle_dock

/datum/hallucination/station_message/shuttle_dock/start()
	hallucination_announce(hallucinator, "Prom ewakuacyjny zadokował przy stacji. Macie [DisplayTimeText(SSshuttle.emergencyDockTime)], by wejść na pokład promu ewakuacyjnego.",
		null, ANNOUNCER_SHUTTLEDOCK, "Komunikat priorytetowy")
	return ..()

/datum/hallucination/station_message/malf_ai

/datum/hallucination/station_message/malf_ai/start()
	if(!(locate(/mob/living/silicon/ai) in GLOB.silicon_mobs))
		return FALSE

	hallucination_announce(hallucinator, "Wykryto wrogie błędy wykonania we wszystkich systemach stacji; dezaktywujcie SI, by zapobiec możliwemu uszkodzeniu jej rdzenia moralności.",
		"Alarm o anomalii", ANNOUNCER_AIMALF)
	return ..()

/datum/hallucination/station_message/heretic
	// Assoc list of ascension text to ascension sound
	var/static/list/announcement_info = list()

/datum/hallucination/station_message/heretic/start()
	if(!length(announcement_info))
		for(var/ascension in subtypesof(/datum/heretic_knowledge/ultimate))
			var/datum/heretic_knowledge/ultimate/instance = new ascension()
			var/text = instance.announcement_text
			var/sound = instance.announcement_sound
			if(text && sound)
				announcement_info[text] = sound
			qdel(instance)
	if(!length(announcement_info))
		return FALSE

	// Unfortunately, this will not be synced if mass hallucinated
	var/mob/living/carbon/human/totally_real_heretic = random_non_sec_crewmember()
	if(!totally_real_heretic)
		return FALSE

	var/message = pick(announcement_info)
	var/message_with_name = replacetext(message, "%USER%", totally_real_heretic.real_name)

	hallucination_announce(hallucinator, "[generate_heretic_text()] [message_with_name] [generate_heretic_text()]", "[generate_heretic_text()]", announcement_info[message])
	return ..()

/datum/hallucination/station_message/cult_summon

/datum/hallucination/station_message/cult_summon/start()
	// Same, will not be synced if mass hallucinated
	var/mob/living/carbon/human/totally_real_cult_leader = random_non_sec_crewmember()
	if(!totally_real_cult_leader)
		return FALSE

	// Get a fake area that the summoning is happening in
	var/area/hallucinator_area = get_area(hallucinator)
	var/area/fake_summon_area_type = pick(GLOB.the_station_areas - hallucinator_area.type)
	var/area/fake_summon_area = GLOB.areas_by_type[fake_summon_area_type]
	if(!fake_summon_area)
		return FALSE

	hallucination_announce(hallucinator, "[totally_real_cult_leader.real_name] przyzywa wytwory pradawnego boga z nieznanego wymiaru do: [fake_summon_area]. Przerwijcie rytuał za wszelką cenę!",
		"Wydział Spraw Wyższych Wymiarów Centrali", 'sound/ambience/antag/bloodcult.ogg')
	return ..()

/datum/hallucination/station_message/meteors
	random_hallucination_weight = 2

/datum/hallucination/station_message/meteors/start()
	hallucination_announce(hallucinator, "Wykryto meteory na kursie kolizyjnym ze stacją. Przewidywany czas do uderzenia: 10 MINUT.",
		"Alarm meteorytowy", ANNOUNCER_METEORS)
	return ..()

/datum/hallucination/station_message/supermatter_delam

/datum/hallucination/station_message/supermatter_delam/start()
	SEND_SOUND(hallucinator, 'sound/magic/charge.ogg')
	to_chat(hallucinator, span_bolddanger("Przez chwilę czujesz, jak rzeczywistość się wykrzywia..."))
	return ..()

/datum/hallucination/station_message/clock_cult_ark
	random_hallucination_weight = 1

/datum/hallucination/station_message/clock_cult_ark/start()
	hallucinator.playsound_local(hallucinator, 'sound/machines/clockcult/ark_deathrattle.ogg', 50, FALSE, pressure_affected = FALSE)
	hallucinator.playsound_local(hallucinator, 'sound/effects/clockcult_gateway_disrupted.ogg', 50, FALSE, pressure_affected = FALSE)
	addtimer(CALLBACK(src, PROC_REF(play_distant_explosion_sound)), 2.7 SECONDS)
	return TRUE // does not call parent to finish up the sound in a few seconds

/datum/hallucination/station_message/clock_cult_ark/proc/play_distant_explosion_sound()
	if(QDELETED(src))
		return

	hallucinator.playsound_local(get_turf(hallucinator), 'sound/effects/explosion_distant.ogg', 50, FALSE, pressure_affected = FALSE)
	qdel(src)
