// AQUILA: nora (burrow) - port of Shiptest code/modules/mob_spawner/burrow.dm (/obj/structure/spawner/burrow and
// /burrow/lava_planet, AGPLv3) on our /obj/structure/spawner, spawning our basic mobs. The burrow digs out the rock around
// it, releases fauna like a mining lair and collapses when destroyed, dropping ore and sometimes a legion-infested corpse.
// Changes against Shiptest:
// - our spawner component picks mob_types without weights, so Initialize() expands the weights into repeated entries;
// - goliath and watcher are ours, the legion is our tendril legion (spawner_made, leaves a charred skeleton, as Shiptest's
//   legion/nest leaves no loot body); the brimdemon and the lavagrub are the ones in this folder; Shiptest's lava burrow has
//   no lavagrub, ours spawns it now and then;
// - Shiptest's ore list has the legion-infested corpse three times under one key (one entry); here one 25% roll too.

/obj/structure/spawner/burrow
	name = "wejście do nory"
	desc = "Dziura w ziemi pełna fauny gotowej jej bronić."
	icon = 'icons/mob/nest.dmi'
	icon_state = "hole"
	max_integrity = 250
	max_mobs = 3
	spawn_text = "wypełza z"
	faction = list("mining")
	mob_types = list(
		/mob/living/basic/mining/goliath = 1,
		/mob/living/basic/mining/legion/spawner_made = 1,
		/mob/living/basic/mining/watcher = 1,
	)

/obj/structure/spawner/burrow/Initialize(mapload)
	mob_types = expand_weighted_mob_types(mob_types)
	. = ..()
	clear_rock()

/// Turns a weighted list (type = weight) into a flat list with every type repeated by its weight, for pick()
/obj/structure/spawner/burrow/proc/expand_weighted_mob_types(list/weighted)
	var/list/flat = list()
	for (var/mob_type in weighted)
		var/weight = weighted[mob_type]
		if (!isnum(weight))
			weight = 1
		for (var/i in 1 to weight)
			flat += mob_type
	return flat

/**
 * Clears rocks around the spawner when it is created
 */
/obj/structure/spawner/burrow/proc/clear_rock()
	for (var/turf/nearby_turf in RANGE_TURFS(2, src))
		if (abs(x - nearby_turf.x) + abs(y - nearby_turf.y) > 3)
			continue
		if (ismineralturf(nearby_turf))
			nearby_turf.ScrapeAway(flags = CHANGETURF_IGNORE_AIR)

/obj/structure/spawner/burrow/deconstruct(disassembled = TRUE)
	destroy_effect()
	drop_loot()
	return ..()

/**
 * Effects and messages created when the spawner is destroyed
 */
/obj/structure/spawner/burrow/proc/destroy_effect()
	playsound(loc, 'sound/effects/explosionfar.ogg', 200, TRUE)
	visible_message(span_boldannounce("[src] zapada się, grzebiąc wszystko w środku!") + "\n" + span_warning("Z zawalonej nory wysypuje się ruda!"))

/**
 * Drops items after the spawner is destroyed
 */
/obj/structure/spawner/burrow/proc/drop_loot()
	var/static/list/ore_probability = list(
		/obj/item/stack/ore/plasma = 75,
		/obj/item/stack/ore/iron = 75,
		/obj/item/stack/ore/titanium = 50,
		/obj/item/stack/ore/gold = 50,
		/obj/item/stack/ore/uranium = 50,
		/obj/item/stack/ore/silver = 50,
		/obj/item/stack/ore/diamond = 25,
	)
	var/turf/drop_turf = get_turf(src)
	if (isnull(drop_turf))
		return
	for (var/ore_type in ore_probability)
		if (prob(ore_probability[ore_type]))
			new ore_type(drop_turf, rand(5, 10))
	if (prob(25))
		new /obj/effect/mob_spawn/human/corpse/damaged/legioninfested(drop_turf)

/// Burrow of the lava planets
/obj/structure/spawner/burrow/lava_planet
	mob_types = list(
		/mob/living/basic/mining/goliath = 27,
		/mob/living/basic/mining/legion/spawner_made = 26,
		/mob/living/basic/mining/watcher = 26,
		/mob/living/basic/mining/brimdemon = 20,
		/mob/living/basic/mining/goldgrub/lavagrub = 10,
		/mob/living/basic/mining/watcher/icewing = 1,
	)
