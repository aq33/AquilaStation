/// A bunch of bad effects that can maim or kill you (for science!!!)
/datum/gizmodes/bad
	possible_active_modes = list(
		/datum/gizpulse/explode = 1,
		/datum/gizpulse/explode/fire = 1,
		/datum/gizpulse/dispense/robot_spider = 1,
		/datum/gizpulse/thrower = 1,
		/datum/gizpulse/thrower/grenade = 1,
		/datum/gizpulse/radiation_pulse = 1,
		/datum/gizpulse/bone_breaker = 1,
	)

	guaranteed_active_gizmodes = list(
		/datum/gizpulse/ominous, //it may warn you, it may immediately explode. Who knows!
	)

	min_modes = 1
	max_modes = 2

	cooldown_time = 5 SECONDS

/datum/gizpulse/explode
	var/range_heavy = 0
	var/range_medium = 1
	var/range_light = 3
	var/range_flame = 0

/datum/gizpulse/explode/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	// AQUILA: u nas piąty argument explosion() to flash_range, płomienie idą nazwanym flame_range
	explosion(holder, range_heavy, range_medium, range_light, flash_range = range_light, flame_range = range_flame)

/datum/gizpulse/explode/fire
	range_flame = 5

/datum/gizpulse/dispense/robot_spider
	possible_objects = list(
		/mob/living/simple_animal/hostile/spider/robot = 1,
	)

/// AQUILA: tg /mob/living/basic/spider/robot przepisany na nasze pająki simple_animal
/mob/living/simple_animal/hostile/spider/robot
	name = "pająk-robot"
	desc = "Bip bup, powiedział pająk-robot."
	icon_state = "robot"
	icon_living = "robot"
	icon_dead = "robot_dead"
	mob_biotypes = list(MOB_ROBOTIC, MOB_BUG)
	butcher_results = list(/obj/item/stack/sheet/iron = 2, /obj/item/stack/cable_coil = 3)
	speak_emote = list("bipcze")
	emote_hear = list("bipcze.")
	attack_sound = 'sound/weapons/bite.ogg'
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	speed = 5
	maxHealth = 50
	health = 50
	obj_damage = 10
	melee_damage = 12
	player_speed_modifier = 0
	gold_core_spawnable = NO_SPAWN
	discovery_points = 0

/mob/living/simple_animal/hostile/spider/robot/death(gibbed)
	. = ..()

	explosion(src, 0, 0, 2, flash_range = 2)
	if(prob(80) && !QDELETED(src))
		qdel(src)

/mob/living/simple_animal/hostile/spider/robot/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(stat != DEAD)
		death() //very sensitive spider robot antennae makes it die fast to emp

/datum/gizpulse/thrower
	/// Weighted list of items we can throw
	var/list/throwables = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/shard = 1,
	)
	/// Path of item to throw
	var/throwing_path

/datum/gizpulse/thrower/New()
	. = ..()
	throwing_path = pickweight(throwables)

/datum/gizpulse/thrower/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/obj/item/item = new throwing_path(get_turf(holder))

	var/list/targets = list()
	for(var/mob/living/victims in oview(5, holder))
		targets += victims

	if(!targets.len)
		targets += get_edge_target_turf(holder, pick(GLOB.alldirs))
	item.throw_at(pick(targets), 20, 3)
	modify(item)

/// Do some extra modifications if need be
/datum/gizpulse/thrower/proc/modify(obj/item/item)
	return

/datum/gizpulse/ominous/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	holder.audible_message(span_hear("Słyszysz złowieszcze buczenie."))

/datum/gizpulse/thrower/grenade
	throwables = list(
		/obj/item/grenade/iedcasing = 3,
		/obj/item/grenade/chem_grenade/cleaner = 2,
		/obj/item/grenade/smokebomb = 2,
		/obj/item/grenade/syndieminibomb/concussion = 1,
		/obj/item/grenade/frag = 1,
		/obj/item/grenade/chem_grenade/teargas = 1,
		/obj/item/grenade/chem_grenade/facid = 1,
		/obj/item/grenade/chem_grenade/clf3 = 1,
	)

/datum/gizpulse/thrower/grenade/modify(obj/item/item)
	var/obj/item/grenade/regret = item
	if(istype(regret))
		regret.preprime(null, null, FALSE)

/datum/gizpulse/bone_breaker/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/list/victims = list()
	for(var/mob/living/loser in orange(1, holder))
		victims += loser

	if(!victims.len)
		return

	var/mob/living/victim = pick(victims)
	holder.forceMove(get_turf(victim))
	playsound(victim, 'sound/effects/snap.ogg', 70, TRUE)

	// AQUILA: nie mamy ran (wound_bonus), więc obrażenia idą w losową kończynę
	victim.apply_damage(60, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
	victim.Stun(2 SECONDS)
	victim.Knockdown(5 SECONDS)

	victim.emote("scream")
