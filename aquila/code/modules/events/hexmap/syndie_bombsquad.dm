// AQUILA - Oddział saperów Syndykatu: kapsuła Syndykatu ląduje w ważnym pomieszczeniu okrętu z kilkoma żołnierzami i uzbrojoną bombą, która po pięciu minutach wybucha w tym pomieszczeniu, chyba że ktoś ją rozbroi (port z Bubberstation/Bubberstation modular_zubbers/code/modules/events/moderate/bomb_squad.dm)
// Bubber drops a Syndicate stray cargo pod with six troopers and an armed EZ-bomb (a normal Syndicate bomb core,
// 500 s, engineers see its wires) into the vault, bridge, armory, brig, AI upload, engineering, server room or chemistry.
// Those rooms are closed or dangerous for our events, so ours aims at important rooms the crew can reach (medbay,
// chemistry, research, cargo, hydroponics, the bar and the kitchen, then any safe room) and needs a landing spot with
// no space, shuttle, closed or dangerous area, fuel tank, gas canister or ship ammunition within seven tiles, so the
// light blast can neither open the hull nor set off anything bigger. The pod is a bluespace one (it vanishes after
// landing) with no landing explosion and brings three or four of our basic Syndicate troopers (knife, sword, pistol,
// SMG; no space suits or shotguns) that do not smash obstacles, and our own bomb: 300 s on the clock from the moment
// the pod opens, bolted down for good (its unbolt wire does nothing), wires in a fixed order that the ship's
// blueprints list as "Bomba saperów Syndykatu" (cutting the activation wire stops the clock, as in every Syndicate
// bomb). Its core is a small one (light 2, fire 2, no heavy blast) that goes off only inside the bomb, and only where
// the landing rules still hold: anywhere else it just flashes and smokes. A defused core is inert. CentCom warns the
// crew as the pod falls.

/// Promień, w którym przy bombie saperów nie może być kosmosu, paliwa, kanistrów, amunicji ani zamkniętych obszarów
#define AQUILA_BOMBSQUAD_SAFE_RADIUS 7

/datum/round_event_control/aquila_hex_syndie_bombsquad
	name = "Oddział saperów Syndykatu"
	typepath = /datum/round_event/aquila_hex_syndie_bombsquad
	weight = 5
	min_players = 20
	max_occurrences = 1
	earliest_start = 35 MINUTES

/datum/round_event/aquila_hex_syndie_bombsquad
	fakeable = FALSE
	startWhen = 1
	announceWhen = -1 // ostrzeżenie idzie w start(), gdy kapsuła już leci
	/// Ilu żołnierzy leci w kapsule
	var/squad_size = 3

/datum/round_event/aquila_hex_syndie_bombsquad/setup()
	squad_size = rand(3, 4)

/datum/round_event/aquila_hex_syndie_bombsquad/start()
	var/turf/landing = aquila_hex_bombsquad_landing()
	if(!landing)
		log_game("Syndicate Bomb Squad: no safe landing spot away from the hull, cancelling the event.")
		return kill()
	var/obj/effect/pod_landingzone/marker = launch(landing)
	if(!marker)
		return kill()
	announce_to_ghosts(marker)
	var/area/target_area = get_area(landing)
	priority_announce("Wywiad Nanotrasen przechwycił rozkaz Syndykatu: oddział saperów leci kapsułą desantową do pomieszczenia [target_area.name] i podłoży tam bombę z pięciominutowym zapalnikiem. Ochrona: zneutralizować napastników. Inżynieria: otworzyć panel bomby śrubokrętem i przeciąć przewód uzbrajający. Układ przewodów jest w planach okrętu, w legendzie „Bomba saperów Syndykatu” (otwarte plany trzeba otworzyć ponownie). Pozostali: trzymać się z daleka.", "Wywiad Nanotrasen")
	message_admins("Oddział saperów Syndykatu ląduje w [ADMIN_VERBOSEJMP(landing)].")
	log_game("Syndicate Bomb Squad: a pod with [squad_size] troopers and a bomb is landing at [AREACOORD(landing)].")

/// Wysyła kapsułę z oddziałem i bombą na pole; zwraca znacznik lądowania
/datum/round_event/aquila_hex_syndie_bombsquad/proc/launch(turf/landing)
	if(!isturf(landing))
		return null
	return new /obj/effect/pod_landingzone(landing, make_pod())

/// Kapsuła Syndykatu bez wybuchu przy lądowaniu, która znika po otwarciu, z oddziałem i bombą
/datum/round_event/aquila_hex_syndie_bombsquad/proc/make_pod()
	var/obj/structure/closet/supplypod/pod = new(null, STYLE_SYNDICATE)
	pod.explosionSize = list(0, 0, 0, 0)
	pod.bluespace = TRUE
	fill_pod(pod)
	return pod

/// Wkłada do kapsuły żołnierzy i bombę, która uzbroi się, gdy kapsuła się otworzy
/datum/round_event/aquila_hex_syndie_bombsquad/proc/fill_pod(obj/structure/closet/supplypod/pod)
	var/static/list/squad_types = list(
		/mob/living/basic/trooper/syndicate/melee,
		/mob/living/basic/trooper/syndicate/melee/sword,
		/mob/living/basic/trooper/syndicate/ranged,
		/mob/living/basic/trooper/syndicate/ranged/smg,
	)
	for(var/i in 1 to squad_size)
		var/trooper_type = pick(squad_types)
		var/mob/living/basic/trooper/syndicate/trooper = new trooper_type(pod)
		trooper.environment_smash = ENVIRONMENT_SMASH_NONE // nie rozbijają okien ani ścian
	var/obj/machinery/syndicatebomb/aquila_hex_squad/bomb = new(pod)
	bomb.arm_on_landing = TRUE
	return bomb

/**
 * Pole lądowania saperów: wolne bezpieczne pole w ważnym pomieszczeniu, do którego załoga ma dostęp, z czystą okolicą
 * w promieniu AQUILA_BOMBSQUAD_SAFE_RADIUS (aquila_hex_bomb_spot_ok()); gdy takiego nie ma, to samo w dowolnym
 * bezpiecznym pomieszczeniu. W każdym pomieszczeniu sprawdza najwyżej 20 losowych wolnych pól.
 */
/proc/aquila_hex_bombsquad_landing()
	var/static/list/important_cache = typecacheof(list(
		/area/medical/medbay,
		/area/medical/chemistry,
		/area/science/research,
		/area/quartermaster/storage,
		/area/quartermaster/office,
		/area/hydroponics,
		/area/crew_quarters/bar,
		/area/crew_quarters/kitchen,
		/area/crew_quarters/cafeteria,
	))
	var/list/important = list()
	for(var/area_type in GLOB.the_station_areas)
		if(important_cache[area_type])
			important += area_type
	for(var/list/choices in list(important, GLOB.the_station_areas.Copy()))
		var/checked = 0
		while(length(choices) && checked < 15)
			var/area_type = pick_n_take(choices)
			if(aquila_hex_closed_area_type(area_type) || ispath(area_type, /area/maintenance) || ispath(area_type, /area/space))
				continue
			checked++
			var/tries = 0
			for(var/turf/T as anything in shuffle(get_area_turfs(area_type)))
				if(!is_station_level(T.z) || !aquila_hex_free_safe_turf(T))
					continue
				if(aquila_hex_bomb_spot_ok(T))
					return T
				if(++tries >= 20)
					break
	return null

/// Czy bomba saperów może stać i wybuchnąć na polu statku: poziom statku i czysta okolica (aquila_hex_bomb_area_clear())
/proc/aquila_hex_bomb_spot_ok(turf/center, radius = AQUILA_BOMBSQUAD_SAFE_RADIUS)
	return isturf(center) && is_station_level(center.z) && aquila_hex_bomb_area_clear(center, radius)

/**
 * Czy w promieniu radius od pola nie ma kosmosu, dziury w podłodze, obszaru kosmosu, promu, zamkniętego ani
 * niebezpiecznego obszaru (aquila_hex_closed_area_type()) i niczego, co lekki wybuch albo ogień by odpalił: zbiornika
 * paliwa, kanistra z gazem, amunicji okrętowej. Nie sprawdza poziomu statku (to robi aquila_hex_bomb_spot_ok()).
 */
/proc/aquila_hex_bomb_area_clear(turf/center, radius = AQUILA_BOMBSQUAD_SAFE_RADIUS)
	var/static/list/explosive_types = typecacheof(list(
		/obj/structure/reagent_dispensers/fueltank,
		/obj/structure/reagent_dispensers/plumbed/fuel,
		/obj/machinery/portable_atmospherics/canister,
		/obj/item/ship_weapon/ammunition,
		/obj/item/powder_bag,
	))
	if(!isturf(center))
		return FALSE
	for(var/turf/T as anything in RANGE_TURFS(radius, center))
		if(isspaceturf(T) || isgroundlessturf(T))
			return FALSE
		var/area/turf_area = T.loc
		if(!turf_area || istype(turf_area, /area/space) || istype(turf_area, /area/shuttle) || aquila_hex_closed_area_type(turf_area.type))
			return FALSE
		for(var/atom/movable/thing as anything in T)
			if(explosive_types[thing.type])
				return FALSE
	return TRUE

/// Bomba saperów Syndykatu: mały ładunek, zapalnik 5 min od otwarcia kapsuły, przewody w stałym układzie (pokazują je plany okrętu)
/obj/machinery/syndicatebomb/aquila_hex_squad
	name = "bomba saperów Syndykatu"
	desc = "Tania bomba z demobilu Syndykatu, przykręcona do podłogi na stałe. Pod panelem są przewody w fabrycznym układzie, który pokazują plany okrętu. Przecięcie przewodu uzbrajającego zatrzymuje zegar."
	anchored = TRUE
	can_unanchor = FALSE
	minimum_timer = 300
	timer_set = 300
	payload = /obj/item/bombcore/aquila_hex_squad
	/// Uzbraja się, gdy kapsuła wyrzuci ją na podłogę (w kapsule nie tyka i nie woła duchów)
	var/arm_on_landing = FALSE

/obj/machinery/syndicatebomb/aquila_hex_squad/Initialize(mapload)
	. = ..()
	QDEL_NULL(wires)
	wires = new /datum/wires/syndicatebomb/aquila_hex_squad(src)

/obj/machinery/syndicatebomb/aquila_hex_squad/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	if(arm_on_landing && istype(OldLoc, /obj/structure/closet/supplypod) && isturf(loc))
		arm_on_landing = FALSE
		activate()
		update_icon()

/// Przewody bomby saperów w stałym układzie na rundę (jak przewody śluz), żeby plany okrętu je pokazały; rygli nie da się zwolnić
/datum/wires/syndicatebomb/aquila_hex_squad
	holder_type = /obj/machinery/syndicatebomb/aquila_hex_squad
	proper_name = "Bomba saperów Syndykatu"
	randomize = FALSE

/datum/wires/syndicatebomb/aquila_hex_squad/on_cut(wire, mend)
	if(wire != WIRE_UNBOLT)
		return ..()
	if(!mend)
		holder.visible_message("<span class='notice'>[icon2html(holder, viewers(holder))] Rygle drgają, ale zostają w podłodze.</span>")

/// Mały ładunek saperów: lekki wybuch i ogień w promieniu dwóch pól, tylko w bombie i tylko w czystej okolicy; gdzie indziej błysk i dym
/obj/item/bombcore/aquila_hex_squad
	name = "mały ładunek saperów"
	desc = "Niewielki ładunek z demobilu Syndykatu. Bez obudowy bomby jest bezużyteczny."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	range_heavy = 0
	range_medium = 0
	range_light = 2
	range_flame = 2
	/// Rozbrojony ładunek już nie wybucha
	var/inert = FALSE
	/// Promień, w którym okolica musi być czysta, żeby ładunek wybuchł
	var/safe_radius = AQUILA_BOMBSQUAD_SAFE_RADIUS
	/// Czy wybucha tylko na poziomie statku (test to wyłącza)
	var/station_only = TRUE

/obj/item/bombcore/aquila_hex_squad/ex_act(severity, target)
	return // nie wybucha od innych wybuchów

/obj/item/bombcore/aquila_hex_squad/burn()
	return

/obj/item/bombcore/aquila_hex_squad/defuse()
	inert = TRUE
	name = "rozbrojony ładunek saperów"

/obj/item/bombcore/aquila_hex_squad/detonate()
	var/obj/machinery/syndicatebomb/bomb = loc
	if(inert || !istype(bomb))
		return
	var/turf/bomb_turf = get_turf(bomb)
	if(!bomb_turf)
		return
	if(blast_allowed(bomb_turf))
		explosion(bomb_turf, 0, 0, range_light, 3, flame_range = range_flame)
		log_game("Syndicate Bomb Squad: the bomb went off at [AREACOORD(bomb_turf)].")
	else
		fizzle(bomb_turf)
		log_game("Syndicate Bomb Squad: the bomb only fizzled at [AREACOORD(bomb_turf)], too close to the hull or something explosive.")
	qdel(bomb)
	if(!QDELETED(src))
		qdel(src)

/// Czy ładunek może wybuchnąć na tym polu: te same warunki co przy lądowaniu saperów
/obj/item/bombcore/aquila_hex_squad/proc/blast_allowed(turf/T)
	if(!isturf(T) || (station_only && !is_station_level(T.z)))
		return FALSE
	return aquila_hex_bomb_area_clear(T, safe_radius)

/// Niewypał: sam błysk i dym, bez wybuchu i ognia
/obj/item/bombcore/aquila_hex_squad/proc/fizzle(turf/T)
	T.visible_message("<span class='warning'>Bomba trzaska, błyska i dymi, ale nie wybucha.</span>")
	playsound(T, 'sound/weapons/flashbang.ogg', 50, TRUE)
	new /obj/effect/dummy/lighting_obj(T, 4, 3, LIGHT_COLOR_WHITE, 0.5 SECONDS)
	new /obj/effect/temp_visual/small_smoke(T)

#undef AQUILA_BOMBSQUAD_SAFE_RADIUS
