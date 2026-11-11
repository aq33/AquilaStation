// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/pets/dog/security_dog.dm (decision D11: only with Polish texts).
// Tyson is a map spawner: at round start it turns into the security dog of the last shift (name, sex, breed, how many shifts
// it served, from data/npc_saves/security_dog.json) or a new random one. A dog alive at round end keeps the posting.
// Changes against Bee: Polish examine lines; no Cardigan corgi (we do not have it, its share goes to the corgi); the dog bed
// is renamed by the component itself (our update_owner() only takes plain dog beds); placed in security on every votable ship (instead of Walter on Padalec and Trawnik).
#define SECURITY_DOG_MEMORY_FILE "data/npc_saves/security_dog.json"

GLOBAL_LIST_INIT(security_dog_male_names, list(
	"Ace",
	"Bandit",
	"Boomer", //The equivalent of calling your pet 'cheeseburger'
	"Bruno",
	"Diesel",
	"Duke",
	"Gunner",
	"Hobbes",
	"Hunk",
	"Kaiser",
	"Magnum",
	"Nero",
	"Ranger",
	"Rex",
	"Rocco",
	"Titus",
	"Tyson",
	"Walder", //Walter but ASOIAF :)
	"Walter",
	"Walther",
))

GLOBAL_LIST_INIT(security_dog_female_names, list(
	"Athena", //The coolest greek goddess, obv
	"Freya",
	"Juno",
	"Lillith",
	"Luna",
	"Maple",
	"Nyx",
	"Princess", //Pitbull name, but canon
	"Roxy",
	"Sable",
	"Scout", //Apparentely a girl's name
	"Trixie",
	"Valkyrie",
	"Vega",
))

/**
 * Typepath we can use to spawn. Technically doesn't even have to be a dog
 */
GLOBAL_LIST_INIT(security_dog_breeds, list(
	/mob/living/basic/pet/dog/bullterrier = 40,
	/mob/living/basic/pet/dog/pug = 10,
	/mob/living/basic/pet/dog/corgi = 50,
))

/**
 * Attempt to steal last shifts dog. (This is shitty Ian code)
 * AQUILA: read_save = FALSE gives a new random dog without looking at the save (test chamber dog).
 */
/proc/requisition_security_dog(read_save = TRUE)
	var/json_file = file(SECURITY_DOG_MEMORY_FILE)
	if(read_save && fexists(json_file))
		var/list/save_data
		// AQUILA: a corrupt save gives a new dog and is removed, instead of a runtime and no dog in any round
		try
			save_data = json_decode(rustg_file_read(json_file))
		catch
			save_data = null
		if(!islist(save_data))
			fdel(json_file)
		else if(save_data["name"])
			//Sanity check the breed still exists
			var/saved_breed = text2path(save_data["breed"])
			if(saved_breed in GLOB.security_dog_breeds)
				return list(
					"name" = save_data["name"],
					"gender" = save_data["gender"] == FEMALE ? FEMALE : MALE,
					"breed" = saved_breed,
					"tenure" = isnum(save_data["tenure"]) ? save_data["tenure"] : 0,
				)

	var/new_gender = prob(50) ? MALE : FEMALE
	return list(
		"name" = pick(new_gender == FEMALE ? GLOB.security_dog_female_names : GLOB.security_dog_male_names),
		"gender" = new_gender,
		"breed" = pick_weight(GLOB.security_dog_breeds),
		"tenure" = 0,
	)

/datum/component/security_dog
	///Breed name, grab from type
	var/breed
	///How many shifts this dog has survived
	var/tenure = 0
	///We make a callback if his ass survived to the end
	var/datum/callback/survival_check
	///Is your fate sealed?
	var/memory_saved = FALSE
	/// AQUILA: does this dog write the save of the ship's dog (FALSE for the test chamber dog)
	var/persistent = TRUE

/datum/component/security_dog/Initialize(dog_name, dog_gender, dog_tenure = 0, persistent = TRUE)
	. = ..()
	if(!istype(parent, /mob/living/basic/pet/dog))
		return COMPONENT_INCOMPATIBLE

	tenure = dog_tenure
	src.persistent = persistent
	var/mob/living/basic/pet/dog/dog = parent
	//Grab real_name before overwriting
	breed = dog.real_name
	dog.gender = dog_gender
	dog.unique_pet = TRUE
	dog.fully_replace_character_name(null, dog_name)

	claim_dogbed(dog)

	survival_check = CALLBACK(src, PROC_REF(check_survival))
	SSticker.OnRoundend(survival_check)

	RegisterSignal(parent, COMSIG_MOB_DEATH, PROC_REF(on_death))
	RegisterSignal(parent, COMSIG_LIVING_REVIVE, PROC_REF(on_revive))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/security_dog/Destroy(force)
	LAZYREMOVE(SSticker.round_end_events, survival_check)
	survival_check = null
	return ..()

/datum/component/security_dog/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_DEATH, COMSIG_LIVING_REVIVE, COMSIG_PARENT_EXAMINE))

/**
 * The dogbed is static, so we just overwrite it with the dogs name
 */
/datum/component/security_dog/proc/claim_dogbed(mob/living/dog)
	var/area/dog_area = get_area(dog)
	if(!dog_area)
		return
	for(var/obj/structure/bed/dogbed/tyson/bed in dog_area)
		if(bed.z != dog.z)
			continue
		bed.owned = TRUE
		bed.name = "legowisko: [dog]"
		bed.desc = "Legowisko, które należy do: [dog]. Wygląda wygodnie."
		return

/**
 * The security posting is described here rather than baked into desc, because the corgi
 * breeds reset their desc back to the type default every time their hat changes.
 */
/datum/component/security_dog/proc/on_examine(mob/living/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("To pies ochrony ([breed]) i traktuje tę służbę o wiele poważniej niż większość tych matołów.")
	if(tenure)
		examine_list += span_notice("Zmiany na tym posterunku z rzędu: [tenure].")

/datum/component/security_dog/proc/on_death(mob/living/source, gibbed)
	SIGNAL_HANDLER
	write_memory(dead = TRUE)

/datum/component/security_dog/proc/on_revive(mob/living/source)
	SIGNAL_HANDLER
	//Back on the roster, so let the roundend check save us again.
	memory_saved = FALSE

///Roundend check: if we're still standing, we keep the posting.
/datum/component/security_dog/proc/check_survival()
	var/mob/living/dog = parent
	if(!dog.stat)
		write_memory(dead = FALSE)

///Records this dog for next shift. A dead dog leaves no save behind, which is what makes the randomiser spin.
/datum/component/security_dog/proc/write_memory(dead)
	var/mob/living/dog = parent
	if(memory_saved || !persistent)
		return
	memory_saved = TRUE

	var/json_file = file(SECURITY_DOG_MEMORY_FILE)
	fdel(json_file)
	if(dead)
		return

	var/list/file_data = list(
		"name" = dog.real_name,
		"gender" = dog.gender,
		"breed" = "[dog.type]",
		"tenure" = tenure + 1,
	)
	WRITE_FILE(json_file, json_encode(file_data))

/// The bed of the security dog; the dog renames it when it reports for duty
/obj/structure/bed/dogbed/tyson
	name = "legowisko psa ochrony"
	desc = "Legowisko psa ochrony. Pachnie kawą z posterunku."
	anchored = TRUE

/**
 * The dog. basically a map spawner we swap in at init for whatever breed/name got chosen
 */
/mob/living/basic/pet/dog/bullterrier/tyson
	name = "Tyson"
	real_name = "Tyson"
	gender = MALE
	desc = "Krzepki bulterier o przyjaznym, ale czujnym usposobieniu."
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	/// AQUILA: does the dog on duty come from and go to the ship dog's save
	var/persistent = TRUE

/// AQUILA: the test chamber Tyson: a new random dog that never reads or writes the ship dog's save
/mob/living/basic/pet/dog/bullterrier/tyson/test_chamber
	persistent = FALSE

/mob/living/basic/pet/dog/bullterrier/tyson/Initialize(mapload)
	. = ..()
	if(mapload)
		return INITIALIZE_HINT_LATELOAD
	report_for_duty()
	return INITIALIZE_HINT_QDEL

/mob/living/basic/pet/dog/bullterrier/tyson/LateInitialize()
	. = ..()
	report_for_duty()
	qdel(src)

///Swaps mr hardcoded out: makes the dog on duty here and returns it (the spawner deletes itself)
/mob/living/basic/pet/dog/bullterrier/tyson/proc/report_for_duty()
	var/turf/kennel = get_turf(src)
	if(!kennel)
		return
	var/list/on_duty = requisition_security_dog(persistent)
	var/breed = on_duty["breed"]
	var/mob/living/basic/pet/dog/dog = new breed(kennel)
	dog.AddComponent(/datum/component/security_dog, on_duty["name"], on_duty["gender"], on_duty["tenure"], persistent)
	return dog

#undef SECURITY_DOG_MEMORY_FILE
