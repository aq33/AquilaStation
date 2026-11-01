// A type of antagonist created by the moon ascension
/datum/antagonist/lunatic
	name = "\improper Lunatic"
	roundend_category = "heretycy"
	hijack_speed = 0
	antagpanel_category = ANTAG_GROUP_HORRORS
	show_in_antagpanel = FALSE
	count_against_dynamic_roll_chance = FALSE
	// AQUILA - szaleńcem zostaje się wbrew woli (jak przy praniu mózgu), więc nie da się tego zbanować
	banning_key = UNBANNABLE_ANTAGONIST
	antag_moodlet = /datum/mood_event/heretics/lunatic
	// The mind of the ascended heretic who created us
	var/datum/mind/ascended_heretic
	// The body of the ascended heretic who created us
	var/mob/living/carbon/human/ascended_body
	// Our objective
	var/datum/objective/lunatic/lunatic_obj
	// Actions granted by this datum, tracked for proper cleanup on body transfer
	var/datum/action/cooldown/lunatic_track/moon_track
	var/datum/action/cooldown/spell/touch/mansus_grasp/mad_touch
	/// AQUILA - stan ikony HUD (tg: antag_hud_name)
	var/lunatic_hud_state = "lunatic"

/datum/antagonist/lunatic/on_gain()
	owner.current.log_message("has become a Lunatic!", LOG_ATTACK, color="red")
	// Masters gain an objective before so we dont want duplicates
	. = ..()
	// AQUILA - tg w tym miejscu wołał ..() drugi raz
	for(var/objective in objectives)
		if(istype(objective, /datum/objective/lunatic))
			return
	var/datum/objective/lunatic/loony = new()
	loony.owner = owner
	objectives += loony
	lunatic_obj = loony
	moon_track = new(owner)
	mad_touch = new(owner)
	mad_touch.Grant(owner.current)
	moon_track.Grant(owner.current)

/datum/antagonist/lunatic/on_removal()
	owner?.current?.log_message("lost their Lunatic status!", LOG_ATTACK, color="red")
	QDEL_NULL(moon_track)
	QDEL_NULL(mad_touch)
	return ..()

/datum/antagonist/lunatic/greet()
	to_chat(owner.current, span_userdanger("Księżyc odsłonił ci prawdę. Jesteś teraz szaleńcem!"))

/// Runs when the moon heretic creates us, used to give the lunatic a master
/datum/antagonist/lunatic/proc/set_master(datum/mind/heretic_master, mob/living/carbon/human/heretic_body)
	src.ascended_heretic = heretic_master
	src.ascended_body = heretic_body

	lunatic_obj?.master = heretic_master
	lunatic_obj?.update_explanation_text()

	to_chat(owner, span_boldnotice("Zniszcz kłamstwo, ocal prawdę, słuchając rozkazów [heretic_master], przewodnika parady!"))
	owner.announce_objectives()

/datum/antagonist/lunatic/apply_innate_effects(mob/living/mob_override)
	var/mob/living/our_mob = mob_override || owner.current
	handle_clown_mutation(our_mob, "Starożytna wiedza z księżyca pozwoliła ci przezwyciężyć klaunowską naturę i władać bronią bez ranienia samego siebie.")
	our_mob.add_faction(FACTION_HERETIC)
	add_lunatic_hud(our_mob)
	ADD_TRAIT(our_mob, TRAIT_MADNESS_IMMUNE, REF(src))

/datum/antagonist/lunatic/remove_innate_effects(mob/living/mob_override)
	var/mob/living/our_mob = mob_override || owner.current
	handle_clown_mutation(our_mob, removing = FALSE)
	our_mob.remove_faction(FACTION_HERETIC)
	remove_lunatic_hud(our_mob)
	REMOVE_TRAIT(our_mob, TRAIT_MADNESS_IMMUNE, REF(src))

/**
 * AQUILA - wspólny HUD szaleńców i przewodnika (tg: add_team_hud).
 * Nasza lista GLOB.huds jest indeksowana definami, więc - jak arena - dopisujemy własny HUD na koniec listy.
 */
/datum/antagonist/lunatic/proc/get_lunatic_hud_index()
	var/static/hud_index
	if(isnull(hud_index))
		var/datum/atom_hud/antag/lunatic_hud = new()
		GLOB.huds += lunatic_hud
		hud_index = length(GLOB.huds)
	return hud_index

/datum/antagonist/lunatic/proc/add_lunatic_hud(mob/living/our_mob)
	if(!our_mob?.mind)
		return
	add_antag_hud(get_lunatic_hud_index(), lunatic_hud_state, our_mob)

/datum/antagonist/lunatic/proc/remove_lunatic_hud(mob/living/our_mob)
	if(!our_mob)
		return
	remove_antag_hud(get_lunatic_hud_index(), our_mob)

// Mood event given to moon acolytes
/datum/mood_event/heretics/lunatic
	description = "<span class='nicegreen'>PRAWDA OBJAWIONA, KŁAMSTWO ZABITE.</span>\n"
	mood_change = 10

/datum/objective/lunatic
	explanation_text = "Pomagaj swojemu przewodnikowi. Jeśli to widzisz, przewiń czat w górę, by sprawdzić kto nim jest, i zgłoś to"
	var/datum/mind/master
	// If the person with this objective is a lunatic master
	var/is_master = FALSE

/datum/objective/lunatic/check_completion()
	return TRUE

/datum/objective/lunatic/update_explanation_text()
	. = ..()
	if(is_master)
		explanation_text = "Prowadź swoich szaleńców ku własnym celom!"
		return
	explanation_text = "Pomagaj swojemu przewodnikowi [master], nie krzywdź innych szaleńców."

// Lunatic master
/datum/antagonist/lunatic/master
	name = "\improper Ringleader"
	lunatic_hud_state = "lunatic_master"

/datum/antagonist/lunatic/master/on_gain()
	var/datum/objective/lunatic/loony = new()
	loony.owner = owner
	objectives += loony
	loony.is_master = TRUE
	loony.update_explanation_text()
	return ..()

/datum/antagonist/lunatic/master/greet()
	to_chat(owner.current, span_userdanger("Jesteś przewodnikiem parady. Szaleńcy pójdą za tobą!"))
	owner.announce_objectives()

/datum/antagonist/lunatic/master/apply_innate_effects(mob/living/mob_override)
	var/mob/living/our_mob = mob_override || owner.current
	add_lunatic_hud(our_mob)

/datum/antagonist/lunatic/master/remove_innate_effects(mob/living/mob_override)
	var/mob/living/our_mob = mob_override || owner.current
	remove_lunatic_hud(our_mob)
