// AQUILA: port of tgstation code/modules/mob/living/basic/space_fauna/lightgeist.dm (tg 926bf40c5a) in place of our simple animal
// lightgeist from colossus.dm. Polish names and lines of our simple animal.
// Changes against tg:
// - the healing touch heals brute and burn by 5 at once, like our simple lightgeist (no do_after);
// - healed mobs become friends through befriend() (tg add_ally());
// - the medical HUD through the advanced medical data HUD, like our simple lightgeist (no TRAIT_MEDICAL_HUD handling here);
//   it cannot emote or pull (verbs removed, as before).
/**
 * ## Lightgeists
 *
 * Small critters meant to heal other living mobs and unable to interact with almost everything else.
 */
/mob/living/basic/lightgeist
	name = "świetlik"
	desc = "To małe unoszące się stworzenie jest zupełnie nieznaną formą życia... Jego bliskość napełnia cię spokojem."
	icon_state = "lightgeist"
	icon_living = "lightgeist"
	icon_dead = "butterfly_dead"
	response_help_continuous = "odgania"
	response_disarm_continuous = "odsuwa na bok"
	response_harm_continuous = "zakłóca"
	speak_emote = list("oscyluje")
	maxHealth = 2
	health = 2
	melee_damage = 5
	melee_attack_cooldown = 5 SECONDS
	friendly_verb_continuous = "opatruje"
	density = FALSE
	basic_mob_flags = DEL_ON_DEATH
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = HOSTILE_SPAWN
	verb_say = "faluje"
	verb_ask = "unosi się pytająco"
	verb_exclaim = "iskrzy"
	verb_yell = "huczy"
	initial_language_holder = /datum/language_holder/lightbringer
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	light_range = 4
	faction = list(FACTION_NEUTRAL)
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	ai_controller = /datum/ai_controller/basic_controller/lightgeist

/mob/living/basic/lightgeist/Initialize(mapload)
	. = ..()
	remove_verb(/mob/living/verb/pulled)
	remove_verb(/mob/verb/me_verb)
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(src)
	AddElement(/datum/element/simple_flying)
	AddComponent(\
		/datum/component/healing_touch,\
		heal_brute = melee_damage,\
		heal_burn = melee_damage,\
		heal_time = 0,\
		valid_targets_typecache = typecacheof(list(/mob/living)),\
		action_text = "%SOURCE% zaczyna opatrywać rany %TARGET%",\
		complete_text = "Rany %TARGET% się zasklepiają.",\
		after_healed = CALLBACK(src, PROC_REF(on_healed)),\
	)

/// Anyone we heal treats us as a friend
/mob/living/basic/lightgeist/proc/on_healed(mob/living/healed)
	befriend(healed)

/mob/living/basic/lightgeist/ghostize(can_reenter_corpse, sentience_retention)
	. = ..()
	if(.)
		death()

/datum/ai_controller/basic_controller/lightgeist
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/lightgeist,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk/less_walking

	planning_subtrees = list(
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree, // We heal things by attacking them
	)

/// Attack only mobs who have damage that we can heal, I think this is specific enough not to be a generic type
/datum/targeting_strategy/lightgeist
	/// Types of mobs we can heal
	var/list/heal_biotypes = list(MOB_ORGANIC, MOB_MINERAL)
	/// Type of limb we can heal
	var/required_bodytype = BODYTYPE_ORGANIC

/datum/targeting_strategy/lightgeist/can_attack(mob/living/living_mob, mob/living/target, vision_range)
	if (!isliving(target) || target.stat == DEAD || target == living_mob)
		return FALSE
	var/biotype_found = FALSE
	for (var/biotype in heal_biotypes)
		if (biotype in target.mob_biotypes)
			biotype_found = TRUE
			break
	if (!biotype_found)
		return FALSE
	if (!iscarbon(target))
		return target.getBruteLoss() > 0 || target.getFireLoss() > 0
	var/mob/living/carbon/carbon_target = target
	for (var/obj/item/bodypart/part as anything in carbon_target.bodyparts)
		if (!part.brute_dam && !part.burn_dam)
			continue
		if (!(part.bodytype & required_bodytype))
			continue
		return TRUE
	return FALSE

/// The lightgeist of the slime crossbreed structure
/mob/living/basic/lightgeist/slime
	name = "kryształowy świetlik"
