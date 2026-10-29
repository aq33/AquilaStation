
// AQUILA - u nas plik ikony zdolności to icon_icon, a button_icon to tło (odwrotnie niż w tg), panelu „Cult” nie ma
/datum/action/cooldown/spell/cult
	overlay_icon_state = "cult"
	icon_icon = 'aquila/icons/bloodcult/spells.dmi'
	spell_requirements = NONE
	var/pointed = FALSE

/datum/action/cooldown/spell/cult/is_valid_target(atom/cast_on)
	. = ..()
	if(cast_on != owner)
		return FALSE

// Not sure what to do with this spell really, it always kinda sucked and tomes as a whole need an overhaul. Runic Skin is a better power.
GLOBAL_LIST_EMPTY(arcane_pockets)

/datum/action/cooldown/spell/cult/arcane_dimension
	name = "Tajemny Wymiar (pusty)"
	desc = "Rzuć, trzymając Tajemną Księgę, by dyskretnie schować ją za zasłoną."
	button_icon_state = "cult_pocket_empty"
	icon_icon = 'aquila/icons/bloodcult/spells.dmi'
	button_icon = 'aquila/icons/bloodcult/spells.dmi'
	background_icon_state = "const_spell_base"
	invocation_type = INVOCATION_NONE
	var/obj/item/tome/stored_tome = null

/datum/action/cooldown/spell/cult/arcane_dimension/New()
	..()
	LAZYADD(GLOB.arcane_pockets, src)

/datum/action/cooldown/spell/cult/arcane_dimension/Destroy()
	LAZYREMOVE(GLOB.arcane_pockets, src)
	return ..()

/datum/action/cooldown/spell/cult/arcane_dimension/cast(mob/living/user)
	. = ..()
	if (user.occult_muted())
		to_chat(user, span_warning("Nie możesz sobie teraz przypomnieć, jak sięgnąć do swojego tajemnego wymiaru.") )
		return
	if (stored_tome)
		stored_tome.forceMove(get_turf(user))
		if (user.get_inactive_held_item() && user.get_active_held_item())//full hands
			to_chat(user, span_warning("Masz pełne ręce, więc [stored_tome] nie miała gdzie spaść, tylko na podłogę.") )
		else
			to_chat(user, span_notice("Unosisz dłoń wnętrzem do góry, a [stored_tome] spada w nią znikąd.") )
			user.put_in_hands(stored_tome)
		stored_tome = null
		name = "Tajemny Wymiar (pusty)"
		desc = "Rzuć, trzymając Tajemną Księgę, by dyskretnie schować ją za zasłoną."
		button_icon_state = "cult_pocket_empty"
		return

	var/obj/item/tome/held_tome = locate() in user.held_items
	if (held_tome)
		if (held_tome.state == TOME_OPEN)
			held_tome.icon_state = "tome"
			held_tome.state = TOME_CLOSED
		stored_tome = held_tome
		user.dropItemToGround(held_tome)
		held_tome.moveToNullspace()
		to_chat(user, span_notice("Szybkim ruchem ręki upuszczasz [held_tome], która znika w powietrzu, zanim dotknie ziemi.") )
		name = "Tajemny Wymiar (pełny)"
		desc = "Rzuć, by odzyskać Tajemną Księgę zza zasłony. Najlepiej miej wolną rękę."
		button_icon_state = "cult_pocket_full"


///////////////////////////////ASTRAL PROJECTION SPELLS/////////////////////////////////////


/datum/action/cooldown/spell/astral_return
	name = "Powrót do Ciała"
	desc = "Zakończ projekcję astralną i obudź się w swoim ciele. Jeśli zrobisz to, będąc namacalnym, możesz przestraszyć gapiów, więc uważaj."
	button_icon_state = "astral_return"
	icon_icon = 'aquila/icons/bloodcult/spells.dmi'
	button_icon = 'aquila/icons/bloodcult/spells.dmi'
	background_icon_state = "const_spell_base"
	spell_requirements = NONE


/datum/action/cooldown/spell/astral_return/cast(mob/living/user)
	. = ..()
	var/mob/living/simple_animal/astral_projection/astral = user
	if (istype(astral))
		astral.death()//pretty straightforward isn't it?

/datum/action/cooldown/spell/astral_toggle
	name = "Przełącz Namacalność"
	desc = "Zmień się w widoczną kopię swojego ciała, która może mówić i wpadać na drzwi. Pamiętaj jednak, że najmniejsze obrażenia rozwieją całą projekcję astralną."
	button_icon_state = "astral_toggle"
	icon_icon = 'aquila/icons/bloodcult/spells.dmi'
	button_icon = 'aquila/icons/bloodcult/spells.dmi'
	background_icon_state = "const_spell_base"
	spell_requirements = NONE

/datum/action/cooldown/spell/astral_toggle/cast(mob/living/user)
	. = ..()
	var/mob/living/simple_animal/astral_projection/astral = user
	if (!istype(astral))
		return
	astral.toggle_tangibility()
	if (astral.tangibility)
		desc = "Wróć do niewidzialnej projekcji swojej duszy."
	else
		desc = "Zmień się w widoczną kopię swojego ciała, która może mówić i wpadać na drzwi. Pamiętaj jednak, że najmniejsze obrażenia rozwieją całą projekcję astralną."
