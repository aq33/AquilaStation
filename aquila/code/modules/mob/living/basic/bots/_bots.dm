/*
 * Basic boty: port bazy /mob/living/basic/bot z tgstation (code/modules/mob/living/basic/bots/_bots.dm, tgstation/tgstation@5ee81d6)
 * na nasze API (attackby, canUseTopic, /obj/item/paicard, okno SimpleBot). Myślą drzewem zachowań
 * (aquila/code/datums/ai/behavior_tree/, bot.bt.json).
 *
 * Różnice względem tg:
 * - wspólny schemat pracy zamiast osobnego drzewa każdego bota: bot podaje is_valid_work_target() i work_on_target(),
 *   a drzewo (bot_work.bt.json) szuka celu, idzie do niego i pracuje; boty z innym rytmem (MULE) mają własne drzewo;
 * - opętanie przez ducha bez komponentu ghost_direct_control (nie mamy go): przełącznik „Osobowość” w panelu
 *   pozwala duchom przejąć bota kliknięciem (attack_ghost), z banem na ROLE_SENTIENCE;
 * - osobna lista GLOB.basic_bots_list (MULEbot na starej bazie zostaje w GLOB.bots_list), konsola SI i PDA widzą obie
 *   (aquila/code/modules/mob/living/basic/bots/bot_control.dm);
 * - bez PA-systemu z głosami tg: speak() mówi i opcjonalnie gra dźwięk bota.
 */

GLOBAL_LIST_EMPTY(basic_bots_list)

/// Ile czasu bot ze świadomością gracza trzyma dostęp z wezwania
#define SENTIENT_BOT_RESET_TIMER (45 SECONDS)

/mob/living/basic/bot
	icon = 'icons/mob/aibots.dmi'
	layer = MOB_LAYER
	gender = NEUTER
	mob_biotypes = list(MOB_ROBOTIC)
	basic_mob_flags = DEL_ON_DEATH
	density = FALSE
	maxHealth = 25
	health = 25
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	unsuitable_cold_damage = 0
	unsuitable_heat_damage = 0
	maximum_survivable_temperature = INFINITY
	minimum_survivable_temperature = 0
	healable = FALSE
	sentience_type = SENTIENCE_ARTIFICIAL
	status_flags = NONE
	ai_controller = /datum/ai_controller/basic_controller/bot
	pass_flags = PASSMOB
	verb_say = "stwierdza"
	verb_ask = "pyta"
	verb_exclaim = "oznajmia"
	verb_yell = "alarmuje"
	initial_language_holder = /datum/language_holder/synthetic
	bubble_icon = "machine"
	speech_span = SPAN_ROBOT
	faction = list("neutral", "silicon", "turret")
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_power = 0.6
	speed = 3
	discovery_points = 0
	response_help_continuous = "klepie"
	response_disarm_continuous = "popycha"
	response_harm_continuous = "kopie"
	attack_verb_continuous = "uderza"
	hud_possible = list(DIAG_STAT_HUD, DIAG_BOT_HUD, DIAG_HUD, DIAG_PATH_HUD = HUD_LIST_LIST)

	/// Ramię robota, które wypada przy zniszczeniu (50%)
	var/robot_arm = /obj/item/bodypart/r_arm/robot
	/// Włożona karta pAI
	var/obj/item/paicard/paicard
	/// Rodzaj bota do sterowania z PDA
	var/bot_type = NONE
	/// Nazwa modelu w konsolach
	var/model = "Bot"
	/// Dostęp z budowy
	var/list/initial_access = list()
	/// Flagi trybu, zmieniaj tylko przez set_mode_flags()
	var/bot_mode_flags = BOT_MODE_ON | BOT_MODE_REMOTE_ENABLED | BOT_MODE_CAN_BE_SAPIENT
	/// Flagi obudowy (panel, blokada, emag)
	var/bot_access_flags = BOT_COVER_LOCKED
	/// Co się przepala przy hakowaniu (do komunikatów)
	var/hackables = "obwody systemowe"
	/// Bieżący stan, tekst
	var/mode = BBOT_IDLE
	/// SI, która wezwała bota
	var/datum/weakref/calling_ai_ref
	/// Radio bota
	var/obj/item/radio/internal_radio
	/// Klucz szyfrujący radia
	var/radio_key = null
	/// Domyślny kanał radia
	var/radio_channel = RADIO_CHANNEL_COMMON
	/// Dodatkowy dostęp z pracy
	var/list/additional_access = list()
	/// Duchy mogą przejąć bota (przełącznik „Osobowość”)
	var/can_be_possessed = FALSE
	/// Tekst dla gracza po przejęciu bota
	var/possessed_message = "Jesteś botem. Słuchaj załogi i wykonuj swoją pracę."
	/// Tekst dla gracza w zhakowanym bocie
	var/emagged_message = "Jesteś zepsutym botem! Sprawiaj kłopoty i siej chaos!"
	/// Okno panelu
	var/bot_ui = "SimpleBot"
	/// Frakcja przed pAI
	var/list/original_faction
	/// Nazwa przed pAI
	var/pre_pai_name
	/// Mapy: bot zaczyna z włączonym patrolem / wyłączony / zhakowany (dawne auto_patrol, on, emagged)
	var/start_patrolling = null
	var/start_off = FALSE
	var/start_emagged = FALSE
	/// Następne ogłoszenie duchom o osobowości
	COOLDOWN_DECLARE(offer_ghosts_cooldown)

	// Schemat pracy (bot_work.bt.json)
	/// Zasięg szukania celu
	var/work_scan_range = 7
	/// Szukaj wśród kafelków zamiast obiektów w zasięgu wzroku
	var/work_scan_turfs = FALSE
	/// Typy celów (typecache po Initialize); null = sprawdzaj wszystko is_valid_work_target()
	var/list/work_target_types
	/// Z jakiej odległości bot pracuje (0 = na kafelku celu)
	var/work_reach = 1
	/// Stan pokazywany w czasie pracy
	var/work_mode = BBOT_WORKING
	/// Co ile bot ponawia pracę, gdy zwraca BOT_WORK_CONTINUE
	var/work_interval = 1 SECONDS
	/// Jak długo cel, do którego nie da się dojść, jest ignorowany
	var/unreachable_cooldown = 45 SECONDS
	/// Teksty, które bot czasem mówi bez celu
	var/list/idle_phrases
	/// Dźwięki do teksów (tekst = dźwięk)
	var/list/phrase_sounds

/mob/living/basic/bot/Initialize(mapload)
	if(!isnull(start_patrolling))
		bot_mode_flags = start_patrolling ? (bot_mode_flags | BOT_MODE_AUTOPATROL) : (bot_mode_flags & ~BOT_MODE_AUTOPATROL)
	if(start_off)
		bot_mode_flags &= ~BOT_MODE_ON
	. = ..()
	GLOB.basic_bots_list += src
	if(length(work_target_types))
		work_target_types = typecacheof(work_target_types)
	access_card = new /obj/item/card/id(src)
	access_card.access = list(ACCESS_ROBOTICS) + additional_access
	initial_access = access_card.access.Copy()

	internal_radio = new /obj/item/radio(src)
	if(radio_key)
		internal_radio.keyslot = new radio_key
	internal_radio.subspace_transmission = TRUE
	internal_radio.canhear_range = 0
	internal_radio.recalculateChannels()

	prepare_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)
	diag_hud_set_bothealth()
	diag_hud_set_botstat()
	diag_hud_set_botmode()
	var/datum/atom_hud/datahud = GLOB.huds[DATA_HUD_DIAGNOSTIC_BASIC]
	datahud?.add_hud_to(src)

	ai_controller?.set_blackboard_key(BB_UNREACHABLE_LIST_COOLDOWN, unreachable_cooldown)
	set_light_on(bot_mode_flags & BOT_MODE_ON)
	update_mobility()
	update_appearance()
	if(start_emagged)
		bot_access_flags |= BOT_COVER_EMAGGED | BOT_COVER_LOCKED
		set_mode_flags(bot_mode_flags & ~BOT_MODE_REMOTE_ENABLED)
		INVOKE_ASYNC(src, PROC_REF(emag_effects), null)

/mob/living/basic/bot/Destroy()
	GLOB.basic_bots_list -= src
	calling_ai_ref = null
	if(paicard)
		ejectpai()
	QDEL_NULL(internal_radio)
	return ..()

/mob/living/basic/bot/proc/set_mode_flags(mode_flags)
	SHOULD_CALL_PARENT(TRUE)
	bot_mode_flags = mode_flags
	SEND_SIGNAL(src, COMSIG_BOT_MODE_FLAGS_SET, mode_flags)

/// Stan do PDA i konsoli SI, czysty tekst
/mob/living/basic/bot/proc/get_mode_ui()
	if(client)
		return paicard ? "Sterowany przez pAI" : "Autonomiczny"
	if(!(bot_mode_flags & BOT_MODE_ON))
		return "Nieaktywny"
	return mode

/mob/living/basic/bot/proc/get_mode()
	if(client)
		return span_bold(get_mode_ui())
	if(!(bot_mode_flags & BOT_MODE_ON))
		return span_bad("Nieaktywny")
	return span_average(mode)

/// Czy bot jest włączony (dla kodu core, który nie widzi define'ów BOT_MODE_*)
/mob/living/basic/bot/proc/is_bot_on()
	return !!(bot_mode_flags & BOT_MODE_ON)

/mob/living/basic/bot/proc/is_emagged()
	return !!(bot_access_flags & BOT_COVER_EMAGGED)

/mob/living/basic/bot/proc/turn_on()
	if(stat == DEAD)
		return FALSE
	set_mode_flags(bot_mode_flags | BOT_MODE_ON)
	update_mobility()
	set_light_on(TRUE)
	update_appearance()
	diag_hud_set_botstat()
	return TRUE

/mob/living/basic/bot/proc/turn_off()
	set_mode_flags(bot_mode_flags & ~BOT_MODE_ON)
	update_mobility()
	set_light_on(FALSE)
	bot_reset()
	update_appearance()
	diag_hud_set_botstat()

/mob/living/basic/bot/update_mobility()
	. = ..()
	if(!(bot_mode_flags & BOT_MODE_ON))
		mobility_flags = NONE

/mob/living/basic/bot/update_icon_state()
	icon_state = "[isnull(base_icon_state) ? initial(icon_state) : base_icon_state][bot_mode_flags & BOT_MODE_ON]"
	return ..()

/mob/living/basic/bot/bee_friendly()
	return TRUE

/mob/living/basic/bot/death(gibbed)
	if(paicard)
		ejectpai()
	explode()
	return ..()

/mob/living/basic/bot/proc/explode()
	visible_message(span_boldnotice("[src] rozpada się na kawałki!"))
	do_sparks(3, TRUE, src)
	var/atom/location_destroyed = drop_location()
	if(prob(50) && robot_arm)
		drop_part(robot_arm, location_destroyed)

/mob/living/basic/bot/proc/drop_part(obj/item/drop_item, dropzone)
	var/obj/item/dropped_item
	if(ispath(drop_item))
		dropped_item = new drop_item(dropzone)
	else
		dropped_item = drop_item
		dropped_item.forceMove(dropzone)
	if(istype(dropped_item, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/dropped_cell = dropped_item
		dropped_cell.charge = 0
		dropped_cell.update_icon()
	else if(istype(dropped_item, /obj/item/gun/energy))
		var/obj/item/gun/energy/dropped_gun = dropped_item
		dropped_gun.cell?.charge = 0
		dropped_gun.update_icon()
	return dropped_item

/mob/living/basic/bot/proc/allowed(mob/living/user)
	if(!(bot_access_flags & BOT_COVER_LOCKED))
		return TRUE
	if(issilicon(user) || IsAdminGhost(user))
		return TRUE
	return check_access(user.get_idcard(TRUE))

/mob/living/basic/bot/emag_act(mob/user)
	if(bot_access_flags & BOT_COVER_LOCKED)
		bot_access_flags &= ~BOT_COVER_LOCKED
		to_chat(user, span_notice("Omijasz zabezpieczenia sterowania [src]."))
		return TRUE
	if(!(bot_access_flags & BOT_COVER_MAINTS_OPEN))
		to_chat(user, span_warning("Najpierw musisz otworzyć panel serwisowy!"))
		return FALSE
	if(is_emagged())
		return FALSE
	bot_access_flags |= BOT_COVER_EMAGGED | BOT_COVER_LOCKED
	set_mode_flags(bot_mode_flags & ~BOT_MODE_REMOTE_ENABLED)
	bot_reset()
	turn_on()
	to_chat(src, span_userdanger("(#$*#$^^( WYKRYTO NADPISANIE"))
	to_chat(src, span_boldnotice(emagged_message))
	if(user)
		log_combat(user, src, "emagged")
	emag_effects(user)
	return TRUE

/// Zdalna awaria (burza jonowa, rewenant): otwiera panel i zhakowuje bota
/mob/living/basic/bot/proc/remote_malfunction()
	if(is_emagged())
		return
	bot_access_flags &= ~BOT_COVER_LOCKED
	bot_access_flags |= BOT_COVER_MAINTS_OPEN
	emag_act()

/// Efekty zhakowania konkretnego bota
/mob/living/basic/bot/proc/emag_effects(mob/user)
	return

/mob/living/basic/bot/examine(mob/user)
	. = ..()
	if(health < maxHealth)
		. += health > maxHealth * 0.3 ? "Części [src] wyglądają na poluzowane." : span_warning("Części [src] wyglądają na bardzo poluzowane!")
	else
		. += "[src] jest w idealnym stanie."
	. += span_notice("Panel serwisowy jest [bot_access_flags & BOT_COVER_MAINTS_OPEN ? "otwarty" : "zamknięty"]. Otworzysz go <b>śrubokrętem</b>.")
	if(bot_access_flags & BOT_COVER_MAINTS_OPEN)
		. += span_notice("Panel sterowania jest [bot_access_flags & BOT_COVER_LOCKED ? "zablokowany" : "odblokowany"].")
	if(paicard)
		. += span_notice("Ma włożoną kartę pAI. Przy zamkniętym panelu wyjmiesz ją <b>hemostatem</b>.")
	if(can_be_possessed && !key)
		. += span_notice("Czeka na nową osobowość.")

/mob/living/basic/bot/updatehealth()
	. = ..()
	diag_hud_set_bothealth()

/mob/living/basic/bot/med_hud_set_health()
	return

/mob/living/basic/bot/med_hud_set_status()
	return

/mob/living/basic/bot/attack_hand(mob/living/carbon/human/user)
	if(!user.combat_mode)
		ui_interact(user)
		return
	return ..()

/mob/living/basic/bot/attack_ai(mob/user)
	if(!topic_denied(user))
		ui_interact(user)
		return
	to_chat(user, span_warning("Interfejs [src] nie reaguje!"))

/mob/living/basic/bot/attack_robot(mob/user)
	return attack_ai(user)

/mob/living/basic/bot/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, bot_ui, name)
		ui.open()

/mob/living/basic/bot/AltClick(mob/user)
	. = ..()
	if(user.canUseTopic(src, !issilicon(user)))
		unlock_with_id(user)

/mob/living/basic/bot/proc/unlock_with_id(mob/living/user)
	if(is_emagged())
		to_chat(user, span_danger("BŁĄD"))
		return
	if(bot_access_flags & BOT_COVER_MAINTS_OPEN)
		to_chat(user, span_warning("Zamknij panel dostępu przed zablokowaniem."))
		return
	if(!(issilicon(user) || IsAdminGhost(user) || check_access(user.get_idcard(TRUE))))
		to_chat(user, span_warning("Odmowa dostępu."))
		return
	bot_access_flags ^= BOT_COVER_LOCKED
	to_chat(user, span_notice("Sterowanie jest teraz [bot_access_flags & BOT_COVER_LOCKED ? "zablokowane" : "odblokowane"]."))
	return TRUE

/mob/living/basic/bot/proc/check_access(obj/item/card/id/card)
	if(!card)
		return FALSE
	var/list/card_access = card.GetAccess()
	return (ACCESS_ROBOTICS in card_access) || length(req_bot_access() & card_access)

/// Dostępy, które poza robotyką odblokowują panel (np. ochrona dla secbota)
/mob/living/basic/bot/proc/req_bot_access()
	return list()

/mob/living/basic/bot/attackby(obj/item/attacking_item, mob/living/user, params)
	if(attacking_item.tool_behaviour == TOOL_SCREWDRIVER)
		if(bot_access_flags & BOT_COVER_LOCKED)
			to_chat(user, span_warning("Panel serwisowy jest zablokowany!"))
			return TRUE
		attacking_item.play_tool_sound(src)
		bot_access_flags ^= BOT_COVER_MAINTS_OPEN
		to_chat(user, span_notice("Panel serwisowy jest teraz [bot_access_flags & BOT_COVER_MAINTS_OPEN ? "otwarty" : "zamknięty"]."))
		return TRUE
	if(attacking_item.GetID())
		unlock_with_id(user)
		return TRUE
	if(istype(attacking_item, /obj/item/paicard))
		insertpai(user, attacking_item)
		return TRUE
	if(attacking_item.tool_behaviour == TOOL_HEMOSTAT && paicard)
		if(bot_access_flags & BOT_COVER_MAINTS_OPEN)
			to_chat(user, span_warning("Zamknij panel dostępu, zanim zaczniesz grzebać w gnieździe osobowości!"))
			return TRUE
		to_chat(user, span_notice("Próbujesz wyciągnąć [paicard]..."))
		if(do_after(user, 3 SECONDS, target = src) && paicard)
			user.visible_message(span_notice("[user] wyciąga [paicard] z [src] za pomocą [attacking_item]!"), span_notice("Wyciągasz [paicard] z [src] za pomocą [attacking_item]."))
			ejectpai(user)
		return TRUE
	if(attacking_item.tool_behaviour == TOOL_WELDER && !user.combat_mode)
		user.changeNext_move(CLICK_CD_MELEE)
		if(health >= maxHealth)
			to_chat(user, span_warning("[src] nie wymaga naprawy!"))
			return TRUE
		if(!(bot_access_flags & BOT_COVER_MAINTS_OPEN))
			to_chat(user, span_warning("Nie można naprawiać przy zamkniętym panelu serwisowym!"))
			return TRUE
		if(attacking_item.use_tool(src, user, 0, volume = 40))
			adjustBruteLoss(-10)
			adjustFireLoss(-10)
			user.visible_message(span_notice("[user] naprawia [src]!"), span_notice("Naprawiasz [src]."))
		return TRUE
	if(attacking_item.force)
		do_sparks(5, TRUE, src)
	return ..()

/mob/living/basic/bot/bullet_act(obj/item/projectile/hitting_projectile, def_zone, piercing_hit = FALSE)
	if(hitting_projectile && (hitting_projectile.damage_type == BRUTE || hitting_projectile.damage_type == BURN) && hitting_projectile.damage > 0 && prob(75))
		do_sparks(5, TRUE, src)
	return ..()

/mob/living/basic/bot/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	new /obj/effect/temp_visual/emp(loc)
	if(paicard)
		paicard.emp_act(severity)
		visible_message(span_notice("[paicard] wylatuje z [src]!"), span_warning("Zostajesz siłą wyrzucony z [src]!"))
		ejectpai()
	if(QDELETED(src))
		return
	if(bot_mode_flags & BOT_MODE_ON)
		turn_off()
		addtimer(CALLBACK(src, PROC_REF(turn_on)), severity * 30 SECONDS)

/// Bot mówi (i gra dźwięk z phrase_sounds); z kanałem także przez radio
/mob/living/basic/bot/proc/speak(message, channel, sound)
	if(!message || !(bot_mode_flags & BOT_MODE_ON))
		return
	if(channel && internal_radio.channels[channel])
		internal_radio.talk_into(src, message, channel)
	else
		say(message)
	var/sound_to_play = sound || LAZYACCESS(phrase_sounds, message)
	if(sound_to_play)
		playsound(src, sound_to_play, 50, FALSE)

/mob/living/basic/bot/radio(message, list/message_mods = list(), list/spans, language)
	. = ..()
	if(. != 0)
		return
	if(message_mods[MODE_HEADSET])
		internal_radio.talk_into(src, message, , spans, language, message_mods)
		return REDUCE_RANGE
	if(message_mods[RADIO_EXTENSION] == MODE_DEPARTMENT || (message_mods[RADIO_EXTENSION] in GLOB.radiochannels))
		internal_radio.talk_into(src, message, message_mods[RADIO_EXTENSION], spans, language, message_mods)
		return REDUCE_RANGE

/// Powrót do stanu wyjściowego: koniec wezwania, cel pracy porzucony
/mob/living/basic/bot/proc/bot_reset(bypass_ai_reset = FALSE)
	SEND_SIGNAL(src, COMSIG_BOT_RESET)
	access_card.access = initial_access.Copy()
	update_bot_mode(BBOT_IDLE)
	diag_hud_set_botstat()
	if(bypass_ai_reset || isnull(calling_ai_ref))
		return
	var/mob/living/ai_caller = calling_ai_ref.resolve()
	calling_ai_ref = null
	if(ai_caller)
		to_chat(ai_caller, span_danger("Polecenie wezwania bota zostało anulowane."))

/mob/living/basic/bot/proc/update_bot_mode(new_mode, update_hud = TRUE)
	mode = new_mode
	update_appearance()
	if(update_hud)
		diag_hud_set_botmode()

/// Polecenia z PDA i konsoli SI
/mob/living/basic/bot/proc/bot_control(command, mob/user, list/user_access = list())
	if(!(bot_mode_flags & BOT_MODE_ON) || is_emagged() || !(bot_mode_flags & BOT_MODE_REMOTE_ENABLED))
		return TRUE
	if(client && command != "ejectpai")
		to_chat(src, span_notice("Otrzymano polecenie: [bot_control_message(command, user)]"))
	switch(command)
		if("patroloff")
			bot_reset()
			set_mode_flags(bot_mode_flags & ~BOT_MODE_AUTOPATROL)
		if("patrolon")
			set_mode_flags(bot_mode_flags | BOT_MODE_AUTOPATROL)
		if("summon")
			summon_bot(user, user_access = user_access)
		if("ejectpai")
			if(paicard && (issilicon(user) || check_access(user.get_idcard(TRUE))))
				speak("Odłączanie czipu osobowości.", radio_channel)
				ejectpai(user)

/mob/living/basic/bot/proc/bot_control_message(command, mob/user)
	switch(command)
		if("summon")
			return "PILNE: [user] w [get_area_name(user)]!"
		if("patroloff")
			return "KONIEC PATROLU"
		if("patrolon")
			return "POCZĄTEK PATROLU"
		if("stop")
			return "STOP"
		if("go")
			return "NAPRZÓD"
		if("home")
			return "POWRÓT DO BAZY"
	return "Nieznana sekwencja sterująca: [command]"

/// Wezwanie bota na miejsce (PDA albo punkt SI)
/mob/living/basic/bot/proc/summon_bot(atom/summoner, turf/turf_destination, user_access = list(), grant_all_access = FALSE)
	if(isAI(summoner) && !set_ai_caller(summoner))
		return FALSE
	bot_reset(bypass_ai_reset = isAI(summoner))
	var/turf/destination = turf_destination || get_turf(summoner)
	ai_controller?.set_blackboard_key(BB_BOT_SUMMON_TARGET, destination)
	access_card.access = grant_all_access ? get_all_accesses() : (initial_access | user_access)
	speak("Przyjąłem, w drodze.", radio_channel)
	update_bot_mode(BBOT_SUMMON)
	if(client)
		addtimer(CALLBACK(src, PROC_REF(bot_reset)), SENTIENT_BOT_RESET_TIMER)
	return TRUE

/mob/living/basic/bot/proc/set_ai_caller(mob/living/ai_caller)
	var/atom/calling_ai = calling_ai_ref?.resolve()
	if(!isnull(calling_ai) && calling_ai != ai_caller)
		return FALSE
	calling_ai_ref = WEAKREF(ai_caller)
	return TRUE

/mob/living/basic/bot/Bump(atom/bumped)
	. = ..()
	if(istype(bumped, /obj/machinery/door/airlock) || istype(bumped, /obj/machinery/door/window))
		var/obj/machinery/door/door = bumped
		if(door.check_access(access_card))
			door.open()

// --- Okno SimpleBot

/mob/living/basic/bot/ui_data(mob/user)
	var/list/data = list()
	data["can_hack"] = issilicon(user) || IsAdminGhost(user)
	data["emagged"] = is_emagged()
	data["hacked"] = !!(bot_access_flags & BOT_COVER_HACKED)
	data["has_access"] = allowed(user)
	data["locked"] = !!(bot_access_flags & BOT_COVER_LOCKED)
	data["settings"] = list(
		"power" = !!(bot_mode_flags & BOT_MODE_ON),
		"airplane_mode" = !(bot_mode_flags & BOT_MODE_REMOTE_ENABLED),
		"patrol_station" = !!(bot_mode_flags & BOT_MODE_AUTOPATROL),
		"maintenance_open" = !!(bot_access_flags & BOT_COVER_MAINTS_OPEN),
		"allow_possession" = !!(bot_mode_flags & BOT_MODE_CAN_BE_SAPIENT),
		"pai_inserted" = !!paicard,
		"pai_active" = !!(paicard && client),
		"personality" = TRUE,
		"possession_enabled" = can_be_possessed,
	)
	data["custom_controls"] = get_custom_controls(user)
	return data

/mob/living/basic/bot/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	if(topic_denied(user))
		to_chat(user, span_warning("Interfejs [src] nie reaguje!"))
		return TRUE
	add_fingerprint(user)
	var/silicon_access = issilicon(user) || IsAdminGhost(user)
	switch(action)
		if("power")
			if(!allowed(user))
				return TRUE
			if(bot_mode_flags & BOT_MODE_ON)
				turn_off()
			else
				turn_on()
			return TRUE
		if("lock")
			unlock_with_id(user)
			return TRUE
		if("hack")
			if(!silicon_access)
				return TRUE
			if(!is_emagged())
				bot_access_flags |= (BOT_COVER_LOCKED | BOT_COVER_EMAGGED | BOT_COVER_HACKED)
				emag_effects(user)
				to_chat(user, span_warning("Przeciążasz [hackables] [src]."))
				message_admins("[ADMIN_LOOKUPFLW(user)] wyłącza blokadę bezpieczeństwa: [ADMIN_LOOKUPFLW(src)] w [ADMIN_VERBOSEJMP(src)]")
				log_game("Safety lock of [src] was disabled by [key_name(user)] in [AREACOORD(src)]")
				bot_reset()
				to_chat(src, span_userdanger("(#$*#$^^( WYKRYTO NADPISANIE"))
				to_chat(src, span_boldnotice(emagged_message))
			else if(!(bot_access_flags & BOT_COVER_HACKED))
				to_chat(user, span_boldannounce("Nie udaje ci się naprawić: [hackables] [src]."))
			else
				bot_access_flags &= ~(BOT_COVER_EMAGGED | BOT_COVER_HACKED)
				to_chat(user, span_notice("Resetujesz [hackables] [src]."))
				log_game("Safety lock of [src] was re-enabled by [key_name(user)] in [AREACOORD(src)]")
				bot_reset()
				to_chat(src, span_userdanger("Przywrócono standardowe oprogramowanie."))
				to_chat(src, span_boldnotice(possessed_message))
			return TRUE
		if("eject_pai")
			if(paicard && (!(bot_access_flags & BOT_COVER_LOCKED) || silicon_access))
				to_chat(user, span_notice("Wysuwasz [paicard] z [src]."))
				ejectpai(user)
			return TRUE

	if((bot_access_flags & BOT_COVER_LOCKED) && !silicon_access)
		return TRUE

	switch(action)
		if("patrol")
			set_mode_flags(bot_mode_flags ^ BOT_MODE_AUTOPATROL)
			bot_reset()
			return TRUE
		if("airplane")
			set_mode_flags(bot_mode_flags ^ BOT_MODE_REMOTE_ENABLED)
			return TRUE
		if("toggle_personality")
			if(can_be_possessed)
				disable_possession(user)
			else
				enable_possession(user)
			return TRUE
		if("rename")
			INVOKE_ASYNC(src, PROC_REF(rename), user)
			return TRUE
	return bot_custom_act(action, params, user)

/// Ustawienia konkretnego bota do okna SimpleBot: lista nazwa = wartość
/mob/living/basic/bot/proc/get_custom_controls(mob/user)
	return list()

/// Akcje z ustawień konkretnego bota (sterowanie już odblokowane)
/mob/living/basic/bot/proc/bot_custom_act(action, list/params, mob/user)
	return FALSE

/mob/living/basic/bot/proc/topic_denied(mob/user)
	if(!user.canUseTopic(src, !issilicon(user)))
		return TRUE
	if(!is_emagged())
		return FALSE
	if(!(bot_access_flags & BOT_COVER_HACKED))
		return TRUE
	return !(issilicon(user) || IsAdminGhost(user))

/mob/living/basic/bot/proc/rename(mob/user)
	var/new_name = sanitize_name(tgui_input_text(user, "Ta maszyna nazywa się [real_name]. Zmienić jej nazwę?", "Zmiana nazwy", real_name, MAX_NAME_LEN))
	if(!new_name || QDELETED(src) || !user.canUseTopic(src, !issilicon(user)))
		return
	if(key && user != src && tgui_alert(src, "Czy chcesz nazywać się [new_name]?", "Zmiana nazwy", list("Tak", "Nie")) != "Tak")
		return
	fully_replace_character_name(real_name, new_name)

// --- Osobowość: pAI i duchy

/// Duchy mogą przejąć bota kliknięciem
/mob/living/basic/bot/proc/enable_possession(mob/user)
	if(paicard || !(bot_mode_flags & BOT_MODE_CAN_BE_SAPIENT))
		to_chat(user, span_warning("[src] nie przyjmie teraz nowej osobowości."))
		return
	can_be_possessed = TRUE
	if(COOLDOWN_FINISHED(src, offer_ghosts_cooldown))
		COOLDOWN_START(src, offer_ghosts_cooldown, 30 SECONDS)
		notify_ghosts("[src] w [get_area_name(src)] czeka na nową osobowość. Kliknij go, aby go przejąć.", source = src, action = NOTIFY_ORBIT, header = "Osobowość bota")
	if(user)
		log_game("[key_name(user)] enabled sapience for [src] ([initial(name)])")

/mob/living/basic/bot/proc/disable_possession(mob/user)
	if(user)
		log_game("[key_name(user)] disabled sapience for [src] ([initial(name)])")
	can_be_possessed = FALSE
	if(isnull(key) || paicard)
		return
	to_chat(src, span_warning("Czujesz, jak znikasz, gdy matryca osobowości się resetuje!"))
	ghostize(FALSE)
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	speak("Matryca osobowości zresetowana!")
	key = null

/mob/living/basic/bot/attack_ghost(mob/dead/observer/user)
	if(!can_be_possessed || key || paicard || stat == DEAD || !user.client)
		return ..()
	if(is_banned_from(user.ckey, ROLE_SENTIENCE))
		to_chat(user, span_warning("Masz bana na tę rolę."))
		return
	if(tgui_alert(user, "Przejąć [src]?", "Osobowość bota", list("Tak", "Nie")) != "Tak")
		return
	if(!can_be_possessed || key || paicard || QDELETED(src) || QDELETED(user))
		return
	key = user.key
	to_chat(src, span_boldnotice(is_emagged() ? emagged_message : possessed_message))
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	speak("Nowa osobowość zainstalowana!")
	log_game("[key_name(src)] took control of [src] ([initial(name)]) as a ghost")

/mob/living/basic/bot/proc/insertpai(mob/user, obj/item/paicard/card)
	if(paicard)
		to_chat(user, span_warning("[paicard] jest już włożona!"))
		return
	if(key || !(bot_mode_flags & BOT_MODE_CAN_BE_SAPIENT))
		to_chat(user, span_warning("[src] nie jest zgodny z [card]."))
		return
	if((bot_access_flags & BOT_COVER_LOCKED) || (bot_access_flags & BOT_COVER_MAINTS_OPEN))
		to_chat(user, span_warning("Gniazdo osobowości jest zablokowane."))
		return
	if(!card.pai?.mind)
		to_chat(user, span_warning("[card] jest nieaktywna."))
		return
	if(!user.transferItemToLoc(card, src))
		return
	paicard = card
	can_be_possessed = FALSE
	user.visible_message(span_notice("[user] wkłada [card] do [src]!"), span_notice("Wkładasz [card] do [src]."))
	paicard.pai.mind.transfer_to(src)
	to_chat(src, span_notice("Czujesz, jak zmienia się twoja forma, gdy zostajesz wgrany do [src]."))
	pre_pai_name = name
	name = paicard.pai.name
	original_faction = faction.Copy()
	faction = user.faction.Copy()
	copy_languages(paicard.pai)
	log_combat(user, paicard.pai, "uploaded to [initial(name)],")
	return TRUE

/mob/living/basic/bot/proc/ejectpai(mob/user = null, announce = TRUE)
	if(!paicard)
		return
	if(mind && paicard.pai)
		mind.transfer_to(paicard.pai)
	else if(paicard.pai)
		paicard.pai.key = key
	else
		ghostize(FALSE)
	key = null
	paicard.forceMove(drop_location())
	log_combat(user || src, paicard.pai, "ejected from [initial(name)]")
	if(announce && paicard.pai)
		to_chat(paicard.pai, span_notice("Czujesz, jak tracisz kontrolę, gdy [paicard] wysuwa się z [initial(name)]."))
	paicard = null
	name = pre_pai_name || real_name
	if(original_faction)
		faction = original_faction
		original_faction = null

/mob/living/basic/bot/ghost()
	if(stat != DEAD)
		return ..()
	if(paicard && (!client || stat == DEAD))
		ejectpai(announce = FALSE)

/mob/living/basic/bot/Login()
	. = ..()
	diag_hud_set_botmode()

/mob/living/basic/bot/Logout()
	. = ..()
	bot_reset()

/mob/living/basic/bot/revive(full_heal = FALSE, admin_revive = FALSE)
	. = ..()
	if(.)
		update_appearance()

/mob/living/basic/bot/sentience_act()
	faction -= "silicon"

// --- Schemat pracy (wywołuje drzewo bot_work.bt.json)

/// Czy bot może teraz szukać pracy
/mob/living/basic/bot/proc/can_seek_work()
	return (bot_mode_flags & BOT_MODE_ON) && !client

/// Czy to cel do pracy (bez sprawdzania drogi, to robi drzewo)
/mob/living/basic/bot/proc/is_valid_work_target(atom/target)
	return FALSE

/// Kandydaci do pracy, od najbliższych
/mob/living/basic/bot/proc/get_work_candidates()
	var/list/candidates = list()
	var/list/ignore_list = ai_controller?.blackboard[BB_TEMPORARY_IGNORE_LIST]
	var/list/search = work_scan_turfs ? RANGE_TURFS(work_scan_range, src) : oview(work_scan_range, src)
	for(var/atom/potential_target as anything in search)
		if(work_target_types && !is_type_in_typecache(potential_target, work_target_types))
			continue
		if(LAZYACCESS(ignore_list, potential_target))
			continue
		if(!is_valid_work_target(potential_target))
			continue
		candidates[potential_target] = get_dist(src, potential_target)
	sortTim(candidates, GLOBAL_PROC_REF(cmp_numeric_asc), TRUE)
	var/list/sorted = list()
	for(var/atom/candidate as anything in candidates)
		sorted += candidate
	return sorted

/**
 * Praca nad celem, gdy bot stoi w zasięgu work_reach. Może spać (do_after), wołana asynchronicznie.
 * Zwraca BOT_WORK_DONE, BOT_WORK_CONTINUE, BOT_WORK_FAILED albo BOT_WORK_OUT_OF_REACH.
 */
/mob/living/basic/bot/proc/work_on_target(atom/target)
	return BOT_WORK_FAILED

/// Bot znalazł cel (komunikat, dźwięk)
/mob/living/basic/bot/proc/on_work_target_found(atom/target)
	return

/// Pogawędka bez celu (bot_idle_chatter)
/mob/living/basic/bot/proc/idle_chatter()
	if(length(idle_phrases))
		speak(pick(idle_phrases))

#undef SENTIENT_BOT_RESET_TIMER
