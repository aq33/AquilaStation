// AQUILA - bingle jako antagonista: datum, drużyna, akcja Lorda (port z Monkestation, bingle_datum.dm i team.dm)
// Różnice: bez żetonów antagonisty (u nas ich nie ma) i bez osobnego HUD-u bingli, za to z celem „nakarm Dół”.

GLOBAL_DATUM(bingle_team, /datum/team/bingles)

/datum/antagonist/bingle
	name = "Bingiel"
	roundend_category = "bingle"
	antagpanel_category = "Bingles"
	banning_key = ROLE_BINGLE
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	/// Drużyna wszystkich bingli
	var/datum/team/bingles/team

/datum/antagonist/bingle/Destroy()
	team = null
	return ..()

/datum/antagonist/bingle/create_team(datum/team/bingles/new_team)
	if(QDELETED(GLOB.bingle_team)) // admin mógł usunąć drużynę
		GLOB.bingle_team = new
	team = GLOB.bingle_team

/datum/antagonist/bingle/get_team()
	return team

/datum/antagonist/bingle/on_gain()
	if(!team)
		create_team()
	team.add_member(owner)
	objectives |= team.objectives
	owner.special_role = ROLE_BINGLE
	return ..()

/datum/antagonist/bingle/on_removal()
	team?.remove_member(owner)
	return ..()

/datum/antagonist/bingle/greet()
	to_chat(owner, "<span class='big blue bold'>Jesteś binglem!</span>")
	to_chat(owner, "<span class='boldwarning'>Musisz karmić Dół za wszelką cenę! Jesteś celem do zabicia na widok i nie potrzebujesz eskalacji.</span>")
	to_chat(owner, "<span class='notice'>Wrzucaj do Dołu przedmioty (1 punkt, stos tyle, ile ma sztuk). Od [BINGLE_PIT_LIVING_THRESHOLD] punktów Dół przyjmuje istoty (10 punktów). \
		Co [BINGLE_PIT_SPAWN_STEP] punktów rodzi się nowy bingiel, co [BINGLE_PIT_GROW_STEP] Dół rośnie, a od [BINGLE_PIT_ARMOR_THRESHOLD] wszystkie bingle twardnieją w pancerz. \
		Przy Dole się leczysz. Zniszczenie Dołu zabija wszystkie bingle.</span>")
	owner.announce_objectives()
	SEND_SOUND(owner.current, sound('sound/effects/blobattack.ogg'))
	owner.current.client?.tgui_panel?.give_antagonist_popup("Bingiel", "Nakarm Dół za wszelką cenę!")

/datum/team/bingles
	name = "Bingle"
	member_name = "bingiel"

/datum/team/bingles/New(starting_members)
	. = ..()
	var/datum/objective/bingle_feed/objective = new
	objective.team = src
	objectives += objective

/datum/team/bingles/roundend_report()
	var/list/parts = list()
	parts += "<span class='header'>Bingle karmiły Dół!</span>"
	var/best = 0
	for(var/obj/structure/bingle_hole/hole as anything in GLOB.bingle_holes)
		best = max(best, hole.item_value_consumed)
	parts += "Dół połknął [best] punktów."
	parts += printplayerlist(members)
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/objective/bingle_feed
	name = "nakarm Dół"
	explanation_text = "Nakarm Dół! Wrzucaj do niego wszystko, co się da, i nie pozwól go zniszczyć."

/datum/objective/bingle_feed/check_completion()
	return length(GLOB.bingle_holes) > 0

/// Akcja Bingle Lorda: stawia Dół na wolnym obszarze 3x3 i znika
/datum/action/cooldown/bingle_spawn_hole
	name = "Postaw Dół bingli"
	desc = "Postaw Dół, który trzeba wypełnić przedmiotami!"
	icon_icon = 'aquila/icons/mob/bingle/binglepit.dmi'
	button_icon_state = "binglepit"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 15 SECONDS

/datum/action/cooldown/bingle_spawn_hole/Trigger()
	if(!..())
		return FALSE
	if(!isliving(owner))
		return FALSE
	var/turf/selected_turf = get_turf(owner)
	if(!check_hole_spawn(selected_turf))
		to_chat(owner, "<span class='warning'>Tu jest za mało miejsca na Dół bingli! Potrzebuje wolnego obszaru 3 na 3 metry!</span>")
		return FALSE
	StartCooldown()
	spawn_hole(selected_turf)
	return TRUE

/datum/action/cooldown/bingle_spawn_hole/proc/check_hole_spawn(turf/selected_turf)
	if(!selected_turf)
		return FALSE
	for(var/turf/adjacent_turf as anything in RANGE_TURFS(1, selected_turf))
		if(isnull(adjacent_turf) || adjacent_turf.density)
			return FALSE
	return TRUE

/datum/action/cooldown/bingle_spawn_hole/proc/spawn_hole(turf/selected_turf)
	var/mob/living/simple_animal/hostile/bingle/lord = owner
	var/obj/structure/bingle_hole/hole = new(selected_turf)
	if(istype(lord))
		lord.set_linked_pit(hole)
	if(istype(lord, /mob/living/simple_animal/hostile/bingle/lord))
		var/mob/living/simple_animal/hostile/bingle/lord/real_lord = lord
		real_lord.makehole = null
	owner.visible_message("<span class='danger'>[owner] rozdziera podłogę, a pod nią otwiera się niebieski Dół!</span>", \
		"<span class='notice'>Stawiasz Dół. Teraz go nakarm!</span>")
	message_admins("[ADMIN_LOOKUPFLW(owner)] stawia Dół bingli: [ADMIN_VERBOSEJMP(selected_turf)].")
	log_game("[key_name(owner)] spawned a bingle pit at [AREACOORD(selected_turf)].")
	Remove(owner)
	qdel(src)
