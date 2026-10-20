// AQUILA - krwawe robaki jako antagonista: drużyna, cele, język (port z tgstation#93787)

/datum/antagonist/blood_worm
	name = "Krwawy robak"
	roundend_category = "krwawe robaki"
	antagpanel_category = "Blood Worm"
	banning_key = ROLE_BLOOD_WORM
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	hijack_speed = 0.5
	ui_name = "AntagInfoBloodWorm"
	var/datum/team/blood_worm/team

/datum/antagonist/blood_worm/Destroy()
	team = null
	return ..()

/datum/antagonist/blood_worm/greet()
	to_chat(owner, "<span class='big red bold'>Jesteś krwawym robakiem!</span>")
	to_chat(owner, "<span class='bold'>Gatunek kosmicznych pijawek, ogromnych i zaciekłych w polowaniu. Większość nie wie, skąd pochodzicie, \
		ale dla niektórych jesteście jednym z ich największych dzieł: nieudanym projektem broni biologicznej Syndykatu, \
		porzuconym przez sponsorów z powodu \"braku wyników\". A jednak jesteś tutaj, na statku Nanotrasen. Czyż to nie idealne środowisko?</span>")
	to_chat(owner, "<span class='danger'><b>ZABIJAJ, POŻERAJ, ROZMNAŻAJ SIĘ, PODBIJAJ.</b></span>")
	owner.announce_objectives()
	SEND_SOUND(owner.current, sound('sound/magic/exit_blood.ogg'))
	owner.current.client?.tgui_panel?.give_antagonist_popup("Krwawy robak", "Zabijaj, pożeraj, rozmnażaj się, podbijaj.")

/datum/antagonist/blood_worm/create_team(datum/team/blood_worm/new_team)
	if(!GLOB.blood_worm_team)
		GLOB.blood_worm_team = new
	team = GLOB.blood_worm_team

/datum/antagonist/blood_worm/get_team()
	return team

/datum/antagonist/blood_worm/on_gain()
	if(!team)
		create_team()
	team.add_member(owner)
	objectives |= team.objectives
	. = ..()

/datum/antagonist/blood_worm/on_removal()
	team?.remove_member(owner)
	return ..()

/datum/antagonist/blood_worm/apply_innate_effects(mob/living/mob_override)
	var/mob/living/target = mob_override || owner.current
	if(!target)
		return
	if(!isbloodworm(target))
		target.faction |= FACTION_BLOOD_WORM
	ADD_TRAIT(target, TRAIT_FEARLESS, REF(src))
	GLOB.blood_worm_team_hud.add_to_hud(target)
	GLOB.blood_worm_team_hud.add_hud_to(target)

/datum/antagonist/blood_worm/remove_innate_effects(mob/living/mob_override)
	var/mob/living/target = mob_override || owner.current
	if(!target)
		return
	if(!isbloodworm(target))
		target.faction -= FACTION_BLOOD_WORM
	REMOVE_TRAITS_IN(target, REF(src))
	if(!HAS_TRAIT(target, TRAIT_BLOOD_WORM_HOST))
		GLOB.blood_worm_team_hud.remove_from_hud(target)
	GLOB.blood_worm_team_hud.remove_hud_from(target, TRUE)

/datum/antagonist/blood_worm/admin_add(datum/mind/new_owner, mob/admin)
	if(!new_owner.current)
		return
	if(!isbloodworm(new_owner.current))
		var/mob/old_mob = new_owner.current
		var/mob/living/simple_animal/hostile/blood_worm/hatchling/new_worm = new(get_turf(old_mob))
		new_owner.transfer_to(new_worm, force_key_move = TRUE)
		qdel(old_mob)
	return ..()

/datum/antagonist/blood_worm/ui_static_data(mob/user)
	. = ..()
	.["team"] = list(
		"blood_consumed_total" = round(team?.blood_consumed_total),
		"times_reproduced_total" = round(team?.times_reproduced_total),
	)

/// Robaki z ankiety duchów i z rozmnażania
/datum/antagonist/blood_worm/infestation
	show_in_antagpanel = FALSE

GLOBAL_DATUM(blood_worm_team, /datum/team/blood_worm)

/datum/team/blood_worm
	name = "Krwawe robaki"
	member_name = "krwawy robak"
	var/blood_consumed_total = 0
	var/times_reproduced_total = 0
	var/static/list/objective_types = list(
		/datum/objective/blood_worm/kill,
		/datum/objective/blood_worm/consume,
		/datum/objective/blood_worm/multiply,
		/datum/objective/blood_worm/conquer,
	)

/datum/team/blood_worm/New(starting_members)
	. = ..()
	for(var/objective_type in objective_types)
		var/datum/objective/objective = new objective_type
		objective.team = src
		objectives += objective

/datum/team/blood_worm/add_member(datum/mind/member)
	. = ..()
	register_member_mob(member.current)
	RegisterSignal(member, COMSIG_MIND_TRANSFER_TO, PROC_REF(on_mind_transferred), override = TRUE)

/datum/team/blood_worm/remove_member(datum/mind/member)
	UnregisterSignal(member, COMSIG_MIND_TRANSFER_TO)
	unregister_member_mob(member.current)
	return ..()

/datum/team/blood_worm/proc/on_mind_transferred(datum/mind/member, mob/old_body, mob/new_body)
	SIGNAL_HANDLER
	unregister_member_mob(old_body)
	register_member_mob(new_body)

/datum/team/blood_worm/proc/register_member_mob(mob/member_mob)
	if(!isbloodworm(member_mob))
		return
	RegisterSignal(member_mob, COMSIG_BLOOD_WORM_CONSUMED_BLOOD, PROC_REF(on_blood_worm_consumed_blood), override = TRUE)
	RegisterSignal(member_mob, COMSIG_BLOOD_WORM_REPRODUCED, PROC_REF(on_blood_worm_reproduced), override = TRUE)

/datum/team/blood_worm/proc/unregister_member_mob(mob/member_mob)
	// Robak w nosicielu dalej je, więc sygnały zostają, dopóki robak istnieje
	if(!isbloodworm(member_mob) || !QDELETED(member_mob))
		return
	UnregisterSignal(member_mob, list(COMSIG_BLOOD_WORM_CONSUMED_BLOOD, COMSIG_BLOOD_WORM_REPRODUCED))

/datum/team/blood_worm/proc/on_blood_worm_consumed_blood(mob/living/simple_animal/hostile/blood_worm/worm, normal_blood_amount, synth_blood_amount, total_blood_amount)
	SIGNAL_HANDLER
	blood_consumed_total += normal_blood_amount

/datum/team/blood_worm/proc/on_blood_worm_reproduced(mob/living/simple_animal/hostile/blood_worm/worm)
	SIGNAL_HANDLER
	times_reproduced_total++

// Cele

/datum/objective/blood_worm
	name = "blood worm"

/datum/objective/blood_worm/proc/get_blood_worm_team()
	RETURN_TYPE(/datum/team/blood_worm)
	return team

/datum/objective/blood_worm/kill
	name = "ZABIJAJ"
	explanation_text = "Nie możemy pozwolić, żeby ktokolwiek z dowództwa statku przeżył do końca zmiany i odleciał."

/datum/objective/blood_worm/kill/check_completion()
	for(var/datum/mind/crew_mind as anything in SSticker.minds)
		if(!(crew_mind.assigned_role in GLOB.command_positions))
			continue
		if(considered_escaped(crew_mind))
			return FALSE
	return TRUE

/datum/objective/blood_worm/consume
	name = "POŻERAJ"
	var/blood_required = 0

/datum/objective/blood_worm/consume/New(text)
	blood_required = rand(20, 30) * 100
	..()
	update_explanation_text()

/datum/objective/blood_worm/consume/update_explanation_text()
	explanation_text = "Musimy wypić łącznie co najmniej [blood_required] j. prawdziwej krwi, żeby zaspokoić nasz głód."

/datum/objective/blood_worm/consume/check_completion()
	return get_blood_worm_team()?.blood_consumed_total >= blood_required

/datum/objective/blood_worm/multiply
	name = "ROZMNAŻAJ SIĘ"
	var/times_required = 0

/datum/objective/blood_worm/multiply/New(text)
	times_required = rand(2, 3)
	..()
	update_explanation_text()

/datum/objective/blood_worm/multiply/update_explanation_text()
	explanation_text = "Co najmniej [times_required] z nas musi się rozmnożyć, żeby utorować drogę naszej przytłaczającej liczebności."

/datum/objective/blood_worm/multiply/check_completion()
	return get_blood_worm_team()?.times_reproduced_total >= times_required

/datum/objective/blood_worm/conquer
	name = "PODBIJAJ"
	var/worms_required = 0

/datum/objective/blood_worm/conquer/New(text)
	worms_required = rand(3, 4)
	..()
	update_explanation_text()

/datum/objective/blood_worm/conquer/update_explanation_text()
	explanation_text = "Co najmniej [worms_required] z nas musi przeżyć do końca zmiany i odlecieć, żeby podbić to, co czeka po drugiej stronie."

/datum/objective/blood_worm/conquer/check_completion()
	var/conquerors = 0
	for(var/datum/mind/member as anything in team?.members)
		if(QDELETED(member.current))
			continue
		if(!isbloodworm(member.current) && !HAS_TRAIT(member.current, TRAIT_BLOOD_WORM_HOST))
			continue
		if(considered_escaped(member))
			conquerors++
	return conquerors >= worms_required

// Język

/datum/language/wormspeak
	name = "Robaczy"
	desc = "Język wszelkich wielkich robaków, złożony z ryków ich ogromnych paszcz."
	speech_verb = "ryczy"
	ask_verb = "ryczy"
	exclaim_verb = "ryczy"
	key = "w"
	syllables = list("oaaa", "eeo", "aaeo", "ooe", "eaeaea", "aeaeoo", "o", "ae")
	icon = 'aquila/icons/misc/language_wormspeak.dmi'
	icon_state = "wormspeak"
	default_priority = 90

/datum/language_holder/blood_worm
	understood_languages = list(
		/datum/language/wormspeak = list(LANGUAGE_ATOM),
		/datum/language/common = list(LANGUAGE_ATOM),
	)
	// Rozumieją wspólny, ale mówią tylko po robaczemu (u nas blokada języka odbiera też rozumienie)
	spoken_languages = list(/datum/language/wormspeak = list(LANGUAGE_ATOM))
