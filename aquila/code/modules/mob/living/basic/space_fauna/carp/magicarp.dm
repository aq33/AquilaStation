// AQUILA: tg 926bf40c5a magicarp.dm and megacarp.dm. Our spell lists (code/modules/events/wizard/magicarp.dm had them on the
// simple animal), our /obj/item/projectile/magic types, no name prefixes or spell colours (our magicarp sprite is not greyscale),
// the chaos magicarp stays cyan; descriptions and research points of our simple animals, the xenobiology variants keep theirs.
// The megacarp keeps our sprite (broadMobs.dmi), +10-20 damage and +30-60 health (tg: lower and upper damage separately) and
// regenerates like every carp here (see carp.dm).

/**
 * # Magicarp
 *
 * Carp who can cast spells!
 * Mostly created via wizard event or transformation.
 * Come in 'does one thing' and 'does random things' varieties.
 */
/mob/living/basic/carp/magic
	name = "magikarp"
	desc = "50% magii, 50% karpia, 100% okropieństwa."
	icon_state = "magicarp"
	icon_living = "magicarp"
	icon_dead = "magicarp_dead"
	icon_gib = "magicarp_gib"
	maxHealth = 50
	health = 50
	random_color = FALSE
	gold_core_spawnable = NO_SPAWN
	discovery_points = 3000
	ai_controller = /datum/ai_controller/basic_controller/carp/ranged
	tamed_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/attack,
		/datum/pet_command/use_ability/magicarp,
	)
	/// List of all projectiles we can fire.
	/// Non-static, because subtypes can have their own lists.
	var/list/allowed_projectile_types = list(
		/obj/item/projectile/magic/animate,
		/obj/item/projectile/magic/resurrection,
		/obj/item/projectile/magic/death,
		/obj/item/projectile/magic/teleport,
		/obj/item/projectile/magic/door,
		/obj/item/projectile/magic/fireball,
		/obj/item/projectile/magic/spellblade,
		/obj/item/projectile/magic/arcane_barrage,
	)
	/// Our magic attack
	var/datum/action/cooldown/mob_cooldown/projectile_attack/magicarp_bolt/spell

/mob/living/basic/carp/magic/Initialize(mapload)
	. = ..()
	assign_spell()

/mob/living/basic/carp/magic/Destroy()
	QDEL_NULL(spell)
	return ..()

/// Picks the spell we cast
/mob/living/basic/carp/magic/proc/assign_spell()
	var/obj/item/projectile/spell_type = pick(allowed_projectile_types)
	spell = new(src)
	spell.projectile_type = spell_type
	spell.button_icon_state = initial(spell_type.icon_state)
	spell.Grant(src)
	ai_controller?.set_blackboard_key(BB_MAGICARP_SPELL, spell)
	assign_spell_ai(spell_type)

/// If you have certain spells, use a different targeting strategy
/mob/living/basic/carp/magic/proc/assign_spell_ai(spell_type)
	var/static/list/spell_special_targeting = list(
		/obj/item/projectile/magic/animate = MAGICARP_SPELL_OBJECTS,
		/obj/item/projectile/magic/door = MAGICARP_SPELL_WALLS,
		/obj/item/projectile/magic/resurrection = MAGICARP_SPELL_CORPSES,
	)
	ai_controller?.set_blackboard_key(BB_MAGICARP_SPELL_SPECIAL_TARGETING, spell_special_targeting[spell_type])

/// Shoot when you click away from you
/mob/living/basic/carp/magic/RangedAttack(atom/atom_target, params)
	. = ..()
	spell?.Trigger(target = atom_target)

/***
 * # Chaos Magicarp
 *
 * Fires a random spell every time, also beefier.
 * Sometimes actually more durable than the much larger megacarp. That's magic for you.
 * They trade off for this with a tendency to fireball themselves.
 */
/mob/living/basic/carp/magic/chaos
	name = "magikarp chaosu"
	desc = "50% karpia, 100% magii, 150% okropieństwa."
	color = "#00FFFF"
	maxHealth = 75
	health = 75
	discovery_points = 5000

/mob/living/basic/carp/magic/chaos/assign_spell()
	var/datum/action/cooldown/mob_cooldown/projectile_attack/magicarp_bolt/chaos/chaos_bolt = new(src)
	chaos_bolt.permitted_projectiles = allowed_projectile_types
	chaos_bolt.Grant(src)
	spell = chaos_bolt
	ai_controller?.set_blackboard_key(BB_MAGICARP_SPELL, spell)

/// Has a more limited spell pool but can appear from gold slime cores
/mob/living/basic/carp/magic/xenobiology
	desc = "45% magii, 50% karpia, 5% szlamu, 100% okropieństwa."
	gold_core_spawnable = HOSTILE_SPAWN
	allowed_projectile_types = list(
		/obj/item/projectile/magic/animate,
		/obj/item/projectile/magic/teleport,
		/obj/item/projectile/magic/door,
		/obj/item/projectile/magic/fireball,
		/obj/item/projectile/magic/spellblade,
		/obj/item/projectile/magic/arcane_barrage,
	)

/mob/living/basic/carp/magic/chaos/xenobiology
	desc = "95% magii, 50% karpia, 5% szlamu, 150% okropieństwa."
	gold_core_spawnable = HOSTILE_SPAWN
	allowed_projectile_types = list(
		/obj/item/projectile/magic/animate,
		/obj/item/projectile/magic/teleport,
		/obj/item/projectile/magic/door,
		/obj/item/projectile/magic/fireball,
		/obj/item/projectile/magic/spellblade,
		/obj/item/projectile/magic/arcane_barrage,
	)

/**
 * ## Mega Space Carp
 *
 * A bigger space carp with more health and greater ability to smash objects.
 * Has mildly randomised stats for some inexplicable reason, makes it somewhat more like a randomised Diablo mob.
 */
/mob/living/basic/carp/mega
	icon = 'icons/mob/broadMobs.dmi'
	name = "kosmiczny megakarp"
	desc = "Groźne, kłapiące kłami stworzenie przypominające rekina. Ten wydaje się wyjątkowo wkurzony."
	icon_state = "megacarp"
	icon_living = "megacarp"
	icon_dead = "megacarp_dead"
	icon_gib = "megacarp_gib"
	maxHealth = 20
	health = 20
	pixel_x = -16
	base_pixel_x = -16
	mob_size = MOB_SIZE_LARGE
	obj_damage = 80
	random_color = FALSE
	ai_controller = /datum/ai_controller/basic_controller/carp/mega

/mob/living/basic/carp/mega/Initialize(mapload)
	. = ..()
	name = "[pick(GLOB.megacarp_first_names)] [pick(GLOB.megacarp_last_names)]"
	melee_damage += rand(10, 20) //this is on initialize so even with rng the damage will be consistent
	maxHealth += rand(30, 60)
	health = maxHealth
