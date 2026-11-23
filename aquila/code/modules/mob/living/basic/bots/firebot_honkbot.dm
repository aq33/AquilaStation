// Firebot i honkbot na basic bocie (zachowanie naszych starych botów z Bee).

/mob/living/basic/bot/firebot
	name = "\improper Firebot"
	desc = "Mały bot gaśniczy. Wygląda na dość zaniepokojonego."
	icon_state = "firebot0"
	base_icon_state = "firebot"
	maxHealth = 25
	health = 25
	radio_key = /obj/item/encryptionkey/headset_eng
	radio_channel = RADIO_CHANNEL_ENGINEERING
	bot_type = BASIC_FIRE_BOT
	model = "Firebot"
	hackables = "protokoły bezpieczeństwa"
	work_reach = 2
	work_scan_range = 7
	work_interval = 3 SECONDS
	possessed_message = "Jesteś firebotem! Gaś pożary i płonącą załogę."
	emagged_message = "Jesteś zepsutym firebotem! Podpalaj załogę gaśnicą pełną ognia."
	idle_phrases = list("Nie wykryto pożarów.", "Tylko ty możesz zapobiec pożarom na stacji.", "Temperatura w normie.", "Zachowaj chłód.")
	phrase_sounds = list(
		"Nie wykryto pożarów." = 'sound/voice/firebot/nofires.ogg',
		"Tylko ty możesz zapobiec pożarom na stacji." = 'sound/voice/firebot/onlyyou.ogg',
		"Temperatura w normie." = 'sound/voice/firebot/tempnominal.ogg',
		"Zachowaj chłód." = 'sound/voice/firebot/keepitcool.ogg',
		"Stój, padnij i tarzaj się!" = 'sound/voice/firebot/stopdropnroll.ogg',
		"Gaszenie!" = 'sound/voice/firebot/extinguishing.ogg',
		"Wykryto ogień!" = 'sound/voice/firebot/detected.ogg',
	)
	/// Wbudowana gaśnica
	var/obj/item/extinguisher/internal_ext
	var/extinguish_people = TRUE
	var/extinguish_fires = TRUE
	var/stationary_mode = FALSE
	COOLDOWN_DECLARE(detected_cooldown)
	COOLDOWN_DECLARE(foam_cooldown)

/mob/living/basic/bot/firebot/Initialize(mapload)
	additional_access = list(ACCESS_ENGINE, ACCESS_ENGINE_EQUIP, ACCESS_CONSTRUCTION, ACCESS_ATMOSPHERICS, ACCESS_MAINT_TUNNELS, ACCESS_EXTERNAL_AIRLOCKS)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	create_extinguisher()

/mob/living/basic/bot/firebot/Destroy()
	QDEL_NULL(internal_ext)
	return ..()

/mob/living/basic/bot/firebot/req_bot_access()
	return ..() + list(ACCESS_ENGINE)

/mob/living/basic/bot/firebot/proc/create_extinguisher(reagent)
	QDEL_NULL(internal_ext)
	internal_ext = new /obj/item/extinguisher(src)
	if(reagent)
		internal_ext.chem = reagent
		internal_ext.power = 3
		internal_ext.precision = FALSE
	else
		internal_ext.precision = TRUE
	internal_ext.safety = FALSE
	internal_ext.max_water = INFINITY
	internal_ext.refill()

/mob/living/basic/bot/firebot/update_icon_state()
	. = ..()
	if(!(bot_mode_flags & BOT_MODE_ON))
		icon_state = "firebot0"
	else if(IsStun() || IsParalyzed() || stationary_mode)
		icon_state = "firebots1"
	else
		icon_state = "firebot1"

/mob/living/basic/bot/firebot/proc/is_burning(atom/target)
	if(isliving(target))
		var/mob/living/burning = target
		if(burning == src || burning.stat == DEAD)
			return FALSE
		return burning.on_fire || (is_emagged() && !burning.on_fire && iscarbon(burning))
	if(isopenturf(target))
		var/turf/open/burning_turf = target
		return !!burning_turf.active_hotspot
	return FALSE

/mob/living/basic/bot/firebot/get_work_candidates()
	var/scan_range = stationary_mode ? 1 : initial(work_scan_range)
	var/list/candidates = list()
	if(extinguish_people)
		for(var/mob/living/burning in oview(scan_range, src))
			if(is_burning(burning))
				candidates += burning
	if(extinguish_fires)
		for(var/turf/open/burning_turf in RANGE_TURFS(scan_range, src))
			if(is_burning(burning_turf))
				candidates += burning_turf
	return candidates

/mob/living/basic/bot/firebot/on_work_target_found(atom/target)
	if(COOLDOWN_FINISHED(src, detected_cooldown))
		COOLDOWN_START(src, detected_cooldown, 30 SECONDS)
		speak("Wykryto ogień!")

/mob/living/basic/bot/firebot/work_on_target(atom/target)
	if(QDELETED(target) || !is_burning(target))
		return BOT_WORK_DONE
	if(get_dist(src, target) > work_reach)
		return BOT_WORK_OUT_OF_REACH
	speak(ishuman(target) ? "Stój, padnij i tarzaj się!" : "Gaszenie!")
	flick(stationary_mode ? "firebots_use" : "firebot1_use", src)
	internal_ext.afterattack(target, src)
	return is_burning(target) ? BOT_WORK_CONTINUE : BOT_WORK_DONE

/mob/living/basic/bot/firebot/UnarmedAttack(atom/target, proximity_flag)
	if(!(bot_mode_flags & BOT_MODE_ON))
		return
	if(internal_ext)
		internal_ext.afterattack(target, src)
		return
	return ..()

/mob/living/basic/bot/firebot/RangedAttack(atom/target)
	if((bot_mode_flags & BOT_MODE_ON) && internal_ext)
		internal_ext.afterattack(target, src)

/mob/living/basic/bot/firebot/temperature_expose(datum/gas_mixture/air, temperature, volume)
	if((temperature > T0C + 200 || temperature < BODYTEMP_COLD_DAMAGE_LIMIT) && COOLDOWN_FINISHED(src, foam_cooldown))
		COOLDOWN_START(src, foam_cooldown, 5 SECONDS)
		new /obj/effect/particle_effect/foam/firefighting(loc)
	return ..()

/mob/living/basic/bot/firebot/emag_effects(mob/user)
	if(user)
		to_chat(user, span_danger("[src] brzęczy i pika."))
	audible_message(span_danger("[src] dziwnie brzęczy!"))
	playsound(src, "sparks", 75, TRUE)
	extinguish_fires = FALSE
	extinguish_people = TRUE
	// ogień z CLF3 tylko z bliska: drzewo musi podjechać tak samo blisko, jak sprawdza work_on_target()
	work_reach = 1
	create_extinguisher(/datum/reagent/clf3)

/mob/living/basic/bot/firebot/undo_emag_effects()
	. = ..()
	extinguish_fires = initial(extinguish_fires)
	extinguish_people = initial(extinguish_people)
	work_reach = initial(work_reach)
	create_extinguisher()

/mob/living/basic/bot/firebot/bot_reset(bypass_ai_reset)
	. = ..()
	if(!is_emagged())
		create_extinguisher()

/mob/living/basic/bot/firebot/explode()
	var/atom/drop_spot = drop_location()
	new /obj/item/assembly/prox_sensor(drop_spot)
	new /obj/item/clothing/head/hardhat/red(drop_spot)
	var/turf/open/drop_turf = get_turf(src)
	if(istype(drop_turf))
		drop_turf.atmos_spawn_air("water_vapor=20;TEMP=[T20C]")
	return ..()

/mob/living/basic/bot/firebot/get_custom_controls(mob/user)
	return list(
		"extinguish_fires" = extinguish_fires,
		"extinguish_people" = extinguish_people,
		"stationary_mode" = stationary_mode,
	)

/mob/living/basic/bot/firebot/bot_custom_act(action, list/params, mob/user)
	switch(action)
		if("extinguish_fires")
			extinguish_fires = !extinguish_fires
		if("extinguish_people")
			extinguish_people = !extinguish_people
		if("stationary_mode")
			stationary_mode = !stationary_mode
		else
			return FALSE
	update_appearance()
	return TRUE

/// Honkbot: ściga „przestępców” klaksonem, po zhakowaniu ogłusza syreną
/mob/living/basic/bot/honkbot
	name = "\improper honkbot"
	desc = "Mały robot. Wygląda na zadowolonego ze swojego klaksonu."
	icon_state = "honkbot0"
	base_icon_state = "honkbot"
	maxHealth = 25
	health = 25
	radio_key = /obj/item/encryptionkey/headset_service
	radio_channel = RADIO_CHANNEL_SERVICE
	model = "Honkbot"
	hackables = "system sterowania dźwiękiem"
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_REMOTE_ENABLED | BOT_MODE_AUTOPATROL | BOT_MODE_CAN_BE_SAPIENT
	work_mode = BBOT_HUNT
	work_reach = 1
	work_interval = 1 SECONDS
	possessed_message = "Jesteś honkbotem! Trąb na wszystkich, ku radości załogi."
	emagged_message = "Jesteś zepsutym honkbotem! Ogłuszaj każdego syreną."
	/// Dźwięk klaksonu
	var/honksound = 'sound/items/bikehorn.ogg'
	/// Klakson z budowy
	var/bikehorn = /obj/item/bikehorn
	COOLDOWN_DECLARE(honk_cooldown)
	var/oldtarget_name
	var/last_found = 0

/mob/living/basic/bot/honkbot/Initialize(mapload)
	additional_access = list(ACCESS_THEATRE)
	. = ..()
	var/datum/atom_hud/sechud = GLOB.huds[DATA_HUD_SECURITY_BASIC]
	sechud?.add_hud_to(src)

/mob/living/basic/bot/honkbot/req_bot_access()
	return list(ACCESS_THEATRE, ACCESS_ROBOTICS)

/mob/living/basic/bot/honkbot/proc/judgment_criteria()
	return JUDGE_RECORDCHECK | (is_emagged() ? JUDGE_EMAGGED : NONE)

/mob/living/basic/bot/honkbot/proc/sensor_blink()
	flick("honkbot-c", src)

/mob/living/basic/bot/honkbot/proc/react_ping()
	playsound(src, 'sound/machines/ping.ogg', 50, TRUE, -1)
	sensor_blink()
	COOLDOWN_START(src, honk_cooldown, 1.8 SECONDS)

/mob/living/basic/bot/honkbot/proc/bike_horn()
	if(!COOLDOWN_FINISHED(src, honk_cooldown))
		return
	COOLDOWN_START(src, honk_cooldown, is_emagged() ? 3 SECONDS : 1 SECONDS)
	if(is_emagged())
		playsound(src, "honkbot_e", 50, FALSE)
		flick("honkbot-e", src)
	else
		playsound(src, honksound, 50, TRUE, -1)
		sensor_blink()

/mob/living/basic/bot/honkbot/is_valid_work_target(atom/target)
	if(!iscarbon(target))
		return FALSE
	var/mob/living/carbon/victim = target
	if(victim.stat || victim.handcuffed)
		return FALSE
	if(victim.name == oldtarget_name && world.time < last_found + 10 SECONDS)
		return FALSE
	var/threat = victim.assess_threat(judgment_criteria())
	if(threat <= 3 && get_dist(victim, src) <= 4)
		bike_horn()
		return FALSE
	return threat >= 4

/mob/living/basic/bot/honkbot/on_work_target_found(atom/target)
	oldtarget_name = target.name
	bike_horn()
	speak("Honk!")
	visible_message("<b>[src]</b> zaczyna gonić [target.name]!")

/mob/living/basic/bot/honkbot/work_on_target(atom/target)
	var/mob/living/carbon/victim = target
	if(!istype(victim) || victim.stat)
		return BOT_WORK_DONE
	if(!Adjacent(victim))
		return BOT_WORK_OUT_OF_REACH
	last_found = world.time
	if(!is_emagged())
		honk_attack(victim)
		return BOT_WORK_DONE
	if(!victim.IsParalyzed())
		stun_attack(victim)
	return BOT_WORK_CONTINUE

/mob/living/basic/bot/honkbot/proc/honk_attack(mob/living/carbon/victim)
	bike_horn()
	victim.visible_message(span_danger("[src] trąbi na [victim]!"), span_userdanger("[src] trąbi na ciebie!"))

/// Ogłuszenie syreną
/mob/living/basic/bot/honkbot/proc/stun_attack(mob/living/carbon/victim)
	if(!COOLDOWN_FINISHED(src, honk_cooldown))
		return
	COOLDOWN_START(src, honk_cooldown, 3 SECONDS)
	playsound(src, 'sound/items/AirHorn.ogg', 100, TRUE, -1)
	sensor_blink()
	victim.stuttering = 20
	if(ishuman(victim))
		victim.adjustEarDamage(0, 5)
		victim.Jitter(50)
		victim.Paralyze(6 SECONDS)
	else
		victim.Paralyze(8 SECONDS)
	log_combat(src, victim, "honked")
	victim.visible_message(span_danger("[src] trąbi na [victim]!"), span_userdanger("[src] trąbi na ciebie!"))

/mob/living/basic/bot/honkbot/proc/retaliate(mob/living/carbon/human/attacker)
	if(!istype(attacker) || client)
		return
	ai_controller?.set_blackboard_key(BB_BOT_WORK_TARGET, attacker)
	addtimer(CALLBACK(src, PROC_REF(react_buzz)), 0.5 SECONDS)

/mob/living/basic/bot/honkbot/proc/react_buzz()
	playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE, -1)
	sensor_blink()

/mob/living/basic/bot/honkbot/attack_hand(mob/living/carbon/human/user)
	if(user.combat_mode)
		retaliate(user)
	return ..()

/mob/living/basic/bot/honkbot/attackby(obj/item/attacking_item, mob/living/user, params)
	if(attacking_item.tool_behaviour != TOOL_SCREWDRIVER && attacking_item.force && attacking_item.damtype != STAMINA)
		retaliate(user)
	return ..()

/mob/living/basic/bot/honkbot/hitby(atom/movable/thrown_atom, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(isitem(thrown_atom))
		playsound(src, honksound, 50, TRUE, -1)
		var/obj/item/thrown_item = thrown_atom
		var/mob/thrown_by = thrown_item.thrownby?.resolve()
		if(thrown_item.throwforce < health && ishuman(thrown_by))
			retaliate(thrown_by)
	return ..()

/mob/living/basic/bot/honkbot/emag_effects(mob/user)
	if(user)
		to_chat(user, span_danger("Zwierasz system sterowania dźwiękiem [src]. Wydaje z siebie złowieszczy śmiech!!"))
		oldtarget_name = user.name
		last_found = world.time
	audible_message(span_danger("[src] wydaje z siebie złowieszczy śmiech!"))
	playsound(src, 'sound/machines/honkbot_evil_laugh.ogg', 75, TRUE, -1)
	update_appearance()

/mob/living/basic/bot/honkbot/explode()
	var/atom/drop_spot = drop_location()
	new /obj/item/assembly/prox_sensor(drop_spot)
	drop_part(bikehorn, drop_spot)
	playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE, -1)
	return ..()
