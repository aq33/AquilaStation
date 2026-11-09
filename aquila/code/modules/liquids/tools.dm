// AQUILA - Ciecze: narzędzia admina, port z Monkestation 2.0 (monkestation/code/modules/liquids/tools.dm), bez zmiany oceanu.
// U nas nie ma makra ADMIN_VERB, więc zwykłe verby dopisane do list jak w aquila/code/modules/wiremod/admin_verbs.dm.

/world/AVerbsAdmin()
	. = ..()
	. += /client/proc/spawn_liquid
	. += /client/proc/remove_liquid

/world/AVerbsDebug()
	. = ..()
	. += /client/proc/toggle_liquid_debug

/client/proc/spawn_liquid()
	set category = "Fun"
	set name = "Spawn Liquid"
	set desc = "Tworzy wybraną ilość cieczy na twoim kafelku."
	if(!check_rights(R_FUN))
		return
	var/choice
	var/valid_id
	while(!valid_id)
		choice = stripped_input(usr, "Podaj ID reagentu.", "Szukaj reagentu")
		if(isnull(choice)) //Get me out of here!
			break
		if(!ispath(text2path(choice)))
			choice = pick_closest_path(choice, make_types_fancy(subtypesof(/datum/reagent)))
			if(ispath(choice))
				valid_id = TRUE
		else
			choice = text2path(choice)
			valid_id = TRUE
		if(!valid_id)
			to_chat(usr, "<span class='warning'>Nie ma reagentu o takim ID!</span>")
	if(!choice)
		return
	var/volume = input(usr, "Ilość:", "Wybierz ilość") as num|null
	if(!volume)
		return
	if(volume >= 100000)
		to_chat(usr, "<span class='warning'>Najwyżej 100000 jednostek!</span>")
		return
	var/turf/epicenter = get_turf(mob)
	epicenter.add_liquid(choice, volume, FALSE, T20C)
	message_admins("[ADMIN_LOOKUPFLW(usr)] tworzy ciecz w [epicenter.loc] ([choice] - [volume]).")
	log_admin("[key_name(usr)] spawned liquid at [epicenter.loc] ([choice] - [volume]).")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Spawn Liquid")

/client/proc/remove_liquid()
	set category = "Fun"
	set name = "Remove Liquids"
	set desc = "Usuwa ciecze w promieniu od twojego kafelka."
	if(!check_rights(R_FUN))
		return
	var/turf/epicenter = get_turf(mob)

	var/range = input(usr, "Promień:", "Wybierz promień", 2) as num|null
	if(isnull(range))
		return

	var/old_can_fire = SSliquids.can_fire
	SSliquids.can_fire = FALSE
	for(var/obj/effect/abstract/liquid_turf/liquid in range(range, epicenter))
		if(QDELETED(liquid))
			continue
		if(!QDELETED(liquid.liquid_group))
			liquid.liquid_group.remove_any(liquid, liquid.liquid_group.reagents_per_turf)
		qdel(liquid)
	for(var/obj/structure/liquid_ice_block/block in range(range, epicenter))
		QDEL_NULL(block.reagents)
		qdel(block)
	SSliquids.can_fire = old_can_fire

	message_admins("[key_name_admin(usr)] usuwa ciecze w promieniu [range] w [epicenter.loc.name]")
	log_game("[key_name_admin(usr)] removed liquids with range [range] in [epicenter.loc.name]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Remove Liquids")

/// Upadek z piętra w ciecz (Monke: COMSIG_TURF_MOB_FALL w ZImpactDamage)
/mob/living/ZImpactDamage(turf/T, levels)
	if(!QDELETED(T?.liquids))
		T.liquids.mob_fall(src)
	return ..()
