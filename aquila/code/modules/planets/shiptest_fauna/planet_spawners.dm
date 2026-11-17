// AQUILA: spawners of the planet fauna, ported from Shiptest (AGPLv3): the burrows of code/modules/mob_spawner/burrow.dm,
// the hivebot fabricator of mob_spawner/hivebot.dm, the carp puddle of mob_spawner/spawner.dm and the jungle chicken flock
// of code/game/objects/effects/spawners/mobspawner.dm. Sprite of the hivebot fabricator: Shiptest icons/obj/machines/
// hivebot_fabricator.dmi (CC BY-SA 3.0), copied to aquila/icons/planets/fauna/hivebot_fabricator.dmi.
// Changes against Shiptest:
// - the mobs are our basic mobs (planet fauna of this folder, our goliath, legion, hivelord, carp, bat, snake); the nest
//   legions and goliaths of the burrows are our spawner_made/nest variants without loot bodies or hides;
// - the jungle burrow's bat and snake and the asteroid burrow's carp are our basic bat, snake and carp;
// - the hivebot fabricator spawns our four hivebots (Shiptest's mechanic and core hivebots are not here) and drops scrap
//   metal instead of Shiptest's hivebot beacon loot.

/// Burrow of the ice planets: wolves and polar bears
/obj/structure/spawner/burrow/ice_planet
	mob_types = list(
		/mob/living/basic/mining/wolf = 1,
		/mob/living/basic/mining/polarbear = 1,
	)

/// Deeper burrow of the ice planets: the nasty ones
/obj/structure/spawner/burrow/ice_planet/hard
	mob_types = list(
		/mob/living/basic/mining/brimdemon = 35,
		/mob/living/basic/mining/legion/snow/spawner_made = 35,
		/mob/living/basic/mining/ice_whelp = 15,
		/mob/living/basic/mining/ice_demon = 15,
	)

/// Burrow of the jungle planets
/obj/structure/spawner/burrow/jungle_planet
	mob_types = list(
		/mob/living/basic/mining/wolf = 1, // nie wolf/random: ten usuwa się w Initialize, a spawner zapisuje usuniętego
		/mob/living/basic/bat = 1,
		/mob/living/basic/snake = 1,
	)

/// Burrow of the rock planets: gruboids
/obj/structure/spawner/burrow/rock_plant
	mob_types = list(
		/mob/living/basic/mining/goliath/rockplanet = 1,
		/mob/living/simple_animal/hostile/asteroid/elite/broodmother_child/rockplanet = 1,
	)

/// Burrow of the sand planets
/obj/structure/spawner/burrow/sand_planet
	mob_types = list(
		/mob/living/basic/mining/legion/spawner_made = 40,
		/mob/living/basic/mining/basilisk/whitesands = 40,
		/mob/living/basic/mining/goliath/whitesands/nest = 20,
	)

/// Burrow of the asteroids
/obj/structure/spawner/burrow/asteroid
	mob_types = list(
		/mob/living/basic/mining/goliath = 1,
		/mob/living/basic/mining/hivelord = 1,
		/mob/living/basic/carp = 1,
	)

/// Puddle full of carp
/obj/structure/spawner/carp
	name = "kałuża z karpiami"
	desc = "Kałuża, w której chyba roi się od karpi."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "puddle"
	max_integrity = 150
	max_mobs = 5
	spawn_time = 2 MINUTES
	mob_types = list(/mob/living/basic/carp)
	spawn_text = "wypływa z"
	faction = list("carp")

/// Hivebot fabricator of the waste planets
/obj/structure/spawner/hivebot
	name = "fabrykator hivebotów"
	desc = "Działająca fabryka, której elektryczne macki wnikają w ziemię w poszukiwaniu złomu. Bije od niej głód."
	icon = 'aquila/icons/planets/fauna/hivebot_fabricator.dmi'
	icon_state = "hivefab"
	faction = list("hivebot")
	max_integrity = 250
	max_mobs = 3
	spawn_text = "wyłania się z"
	mob_types = list(
		/mob/living/basic/hivebot,
		/mob/living/basic/hivebot,
		/mob/living/basic/hivebot,
		/mob/living/basic/hivebot,
		/mob/living/basic/hivebot/range,
		/mob/living/basic/hivebot/range,
		/mob/living/basic/hivebot/range,
		/mob/living/basic/hivebot/range,
		/mob/living/basic/hivebot/rapid,
		/mob/living/basic/hivebot/strong,
	)
	resistance_flags = FIRE_PROOF | LAVA_PROOF
	light_range = 4
	light_power = 2.5
	light_color = COLOR_RED_LIGHT

/obj/structure/spawner/hivebot/deconstruct(disassembled = TRUE)
	var/turf/drop_turf = get_turf(src)
	if(drop_turf)
		playsound(drop_turf, 'sound/effects/explosionfar.ogg', 200, TRUE)
		visible_message(span_boldannounce("[src] zaczyna trząść się i grzechotać, sypiąc iskrami!"))
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(2, drop_turf)
		smoke.start()
		do_sparks(3, FALSE, drop_turf)
		new /obj/item/stack/sheet/iron(drop_turf, rand(5, 10))
	return ..()

/// A flock of jungle chickens (Shiptest: seven)
/obj/effect/spawner/lootdrop/jungle_chicken_flock
	name = "stado kur z dżungli"
	icon = 'icons/mob/animal.dmi'
	icon_state = "chicken_brown"
	lootcount = 7
	loot = list(/mob/living/basic/chicken = 1)
