/mob/living/simple_animal/hostile/heretic_summon/fire_shark
	name = "\improper Fire Shark"
	real_name = "Fire Shark"
	desc = "To eldritchowy, karłowaty rekin kosmiczny, znany też jako ognisty rekin."
	icon_state = "fire_shark"
	icon_living = "fire_shark"
	pass_flags = PASSTABLE | PASSMOB
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	movement_type = FLYING
	speed = -0.5
	health = 16
	maxHealth = 16
	melee_damage = 8
	attack_sound = 'sound/weapons/bite.ogg'
	attacktext = "gryzie"
	obj_damage = 0
	damage_coeff = list(BRUTE = 1, BURN = 0.25, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	faction = list(FACTION_HERETIC)
	mob_size = MOB_SIZE_TINY
	speak_emote = list("wrzeszczy")
	ventcrawler = VENTCRAWLER_ALWAYS
	/// AQUILA - ile flogistonu wstrzykuje ugryzienie (tg: element venomous)
	var/venom_amount = 2
	/// AQUILA - ile moli plazmy uwalnia po śmierci (tg: element death_gases)
	var/death_plasma = 40
	/// AQUILA - kiedy ostatnio dostał (tg: komponent regenerator)
	var/last_damaged = 0

/mob/living/simple_animal/hostile/heretic_summon/fire_shark/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/swarming)
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)

// Pływa w kosmosie jak karp
/mob/living/simple_animal/hostile/heretic_summon/fire_shark/Process_Spacemove(movement_dir = 0)
	return TRUE

/mob/living/simple_animal/hostile/heretic_summon/fire_shark/on_melee_hit(mob/living/victim)
	if(!iscarbon(victim) || !victim.reagents || victim.stat == DEAD)
		return
	var/mob/living/carbon/carbon_victim = victim
	if(carbon_victim.can_inject(src, FALSE, BODY_ZONE_CHEST, TRUE))
		carbon_victim.reagents.add_reagent(/datum/reagent/phlogiston, venom_amount)

/mob/living/simple_animal/hostile/heretic_summon/fire_shark/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(amount > 0)
		last_damaged = world.time
	return ..()

// Po 10 sekundach bez obrażeń szybko się regeneruje
/mob/living/simple_animal/hostile/heretic_summon/fire_shark/Life(seconds, times_fired)
	. = ..()
	if(stat == DEAD || health >= maxHealth)
		return
	if(world.time < last_damaged + 10 SECONDS)
		return
	adjustBruteLoss(-maxHealth * 0.25)
	adjustFireLoss(-maxHealth * 0.25)

/mob/living/simple_animal/hostile/heretic_summon/fire_shark/death(gibbed)
	var/turf/open/death_turf = get_turf(src)
	if(istype(death_turf) && death_plasma)
		death_turf.atmos_spawn_air("plasma=[death_plasma];TEMP=[T20C]")
	return ..()

/// Dzikie rekiny są wrogie i mają AI
/mob/living/simple_animal/hostile/heretic_summon/fire_shark/wild
	faction = list(FACTION_HOSTILE)
	AIStatus = AI_ON
	can_have_ai = TRUE
	wander = TRUE
