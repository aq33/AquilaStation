// AQUILA - Portal kultu: ogłoszenie udaje zwykłą anomalię, a w obszarze otwiera się portal Nar'Sie, przez który 2-3 duchy wchodzą na okręt jako konstrukty kultu (port z TauCetiClassic code/modules/events/cult_portals.dm + /obj/effect/anomaly/bluespace/cult_portal z code/game/objects/effects/anomalies.dm)
// Like TauCeti: the announcement is a random announcement of another anomaly (here one of the E3 anomalies), it comes
// a few seconds after the portal opens, ghosts are polled for 2-3 constructs and the remaining shells can be taken by
// clicking the portal as a ghost (30 s apart); the portal closes when the event ends. Differences: our construct types
// (wraith, juggernaut, proteon, artificer; no harvester, behemoth or Halloween ones), no pylons around the portal and no
// leash to it (we have no bounded component). The poll and the click on the portal check the same things: the ghost
// role switch, the cultist ban, the blood cultist preference and the cultist living hours (the poll also honours the
// cult ghost poll ignore).
// Constructs join an existing blood cult when its construct limit allows; otherwise (no cult, a full cult or a failed
// cult datum) they get a small antagonist datum of their own instead of TauCeti's cult religion. The portal is still an
// anomaly, so the signaller and the anomaly neutraliser close it (it leaves no core). TauCeti's "massive" 50 portal
// variant is not ported. TauCeti's 20 minute earliest start is not here: events rolled by a hex tile skip it on purpose.

/datum/round_event_control/aquila_hex_cult_portal
	name = "Portal kultu"
	typepath = /datum/round_event/aquila_hex_anomaly/cult_portal
	weight = 5
	min_players = 15
	max_occurrences = 1

// Typ eventu nie dziedziczy po /datum/round_event/ghost_role, więc bazowa kontrola nie widzi przełącznika ról duchów
/datum/round_event_control/aquila_hex_cult_portal/canSpawnEvent(players_amt, gamemode)
	. = ..()
	if(. && !(GLOB.ghost_role_flags & GHOSTROLE_MIDROUND_EVENT))
		return FALSE

/datum/round_event/aquila_hex_anomaly/cult_portal
	fakeable = FALSE
	anomaly_path = /obj/effect/anomaly/aquila_hex_cult_portal
	/// Ilu konstruktów może wpuścić portal
	var/max_constructs = 2

/datum/round_event/aquila_hex_anomaly/cult_portal/setup()
	..()
	startWhen = rand(20, 60)
	announceWhen = startWhen + 3
	endWhen = startWhen + 150
	max_constructs = rand(2, 3)
	announce_kind = pick(aquila_hex_anomaly_kinds()) // udaje inną anomalię

/datum/round_event/aquila_hex_anomaly/cult_portal/spawn_anomaly(turf/spawn_turf)
	var/obj/effect/anomaly/aquila_hex_cult_portal/portal = new anomaly_path(spawn_turf)
	portal.spawns_left = max_constructs
	INVOKE_ASYNC(portal, TYPE_PROC_REF(/obj/effect/anomaly/aquila_hex_cult_portal, poll_ghosts))
	message_admins("Portal kultu otwiera się w [ADMIN_VERBOSEJMP(spawn_turf)] i wpuści [max_constructs] konstruktów.")
	return portal

/datum/round_event/aquila_hex_anomaly/cult_portal/end()
	var/obj/effect/anomaly/aquila_hex_cult_portal/portal = anomaly_ref?.resolve()
	if(!QDELETED(portal))
		portal.disable()

/obj/effect/anomaly/aquila_hex_cult_portal
	name = "przerażający portal"
	desc = "Nikt nie wie, co ani kto otworzyło ten portal. Może najbardziej rozwinięta rasa w galaktyce, a może potwór z jej głębin."
	icon = 'aquila/icons/bloodcult/cult.dmi'
	icon_state = "hole"
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	layer = ABOVE_MOB_LAYER
	lifespan = 5 MINUTES
	/// Ile konstruktów jeszcze wejdzie
	var/spawns_left = 2
	/// Portal przyjmuje jeszcze duchy
	var/enabled = TRUE
	COOLDOWN_DECLARE(ghost_spawn_cooldown)
	/// Czas między konstruktami wziętymi kliknięciem ducha
	var/ghost_spawn_delay = 30 SECONDS

// Bez ..(): portal stoi w miejscu
/obj/effect/anomaly/aquila_hex_cult_portal/anomalyEffect(delta_time)
	return

/obj/effect/anomaly/aquila_hex_cult_portal/examine(mob/user)
	. = ..()
	if(enabled && (isobserver(user) || iscultist(user)))
		. += "<span class='cult'>Powłok dla przyszłych sług zostało: [spawns_left].</span>"

/// Czy duch może wejść przez portal: przełącznik ról duchów, ban na kult, preferencja kultysty krwi i godziny gry
/proc/aquila_hex_cult_portal_can_join(mob/dead/observer/ghost, feedback = FALSE)
	var/datum/antagonist/cult/cult_datum = /datum/antagonist/cult
	var/client/player = ghost && GET_CLIENT(ghost)
	if(!player)
		return FALSE
	if(!(GLOB.ghost_role_flags & GHOSTROLE_MIDROUND_EVENT) || !player.should_include_for_role(
		banning_key = ROLE_CULTIST,
		role_preference_key = /datum/role_preference/antagonist/blood_cultist,
		req_hours = initial(cult_datum.required_living_playtime),
	))
		if(feedback)
			to_chat(ghost, "<span class='warning'>Nie możesz teraz wejść przez portal.</span>")
		return FALSE
	return TRUE

/// Pyta duchy i wpuszcza wybranych jako konstrukty (śpi na czas ankiety)
/obj/effect/anomaly/aquila_hex_cult_portal/proc/poll_ghosts()
	var/datum/antagonist/cult/cult_datum = /datum/antagonist/cult
	var/datum/poll_config/config = new()
	config.question = "Czy chcesz zagrać jako konstrukt kultu, który wychodzi z portalu Nar'Sie na okręt?"
	config.check_jobban = ROLE_CULTIST
	config.role = /datum/role_preference/antagonist/blood_cultist
	config.ignore_category = POLL_IGNORE_CULT_SHADE
	config.req_hours = initial(cult_datum.required_living_playtime)
	config.poll_time = 20 SECONDS
	config.role_name_text = "konstrukt z portalu kultu"
	config.alert_pic = src
	config.jump_target = src
	config.amount_to_pick = spawns_left
	var/result = SSpolling.poll_ghost_candidates(config)
	var/list/chosen = islist(result) ? result : (result ? list(result) : list())
	for(var/mob/dead/observer/ghost in chosen)
		if(QDELETED(src) || !enabled || spawns_left <= 0)
			return
		create_construct(ghost)
	if(!QDELETED(src) && enabled && spawns_left > 0)
		notify_ghosts("Portal kultu ma jeszcze wolne powłoki konstruktów. Kliknij go, żeby wejść na okręt jako konstrukt.", source = src, action = NOTIFY_ORBIT, header = "Portal kultu")

/obj/effect/anomaly/aquila_hex_cult_portal/attack_ghost(mob/dead/observer/user)
	if(!enabled || spawns_left <= 0)
		return ..()
	if(!aquila_hex_cult_portal_can_join(user, TRUE))
		return TRUE
	if(!COOLDOWN_FINISHED(src, ghost_spawn_cooldown))
		to_chat(user, "<span class='warning'>Nar'Sie stworzy nową powłokę za [DisplayTimeText(COOLDOWN_TIMELEFT(src, ghost_spawn_cooldown))].</span>")
		return TRUE
	if(tgui_alert(user, "Wejść przez portal jako konstrukt kultu?", "Portal kultu", list("Tak", "Nie")) != "Tak")
		return TRUE
	if(QDELETED(src) || !enabled || spawns_left <= 0 || !COOLDOWN_FINISHED(src, ghost_spawn_cooldown) || !aquila_hex_cult_portal_can_join(user))
		return TRUE
	COOLDOWN_START(src, ghost_spawn_cooldown, ghost_spawn_delay)
	create_construct(user)
	return TRUE

/// Tworzy konstrukt z duchem gracza przy portalu. Zwraca konstrukt.
/obj/effect/anomaly/aquila_hex_cult_portal/proc/create_construct(mob/dead/observer/ghost)
	var/static/list/construct_weights = list(
		/mob/living/simple_animal/hostile/construct/wraith = 50,
		/mob/living/simple_animal/hostile/construct/armored = 50,
		/mob/living/simple_animal/hostile/construct/proteon = 40,
		/mob/living/simple_animal/hostile/construct/builder = 30,
	)
	var/turf/portal_turf = get_turf(src)
	if(!ghost?.client || !portal_turf || spawns_left <= 0)
		return null
	spawns_left--
	var/construct_type = pickweight(construct_weights)
	var/mob/living/simple_animal/hostile/construct/construct = new construct_type(portal_turf)
	new /obj/effect/temp_visual/cult/sparks(portal_turf)
	construct.key = ghost.key
	give_antagonist(construct)
	for(var/i in 1 to rand(1, 3))
		step(construct, pick(GLOB.alldirs))
	message_admins("[ADMIN_LOOKUPFLW(construct)] wchodzi na okręt przez portal kultu.")
	log_game("[key_name(construct)] came through a cult portal as [construct_type] at [AREACOORD(portal_turf)].")
	if(spawns_left <= 0)
		disable()
	return construct

/// Konstrukt dołącza do kultu krwi, jeśli ten jest i ma miejsce, a inaczej dostaje własnego antagonistę. Zwraca datum.
/obj/effect/anomaly/aquila_hex_cult_portal/proc/give_antagonist(mob/living/simple_animal/hostile/construct/construct)
	if(!construct?.mind)
		return null
	var/datum/team/cult/cult_team = locate_team(/datum/team/cult)
	if(cult_team?.CanConvert(construct.construct_type))
		var/datum/antagonist/cult/cultist = construct.mind.add_antag_datum(/datum/antagonist/cult)
		if(cultist)
			return cultist
	var/datum/antagonist/aquila_hex_portal_construct/loner = new()
	loner.cult_full = !!cult_team
	return construct.mind.add_antag_datum(loner)

/// Zamyka portal dla duchów
/obj/effect/anomaly/aquila_hex_cult_portal/proc/disable()
	if(!enabled)
		return
	enabled = FALSE
	icon_state = "hole-old"
	visible_message("<span class='cult'>[src] przygasa i przestaje pulsować.</span>")

/// Konstrukt, który wyszedł z portalu kultu, a na okręcie nie było kultu albo kult nie miał dla niego miejsca
/datum/antagonist/aquila_hex_portal_construct
	name = "Konstrukt z portalu kultu"
	roundend_category = "konstrukty z portalu kultu"
	antagpanel_category = "Cult"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	/// Kult krwi jest na okręcie, ale nie ma już miejsca na tego konstrukta
	var/cult_full = FALSE

/datum/antagonist/aquila_hex_portal_construct/on_gain()
	var/datum/objective/chaos = new
	chaos.owner = owner
	chaos.explanation_text = "Służ Nar'Sie: siej strach i zniszczenie na okręcie Nanotrasen, który znalazł się zbyt blisko gwiazdy."
	chaos.completed = TRUE
	objectives += chaos
	return ..()

/datum/antagonist/aquila_hex_portal_construct/greet()
	to_chat(owner.current, "<span class='cult big'>Wychodzisz przez portal Nar'Sie na okręt Nanotrasen.</span>")
	if(cult_full)
		to_chat(owner.current, "<span class='cult'>Kult na pokładzie nie ma już miejsca dla kolejnego sługi. Działasz sam: siej strach i zniszczenie w imię Nar'Sie, ale nie atakuj kultystów.</span>")
	else
		to_chat(owner.current, "<span class='cult'>Na pokładzie nie ma kultu, któremu mógłbyś służyć. Jesteś sam: siej strach i zniszczenie w imię Nar'Sie.</span>")
	owner.announce_objectives()
