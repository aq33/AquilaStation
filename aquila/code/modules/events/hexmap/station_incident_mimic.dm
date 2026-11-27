// AQUILA - Podejrzana skrzynia: złomiarze z pobliskiego złomowiska przysyłają kapsułą do zaopatrzenia zaplombowaną skrzynię z wraku, a skrzynia okazuje się mimikiem (port z BlueMoon-Labs/BlueMoon-Station code/modules/events/station_incidents.dm, /datum/round_event_control/station_incident/mimic)
// BlueMoon delivers a sealed salvage transit case with its own crate sprite to cargo, with a crate mimic and some metal
// and glass inside, a shipping manifest and an announcement of the salvage service. We have no transit case sprite, so
// the pod carries our crate mimic itself (/mob/living/basic/mimic/crate, inert until someone tries to open it or hits it)
// renamed to a sealed salvage crate, with the metal and glass inside and the manifest next to it. The pod lands in the
// cargo bay like our stray cargo pod (landing checks through parent_type), with no landing explosion. Texts written anew.

/datum/round_event_control/aquila_hex_station_incident_mimic
	name = "Podejrzana skrzynia"
	typepath = /datum/round_event/aquila_hex_station_incident_mimic
	weight = 10
	min_players = 10
	max_occurrences = 1
	earliest_start = 25 MINUTES

/datum/round_event/aquila_hex_station_incident_mimic
	parent_type = /datum/round_event/aquila_stray_cargo
	fakeable = FALSE

/datum/round_event/aquila_hex_station_incident_mimic/announce(fake)
	if(!landing_zone)
		return
	priority_announce("Spółdzielnia Złomiarzy „Pod Wrakiem” przesyła do oceny skrzynię znalezioną w ładowni porzuconego frachtowca. Kapsuła wyląduje w: [impact_area?.name || "nieznane"]. Według naszej brygady skrzynia ważyła przy każdym ważeniu inaczej. To na pewno nic takiego. Prosimy otwierać w obecności ochrony.", "Spółdzielnia Złomiarzy „Pod Wrakiem”")

/datum/round_event/aquila_hex_station_incident_mimic/start()
	if(!landing_zone)
		return kill()
	if(is_blocked_turf(landing_zone, TRUE))
		landing_zone = get_landing_zone()
		if(!landing_zone)
			return kill()
	var/obj/structure/closet/supplypod/pod = make_shipment()
	var/obj/effect/pod_landingzone/landing_marker = new(landing_zone, pod)
	announce_to_ghosts(landing_marker)
	log_game("Counterfeit Cargo Crate: a salvage crate mimic is landing at [AREACOORD(landing_zone)].")

/// Kapsuła (w nullspace) ze skrzynią-mimikiem i listem przewozowym
/datum/round_event/aquila_hex_station_incident_mimic/proc/make_shipment()
	var/obj/structure/closet/supplypod/pod = new(null, STYLE_PIRATE)
	pod.explosionSize = list(0, 0, 0, 0)
	var/mob/living/basic/mimic/crate/mimic = new(pod)
	mimic.name = "zaplombowana skrzynia złomiarzy"
	mimic.desc = "Obita blachą skrzynia z ładowni wraku, ściągnięta miedzianymi pasami. Plomba jest cała, ale wieko leży trochę krzywo."
	new /obj/item/stack/sheet/iron(mimic, 10)
	new /obj/item/stack/sheet/glass(mimic, 5)
	var/obj/item/paper/manifest = new(pod)
	manifest.name = "list przewozowy Spółdzielni Złomiarzy"
	manifest.add_raw_text("<center><b>SPÓŁDZIELNIA ZŁOMIARZY „POD WRAKIEM”</b></center><br>\
		Odbiorca: dział zaopatrzenia, do oceny i przekazania specjalistom.<br>\
		Znalezisko: skrzynia bez oznaczeń z ładowni porzuconego frachtowca.<br>\
		Plomba: cała, nasza, nie ruszana.<br>\
		Uwagi brygady: masa zmieniała się między ważeniami. Józek mówi, że słyszał oddech. Józek mówi wiele rzeczy. \
		Drugi tragarz odmówił podpisania protokołu.<br><br>\
		<i>Otwierać w zamkniętym pomieszczeniu, w obecności ochrony. Reklamacji nie przyjmujemy.</i>")
	manifest.update_appearance()
	return pod

/// Magazyn zaopatrzenia (jak prezent od Nanotrasen), a gdy okręt nie ma tam wolnej podłogi, dowolny bezpieczny obszar
/datum/round_event/aquila_hex_station_incident_mimic/find_event_area()
	for(var/area_type in list(/area/quartermaster/storage, /area/quartermaster/warehouse, /area/quartermaster))
		var/area/cargo = GLOB.areas_by_type[area_type]
		if(!cargo)
			continue
		for(var/turf/open/T in cargo)
			if(!isspaceturf(T) && !is_blocked_turf(T, TRUE))
				return cargo
	return ..()
