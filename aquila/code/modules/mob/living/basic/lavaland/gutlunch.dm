// AQUILA: our gutlunches (/mob/living/simple_animal/hostile/asteroid/gutlunch) as basic mining mobs, on the frame of
// tgstation code/modules/mob/living/basic/lavaland/gutlunchers/ (tg 926bf40c5a). They keep our design instead of tg's
// gubbucks and warrior gunthers with inherited stats and ore troughs: they eat gibs and organs (find_food + basic_eating),
// which fills the udder (/obj/item/udder/gutlunch in aquila/code/datums/components/udder.dm); a full guthen breeds with a
// gubbuck nearby and the grublunch grows into one of them. Polish lines and sprites of our simple animals.

//Gutlunches, passive mods that devour blood and gibs
/mob/living/basic/mining/gutlunch
	name = "żarłoczek"
	desc = "Padlinożerca jedzący surowe mięso, często spotykany u boku popielnych wędrowców. Daje gęste, pożywne mleko."
	icon_state = "gutlunch"
	icon_living = "gutlunch"
	icon_dead = "gutlunch"
	speak_emote = list("gulgocze", "drży")
	faction = list("mining", "ashwalker")
	density = FALSE
	obj_damage = 0
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "rozgniata"
	friendly_verb_continuous = "szczypie"
	combat_mode = FALSE
	gold_core_spawnable = FRIENDLY_SPAWN
	ventcrawler = VENTCRAWLER_ALWAYS
	gender = NEUTER
	basic_mob_flags = DEL_ON_DEATH
	death_message = "zostaje rozgnieciony na robaczą papkę."
	discovery_points = 1000
	ai_controller = /datum/ai_controller/basic_controller/gutlunch
	/// Does it eat gibs and give milk?
	var/eats_gibs = TRUE
	/// Is the udder full (overlay)
	var/udder_full = FALSE

/mob/living/basic/mining/gutlunch/Initialize(mapload)
	. = ..()
	var/static/list/death_loot = list(/obj/effect/decal/cleanable/blood/gibs)
	AddElement(/datum/element/death_drops, death_loot)
	if(!eats_gibs)
		return
	var/static/list/gutlunch_foods = list(/obj/effect/decal/cleanable/xenoblood/xgibs, /obj/effect/decal/cleanable/blood/gibs, /obj/item/organ)
	AddElement(/datum/element/basic_eating, food_types = gutlunch_foods)
	var/static/list/food_typecache
	if(isnull(food_typecache))
		food_typecache = typecacheof(gutlunch_foods)
	ai_controller.set_blackboard_key(BB_BASIC_FOODS, food_typecache)
	AddComponent(/datum/component/udder, /obj/item/udder/gutlunch, CALLBACK(src, PROC_REF(udder_changed)), CALLBACK(src, PROC_REF(udder_changed)))
	RegisterSignal(src, COMSIG_MOB_ATE, PROC_REF(on_ate))

/// Eating gibs fills the udder
/mob/living/basic/mining/gutlunch/proc/on_ate(datum/source, atom/food, mob/feeder)
	SIGNAL_HANDLER
	var/datum/component/udder/udder_component = GetComponent(/datum/component/udder)
	udder_component?.udder.generate()

/// The udder component calls this with its volume when milked or filled
/mob/living/basic/mining/gutlunch/proc/udder_changed(new_udder_volume, max_udder_volume)
	if(isnull(new_udder_volume)) // ordinary redraw without the udder callback: read the udder itself
		var/datum/component/udder/udder_component = GetComponent(/datum/component/udder)
		new_udder_volume = udder_component?.udder?.reagents?.total_volume
		max_udder_volume = udder_component?.udder?.reagents?.maximum_volume
	udder_full = new_udder_volume && new_udder_volume == max_udder_volume
	update_appearance(UPDATE_OVERLAYS)

/mob/living/basic/mining/gutlunch/update_overlays()
	. = ..()
	if(udder_full)
		. += "gl_full"

/**
 * A full guthen makes a grublunch with a gubbuck nearby (our simple animal make_babies(), called by the gutlunch udder).
 * Returns TRUE if a baby was made.
 */
/mob/living/basic/mining/gutlunch/proc/make_babies()
	if(gender != FEMALE || stat != CONSCIOUS || !isturf(loc))
		return FALSE
	var/partner_found = FALSE
	var/nearby_gutlunches = 0
	for(var/mob/living/basic/mining/gutlunch/other in oview(7, src))
		nearby_gutlunches++
		if(other.gender == MALE && other.stat == CONSCIOUS)
			partner_found = TRUE
	if(!partner_found || nearby_gutlunches >= 8)
		return FALSE
	new /mob/living/basic/mining/gutlunch/grublunch(loc)
	return TRUE

/datum/ai_controller/basic_controller/gutlunch
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity/pacifist,
		/datum/ai_planning_subtree/find_food,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/random_speech/gutlunch,
	)

/datum/ai_planning_subtree/random_speech/gutlunch
	speech_chance = 1
	emote_hear = list("trylikuje.")
	emote_see = list("węszy.", "beka.")

//Male gutlunch. They're smaller and more colorful!
/mob/living/basic/mining/gutlunch/gubbuck
	name = "żarłoczek samiec"
	gender = MALE

/mob/living/basic/mining/gutlunch/gubbuck/Initialize(mapload)
	. = ..()
	add_atom_colour(pick("#E39FBB", "#D97D64", "#CF8C4A"), FIXED_COLOUR_PRIORITY)
	resize = 0.85
	update_transform()

//Lady gutlunch. They make the babby.
/mob/living/basic/mining/gutlunch/guthen
	name = "żarłoczka"
	gender = FEMALE

/// Baby gutlunch, does not eat and grows up into a gubbuck or a guthen
/mob/living/basic/mining/gutlunch/grublunch
	name = "młody żarłoczek"
	gold_core_spawnable = NO_SPAWN
	eats_gibs = FALSE
	/// Life ticks until it grows up
	var/growth = 0

/mob/living/basic/mining/gutlunch/grublunch/Initialize(mapload)
	. = ..()
	add_atom_colour("#9E9E9E", FIXED_COLOUR_PRIORITY) //Somewhat hidden
	resize = 0.45
	update_transform()

/mob/living/basic/mining/gutlunch/grublunch/Life(seconds, times_fired)
	. = ..()
	if(stat == DEAD)
		return
	growth++
	if(growth > 50)
		grow_up()

/mob/living/basic/mining/gutlunch/grublunch/proc/grow_up()
	var/mob/living/grown
	if(prob(45))
		grown = new /mob/living/basic/mining/gutlunch/gubbuck(loc)
	else
		grown = new /mob/living/basic/mining/gutlunch/guthen(loc)
	mind?.transfer_to(grown)
	grown.faction = faction.Copy()
	grown.setDir(dir)
	grown.Stun(2 SECONDS, ignore_canstun = TRUE)
	visible_message(span_notice("[src] dorasta, stając się [grown]."))
	qdel(src)
