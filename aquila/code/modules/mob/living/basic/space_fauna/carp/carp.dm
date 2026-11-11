// AQUILA: port of tgstation code/modules/mob/living/basic/space_fauna/carp/ (carp.dm, carp_controllers.dm, carp_abilities.dm,
// carp_ai_actions.dm, carp_ai_rift_actions.dm, carp_ai_migration.dm, magicarp.dm, megacarp.dm) and code/__DEFINES/ai/carp.dm from the
// last revision before behaviour trees (tg 926bf40c5a), on the Bee AI core. Polish names and lines of our simple animal carp.
// Changes against tg:
// - our GAGS colours (14 common, 1% silver; Cayenne 10% silver), non-greyscale magicarp and megacarp sprites, no spell name
//   prefixes or spell colours for magicarp (we have no carp_magic/carp_mega greyscale configs), the chaos magicarp keeps its cyan;
// - regeneration in Life() (2 health a second after 6 s without damage, the regenerator component defaults; the megacarp heals
//   as our simple animal did, 4 every Life tick, which is the same rate) instead of the regenerator component;
// - moving in space through our `spacewalk` (decision D8); no TRAIT_FREE_HYPERSPACE_MOVEMENT, TRAIT_HEALS_FROM_CARP_RIFTS
//   (the dragon rift heals carp by faction, as before), speechmod, swabbing, fishing (profound_fisher, the fisherman fear and
//   priority), carp language holders (we have the carp wave speech of the dragon), holographic_nature (the holodeck derezzes
//   its mobs itself), ridable creature riding (the lasso gives our riding/tamed);
// - no taming with meat (decision D12, the space lasso tames carp); the lasso keeps the carp AI and only adds pet commands (D11);
// - the hiss on a new target is our taunt "kłapie zębami" at a steady 30%; no eating of six-pack rings (we have no can holders);
// - the nuclear_bomb_operator component is not ported: Cayenne keeps our disk handling in resolve_unarmed_attack();
// - Ella and the false carp (new content) are not ported;
// - kept from our simple animal: ghost possession of carp (playable, D14), silence (should_talk), NSV13 meat (two fillets).

/// Ability: the lesser carp rift
#define BB_CARP_RIFT "BB_carp_rift"
/// Ability: the magicarp bolt
#define BB_MAGICARP_SPELL "BB_magicarp_spell"
/// List of turfs we want to travel to
#define BB_CARP_MIGRATION_PATH "BB_carp_migration_path"
/// Current target turf in your migration
#define BB_CARP_MIGRATION_TARGET "BB_carp_migration_target"
/// Targeting keys for magicarp spells
#define BB_MAGICARP_SPELL_TARGET "BB_magicarp_spell_target"
#define BB_MAGICARP_SPELL_SPECIAL_TARGETING "BB_magicarp_spell_special_targeting"
#define MAGICARP_SPELL_CORPSES "magicarp_spell_corpses"
#define MAGICARP_SPELL_WALLS "magicarp_spell_walls"
#define MAGICARP_SPELL_OBJECTS "magicarp_spell_objects"

/// Time without damage before a carp starts to regenerate
#define CARP_REGENERATION_DELAY (6 SECONDS)

/**
 * ## Space Carp
 *
 * A migratory dwarf fortress reference who swim through space and sometimes bump into the station.
 * Can be created in dehydrated form by traitors, and are also summoned through rifts by space dragons.
 *
 * Begin regenerating their health after a short time without taking any damage, and will try to run away to do this if they get hurt.
 * Can follow basic instructions once tamed with the space lasso. Rideable.
 */
/mob/living/basic/carp
	name = "kosmiczny karp"
	desc = "Groźne, kłapiące kłami stworzenie przypominające rybę."
	icon = 'icons/mob/carp.dmi'
	icon_state = "base"
	icon_living = "base"
	icon_dead = "base_dead"
	icon_gib = "carp_gib"
	gold_core_spawnable = HOSTILE_SPAWN
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	health = 25
	maxHealth = 25
	speed = 0
	pressure_resistance = 200
	combat_mode = TRUE
	obj_damage = 50
	melee_damage = 20
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	attack_verb_continuous = "gryzie"
	melee_attack_cooldown = 1.5 SECONDS
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "uderza"
	speak_emote = list("zgrzyta zębami")
	chat_color = "#B15FB9"
	mobchatspan = "researchdirector"
	faction = list("carp")
	butcher_results = list(/obj/item/food/fishmeat/carp = 2)
	ai_controller = /datum/ai_controller/basic_controller/carp
	spacewalk = TRUE
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	playable = TRUE
	should_talk = FALSE

	/// If the carp uses random coloring
	var/random_color = TRUE
	/// The chance for a rare color variant
	var/rarechance = 1
	/// If true we will run away from attackers even at full health
	var/cowardly = FALSE
	/// Health regained every second after CARP_REGENERATION_DELAY without damage
	var/regeneration_per_second = 2
	/// world.time from which we regenerate
	var/regeneration_cooldown = 0
	/// Ability which lets carp teleport around
	var/datum/action/cooldown/mob_cooldown/lesser_carp_rift/teleport
	/// Commands you can give this carp once it is tamed, not static because subtypes can modify it
	var/tamed_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/attack,
	)
	/// Carp want to eat raw meat
	var/static/list/desired_food = list(/obj/item/food/meat/slab, /obj/item/food/meat/rawcutlet)
	/// Structures that AI carp are willing to attack. This prevents them from deconstructing supermatter cooling equipment.
	var/static/list/allowed_obstacle_targets = typecacheof(list(
		/obj/structure/closet,
		/obj/machinery/door,
		/obj/structure/door_assembly,
		/obj/structure/filingcabinet,
		/obj/structure/frame,
		/obj/structure/grille,
		/obj/structure/plasticflaps,
		/obj/structure/rack,
		/obj/structure/reagent_dispensers, // Carp can have a little welding fuel, as a treat
		/obj/structure/table,
		/obj/machinery/vending,
		/obj/structure/window,
	))
	/// List of usual carp colors
	var/static/list/carp_colors = list(
		"lightpurple" = "#aba2ff",
		"lightpink" = "#da77a8",
		"green" = "#70ff25",
		"grape" = "#df0afb",
		"swamp" = "#e5e75a",
		"turquoise" = "#04e1ed",
		"brown" = "#ca805a",
		"teal" = "#20e28e",
		"lightblue" = "#4d88cc",
		"rusty" = "#dd5f34",
		"lightred" = "#fd6767",
		"yellow" = "#f3ca4a",
		"blue" = "#09bae1",
		"palegreen" = "#7ef099"
	)
	/// List of rare carp colors
	var/static/list/carp_colors_rare = list(
		"silver" = "#fdfbf3"
	)

/mob/living/basic/carp/Initialize(mapload)
	if(random_color)
		set_greyscale(new_config = /datum/greyscale_config/carp)
		carp_randomify(rarechance)
	. = ..()
	AddElement(/datum/element/simple_flying)
	if(!cowardly)
		AddElement(/datum/element/ai_flee_while_injured)
	setup_eating()
	AddComponent(/datum/component/aggro_emote, living_only = TRUE, emote_list = string_list(list("kłapie zębami")), emote_chance = 30, minimum_chance = 30, subtract_chance = 0)

	teleport = new(src)
	teleport.Grant(src)
	ai_controller?.set_blackboard_key(BB_CARP_RIFT, teleport)
	ai_controller?.set_blackboard_key(BB_OBSTACLE_TARGETING_WHITELIST, allowed_obstacle_targets)
	find_candidates()

/mob/living/basic/carp/Destroy()
	QDEL_NULL(teleport)
	return ..()

/mob/living/basic/carp/attack_ghost(mob/dead/observer/user)
	. = ..()
	give_to_ghost(user)

/// Tell the elements and the blackboard what food we want to eat
/mob/living/basic/carp/proc/setup_eating()
	AddElement(/datum/element/basic_eating, food_types = desired_food)
	ai_controller?.set_blackboard_key(BB_BASIC_FOODS, typecacheof(desired_food))

/**
 * Randomly assigns a color to a carp from either a common or rare color variant lists
 *
 * Arguments:
 * * rarechance The chance of the carp receiving color from the rare color variant list
 */
/mob/living/basic/carp/proc/carp_randomify(rarechance)
	var/our_color
	if(prob(rarechance))
		our_color = pick(carp_colors_rare)
		set_greyscale(colors = list(carp_colors_rare[our_color]))
	else
		our_color = pick(carp_colors)
		set_greyscale(colors = list(carp_colors[our_color]))

/mob/living/basic/carp/revive(full_heal = FALSE, admin_revive = FALSE)
	. = ..()
	if(.)
		update_greyscale()
		update_icon()

/// Any damage holds the regeneration back
/mob/living/basic/carp/adjust_health(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(amount > 0)
		regeneration_cooldown = world.time + CARP_REGENERATION_DELAY

/mob/living/basic/carp/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == DEAD || !regeneration_per_second || regeneration_cooldown > world.time || health >= maxHealth)
		return
	heal_overall_damage(regeneration_per_second * SSMOBS_DT, 0)

/// Called when the space lasso tames us: the carp keeps its own AI and takes pet commands (decision D11)
/mob/living/basic/carp/tamed(mob/living/tamer, atom/food)
	. = ..()
	AddComponent(/datum/component/obeys_commands, tamed_commands)

/// Teleport when you right click away from you (the disarm intent in the legacy controls)
/mob/living/basic/carp/ranged_secondary_attack(atom/atom_target, modifiers)
	teleport?.Trigger(target = atom_target)

/// Gives the carp a list of turfs to try and travel between when it has nothing better to do
/mob/living/basic/carp/proc/migrate_to(list/migration_points)
	if(!ai_controller || !length(migration_points))
		return
	ai_controller.can_idle = FALSE
	ai_controller.set_ai_status(AI_STATUS_ON) // We need them to actually swim to the station
	ai_controller.set_blackboard_key(BB_CARP_MIGRATION_PATH, migration_points.Copy())

/**
 * Holographic carp from the holodeck
 */
/mob/living/basic/carp/holographic
	icon_state = "holocarp"
	icon_living = "holocarp"
	gold_core_spawnable = NO_SPAWN
	basic_mob_flags = DEL_ON_DEATH
	random_color = FALSE
	maximum_survivable_temperature = INFINITY

/// Holocarp don't eat food
/mob/living/basic/carp/holographic/setup_eating()
	return FALSE

/**
 * Pet carp, abstract carp which just holds some shared properties.
 */
/mob/living/basic/carp/pet
	speak_emote = list("piszczy")
	gold_core_spawnable = NO_SPAWN
	gender = FEMALE // Both current existing pet carp are female but you can remove this if someone else gets a male one?
	ai_controller = /datum/ai_controller/basic_controller/carp/pet

/mob/living/basic/carp/pet/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/pet_bonus, "radośnie bulgocze!")

/**
 * Lia - a pet of the Head of Security.
 * Has a lot more health than a normal carp because she's meant to be a mildly more threatening pet to have to assassinate than an aging corgi.
 */
/mob/living/basic/carp/pet/lia
	name = "Lia"
	real_name = "Lia"
	desc = "Nieudany eksperyment Nanotrasen z bojowymi karpiami. Ten niezbyt groźny karp jest teraz zwierzakiem Komendanta."
	faction = list(FACTION_NEUTRAL)
	maxHealth = 200
	health = 200
	icon_state = "magicarp"
	icon_dead = "magicarp_dead"
	icon_gib = "magicarp_gib"
	icon_living = "magicarp"
	random_color = FALSE

/**
 * Cayenne - Loyal member of the nuclear operatives.
 * Spawns in the nuke op shuttle, can be made sapient if they want to do that for some reason.
 * Is very talented and also capable of holding the nuclear disk.
 */
/mob/living/basic/carp/pet/cayenne
	name = "Cayenne"
	real_name = "Cayenne"
	desc = "Nieudany eksperyment Syndykatu z bojowymi kosmicznymi karpiami. Dziś jest uroczą maskotką."
	faction = list(FACTION_SYNDICATE)
	rarechance = 10
	/// Keeping track of the nuke disk for the functionality of storing it.
	var/obj/item/disk/nuclear/disky
	/// Location of the file storing disk overlays
	var/icon/disk_overlay_file = 'icons/mob/carp.dmi'
	/// Colored disk mouth appearance for adding it as a mouth overlay
	var/mutable_appearance/colored_disk_mouth

/mob/living/basic/carp/pet/cayenne/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_DISK_VERIFIER, INNATE_TRAIT) //carp can verify disky
	ADD_TRAIT(src, TRAIT_CAN_USE_NUKE, INNATE_TRAIT)  //carp SMART
	colored_disk_mouth = mutable_appearance(SSgreyscale.GetColoredIconByType(/datum/greyscale_config/carp/disk_mouth, greyscale_colors), "disk_mouth")

/mob/living/basic/carp/pet/cayenne/death(gibbed)
	if(disky)
		disky.forceMove(drop_location())
		disky = null
	return ..()

/mob/living/basic/carp/pet/cayenne/Destroy(force)
	QDEL_NULL(disky)
	return ..()

/mob/living/basic/carp/pet/cayenne/examine(mob/user)
	. = ..()
	if(disky)
		. += "<span class='notice'>Chwila... czy to [disky] w jego pysku?</span>"

/// Cayenne picks the disk up, puts it down on a floor she clicks, uses it on anything else and opens the bomb's window
/mob/living/basic/carp/pet/cayenne/resolve_unarmed_attack(atom/target, list/modifiers)
	if(istype(target, /obj/item/disk/nuclear))
		var/obj/item/disk/nuclear/potential_disky = target
		if(potential_disky.anchored || disky)
			return
		potential_disky.forceMove(src)
		disky = potential_disky
		to_chat(src, "<span class='nicegreen'>TAK!! Udaje ci się podnieść [disky]. (Kliknij gdziekolwiek, by go odłożyć.)</span>")
		update_icon()
		if(!disky.fake)
			client?.give_award(/datum/award/achievement/misc/cayenne_disk, src)
		return
	if(disky)
		if(isopenturf(target))
			to_chat(src, "<span class='notice'>Kładziesz [disky] na [target]</span>")
			disky.forceMove(target)
			disky = null
			update_icon()
		else
			disky.melee_attack_chain(src, target)
		return
	if(istype(target, /obj/machinery/nuclearbomb))
		var/obj/machinery/nuclearbomb/nuke = target
		nuke.ui_interact(src)
		return
	return ..()

/mob/living/basic/carp/pet/cayenne/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == disky)
		disky = null
		update_icon()

/mob/living/basic/carp/pet/cayenne/update_overlays()
	. = ..()
	if(!disky || stat == DEAD)
		return
	. += colored_disk_mouth
	. += mutable_appearance(disk_overlay_file, "disk_overlay")

/// Carp from the dragon's rifts (and their ghost players), a little tougher
/mob/living/basic/carp/advanced
	name = "zaawansowany kosmiczny karp"
	desc = "Groźne, kłapiące kłami stworzenie przypominające rybę. Ten wydaje się mieć samoświadomość."
	maxHealth = 40
	health = 40
	gold_core_spawnable = NO_SPAWN
	obj_damage = 15

#undef CARP_REGENERATION_DELAY
