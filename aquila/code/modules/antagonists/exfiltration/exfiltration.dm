// Ewakuacja antagonisty z rundy (port ParadiseSS13/Paradise: code/modules/antagonists/_common/antag_exfiltration.dm,
// changeling/powers/exfilling.dm, uplink „Extraction Flare”). Kod AGPL-3.0, grafiki CC-BY-SA 3.0 (Paradise).
// Raca działa tylko w jednym z trzech wylosowanych pomieszczeń okrętu. Po 90 s w jej miejscu otwiera się portal na 30 s.
// Przejście przez portal = ucieczka (mind.force_escaped, jak „Into the Sunset” promu): postać trafia do nullspace,
// gracz zostaje duchem. Załoga może zgasić racę albo ją rozbić, zanim portal się otworzy.

/// Ile czasu od startu rundy musi minąć, zanim ewakuacja zadziała (Paradise: 60 minut)
#define AQUILA_EXFIL_MIN_ROUND_TIME (60 MINUTES)

/// Czy ten cel pozwala na wcześniejszą ewakuację. FALSE dla celów, które wymagają obecności do końca rundy.
/datum/objective/proc/allows_exfiltration()
	return TRUE

/datum/objective/hijack/allows_exfiltration()
	return FALSE

/datum/objective/nuclear/allows_exfiltration()
	return FALSE

/datum/objective/martyr/allows_exfiltration()
	return FALSE

/datum/objective/iff_subvert/allows_exfiltration()
	return FALSE

/datum/objective/steal/allows_exfiltration()
	return !istype(targetinfo, /datum/objective_item/steal/nukedisc)

/// Powód odmowy ewakuacji albo null, jeśli wolno. check_time = FALSE pomija limit czasu (raca admina).
/datum/mind/proc/aquila_exfiltration_denial(check_time = TRUE)
	for(var/datum/objective/goal as anything in get_all_objectives())
		if(!goal.allows_exfiltration())
			return "Twoje cele są zbyt delikatne na wcześniejszą ewakuację."
	if(check_time)
		var/time_left = AQUILA_EXFIL_MIN_ROUND_TIME - (world.time - SSticker.round_start_time)
		if(time_left > 0)
			return "Portal ewakuacyjny jest jeszcze kalibrowany. Spróbuj ponownie za [round(time_left / (1 MINUTES)) + 1] min."
	return null

/// Czy ktoś inny ma tę osobę za cel (poza ochroną i wyciągnięciem z aresztu). Taki agent nie ucieknie racą (Paradise).
/datum/mind/proc/aquila_is_exfiltration_target()
	for(var/datum/mind/other as anything in SSticker.minds)
		if(other == src)
			continue
		for(var/datum/antagonist/antag as anything in other.antag_datums)
			for(var/datum/objective/objective as anything in antag.objectives)
				if(objective.target == src && !istype(objective, /datum/objective/protect) && !istype(objective, /datum/objective/breakout))
					return TRUE
	return FALSE

/// Losuje pomieszczenia okrętu, w których zadziała raca. Pomija mostek, ochronę z aresztem, kapitana, szefa ochrony i rdzeń SI (jak Paradise).
/proc/aquila_pick_exfiltration_areas(amount = 3)
	var/static/list/allowed = typecacheof(list(
		/area/engine,
		/area/medical,
		/area/science,
		/area/quartermaster,
		/area/hydroponics,
		/area/library,
		/area/chapel,
		/area/crew_quarters,
		/area/hallway,
		/area/janitor,
		/area/lawoffice,
		/area/teleporter,
		/area/storage,
		/area/tcommsat,
		/area/ai_monitored/storage/eva,
	))
	var/static/list/forbidden = typecacheof(list(
		/area/bridge,
		/area/security,
		/area/crew_quarters/heads/captain,
		/area/crew_quarters/heads/hos,
		/area/ai_monitored/turret_protected,
		/area/hallway/secondary/entry,
	))
	var/list/candidates = list()
	for(var/area_type in GLOB.the_station_areas)
		if(!is_type_in_typecache(area_type, allowed) || is_type_in_typecache(area_type, forbidden))
			continue
		var/area/candidate = GLOB.areas_by_type[area_type]
		if(candidate)
			candidates += candidate
	var/list/picked = list()
	while(length(picked) < amount && length(candidates))
		picked += pick_n_take(candidates)
	return picked

/// Raca ewakuacyjna zdrajcy
/obj/item/aquila_exfiltration_flare
	name = "raca ewakuacyjna"
	desc = "Jednorazowa raca, która wzywa portal ewakuacyjny Syndykatu. Bilet w jedną stronę."
	icon = 'aquila/icons/obj/antag_exfiltration.dmi'
	icon_state = "flare-contractor"
	item_state = "flare"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	/// Pomieszczenia, w których raca zadziała
	var/list/extractable_areas
	/// Czy obowiązuje limit czasu od startu rundy
	var/delayed_extraction = TRUE
	/// Ile trwa wzywanie portalu
	var/extraction_time = 90 SECONDS
	/// Co zostaje na podłodze po odpaleniu
	var/beacon_type = /obj/structure/aquila_exfiltration_beacon

/obj/item/aquila_exfiltration_flare/Initialize(mapload)
	. = ..()
	extractable_areas = aquila_pick_exfiltration_areas()

/obj/item/aquila_exfiltration_flare/Destroy()
	extractable_areas = null
	return ..()

/obj/item/aquila_exfiltration_flare/examine(mob/user)
	. = ..()
	if(!length(user?.mind?.antag_datums))
		return
	if(!length(extractable_areas))
		. += "<span class='warning'>Na tym okręcie nie ma pomieszczenia, w którym zadziała.</span>"
		return
	. += "<span class='warning'>Zadziała tylko w tych miejscach:</span>"
	for(var/area/A as anything in extractable_areas)
		. += "<span class='warning'> - [A.name]</span>"

/obj/item/aquila_exfiltration_flare/attack_self(mob/user)
	activate(user)

/// Odpala racę. Zwraca stawiany znacznik albo null.
/obj/item/aquila_exfiltration_flare/proc/activate(mob/living/user)
	if(!istype(user) || !user.mind)
		return
	if(!length(user.mind.antag_datums))
		to_chat(user, "<span class='warning'>Mimo starań nie udaje ci się jej odpalić.</span>")
		return
	var/turf/our_turf = get_turf(user)
	if(!our_turf || !(get_area(our_turf) in extractable_areas))
		to_chat(user, "<span class='warning'>Tutaj [src] nie zadziała. Obejrzyj ją, by sprawdzić, gdzie można ją odpalić.</span>")
		return
	if(user.mind.aquila_is_exfiltration_target())
		to_chat(user, "<span class='warning'>Ktoś zagłuszył twoją ewakuację! [src] rozpada się w popiół.</span>")
		var/datum/antagonist/antag = user.mind.antag_datums[1]
		if(!(locate(/datum/objective/potentially_backstabbed) in antag.objectives))
			var/datum/objective/potentially_backstabbed/warning = new
			warning.owner = user.mind
			antag.objectives += warning
			user.mind.announce_objectives()
		new /obj/effect/decal/cleanable/ash(our_turf)
		qdel(src)
		return
	var/denial = user.mind.aquila_exfiltration_denial(delayed_extraction)
	if(denial)
		to_chat(user, "<span class='warning'>[denial]</span>")
		return
	show_activation_message(user)
	var/obj/structure/aquila_exfiltration_beacon/beacon = new beacon_type(our_turf, user.mind, extraction_time)
	log_game("[key_name(user)] odpalił [src] w [AREACOORD(our_turf)].")
	message_admins("[ADMIN_LOOKUPFLW(user)] rozpoczął ewakuację z rundy ([src]) w [ADMIN_VERBOSEJMP(our_turf)].")
	bitrunning_announce("Wykryto nieznany sygnał portalu: [get_area_name(our_turf, TRUE)].", RADIO_CHANNEL_SECURITY)
	qdel(src)
	return beacon

/obj/item/aquila_exfiltration_flare/proc/show_activation_message(mob/living/user)
	user.visible_message("<span class='notice'>[user] wyciąga czarno-złotą racę i ją odpala.</span>", \
		"<span class='notice'>Odpalasz racę ewakuacyjną. Portal otworzy się za półtorej minuty.</span>")

/// Szybka raca dla adminów i testów (Paradise: advanced extraction flare)
/obj/item/aquila_exfiltration_flare/admin
	name = "zaawansowana raca ewakuacyjna"
	desc = "Ulepszona jednorazowa raca, która szybko wzywa portal ewakuacyjny Syndykatu. Bilet w jedną stronę."
	delayed_extraction = FALSE
	extraction_time = 5 SECONDS

/// Masa ewakuacyjna zmiennokształtnego
/obj/item/aquila_exfiltration_flare/changeling
	name = "wijąca się masa"
	desc = "Wijąca się bryła ciała, która otworzy jednorazowy portal z okrętu. Bilet w jedną stronę."
	icon_state = "changeling_organ"
	item_state = null
	beacon_type = /obj/structure/aquila_exfiltration_beacon/changeling

/obj/item/aquila_exfiltration_flare/changeling/show_activation_message(mob/living/user)
	user.visible_message("<span class='notice'>[user] kładzie na podłodze groteskową, mięsistą bryłę.</span>", \
		"<span class='notice'>Kładziemy na podłodze pulsujący kawałek siebie. Portal otworzy się za półtorej minuty.</span>")

/// Odpalona raca. Załoga może ją zgasić albo rozbić, zanim otworzy się portal.
/obj/structure/aquila_exfiltration_beacon
	name = "płonąca raca ewakuacyjna"
	desc = "Czarno-złota raca sypie iskrami. Wygląda na to, że coś wzywa."
	icon = 'aquila/icons/obj/antag_exfiltration.dmi'
	icon_state = "flare-contractor-on"
	anchored = TRUE
	density = FALSE
	max_integrity = 15
	layer = BELOW_MOB_LAYER
	light_range = 6
	light_power = 1
	light_color = "#FFD165"
	/// Kto się ewakuuje
	var/datum/mind/antag_mind
	/// Timer otwarcia portalu
	var/portal_timer
	/// Czy portal się otworzył (wtedy zniknięcie racy to nie porażka)
	var/opened = FALSE
	/// Dźwięk odpalenia
	var/activation_sound = 'sound/items/match_strike.ogg'
	/// Komunikat dla gaszącego
	var/extinguish_text = "gasi racę ewakuacyjną"
	/// Komunikat przy próbie gaszenia
	var/extinguish_attempt_text = "próbuje zgasić racę ewakuacyjną"

/obj/structure/aquila_exfiltration_beacon/Initialize(mapload, datum/mind/owner_mind, delay = 90 SECONDS)
	. = ..()
	antag_mind = owner_mind
	playsound(src, activation_sound, 50, TRUE)
	portal_timer = addtimer(CALLBACK(src, PROC_REF(open_portal)), delay, TIMER_STOPPABLE)

/obj/structure/aquila_exfiltration_beacon/Destroy()
	if(portal_timer)
		deltimer(portal_timer)
		portal_timer = null
	if(!opened && antag_mind)
		log_game("Ewakuacja [key_name(antag_mind)] została przerwana.")
		to_chat(antag_mind.current, "<span class='userdanger'>Twoja ewakuacja została przerwana!</span>")
	antag_mind = null
	return ..()

/obj/structure/aquila_exfiltration_beacon/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.mind && user.mind == antag_mind)
		to_chat(user, "<span class='notice'>Portal już się wzywa. Czekaj w pobliżu.</span>")
		return TRUE
	user.visible_message("<span class='warning'>[user] [extinguish_attempt_text]!</span>")
	if(!do_after(user, 3 SECONDS, target = src))
		return TRUE
	put_out(user)
	return TRUE

/// Załoga przerywa ewakuację
/obj/structure/aquila_exfiltration_beacon/proc/put_out(mob/living/user)
	if(QDELETED(src) || opened)
		return
	if(user)
		user.visible_message("<span class='warning'>[user] [extinguish_text]!</span>")
		log_game("[key_name(user)] przerwał ewakuację [key_name(antag_mind)] w [AREACOORD(src)].")
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)

/obj/structure/aquila_exfiltration_beacon/proc/open_portal()
	portal_timer = null
	if(QDELETED(src))
		return
	opened = TRUE
	var/turf/our_turf = get_turf(src)
	var/obj/effect/aquila_exfiltration_portal/portal = new(our_turf, antag_mind)
	new /obj/effect/decal/cleanable/ash(our_turf)
	qdel(src)
	return portal

/obj/structure/aquila_exfiltration_beacon/changeling
	name = "wijąca się masa"
	desc = "Pulsująca bryła ciała wije się na podłodze. Coś z niej wyrasta."
	icon_state = "changeling-organ"
	light_color = "#E79592"
	activation_sound = 'sound/effects/splat.ogg'
	extinguish_text = "rozgniata wijącą się masę"
	extinguish_attempt_text = "próbuje rozgnieść wijącą się masę"

/// Portal ewakuacyjny. Przepuszcza tylko właściciela, innych odrzuca w losowe miejsce okrętu.
/obj/effect/aquila_exfiltration_portal
	name = "portal ewakuacyjny"
	desc = "Wirujący portal Syndykatu. Nie wygląda przyjaźnie."
	icon = 'aquila/icons/obj/antag_exfiltration.dmi'
	icon_state = "portal-syndicate"
	anchored = TRUE
	light_range = 3
	light_power = 1
	light_color = "#FF3030"
	/// Kto może przejść
	var/datum/mind/antag_mind
	/// Czy ktoś się już ewakuował
	var/used = FALSE
	/// Jak długo portal jest otwarty
	var/lifetime = 30 SECONDS

/obj/effect/aquila_exfiltration_portal/Initialize(mapload, datum/mind/owner_mind)
	. = ..()
	antag_mind = owner_mind
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	QDEL_IN(src, lifetime)

/obj/effect/aquila_exfiltration_portal/Destroy()
	if(!used && antag_mind)
		log_game("[key_name(antag_mind)] nie zdążył się ewakuować.")
	antag_mind = null
	return ..()

/obj/effect/aquila_exfiltration_portal/proc/on_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(isliving(arrived))
		INVOKE_ASYNC(src, PROC_REF(pass_through), arrived)

/obj/effect/aquila_exfiltration_portal/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	if(user.Adjacent(src))
		pass_through(user)
		return TRUE

/obj/effect/aquila_exfiltration_portal/proc/pass_through(mob/living/user)
	if(used || QDELETED(src) || QDELETED(user))
		return
	if(user.mind && user.mind == antag_mind)
		extract(user)
	else
		reject(user)

/// Ucieczka: cele liczą postać jako uciekiniera, ciało w nullspace, gracz zostaje duchem
/obj/effect/aquila_exfiltration_portal/proc/extract(mob/living/user)
	used = TRUE
	var/datum/mind/extracted = user.mind
	extracted.force_escaped = TRUE
	do_sparks(4, FALSE, src)
	log_game("[key_name(user)] ewakuował się z rundy przez portal w [AREACOORD(src)].")
	message_admins("[ADMIN_LOOKUPFLW(user)] ewakuował się z rundy przez portal.")
	if(extracted.has_antag_datum(/datum/antagonist/changeling))
		bitrunning_announce("--ZZZT!- Witaj w domu, [user.real_name]. -ZZT!-", RADIO_CHANNEL_SECURITY)
	else
		bitrunning_announce("--ZZZT!- Dobra robota, agencie [user.real_name]. Wracaj do -^&!-ZZT!-", RADIO_CHANNEL_SECURITY)
	to_chat(user, "<span class='greentext big'>Przechodzisz przez portal. Ewakuacja udana, opuszczasz okręt.</span>")
	user.visible_message("<span class='warning'>[user] znika w portalu!</span>", ignored_mobs = list(user))
	// Jak „Into the Sunset” promu: ciało w stazie w nullspace (sprawdzenia celów i statystyki), gracz jako duch
	user.notransform = TRUE
	user.ghostize(FALSE)
	user.moveToNullspace()
	qdel(src)

/// Ktoś obcy wskoczył do portalu: odrzuca go poturbowanego w losowe miejsce okrętu (Paradise: fail_extraction)
/obj/effect/aquila_exfiltration_portal/proc/reject(mob/living/user)
	to_chat(user, "<span class='userdanger'>Wskakujesz do portalu! Tuż przed drugą stroną czujesz przeszywający ból głowy!</span>")
	log_game("[key_name(user)] wszedł do cudzego portalu ewakuacyjnego w [AREACOORD(src)].")
	var/turf/destination
	if(length(GLOB.the_station_areas))
		var/list/turfs = get_safe_random_station_turfs(list(pick(GLOB.the_station_areas)))
		if(length(turfs))
			destination = turfs[1]
	do_sparks(4, FALSE, src)
	if(destination)
		user.forceMove(destination)
	user.Paralyze(30 SECONDS)
	user.blind_eyes(35)
	user.adjustBruteLoss(40)

/// Moc zmiennokształtnego: oddziela masę, która wzywa portal ewakuacyjny (Paradise: Generate Extraction Mass)
/datum/action/changeling/aquila_exfiltration
	name = "Masa ewakuacyjna"
	desc = "Oddzielamy wyspecjalizowany narząd, który otworzy portal ewakuacyjny. Raz na rundę. Kosztuje 30 chemikaliów."
	helptext = "Tworzy mięsistą bryłę, którą w kilku wybranych miejscach okrętu można położyć, by po półtorej minuty otworzyć portal i opuścić rundę z obecną tożsamością. Załoga może ją rozgnieść."
	icon_icon = 'aquila/icons/obj/antag_exfiltration.dmi'
	button_icon_state = "changeling_organ"
	chemical_cost = 30
	dna_cost = 0
	req_human = TRUE

/// Czy zmiennokształtny oddzielił już masę ewakuacyjną (raz na rundę, przetrwa ponowne przystosowanie)
/datum/antagonist/changeling/var/aquila_exfiltration_used = FALSE

/datum/action/changeling/aquila_exfiltration/can_sting(mob/living/user, mob/target)
	. = ..()
	if(!.)
		return
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(changeling.aquila_exfiltration_used)
		to_chat(user, "<span class='warning'>Już oddzieliliśmy masę ewakuacyjną.</span>")
		return FALSE
	var/denial = user.mind.aquila_exfiltration_denial()
	if(denial)
		to_chat(user, "<span class='warning'>[denial]</span>")
		return FALSE

/datum/action/changeling/aquila_exfiltration/sting_action(mob/living/user)
	..()
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	changeling.aquila_exfiltration_used = TRUE
	var/obj/item/aquila_exfiltration_flare/changeling/mass = new(get_turf(user))
	user.put_in_hands(mass)
	to_chat(user, "<span class='notice'>Oddzielamy od siebie wijącą się masę. Obejrzyj ją, by sprawdzić, gdzie zadziała.</span>")
	return TRUE

/datum/uplink_item/device_tools/aquila_exfiltration_flare
	name = "Raca ewakuacyjna"
	desc = "Specjalna raca, która wzywa portal ewakuacyjny. Portal otwiera się po półtorej minuty i tylko w kilku pomieszczeniach, do których raca jest skalibrowana. Przejście przez niego to udana ucieczka z rundy. Działa najwcześniej godzinę po starcie zmiany. Syndykat odmówi portalu agentom z celami, które wymagają obecności do końca (porwanie promu, IFF, męczeństwo, dysk nuklearny)."
	item = /obj/item/aquila_exfiltration_flare
	cost = 0
	limited_stock = 1
	purchasable_from = UPLINK_TRAITORS
	surplus = 0
	cant_discount = TRUE

#undef AQUILA_EXFIL_MIN_ROUND_TIME
