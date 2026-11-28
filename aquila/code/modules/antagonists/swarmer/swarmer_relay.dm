// AQUILA - cel końcowy rojowców: przekaźnik sygnału dla Mistrzów.
// Pomysł z Goonstation (Flockmind, „Signal Relay Broadcast Amplifier”: zbudować przekaźnik i bronić go, aż nada Sygnał)
// i z rojowców SS220. Kod napisany od nowa dla naszych rojowców (Bee), bez kodu Goona; sprite przekaźnika z Goona
// (icons/misc/featherzone-160x160.dmi, stany structure-relay, -glow, -sparks), zmniejszony do 3x3 pól,
// licencja CC BY-NC-SA 3.0 (aquila/icons/goonstation/README.md).
// Różnice względem Goona: zamiast mocy obliczeniowej i przejętych pól liczą się zasoby zebrane przez cały rój,
// przekaźnik nie zamienia okrętu w tworzywo, nie wybucha i nie psuje radia; po zniszczeniu rój zbiera zasoby od nowa.

/// Ile zasobów musi zebrać cały rój, zanim któryś rojowiec złoży przekaźnik
#define SWARMER_RELAY_RESOURCES 250
/// Koszt złożenia przekaźnika (pełny magazyn jednego rojowca)
#define SWARMER_RELAY_COST 100
/// Jak długo przekaźnik musi przetrwać, zanim nada sygnał
#define SWARMER_RELAY_CHARGE_TIME (5 MINUTES)
/// Ile trwa składanie przekaźnika
#define SWARMER_RELAY_BUILD_TIME (15 SECONDS)

/obj/effect/mob_spawn/swarmer
	antagonist_type = /datum/antagonist/swarmer

///////////////////
// Rola i rój
///////////////////

/datum/antagonist/swarmer
	name = "Rojowiec"
	roundend_category = "rojowce"
	antagpanel_category = "Swarmer"
	banning_key = BAN_ROLE_ALL_ANTAGONISTS // rola ducha ze skorupy, bez własnej preferencji (jak highlander)
	show_name_in_check_antagonists = TRUE
	show_to_ghosts = TRUE
	// Rola ducha ze zdarzenia: nie trzyma rundy i nie blokuje zmiany trybu
	delay_roundend = FALSE
	prevent_roundtype_conversion = FALSE
	var/datum/team/swarmers/swarm

/datum/antagonist/swarmer/create_team(datum/team/swarmers/new_team)
	if(!istype(new_team))
		new_team = get_swarmer_team(create = TRUE)
	swarm = new_team
	swarm.add_member(owner)
	objectives |= swarm.objectives

/datum/antagonist/swarmer/get_team()
	return swarm

/datum/antagonist/swarmer/greet()
	to_chat(owner, "<span class='boldannounce'>Jesteś rojowcem!</span>")
	to_chat(owner, "<B>Pochłaniaj przedmioty i maszyny, a zasoby trafią do całego roju. Gdy rój zbierze [SWARMER_RELAY_RESOURCES] zasobów, zbuduj przekaźnik (przycisk na pasku, koszt: [SWARMER_RELAY_COST] zasobów) i broń go, aż nada sygnał do naszych Mistrzów. Systemów okrętu nie ruszaj: Mistrzowie chcą go przejąć w całości.</B>")
	owner.announce_objectives()

/// Jedyny rój w rundzie, z create = TRUE tworzy go, gdy go jeszcze nie ma
/proc/get_swarmer_team(create = FALSE)
	for(var/datum/team/swarmers/swarm in GLOB.antagonist_teams)
		return swarm
	if(create)
		return new /datum/team/swarmers

/datum/team/swarmers
	name = "Rój"
	member_name = "rojowiec"
	/// Zasoby zebrane przez cały rój od ostatniego przekaźnika
	var/collected = 0
	/// Wszystkie zasoby zebrane w rundzie (do raportu)
	var/collected_total = 0
	/// Stojący przekaźnik, który jeszcze nie nadał sygnału
	var/obj/structure/swarmer_relay/relay
	var/signal_sent = FALSE
	var/relays_destroyed = 0

/datum/team/swarmers/New(starting_members)
	. = ..()
	var/datum/objective/swarmer_signal/signal = new
	signal.team = src
	signal.update_explanation_text()
	objectives += signal

/datum/team/swarmers/Destroy(force, ...)
	relay = null
	QDEL_LIST(objectives)
	return ..()

/// Zasoby zebrane przez któregoś rojowca
/datum/team/swarmers/proc/add_resources(amount)
	if(amount <= 0 || signal_sent)
		return
	var/was_ready = collected >= SWARMER_RELAY_RESOURCES
	collected += amount
	collected_total += amount
	if(!was_ready && collected >= SWARMER_RELAY_RESOURCES && !relay)
		message_swarm("Rój zebrał dość zasobów. Rojowiec z pełnym magazynem może złożyć przekaźnik.")

/datum/team/swarmers/proc/message_swarm(message)
	for(var/datum/mind/M as anything in members)
		if(M.current)
			to_chat(M.current, "<span class='swarmer'><b>[message]</b></span>")

/// Przekaźnik zniszczony przed nadaniem: zasoby trzeba zebrać od nowa
/datum/team/swarmers/proc/relay_lost()
	relay = null
	relays_destroyed++
	collected = 0
	message_swarm("Przekaźnik zniszczony! Musimy zebrać zasoby od nowa i złożyć kolejny.")

/datum/team/swarmers/roundend_report()
	var/list/parts = list()
	parts += "<span class='header'>Rój rojowców:</span>"
	parts += printplayerlist(members)
	parts += "Zasoby zebrane przez rój: [collected_total]"
	if(relays_destroyed)
		parts += "Zniszczone przekaźniki: [relays_destroyed]"
	if(signal_sent)
		parts += "<span class='greentext big'>Rojowce nadały sygnał do swoich Mistrzów!</span>"
	else
		parts += "<span class='redtext big'>Rojowce nie nadały sygnału.</span>"
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"

/datum/objective/swarmer_signal
	explanation_text = "Zbudujcie przekaźnik i brońcie go, aż nada sygnał do naszych Mistrzów."

/datum/objective/swarmer_signal/update_explanation_text()
	explanation_text = "Zbierzcie [SWARMER_RELAY_RESOURCES] zasobów, zbudujcie przekaźnik i brońcie go, aż nada sygnał do naszych Mistrzów."

/datum/objective/swarmer_signal/check_completion()
	var/datum/team/swarmers/swarm = team
	return istype(swarm) && swarm.signal_sent

///////////////////
// Rojowiec: zasoby roju i składanie przekaźnika
///////////////////

/// Rój tego rojowca. Z create = TRUE rojowiec z umysłem bez roli (np. wcielony przez admina) dostaje rolę rojowca
/mob/living/simple_animal/hostile/swarmer/proc/swarm_team(create = FALSE)
	if(!mind)
		return
	var/datum/antagonist/swarmer/role = mind.has_antag_datum(/datum/antagonist/swarmer)
	if(!role && create)
		role = mind.add_antag_datum(/datum/antagonist/swarmer)
	return role?.swarm

/mob/living/simple_animal/hostile/swarmer/Integrate(atom/movable/target)
	var/before = resources
	// Skorupy rojowców nie liczą się do roju, inaczej powielanie i zjadanie skorupy nabijałoby zasoby za darmo
	var/counts = !istype(target, /obj/effect/mob_spawn/swarmer) && !istype(target, /obj/item/deactivated_swarmer)
	. = ..()
	if(counts && resources > before)
		var/datum/team/swarmers/swarm = swarm_team(create = TRUE)
		swarm?.add_resources(resources - before)

/mob/living/simple_animal/hostile/swarmer/get_stat_tab_status()
	. = ..()
	var/datum/team/swarmers/swarm = swarm_team()
	if(!swarm)
		return
	if(swarm.signal_sent)
		.["Przekaźnik"] = GENERATE_STAT_TEXT("sygnał nadany")
	else if(swarm.relay)
		.["Przekaźnik"] = GENERATE_STAT_TEXT("nadaje za [round(swarm.relay.time_left() / (1 SECONDS))] s")
	else
		.["Zasoby roju"] = GENERATE_STAT_TEXT("[min(swarm.collected, SWARMER_RELAY_RESOURCES)]/[SWARMER_RELAY_RESOURCES]")

/// Dlaczego nie da się tu teraz złożyć przekaźnika, albo null, gdy się da
/mob/living/simple_animal/hostile/swarmer/proc/relay_build_problem(datum/team/swarmers/swarm)
	if(!swarm)
		return "Nie należymy do żadnego roju."
	if(swarm.signal_sent)
		return "Sygnał już nadano. Nasi Mistrzowie wiedzą o tym okręcie."
	if(swarm.relay)
		return "Rój ma już przekaźnik. Musimy go bronić."
	if(swarm.collected < SWARMER_RELAY_RESOURCES)
		return "Rój zebrał dopiero [swarm.collected] z [SWARMER_RELAY_RESOURCES] zasobów potrzebnych do przekaźnika."
	if(resources < SWARMER_RELAY_COST)
		return "Do złożenia przekaźnika potrzebujemy [SWARMER_RELAY_COST] własnych zasobów."
	var/turf/here = loc
	if(!isturf(here) || !is_station_level(here.z))
		return "Przekaźnik musi stanąć na pokładzie okrętu."
	for(var/turf/T as anything in RANGE_TURFS(1, here))
		if(isclosedturf(T) || isgroundlessturf(T))
			return "Przekaźnik potrzebuje więcej przestrzeni: wokół nas nie może być ścian ani próżni."
	if(is_blocked_turf(here, TRUE))
		return "Coś stoi nam na drodze. Potrzebujemy wolnego miejsca."

/mob/living/simple_animal/hostile/swarmer/proc/CreateRelay()
	var/datum/team/swarmers/swarm = swarm_team(create = TRUE)
	var/problem = relay_build_problem(swarm)
	if(problem)
		to_chat(src, "<span class='warning'>[problem]</span>")
		return
	to_chat(src, "<span class='info'>Zaczynamy składać przekaźnik. Musimy stać w miejscu do końca procesu.</span>")
	if(!do_mob(src, src, SWARMER_RELAY_BUILD_TIME))
		return
	problem = relay_build_problem(swarm)
	if(problem)
		to_chat(src, "<span class='warning'>[problem]</span>")
		return
	build_relay(swarm)

/// Składa przekaźnik na swoim polu (już po sprawdzeniu miejsca i zasobów)
/mob/living/simple_animal/hostile/swarmer/proc/build_relay(datum/team/swarmers/swarm)
	var/obj/structure/swarmer_relay/relay = Fabricate(/obj/structure/swarmer_relay, SWARMER_RELAY_COST)
	if(!relay)
		return
	playsound(loc, 'sound/items/poster_being_created.ogg', 50, TRUE, -1)
	relay.start_charging(swarm)
	return relay

/atom/movable/screen/swarmer/BuildRelay
	icon = 'aquila/icons/goonstation/swarmer_relay_ui.dmi'
	icon_state = "ui_relay"
	name = "Zbuduj przekaźnik (koszt: 100 zasobów)"
	desc = "Gdy rój zbierze dość zasobów, składa przekaźnik, który po kilku minutach nada sygnał do naszych Mistrzów."

/atom/movable/screen/swarmer/BuildRelay/Click()
	if(isswarmer(usr))
		var/mob/living/simple_animal/hostile/swarmer/S = usr
		S.CreateRelay()

/datum/hud/swarmer/New(mob/owner)
	. = ..()
	var/atom/movable/screen/swarmer/BuildRelay/relay_button = new
	relay_button.screen_loc = ui_belt
	relay_button.hud = src
	static_inventory += relay_button

///////////////////
// Przekaźnik
///////////////////

/obj/structure/swarmer_relay
	name = "przekaźnik roju"
	desc = "Olbrzymi wielościan z błękitnego kryształu, z którego dobiega szept tysięcy głosów. Rojowce bronią go zawzięcie."
	icon = 'aquila/icons/goonstation/swarmer_relay.dmi'
	icon_state = "relay"
	pixel_x = -32
	pixel_y = -32
	layer = ABOVE_ALL_MOB_LAYER
	density = TRUE
	anchored = TRUE
	max_integrity = 500
	armor = list("melee" = 20, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 50, "acid" = 50, "stamina" = 0, "bleed" = 0)
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	light_range = 4
	light_power = 1
	light_color = LIGHT_COLOR_CYAN
	var/datum/team/swarmers/swarm
	/// Kiedy przekaźnik nada sygnał
	var/charge_end = 0
	var/halfway_announced = FALSE
	var/finished = FALSE

/obj/structure/swarmer_relay/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(swarm)
		if(!finished)
			swarm.relay_lost()
			if(SSticker.current_state == GAME_STATE_PLAYING)
				priority_announce("Źródło anomalnego sygnału zostało zniszczone. Nadawanie przerwane.", "Anomalia zneutralizowana")
		else if(swarm.relay == src)
			swarm.relay = null
		swarm = null
	return ..()

/// Przekaźnik zaczyna się ładować: ogłoszenie dla załogi, sygnał GPS i odliczanie
/obj/structure/swarmer_relay/proc/start_charging(datum/team/swarmers/new_swarm)
	swarm = new_swarm
	if(swarm)
		swarm.relay = src
	charge_end = world.time + SWARMER_RELAY_CHARGE_TIME
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/gps, "Sygnał roju")
	var/area/A = get_area(src)
	swarm?.message_swarm("Przekaźnik stoi w okolicy: [A?.name]. Brońcie go, aż nada sygnał!")
	priority_announce("Na pokładzie wykryto przytłaczającą anomalną sygnaturę energetyczną. Jej źródło jest w okolicy: [A?.name]. Nieznane maszyny złożyły nadajnik, który za kilka minut wyśle sygnał w głęboki kosmos. Zniszczcie go, zanim to nastąpi!", "Wykryto anomalię")
	notify_ghosts("Rojowce złożyły przekaźnik w okolicy: [A?.name].", source = src, action = NOTIFY_ORBIT, header = "Przekaźnik roju")
	playsound(src, 'sound/effects/empulse.ogg', 80, TRUE)
	message_admins("Rojowce złożyły przekaźnik w [ADMIN_VERBOSEJMP(src)].")
	log_game("Swarmers built a signal relay at [AREACOORD(src)].")

/obj/structure/swarmer_relay/proc/time_left()
	return max(0, charge_end - world.time)

/obj/structure/swarmer_relay/process(delta_time)
	if(finished || !charge_end)
		return PROCESS_KILL
	if(!halfway_announced && time_left() <= SWARMER_RELAY_CHARGE_TIME / 2)
		halfway_announced = TRUE
		icon_state = "relay-glow"
		priority_announce("Sygnał z pokładu okrętu jest coraz silniejszy. Do jego nadania zostało około [round(time_left() / (1 MINUTES))] min.", "Wykryto anomalię")
	if(!time_left())
		broadcast()
		return PROCESS_KILL

/// Udane nadanie: wygrana roju w raporcie końca rundy
/obj/structure/swarmer_relay/proc/broadcast()
	if(finished)
		return
	finished = TRUE
	STOP_PROCESSING(SSobj, src)
	icon_state = "relay-glow"
	add_overlay("relay-sparks")
	if(swarm)
		swarm.signal_sent = TRUE
		swarm.relay = null
		swarm.message_swarm("Sygnał nadany! Nasi Mistrzowie wiedzą już o tym okręcie.")
	visible_message("<span class='warning'>[src] sypie iskrami, a powietrze aż trzeszczy od ładunków!</span>")
	priority_announce("Anomalny nadajnik na pokładzie wysłał sygnał w głęboki kosmos. Coś go odebrało.", "Sygnał nadany")
	playsound(src, 'sound/magic/lightningshock.ogg', 100, TRUE)
	message_admins("Przekaźnik rojowców w [ADMIN_VERBOSEJMP(src)] nadał sygnał.")
	log_game("The swarmer signal relay at [AREACOORD(src)] broadcast the signal.")

/obj/structure/swarmer_relay/examine(mob/user)
	. = ..()
	if(finished)
		. += "<span class='warning'>Przekaźnik nadał już sygnał.</span>"
	else if(charge_end)
		. += "<span class='warning'>Do nadania sygnału zostało około [round(time_left() / (1 SECONDS))] s.</span>"

/obj/structure/swarmer_relay/swarmer_act(mob/living/simple_animal/hostile/swarmer/S)
	to_chat(S, "<span class='warning'>To nasz przekaźnik. Musimy go bronić, a nie rozbierać.</span>")
	return FALSE

/obj/structure/swarmer_relay/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	take_damage(severity == EMP_HEAVY ? 100 : 50, BURN, "energy", FALSE)

/obj/structure/swarmer_relay/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(src, 'sound/weapons/egloves.ogg', 80, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, TRUE)

