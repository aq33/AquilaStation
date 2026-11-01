/obj/effect/decal/cleanable/blood/writing
	icon = 'aquila/icons/bloodcult/effects.dmi'
	icon_state = "nothing"
	random_icon_states = null
	can_dry = FALSE

/datum/action/cooldown/blood_doodle
	name = "Krwawy Bazgroł"
	desc = "Wypisz na podłodze krwią wiadomość, którą zobaczą inni."
	button_icon_state = "cult_word"
	icon_icon = 'aquila/icons/bloodcult/spells.dmi'
	button_icon = 'aquila/icons/bloodcult/spells.dmi'
	background_icon_state = "const_spell_base"

	var/override = FALSE

// AQUILA - w drafcie PreActivate()/Activate() z akcji tg; u nas /datum/action/cooldown ma tylko Trigger().
// Sprawdzenie zaćmienia w drafcie niczego nie blokowało (wynik był ignorowany), więc go nie ma.
/datum/action/cooldown/blood_doodle/Trigger()
	if(!..())
		return FALSE
	INVOKE_ASYNC(src, PROC_REF(draw_doodle))
	return TRUE

/datum/action/cooldown/blood_doodle/proc/draw_doodle()
	var/turf/parent_turf = get_turf(owner)

	if(locate(/obj/effect/decal/cleanable/blood/writing) in parent_turf)
		to_chat(owner, span_cultbold("Tu już jest krwawy rysunek."))
		return

	var/obj/effect/decal/cleanable/blood/blood = locate(/obj/effect/decal/cleanable/blood) in parent_turf
	if(!blood)
		to_chat(owner, span_cultbold("Nie ma tu krwi, którą można by pisać!"))
		return

	var/blood_color = blood.color || COLOR_BLOOD

	var/maximum_length = 30
	var/message = stripped_input(owner, "Napisz wiadomość. Zobaczysz jej podgląd.", "Krwawe napisy", "")
	if(!message || QDELETED(src) || !owner)
		return
	message = copytext_char(message, 1, maximum_length)

	var/letter_amount = length(replacetext(message, " ", ""))
	if(!letter_amount) //If there is no text
		return

	// AQUILA - czcionka YouMurderer nie ma polskich liter
	var/shown_message = youmurderer_safe_text(message)

	var/angle = rand(-25, 25)
	var/image/preview = image(icon = null)
	preview.maptext = MAPTEXT_YOU_MURDERER("<span style = 'text-align: center; -dm-text-outline: 1px black; color:[blood_color]'> [shown_message] </span>")
	preview.maptext_height = 64
	preview.maptext_width = 128
	preview.maptext_x = -48
	preview.maptext_y = 8
	preview.alpha = 180
	preview.loc = parent_turf
	preview.transform = matrix(angle, MATRIX_ROTATE)

	owner.client?.images.Add(preview)
	var/continue_drawing = tgui_alert(owner, "Tak będzie wyglądać twoja wiadomość. Kontynuować?", "Krwawe napisy", list("Tak", "Anuluj"))
	owner?.client?.images.Remove(preview)
	animate(preview)
	preview.loc = null

	if(continue_drawing != "Tak" || QDELETED(blood))
		return

	message_admins("[key_name_admin(owner)] tworzy krwawy napis o treści: [message] [ADMIN_JMP(parent_turf)]")
	log_game("[key_name(owner)] created a blood doodle containing the phrase: [message] at [AREACOORD(parent_turf)]")
	var/obj/effect/decal/cleanable/blood/writing/spawned_writing = new /obj/effect/decal/cleanable/blood/writing(parent_turf)
	spawned_writing.color = blood_color

	spawned_writing.maptext = MAPTEXT_YOU_MURDERER("<span style = 'text-align: center; -dm-text-outline: 1px black; color:[blood_color]'> [shown_message] </span>")
	spawned_writing.maptext_height = 64
	spawned_writing.maptext_width = 128
	spawned_writing.maptext_x = -48
	spawned_writing.maptext_y = 8
	spawned_writing.transform = matrix(angle, MATRIX_ROTATE)
	qdel(blood)
