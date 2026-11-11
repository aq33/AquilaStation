// AQUILA: port of BeeStation/BeeStation-Hornet code/modules/mob/living/basic/pets/gondolas/gondola.dm (bee/master 0adf0fe9ae)
// Polish texts of our simple animal gondola. Silence stays as our IsVocal() override.
#define GONDOLA_HEIGHT pick(list("gondola_body_long", "gondola_body_medium", "gondola_body_short"))
#define GONDOLA_COLOR pick(list("#A87855", "#915E48", "#683E2C"))
#define GONDOLA_MOUSTACHE pick(list("gondola_moustache_large", "gondola_moustache_small"))
#define GONDOLA_EYES pick(list("gondola_eyes_close", "gondola_eyes_far"))

/mob/living/basic/pet/gondola
	name = "gondola"
	real_name = "gondola"
	desc = "Gondola to milczący wędrowiec. Nie mając rąk, uosabia taoistyczną zasadę wu-wei (niedziałania), a jej uśmiechnięta mina wyraża całkowitą i bezwarunkową akceptację świata takim, jakim jest. Jej skóra jest niezwykle cenna."
	icon = 'icons/mob/gondolas.dmi'
	icon_state = "gondola"
	icon_living = "gondola"

	maxHealth = 200
	health = 200
	faction = list(FACTION_GONDOLA)
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "pstryka"
	response_harm_continuous = "kopie"
	ai_controller = /datum/ai_controller/basic_controller/gondola

	//Gondolas aren't affected by cold.
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	basic_mob_flags = DEL_ON_DEATH
	gold_core_spawnable = FRIENDLY_SPAWN // AQUILA: our gondolas come from gold cores

/mob/living/basic/pet/gondola/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "uśmiecha się!")
	AddElement(/datum/element/death_drops, get_death_loot())
	create_gondola()

/**
 * Loot drops on death, since it deletes itself on death (like trooper).
 * AQUILA: one static list per type. Bee's string_list() keys the cache by the paths alone, so the gondola and the
 * gondola pod (same paths, other counts) shared whichever list was made first.
 */
/mob/living/basic/pet/gondola/proc/get_death_loot()
	var/static/list/loot = list(
		/obj/effect/decal/cleanable/blood/gibs = 1,
		/obj/item/stack/sheet/animalhide/gondola = 1,
		/obj/item/food/meat/slab/gondola = 1,
	)
	return loot

/mob/living/basic/pet/gondola/proc/create_gondola()
	icon_state = null
	icon_living = null
	var/height = GONDOLA_HEIGHT
	var/mutable_appearance/body_overlay = mutable_appearance(icon, height)
	var/mutable_appearance/eyes_overlay = mutable_appearance(icon, GONDOLA_EYES)
	var/mutable_appearance/moustache_overlay = mutable_appearance(icon, GONDOLA_MOUSTACHE)
	body_overlay.color = GONDOLA_COLOR

	//Offset the face to match the Gondola's height.
	switch(height)
		if("gondola_body_medium")
			eyes_overlay.pixel_y = -4
			moustache_overlay.pixel_y = -4
		if("gondola_body_short")
			eyes_overlay.pixel_y = -8
			moustache_overlay.pixel_y = -8

	cut_overlays(TRUE)
	add_overlay(body_overlay)
	add_overlay(eyes_overlay)
	add_overlay(moustache_overlay)

/mob/living/basic/pet/gondola/IsVocal() //Gondolas are the silent walker.
	return FALSE

/datum/ai_controller/basic_controller/gondola
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_traits = STOP_MOVING_WHEN_PULLED
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking

#undef GONDOLA_HEIGHT
#undef GONDOLA_COLOR
#undef GONDOLA_MOUSTACHE
#undef GONDOLA_EYES
