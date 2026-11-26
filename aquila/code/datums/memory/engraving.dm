// Ryciny w ścianach z tg (tgstation/tgstation#60302): dłuto, element wall_engraver, komponent engraved i zapis między rundami.

/**
 * # engraved component!
 *
 * component for walls that applies an engraved overlay and lets you examine it to read a story (+ art element yay)
 * new creations will get a high art value, cross round scrawlings will get a low one.
 * MUST be a component, though it doesn't look like it. SSPersistence demandeth
 */
/datum/component/engraved
	///the generated story string
	var/engraved_description
	///whether this is a new engraving, or a persistence loaded one.
	var/persistent_save
	///what random icon state should the engraving have
	var/icon_state_append
	///The story value of this piece.
	var/story_value
	/// Wartość elementu art, żeby zdjąć go z tymi samymi argumentami
	var/art_value

/datum/component/engraved/Initialize(engraved_description, persistent_save, story_value)
	. = ..()
	if(!isclosedturf(parent))
		return COMPONENT_INCOMPATIBLE
	var/turf/closed/engraved_wall = parent

	src.engraved_description = engraved_description
	src.persistent_save = persistent_save
	src.story_value = story_value

	var/beauty_value
	switch(story_value)
		if(STORY_VALUE_KEY)
			beauty_value = 0 // what is this
		if(STORY_VALUE_SHIT)
			beauty_value = rand(-50, 50) //Ugly or mediocre at best
		if(STORY_VALUE_NONE)
			beauty_value = rand(0, 100) //No inherent value
		if(STORY_VALUE_MEH)
			beauty_value = rand(100, 200) //Its an okay tale
		if(STORY_VALUE_OKAY)
			beauty_value = rand(150, 300) //Average story! most things are like this
		if(STORY_VALUE_AMAZING)
			beauty_value = rand(300, 600)//Really impactful stories, seeing a lost limb, losing a loved pet.
		if(STORY_VALUE_LEGENDARY)
			beauty_value = rand(500, 800) //Almost always a good story! this is for memories you can barely ever get, killing megafauna, doing ultimate feats!
		else
			beauty_value = 0

	// AQUILA: nie mamy piękna pomieszczeń (element beauty), więc stara rycina traci na wartości samej sztuki
	art_value = beauty_value / ENGRAVING_BEAUTY_TO_ART_FACTOR
	if(!persistent_save)
		art_value /= ENGRAVING_PERSISTENCE_BEAUTY_LOSS_FACTOR //Old age does them harm
	engraved_wall.AddElement(/datum/element/art, art_value)
	icon_state_append = rand(1, 2)
	//must be here to allow overlays to be updated
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	engraved_wall.update_icon()

/datum/component/engraved/Destroy(force, silent)
	if(!parent)
		return ..()
	parent.RemoveElement(/datum/element/art, art_value)
	//must be here to allow overlays to be updated
	UnregisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS)
	if(!QDELETED(parent))
		var/atom/parent_atom = parent
		parent_atom.update_icon()
	return ..() //call this after since we null out the parent

/datum/component/engraved/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	//supporting component transfer means putting these here instead of initialize
	SSpersistence.wall_engravings += src
	ADD_TRAIT(parent, TRAIT_NOT_ENGRAVABLE, ENGRAVED_TRAIT)

/datum/component/engraved/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)
	//supporting component transfer means putting these here instead of destroy
	SSpersistence.wall_engravings -= src
	REMOVE_TRAIT(parent, TRAIT_NOT_ENGRAVABLE, ENGRAVED_TRAIT)

/// Used to maintain the engraving overlay on the parent [/atom].
/datum/component/engraved/proc/on_update_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	// AQUILA: nad narożnikami starego wygładzania ścian (icon_smoothing.dm dokłada je osobno przy każdym przewygładzeniu)
	overlays += mutable_appearance('aquila/icons/turf/wall_engravings.dmi', "engraving[icon_state_append]", ABOVE_NORMAL_TURF_LAYER)

///signal called on parent being examined
/datum/component/engraved/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += "<span class='boldnotice'>[engraved_description]</span>"

///returns all the information SSpersistence needs in a list to load up this engraving on a future round!
/datum/component/engraved/proc/save_persistent()
	var/list/saved_data = list()
	saved_data["story"] = engraved_description
	saved_data["story_value"] = story_value

	return list(saved_data)

/// An element that lets you engrave walls when right click is used
/datum/element/wall_engraver
	element_flags = ELEMENT_DETACH

/datum/element/wall_engraver/Attach(datum/target)
	. = ..()

	if (!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(target, COMSIG_ITEM_PRE_ATTACK_SECONDARY, PROC_REF(on_item_pre_attack_secondary))

/datum/element/wall_engraver/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_PARENT_EXAMINE, COMSIG_ITEM_PRE_ATTACK_SECONDARY))

///signal called on parent being examined
/datum/element/wall_engraver/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += "<span class='notice'>Kliknij ścianę [user.secondary_click_text()], żeby wyryć w niej jedno ze swoich wspomnień.</span>"

///signal called on parent being used to right click attack something
/datum/element/wall_engraver/proc/on_item_pre_attack_secondary(datum/source, atom/target, mob/living/user)
	SIGNAL_HANDLER

	if(!isclosedturf(target))
		return NONE
	INVOKE_ASYNC(src, PROC_REF(try_chisel), source, target, user)
	return COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN

/datum/element/wall_engraver/proc/try_chisel(obj/item/item, turf/closed/wall, mob/living/user)
	if(!istype(wall) || !user.mind)
		return
	if(HAS_TRAIT_FROM(wall, TRAIT_NOT_ENGRAVABLE, ENGRAVED_TRAIT))
		user.balloon_alert(user, "ta ściana ma już rycinę!")
		return
	if(HAS_TRAIT(wall, TRAIT_NOT_ENGRAVABLE) || istype(wall, /turf/closed/indestructible))
		user.balloon_alert(user, "w tej ścianie nie da się ryć!")
		return
	if(!user.mind.has_story_memory())
		user.balloon_alert(user, "nie masz nic wartego wyrycia!")
		return
	var/datum/memory/memory_to_engrave = user.mind.select_memory("wyryć")
	if(!memory_to_engrave || QDELETED(memory_to_engrave))
		return
	if(!user.Adjacent(wall))
		return
	item.add_fingerprint(user)
	playsound(item, item.hitsound, 30, TRUE, -1)
	user.do_attack_animation(wall)
	user.balloon_alert(user, "ryjesz w ścianie...")
	if(!do_after(user, 5 SECONDS, target = wall))
		return
	if(QDELETED(memory_to_engrave) || !isclosedturf(wall) || HAS_TRAIT(wall, TRAIT_NOT_ENGRAVABLE))
		return
	user.balloon_alert(user, "wyryto rycinę")
	user.do_attack_animation(wall)

	var/do_persistent_save = !(memory_to_engrave.memory_flags & MEMORY_FLAG_NOPERSISTENCE)
	var/engraved_story = memory_to_engrave.generate_story(STORY_ENGRAVING, STORY_FLAG_DATED)

	if(!engraved_story)
		CRASH("Tried to submit a memory with an invalid story [memory_to_engrave]")

	if(!wall.AddComponent(/datum/component/engraved, engraved_story, do_persistent_save, memory_to_engrave.story_value))
		return
	memory_to_engrave.memory_flags |= MEMORY_FLAG_ALREADY_USED
	//while someone just engraved a story "worth engraving" we should add this to SSpersistence for a possible prison tattoo

	if(do_persistent_save)
		var/list/tattoo_entry = list()

		var/tattoo_story = memory_to_engrave.generate_story(STORY_TATTOO)

		if(!tattoo_story)
			CRASH("Tried to submit a memory with an invalid story [memory_to_engrave]")

		tattoo_entry["story"] = tattoo_story
		SSpersistence.prison_tattoos_to_save += list(tattoo_entry)

/// Dłuto z tg (bez rzeźbienia posągów, którego u nas nie ma): ryje wspomnienia w ścianach
/obj/item/chisel
	name = "dłuto"
	desc = "Psuje i tworzy sztukę od 4000 lat przed naszą erą. Można nim wyryć w ścianie własne wspomnienie."
	icon = 'aquila/icons/obj/memory.dmi'
	icon_state = "chisel"
	item_state = "screwdriver_nuke"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 5
	w_class = WEIGHT_CLASS_TINY
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	custom_materials = list(/datum/material/iron = 75)
	attack_verb = list("dźga")
	hitsound = 'sound/weapons/bladeslice.ogg'
	usesound = list('sound/effects/picaxe1.ogg', 'sound/effects/picaxe2.ogg', 'sound/effects/picaxe3.ogg')
	sharpness = IS_SHARP
	tool_behaviour = TOOL_RUSTSCRAPER
	toolspeed = 3 // You're gonna have a bad time

/obj/item/chisel/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/wall_engraver)

/datum/design/chisel
	name = "Dłuto"
	id = "chisel"
	build_type = AUTOLATHE
	materials = list(/datum/material/iron = 75)
	build_path = /obj/item/chisel
	category = list("initial", "Misc")

// ---------------------------------------------------------------- zapis między rundami

/datum/controller/subsystem/persistence
	///instantiated wall engraving components
	var/list/wall_engravings = list()
	///all saved persistent engravings loaded from JSON
	var/list/saved_engravings = list()
	///tattoo stories that we're saving.
	var/list/prison_tattoos_to_save = list()
	///tattoo stories that have been selected for this round.
	var/list/prison_tattoos_to_use = list()

/datum/controller/subsystem/persistence/Initialize()
	. = ..()
	load_wall_engravings()
	load_prisoner_tattoos()

/datum/controller/subsystem/persistence/CollectData()
	. = ..()
	save_wall_engravings()
	save_prisoner_tattoos()

/// Ściany, na których mogą pojawić się stare ryciny i z których ryciny są zapisywane (tg: obszary z PERSISTENT_ENGRAVINGS)
/proc/engraving_persistent_area(area/place)
	return istype(place, /area/maintenance) || istype(place, /area/security/prison)

///Loads all engravings, and places a select amount in maintenance and the prison.
/datum/controller/subsystem/persistence/proc/load_wall_engravings()
	var/json_file = file(ENGRAVING_SAVE_FILE)
	if(!fexists(json_file))
		return

	var/json_text = file2text(json_file)
	if(!rustg_json_is_valid(json_text))
		return

	var/list/json = json_decode(json_text)
	if(json["version"] < ENGRAVING_PERSISTENCE_VERSION)
		update_wall_engravings(json)

	saved_engravings = json["entries"]

	if(!length(saved_engravings))
		log_world("Failed to load engraved messages on map [SSmapping.config.map_name]")
		return

	var/list/turfs_to_pick_from = list()
	for(var/area/place as anything in GLOB.sortedAreas)
		if(!engraving_persistent_area(place))
			continue
		for(var/turf/closed/wall/candidate in place)
			if(!is_station_level(candidate.z) || HAS_TRAIT(candidate, TRAIT_NOT_ENGRAVABLE))
				continue
			turfs_to_pick_from += candidate

	var/successfully_loaded_engravings = 0
	var/list/engravings_left = saved_engravings.Copy()

	for(var/iteration in 1 to min(rand(MIN_PERSISTENT_ENGRAVINGS, MAX_PERSISTENT_ENGRAVINGS), length(engravings_left)))
		if(!length(turfs_to_pick_from))
			break
		var/engraving = pick_n_take(engravings_left)
		if(!islist(engraving))
			stack_trace("something's wrong with the engraving data! one of the saved engravings wasn't a list!")
			continue

		var/turf/closed/engraved_wall = pick_n_take(turfs_to_pick_from)
		engraved_wall.AddComponent(/datum/component/engraved, engraving["story"], FALSE, engraving["story_value"])
		successfully_loaded_engravings++

	log_world("Loaded [successfully_loaded_engravings] engraved messages on map [SSmapping.config.map_name]")

///Saves all new engravings in the world.
/datum/controller/subsystem/persistence/proc/save_wall_engravings()
	var/list/saved_data = list()

	saved_data["version"] = ENGRAVING_PERSISTENCE_VERSION
	saved_data["entries"] = list()

	var/json_file = file(ENGRAVING_SAVE_FILE)
	if(fexists(json_file))
		var/list/old_json = json_decode(file2text(json_file))
		if(old_json)
			saved_data["entries"] = old_json["entries"]

	var/new_entries = 0
	for(var/datum/component/engraved/engraving in wall_engravings)
		if(!engraving.persistent_save)
			continue
		if(!engraving_persistent_area(get_area(engraving.parent)))
			continue
		saved_data["entries"] += engraving.save_persistent()
		new_entries++

	if(!new_entries && !fexists(json_file))
		return

	fdel(json_file)
	WRITE_FILE(json_file, json_encode(saved_data))

///This proc can update entries if the format has changed at some point.
/datum/controller/subsystem/persistence/proc/update_wall_engravings(json)
	//Save it to the file
	var/json_file = file(ENGRAVING_SAVE_FILE)
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(json))

	return json
