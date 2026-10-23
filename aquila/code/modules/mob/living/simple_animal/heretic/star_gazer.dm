// AQUILA - Star Gazer z tg (tam basic mob z kontrolerem AI, pet commands i smyczą), u nas wrogi simple_animal.
// Gdy nikt go nie steruje, działa zwykłe AI simple_animal plus rozkazy pana (Alt+klik, przycisk akcji, mowa, wskazywanie).
// Smycz: jeśli odejdzie od pana dalej niż leash_range, wraca do niego teleportem.
/mob/living/simple_animal/hostile/heretic_summon/star_gazer
	name = "\improper Star Gazer"
	real_name = "Star Gazer"
	desc = "Istota, której powierzono czuwanie nad gwiazdami."
	icon = 'aquila/icons/mob/nonhuman-player/96x96eldritch_mobs.dmi'
	icon_state = "star_gazer"
	icon_living = "star_gazer"
	pixel_x = -32
	base_pixel_x = -32
	mob_biotypes = list(MOB_HUMANOID)
	response_help = "przenika przez"
	speed = -0.2
	maxHealth = 6000
	health = 6000

	obj_damage = 400
	armour_penetration = 20
	melee_damage = 40
	sentience_type = SENTIENCE_BOSS
	attacktext = "rozszarpuje"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	speak_emote = list("warczy")
	damage_coeff = list(BRUTE = 1, BURN = 0.5, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	deathsound = 'aquila/sound/effects/magic/cosmic_expansion.ogg'
	deathmessage = "rozpada się w kosmiczny pył."
	loot = list(/obj/effect/temp_visual/cosmic_domain)

	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_HUGE
	layer = LARGE_MOB_LAYER
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	sight = SEE_TURFS|SEE_MOBS|SEE_OBJS
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	movement_type = FLYING

	// AI działa, gdy nie steruje nim gracz
	AIStatus = AI_ON
	can_have_ai = TRUE
	robust_searching = TRUE
	stat_attack = SOFT_CRIT // tg: BB_TARGET_MINIMUM_STAT = HARD_CRIT
	vision_range = 9
	aggro_vision_range = 9
	move_to_delay = 3

	/// Reference to the mob which summoned us
	var/datum/weakref/summoner
	/// How far we can go before being pulled back
	var/leash_range = 20
	/// Timer for finding a ghost so it doesn't spam dead chat with requests
	var/begging_timer
	/// Aktualny rozkaz pana (STAR_GAZER_COMMAND_*)
	var/command_mode = STAR_GAZER_COMMAND_FREE
	/// Cel wskazany rozkazem ataku
	var/datum/weakref/command_target
	/// Ostatnio wskazany przez pana cel i kiedy
	var/datum/weakref/last_pointed_target
	var/last_pointed_time = 0
	/// Kiedy ostatnio oberwaliśmy (do regeneracji, tg: /datum/component/regenerator)
	var/last_damage_time = 0
	/// Żeby wybuch śmierci nie poszedł dwa razy
	var/death_exploded = FALSE
	///---- Abilities given to the star gazer mob
	var/list/abilities_to_grant = list(
		/datum/action/cooldown/spell/conjure/cosmic_expansion,
		/datum/action/cooldown/spell/pointed/projectile/star_blast,
		/datum/action/cooldown/recall_stargazer,
		/datum/action/cooldown/spell/stargazer_laser,
	)

/mob/living/simple_animal/hostile/heretic_summon/star_gazer/Initialize(mapload, mob/living/master)
	. = ..()
	for(var/datum/action/action_type as anything in abilities_to_grant)
		var/datum/action/new_action = new action_type(src)
		new_action.Grant(src)
	if(master)
		set_summoner(master)
	AddElement(/datum/element/effect_trail/cosmic_field/antiprojectile, /obj/effect/forcefield/cosmic_field/fast)
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_LAVA_IMMUNE, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_MARTIAL_ARTS_IMMUNE, MEGAFAUNA_TRAIT)
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_MAGICALLY_GIFTED, INNATE_TRAIT)
	set_light(4, 1, "#dcaa5b")
	INVOKE_ASYNC(src, PROC_REF(beg_for_ghost))

/mob/living/simple_animal/hostile/heretic_summon/star_gazer/Destroy()
	deltimer(begging_timer)
	var/mob/living/master = summoner?.resolve()
	if(master)
		UnregisterSignal(master, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_POINTED))
	summoner = null
	command_target = null
	last_pointed_target = null
	return ..()

/mob/living/simple_animal/hostile/heretic_summon/star_gazer/examine(mob/user)
	. = ..()
	if(user == summoner?.resolve())
		. += span_notice("Alt+klik, żeby wydać rozkaz. Możesz też rozkazywać mową: \"za mną\", \"zostań\", \"wolny\", \"atakuj\" (wskaż cel).")

/// Ustawia pana: jego zaklęcia go nie ranią, AI go nie atakuje
/mob/living/simple_animal/hostile/heretic_summon/star_gazer/proc/set_summoner(mob/living/master)
	summoner = WEAKREF(master)
	befriend(master)
	for(var/datum/action/cooldown/spell/conjure/cosmic_expansion/expansion in actions)
		expansion.summoner = WEAKREF(master)
	for(var/datum/action/cooldown/spell/pointed/projectile/star_blast/blast in actions)
		blast.summoner = WEAKREF(master)
	for(var/datum/action/cooldown/spell/stargazer_laser/laser in actions)
		laser.our_master = WEAKREF(master)
	RegisterSignal(master, COMSIG_MOB_POINTED, PROC_REF(on_master_pointed), override = TRUE)

/// tg: befriend() z basic mobów - AI nie atakuje przyjaciół
/mob/living/simple_animal/hostile/heretic_summon/star_gazer/proc/befriend(mob/living/new_friend)
	friends |= new_friend
	if(target == new_friend)
		LoseTarget()

/mob/living/simple_animal/hostile/heretic_summon/star_gazer/CanAttack(atom/the_target)
	if(the_target == summoner?.resolve())
		return FALSE
	if(isliving(the_target) && (the_target in friends))
		return FALSE
	return ..()

/// Tries to find a ghost to take control of the mob. If no ghost accepts, ask again in a bit
/mob/living/simple_animal/hostile/heretic_summon/star_gazer/proc/beg_for_ghost()
	if(client || QDELETED(src) || stat == DEAD)
		return
	if(begging_timer && timeleft(begging_timer))
		return
	begging_timer = addtimer(CALLBACK(src, PROC_REF(beg_for_ghost)), 2 MINUTES, TIMER_STOPPABLE | TIMER_UNIQUE) // Keep begging until someone accepts
	var/mob/chosen_ghost = SSpolling.poll_ghost_candidates(new /datum/poll_config(
		question = "Czy chcesz zagrać jako Star Gazer wzniesionego heretyka?",
		check_jobban = ROLE_HERETIC,
		poll_time = 20 SECONDS,
		ignore_category = POLL_IGNORE_HERETIC_MONSTER,
		alert_pic = src,
		jump_target = src,
		role_name_text = "star gazer",
		amount_to_pick = 1,
	))
	if(!chosen_ghost || QDELETED(src) || client)
		return
	deltimer(begging_timer)
	begging_timer = null
	key = chosen_ghost.key
	var/mob/living/master = summoner?.resolve()
	to_chat(src, span_mansus("Jesteś Star Gazerem - wielką istotą z gwiazd. Chroń [master ? master.real_name : "swojego pana"] i niszcz jego wrogów. Nie możesz oddalić się od niego zbyt daleko."))

/// tg: sygnał COMSIG_MOB_GHOSTIZED - po odejściu gracza szukamy następnego
/mob/living/simple_animal/hostile/heretic_summon/star_gazer/ghostize(can_reenter_corpse = TRUE, sentience_retention = SENTIENCE_SKIP)
	. = ..()
	if(!QDELETED(src) && stat != DEAD)
		INVOKE_ASYNC(src, PROC_REF(beg_for_ghost))

/// Connects these two mobs by a leash
/mob/living/simple_animal/hostile/heretic_summon/star_gazer/proc/leash_to(atom/movable/leashed, atom/movable/leashed_to)
	RegisterSignal(leashed_to, COMSIG_MOVABLE_MOVED, PROC_REF(check_leash), override = TRUE)
	RegisterSignal(leashed, COMSIG_MOVABLE_MOVED, PROC_REF(check_leash), override = TRUE)

/// Sprawdza smycz, gdy ktoś z pary się ruszy
/mob/living/simple_animal/hostile/heretic_summon/star_gazer/proc/check_leash(datum/source)
	SIGNAL_HANDLER
	var/mob/living/master = summoner?.resolve()
	if(!master || QDELETED(master))
		return
	var/turf/master_turf = get_turf(master)
	var/turf/our_turf = get_turf(src)
	if(!master_turf || !our_turf)
		return
	if(master_turf.z == our_turf.z && get_dist(master_turf, our_turf) <= leash_range)
		return
	INVOKE_ASYNC(src, PROC_REF(snap_to_master))

/mob/living/simple_animal/hostile/heretic_summon/star_gazer/proc/snap_to_master()
	var/mob/living/master = summoner?.resolve()
	var/turf/master_turf = get_turf(master)
	if(!master_turf || QDELETED(src))
		return
	new /obj/effect/temp_visual/guardian/phase/out(get_turf(src))
	forceMove(master_turf)
	new /obj/effect/temp_visual/guardian/phase(master_turf)

// Star gazer attacks everything around itself applies a spooky mark
/mob/living/simple_animal/hostile/heretic_summon/star_gazer/AttackingTarget()
	if(!target || target == summoner?.resolve() || (target in friends))
		return FALSE
	. = ..()
	if(!isliving(target))
		return
	var/mob/living/living_target = target

	living_target.apply_status_effect(/datum/status_effect/star_mark)
	living_target.apply_damage(5, BURN)
	for(var/mob/living/nearby_mob in range(1, src))
		if(nearby_mob == src || living_target == nearby_mob || !CanAttack(nearby_mob))
			continue
		nearby_mob.apply_status_effect(/datum/status_effect/star_mark)
		nearby_mob.apply_damage(10)
		to_chat(nearby_mob, span_userdanger("[src] [attacktext] cię!"))
		do_attack_animation(nearby_mob, ATTACK_EFFECT_SLASH)
		log_combat(src, nearby_mob, "slashed")

/mob/living/simple_animal/hostile/heretic_summon/star_gazer/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(amount > 0)
		last_damage_time = world.time

/mob/living/simple_animal/hostile/heretic_summon/star_gazer/Life()
	. = ..()
	if(!. || stat == DEAD)
		return
	// tg: /datum/component/regenerator - po 6 s bez obrażeń leczy 2 obrażenia fizyczne na sekundę
	if(health < maxHealth && world.time > last_damage_time + 6 SECONDS)
		adjustBruteLoss(-4)

/mob/living/simple_animal/hostile/heretic_summon/star_gazer/death(gibbed)
	if(!death_exploded)
		death_exploded = TRUE
		var/turf/our_turf = get_turf(src)
		if(our_turf)
			INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(explosion), our_turf, 3, 6, 12) // tg: /datum/element/death_explosion
	return ..()

// ---------------------------------------------------------------------------
// Rozkazy (tg: /datum/component/obeys_commands i /datum/pet_command)

/mob/living/simple_animal/hostile/heretic_summon/star_gazer/AltClick(mob/user)
	if(user == summoner?.resolve() && isliving(user))
		INVOKE_ASYNC(src, PROC_REF(open_command_menu), user)
		return
	return ..()

/// Radialne menu rozkazów dla pana
/mob/living/simple_animal/hostile/heretic_summon/star_gazer/proc/open_command_menu(mob/living/user)
	var/static/list/command_icons
	if(!command_icons)
		command_icons = list(
			"Podążaj" = image(icon = 'aquila/icons/hud/radial_pets.dmi', icon_state = "follow"),
			"Zostań" = image(icon = 'aquila/icons/hud/radial_pets.dmi', icon_state = "halt"),
			"Wolny" = image(icon = 'aquila/icons/hud/radial_pets.dmi', icon_state = "free"),
			"Atakuj" = image(icon = 'aquila/icons/hud/radial_pets.dmi', icon_state = "attack"),
		)
	var/choice = show_radial_menu(user, user, command_icons, radius = 38, tooltips = TRUE)
	if(!choice || QDELETED(src) || user.incapacitated())
		return
	switch(choice)
		if("Podążaj")
			set_command(STAR_GAZER_COMMAND_FOLLOW, user)
		if("Zostań")
			set_command(STAR_GAZER_COMMAND_IDLE, user)
		if("Wolny")
			set_command(STAR_GAZER_COMMAND_FREE, user)
		if("Atakuj")
			set_command(STAR_GAZER_COMMAND_ATTACK, user)
			var/mob/living/pointed = last_pointed_target?.resolve()
			if(pointed && world.time < last_pointed_time + 10 SECONDS)
				set_attack_target(pointed)
			else
				to_chat(user, span_notice("Wskaż cel (Shift+środkowy przycisk albo „Wskaż”), żeby [src] go zaatakował."))

/// Zmienia rozkaz
/mob/living/simple_animal/hostile/heretic_summon/star_gazer/proc/set_command(new_mode, mob/living/commander)
	command_mode = new_mode
	if(new_mode != STAR_GAZER_COMMAND_ATTACK)
		command_target = null
	if(new_mode == STAR_GAZER_COMMAND_IDLE || new_mode == STAR_GAZER_COMMAND_FOLLOW)
		LoseTarget()
	var/command_text
	switch(new_mode)
		if(STAR_GAZER_COMMAND_FOLLOW)
			command_text = "podążaj"
		if(STAR_GAZER_COMMAND_IDLE)
			command_text = "zostań"
		if(STAR_GAZER_COMMAND_FREE)
			command_text = "rób, co chcesz"
		if(STAR_GAZER_COMMAND_ATTACK)
			command_text = "atakuj"
	if(client)
		to_chat(src, span_mansus("Twój pan rozkazuje: [command_text]!"))
	else
		visible_message(span_notice("[src] wpatruje się w [commander]."))
	if(AIStatus == AI_IDLE)
		toggle_ai(AI_ON)

/mob/living/simple_animal/hostile/heretic_summon/star_gazer/proc/set_attack_target(mob/living/new_target)
	if(!isliving(new_target) || new_target == src || new_target == summoner?.resolve())
		return
	command_target = WEAKREF(new_target)
	if(client)
		to_chat(src, span_mansus("Twój pan wskazuje cel: [new_target]!"))
	else
		visible_message(span_danger("[src] wpatruje się intensywnie w [new_target]!"))
		GiveTarget(new_target)
	if(AIStatus == AI_IDLE)
		toggle_ai(AI_ON)

/// Pan coś wskazał
/mob/living/simple_animal/hostile/heretic_summon/star_gazer/proc/on_master_pointed(mob/living/source, atom/pointed_at)
	SIGNAL_HANDLER
	if(!isliving(pointed_at) || pointed_at == src || pointed_at == source)
		return
	if(get_dist(source, src) > 9)
		return
	last_pointed_target = WEAKREF(pointed_at)
	last_pointed_time = world.time
	if(command_mode == STAR_GAZER_COMMAND_ATTACK)
		set_attack_target(pointed_at)

/// Rozkazy mową, jak speech_commands w tg
/mob/living/simple_animal/hostile/heretic_summon/star_gazer/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	. = ..()
	if(radio_freq || !speaker || speaker != summoner?.resolve() || !raw_message)
		return
	var/lowered = lowertext(raw_message)
	var/static/list/follow_words = list("za mną", "do nogi", "podążaj", "chodź", "heel", "follow")
	var/static/list/idle_words = list("zostań", "stój", "czekaj", "siad", "stay", "stop")
	var/static/list/free_words = list("wolny", "swobodnie", "luzem", "free", "loose")
	var/static/list/attack_words = list("atakuj", "bierz", "zabij", "szarp", "attack", "sic", "kill")
	for(var/word in attack_words)
		if(findtext(lowered, word))
			set_command(STAR_GAZER_COMMAND_ATTACK, speaker)
			var/mob/living/pointed = last_pointed_target?.resolve()
			if(pointed && world.time < last_pointed_time + 10 SECONDS)
				set_attack_target(pointed)
			return
	for(var/word in follow_words)
		if(findtext(lowered, word))
			set_command(STAR_GAZER_COMMAND_FOLLOW, speaker)
			return
	for(var/word in idle_words)
		if(findtext(lowered, word))
			set_command(STAR_GAZER_COMMAND_IDLE, speaker)
			return
	for(var/word in free_words)
		if(findtext(lowered, word))
			set_command(STAR_GAZER_COMMAND_FREE, speaker)
			return

/// AI z rozkazami. Bez gracza; gracz steruje sam.
/mob/living/simple_animal/hostile/heretic_summon/star_gazer/handle_automated_action()
	if(AIStatus == AI_OFF)
		return FALSE
	var/mob/living/master = summoner?.resolve()
	switch(command_mode)
		if(STAR_GAZER_COMMAND_IDLE)
			if(target)
				LoseTarget()
			SSmove_manager.stop_looping(src)
			return TRUE
		if(STAR_GAZER_COMMAND_ATTACK)
			var/mob/living/ordered_target = command_target?.resolve()
			if(ordered_target && ordered_target.stat < UNCONSCIOUS && !QDELETED(ordered_target) && ordered_target.z == z)
				if(target != ordered_target)
					GiveTarget(ordered_target)
				if(!target.Adjacent(src))
					DestroyPathToTarget()
				MoveToTarget(list(ordered_target))
				return TRUE
			// Cel padł albo uciekł - wracamy do pana
			command_target = null
			command_mode = STAR_GAZER_COMMAND_FOLLOW
			LoseTarget()
		if(STAR_GAZER_COMMAND_FREE)
			return ..()
	// Podążanie: idziemy za panem, ale bronimy się, gdy coś nas zaatakuje
	if(target && !QDELETED(target) && CanAttack(target) && (!master || get_dist(target, master) <= 7))
		return ..()
	if(target)
		LoseTarget()
	if(master && get_dist(src, master) > 2)
		Goto(master, move_to_delay, 2)
	return TRUE

/mob/living/simple_animal/hostile/heretic_summon/star_gazer/handle_automated_movement()
	if(command_mode != STAR_GAZER_COMMAND_FREE)
		return FALSE // nie wędrujemy losowo
	return ..()

/// Akcja dla pana: menu rozkazów (tg: /datum/action/cooldown/open_mob_commands)
/datum/action/cooldown/star_gazer_commands
	name = "Command Star Gazer"
	desc = "Wydaj rozkaz swojemu Star Gazerowi."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "stargazer_menu"
	cooldown_time = 1 SECONDS
	/// Nasz Star Gazer
	var/datum/weakref/gazer_ref

/datum/action/cooldown/star_gazer_commands/proc/set_gazer(mob/living/simple_animal/hostile/heretic_summon/star_gazer/gazer)
	gazer_ref = WEAKREF(gazer)

/datum/action/cooldown/star_gazer_commands/Trigger()
	if(!..())
		return FALSE
	var/mob/living/simple_animal/hostile/heretic_summon/star_gazer/gazer = gazer_ref?.resolve()
	if(!gazer || !isliving(owner))
		owner.balloon_alert(owner, "brak Star Gazera!")
		return FALSE
	StartCooldown()
	INVOKE_ASYNC(gazer, TYPE_PROC_REF(/mob/living/simple_animal/hostile/heretic_summon/star_gazer, open_command_menu), owner)
	return TRUE

/datum/action/cooldown/recall_stargazer
	name = "Seek master"
	desc = "Przenosi cię do twojego pana."
	background_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "stargazer_menu"
	check_flags = NONE
	cooldown_time = 5 SECONDS

/datum/action/cooldown/recall_stargazer/Trigger()
	if(!..())
		return FALSE
	var/mob/living/simple_animal/hostile/heretic_summon/star_gazer/real_owner = owner
	if(!istype(real_owner))
		return FALSE
	var/mob/living/master = real_owner.summoner?.resolve()
	if(!master)
		return FALSE
	do_teleport(owner, get_turf(master), no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC, forced = TRUE)
	StartCooldown()
	return TRUE

/datum/action/cooldown/spell/stargazer_laser
	name = "Star Gaze"
	desc = "Tworzy potężny promień śmierci, który zmiata wszystko na swojej drodze. \
			Ma własną grawitację, która wciąga kolejne ofiary."
	background_icon_state = "bg_ecult"
	overlay_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "gazer_beam_charge"
	check_flags = NONE
	cooldown_time = 30 SECONDS
	invocation = "SH''P D' W''P"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	/// list of turfs we are hitting while shooting our beam
	var/list/turf/targets
	/// Timer that handles the damage ticking
	var/damage_timer
	/// Reference to our summoner so that we don't disintegrate them by accident
	var/datum/weakref/our_master
	/// The overlay on the caster when they fire the beam
	var/obj/effect/abstract/gazer_orb/orb_visual
	/// The visual effect at the beginning of the laser
	var/obj/effect/abstract/gazer_beam/beam_visual
	/// List of visual effects for the beam, in between and in the end
	var/list/beam_fillings
	/// Sound loop for the active laser
	var/datum/looping_sound/gazer_beam/sound_loop
	/// The visual effect at the end of the laser
	var/obj/effect/abstract/gazer_beamend/end_visual
	/// Tracks how many times the beam has processed, after the maximum amount of cycles it will forcibly end the beam
	var/cycle_tracker = 0

/datum/action/cooldown/spell/stargazer_laser/New(Target, original)
	. = ..()
	sound_loop = new

/datum/action/cooldown/spell/stargazer_laser/Destroy()
	stop_beaming()
	QDEL_NULL(sound_loop)
	return ..()

/datum/action/cooldown/spell/stargazer_laser/cast(atom/target)
	. = ..()

	cooldown_time = initial(cooldown_time)
	if(damage_timer)
		stop_beaming()

	var/turf/check_turf = get_step(owner, owner.dir)
	var/list/turf/targets_left = list()
	targets_left += get_step(check_turf, turn(owner.dir, 90))
	var/list/turf/targets_right = list()
	targets_right += get_step(check_turf, turn(owner.dir, -90))
	LAZYINITLIST(targets)
	while(check_turf && length(targets) < 20)
		targets += check_turf
		check_turf = get_step(check_turf, owner.dir)
		targets_left += get_step(check_turf, turn(owner.dir, 90))
		targets_right += get_step(check_turf, turn(owner.dir, -90))
	// AQUILA - przy krawędzi mapy wiązka byłaby za krótka na grafikę
	if(length(targets) < 6)
		targets = null
		cooldown_time = 1 SECONDS
		return

	RegisterSignals(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE), PROC_REF(stop_beaming))
	beam_fillings = list()
	cycle_tracker = 0
	orb_visual = new(get_step(owner, owner.dir))
	var/beam_timer = addtimer(CALLBACK(src, PROC_REF(open_laser), owner, targets), 2.2 SECONDS, TIMER_STOPPABLE)
	playsound(owner, 'aquila/sound/mobs/non-humanoids/stargazer/beam_open.ogg', 50, FALSE)
	if(!do_after(owner, 3 SECONDS, FALSE, owner) || !targets)
		cooldown_time = 1 SECONDS
		deltimer(beam_timer)
		UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE))
		QDEL_NULL(orb_visual)
		QDEL_NULL(beam_visual)
		QDEL_NULL(end_visual)
		QDEL_LIST(beam_fillings)
		targets = null
		return

	sound_loop.start(owner)
	QDEL_NULL(orb_visual)
	if(beam_visual)
		beam_visual.icon_state = "gazer_beam_active"
	if(end_visual)
		end_visual.icon_state = "gazer_beam_end"
	targets += targets_left
	targets += targets_right
	process_beam()

/// Spawns the beginning of the laser, uses `targets` to determine the rotation
/datum/action/cooldown/spell/stargazer_laser/proc/open_laser(mob/owner, list/turf/targets)
	if(!length(targets))
		return
	beam_visual = new(get_step(get_step(owner, owner.dir), owner.dir), targets[length(targets)])
	end_visual = new(targets[length(targets)], owner)
	for(var/turf/to_fill as anything in getline(targets[4], targets[length(targets)-2]))
		var/obj/effect/abstract/gazer_beam_filling/new_filling = new(to_fill, owner.dir)
		beam_fillings += new_filling

// Visual effect of the big orb when you start channeling the laser
/obj/effect/abstract/gazer_orb
	icon = 'icons/effects/160x160.dmi'
	icon_state = "gazer_beam_charge"
	pixel_x = -64
	pixel_y = -64

// Visual effect at the start of the beam, has an opening/active/closing state
/obj/effect/abstract/gazer_beam
	icon = 'aquila/icons/effects/beam96x96.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/effect/abstract/gazer_beam/Initialize(mapload, turf/target)
	. = ..()
	if(!target)
		return INITIALIZE_HINT_QDEL
	var/Angle = get_angle(src, target)
	var/matrix/transform_matrix = matrix()
	Angle = round(Angle, 45)
	transform_matrix.Turn(Angle-90)
	transform_matrix.Scale(2, 2)
	transform = transform_matrix
	flick("gazer_beam_start", src)

// Visual effect of the middle of the beam, has an opening/active/closing state
/obj/effect/abstract/gazer_beam_filling
	icon = 'icons/effects/beam.dmi'
	icon_state = "gazer_beam"

/obj/effect/abstract/gazer_beam_filling/Initialize(mapload, direction)
	. = ..()
	if(!direction)
		return INITIALIZE_HINT_QDEL
	var/Angle = dir2angle(direction)
	var/matrix/transform_matrix = matrix()
	transform_matrix.Turn(Angle)
	transform_matrix.Scale(2, 2)
	transform = transform_matrix
	flick("gazer_beam_end_opening", src)

/obj/effect/abstract/gazer_beam_filling/proc/pull_victims()
	for(var/atom/movable/movable_atom in orange(5, src))
		if((movable_atom.anchored || movable_atom.move_resist >= MOVE_FORCE_EXTREMELY_STRONG))
			continue
		if(ismob(movable_atom))
			var/mob/pulled_mob = movable_atom
			if(pulled_mob.mob_negates_gravity())
				continue
		step_towards(movable_atom, src)

// Visual effect at the end of the beam, has an opening/active/closing state
/obj/effect/abstract/gazer_beamend
	icon = 'icons/effects/beam.dmi'

/obj/effect/abstract/gazer_beamend/Initialize(mapload, atom/origin)
	. = ..()
	if(!origin)
		return INITIALIZE_HINT_QDEL
	var/Angle = get_angle(origin, src)
	var/matrix/transform_matrix = matrix()
	Angle = round(Angle, 45)
	transform_matrix.Turn(Angle)
	transform_matrix.Scale(2, 2)
	transform = transform_matrix
	flick("gazer_beam_end_opening", src)

/datum/looping_sound/gazer_beam
	mid_sounds = list('aquila/sound/mobs/non-humanoids/stargazer/beam_loop_one.ogg')
	mid_length = 109
	volume = 80

/// Recursive proc which affects whatever is caught within the beam
/datum/action/cooldown/spell/stargazer_laser/proc/process_beam()
	if(cycle_tracker > 33)
		stop_beaming()
		return
	for(var/obj/effect/abstract/gazer_beam_filling/fillings as anything in beam_fillings)
		if(prob(98))
			continue
		// 2% chance to pull you towards the beam
		fillings.pull_victims()
	var/mob/living/master = our_master?.resolve()
	for(var/turf/target as anything in targets)
		if(iswallturf(target))
			var/turf/closed/wall/wall_target = target
			wall_target.dismantle_wall(devastated = TRUE)
			continue
		if(isfloorturf(target))
			var/turf/open/floor/to_burn = target
			to_burn.burn_tile()
		for(var/victim in target)
			if(isobj(victim))
				var/obj/to_obliterate = victim
				if(to_obliterate.resistance_flags & INDESTRUCTIBLE)
					continue
				if(istype(to_obliterate, /obj/effect))
					continue
				to_obliterate.obj_destruction("fire")
			if(isliving(victim))
				if(victim == master || victim == owner)
					continue
				var/mob/living/living_victim = victim
				if(living_victim.stat != CONSCIOUS)
					playsound(living_victim, 'sound/effects/supermatter.ogg', 80, TRUE)
					living_victim.visible_message(
						span_danger("[living_victim] zostaje pochłonięty przez palący gniew kosmosu. \
							Przez chwilę widzisz, jak jego sylwetka miota się w agonii, po czym rozpada się na atomy."),
						span_boldbig(span_hypnophrase("MOC SAMEGO KOSMOSU ZALEWA TWOJE CIAŁO. \
							FALE ŻARU WCZEPIAJĄ SIĘ W CIEBIE I ROZRYWAJĄ CIĘ W SZWACH. \
							CAŁKOWITA ZAGŁADA TRWA TYLKO CHWILĘ, NIM ZNÓW STAJESZ SIĘ TYM, CZYM ZAWSZE BYŁEŚ. \
							DROBINAMI PYŁU..."))
						)
					living_victim.dust()
					continue
				living_victim.emote("scream")
				living_victim.apply_status_effect(/datum/status_effect/star_mark)
				living_victim.apply_damage(30, BURN)
	cycle_tracker++
	damage_timer = addtimer(CALLBACK(src, PROC_REF(process_beam)), 0.3 SECONDS, TIMER_STOPPABLE)

/// Stops the beam after we cancel it
/datum/action/cooldown/spell/stargazer_laser/proc/stop_beaming()
	SIGNAL_HANDLER
	sound_loop?.stop()
	if(owner)
		UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_ATOM_DIR_CHANGE))
	QDEL_NULL(orb_visual)
	QDEL_NULL(beam_visual)
	QDEL_NULL(end_visual)
	QDEL_LIST(beam_fillings)
	deltimer(damage_timer)
	damage_timer = null
	targets = null
