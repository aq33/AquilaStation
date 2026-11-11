// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/pets/dog/corgi.dm (bee/master 0adf0fe9ae)
// Polish names and lines from our simple animal corgis, our Ian persistence (data/npc_saves/Ian.json, same keys).
// Not ported: deadchat plays, cardigan corgis.

//CORGIS!

/mob/living/basic/pet/dog/corgi
	name = "\improper corgi"
	real_name = "corgi"
	desc = "To corgi."
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	held_state = "corgi"
	butcher_results = list(/obj/item/food/meat/slab/corgi = 3, /obj/item/stack/sheet/animalhide/corgi = 1)
	gold_core_spawnable = FRIENDLY_SPAWN
	collar_icon_state = "corgi"
	worn_slot_flags = ITEM_SLOT_HEAD
	ai_controller = /datum/ai_controller/basic_controller/dog/corgi
	///Can this corgi be shaved by an electric razor?
	var/can_be_shaved = TRUE
	///Did this corgi get mutilated and has had their fur shaved by an electric razor, oh the humanity?
	var/shaved = FALSE
	///Currently worn item on the head slot
	var/obj/item/inventory_head = null
	///Currently worn item on the back slot
	var/obj/item/inventory_back = null
	///Is this corgi physically slow due to age, etc?
	var/is_slow = FALSE
	///Item slots that are available for this corgi to equip stuff into
	var/list/strippable_inventory_slots = list()
	///can this mob breed?
	var/can_breed = TRUE

/mob/living/basic/pet/dog/corgi/examine(mob/user)
	. = ..()
	if(access_card)
		. += "Ma przypiętą [icon2html(access_card, user)] [access_card]."

/mob/living/basic/pet/dog/corgi/Initialize(mapload)
	. = ..()
	update_appearance()
	// AQUILA: one strippable list per corgi type (bespoke element, a fresh list per puppy made a new element each)
	var/static/list/strippable_lists_by_type = list()
	var/list/strippable_items = GLOB.strippable_corgi_items
	if(length(strippable_inventory_slots))
		strippable_items = strippable_lists_by_type[type]
		if(!strippable_items)
			strippable_items = create_strippable_list(strippable_inventory_slots)
			strippable_lists_by_type[type] = strippable_items
	AddElement(/datum/element/strippable, strippable_items)
	RegisterSignals(src, list(COMSIG_BASICMOB_LOOK_ALIVE, COMSIG_BASICMOB_LOOK_DEAD), PROC_REF(on_appearance_change))
	if(can_breed)
		add_breeding_component()

/mob/living/basic/pet/dog/corgi/Destroy()
	QDEL_NULL(inventory_head)
	QDEL_NULL(inventory_back)
	UnregisterSignal(src, list(COMSIG_BASICMOB_LOOK_ALIVE, COMSIG_BASICMOB_LOOK_DEAD))
	return ..()

/mob/living/basic/pet/dog/corgi/handle_atom_del(atom/deleting_atom)
	if(deleting_atom == inventory_head)
		inventory_head = null
		update_corgi_fluff()
		update_appearance(UPDATE_OVERLAYS)
	if(deleting_atom == inventory_back)
		inventory_back = null
		update_corgi_fluff()
		update_appearance(UPDATE_OVERLAYS)
	if(deleting_atom == access_card)
		access_card = null
	return ..()

/mob/living/basic/pet/dog/corgi/gib()
	if(inventory_head)
		inventory_head.forceMove(drop_location())
		inventory_head = null
	if(inventory_back)
		inventory_back.forceMove(drop_location())
		inventory_back = null
	if(access_card)
		access_card.forceMove(drop_location())
		access_card = null
	return ..()

/mob/living/basic/pet/dog/corgi/proc/add_breeding_component()
	var/static/list/baby_paths = list(
		/mob/living/basic/pet/dog/corgi/puppy = 95,
		/mob/living/basic/pet/dog/corgi/puppy/void = 5,
	)
	AddComponent(\
		/datum/component/breed,\
		can_breed_with = typecacheof(list(/mob/living/basic/pet/dog/corgi)),\
		baby_paths = baby_paths,\
	)

/**
 * Corgis get full protection from their equipped fashion items if attacked in a way that passes def_zone,
 * which usually means any direct attack like melee or gunshot. Anything abstract like a bomb or acid or something
 * will instead give half the armor value.
 */
/mob/living/basic/pet/dog/corgi/getarmor(def_zone, type)
	var/armorval = 0

	if(def_zone)
		if(def_zone == BODY_ZONE_HEAD)
			if(inventory_head)
				armorval = inventory_head.get_armor_rating(type, src)
		else
			if(inventory_back)
				armorval = inventory_back.get_armor_rating(type, src)
		return armorval
	else
		if(inventory_head)
			armorval += inventory_head.get_armor_rating(type, src)
		if(inventory_back)
			armorval += inventory_back.get_armor_rating(type, src)
	return armorval * 0.5

/mob/living/basic/pet/dog/corgi/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/razor))
		if(shaved)
			to_chat(user, span_warning("Nie możesz ogolić tego corgi, już jest ogolony!"))
			return
		if(!can_be_shaved)
			to_chat(user, span_warning("Nie możesz ogolić tego corgi, nie ma futra!"))
			return
		user.visible_message("[user] zaczyna golić [src] za pomocą [attacking_item].", span_notice("Zaczynasz golić [src] za pomocą [attacking_item]..."))
		if(do_after(user, 5 SECONDS, target = src))
			user.visible_message("[user] goli sierść [src] za pomocą [attacking_item].")
			playsound(get_turf(src), 'sound/items/welder2.ogg', 20, TRUE)
			shaved = TRUE
			icon_living = "[icon_living]_shaved"
			icon_dead = "[icon_living]_dead"
			if(stat == CONSCIOUS)
				icon_state = icon_living
			else
				icon_state = icon_dead
		return TRUE

	. = ..()
	update_corgi_fluff()

/mob/living/basic/pet/dog/corgi/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	. = ..()

	if(inventory_head?.dog_fashion)
		var/datum/dog_fashion/equipped_head_fashion_item = new inventory_head.dog_fashion(src)
		equipped_head_fashion_item.apply_to_speech(speech)

	if(inventory_back?.dog_fashion)
		var/datum/dog_fashion/equipped_back_fashion_item = new inventory_back.dog_fashion(src)
		equipped_back_fashion_item.apply_to_speech(speech)

/mob/living/basic/pet/dog/corgi/update_overlays()
	. = ..()
	if(inventory_head?.dog_fashion) // AQUILA: a hat without fashion (old saves, admin edits) would runtime on new null
		var/image/head_icon
		var/datum/dog_fashion/equipped_head_fashion_item = new inventory_head.dog_fashion(src)

		if(!equipped_head_fashion_item.obj_icon_state)
			equipped_head_fashion_item.obj_icon_state = inventory_head.icon_state
		if(!equipped_head_fashion_item.obj_alpha)
			equipped_head_fashion_item.obj_alpha = inventory_head.alpha
		if(!equipped_head_fashion_item.obj_color)
			equipped_head_fashion_item.obj_color = inventory_head.color

		if(stat == DEAD || HAS_TRAIT(src, TRAIT_FAKEDEATH))
			head_icon = equipped_head_fashion_item.get_overlay(dir = EAST)
			head_icon.pixel_y = -8
			head_icon.transform = head_icon.transform.Turn(180)
		else
			head_icon = equipped_head_fashion_item.get_overlay()

		. += head_icon

	if(inventory_back?.dog_fashion)
		var/image/back_icon
		var/datum/dog_fashion/equipped_back_fashion_item = new inventory_back.dog_fashion(src)

		if(!equipped_back_fashion_item.obj_icon_state)
			equipped_back_fashion_item.obj_icon_state = inventory_back.icon_state
		if(!equipped_back_fashion_item.obj_alpha)
			equipped_back_fashion_item.obj_alpha = inventory_back.alpha
		if(!equipped_back_fashion_item.obj_color)
			equipped_back_fashion_item.obj_color = inventory_back.color

		if(stat == DEAD || HAS_TRAIT(src, TRAIT_FAKEDEATH))
			back_icon = equipped_back_fashion_item.get_overlay(dir = EAST)
			back_icon.pixel_y = -11
			back_icon.transform = back_icon.transform.Turn(180)
		else
			back_icon = equipped_back_fashion_item.get_overlay()

		. += back_icon

/**
 * Places an item on the corgi's head, handling updating the corgi's appearance and the item's dog fashion modifiers
 * to the name, description, speech etc. Doesn't need the user to complete, and is also used in station traits/events/persistence reading.
*/
/mob/living/basic/pet/dog/corgi/proc/place_on_head(obj/item/item_to_add, mob/living/user)
	if(inventory_head)
		if(user)
			to_chat(user, span_warning("Nie możesz założyć [src] więcej niż jednej czapki!"))
		return
	if(!item_to_add)
		user.visible_message(span_notice("[user] głaszcze [src]."), span_notice("Kładziesz na chwilę dłoń na głowie [src]."))
		if(flags_1 & HOLOGRAM_1)
			return
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, REF(src), /datum/mood_event/pet_animal, src)
		return

	if(user && !user.temporarilyRemoveItemFromInventory(item_to_add))
		to_chat(user, span_warning("[item_to_add] przykleił się do twojej ręki, nie możesz założyć go [src] na głowę!"))
		return

	var/valid = FALSE
	if(ispath(item_to_add.dog_fashion, /datum/dog_fashion/head))
		valid = TRUE

	//Various hats and items (worn on his head) change Ian's behaviour. His attributes are reset when a hat is removed.

	if(valid)
		if(user && (stat == DEAD || HAS_TRAIT(src, TRAIT_FAKEDEATH)))
			to_chat(user, span_notice("W oczach [real_name] widać tylko tępe, martwe spojrzenie, gdy zakładasz mu [item_to_add]."))
		else if(user)
			user.visible_message("[user] zakłada [item_to_add] na głowę [real_name].  [src] patrzy na [user] i raz szczeka.",
				span_notice("Zakładasz [item_to_add] na głowę [real_name].  [src] patrzy na ciebie dziwnie, po czym raz macha ogonem i szczeka."),
				"<span class='italics'>Słyszysz przyjaźnie brzmiące szczeknięcie.</span>")
		item_to_add.forceMove(src)
		inventory_head = item_to_add
		update_corgi_fluff()
		update_appearance(UPDATE_OVERLAYS)
	else
		to_chat(user, span_warning("Kładziesz [item_to_add] na głowie [src], ale spada!"))
		item_to_add.forceMove(drop_location())
		if(prob(25))
			step_rand(item_to_add)
		INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, emote), "spin")

	return valid

/mob/living/basic/pet/dog/corgi/proc/update_corgi_fluff()
	// First, change back to defaults
	name = real_name
	desc = initial(desc)
	// BYOND/DM doesn't support the use of initial on lists.
	speak_emote = list("szczeka", "hauka")
	set_light(0)

	if(inventory_head?.dog_fashion)
		var/datum/dog_fashion/equipped_head_fashion_item = new inventory_head.dog_fashion(src)
		equipped_head_fashion_item.apply(src)

	if(inventory_back?.dog_fashion)
		var/datum/dog_fashion/equipped_back_fashion_item = new inventory_back.dog_fashion(src)
		equipped_back_fashion_item.apply(src)

///Handles updating any existing overlays for the corgi (such as fashion items) when it changes how it appears, as in, dead or alive.
/mob/living/basic/pet/dog/corgi/proc/on_appearance_change()
	SIGNAL_HANDLER
	update_appearance(UPDATE_OVERLAYS)

//SUBTYPES!

/mob/living/basic/pet/dog/corgi/exoticcorgi
	name = "egzotyczny corgi"
	desc = "Tak samo uroczy, jak kolorowy!"
	icon = 'icons/mob/pets.dmi'
	icon_state = "corgigrey"
	icon_living = "corgigrey"
	icon_dead = "corgigrey_dead"
	can_be_shaved = FALSE
	worn_slot_flags = null

/mob/living/basic/pet/dog/corgi/exoticcorgi/Initialize(mapload)
	. = ..()
	var/newcolor = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)

//IAN! SQUEEEEEEEEE~
/mob/living/basic/pet/dog/corgi/ian
	name = "Ian"
	real_name = "Ian" //Intended to hold the name without altering it.
	gender = MALE
	desc = "To ukochany corgi Starszego Oficera."
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	///Tracks how many rounds did Ian survive from start to finish
	var/age = 0
	///Highest achieved consecutive rounds that Ian survived from start to finish
	var/record_age = 1
	///Whether we have already recorded this Ian's achievements(survival and equipped hat) to the database
	var/memory_saved = FALSE
	///Path of the item Ian was wearing in a previous shift, if he survived through it
	var/saved_head = null

/mob/living/basic/pet/dog/corgi/ian/Initialize(mapload)
	. = ..()

	//parent call must happen first to ensure IAN
	//is not in nullspace when child puppies spawn
	Read_Memory()
	if(age == 0)
		var/turf/target = get_turf(loc)
		if(target)
			new /mob/living/basic/pet/dog/corgi/puppy/ian(target)
			Write_Memory(FALSE)
			return INITIALIZE_HINT_QDEL
	else if(age == record_age)
		icon_state = "old_corgi"
		icon_living = "old_corgi"
		held_state = "old_corgi"
		icon_dead = "old_corgi_dead"
		desc = "W sędziwym wieku [record_age] lat Ian nie jest już tak żwawy jak kiedyś, ale zawsze pozostanie ukochanym corgi Starszego Oficera." //RIP
		ai_controller?.set_blackboard_key(BB_DOG_IS_SLOW, TRUE)
		is_slow = TRUE
		set_varspeed(2)

/mob/living/basic/pet/dog/corgi/ian/Life(seconds, times_fired)
	if(!stat && SSticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		Write_Memory(FALSE)
		memory_saved = TRUE
	return ..()

/mob/living/basic/pet/dog/corgi/ian/death(gibbed)
	if(!memory_saved)
		Write_Memory(TRUE)
	return ..()

/mob/living/basic/pet/dog/corgi/ian/narsie_act()
	playsound(src, 'sound/magic/demon_dies.ogg', 75, TRUE)
	var/mob/living/basic/pet/dog/corgi/narsie/narsIan = new(loc)
	narsIan.setDir(dir)
	investigate_log("has been gibbed and replaced with Nars-Ian by Nar'Sie.", INVESTIGATE_DEATHS)
	gib()

/// Reads Ian's age, record and hat from data/npc_saves/Ian.json (or the legacy Ian.sav, converted on read)
/mob/living/basic/pet/dog/corgi/ian/proc/Read_Memory()
	if(fexists("data/npc_saves/Ian.sav")) //legacy compatability to convert old format to new
		var/savefile/S = new /savefile("data/npc_saves/Ian.sav")
		S["age"] >> age
		S["record_age"] >> record_age
		S["saved_head"] >> saved_head
		fdel("data/npc_saves/Ian.sav")
	else
		var/json_file = file("data/npc_saves/Ian.json")
		if(!fexists(json_file))
			return
		var/list/json
		// AQUILA: a corrupt save is removed and Ian starts as a puppy, instead of a runtime in Initialize()
		try
			json = json_decode(rustg_file_read(json_file))
		catch
			json = null
		if(!islist(json))
			fdel(json_file)
		else
			age = json["age"]
			record_age = json["record_age"]
			saved_head = json["saved_head"]
	if(isnull(age))
		age = 0
	if(isnull(record_age))
		record_age = 1
	// The save keeps the hat as a type path written as text; a hat removed since then is just forgotten
	if(istext(saved_head))
		saved_head = text2path(saved_head)
	if(ispath(saved_head, /obj/item))
		place_on_head(new saved_head)
	else
		saved_head = null

/// Writes Ian's age, record and hat; a dead Ian starts again from a puppy
/mob/living/basic/pet/dog/corgi/ian/proc/Write_Memory(dead)
	var/json_file = file("data/npc_saves/Ian.json")
	var/list/file_data = list()
	if(!dead)
		file_data["age"] = age + 1
		if((age + 1) > record_age)
			file_data["record_age"] = record_age + 1
		else
			file_data["record_age"] = record_age
		if(inventory_head)
			file_data["saved_head"] = inventory_head.type
		else
			file_data["saved_head"] = null
	else
		file_data["age"] = 0
		file_data["record_age"] = record_age
		file_data["saved_head"] = null
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

//NARS-IAN! SQ-Q-QooEglor-r'EEn-nl-luEEEf-f-fth-h
/mob/living/basic/pet/dog/corgi/narsie
	name = "Nars-Ian"
	real_name = "Nars-Ian"
	desc = "Ia! Ia!"
	icon_state = "narsian"
	icon_living = "narsian"
	icon_dead = "narsian_dead"
	faction = list(FACTION_NEUTRAL, FACTION_CULT)
	speak_emote = list("warczy", "szczeka złowieszczo")
	gold_core_spawnable = NO_SPAWN
	can_be_shaved = FALSE
	unique_pet = TRUE
	held_state = "narsian"
	worn_slot_flags = null

/mob/living/basic/pet/dog/corgi/narsie/Life(seconds, times_fired)
	. = ..()
	//consume simple_animal pets
	for(var/mob/living/simple_animal/pet/simple_pet in range(1, src))
		if(simple_pet != src)
			devour_pet(simple_pet)
	for(var/mob/living/basic/pet/basic_pet in range(1, src))
		if(basic_pet != src && !istype(basic_pet, /mob/living/basic/pet/dog/corgi/narsie))
			devour_pet(basic_pet)

/// Nars-Ian eats a pet's soul and body
/mob/living/basic/pet/dog/corgi/narsie/proc/devour_pet(mob/living/pet)
	visible_message(span_warning("[src] pożera [pet]!"), \
	span_cultbigbold("PYSZNE DUSZE"))
	playsound(src, 'sound/magic/demon_attack1.ogg', 75, TRUE)
	narsie_act()
	if(pet.mind)
		if(pet.mind.hasSoul)
			pet.mind.hasSoul = FALSE //Nars-Ian ate your soul; you don't have one anymore
		else
			visible_message("<span class='cult big bold'>... Ech, ktoś mnie ubiegł.</span>")
	pet.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
	pet.gib()

/mob/living/basic/pet/dog/corgi/narsie/update_corgi_fluff()
	..()
	speak_emote = list("warczy", "szczeka złowieszczo")

/mob/living/basic/pet/dog/corgi/narsie/update_dog_speech(datum/ai_planning_subtree/random_speech/speech)
	speech.speak = string_list(list("Tari'karat-pasnar!", "IA! IA!", "BRRUUURGHGHRHR"))
	speech.emote_hear = string_list(list("szczeka echem!", "hauka upiornie!", "ujada w nieziemski sposób.", "mamrocze coś niewypowiedzianego."))
	speech.emote_see = string_list(list("obcuje z bezimiennym.", "rozważa pożarcie kilku dusz.", "trzęsie się."))

/mob/living/basic/pet/dog/corgi/narsie/narsie_act()
	if(stat == DEAD) //Nar'Sie loves her doggy
		visible_message(span_warning("[src] powstaje znowu, ożywiony mroczną magią!"), \
		"<span class='cult large'>POWSTAŃ</span>")
		revive(full_heal = TRUE, admin_revive = TRUE) //also means that a dead Nars-Ian can consume a pet and revive
	adjustBruteLoss(-maxHealth)

//LISA! SQUEEEEEEEEE~
/mob/living/basic/pet/dog/corgi/lisa
	name = "Lisa"
	real_name = "Lisa"
	gender = FEMALE
	desc = "Rozdziera cię na kawałki."
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	icon_state = "lisa"
	icon_living = "lisa"
	icon_dead = "lisa_dead"
	held_state = "lisa"
	strippable_inventory_slots = list(/datum/strippable_item/corgi_back, /datum/strippable_item/pet_collar, /datum/strippable_item/corgi_id) //Lisa already has a cute bow!

//PUPPIES! SQUEEEEEEEEE~
/mob/living/basic/pet/dog/corgi/puppy
	name = "\improper szczeniak corgi"
	real_name = "corgi"
	desc = "To szczeniak corgi!"
	icon_state = "puppy"
	icon_living = "puppy"
	icon_dead = "puppy_dead"
	density = FALSE
	pass_flags = PASSMOB
	ai_controller = /datum/ai_controller/basic_controller/dog/puppy
	mob_size = MOB_SIZE_SMALL
	strippable_inventory_slots = list(/datum/strippable_item/pet_collar, /datum/strippable_item/corgi_id) //puppies are too small to handle hats and back slot items
	can_breed = FALSE
	collar_icon_state = "puppy"

//PUPPY IAN! SQUEEEEEEEEE~
/mob/living/basic/pet/dog/corgi/puppy/ian
	name = "Ian"
	real_name = "Ian"
	gender = MALE
	desc = "To ukochany szczeniak corgi Starszego Oficera."

/mob/living/basic/pet/dog/corgi/puppy/void //Tribute to the corgis born in nullspace
	name = "\improper szczeniak z pustki"
	real_name = "voidy"
	desc = "Szczeniak corgi nasycony energią głębokiego kosmosu. Odwzajemnia twoje spojrzenie..."
	gender = NEUTER
	icon_state = "void_puppy"
	icon_living = "void_puppy"
	icon_dead = "void_puppy_dead"
	can_be_shaved = FALSE
	held_state = "void_puppy"
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = TCMB
	maximum_survivable_temperature = T0C + 40

/mob/living/basic/pet/dog/corgi/puppy/void/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_AI_BAGATTACK, INNATE_TRAIT)

/mob/living/basic/pet/dog/corgi/puppy/void/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return 1 //Void puppies can navigate space.
