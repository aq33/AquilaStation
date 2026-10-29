//Programs that interact with other programs or nanites directly, or have other special purposes.
/datum/nanite_program/viral
	name = "Wirusowa replika"
	desc = "Nanity nieustannie wysyłają zaszyfrowane sygnały, próbując siłą skopiować swoje oprogramowanie do innych skupisk nanitów, a także nadpisać lub wyłączyć ich synchronizację z chmurą."
	use_rate = 0.5
	rogue_types = list(/datum/nanite_program/toxic)
	var/pulse_cooldown = 0

/datum/nanite_program/viral/register_extra_settings()
	extra_settings[NES_PROGRAM_OVERWRITE] = new /datum/nanite_extra_setting/type("Dodaj", list("Nadpisz", "Dodaj", "Ignoruj"))
	extra_settings[NES_CLOUD_OVERWRITE] = new /datum/nanite_extra_setting/number(0, 0, 100)

/datum/nanite_program/viral/active_effect()
	if(world.time < pulse_cooldown)
		return
	var/datum/nanite_extra_setting/program = extra_settings[NES_PROGRAM_OVERWRITE]
	var/datum/nanite_extra_setting/cloud = extra_settings[NES_CLOUD_OVERWRITE]
	for(var/mob/M in orange(5, host_mob))
		if(SEND_SIGNAL(M, COMSIG_NANITE_IS_STEALTHY))
			continue
		switch(program.get_value())
			if("Nadpisz")
				SEND_SIGNAL(M, COMSIG_NANITE_SYNC, nanites, TRUE)
			if("Dodaj")
				SEND_SIGNAL(M, COMSIG_NANITE_SYNC, nanites, FALSE)
		SEND_SIGNAL(M, COMSIG_NANITE_SET_CLOUD, cloud.get_value())
	pulse_cooldown = world.time + 75

/datum/nanite_program/monitoring
	name = "Monitorowanie"
	desc = "Nanity monitorują funkcje życiowe i położenie nosiciela, przesyłając je do sieci czujników kombinezonów."
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/monitoring/enable_passive_effect()

	. = ..()

	if(!ishuman(host_mob))
		return

	ADD_TRAIT(host_mob, TRAIT_NANITE_SENSORS, TRACKED_SENSORS_TRAIT)
	if(!HAS_TRAIT(host_mob, TRAIT_SUIT_SENSORS))
		GLOB.suit_sensors_list += host_mob
	host_mob.hud_set_nanite_indicator()

/datum/nanite_program/monitoring/disable_passive_effect()

	. = ..()

	if(!ishuman(host_mob))
		return

	REMOVE_TRAIT(host_mob, TRAIT_NANITE_SENSORS, TRACKED_SENSORS_TRAIT)
	if(!HAS_TRAIT(host_mob, TRAIT_SUIT_SENSORS))
		GLOB.suit_sensors_list -= host_mob
	host_mob.hud_set_nanite_indicator()

/datum/nanite_program/self_scan
	name = "Skan nosiciela"
	desc = "Nanity wyświetlają nosicielowi szczegółowy odczyt skanu ciała."
	unique = FALSE
	can_trigger = TRUE
	trigger_cost = 3
	trigger_cooldown = 50
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/self_scan/register_extra_settings()
	extra_settings[NES_SCAN_TYPE] = new /datum/nanite_extra_setting/type("Medyczny", list("Medyczny", "Chemiczny", "Nanity"))

/datum/nanite_program/self_scan/on_trigger(comm_message)
	if(host_mob.stat == DEAD)
		return
	var/datum/nanite_extra_setting/NS = extra_settings[NES_SCAN_TYPE]
	switch(NS.get_value())
		if("Medyczny")
			healthscan(host_mob, host_mob)
		if("Chemiczny")
			chemscan(host_mob, host_mob)
		if("Nanity")
			SEND_SIGNAL(host_mob, COMSIG_NANITE_SCAN, host_mob, TRUE)

/datum/nanite_program/stealth
	name = "Kamuflaż"
	desc = "Nanity maskują swoją aktywność przed pobieżnymi skanami, przez co HUD-y i niespecjalistyczne skanery ich nie wykrywają."
	rogue_types = list(/datum/nanite_program/toxic)
	use_rate = 0.2

/datum/nanite_program/stealth/enable_passive_effect()
	. = ..()
	nanites.stealth = TRUE

/datum/nanite_program/stealth/disable_passive_effect()
	. = ..()
	nanites.stealth = FALSE

/datum/nanite_program/reduced_diagnostics
	name = "Ograniczona diagnostyka"
	desc = "Wyłącza część kosztownej diagnostyki nanitów, przez co nie przekazują listy programów przenośnym skanerom. \
	Oszczędza to nieco energii i lekko przyspiesza replikację."
	rogue_types = list(/datum/nanite_program/toxic)
	use_rate = -0.1

/datum/nanite_program/reduced_diagnostics/enable_passive_effect()
	. = ..()
	nanites.diagnostics = FALSE

/datum/nanite_program/reduced_diagnostics/disable_passive_effect()
	. = ..()
	nanites.diagnostics = TRUE

/datum/nanite_program/relay
	name = "Przekaźnik"
	desc = "Nanity odbierają i przekazują dalekosiężne sygnały nanitów."
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/relay/register_extra_settings()
	extra_settings[NES_RELAY_CHANNEL] = new /datum/nanite_extra_setting/number(1, 1, 9999)

/datum/nanite_program/relay/enable_passive_effect()
	. = ..()
	SSnanites.nanite_relays |= src

/datum/nanite_program/relay/disable_passive_effect()
	. = ..()
	SSnanites.nanite_relays -= src

/datum/nanite_program/relay/proc/relay_signal(code, relay_code, source)
	if(!activated)
		return
	if(!host_mob)
		return
	var/datum/nanite_extra_setting/NS = extra_settings[NES_RELAY_CHANNEL]
	if(relay_code != NS.get_value())
		return
	SEND_SIGNAL(host_mob, COMSIG_NANITE_SIGNAL, code, source)

/datum/nanite_program/relay/proc/relay_comm_signal(comm_code, relay_code, comm_message)
	if(!activated)
		return
	if(!host_mob)
		return
	var/datum/nanite_extra_setting/NS = extra_settings[NES_RELAY_CHANNEL]
	if(relay_code != NS.get_value())
		return
	SEND_SIGNAL(host_mob, COMSIG_NANITE_COMM_SIGNAL, comm_code, comm_message)

/datum/nanite_program/metabolic_synthesis
	name = "Synteza metaboliczna"
	desc = "Nanity wykorzystują cykl metaboliczny nosiciela, by przyspieszyć replikację, zużywając jego nadmiar składników odżywczych jako paliwo."
	use_rate = -0.5 //generates nanites
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/metabolic_synthesis/check_conditions()
	if(!iscarbon(host_mob))
		return FALSE
	var/mob/living/carbon/C = host_mob
	if(C.nutrition <= NUTRITION_LEVEL_WELL_FED)
		return FALSE
	return ..()

/datum/nanite_program/metabolic_synthesis/active_effect()
	host_mob.adjust_nutrition(-0.5)

/datum/nanite_program/research
	name = "Obliczenia rozproszone"
	desc = "Nanity wspomagają serwery badawcze, wykonując część ich obliczeń, co zwiększa przyrost punktów badań."
	use_rate = 0.2
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/research/active_effect()
	if(!iscarbon(host_mob))
		return
	var/points = 1
	if(!host_mob.client) //less brainpower
		points *= 0.25
	SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = points))

/datum/nanite_program/researchplus
	name = "Sieć neuronowa"
	desc = "Nanity łączą mózgi nosicieli w neuronową sieć badawczą, która działa tym wydajniej, im więcej jest nosicieli."
	use_rate = 0.3
	rogue_types = list(/datum/nanite_program/brain_decay)

/datum/nanite_program/researchplus/enable_passive_effect()
	. = ..()
	if(!iscarbon(host_mob))
		return
	if(host_mob.client)
		SSnanites.neural_network_count++
	else
		SSnanites.neural_network_count += 0.25

/datum/nanite_program/researchplus/disable_passive_effect()
	. = ..()
	if(!iscarbon(host_mob))
		return
	if(host_mob.client)
		SSnanites.neural_network_count--
	else
		SSnanites.neural_network_count -= 0.25

/datum/nanite_program/researchplus/active_effect()
	if(!iscarbon(host_mob))
		return
	var/mob/living/carbon/C = host_mob
	var/points = round(SSnanites.neural_network_count / 12, 0.1)
	if(!C.client) //less brainpower
		points *= 0.25
	SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = points))

/datum/nanite_program/access
	name = "Podskórny identyfikator"
	desc = "Nanity zapisują uprawnienia dostępu z identyfikatora nosiciela na podskórnym pasku magnetycznym. Po aktywacji aktualizują je, kopiując obecny dostęp nosiciela."
	can_trigger = TRUE
	trigger_cost = 3
	trigger_cooldown = 30
	rogue_types = list(/datum/nanite_program/skin_decay)
	var/access = list()

//Syncs the nanites with the cumulative current mob's access level. Can potentially wipe existing access.
/datum/nanite_program/access/on_trigger(comm_message)
	var/list/new_access = list()
	var/obj/item/current_item
	current_item = host_mob.get_active_held_item()
	if(current_item)
		new_access += current_item.GetAccess()
	current_item = host_mob.get_inactive_held_item()
	if(current_item)
		new_access += current_item.GetAccess()
	if(ishuman(host_mob))
		var/mob/living/carbon/human/H = host_mob
		current_item = H.wear_id
		if(current_item)
			new_access += current_item.GetAccess()
	else if(isanimal(host_mob))
		var/mob/living/simple_animal/A = host_mob
		current_item = A.access_card
		if(current_item)
			new_access += current_item.GetAccess()
	access = new_access

/datum/nanite_program/spreading
	name = "Zakaźna egzolokomocja"
	desc = "Nanity zyskują zdolność krótkiego przetrwania poza ludzkim ciałem oraz zakładania nowych kolonii bez procesu integracji, \
			co daje skrajnie zakaźny szczep nanitów."
	use_rate = 1.50
	rogue_types = list(/datum/nanite_program/aggressive_replication, /datum/nanite_program/necrotic)
	var/spread_cooldown = 0

/*/datum/nanite_program/spreading/active_effect() AQUILA EDIT START
	if(spread_cooldown < world.time)
		return
	spread_cooldown = world.time + 50
	var/list/mob/living/target_hosts = list()
	for(var/mob/living/L in ohearers(5, host_mob))
		if(!prob(25))
			continue
		if(!(MOB_ORGANIC in L.mob_biotypes) && !(MOB_UNDEAD in L.mob_biotypes) && !HAS_TRAIT(host_mob, TRAIT_NANITECOMPATIBLE))
			continue
		target_hosts += L
	if(!target_hosts.len)
		return
	var/mob/living/infectee = pick(target_hosts)
	if(prob(100 - (infectee.get_permeability_protection() * 100)))
		//this will potentially take over existing nanites!
		infectee.AddComponent(/datum/component/nanites, 10)
		SEND_SIGNAL(infectee, COMSIG_NANITE_SYNC, nanites)
		infectee.investigate_log("was infected by spreading nanites by [key_name(host_mob)] at [AREACOORD(infectee)].", INVESTIGATE_NANITES)

/datum/nanite_program/nanite_sting
	name = "Żądło nanitów"
	desc = "Po aktywacji wystrzeliwuje niemal niewidoczny kolec nanitów, który próbuje zarazić pobliską osobę bez nanitów kopią skupiska nanitów nosiciela."
	can_trigger = TRUE
	trigger_cost = 5
	trigger_cooldown = 100
	rogue_types = list(/datum/nanite_program/glitch, /datum/nanite_program/toxic)

/datum/nanite_program/nanite_sting/on_trigger(comm_message)
	var/list/mob/living/target_hosts = list()
	for(var/mob/living/L in oview(1, host_mob))
		if(!(MOB_ORGANIC in L.mob_biotypes) && !(MOB_UNDEAD in L.mob_biotypes) && !HAS_TRAIT(host_mob, TRAIT_NANITECOMPATIBLE))
			continue
		if(SEND_SIGNAL(L, COMSIG_HAS_NANITES) || !L.Adjacent(host_mob))
			continue
		target_hosts += L
	if(!target_hosts.len)
		consume_nanites(-5)
		return
	var/mob/living/infectee = pick(target_hosts)
	if(prob(100 - (infectee.get_permeability_protection() * 100)))
		//unlike with Infective Exo-Locomotion, this can't take over existing nanites, because Nanite Sting only targets non-hosts.
		infectee.AddComponent(/datum/component/nanites, 5)
		SEND_SIGNAL(infectee, COMSIG_NANITE_SYNC, nanites)
		infectee.investigate_log("was infected by a nanite cluster by [key_name(host_mob)] at [AREACOORD(infectee)].", INVESTIGATE_NANITES)
		to_chat(infectee, "<span class='warning'>You feel a tiny prick!</span>")*/ //AQUILA EDIT END

/datum/nanite_program/mitosis
	name = "Mitoza"
	desc = "Nanity zyskują zdolność samoreplikacji zasilanej bluespace. Działa tym skuteczniej, im więcej nanitów jest już w nosicielu. \
			Replikacja może też uszkodzić oprogramowanie nanitów przez błędy kopiowania, więc zalecana jest synchronizacja z chmurą."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/mitosis/active_effect()
	var/rep_rate = round(nanites.nanite_volume / 50, 1) //0.5 per 50 nanite volume
	rep_rate *= 0.5
	nanites.adjust_nanites(null, rep_rate)
	if(prob(rep_rate))
		var/datum/nanite_program/fault = pick(nanites.programs)
		if(fault == src)
			return
		fault.software_error()

/datum/nanite_program/dermal_button
	name = "Przycisk skórny"
	desc = "Wyświetla na skórze nosiciela przycisk, którym można wysłać sygnał do nanitów."
	unique = FALSE
	var/datum/action/innate/nanite_button/button

/datum/nanite_program/dermal_button/register_extra_settings()
	extra_settings[NES_SENT_CODE] = new /datum/nanite_extra_setting/number(1, 1, 9999)
	extra_settings[NES_BUTTON_NAME] = new /datum/nanite_extra_setting/text("Przycisk")
	extra_settings[NES_ICON] = new /datum/nanite_extra_setting/type("power", list("one","two","three","four","five","plus","minus","power"))
	extra_settings[NES_COLOR] = new /datum/nanite_extra_setting/type("green", list("green","red","yellow","blue"))

/datum/nanite_program/dermal_button/enable_passive_effect()
	. = ..()
	var/datum/nanite_extra_setting/bn_name = extra_settings[NES_BUTTON_NAME]
	var/datum/nanite_extra_setting/bn_icon = extra_settings[NES_ICON]
	var/datum/nanite_extra_setting/bn_color = extra_settings[NES_COLOR]
	if(!button)
		button = new(src, bn_name.get_value(), bn_icon.get_value(), bn_color.get_value())
	button.target = host_mob
	button.Grant(host_mob)

/datum/nanite_program/dermal_button/disable_passive_effect()
	. = ..()
	if(button)
		button.Remove(host_mob)

/datum/nanite_program/dermal_button/on_mob_remove()
	. = ..()
	QDEL_NULL(button)

/datum/nanite_program/dermal_button/proc/press()
	if(activated)
		host_mob.visible_message("<span class='notice'>[host_mob] naciska przycisk na przedramieniu.</span>",
								"<span class='notice'>Naciskasz przycisk nanitów na przedramieniu.</span>", null, 2)
		var/datum/nanite_extra_setting/sent_code = extra_settings[NES_SENT_CODE]
		SEND_SIGNAL(host_mob, COMSIG_NANITE_SIGNAL, sent_code.get_value(), "program [name]")

/datum/action/innate/nanite_button
	name = "Przycisk"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	button_icon_state = "power_green"
	var/datum/nanite_program/dermal_button/program

/datum/action/innate/nanite_button/New(datum/nanite_program/dermal_button/_program, _name, _icon, _color)
	..()
	program = _program
	name = _name
	button_icon_state = "[_icon]_[_color]"

/datum/action/innate/nanite_button/Activate()
	program.press()
