// AQUILA - kosmiczna fauna przelatująca obok okrętu (eventy mapy hex, etap E5): koi (port z ParadiseSS13/Paradise
// code/modules/mob/living/simple_animal/hostile/retaliate/fish.dm), muszki, płaszczki, rekiny (VOREStation/VOREStation
// code/modules/mob/living/simple_mob/subtypes/animal/space/gnat.dm, ray.dm, shark.dm), meduzy (VOREStation
// code/modules/mob/living/simple_mob/subtypes/animal/alien animals/jellyfish.dm) i wieloryby z młodymi (Baystation12/Baystation12
// code/modules/mob/living/simple_animal/hostile/retaliate/space_whale.dm, friendly/juvenile_space_whale.dm).
// Grafika: aquila/icons/mob/space_fauna/ (Paradise, VOREStation, Baystation12; CC BY-SA 3.0, źródła w ATTRIBUTION.md tamtego folderu).
// Changes against the originals:
// - basic mobs on our AI instead of simple animals/simple mobs, one shared base type and two controllers (retaliating and hunting);
// - they fly past the ship on a route given by the event (aquila_flyby subtree) and vanish at its end, instead of swimming
//   at the map centre and staying; hunters only pick targets in space (people on EVA), never through the hull;
// - none of them break walls or windows (obj_damage 0), so they never let themselves into the ship;
// - VORE jellyfish: no vore, nutrition drain or breeding, the touch is a burning sting that also tires; VORE ray: the buffet
//   tires the victim instead of entangling it; VORE shark: the knockdown is a 2 s Knockdown at 10%;
// - Bay whales: no multi-tile bounds (one tile with a big sprite and pixel offsets), no skins; the calf follows its mother
//   through our look_for_adult subtree, and any attack on a whale makes the adults of the pod nearby strike back.

/// Lista pól, przez które stwór przelatuje obok okrętu
#define BB_AQUILA_FLYBY_PATH "BB_aquila_flyby_path"
/// Pole, do którego stwór teraz leci
#define BB_AQUILA_FLYBY_TARGET "BB_aquila_flyby_target"
/// Najmniejsza odległość od bieżącego pola, jaką stwór osiągnął
#define BB_AQUILA_FLYBY_BEST_DIST "BB_aquila_flyby_best_dist"
/// Ile razy z rzędu stwór nie zbliżył się do pola
#define BB_AQUILA_FLYBY_STALL "BB_aquila_flyby_stall"

/**
 * Kosmiczne stworzenie: lata w próżni, nie potrzebuje powietrza, nie niszczy kadłuba.
 * Event daje mu trasę przelotu (fly_by()), po której znika.
 */
/mob/living/basic/aquila_void_fauna
	name = "kosmiczne stworzenie"
	desc = "Coś, co żyje w próżni."
	icon = 'aquila/icons/mob/space_fauna/space_fauna.dmi'
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speed = 1
	pressure_resistance = 200
	spacewalk = TRUE
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = 1500
	combat_mode = TRUE
	obj_damage = 0
	attack_sound = 'sound/weapons/bite.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	attack_verb_continuous = "gryzie"
	response_help_continuous = "głaszcze"
	response_disarm_continuous = "delikatnie odsuwa na bok"
	response_harm_continuous = "uderza"
	faction = list("void_fauna")
	should_talk = FALSE
	ai_controller = /datum/ai_controller/basic_controller/aquila_void_fauna

/mob/living/basic/aquila_void_fauna/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)
	AddElement(/datum/element/ai_retaliate)

/// Daje stworowi trasę przelotu: kolejne pola, do których leci; po ostatnim znika
/mob/living/basic/aquila_void_fauna/proc/fly_by(list/route)
	if(!ai_controller || !length(route))
		return FALSE
	ai_controller.can_idle = FALSE
	ai_controller.set_ai_status(AI_STATUS_ON)
	ai_controller.set_blackboard_key(BB_AQUILA_FLYBY_PATH, route.Copy())
	return TRUE

/// Stwór odlatuje: blednie i znika. Martwe i opętane zostają.
/mob/living/basic/aquila_void_fauna/proc/leave_flyby()
	if(QDELETED(src) || stat == DEAD || client || key)
		return FALSE
	ai_controller?.clear_blackboard_key(BB_AQUILA_FLYBY_PATH)
	animate(src, alpha = 0, time = 1 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(finish_leaving)), 1 SECONDS, TIMER_UNIQUE)
	return TRUE

/mob/living/basic/aquila_void_fauna/proc/finish_leaving()
	if(!QDELETED(src))
		qdel(src)

/**
 * # Przelot obok okrętu
 * Leci po kolei do pól z BB_AQUILA_FLYBY_PATH. Pole, do którego długo nie udaje się zbliżyć, pomija.
 * Po ostatnim polu stwór odlatuje (leave_flyby()).
 */
/datum/ai_planning_subtree/aquila_flyby
	/// Odległość, z której pole uznaje się za osiągnięte
	var/arrive_distance = 2
	/// Po ilu planowaniach bez postępu pole jest pomijane
	var/stall_limit = 8

/datum/ai_planning_subtree/aquila_flyby/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/turf/moving_to = controller.blackboard[BB_AQUILA_FLYBY_TARGET]
	if(!QDELETED(moving_to))
		var/distance = get_dist(controller.pawn, moving_to)
		if(moving_to.z == controller.pawn.z && distance > arrive_distance && !stalled(controller, distance))
			controller.queue_behavior(/datum/ai_behavior/step_towards_turf, BB_AQUILA_FLYBY_TARGET)
			return SUBTREE_RETURN_FINISH_PLANNING
		controller.clear_blackboard_key(BB_AQUILA_FLYBY_TARGET)

	var/list/route = controller.blackboard[BB_AQUILA_FLYBY_PATH]
	if(isnull(route))
		return
	while(length(route))
		var/turf/next_point = route[1]
		route.Cut(1, 2)
		if(QDELETED(next_point) || next_point.z != controller.pawn.z || get_dist(controller.pawn, next_point) <= arrive_distance)
			continue
		controller.set_blackboard_key(BB_AQUILA_FLYBY_TARGET, next_point)
		controller.clear_blackboard_key(BB_AQUILA_FLYBY_BEST_DIST)
		controller.clear_blackboard_key(BB_AQUILA_FLYBY_STALL)
		controller.queue_behavior(/datum/ai_behavior/step_towards_turf, BB_AQUILA_FLYBY_TARGET)
		return SUBTREE_RETURN_FINISH_PLANNING

	// Koniec trasy: stwór odlatuje (poza procką planowania, żeby nie usuwać pionka w trakcie)
	controller.clear_blackboard_key(BB_AQUILA_FLYBY_PATH)
	var/mob/living/basic/aquila_void_fauna/fauna = controller.pawn
	if(istype(fauna))
		INVOKE_ASYNC(fauna, TYPE_PROC_REF(/mob/living/basic/aquila_void_fauna, leave_flyby))
	return SUBTREE_RETURN_FINISH_PLANNING

/// TRUE, gdy stwór od stall_limit planowań nie zbliżył się do pola
/datum/ai_planning_subtree/aquila_flyby/proc/stalled(datum/ai_controller/controller, distance)
	var/best = controller.blackboard[BB_AQUILA_FLYBY_BEST_DIST]
	if(isnull(best) || distance < best)
		controller.set_blackboard_key(BB_AQUILA_FLYBY_BEST_DIST, distance)
		controller.set_blackboard_key(BB_AQUILA_FLYBY_STALL, 0)
		return FALSE
	var/stall = controller.blackboard[BB_AQUILA_FLYBY_STALL] + 1
	controller.set_blackboard_key(BB_AQUILA_FLYBY_STALL, stall)
	return stall >= stall_limit

/// Cel tylko w kosmosie (ludzie na EVA): stwory nie polują przez kadłub ani w środku okrętu
/datum/targeting_strategy/basic/aquila_outside_ship

/datum/targeting_strategy/basic/aquila_outside_ship/can_attack(mob/living/living_mob, atom/the_target, vision_range)
	var/turf/target_turf = get_turf(the_target)
	if(!target_turf || !(isspaceturf(target_turf) || istype(get_area(target_turf), /area/space)))
		return FALSE
	return ..()

/// Spokojny przelot, oddaje tylko temu, kto go zaatakował
/datum/ai_controller/basic_controller/aquila_void_fauna
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic/aquila_outside_ship,
	)
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/aquila_flyby,
	)

/// Po drodze poluje na ludzi w kosmosie
/datum/ai_controller/basic_controller/aquila_void_fauna/hunter
	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/aquila_flyby,
	)

/// Młode trzyma się matki, a bez niej leci swoją trasą
/datum/ai_controller/basic_controller/aquila_void_fauna/calf
	planning_subtrees = list(
		/datum/ai_planning_subtree/look_for_adult,
		/datum/ai_planning_subtree/aquila_flyby,
	)

/**
 * Kosmiczny koi: niegroźna, kolorowa rybka z ławicy. Bardzo rzadko trafia się koi-klaun.
 */
/mob/living/basic/aquila_void_fauna/koi
	name = "kosmiczny koi"
	desc = "Łagodny koi, który pływa w próżni jak w przydomowym oczku wodnym."
	icon_state = "koi1"
	icon_living = "koi1"
	icon_dead = "koi1-dead"
	maxHealth = 25
	health = 25
	melee_damage = 2
	attack_verb_continuous = "skubie"
	speak_emote = list("bulgocze")
	butcher_results = list(/obj/item/food/fishmeat = 1)
	gold_core_spawnable = FRIENDLY_SPAWN
	/// Losowy z czterech wzorów łusek
	var/random_pattern = TRUE

/mob/living/basic/aquila_void_fauna/koi/Initialize(mapload)
	if(random_pattern)
		var/pattern = rand(1, 4)
		icon_state = "koi[pattern]"
		icon_living = "koi[pattern]"
		icon_dead = "koi[pattern]-dead"
	return ..()

/mob/living/basic/aquila_void_fauna/koi/honk
	name = "kosmiczny koi-klaun"
	desc = "Koi w barwach cyrku. Ktoś musiał go wychować na planecie klaunów."
	icon_state = "koi5"
	icon_living = "koi5"
	icon_dead = "koi5-dead"
	attack_sound = 'sound/items/bikehorn.ogg'
	random_pattern = FALSE

/**
 * Kosmiczna muszka: drobny, wściekły szkodnik. Sama niegroźna, w roju potrafi zamęczyć człowieka na EVA.
 */
/mob/living/basic/aquila_void_fauna/gnat
	name = "kosmiczna muszka"
	desc = "Mały, nieszczęsny szkodnik międzygwiezdny. Sam niegroźny, w roju potrafi dać się we znaki."
	icon_state = "gnat"
	icon_living = "gnat"
	icon_dead = "gnat_dead"
	maxHealth = 5
	health = 5
	speed = 0
	melee_damage = 3
	melee_attack_cooldown = 1 SECONDS
	sharpness = IS_SHARP
	attack_verb_continuous = "kąsa"
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE | PASSMOB
	gold_core_spawnable = HOSTILE_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/aquila_void_fauna/hunter

/**
 * Kosmiczna meduza: półprzezroczysta, mieniąca się światłem. Parzy każdego, kto podleci za blisko.
 */
/mob/living/basic/aquila_void_fauna/jellyfish
	name = "kosmiczna meduza"
	desc = "Półprzezroczyste stworzenie z mackami, mieniące się hipnotycznym światłem. Lepiej jej nie dotykać."
	icon_state = "space_jellyfish"
	icon_living = "space_jellyfish"
	icon_dead = "space_jellyfish_dead"
	maxHealth = 60
	health = 60
	speed = 2
	melee_damage = 4
	melee_damage_type = BURN
	attack_verb_continuous = "parzy"
	attack_sound = 'sound/weapons/sear.ogg'
	attack_vis_effect = null
	speak_emote = list("pulsuje")
	pass_flags = PASSTABLE
	light_range = 2
	light_power = 0.6
	light_color = "#9a6cff"
	gold_core_spawnable = HOSTILE_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/aquila_void_fauna/hunter
	/// Zmęczenie (obrażenia wytrzymałości) od każdego oparzenia
	var/sting_stamina_damage = 12

/mob/living/basic/aquila_void_fauna/jellyfish/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	. = ..()
	if(!. || !iscarbon(target))
		return
	var/mob/living/carbon/stung = target
	stung.adjustStaminaLoss(sting_stamina_damage)
	stung.Jitter(5)

/**
 * Kosmiczna płaszczka: wygląda groźnie, ale szybuje spokojnie na wiatrach słonecznych i oddaje tylko zaczepiona.
 */
/mob/living/basic/aquila_void_fauna/ray
	name = "kosmiczna płaszczka"
	desc = "Przerażająca z wyglądu, ale w gruncie rzeczy łagodna istota, która szybuje na słonecznym wietrze."
	icon_state = "ray"
	icon_living = "ray"
	icon_dead = "ray_dead"
	maxHealth = 125
	health = 125
	speed = 0
	melee_damage = 7
	melee_attack_cooldown = 1.8 SECONDS
	sharpness = IS_SHARP
	attack_verb_continuous = "smaga"
	butcher_results = list(/obj/item/food/fishmeat = 3)
	gold_core_spawnable = FRIENDLY_SPAWN
	/// Szansa (%), że uderzenie skrzydłem zmęczy ofiarę, a płaszczka straci nią zainteresowanie
	var/buffet_chance = 66

/mob/living/basic/aquila_void_fauna/ray/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	. = ..()
	if(!. || !isliving(target) || !prob(buffet_chance))
		return
	var/mob/living/victim = target
	victim.adjustStaminaLoss(20)
	victim.visible_message("<span class='danger'>[src] odrzuca [victim] uderzeniem skrzydła!</span>", "<span class='userdanger'>[src] odrzuca cię uderzeniem skrzydła!</span>")
	ai_controller?.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
	var/list/grudges = ai_controller?.blackboard[BB_BASIC_MOB_RETALIATE_LIST]
	if(islist(grudges) && (victim in grudges))
		ai_controller.remove_thing_from_blackboard_key(BB_BASIC_MOB_RETALIATE_LIST, victim)
	visible_message("<span class='notice'>[src] traci zainteresowanie [victim].</span>")

/**
 * Kosmiczny rekin: większy i znacznie groźniejszy kuzyn karpia. Lepiej nie wychodzić wtedy na kadłub.
 */
/mob/living/basic/aquila_void_fauna/shark
	name = "kosmiczny rekin"
	desc = "Dostojny i groźny drapieżnik międzygwiezdny. Dla nieprzygotowanych bardzo poważne zagrożenie."
	icon_state = "shark"
	icon_living = "shark"
	icon_dead = "shark_dead"
	maxHealth = 125
	health = 125
	speed = 0
	melee_damage = 22
	melee_attack_cooldown = 2.2 SECONDS
	sharpness = IS_SHARP
	butcher_results = list(/obj/item/food/fishmeat = 5)
	gold_core_spawnable = HOSTILE_SPAWN
	ai_controller = /datum/ai_controller/basic_controller/aquila_void_fauna/hunter
	/// Szansa (%), że ugryzienie przewróci ofiarę
	var/knockdown_chance = 10

/mob/living/basic/aquila_void_fauna/shark/melee_attack(atom/target, list/modifiers, ignore_cooldown = FALSE)
	. = ..()
	if(!. || !isliving(target) || !prob(knockdown_chance))
		return
	var/mob/living/victim = target
	victim.Knockdown(2 SECONDS)
	victim.visible_message("<span class='danger'>[src] powala [victim]!</span>", "<span class='userdanger'>[src] cię powala!</span>")

/**
 * Kosmiczny wieloryb: majestatyczny i spokojny. Atakuje tylko wtedy, gdy ktoś skrzywdzi jego albo młode ze stada.
 * Zajmuje jedno pole, ale ma duży sprite przesunięty na środek.
 */
/mob/living/basic/aquila_void_fauna/space_whale
	name = "kosmiczny wieloryb"
	desc = "Majestatyczny kosmiczny walen. Prawdziwy widok dla oczu."
	icon = 'aquila/icons/mob/space_fauna/space_whale.dmi'
	icon_state = "alive"
	icon_living = "alive"
	icon_dead = "dead"
	pixel_x = -48
	base_pixel_x = -48
	pixel_y = -48
	base_pixel_y = -48
	maxHealth = 250
	health = 250
	speed = 3
	melee_damage = 30
	melee_attack_cooldown = 2 SECONDS
	attack_verb_continuous = "taranuje"
	attack_sound = 'sound/weapons/punch4.ogg'
	attack_vis_effect = ATTACK_EFFECT_SMASH
	speak_emote = list("śpiewa", "nuci")
	mob_size = MOB_SIZE_LARGE
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	butcher_results = list(/obj/item/food/meat/slab = 8)
	/// Zasięg, z którego dorosłe wieloryby przybywają z pomocą
	var/herd_range = 9

/mob/living/basic/aquila_void_fauna/space_whale/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))
	if(prob(1))
		name = "Moby Dick"
		real_name = name
	else if(prob(2))
		color = pick("#4a6ea8", "#7a4aa8", "#4a5468", "#e8b4c8")

/// Atak na wieloryba albo młode: dorosłe ze stada w pobliżu oddają napastnikowi
/mob/living/basic/aquila_void_fauna/space_whale/proc/on_attacked(datum/source, atom/attacker)
	SIGNAL_HANDLER
	rally_herd(attacker)

/// Dorosłe wieloryby w zasięgu herd_range biorą napastnika na cel
/mob/living/basic/aquila_void_fauna/space_whale/proc/rally_herd(atom/attacker)
	if(!attacker || attacker == src || istype(attacker, /mob/living/basic/aquila_void_fauna/space_whale))
		return
	for(var/mob/living/basic/aquila_void_fauna/space_whale/whale in range(herd_range, src))
		if(whale.stat == DEAD || whale.mob_size != MOB_SIZE_LARGE || whale == attacker)
			continue
		whale.ai_controller?.insert_blackboard_key_lazylist(BB_BASIC_MOB_RETALIATE_LIST, attacker)

/**
 * Młody kosmiczny wieloryb: trzyma się matki i sam nie walczy, ale stado go broni.
 */
/mob/living/basic/aquila_void_fauna/space_whale/calf
	name = "młody kosmiczny wieloryb"
	desc = "Majestatyczny kosmiczny walen. Ten jest jeszcze maluchem."
	icon = 'aquila/icons/mob/space_fauna/juvenile_space_whale.dmi'
	pixel_x = -16
	base_pixel_x = -16
	pixel_y = -16
	base_pixel_y = -16
	maxHealth = 80
	health = 80
	melee_damage = 0
	mob_size = MOB_SIZE_HUMAN
	move_force = MOVE_FORCE_STRONG
	move_resist = MOVE_FORCE_STRONG
	pull_force = MOVE_FORCE_STRONG
	butcher_results = list(/obj/item/food/meat/slab = 3)
	ai_controller = /datum/ai_controller/basic_controller/aquila_void_fauna/calf

/mob/living/basic/aquila_void_fauna/space_whale/calf/Initialize(mapload)
	. = ..()
	ai_controller?.set_blackboard_key(BB_FIND_MOM_TYPES, list(/mob/living/basic/aquila_void_fauna/space_whale))
	ai_controller?.set_blackboard_key(BB_IGNORE_MOM_TYPES, list(/mob/living/basic/aquila_void_fauna/space_whale/calf))

/// Młode podąża za tą matką
/mob/living/basic/aquila_void_fauna/space_whale/calf/proc/follow_mother(mob/living/basic/aquila_void_fauna/space_whale/mother)
	if(QDELETED(mother))
		return FALSE
	ai_controller?.set_blackboard_key(BB_FOUND_MOM, mother)
	color = mother.color
	return TRUE
