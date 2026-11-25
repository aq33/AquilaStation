// Procki pomocnicze wspomnień z tg (code/__HELPERS/memory_helpers.dm). Makra są w aquila/code/__DEFINES/memory.dm.

/datum/mind
	/// a list of /datum/memories. assoc type of memory = memory datum. only one type of memory will be stored, new ones of the same type overriding the last.
	var/list/memories = list()

/datum/mind/Destroy()
	QDEL_LIST_ASSOC_VAL(memories)
	return ..()

/// AQUILA: tg czyści tylko wspomnienia, u nas wipe_memory czyści też notatki tekstowe (..())
/datum/mind/wipe_memory()
	. = ..()
	QDEL_LIST_ASSOC_VAL(memories)

/// Unless you need to use this for an explicit reason, use the add_memory_in_range macro wrapper.
/proc/_add_memory_in_range(atom/source, range = 7, list/memory_args)
	for(var/mob/living/carbon/memorizer in hearers(range, source))
		memorizer.mind?._add_memory(memory_args.Copy()) // One copy for each memory, since it mutates the list

/// Unless you need to use this for an explicit reason, use the add_memory, add_mob_memory, or add_memory_in_range macro wrappers.
/datum/mind/proc/_add_memory(list/memory_args)
	RETURN_TYPE(/datum/memory)
	var/datum/memory/memory_type = memory_args[1]
	if(!ispath(memory_type, /datum/memory))
		CRASH("add_memory called with an invalid memory type. (Got: [memory_type || "null"])")

	if(current)
		var/new_memory_flags = initial(memory_type.memory_flags)
		// tg: IS_UNCONSCIOUS (nieprzytomny albo w ciężkim stanie, ale nie martwy)
		if(!(new_memory_flags & MEMORY_SKIP_UNCONSCIOUS) && current.stat == UNCONSCIOUS)
			return
		if(new_memory_flags & MEMORY_CHECK_BLINDNESS && is_blind(current))
			return
		if(new_memory_flags & MEMORY_CHECK_DEAFNESS && HAS_TRAIT(current, TRAIT_DEAF))
			return

	var/datum/memory/replaced_memory = memories[memory_type]
	if(replaced_memory)
		qdel(replaced_memory)

	memory_args[1] = src
	var/datum/memory/created_memory = new memory_type(arglist(memory_args))

	memories[memory_type] = created_memory
	return created_memory

/**
 * Simple / sane proc for giving a mob the option to select one of their memories
 * that do not have the flags [MEMORY_FLAG_ALREADY_USED] or [MEMORY_NO_STORY].
 *
 * Arguments
 * * verbage: tekst w oknie wyboru, mówi, do czego wybiera się wspomnienie („wyryć”, „wytatuować”)
 *
 * Returns the memory selected, or null otherwise.
 */
/datum/mind/proc/select_memory(verbage = "wykorzystać")
	RETURN_TYPE(/datum/memory)
	var/list/choice_list = list()

	for(var/key in memories)
		var/datum/memory/memory_iter = memories[key]
		if(memory_iter.memory_flags & (MEMORY_FLAG_ALREADY_USED|MEMORY_NO_STORY)) //Can't use memories multiple times
			continue
		choice_list[memory_iter.name] = memory_iter

	if(!length(choice_list))
		return null

	var/choice = tgui_input_list(usr, "Wybierz wspomnienie, które chcesz [verbage]", "Wybór wspomnienia", choice_list)
	if(isnull(choice))
		return null
	if(isnull(choice_list[choice]))
		return null
	return choice_list[choice]

/// Czy umysł ma wspomnienie, z którego da się zrobić opowieść (rycinę, tatuaż)
/datum/mind/proc/has_story_memory()
	for(var/key in memories)
		var/datum/memory/memory_iter = memories[key]
		if(!(memory_iter.memory_flags & (MEMORY_FLAG_ALREADY_USED|MEMORY_NO_STORY)))
			return TRUE
	return FALSE

/// Helder to wipe the passed memory type ONLY from our list of memories
/datum/mind/proc/wipe_memory_type(memory_type)
	qdel(memories[memory_type])
	memories -= memory_type

/// Helper to create quick copies of all of our memories
/// Quick copies aren't full copies - just basic copies containing necessities.
/// They cannot be used in stories.
/datum/mind/proc/quick_copy_all_memories(datum/mind/new_memorizer)
	for(var/memory_path in memories)
		var/datum/memory/prime_memory = memories[memory_path]
		new_memorizer.memories[memory_path] = prime_memory.quick_copy_memory(new_memorizer)

/// Okno notatek (MemoryPanel) dostaje listę wspomnień z oceną wartości historii, jak w tg
/datum/memory_panel/ui_data(mob/user)
	var/list/data = ..()
	var/list/memory_list = list()
	var/datum/mind/mind = user?.mind
	for(var/memory_key in mind?.memories)
		var/datum/memory/memory = mind.memories[memory_key]
		memory_list += list(list("name" = memory.name, "quality" = memory.story_value))
	data["memories"] = memory_list
	return data
