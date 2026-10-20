// AQUILA - krwawy robak (port z tgstation#93787 i poprawek)
// W tg to basic mob, tu simple_animal z tą samą logiką.

/mob/living/simple_animal/hostile/blood_worm
	name = "krwawy robak"
	desc = "Kosmiczna pijawka, żywiąca się krwią."
	icon = 'aquila/icons/mob/blood_worm_32x32.dmi'
	icon_state = "hatchling"
	icon_living = "hatchling"
	icon_dead = "hatchling-dead"

	faction = list(FACTION_BLOOD_WORM)
	initial_language_holder = /datum/language_holder/blood_worm
	mob_biotypes = list(MOB_ORGANIC)
	status_flags = CANPUSH // Bez CANSTUN, robaków nie da się ogłuszyć
	gender = NEUTER

	damage_coeff = list(BRUTE = 1, BURN = 1.5, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	pressure_resistance = 200
	combat_mode = TRUE

	attack_sound = 'sound/weapons/bite.ogg'
	attacktext = "gryzie"
	friendly = "obwąchuje"
	response_help = "szturcha"
	response_disarm = "odpycha"
	response_harm = "uderza"
	speak_emote = list("bulgocze")

	// Nie oddychają, ale nie lubią skrajnych temperatur
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	minbodytemp = T0C - 100
	maxbodytemp = T0C + 100

	AIStatus = AI_OFF
	can_have_ai = FALSE
	wander = FALSE
	stop_automated_movement = TRUE
	healable = FALSE
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	discovery_points = 2000
	// Wstrzykiwacz Lazarusa nie zrobi z robaka posłusznego zwierzaka (tgstation#97377)
	sentience_type = SENTIENCE_BOSS

	/// Numer robaka, przechodzi przez wszystkie etapy wzrostu
	var/id_number = null
	/// Nazwa etapu do stanów ikon, np. "invade-[effect_name]"
	var/effect_name = ""
	/// Ile trwa animacja wychodzenia z nosiciela
	var/leave_host_duration = 0
	/// Obrażenia od zimna na sekundę
	var/unsuitable_cold_damage = 0
	/// Obrażenia od gorąca na sekundę
	var/unsuitable_heat_damage = 0
	/// Obrażenia na sekundę przy ciśnieniu poniżej BLOOD_WORM_MIN_PRESSURE
	var/low_pressure_damage = 0
	/// Zakres obrażeń w zwarciu
	var/melee_damage_lower = 0
	var/melee_damage_upper = 0
	/// Czas wślizgiwania się pod drzwi. 0 = nie potrafi
	var/slide_under_doors_delay = 0

	/// Ile zwykłej krwi (ludzie) robak zjadł
	var/consumed_normal_blood = 0
	/// Ile syntetycznej krwi (małpy, worki, zwierzęta) robak zjadł
	var/consumed_synth_blood = 0
	/// Ile syntetycznej krwi najwyżej liczy się do wzrostu
	var/maximum_synth_blood = 1000
	/// Jak wydajna jest krew syntetyczna względem zwykłej
	var/synth_blood_efficiency = 0.7

	/// Obecny nosiciel, jeśli jest
	var/mob/living/carbon/human/host
	/// Martwy mob, w którym czeka umysł nosiciela, gdy robak go kontroluje
	var/mob/living/blood_worm_host/backseat
	/// Czy robak ma nosiciela i nim steruje
	var/is_possessing_host = FALSE
	/// Regeneracja w punktach zdrowia na sekundę
	var/regen_rate = 0

	// Akcje: ścieżki typów na typie, instancje po Initialize
	var/datum/action/cooldown/spell/blood_worm/spit/spit_action
	var/datum/action/cooldown/spell/blood_worm/leech/leech_action
	var/datum/action/cooldown/spell/blood_worm/invade/invade_action
	var/datum/action/cooldown/spell/blood_worm/cocoon/cocoon_action
	var/datum/action/cooldown/spell/blood_worm/inject/transfuse_action
	var/datum/action/cooldown/spell/blood_worm/eject/eject_action
	var/datum/action/cooldown/spell/blood_worm/revive/revive_action

	/// Akcje poza nosicielem
	var/list/innate_actions = list()
	/// Akcje w nosicielu
	var/list/host_actions = list()

	/// Czy właśnie synchronizujemy zdrowie z krwią nosiciela (wtedy obrażenia przechodzą)
	var/syncing_health = FALSE

	COOLDOWN_DECLARE(host_heat_alert_cooldown)
	COOLDOWN_DECLARE(host_bleed_alert_cooldown)

/mob/living/simple_animal/hostile/blood_worm/Initialize(mapload)
	. = ..()
	if(ispath(spit_action))
		spit_action = new spit_action(src)
		innate_actions += spit_action
		host_actions += spit_action
	if(ispath(leech_action))
		leech_action = new leech_action(src)
		innate_actions += leech_action
	invade_action = new /datum/action/cooldown/spell/blood_worm/invade(src)
	innate_actions += invade_action
	if(ispath(cocoon_action))
		cocoon_action = new cocoon_action(src)
		innate_actions += cocoon_action
	if(ispath(transfuse_action))
		transfuse_action = new transfuse_action(src)
		host_actions += transfuse_action
	eject_action = new /datum/action/cooldown/spell/blood_worm/eject(src)
	host_actions += eject_action
	revive_action = new /datum/action/cooldown/spell/blood_worm/revive(src)
	host_actions += revive_action

	grant_actions(src, innate_actions)

	ADD_TRAIT(src, TRAIT_BLOOD_HUD, INNATE_TRAIT)
	update_blood_worm_hud_sight()

	if(slide_under_doors_delay)
		AddComponent(/datum/component/slide_under_doors, slide_under_doors_delay)

	RegisterSignal(src, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, PROC_REF(on_pre_living_move))
	RegisterSignal(src, COMSIG_MOB_EXAMINATE, PROC_REF(on_examinate))

	id_number = rand(1, 999)
	update_worm_name()

/mob/living/simple_animal/hostile/blood_worm/Destroy()
	unregister_host()
	for(var/datum/action/action as anything in innate_actions | host_actions)
		qdel(action)
	spit_action = null
	leech_action = null
	invade_action = null
	cocoon_action = null
	transfuse_action = null
	eject_action = null
	revive_action = null
	innate_actions = null
	host_actions = null
	return ..()

/mob/living/simple_animal/hostile/blood_worm/Login()
	. = ..()
	if(!client)
		return
	update_blood_worm_hud_sight()
	var/atom/movable/screen/alert/bloodworm_info/info_alert = throw_alert(ALERT_BLOODWORM_INFO, /atom/movable/screen/alert/bloodworm_info)
	if(istype(info_alert)) // throw_alert zwraca 0, gdy alert już jest
		info_alert.worm_owner = src
	if(slide_under_doors_delay)
		to_chat(src, "<span class='notice'>Potrafisz wślizgnąć się pod drzwi! <b>Kliknij drzwi [secondary_click_text()], żeby się pod nie wcisnąć.</b></span>")

/mob/living/simple_animal/hostile/blood_worm/Logout()
	clear_alert(ALERT_BLOODWORM_INFO)
	return ..()

/mob/living/simple_animal/hostile/blood_worm/Life(seconds, times_fired)
	. = ..()
	if(QDELETED(src) || stat == DEAD)
		return
	var/delta = seconds || 2
	if(host)
		bodytemperature = T20C
		return
	adjust_worm_health(regen_rate * delta)
	handle_low_pressure(delta)

/mob/living/simple_animal/hostile/blood_worm/handle_environment(datum/gas_mixture/environment)
	if(host)
		bodytemperature = T20C
		return
	return ..()

// Osobne obrażenia od zimna i gorąca, liczone na sekundę jak w tg
/mob/living/simple_animal/hostile/blood_worm/handle_temperature_damage()
	if(bodytemperature < minbodytemp && unsuitable_cold_damage > 0)
		adjustHealth(unsuitable_cold_damage * 2)
		throw_alert("temp", /atom/movable/screen/alert/cold, 1)
	else if(bodytemperature > maxbodytemp && unsuitable_heat_damage > 0)
		adjustHealth(unsuitable_heat_damage * damage_coeff[BURN] * 2)
		throw_alert("temp", /atom/movable/screen/alert/hot, 1)
	else
		clear_alert("temp")

/// Za niskie ciśnienie powoli rani robaka (tgstation#96607)
/mob/living/simple_animal/hostile/blood_worm/proc/handle_low_pressure(delta)
	if(low_pressure_damage <= 0 || !isturf(loc))
		clear_alert("pressure")
		return
	var/datum/gas_mixture/environment = loc.return_air()
	var/pressure = environment ? environment.return_pressure() : 0
	if(pressure < BLOOD_WORM_MIN_PRESSURE && !HAS_TRAIT(src, TRAIT_RESISTLOWPRESSURE))
		adjustBruteLoss(low_pressure_damage * delta)
		throw_alert("pressure", /atom/movable/screen/alert/lowpressure, 1)
	else
		clear_alert("pressure")

/mob/living/simple_animal/hostile/blood_worm/proc/update_worm_name()
	var/new_name = "[initial(name)] ([id_number])"
	name = new_name
	real_name = new_name

/mob/living/simple_animal/hostile/blood_worm/AttackingTarget()
	if(target == src)
		// Robakowi nic nie da ugryzienie samego siebie
		to_chat(src, "<span class='warning'>Rezygnujesz z gryzienia samego siebie.</span>")
		return FALSE
	if(melee_damage_upper)
		melee_damage = rand(melee_damage_lower, melee_damage_upper)
	return ..()

/mob/living/simple_animal/hostile/blood_worm/updatehealth()
	. = ..()
	// Ranny robak jest wolniejszy (w tg health_scaling_effects)
	if(maxHealth > 0)
		var/new_speed = initial(speed) + 0.5 * (1 - clamp(health / maxHealth, 0, 1))
		if(abs(new_speed - speed) >= 0.05)
			set_varspeed(new_speed)

// W nosicielu zdrowiem robaka jest krew nosiciela, więc zwykłe obrażenia nic nie robią
/mob/living/simple_animal/hostile/blood_worm/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(host && !syncing_health)
		return 0
	return ..()

/mob/living/simple_animal/hostile/blood_worm/update_mobility(value_otherwise = TRUE)
	. = ..()
	if(HAS_TRAIT(src, TRAIT_IMMOBILIZED))
		mobility_flags &= ~MOBILITY_MOVE

/mob/living/simple_animal/hostile/blood_worm/set_stat(new_stat)
	. = ..()
	if(host && stat != CONSCIOUS)
		leave_host()

/mob/living/simple_animal/hostile/blood_worm/Moved(atom/OldLoc, Dir)
	. = ..()
	if(host && loc != host)
		unregister_host()

/// W nosicielu i w kokonie robak się nie rusza, a spod drzwi wychodzi ruchem
/mob/living/simple_animal/hostile/blood_worm/proc/on_pre_living_move(datum/source)
	SIGNAL_HANDLER
	if(host)
		return COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE
	if(HAS_TRAIT(src, TRAIT_IMMOBILIZED))
		return COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE

/// Zdrowie robaka, w nosicielu liczone z jego krwi
/mob/living/simple_animal/hostile/blood_worm/proc/get_worm_health()
	return host ? min(host.blood_volume * BLOOD_WORM_BLOOD_TO_HEALTH, maxHealth) : health

/// Zmienia zdrowie robaka, w nosicielu przez jego krew. Zwraca faktyczną zmianę.
/mob/living/simple_animal/hostile/blood_worm/proc/adjust_worm_health(amount)
	if(host)
		var/old_volume = host.blood_volume
		host.blood_volume = clamp(host.blood_volume + amount * BLOOD_WORM_HEALTH_TO_BLOOD, 0, maxHealth * BLOOD_WORM_HEALTH_TO_BLOOD)
		return (host.blood_volume - old_volume) * BLOOD_WORM_BLOOD_TO_HEALTH
	var/old_health = health
	adjustBruteLoss(-amount)
	return health - old_health

/mob/living/simple_animal/hostile/blood_worm/proc/grant_actions(mob/target, list/actions)
	for(var/datum/action/action as anything in actions)
		action.Grant(target)

/mob/living/simple_animal/hostile/blood_worm/proc/remove_actions(mob/target, list/actions)
	for(var/datum/action/action as anything in actions)
		if(action.owner == target)
			action.Remove(target)

/// Ustawia zdrowie robaka według krwi nosiciela
/mob/living/simple_animal/hostile/blood_worm/proc/sync_health(already_ejecting = FALSE)
	if(!host)
		return
	var/host_max_blood = maxHealth * BLOOD_WORM_HEALTH_TO_BLOOD
	if(host.blood_volume > host_max_blood)
		host.blood_volume = host_max_blood
	var/cached_blood_volume = host.blood_volume

	syncing_health = TRUE
	bruteloss = round(clamp(maxHealth * (1 - cached_blood_volume / host_max_blood), 0, maxHealth), DAMAGE_PRECISION)
	updatehealth()
	syncing_health = FALSE

	if(!host)
		return
	if(!already_ejecting && cached_blood_volume <= get_eject_volume_threshold())
		to_chat_self("<span class='userdanger'>Brakuje ci krwi, żeby dalej sterować nosicielem!</span>")
		leave_host()
		balloon_alert_self("koniec krwi!")

/// Próg krwi, przy którym robak wylatuje z nosiciela
/mob/living/simple_animal/hostile/blood_worm/proc/get_eject_volume_threshold()
	return maxHealth * BLOOD_WORM_HEALTH_TO_BLOOD * BLOOD_WORM_EJECT_THRESHOLD

/mob/living/simple_animal/hostile/blood_worm/death(gibbed)
	if(host)
		leave_host()
	. = ..()

/obj/effect/temp_visual/blood_worm_invade_host
	icon = 'aquila/icons/mob/blood_worm_32x32.dmi'
	icon_state = "invade-hatchling"
	duration = 2 SECONDS

/obj/effect/temp_visual/blood_worm_invade_host/Initialize(mapload, effect_name)
	. = ..()
	if(effect_name)
		icon_state = "invade-[effect_name]"

// Etapy wzrostu

/mob/living/simple_animal/hostile/blood_worm/hatchling
	name = "larwa krwawego robaka"
	desc = "Świeżo wyklęty krwawy robak. Wygląda na głodnego i słabego, potrzebuje krwi, żeby urosnąć."
	icon_state = "hatchling"
	icon_living = "hatchling"
	icon_dead = "hatchling-dead"
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	butcher_results = list(/obj/item/food/meat/slab/blood_worm = 1)
	maxHealth = 80
	health = 80
	unsuitable_cold_damage = 0.5
	unsuitable_heat_damage = 1
	low_pressure_damage = 0.5
	obj_damage = 15
	melee_damage = 13
	melee_damage_lower = 12
	melee_damage_upper = 14
	armour_penetration = 10
	speed = 0
	effect_name = "hatchling"
	leave_host_duration = 0.6 SECONDS
	slide_under_doors_delay = 3 SECONDS
	leech_action = /datum/action/cooldown/spell/blood_worm/leech/hatchling
	cocoon_action = /datum/action/cooldown/spell/blood_worm/cocoon/hatchling
	transfuse_action = /datum/action/cooldown/spell/blood_worm/inject/hatchling
	regen_rate = 0.3

/mob/living/simple_animal/hostile/blood_worm/juvenile
	name = "młody krwawy robak"
	desc = "Średniej wielkości krwawy robak. Wygląda na żądnego krwi i ma mnóstwo długich, ostrych jak brzytwa zębów."
	icon_state = "juvenile"
	icon_living = "juvenile"
	icon_dead = "juvenile-dead"
	mob_size = MOB_SIZE_SMALL
	butcher_results = list(/obj/item/food/meat/slab/blood_worm = 2)
	maxHealth = 120
	health = 120
	unsuitable_cold_damage = 1
	unsuitable_heat_damage = 1.5
	low_pressure_damage = 1
	obj_damage = 35
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	melee_damage = 20
	melee_damage_lower = 18
	melee_damage_upper = 22
	armour_penetration = 30
	speed = 0.3
	effect_name = "juvenile"
	leave_host_duration = 1 SECONDS
	slide_under_doors_delay = 5 SECONDS
	spit_action = /datum/action/cooldown/spell/blood_worm/spit/juvenile
	leech_action = /datum/action/cooldown/spell/blood_worm/leech/juvenile
	cocoon_action = /datum/action/cooldown/spell/blood_worm/cocoon/juvenile
	transfuse_action = /datum/action/cooldown/spell/blood_worm/inject/juvenile
	regen_rate = 0.4

/mob/living/simple_animal/hostile/blood_worm/adult
	name = "dorosły krwawy robak"
	desc = "Potworny krwawy robak. Lepiej już włożyć głowę do przemysłowej niszczarki niż do jego paszczy."
	icon = 'aquila/icons/mob/blood_worm_32x48.dmi'
	icon_state = "adult"
	icon_living = "adult"
	icon_dead = "adult-dead"
	mob_size = MOB_SIZE_HUMAN
	butcher_results = list(/obj/item/food/meat/slab/blood_worm = 3)
	maxHealth = 180
	health = 180
	unsuitable_cold_damage = 1
	unsuitable_heat_damage = 2
	low_pressure_damage = 2
	obj_damage = 50
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	melee_damage = 27
	melee_damage_lower = 25
	melee_damage_upper = 30
	armour_penetration = 50
	attacktext = "rozszarpuje"
	speed = 0.5
	effect_name = "adult"
	leave_host_duration = 1.4 SECONDS
	spit_action = /datum/action/cooldown/spell/blood_worm/spit/adult
	leech_action = /datum/action/cooldown/spell/blood_worm/leech/adult
	cocoon_action = /datum/action/cooldown/spell/blood_worm/cocoon/adult
	transfuse_action = /datum/action/cooldown/spell/blood_worm/inject/adult
	regen_rate = 0.5

// Robaki z przemiany (wabbajack): nie mają drużyny, a dorosły się nie rozmnaża (tgstation#96017)
/mob/living/simple_animal/hostile/blood_worm/hatchling/polymorph
	cocoon_action = /datum/action/cooldown/spell/blood_worm/cocoon/hatchling/polymorph

/mob/living/simple_animal/hostile/blood_worm/juvenile/polymorph
	cocoon_action = /datum/action/cooldown/spell/blood_worm/cocoon/juvenile/polymorph

/mob/living/simple_animal/hostile/blood_worm/adult/polymorph
	cocoon_action = null

// Mięso

/obj/item/food/meat/slab/blood_worm
	name = "mięso krwawego robaka"
	desc = "Kto wpadł na to, żeby to jeść? Przynajmniej jest soczyste..."
	foodtypes = RAW | MEAT | BUGS | GORE
	food_reagents = list(
		/datum/reagent/blood = 30,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 3,
		/datum/reagent/consumable/nutriment/fat = 2,
	)
	bite_consumption = 10
	tastes = list("krew" = 2, "mięso" = 1)

/obj/item/food/meat/slab/blood_worm/make_grillable()
	AddComponent(/datum/component/grillable, /obj/item/food/meat/steak/blood_worm, rand(30 SECONDS, 90 SECONDS), TRUE, TRUE)

/obj/item/food/meat/steak/blood_worm
	name = "stek z krwawego robaka"
	desc = "No i to jest krwisty stek!"
	tastes = list("mięso" = 1)
	foodtypes = MEAT | BUGS
