// Tatuaże z tg (tgstation/tgstation#72457): zestaw do tatuaży, komponent tatuażu na kończynie, tatuaże więźniów z poprzednich rund.

/obj/item/tattoo_kit
	name = "zestaw do tatuażu"
	desc = "Zestaw ze wszystkim, czego trzeba, żeby przegrać zakład albo podjąć inną wyjątkowo nieodwracalną decyzję."
	icon = 'aquila/icons/obj/memory.dmi'
	icon_state = "tattoo_kit"
	w_class = WEIGHT_CLASS_SMALL
	///each use = 1 tattoo
	var/uses = 1
	///how many uses can be stored
	var/max_uses = 5

/obj/item/tattoo_kit/examine(mob/tattoo_artist)
	. = ..()
	if(!uses)
		. += "<span class='warning'>W zestawie skończył się tusz!</span>"
	else
		. += "<span class='notice'>Tuszu wystarczy jeszcze na tatuaże: [uses].</span>"
	. += "<span class='boldnotice'>Można go uzupełnić kartridżem z tonerem.</span>"
	. += "<span class='notice'>Bez trybu walki kliknij kogoś zestawem, żeby wytatuować na wybranej części ciała jedno ze swoich wspomnień.</span>"

/obj/item/tattoo_kit/attackby(obj/item/I, mob/living/user, params)
	if(!istype(I, /obj/item/toner))
		return ..()
	var/obj/item/toner/ink_cart = I
	var/added_amount = round(ink_cart.charges / 5)
	if(added_amount == 0)
		balloon_alert(user, "toner jest pusty!")
		return TRUE
	if(uses >= max_uses)
		balloon_alert(user, "zestaw jest pełny!")
		return TRUE

	uses = min(uses + added_amount, max_uses)
	qdel(ink_cart)
	balloon_alert(user, "dolano tuszu")
	return TRUE

/obj/item/tattoo_kit/attack(mob/living/tattoo_holder, mob/living/tattoo_artist)
	if(!tattoo_artist.mind || tattoo_artist.combat_mode || !iscarbon(tattoo_holder))
		return ..()
	INVOKE_ASYNC(src, PROC_REF(try_tattoo), tattoo_holder, tattoo_artist)
	return TRUE

/obj/item/tattoo_kit/proc/try_tattoo(mob/living/carbon/tattoo_holder, mob/living/tattoo_artist)
	if(!uses)
		balloon_alert(tattoo_artist, "za mało tuszu!")
		return
	if(!tattoo_artist.mind.has_story_memory())
		balloon_alert(tattoo_artist, "nie masz nic wartego wytatuowania!")
		return
	var/selected_zone = check_zone(tattoo_artist.zone_selected)
	var/obj/item/bodypart/tattoo_target = tattoo_holder.get_bodypart(selected_zone)
	if(!tattoo_target)
		balloon_alert(tattoo_artist, "brak kończyny do tatuowania!")
		return
	if(HAS_TRAIT_FROM(tattoo_target, TRAIT_NOT_ENGRAVABLE, ENGRAVED_TRAIT))
		balloon_alert(tattoo_artist, "ta część ciała ma już tatuaż!")
		return
	if(HAS_TRAIT(tattoo_target, TRAIT_NOT_ENGRAVABLE) || !IS_ORGANIC_LIMB(tattoo_target))
		balloon_alert(tattoo_artist, "tej części ciała nie da się wytatuować!")
		return
	var/datum/memory/memory_to_tattoo = tattoo_artist.mind.select_memory("wytatuować")
	if(!memory_to_tattoo || QDELETED(memory_to_tattoo) || !tattoo_artist.Adjacent(tattoo_holder) || tattoo_holder.get_bodypart(selected_zone) != tattoo_target)
		return

	tattoo_artist.visible_message("<span class='notice'>[tattoo_artist] zaczyna tatuować coś na ciele: [tattoo_holder] ([tattoo_target.name])...</span>", \
		"<span class='notice'>Zaczynasz tatuować: [tattoo_holder] ([tattoo_target.name])...</span>")
	if(!do_after(tattoo_artist, 5 SECONDS, target = tattoo_holder))
		return
	if(!uses || QDELETED(memory_to_tattoo) || tattoo_holder.get_bodypart(selected_zone) != tattoo_target || HAS_TRAIT(tattoo_target, TRAIT_NOT_ENGRAVABLE))
		return
	tattoo_target.AddComponent(/datum/component/tattoo, memory_to_tattoo.generate_story(STORY_TATTOO))
	uses--
	//prevent this memory from being used again this round
	memory_to_tattoo.memory_flags |= MEMORY_FLAG_ALREADY_USED
	tattoo_artist.visible_message("<span class='notice'>[tattoo_artist] kończy tatuaż: [tattoo_holder] ([tattoo_target.name]).</span>")

/**
 * ### tattoo component!
 *
 * component for bodyparts that lets you examine it (and its owner) to read a story (+ art element yay)
 */
/datum/component/tattoo
	///the generated story string
	var/tattoo_description

/datum/component/tattoo/Initialize(tattoo_description)
	. = ..()
	if(!isbodypart(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/bodypart/tatted_limb = parent

	if(!tattoo_description)
		return COMPONENT_INCOMPATIBLE
	src.tattoo_description = tattoo_description
	tatted_limb.AddElement(/datum/element/art/commoner, 15)

/datum/component/tattoo/Destroy(force, silent)
	if(!parent)
		return ..()
	parent.RemoveElement(/datum/element/art/commoner, 15)
	return ..()

/datum/component/tattoo/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	ADD_TRAIT(parent, TRAIT_NOT_ENGRAVABLE, ENGRAVED_TRAIT)

/datum/component/tattoo/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)
	REMOVE_TRAIT(parent, TRAIT_NOT_ENGRAVABLE, ENGRAVED_TRAIT)

/datum/component/tattoo/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += "<span class='boldnotice'>[tattoo_description]</span>"

/// Tekst tatuażu przy oglądaniu właściciela kończyny, o ile ubranie go nie zasłania
/datum/component/tattoo/proc/owner_examine_text(mob/living/carbon/bodypart_owner, list/examine_list)
	var/obj/item/bodypart/tatted_limb = parent
	for(var/obj/item/clothing/possibly_blocking in bodypart_owner.get_equipped_items())
		if(possibly_blocking.body_parts_covered & tatted_limb.body_part) //check to see if something is obscuring their tattoo.
			return

	examine_list += "<span class='notice'>Na tej części ciała ([tatted_limb.name]) widać tatuaż!</span>"
	examine_list += "<span class='boldnotice'>[tattoo_description]</span>"

// AQUILA: w tg tatuaż rejestruje COMSIG_ATOM_EXAMINE na właścicielu. U nas oglądanie człowieka tego sygnału nie wysyła,
// więc tatuaże dopisuje nadpisanie examine (przy okazji działa to po przeszczepieniu kończyny).
/mob/living/carbon/human/examine(mob/user)
	. = ..()
	for(var/obj/item/bodypart/part as anything in bodyparts)
		var/datum/component/tattoo/tattoo = part.GetComponent(/datum/component/tattoo)
		tattoo?.owner_examine_text(src, .)

// ---------------------------------------------------------------- tatuaże więźniów

/// Ile tatuaży z poprzednich rund trafia na więźniów w jednej rundzie (tg: liczba miejsc profesji więźnia)
#define PRISONER_TATTOOS_PER_ROUND 4

///Loads all tattoos, and select a few for this round's prisoners.
/datum/controller/subsystem/persistence/proc/load_prisoner_tattoos()
	var/json_file = file(PRISONER_TATTOO_SAVE_FILE)
	if(!fexists(json_file))
		return
	var/list/json = json_decode(file2text(json_file))
	if(!json)
		return

	if(json["version"] < TATTOO_PERSISTENCE_VERSION)
		update_prisoner_tattoos(json)

	var/list/entries = json["entries"]
	if(length(entries))
		for(var/index in 1 to PRISONER_TATTOOS_PER_ROUND)
			prison_tattoos_to_use += list(entries[rand(1, length(entries))])

	log_world("Loaded [length(prison_tattoos_to_use)] prison tattoos")

///Saves all tattoos, so they can appear on prisoners in future rounds
/datum/controller/subsystem/persistence/proc/save_prisoner_tattoos()
	if(!length(prison_tattoos_to_save))
		return
	var/json_file = file(PRISONER_TATTOO_SAVE_FILE)
	var/list/saved_data = list()
	var/list/entries = list()

	if(fexists(json_file))
		var/list/old_json = json_decode(file2text(json_file))
		if(old_json)
			entries += old_json["entries"]  //Save the old if its there

	entries += prison_tattoos_to_save

	saved_data["version"] = TATTOO_PERSISTENCE_VERSION
	saved_data["entries"] = entries

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(saved_data))

///This proc can update entries if the format has changed at some point.
/datum/controller/subsystem/persistence/proc/update_prisoner_tattoos(json)
	//Save it to the file
	var/json_file = file(PRISONER_TATTOO_SAVE_FILE)
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))

	return json

/// Daje więźniowi tatuaże z opowieści wyrytych w poprzednich rundach (tg: liczba zależna od wagi przestępstwa)
/proc/apply_prisoner_tattoos(mob/living/carbon/human/new_prisoner, amount)
	var/list/limbs_to_tat = new_prisoner.bodyparts.Copy()
	for(var/i in 1 to amount)
		if(!length(SSpersistence.prison_tattoos_to_use) || !length(limbs_to_tat))
			return
		var/obj/item/bodypart/tatted_limb = pick_n_take(limbs_to_tat)
		var/list/tattoo = pick_n_take(SSpersistence.prison_tattoos_to_use)
		tatted_limb.AddComponent(/datum/component/tattoo, tattoo["story"])

#undef PRISONER_TATTOOS_PER_ROUND
