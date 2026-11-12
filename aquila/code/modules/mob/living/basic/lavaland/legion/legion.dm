// AQUILA: port of tgstation code/modules/mob/living/basic/lavaland/legion/legion.dm (tg 926bf40c5a) in place of our simple
// animal legion (/mob/living/simple_animal/hostile/asteroid/hivelord/legion). Polish lines, sprites and stats of our
// simple animal (biotypes, crusher trophy). Changes against tg:
// - a consumed body dies and waits inside without stasis (we have no stasis status effect); reviving it bursts the legion;
//   no legion tumour, no speech copied from the victim (no copy_recent_speech here), the legion keeps its own name;
//   no gibs on infestation (as our simple animal; thrown gibs drift in zero gravity and runtime in the drift component);
// - no emissive overlays (our sprites have none), no snow legion (no ice moon), no legion monkey (our monkeys are not
//   humans, a skull does not infest them);
// - the tendril legion (spawner_made) drops the charred skeleton of our old tendril legions, the dwarf the dwarf corpse;
// - `random` (5% dwarf) stays for the cave generators, `large` replaces our big legion (/mob/living/simple_animal/hostile/big_legion).

/**
 * Avoids players while throwing skulls at them.
 * Legion skulls heal allies, bite enemies, and infest dying humans to make more legions.
 */
/mob/living/basic/mining/legion
	name = "legion"
	desc = "Pod falującą masą zepsucia wciąż widać, kim kiedyś był: człowiekiem."
	icon_state = "legion"
	icon_living = "legion"
	icon_dead = "legion"
	icon_gib = "syndicate_gib"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	mouse_opacity = MOUSE_OPACITY_ICON
	basic_mob_flags = DEL_ON_DEATH
	speed = 3
	maxHealth = 75
	health = 75
	obj_damage = 60
	melee_damage = 15
	attack_verb_continuous = "rzuca się na"
	speak_emote = list("rozbrzmiewa echem")
	attack_sound = 'sound/weapons/pierce.ogg'
	throw_blocked_message = "nieszkodliwie odbija się od"
	crusher_loot = /obj/item/crusher_trophy/legion_skull
	discovery_points = 3000
	playable = TRUE // AQUILA: ghosts take legions over, as they did through our simple hivelord
	should_talk = FALSE
	ai_controller = /datum/ai_controller/basic_controller/legion
	/// What kind of mob do we spawn?
	var/brood_type = /mob/living/basic/mining/legion_brood
	/// What kind of corpse spawner do we leave behind on death?
	var/corpse_type = /obj/effect/mob_spawn/human/corpse/damaged/legioninfested
	/// Who is inside of us?
	var/mob/living/stored_mob = null

/mob/living/basic/mining/legion/attack_ghost(mob/dead/observer/user)
	. = ..()
	give_to_ghost(user, TRUE)

/mob/living/basic/mining/legion/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/content_barfer)
	var/list/drops = get_loot_list()
	if (length(drops))
		AddElement(/datum/element/death_drops, drops)
	assign_abilities()

/// Give the Legion its spells
/mob/living/basic/mining/legion/proc/assign_abilities()
	var/datum/action/cooldown/mob_cooldown/skull_launcher/skull_launcher = new(src)
	skull_launcher.Grant(src)
	skull_launcher.spawn_type = brood_type
	ai_controller.set_blackboard_key(BB_TARGETED_ACTION, skull_launcher)

/// Create what we want to drop on death, in proc form so we can always return a static list
/mob/living/basic/mining/legion/proc/get_loot_list()
	var/static/list/death_loot = list(/obj/item/organ/regenerative_core/legion)
	return death_loot

/// A player in the legion launches skulls by clicking something out of reach
/mob/living/basic/mining/legion/RangedAttack(atom/atom_target, params)
	. = ..()
	var/datum/action/cooldown/mob_cooldown/skull_launcher/skull_launcher = locate() in actions
	skull_launcher?.Trigger(target = atom_target)

/mob/living/basic/mining/legion/Exited(atom/movable/gone, direction)
	. = ..()
	if (gone != stored_mob)
		return
	UnregisterSignal(stored_mob, COMSIG_LIVING_REVIVE)
	ai_controller?.clear_blackboard_key(BB_LEGION_CORPSE)
	stored_mob = null

/mob/living/basic/mining/legion/death(gibbed)
	visible_message(span_warning("Czaszki na [src] zawodzą z gniewu, uciekając od umierającego nosiciela!"))
	if (isnull(stored_mob) && corpse_type)
		new corpse_type(loc)
	return ..()

/// Put a corpse in this guy
/mob/living/basic/mining/legion/proc/consume(mob/living/carbon/human/consumed)
	gender = consumed.gender
	consumed.death()
	consumed.ExtinguishMob()
	RegisterSignal(consumed, COMSIG_LIVING_REVIVE, PROC_REF(on_consumed_revive))
	consumed.forceMove(src)
	ai_controller?.set_blackboard_key(BB_LEGION_CORPSE, consumed)
	stored_mob = consumed
	visible_message(span_warning("[src] chwiejnie staje na nogi!"))

/// Someone brought the body inside back to life, which the legion does not survive
/mob/living/basic/mining/legion/proc/on_consumed_revive(datum/source, full_heal, admin_revive)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, TYPE_PROC_REF(/mob/living, gib))

/// Legion spawned by a necropolis tendril, leaves only a charred skeleton so it cannot be farmed for loot
/mob/living/basic/mining/legion/spawner_made
	corpse_type = /obj/effect/mob_spawn/human/corpse/charredskeleton

/// Like a Legion but shorter and faster
/mob/living/basic/mining/legion/dwarf
	name = "karłowaty legion"
	desc = "Pod falującą masą zepsucia wciąż widać, kim kiedyś był: dość niskim człowiekiem."
	icon_state = "dwarf_legion"
	icon_living = "dwarf_legion"
	icon_dead = "dwarf_legion"
	maxHealth = 60
	health = 60
	speed = 2
	crusher_drop_chance = 20
	corpse_type = /obj/effect/mob_spawn/human/corpse/damaged/legioninfested/dwarf

/// Legion of the cave generators: one in twenty is a dwarf
/mob/living/basic/mining/legion/random

/mob/living/basic/mining/legion/random/Initialize(mapload)
	. = ..()
	if(prob(5))
		new /mob/living/basic/mining/legion/dwarf(loc)
		return INITIALIZE_HINT_QDEL

/// Like a Legion but larger and spawns regular Legions
/mob/living/basic/mining/legion/large
	desc = "Jeden z wielu."
	icon = 'icons/mob/lavaland/64x64megafauna.dmi'
	icon_state = "legion"
	icon_living = "legion"
	icon_dead = "legion"
	speed = 5
	health = 450
	maxHealth = 450
	melee_damage = 20
	obj_damage = 30
	pixel_x = -16
	base_pixel_x = -16
	sentience_type = SENTIENCE_BOSS
	crusher_loot = null

/mob/living/basic/mining/legion/large/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/spawner, list(/mob/living/basic/mining/legion), 20 SECONDS, faction, "odkleja się od", 3)

/// Create what we want to drop on death, in proc form so we can always return a static list
/mob/living/basic/mining/legion/large/get_loot_list()
	var/static/list/death_loot = list(/obj/item/organ/regenerative_core/legion = 3, /obj/effect/mob_spawn/human/corpse/damaged/legioninfested = 4)
	return death_loot
