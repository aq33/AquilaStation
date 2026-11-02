/datum/nanite_program/kunai
	name = "Forma kunai"
	desc = "Po aktywacji nanity próbują zebrać się w wolnej dłoni nosiciela i stworzyć nóż kunai, który rozpada się kilka sekund po rzuceniu."
	can_trigger = TRUE
	trigger_cost = 100
	trigger_cooldown = 50
	rogue_types = list(/datum/nanite_program/skin_decay)

/datum/nanite_program/kunai/on_trigger(comm_message)
	var/obj/item/throwing_star/nanite/N = new(get_turf(host_mob))
	if(!iscarbon(host_mob))
		to_chat(host_mob, "<span class='notice'>Pod tobą nagle pojawia się kunai!</span>")
		return
	var/mob/living/carbon/C = host_mob
	if(!C.put_in_hands(N))
		to_chat(C, "<span class='notice'>Pod tobą nagle pojawia się kunai!</span>")
		return
	to_chat(C, "<span class='notice'>W twojej dłoni nagle pojawia się kunai!</span>")

/datum/nanite_program/nanophage
	name = "Nanorój"
	desc = "Po aktywacji nanity zbierają się w żołądku nosiciela, tworząc nanofagi - małe, zaprogramowane drony - które zaraz zostają wykaszlane."
	can_trigger = TRUE
	trigger_cost = 100
	trigger_cooldown = 300
	rogue_types = list(/datum/nanite_program/toxic)

/datum/nanite_program/nanophage/register_extra_settings()
	. = ..()
	extra_settings[NES_HOST_AGGRESSION] = new /datum/nanite_extra_setting/boolean(TRUE, "Tak", "Nie")

/datum/nanite_program/nanophage/on_trigger(comm_message)
	host_mob.visible_message("<span class='danger'>[host_mob] wymiotuje rojem nanofagów!</span>", \
					"<span class='userdanger'>Wymiotujesz rojem nanofagów!</span>")
	playsound(host_mob, 'aquila/sound/misc/nanobirth.ogg', 50)

	var/list/factions = list()

	if(!extra_settings[NES_HOST_AGGRESSION].get_value())
		factions = host_mob.faction.Copy() //copypasta z dehydrated carpa. sprawdźmy czy zadziała
		for(var/F in factions)
			if(F == "neutral")
				factions -= F

	for(var/i in 1 to 8)
		var/mob/living/simple_animal/hostile/nanophage/nano = new /mob/living/simple_animal/hostile/nanophage(get_turf(host_mob))
		step(nano, pick(NORTH,SOUTH,EAST,WEST))
		if(!extra_settings[NES_HOST_AGGRESSION].get_value())
			nano.faction = factions
