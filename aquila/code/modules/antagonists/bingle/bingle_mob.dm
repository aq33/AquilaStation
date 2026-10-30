// AQUILA - bingle, port z Monkestation (monkestation/code/modules/veth_misc_items/bingle/mob.dm, Monkestation/Monkestation2.0#7051)
// Różnice: simple_animal zamiast basic moba, dezorientacja z Monke to u nas stamina + zamieszanie + drżenie,
// ewolucja w pancernego bingla raz przy 500 punktach Dołu (w Monke co tick nadpisywała zdrowie).

/mob/living/simple_animal/hostile/bingle
	name = "bingiel"
	real_name = "bingiel"
	desc = "Zabawny mały niebieski stworek."
	icon = 'aquila/icons/mob/bingle/bingles.dmi'
	icon_state = "bingle"
	icon_living = "bingle"
	icon_dead = "bingle"
	speak_emote = list("skrzeczy", "jęczy", "bulgocze", "binguje")
	speak_chance = 0
	mob_biotypes = list(MOB_BEAST)
	pass_flags = PASSTABLE
	faction = list(FACTION_BINGLE)
	AIStatus = AI_OFF
	combat_mode = TRUE
	combat_mode_indicator = TRUE
	unique_name = TRUE

	maxHealth = 100
	health = 100
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	unsuitable_atmos_damage = 0

	obj_damage = 70
	melee_damage = 5
	attacktext = "binguje"
	attack_sound = 'sound/effects/blobattack.ogg'
	response_help = "głaszcze"
	response_disarm = "odpycha"
	response_harm = "uderza"
	butcher_results = null

	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	light_range = 4
	light_color = COLOR_BLUE_LIGHT

	/// Czy bingiel jest już pancerny
	var/evolved = FALSE
	/// Dół, z którego bingiel pochodzi
	var/obj/structure/bingle_hole/linked_pit
	/// Ile chmur dymu wypuszcza po śmierci (min, max)
	var/list/death_smoke_count = list(3, 5)
	/// Z czego jest ten dym
	var/list/death_chems = list(
		/datum/reagent/smoke_powder,
		/datum/reagent/toxin/plasma,
		/datum/reagent/drug/space_drugs,
		/datum/reagent/drug/methamphetamine,
		/datum/reagent/toxin/histamine,
		/datum/reagent/consumable/nutriment,
		/datum/reagent/water,
		/datum/reagent/consumable/ethanol,
		/datum/reagent/colorful_reagent,
		/datum/reagent/glitter,
		/datum/reagent/consumable/sugar,
		/datum/reagent/lube,
		/datum/reagent/consumable/sodiumchloride,
		/datum/reagent/consumable/capsaicin,
		/datum/reagent/consumable/frostoil,
		/datum/reagent/medicine/omnizine,
		/datum/reagent/consumable/honey,
		/datum/reagent/clf3,
		/datum/reagent/fluorosurfactant,
		/datum/reagent/consumable/spacemountainwind,
		/datum/reagent/consumable/dr_gibb,
		/datum/reagent/consumable/space_cola,
		/datum/reagent/consumable/coffee,
		/datum/reagent/consumable/tea,
		/datum/reagent/medicine/ephedrine,
		/datum/reagent/medicine/diphenhydramine,
		/datum/reagent/consumable/garlic,
		/datum/reagent/consumable/banana,
		/datum/reagent/iron,
		/datum/reagent/copper,
		/datum/reagent/silver,
		/datum/reagent/gold,
		/datum/reagent/uranium,
		/datum/reagent/medicine/strange_reagent,
		/datum/reagent/toxin/acid,
		/datum/reagent/napalm,
		/datum/reagent/thermite,
		/datum/reagent/drug/krokodil,
		/datum/reagent/drug/bath_salts,
		/datum/reagent/drug/aranesp,
		/datum/reagent/consumable/pineapplejuice,
		/datum/reagent/consumable/tomatojuice,
		/datum/reagent/consumable/potato_juice,
		/datum/reagent/consumable/limejuice,
		/datum/reagent/consumable/orangejuice,
	)

/mob/living/simple_animal/hostile/bingle/Initialize(mapload, obj/structure/bingle_hole/origin_pit)
	. = ..()
	ADD_TRAIT(src, TRAIT_CLUMSY, BINGLE_TRAIT)
	ADD_TRAIT(src, TRAIT_DUMB, BINGLE_TRAIT)
	set_linked_pit(origin_pit)
	update_icon()

/mob/living/simple_animal/hostile/bingle/Destroy()
	set_linked_pit(null)
	return ..()

/mob/living/simple_animal/hostile/bingle/proc/set_linked_pit(obj/structure/bingle_hole/new_pit)
	if(linked_pit)
		UnregisterSignal(linked_pit, COMSIG_PARENT_QDELETING)
		linked_pit = null
	if(!QDELETED(new_pit))
		RegisterSignal(new_pit, COMSIG_PARENT_QDELETING, PROC_REF(on_pit_destruction))
		linked_pit = new_pit

/mob/living/simple_animal/hostile/bingle/proc/on_pit_destruction()
	SIGNAL_HANDLER
	if(!QDELETED(src))
		INVOKE_ASYNC(src, TYPE_PROC_REF(/mob/living, gib))

/mob/living/simple_animal/hostile/bingle/AttackingTarget()
	. = ..()
	if(!. || !isliving(target))
		return
	var/mob/living/victim = target
	if(isbingle(victim))
		return
	victim.adjustStaminaLoss(32)
	victim.confused = max(victim.confused, 3)
	victim.Jitter(3)

/mob/living/simple_animal/hostile/bingle/CanAttack(atom/the_target)
	if(isbingle(the_target))
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/bingle/mind_initialize()
	. = ..()
	if(!IS_BINGLE(src))
		mind.add_antag_datum(/datum/antagonist/bingle)

/mob/living/simple_animal/hostile/bingle/Life(seconds, times_fired)
	. = ..()
	if(stat == DEAD || !linked_pit || get_dist(src, linked_pit) > linked_pit.healing_range)
		return
	if(health < maxHealth)
		adjustBruteLoss(-5 * seconds)
		new /obj/effect/temp_visual/heal(get_turf(src), COLOR_BLUE_LIGHT)

/// Przy Dole bingle poruszają się w kosmosie jak po kratownicy
/mob/living/simple_animal/hostile/bingle/Process_Spacemove(movement_dir = 0)
	if(locate(/obj/structure/bingle_pit_overlay) in range(1, get_turf(src)))
		return TRUE
	if(linked_pit && get_dist(src, linked_pit) <= 1)
		return TRUE
	return ..()

/mob/living/simple_animal/hostile/bingle/set_combat_mode(new_mode, silent = TRUE)
	. = ..()
	update_icon()

/mob/living/simple_animal/hostile/bingle/update_icon_state()
	. = ..()
	if(stat == DEAD)
		return
	var/base = evolved ? "binglearmored" : "bingle"
	icon_state = combat_mode ? "[base]_combat" : base
	icon_living = icon_state

/// Ewolucja w pancernego bingla, gdy Dół przekroczy 500 punktów
/mob/living/simple_animal/hostile/bingle/proc/evolve(fresh = FALSE)
	if(evolved)
		return
	evolved = TRUE
	var/health_ratio = health / maxHealth
	maxHealth = fresh ? 300 : 200
	health = fresh ? maxHealth : round(maxHealth * health_ratio)
	obj_damage = 100
	melee_damage = fresh ? 18 : 15
	armour_penetration = fresh ? 20 : 10
	update_icon()
	if(!fresh)
		to_chat(src, "<span class='notice'>Dół jest pełny jak nigdy! Twoje ciało twardnieje w niebieski pancerz.</span>")

/mob/living/simple_animal/hostile/bingle/death(gibbed)
	. = ..()
	release_death_smoke()
	if(!gibbed)
		gib()

/mob/living/simple_animal/hostile/bingle/proc/release_death_smoke()
	var/turf/T = get_turf(src)
	if(!T)
		return
	for(var/i in 1 to rand(death_smoke_count[1], death_smoke_count[2]))
		var/datum/reagents/carry = new(100)
		carry.my_atom = src
		carry.add_reagent(pick(death_chems), rand(5, 15))
		var/datum/effect_system/smoke_spread/chem/smoke = new
		smoke.set_up(carry, 2, T, silent = TRUE)
		smoke.start()
		qdel(carry)
	log_game("[key_name(src)] burst into chemical smoke at [AREACOORD(T)].")

/mob/living/simple_animal/hostile/bingle/lord
	name = "lord bingli"
	real_name = "lord bingli"
	desc = "Dość duży zabawny mały niebieski stworek."
	icon = 'aquila/icons/mob/bingle/binglelord.dmi'
	icon_state = "binglelord"
	icon_living = "binglelord"
	icon_dead = "binglelord"
	melee_damage = 12
	death_smoke_count = list(10, 15)
	death_chems = list(
		/datum/reagent/smoke_powder,
		/datum/reagent/toxin/plasma,
		/datum/reagent/drug/space_drugs,
		/datum/reagent/drug/methamphetamine,
		/datum/reagent/toxin/histamine,
		/datum/reagent/consumable/nutriment,
		/datum/reagent/water,
		/datum/reagent/consumable/ethanol,
	)
	/// Akcja stawiająca Dół, znika po jego postawieniu
	var/datum/action/cooldown/bingle_spawn_hole/makehole

/mob/living/simple_animal/hostile/bingle/lord/Initialize(mapload, obj/structure/bingle_hole/origin_pit)
	. = ..()
	if(!origin_pit)
		makehole = new
		makehole.Grant(src)

/mob/living/simple_animal/hostile/bingle/lord/Destroy()
	QDEL_NULL(makehole)
	return ..()

/mob/living/simple_animal/hostile/bingle/lord/update_icon_state()
	. = ..()
	if(stat == DEAD)
		return
	icon_state = combat_mode ? "binglelord_combat" : "binglelord"
	icon_living = icon_state

/// Lord nie ma pancernej wersji
/mob/living/simple_animal/hostile/bingle/lord/evolve(fresh = FALSE)
	return
