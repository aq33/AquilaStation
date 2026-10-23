///a heretic that got soultrapped by cultists. does nothing, other than signify they suck
// AQUILA - w tg to dusza heretyka uwięziona w nawiedzonym ostrzu kultu; nasz kult jeszcze tego nie ma, rola zostaje dla adminów
/datum/antagonist/soultrapped_heretic
	name = "\improper Soultrapped Heretic"
	roundend_category = "heretycy"
	antagpanel_category = "Heretic"
	banning_key = ROLE_HERETIC
	antag_moodlet = /datum/mood_event/soultrapped_heretic

// Will never show up because they're shades inside a sword
/datum/mood_event/soultrapped_heretic
	description = "<span class='boldwarning'>Uwięzili mnie! Nie mogę uciec!</span>\n"
	mood_change = -20

// always failure obj
/datum/objective/heretic_trapped
	name = "soultrapped failure"
	explanation_text = "Pomóż kultowi. Zabij kult. Pomóż załodze. Zabij załogę. Pomóż temu, kto cię dzierży. Zabij tego, kto cię dzierży. Zabij wszystkich. Pobrzękuj łańcuchami. Zerwij więzy."

/datum/antagonist/soultrapped_heretic/apply_innate_effects(mob/living/mob_override)
	. = ..()
	add_antag_hud(ANTAG_HUD_HERETIC, "heretic", mob_override || owner.current)

/datum/antagonist/soultrapped_heretic/remove_innate_effects(mob/living/mob_override)
	remove_antag_hud(ANTAG_HUD_HERETIC, mob_override || owner.current)
	return ..()

/datum/antagonist/soultrapped_heretic/on_gain()
	..()
	to_chat(owner, span_ghostalert("Jesteś uwięzioną duszą heretyka, którym kiedyś byłeś. Możesz próbować przekonać tych, którzy cię dzierżą, by cię uwolnili, \
		co da ci trochę swobody, a im dostęp do części twoich mocy. Kult cię zniewolił, ale nie należysz do niego i zachowujesz resztki wolnej woli. \
		Poza tym niewiele ci zostaje poza komentowaniem. Postaraj się nie utknąć w szafce."))
	owner.current.log_message("was sacrificed to Nar'sie as a Heretic, and sealed inside a longsword.", LOG_GAME)
	var/datum/objective/epic_fail = new /datum/objective/heretic_trapped()
	epic_fail.completed = FALSE
	objectives += epic_fail
