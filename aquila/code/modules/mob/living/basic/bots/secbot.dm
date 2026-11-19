// Securitron, Beepsky i warianty, Generał Beepsky, ED-209 (z laser tagiem) na basic bocie.
// Zachowanie naszych starych botów ochrony (Bee + głosy Aquili, Armsky z NSV13); pościg i areszt przez wspólny schemat pracy.

/mob/living/basic/bot/secbot
	name = "\improper Securitron"
	desc = "Mały robot ochrony. Nie wygląda na zachwyconego."
	icon_state = "secbot0"
	base_icon_state = "secbot"
	maxHealth = 25
	health = 25
	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	speed = 1
	radio_key = /obj/item/encryptionkey/secbot
	radio_channel = RADIO_CHANNEL_SECURITY
	bot_type = BASIC_SEC_BOT
	model = "Securitron"
	hackables = "system identyfikacji celów"
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_REMOTE_ENABLED
	work_mode = BBOT_HUNT
	work_reach = 1
	work_interval = 0.5 SECONDS
	possessed_message = "Jesteś securitronem! Pilnuj porządku i chroń załogę."
	emagged_message = "Jesteś zepsutym securitronem! Wszyscy to przestępcy, aresztuj ich!"
	/// Pałka z budowy (wypada przy zniszczeniu)
	var/baton_type = /obj/item/melee/baton
	/// Nic nie wypada przy zniszczeniu
	var/noloot = FALSE
	/// Ogłasza aresztowania na kanale ochrony
	var/declare_arrests = TRUE
	/// Aresztuje osoby bez identyfikatora
	var/idcheck = FALSE
	/// Aresztuje za broń bez zezwolenia
	var/weaponscheck = FALSE
	/// Sprawdza nakazy w aktach
	var/check_records = TRUE
	/// Tylko zatrzymuje (bez skuwania)
	var/arrest_type = FALSE
	/// Ostatnio ściganych chwilę ignoruje
	var/oldtarget_name
	var/last_found = 0
	/// Bot zaczyna z włączonym patrolem (mapy)
	var/start_patrolling = FALSE

/mob/living/basic/bot/secbot/Initialize(mapload)
	additional_access = list(ACCESS_SECURITY, ACCESS_SEC_DOORS, ACCESS_FORENSICS_LOCKERS, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS, ACCESS_COURT, ACCESS_BRIG)
	if(start_patrolling)
		bot_mode_flags |= BOT_MODE_AUTOPATROL
	. = ..()
	var/datum/atom_hud/secsensor = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
	secsensor?.add_hud_to(src)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/basic/bot/secbot/req_bot_access()
	return list(ACCESS_SECURITY)

/mob/living/basic/bot/secbot/update_icon_state()
	. = ..()
	if(mode == BBOT_HUNT || mode == BBOT_ARREST)
		icon_state = "[base_icon_state]-c"

/mob/living/basic/bot/secbot/proc/judgment_criteria()
	var/final = NONE
	if(idcheck)
		final |= JUDGE_IDCHECK
	if(check_records)
		final |= JUDGE_RECORDCHECK
	if(weaponscheck)
		final |= JUDGE_WEAPONCHECK
	if(is_emagged())
		final |= JUDGE_EMAGGED
	return final

/mob/living/basic/bot/secbot/proc/check_for_weapons(obj/item/slot_item)
	return slot_item && (slot_item.item_flags & NEEDS_PERMIT)

/mob/living/basic/bot/secbot/proc/threat_of(mob/living/carbon/suspect)
	return suspect.assess_threat(judgment_criteria(), weaponcheck = CALLBACK(src, PROC_REF(check_for_weapons)))

/mob/living/basic/bot/secbot/is_valid_work_target(atom/target)
	if(!iscarbon(target))
		return FALSE
	var/mob/living/carbon/suspect = target
	if(suspect.stat || suspect.handcuffed)
		return FALSE
	if(suspect.name == oldtarget_name && world.time < last_found + 10 SECONDS)
		return FALSE
	return threat_of(suspect) >= 4

/mob/living/basic/bot/secbot/on_work_target_found(atom/target)
	var/mob/living/carbon/suspect = target
	oldtarget_name = suspect.name
	speak("Alarm: wykroczenie poziomu [threat_of(suspect)]!")
	playsound(src, pick('aquila/sound/voice/beepsky/criminal.ogg', 'aquila/sound/voice/beepsky/justice.ogg', 'aquila/sound/voice/beepsky/freeze.ogg'), 50, FALSE)
	visible_message("<b>[src]</b> wskazuje na [suspect.name]!")
	update_bot_mode(BBOT_HUNT)

/mob/living/basic/bot/secbot/work_on_target(atom/target)
	var/mob/living/carbon/suspect = target
	if(!istype(suspect) || suspect.stat == DEAD)
		return BOT_WORK_DONE
	if(!Adjacent(suspect) || !isturf(suspect.loc))
		return BOT_WORK_OUT_OF_REACH
	if(!suspect.IsParalyzed() || arrest_type)
		stun_attack(suspect)
		if(arrest_type)
			last_found = world.time
			return BOT_WORK_DONE
		return BOT_WORK_CONTINUE
	if(suspect.handcuffed || !suspect.canBeHandcuffed())
		last_found = world.time
		return BOT_WORK_DONE
	update_bot_mode(BBOT_ARREST)
	playsound(src, 'sound/weapons/cablecuff.ogg', 30, TRUE, -2)
	suspect.visible_message(span_danger("[src] próbuje założyć opaski zaciskowe [suspect]!"), span_userdanger("[src] próbuje założyć ci opaski zaciskowe!"))
	sleep(6 SECONDS)
	if(QDELETED(src) || QDELETED(suspect) || !(bot_mode_flags & BOT_MODE_ON) || !Adjacent(suspect) || !isturf(suspect.loc))
		return BOT_WORK_CONTINUE
	if(!suspect.handcuffed)
		suspect.handcuffed = new /obj/item/restraints/handcuffs/cable/zipties/used(suspect)
		suspect.update_handcuffed()
		playsound(src, "law", 50, FALSE)
	last_found = world.time
	update_bot_mode(BBOT_IDLE)
	return BOT_WORK_DONE

/mob/living/basic/bot/secbot/proc/stun_attack(mob/living/carbon/suspect)
	if(ishuman(suspect))
		var/mob/living/carbon/human/human_suspect = suspect
		if(human_suspect.check_shields(src, 0))
			return
	playsound(src, 'sound/weapons/egloves.ogg', 50, TRUE, -1)
	flick("[base_icon_state]-c", src)
	suspect.stuttering = 5
	suspect.Paralyze(10 SECONDS)
	log_combat(src, suspect, "stunned")
	if(declare_arrests)
		speak("[arrest_type ? "Zatrzymuję" : "Aresztuję"] szumowinę poziomu [threat_of(suspect)] <b>[suspect]</b> w [get_area(src)].", radio_channel)
	suspect.visible_message(span_danger("[src] ogłusza [suspect]!"), span_userdanger("[src] ogłusza cię!"))

/// Ktoś zaatakował bota: od razu ścigaj
/mob/living/basic/bot/secbot/proc/retaliate(mob/living/carbon/human/attacker)
	if(!istype(attacker) || !ai_controller || stat == DEAD || client)
		return
	if(threat_of(attacker) + 6 < 4)
		return
	ai_controller.set_blackboard_key(BB_BOT_WORK_TARGET, attacker)
	update_bot_mode(BBOT_HUNT)

/// Dodatkowa reakcja po ataku; TRUE przerywa dalszą obsługę ciosu
/mob/living/basic/bot/secbot/proc/special_retaliate_after_attack(mob/user)
	return FALSE

/mob/living/basic/bot/secbot/attack_hand(mob/living/carbon/human/user)
	if(user.combat_mode)
		retaliate(user)
		if(special_retaliate_after_attack(user))
			return
	return ..()

/mob/living/basic/bot/secbot/attack_alien(mob/living/carbon/alien/user)
	. = ..()
	ai_controller?.set_blackboard_key(BB_BOT_WORK_TARGET, user)

/mob/living/basic/bot/secbot/attackby(obj/item/attacking_item, mob/living/user, params)
	. = ..()
	if(attacking_item.tool_behaviour == TOOL_WELDER && !user.combat_mode)
		return
	if(attacking_item.tool_behaviour != TOOL_SCREWDRIVER && attacking_item.force && attacking_item.damtype != STAMINA && !ai_controller?.blackboard[BB_BOT_WORK_TARGET])
		retaliate(user)
		special_retaliate_after_attack(user)

/mob/living/basic/bot/secbot/bullet_act(obj/item/projectile/hitting_projectile, def_zone, piercing_hit = FALSE)
	if((istype(hitting_projectile, /obj/item/projectile/beam) || istype(hitting_projectile, /obj/item/projectile/bullet)) && (hitting_projectile.damage_type == BURN || hitting_projectile.damage_type == BRUTE))
		if(!hitting_projectile.nodamage && hitting_projectile.damage < health && ishuman(hitting_projectile.firer))
			retaliate(hitting_projectile.firer)
	return ..()

/mob/living/basic/bot/secbot/hitby(atom/movable/thrown_atom, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(isitem(thrown_atom))
		var/obj/item/thrown_item = thrown_atom
		var/mob/thrown_by = thrown_item.thrownby?.resolve()
		if(thrown_item.throwforce < health && ishuman(thrown_by))
			retaliate(thrown_by)
	return ..()

/mob/living/basic/bot/secbot/emag_effects(mob/user)
	if(user)
		to_chat(user, span_danger("Zwierasz obwody oceny celów [src]."))
		oldtarget_name = user.name
	audible_message(span_danger("[src] dziwnie brzęczy!"))
	declare_arrests = FALSE
	update_appearance()

/// Wbiega na niego ktoś, kogo nie ściga: przewraca
/mob/living/basic/bot/secbot/proc/on_entered(datum/source, atom/movable/entered)
	SIGNAL_HANDLER
	var/atom/target = ai_controller?.blackboard[BB_BOT_WORK_TARGET]
	if(!has_gravity() || !iscarbon(entered) || !target || in_range(src, target))
		return
	var/mob/living/carbon/runner = entered
	runner.visible_message(span_warning("[runner] potyka się o [src]!"))
	runner.Knockdown(2 SECONDS)

/mob/living/basic/bot/secbot/explode()
	var/atom/drop_spot = drop_location()
	var/obj/item/bot_assembly/secbot/assembly = new(drop_spot)
	assembly.build_step = 1
	assembly.add_overlay("hs_hole")
	assembly.created_name = name
	new /obj/item/assembly/prox_sensor(drop_spot)
	if(!noloot)
		drop_part(baton_type, drop_spot)
	new /obj/effect/decal/cleanable/oil(drop_spot)
	return ..()

/mob/living/basic/bot/secbot/get_custom_controls(mob/user)
	return list(
		"check_id" = idcheck,
		"check_weapons" = weaponscheck,
		"check_records" = check_records,
		"detain_only" = arrest_type,
		"declare_arrests" = declare_arrests,
	)

/mob/living/basic/bot/secbot/bot_custom_act(action, list/params, mob/user)
	switch(action)
		if("check_id")
			idcheck = !idcheck
		if("check_weapons")
			weaponscheck = !weaponscheck
		if("check_records")
			check_records = !check_records
		if("detain_only")
			arrest_type = !arrest_type
		if("declare_arrests")
			declare_arrests = !declare_arrests
		else
			return FALSE
	return TRUE

/mob/living/basic/bot/secbot/beepsky
	name = "Oficer Beep O'sky"
	desc = "To Oficer Beep O'sky! Zasila go ziemniak i kieliszek whisky."
	start_patrolling = TRUE

/mob/living/basic/bot/secbot/beepsky/explode()
	var/atom/drop_spot = drop_location()
	new /obj/item/stock_parts/cell/potato(drop_spot)
	var/obj/item/reagent_containers/food/drinks/drinkingglass/shotglass/shot = new(drop_spot)
	shot.reagents.add_reagent(/datum/reagent/consumable/ethanol/whiskey, 15)
	shot.on_reagent_change(ADD_REAGENT)
	return ..()

/mob/living/basic/bot/secbot/beepsky/jr
	name = "Oficer Pipsqueak"
	desc = "To Pipsqueak, mniejszy, ale równie agresywny kuzyn Oficera Beep O'sky'ego."
	resize = 0.8

/mob/living/basic/bot/secbot/pingsky
	name = "Oficer Pingsky"
	desc = "To Oficer Pingsky! Oddelegowany do pilnowania satelity za żywienie antyludzkich uczuć."
	radio_channel = RADIO_CHANNEL_AI_PRIVATE

/// Sierżant Armsky z NSV13: twardszy, sprawdza identyfikatory i broń, tylko zatrzymuje
/mob/living/basic/bot/secbot/armsky
	name = "Sierżant Armsky"
	maxHealth = 45
	health = 45
	idcheck = TRUE
	weaponscheck = TRUE
	arrest_type = TRUE

/// Generał Beepsky: cztery miecze energetyczne
/mob/living/basic/bot/secbot/grievous
	name = "Generał Beepsky"
	desc = "Czy to securitron z czterema energetycznymi mieczami w ramionach...?"
	icon_state = "grievous"
	base_icon_state = "grievous"
	maxHealth = 150
	health = 150
	speed = 0
	baton_type = /obj/item/melee/transforming/energy/sword/saber
	/// Broń, którą tnie
	var/obj/item/weapon
	/// Szansa na odbicie ciosu w pościgu
	var/block_chance = 50

/mob/living/basic/bot/secbot/grievous/Initialize(mapload)
	. = ..()
	weapon = new baton_type(src)
	weapon.attack_self(src)

/mob/living/basic/bot/secbot/grievous/Destroy()
	QDEL_NULL(weapon)
	return ..()

/mob/living/basic/bot/secbot/grievous/update_icon_state()
	. = ..()
	icon_state = (mode == BBOT_HUNT || mode == BBOT_ARREST) ? "grievous-c" : "grievous"

/mob/living/basic/bot/secbot/grievous/on_work_target_found(atom/target)
	. = ..()
	playsound(src, 'sound/weapons/saberon.ogg', 50, TRUE, -1)
	visible_message("[src] włącza energetyczne miecze!")

/mob/living/basic/bot/secbot/grievous/bullet_act(obj/item/projectile/hitting_projectile, def_zone, piercing_hit = FALSE)
	visible_message("[src] odbija [hitting_projectile] energetycznymi mieczami!")
	playsound(src, 'sound/weapons/blade1.ogg', 50, TRUE)
	return BULLET_ACT_BLOCK

/mob/living/basic/bot/secbot/grievous/special_retaliate_after_attack(mob/user)
	if(mode != BBOT_HUNT || !prob(block_chance))
		return FALSE
	visible_message("[src] odbija atak [user] energetycznymi mieczami!")
	playsound(src, 'sound/weapons/blade1.ogg', 50, TRUE, -1)
	return TRUE

/mob/living/basic/bot/secbot/grievous/work_on_target(atom/target)
	var/mob/living/carbon/suspect = target
	if(!istype(suspect) || suspect.stat == DEAD)
		return BOT_WORK_DONE
	if(!Adjacent(suspect))
		return BOT_WORK_OUT_OF_REACH
	stun_attack(suspect)
	return suspect.stat == DEAD ? BOT_WORK_DONE : BOT_WORK_CONTINUE

/// Przestępcy nie zasługują na życie
/mob/living/basic/bot/secbot/grievous/stun_attack(mob/living/carbon/suspect)
	weapon.attack(suspect, src)
	playsound(src, 'sound/weapons/blade1.ogg', 50, TRUE, -1)

/mob/living/basic/bot/secbot/grievous/explode()
	var/atom/drop_spot = drop_location()
	var/obj/item/bot_assembly/secbot/assembly = new(drop_spot)
	assembly.build_step = 1
	assembly.add_overlay("hs_hole")
	assembly.created_name = name
	new /obj/item/assembly/prox_sensor(drop_spot)
	if(!noloot)
		for(var/i in 1 to 4)
			drop_part(baton_type, drop_spot)
	new /obj/effect/decal/cleanable/oil(drop_spot)
	visible_message(span_boldnotice("[src] wydaje potężne kaszlnięcie i rozpada się na kawałki!"))
	do_sparks(3, TRUE, src)
	if(prob(50) && robot_arm)
		drop_part(robot_arm, drop_spot)

/mob/living/basic/bot/secbot/grievous/toy
	name = "Genewul Bweepskee"
	desc = "Uroczy securitron z czterema zabawkowymi mieczami przyklejonymi taśmą do ramion."
	maxHealth = 50
	health = 50
	baton_type = /obj/item/toy/sword

/mob/living/basic/bot/secbot/grievous/nullcrate
	name = "Generał Griefsky"
	desc = "Syndykat przesyła pozdrowienia."
	noloot = TRUE
	faction = list(FACTION_SYNDICATE)
	bot_access_flags = BOT_COVER_LOCKED | BOT_COVER_EMAGGED

/mob/living/basic/bot/secbot/grievous/nullcrate/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/empprotection, EMP_PROTECT_SELF | EMP_PROTECT_CONTENTS | EMP_PROTECT_WIRES)

/// ED-209: duży robot ochrony, strzela z odległości
/mob/living/basic/bot/secbot/ed209
	name = "\improper Robot ochrony ED-209"
	desc = "Robot ochrony. Nie wygląda na zachwyconego."
	icon_state = "ed2090"
	base_icon_state = "ed209"
	density = TRUE
	maxHealth = 100
	health = 100
	obj_damage = 60
	environment_smash = ENVIRONMENT_SMASH_WALLS
	mob_size = MOB_SIZE_LARGE
	speed = 2
	radio_key = /obj/item/encryptionkey/headset_sec
	model = "ED-209"
	idcheck = TRUE
	weaponscheck = TRUE
	baton_type = null
	/// Kolor laser tagu ("b", "r" albo pusty)
	var/lasercolor = ""
	/// Wyłączony trafieniem laser tagu
	var/disabled = FALSE
	var/projectile = /obj/item/projectile/beam/disabler
	var/shoot_sound = 'sound/weapons/laser.ogg'
	var/shot_delay = 1.5 SECONDS
	COOLDOWN_DECLARE(shot_cooldown)
	var/cell_type = /obj/item/stock_parts/cell
	var/vest_type = /obj/item/clothing/suit/armor/vest

/mob/living/basic/bot/secbot/ed209/Initialize(mapload, created_name, created_lasercolor)
	if(created_lasercolor)
		lasercolor = created_lasercolor
	. = ..()
	if(created_name)
		name = created_name
		real_name = created_name
	base_icon_state = "[lasercolor]ed209"
	if(lasercolor)
		bot_mode_flags &= ~BOT_MODE_AUTOPATROL
		check_records = FALSE
		idcheck = FALSE
		weaponscheck = FALSE
		if(name == initial(name))
			name = lasercolor == "b" ? pick("NIEBIESKA PRZEGRANA", "SUPERNIEBIESKI", "NIEBIESKI CZŁOWIEK", "NIEBIESKOŚĆ", "NIEBIESKA RAKIETA") : pick("CZERWONA PRZEGRANA", "SUPERCZERWONY", "CZERWONY CZŁOWIEK", "CZERWOŃ", "CZERWONA RAKIETA")
	set_weapon()
	update_appearance()

/mob/living/basic/bot/secbot/ed209/update_icon_state()
	. = ..()
	if(disabled)
		icon_state = "[base_icon_state]0"

/mob/living/basic/bot/secbot/ed209/proc/set_weapon()
	shoot_sound = 'sound/weapons/laser.ogg'
	if(is_emagged())
		projectile = lasercolor ? /obj/item/projectile/beam/lasertag : /obj/item/projectile/beam
	else if(lasercolor == "b")
		projectile = /obj/item/projectile/beam/lasertag/bluetag
	else if(lasercolor == "r")
		projectile = /obj/item/projectile/beam/lasertag/redtag
	else
		projectile = /obj/item/projectile/beam/disabler

/mob/living/basic/bot/secbot/ed209/emag_effects(mob/user)
	. = ..()
	set_weapon()

/mob/living/basic/bot/secbot/ed209/threat_of(mob/living/carbon/suspect)
	return suspect.assess_threat(judgment_criteria(), lasercolor, weaponcheck = CALLBACK(src, PROC_REF(check_for_weapons)))

/mob/living/basic/bot/secbot/ed209/can_seek_work()
	return ..() && !disabled

/mob/living/basic/bot/secbot/ed209/work_on_target(atom/target)
	if(lasercolor)
		// laser tag: tylko strzela
		if(!(target in view(7, src)))
			return BOT_WORK_DONE
		shoot_at(target)
		return BOT_WORK_DONE
	return ..()

/mob/living/basic/bot/secbot/ed209/Life(seconds, times_fired)
	. = ..()
	if(stat || disabled || !(bot_mode_flags & BOT_MODE_ON))
		return
	var/mob/living/carbon/target = ai_controller?.blackboard[BB_BOT_WORK_TARGET]
	if(istype(target) && !target.IsParalyzed() && get_dist(src, target) > 1 && (target in view(7, src)))
		shoot_at(target)

/mob/living/basic/bot/secbot/ed209/proc/shoot_at(atom/target)
	if(!COOLDOWN_FINISHED(src, shot_cooldown) || !isturf(loc) || !get_turf(target) || !projectile)
		return
	COOLDOWN_START(src, shot_cooldown, shot_delay)
	var/obj/item/projectile/shot = new projectile(loc)
	playsound(src, shoot_sound, 50, TRUE)
	shot.preparePixelProjectile(target, src)
	shot.fire()

/mob/living/basic/bot/secbot/ed209/RangedAttack(atom/target)
	if(bot_mode_flags & BOT_MODE_ON)
		shoot_at(target)

/mob/living/basic/bot/secbot/ed209/bullet_act(obj/item/projectile/hitting_projectile, def_zone, piercing_hit = FALSE)
	if(!disabled && ((lasercolor == "b" && istype(hitting_projectile, /obj/item/projectile/beam/lasertag/redtag)) || (lasercolor == "r" && istype(hitting_projectile, /obj/item/projectile/beam/lasertag/bluetag))))
		disabled = TRUE
		bot_reset()
		update_appearance()
		addtimer(CALLBACK(src, PROC_REF(reenable)), 10 SECONDS)
		return BULLET_ACT_HIT
	return ..()

/mob/living/basic/bot/secbot/ed209/proc/reenable()
	disabled = FALSE
	update_appearance()

/mob/living/basic/bot/secbot/ed209/allowed(mob/living/user)
	if(lasercolor && ishuman(user))
		var/mob/living/carbon/human/human_user = user
		if((lasercolor == "b" && istype(human_user.wear_suit, /obj/item/clothing/suit/redtag)) || (lasercolor == "r" && istype(human_user.wear_suit, /obj/item/clothing/suit/bluetag)))
			return FALSE
	return ..()

/mob/living/basic/bot/secbot/ed209/emp_act(severity)
	if(severity == 2 && prob(70))
		severity = 1
	. = ..()
	if(. & EMP_PROTECT_SELF || severity < 2)
		return
	var/list/targets = list()
	for(var/mob/living/carbon/nearby in view(12, src))
		if(nearby.stat != DEAD)
			targets += nearby
	if(length(targets) && prob(50))
		shoot_at(pick(targets))

/mob/living/basic/bot/secbot/ed209/explode()
	var/atom/drop_spot = drop_location()
	var/obj/item/bot_assembly/ed209/assembly = new(drop_spot)
	assembly.build_step = 1
	assembly.add_overlay("hs_hole")
	assembly.created_name = name
	new /obj/item/assembly/prox_sensor(drop_spot)
	drop_part(cell_type, drop_spot)
	var/obj/item/gun/energy/dropped_gun
	switch(lasercolor)
		if("b")
			dropped_gun = new /obj/item/gun/energy/laser/bluetag(drop_spot)
		if("r")
			dropped_gun = new /obj/item/gun/energy/laser/redtag(drop_spot)
		else
			dropped_gun = new /obj/item/gun/energy/disabler(drop_spot)
	dropped_gun.cell?.charge = 0
	dropped_gun.update_icon()
	if(prob(50))
		new /obj/item/bodypart/l_leg/robot(drop_spot)
		if(prob(25))
			new /obj/item/bodypart/r_leg/robot(drop_spot)
	if(prob(25))
		if(prob(50))
			new /obj/item/clothing/head/helmet(drop_spot)
		else if(lasercolor == "b")
			new /obj/item/clothing/suit/bluetag(drop_spot)
		else if(lasercolor == "r")
			new /obj/item/clothing/suit/redtag(drop_spot)
		else
			drop_part(vest_type, drop_spot)
	new /obj/effect/decal/cleanable/oil(drop_spot)
	visible_message(span_boldnotice("[src] rozpada się na kawałki!"))
	do_sparks(3, TRUE, src)

/mob/living/basic/bot/secbot/ed209/bluetag
	lasercolor = "b"

/mob/living/basic/bot/secbot/ed209/redtag
	lasercolor = "r"
