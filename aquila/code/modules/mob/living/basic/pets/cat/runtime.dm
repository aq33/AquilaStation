// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/pets/cat/runtime.dm (bee/master 0adf0fe9ae)
// Our save stays (data/npc_saves/Runtime.json, "family" = kitten type -> count, written when the round ends alive or on death).
// Saves from the simple animal Runtime name the old kitten paths; they are read into the basic mob paths.
#define RUNTIME_SAVE_DATA "data/npc_saves/Runtime.sav"
#define RUNTIME_JSON_DATA "data/npc_saves/Runtime.json"
#define MAX_CAT_DEPLOY 25

//RUNTIME IS ALIVE! SQUEEEEEEEE~
/mob/living/basic/pet/cat/runtime
	name = "Runtime"
	desc = "GCAT"
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	held_state = "cat"
	gender = FEMALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	///the family we will bring in when a round starts (kitten type -> count)
	var/list/family = list()
	///kittens born this round
	var/list/children = list()
	/// have we deployed the cats?
	var/cats_deployed = FALSE
	/// have we saved memory?
	var/memory_saved = FALSE

/mob/living/basic/pet/cat/runtime/Initialize(mapload)
	// The breeding component is added in the parent call and keeps the callback it gets there
	post_birth_callback = CALLBACK(src, PROC_REF(after_birth))
	if(prob(5))
		icon_state = "original"
		icon_living = "original"
		icon_dead = "original_dead"
	read_memory()
	return ..()

/mob/living/basic/pet/cat/runtime/Destroy()
	children = null
	return ..()

/mob/living/basic/pet/cat/runtime/Life(seconds, times_fired)
	if(!cats_deployed && SSticker.current_state >= GAME_STATE_SETTING_UP)
		deploy_the_cats()
	if(!stat && SSticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		write_memory()
		memory_saved = TRUE
	return ..()

/mob/living/basic/pet/cat/runtime/death(gibbed)
	if(!memory_saved)
		write_memory(TRUE)
	return ..()

/mob/living/basic/pet/cat/runtime/proc/after_birth(mob/living/baby)
	if(isnull(baby))
		return
	children += baby

/mob/living/basic/pet/cat/runtime/proc/read_memory()
	var/list/saved_family
	if(fexists(RUNTIME_SAVE_DATA)) //legacy compatability to convert old format to new
		var/savefile/save_data = new(RUNTIME_SAVE_DATA)
		save_data["family"] >> saved_family
		fdel(RUNTIME_SAVE_DATA)
	else
		var/json_file = file(RUNTIME_JSON_DATA)
		if(!fexists(json_file))
			return
		var/list/json_list = json_decode(rustg_file_read(json_file))
		saved_family = json_list["family"]
	family = list()
	for(var/saved_type in saved_family)
		var/cat_type = saved_type
		// Saves of the simple animal Runtime name the old simple_animal/pet/cat paths (JSON keeps the path as text)
		if(istext(cat_type))
			cat_type = text2path(replacetext(cat_type, "simple_animal/pet/cat", "basic/pet/cat"))
		if(!ispath(cat_type, /mob/living/basic/pet/cat))
			continue
		family[cat_type] += saved_family[saved_type]

/mob/living/basic/pet/cat/runtime/proc/write_memory(dead)
	var/json_file = file(RUNTIME_JSON_DATA)
	var/list/file_data = list()
	family = list()
	if(!dead)
		for(var/mob/living/basic/pet/cat/kitten/kitten in children)
			if(istype(kitten, type) || kitten.stat || !kitten.z || !kitten.butcher_results) //That last one is a work around for hologram cats
				continue
			family[kitten.type] += 1
	file_data["family"] = family
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/mob/living/basic/pet/cat/runtime/proc/deploy_the_cats()
	cats_deployed = TRUE
	for(var/cat_type in family)
		for(var/index in 1 to min(family[cat_type], MAX_CAT_DEPLOY)) //Limits to about 25 cats, prevents catsplosions.
			new cat_type(loc)

#undef RUNTIME_SAVE_DATA
#undef RUNTIME_JSON_DATA
#undef MAX_CAT_DEPLOY
