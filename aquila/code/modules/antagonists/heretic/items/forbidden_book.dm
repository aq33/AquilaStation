// Ye old forbidden book, the Codex Cicatrix.
/obj/item/codex_cicatrix
	name = "Codex Cicatrix"
	desc = "Ten ciężki tom pełen jest tajemniczych bazgrołów i niemożliwych diagramów. \
		Według legendy da się z niego wyczytać sekrety zasłony między światami."
	icon = 'aquila/icons/obj/antags/eldritch.dmi'
	base_icon_state = "book"
	icon_state = "book"
	worn_icon_state = "book"
	w_class = WEIGHT_CLASS_SMALL
	/// Helps determine the icon state of this item when it's used on self.
	var/book_open = FALSE
	/// How fast we can drain influences
	var/drain_speed = 7.5 SECONDS
	/// How fast we can draw runes
	var/draw_speed = 15 SECONDS


/obj/item/codex_cicatrix/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "Usuwasz %THEEFFECT.", \
		on_clear_callback = CALLBACK(src, PROC_REF(after_clear_rune)), \
		effects_we_clear = list(/obj/effect/heretic_rune))

/// Callback for effect_remover component after a rune is deleted
/obj/item/codex_cicatrix/proc/after_clear_rune(obj/effect/target, mob/living/user)
	new /obj/effect/temp_visual/drawing_heretic_rune/fail(target.loc, target.greyscale_colors)

/obj/item/codex_cicatrix/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return

	. += span_notice("Pozwala wysysać wpływy za dodatkowe punkty wiedzy.")
	. += span_notice("Pozwala też łatwo rysować i usuwać runy transmutacji.")

/obj/item/codex_cicatrix/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return

	if(book_open)
		return

	open_animation()
	// AQUILA - u nas nie ma update_weight_class()
	w_class = WEIGHT_CLASS_NORMAL
	addtimer(CALLBACK(src, PROC_REF(close_book)), 30 SECONDS)

	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	var/datum/heretic_knowledge/spell/basic/grasp_knowledge = heretic_datum?.get_knowledge(/datum/heretic_knowledge/spell/basic)
	grasp_knowledge?.add_charges(CEILING(grasp_knowledge.max_charges * 0.5, 1))

/obj/item/codex_cicatrix/proc/close_book()
	close_animation()
	w_class = WEIGHT_CLASS_SMALL

/// AQUILA - tg: interact_with_atom; u nas afterattack
/obj/item/codex_cicatrix/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
	if(!heretic_datum)
		return
	if(isopenturf(target))
		var/obj/effect/heretic_influence/influence = locate(/obj/effect/heretic_influence) in target
		if(!influence?.drain_influence_with_codex(user, src))
			heretic_datum.try_draw_rune(user, target, drawing_time = draw_speed)
		return TRUE

/// Plays a little animation that shows the book opening and closing.
/obj/item/codex_cicatrix/proc/open_animation()
	icon_state = "[base_icon_state]_open"
	flick("[base_icon_state]_opening", src)
	book_open = TRUE

/// Plays a closing animation and resets the icon state.
/obj/item/codex_cicatrix/proc/close_animation()
	icon_state = base_icon_state
	flick("[base_icon_state]_closing", src)
	book_open = FALSE

// Upgraded version of the codex cicatrix that allows us to cast curses
/obj/item/codex_cicatrix/morbus // I'm morbing all over
	name = "Codex Morbus"
	desc = "Ohydna, postrzępiona księga pokryta osobno mrugającymi oczami, a wszystkie wpatrują się w ciebie. Nie masz pojęcia, jak to trzymać, i szczerze mówiąc nie wiesz, czy w ogóle chcesz."
	base_icon_state = "book_morbus"
	icon_state = "book_morbus"
	drain_speed = 5 SECONDS
	draw_speed = 10 SECONDS
	/// List of mobs we've cursed with transmutation. When the codex is destroyed all those curses become undone
	var/list/transmuted_victims = list()

/obj/item/codex_cicatrix/morbus/examine(mob/user)
	. = ..()
	if(IS_HERETIC(user))
		. += span_info("Klikając prawym przyciskiem w runę z krwią ofiary w drugiej ręce, rzucisz klątwę.")
		return
	. += span_danger("Oczy przestają mrugać. Wpatrują się w ciebie. Ich spojrzenie pali...")
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	to_chat(human_user, span_userdanger("Twój umysł płonie, gdy wpatrujesz się w strony!"))
	human_user.adjust_organ_loss(ORGAN_SLOT_BRAIN, 10, 190)
	human_user.add_mood_event("gates_of_mansus", /datum/mood_event/gates_of_mansus)

/// AQUILA - tg: interact_with_atom_secondary; u nas afterattack_secondary
/obj/item/codex_cicatrix/morbus/afterattack_secondary(atom/interacting_with, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag || !istype(interacting_with, /obj/effect/heretic_rune/big) || !IS_HERETIC(user))
		return ..()

	INVOKE_ASYNC(src, PROC_REF(cast_curse), interacting_with, user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/codex_cicatrix/morbus/proc/cast_curse(atom/interacting_with, mob/living/user)
	var/list/curse_list = list()
	for(var/datum/heretic_knowledge/curse/curses as anything in subtypesof(/datum/heretic_knowledge/curse))
		curse_list[initial(curses.name)] = curses
	var/selected_curse = tgui_input_list(user, "Rzuć dowolną klątwę", "Wybierz klątwę!", curse_list)
	if(!selected_curse)
		return

	if(!user.Adjacent(interacting_with))
		return

	var/atom/held_offhand = user.get_inactive_held_item()
	if(!held_offhand)
		user.balloon_alert(user, "brak katalizatora!")
		return
	var/list/blood_samples = list()
	for(var/blood in held_offhand.return_blood_DNA())
		blood_samples[blood] = 1
	for(var/datum/reagent/blood/usable_reagent as anything in held_offhand.reagents?.reagent_list)
		if(!istype(usable_reagent, /datum/reagent/blood))
			continue
		blood_samples += usable_reagent.data[BLOOD_DATA_DNA]
	if(!length(blood_samples))
		user.balloon_alert(user, "brak krwi!")
		return

	var/curse_type = curse_list[selected_curse]
	var/datum/heretic_knowledge/curse/to_cast = new curse_type
	to_cast.recipe_snowflake_check(user, list(held_offhand), loc = get_turf(user))
	to_cast.on_finished_recipe(user, list(src, held_offhand), loc = get_turf(user))

/obj/item/codex_cicatrix/morbus/obj_destruction(damage_flag)
	for(var/datum/weakref/to_uncurse_ref as anything in transmuted_victims)
		var/mob/to_uncurse = to_uncurse_ref.resolve()
		if(!to_uncurse || !ismob(to_uncurse))
			continue
		var/datum/heretic_knowledge/curse/transmutation/to_undo = new()
		to_undo.uncurse(to_uncurse)
		transmuted_victims -= to_uncurse_ref
	return ..()
