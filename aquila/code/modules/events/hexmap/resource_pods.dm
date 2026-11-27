// AQUILA - Kapsuły z zasobami: Centrala zrzuca 2-5 kapsuł ze skrzyniami surowców i zapasów do jednego pomieszczenia okrętu (port z MrMelbert/MapleStationCode maplestation_modules/code/modules/events/resource_pods.dm)
// MapleStation drops its pods (with a small landing explosion) into a random non-maintenance station area, in one of
// four styles (Syndicate loot, Nanotrasen, a trade company, a cult inquisition) with style-specific crates. Ours lands
// the pods without any explosion on free safe floor of one safe room (our shared room finder), in three styles
// (Nanotrasen, goods seized from the Syndicate, a passing trade caravan) with the same crates for all of them: our
// resource caches and a few plain supply crates with fixed contents (no grenades, toxins or anything from the uplink).
// The pods are bluespace pods, so they vanish after landing and leave no pod to clean up. The announcement comes once
// the pods are on their way.

/datum/round_event_control/aquila_hex_resource_pods
	name = "Kapsuły z zasobami"
	typepath = /datum/round_event/aquila_hex_resource_pods
	weight = 12
	max_occurrences = 2
	earliest_start = 10 MINUTES

/datum/round_event/aquila_hex_resource_pods
	fakeable = FALSE
	startWhen = 1
	announceWhen = 2
	/// Ile kapsuł
	var/pod_count = 2
	/// Kto przysyła: "nanotrasen", "syndicate" albo "caravan"
	var/sender
	/// Pomieszczenie, w którym lądują kapsuły
	var/impact_area_name
	/// Ile kapsuł poleciało
	var/pods_sent = 0

/datum/round_event/aquila_hex_resource_pods/setup()
	pod_count = rand(2, 5)
	sender = pick("nanotrasen", "syndicate", "caravan")

/datum/round_event/aquila_hex_resource_pods/start()
	var/list/landing_turfs = aquila_hex_room_turfs(pod_count)
	if(!length(landing_turfs))
		log_game("Resource Pods: no room with [pod_count] free safe turfs, cancelling the event.")
		return kill()
	var/obj/effect/pod_landingzone/first
	for(var/turf/landing as anything in landing_turfs)
		var/obj/effect/pod_landingzone/marker = launch_pod(landing)
		first ||= marker
	pods_sent = length(landing_turfs)
	var/turf/first_turf = landing_turfs[1]
	impact_area_name = get_area_name(first_turf, TRUE)
	announce_to_ghosts(first)
	log_game("Resource Pods: [pods_sent] pod(s) from [sender] landing in [AREACOORD(first_turf)].")

/datum/round_event/aquila_hex_resource_pods/announce(fake)
	if(!pods_sent)
		return
	var/reason
	switch(sender)
		if("syndicate")
			reason = "Oddział szturmowy Nanotrasen zajął skład Syndykatu w tym sektorze. Część zarekwirowanych zapasów przekazujemy waszemu okrętowi, bo i tak nikt nie chce ich wozić z powrotem."
		if("caravan")
			reason = "Przelatująca karawana handlowa zostawiła w Centrali nadwyżki towaru w zamian za darmowe tankowanie. Dzielimy się nimi z wami."
		else
			reason = "Kopalnia Nanotrasen w sąsiednim sektorze przekroczyła normę wydobycia. Nadwyżkę przekazujemy załodze jako inwestycję w morale."
	priority_announce("[reason] Kapsuły zaopatrzeniowe ([pods_sent]) wylądują wkrótce w: [impact_area_name]. Prosimy nie stać pod kapsułami.", "Dział Logistyki Nanotrasen")

/// Wysyła jedną kapsułę ze skrzynią na pole landing; zwraca znacznik lądowania
/datum/round_event/aquila_hex_resource_pods/proc/launch_pod(turf/landing)
	var/obj/structure/closet/supplypod/pod = new(null, pod_style())
	pod.explosionSize = list(0, 0, 0, 0)
	pod.bluespace = TRUE
	make_crate().forceMove(pod)
	return new /obj/effect/pod_landingzone(landing, pod)

/datum/round_event/aquila_hex_resource_pods/proc/pod_style()
	switch(sender)
		if("syndicate")
			return STYLE_SYNDICATE
		if("nanotrasen")
			return STYLE_CENTCOM
	return STYLE_STANDARD

/// Paczki z ładowni, które mogą przylecieć w kapsule: stała zawartość, bez granatów i toksyn
/datum/round_event/aquila_hex_resource_pods/proc/supply_packs()
	var/static/list/packs = list(
		/datum/supply_pack/emergency/internals,
		/datum/supply_pack/medical/basickits,
		/datum/supply_pack/organic/food,
		/datum/supply_pack/service/lightbulbs,
	)
	return packs

/// Skrzynia z kapsuły: zwykle surowce, czasem zapasy z ładowni (pack_type wymusza paczkę)
/datum/round_event/aquila_hex_resource_pods/proc/make_crate(pack_type)
	RETURN_TYPE(/obj/structure/closet/crate)
	if(!pack_type && prob(65))
		return new /obj/structure/closet/crate/wooden/aquila_resource_cache
	var/datum/supply_pack/pack = SSshuttle.supply_packs[pack_type || pick(supply_packs())]
	var/obj/structure/closet/crate/crate = pack?.generate(null)
	if(!istype(crate))
		return new /obj/structure/closet/crate/wooden/aquila_resource_cache
	crate.locked = FALSE
	crate.update_icon()
	return crate
