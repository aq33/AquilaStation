// AQUILA - Splątanie szafek: szafy na okręcie łączą się w pary na kilka minut, a to, co leży albo siedzi w jednej, po otwarciu wychodzi z drugiej (port z goonstation code/modules/events/locker_entanglement.dm)
// Original code: goonstation (https://github.com/goonstation/goonstation), licensed CC BY-NC-SA 3.0
// (https://creativecommons.org/licenses/by-nc-sa/3.0/). This port is non-commercial and keeps the same licence for this file.
// As in Goon: every closet on the ship (not crates, body bags, boxes, pods, secure lockers, bluespace lockers) is paired with another one at random for
// 1-5 minutes, with a Central Command quantum anomaly alert at the start and a stability alert at the end. Goon's storage
// code that moves the contents of entangled lockers is not in the source we have, so here opening an entangled closet
// (or anything else that empties it) drops its contents at its partner instead of in front of itself, with a spark at
// the partner. Getting into one closet and opening it again therefore lets you out of the other one. The contents go
// to the partner only if it stands on a ship level, on a turf that is not space and has breathable pressure; otherwise
// they come out of the opened closet as usual.

/obj/structure/closet
	/// Closet entangled with this one by the locker entanglement event: its contents come out there
	var/datum/weakref/aquila_entangled_closet

/obj/structure/closet/dump_contents()
	var/obj/structure/closet/partner = aquila_entangled_closet?.resolve()
	var/turf/exit = partner && !QDELETED(partner) ? partner.drop_location() : null
	if(aquila_entangled_exit_safe(exit) && length(contents))
		for(var/atom/movable/thing in src)
			thing.forceMove(exit)
		do_sparks(2, TRUE, exit)
		playsound(exit, 'sound/effects/phasein.ogg', 25, TRUE)
	return ..()

/// The partner closet's turf is on the ship, not space and has breathable pressure
/proc/aquila_entangled_exit_safe(turf/exit)
	if(!isopenturf(exit) || isspaceturf(exit) || !is_station_level(exit.z))
		return FALSE
	var/datum/gas_mixture/air = exit.return_air()
	if(!air)
		return FALSE
	var/pressure = air.return_pressure()
	return pressure >= WARNING_LOW_PRESSURE && pressure <= WARNING_HIGH_PRESSURE

/datum/round_event_control/aquila_hex_locker_entanglement
	name = "Splątanie szafek"
	typepath = /datum/round_event/aquila_hex_locker_entanglement
	weight = 10
	min_players = 3
	max_occurrences = 1
	earliest_start = 15 MINUTES

/datum/round_event/aquila_hex_locker_entanglement
	fakeable = FALSE
	startWhen = 1
	announceWhen = 1
	/// Weakrefs of the entangled closets
	var/list/entangled = list()

/datum/round_event/aquila_hex_locker_entanglement/setup()
	endWhen = rand(30, 150) // 1-5 minutes

/datum/round_event/aquila_hex_locker_entanglement/announce(fake)
	if(!fake && !length(entangled))
		return
	priority_announce("Na pokładzie okrętu wykryto anomalię kwantową. Podprzestrzenie wymiarowe szaf mogły stracić stabilność. Do szaf wchodzicie na własne ryzyko.", "Anomalia kwantowa", ANNOUNCER_SPANOMALIES)

/datum/round_event/aquila_hex_locker_entanglement/start()
	var/list/closets = list()
	for(var/area_type in GLOB.the_station_areas)
		var/area/ship_area = GLOB.areas_by_type[area_type]
		if(!ship_area)
			continue
		for(var/obj/structure/closet/closet in ship_area)
			if(can_entangle(closet))
				closets += closet
		CHECK_TICK
	if(entangle(closets) < 2)
		log_game("Locker Entanglement: fewer than two closets on the ship, cancelling the event.")
		return kill()
	log_game("Locker Entanglement paired [length(entangled)] closets for [DisplayTimeText(endWhen * 2 SECONDS)].")

/// A plain closet standing on a ship turf
/datum/round_event/aquila_hex_locker_entanglement/proc/can_entangle(obj/structure/closet/closet)
	var/static/list/excluded_closets = typecacheof(list(
		/obj/structure/closet/crate,
		/obj/structure/closet/body_bag,
		/obj/structure/closet/cardboard,
		/obj/structure/closet/supplypod,
		/obj/structure/closet/stasis,
		/obj/structure/closet/infinite,
		/obj/structure/closet/decay,
		/obj/structure/closet/abductor,
		/obj/structure/closet/secure_closet,
		/obj/structure/closet/bluespace,
	))
	return !excluded_closets[closet.type] && isturf(closet.loc) && is_station_level(closet.z)

/// Pairs the closets at random (an odd one is left alone). Returns how many were entangled
/datum/round_event/aquila_hex_locker_entanglement/proc/entangle(list/closets)
	closets = shuffle(closets.Copy())
	for(var/i in 1 to length(closets) - 1 step 2)
		var/obj/structure/closet/first = closets[i]
		var/obj/structure/closet/second = closets[i + 1]
		first.aquila_entangled_closet = WEAKREF(second)
		second.aquila_entangled_closet = WEAKREF(first)
		entangled += WEAKREF(first)
		entangled += WEAKREF(second)
	return length(entangled)

/// Breaks every pair
/datum/round_event/aquila_hex_locker_entanglement/proc/disentangle()
	for(var/datum/weakref/closet_ref as anything in entangled)
		var/obj/structure/closet/closet = closet_ref.resolve()
		if(closet)
			closet.aquila_entangled_closet = null
	entangled.Cut()

/datum/round_event/aquila_hex_locker_entanglement/end()
	if(!length(entangled))
		return
	disentangle()
	priority_announce("Stabilność kwantowa szaf przywrócona. Zawartość szaf zostaje tam, gdzie wylądowała.", "Anomalia kwantowa")

/datum/round_event/aquila_hex_locker_entanglement/kill()
	disentangle()
	return ..()
