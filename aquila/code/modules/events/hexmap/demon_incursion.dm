// AQUILA - Inwazja demonów: w jednym pomieszczeniu otwierają się portale z zaświatów, z których co jakiś czas wychodzą demony; portale mnożą się w okolicy, jeśli nikt ich nie niszczy, ale najwyżej do sześciu, a zniszczenie wszystkich kończy inwazję (port z ParadiseSS13/Paradise code/modules/events/demon_incursion.dm)
// Paradise opens one portal per ten crew in one area, announces a major incursion after 2 minutes, lets each portal
// (a nether spawner, 200 integrity, self-repairing) spit 1-3 mobs fast and then one every 45 s plus 5 s per living
// mob, spreads a new portal within 8 tiles every 3-4 minutes (always below the starting count, then less and less
// often), turns the floor around the portals into hell flooring, gives some mobs special variants, spawns a lavaland
// elite when the portal count doubles its target, and ends when no portal is left (a destroyed portal drops ore and
// gibs half of its mobs). Ours keeps the core with hard limits: one or two portals in a free safe spot of one safe room,
// each lets out a creature every 45 s while fewer than 12 of the incursion's creatures live and at most 30 come in
// total; a new portal opens every 3 minutes within 6 tiles of a random one, in the same room, on a free safe floor
// in its clear line of sight (not next to another portal) up to 6 portals. No hell flooring, no special variants, no
// elites and no self-repair; a portal the crew destroys (also by fire) takes half of its creatures with it. The crew
// is warned a minute after the first portal opens. Destroying every portal ends the incursion; after 30 minutes the
// remaining portals close on their own. When the incursion ends, its creatures that are still around vanish. The
// creatures are our hell and netherworld mobs and the hellhound of the dimensional tear, with the tear's faction and
// its AI that never attacks obstacles, so nothing breaks the hull. The portal is the nether link sprite (icons/mob/nest.dmi) in red.

/datum/round_event_control/aquila_hex_demon_incursion
	name = "Inwazja demonów"
	typepath = /datum/round_event/aquila_hex_demon_incursion
	weight = 3
	min_players = 25
	max_occurrences = 1
	earliest_start = 40 MINUTES

/datum/round_event/aquila_hex_demon_incursion
	fakeable = FALSE
	startWhen = 1
	announceWhen = 31 // minuta po pierwszym portalu
	endWhen = 901 // po 30 minutach portale gasną same
	/// Otwarte portale
	var/list/obj/structure/aquila_hex_demon_portal/portals = list()
	/// Wypuszczone stwory (weakrefy)
	var/list/datum/weakref/creature_refs = list()
	/// Czy otworzył się choć jeden portal
	var/opened = FALSE
	/// Ile stworów już wyszło
	var/total_spawned = 0
	/// Najwięcej portali naraz
	var/max_portals = 6
	/// Najwięcej żywych stworów inwazji naraz
	var/max_creatures = 12
	/// Najwięcej stworów w całej inwazji
	var/max_total_spawns = 30
	/// Co ile portal wypuszcza stwora
	var/spawn_interval = 45 SECONDS
	/// Co ile otwiera się nowy portal
	var/spread_interval = 3 MINUTES
	/// Kiedy otworzy się następny portal
	var/next_spread = 0
	/// Nazwa pomieszczenia z pierwszym portalem
	var/area_name

/datum/round_event/aquila_hex_demon_incursion/start()
	var/list/room = aquila_hex_room_turfs(2)
	if(!length(room))
		log_game("Demon Incursion: no safe room with free floor, cancelling the event.")
		return kill()
	var/turf/first = room[1]
	open_portal(first)
	var/turf/second = room[2]
	if(length(GLOB.player_list) >= 40 && get_dist(second, first) >= 3) // drugi portal przy dużej załodze, nie tuż obok
		open_portal(second)
	if(!opened)
		return kill()
	area_name = get_area_name(first, TRUE)
	for(var/obj/machinery/light/light in range(8, first))
		INVOKE_ASYNC(light, TYPE_PROC_REF(/obj/machinery/light, flicker))
	next_spread = world.time + spread_interval
	notify_ghosts("W [area_name] otwiera się portal z zaświatów!", source = first, action = NOTIFY_JUMP, flashwindow = FALSE, header = "Inwazja demonów")
	message_admins("Inwazja demonów zaczyna się w [ADMIN_VERBOSEJMP(first)].")
	log_game("Demon Incursion: [length(portals)] portals opened at [AREACOORD(first)].")

/datum/round_event/aquila_hex_demon_incursion/announce(fake)
	if(!length(portals))
		return
	priority_announce("Ogromny skok energii bluespace w: [area_name]. Na pokład przedzierają się intruzi z innego wymiaru. Zniszczcie wszystkie portale, zanim się rozmnożą.", "Alarm inwazji demonów", 'sound/magic/demon_dies.ogg')

/datum/round_event/aquila_hex_demon_incursion/tick()
	if(!opened)
		return
	if(!length(portals))
		minor_announce("Ostatni portal z zaświatów został zniszczony. Inwazja demonów odparta.", "Alarm inwazji demonów")
		log_game("Demon Incursion: every portal was destroyed.")
		kill()
		return
	for(var/obj/structure/aquila_hex_demon_portal/portal as anything in portals.Copy())
		if(world.time >= portal.next_spawn)
			portal_spawn(portal)
	if(world.time >= next_spread)
		spread()

/datum/round_event/aquila_hex_demon_incursion/end()
	if(length(portals))
		minor_announce("Energia zaświatów słabnie. Pozostałe portale gasną same.", "Alarm inwazji demonów")
	close_portals()
	aquila_hex_vanish_creatures(creature_refs)

/datum/round_event/aquila_hex_demon_incursion/kill()
	close_portals()
	aquila_hex_vanish_creatures(creature_refs)
	return ..()

/// Zamyka wszystkie portale
/datum/round_event/aquila_hex_demon_incursion/proc/close_portals()
	var/list/to_close = portals.Copy()
	portals.Cut()
	for(var/obj/structure/aquila_hex_demon_portal/portal as anything in to_close)
		portal.incursion = null
		if(!QDELETED(portal))
			qdel(portal)

/// Otwiera portal na polu; zwraca portal albo null, gdy osiągnięto limit portali
/datum/round_event/aquila_hex_demon_incursion/proc/open_portal(turf/spot)
	if(!isturf(spot) || length(portals) >= max_portals)
		return null
	var/obj/structure/aquila_hex_demon_portal/portal = new(spot, src)
	portal.next_spawn = world.time + rand(2, 6) SECONDS // pierwszy stwór od razu
	portals += portal
	opened = TRUE
	return portal

/// Portal wypuszcza stwora, jeśli inwazja nie wyczerpała limitów; zwraca stwora
/datum/round_event/aquila_hex_demon_incursion/proc/portal_spawn(obj/structure/aquila_hex_demon_portal/portal)
	portal.next_spawn = world.time + spawn_interval
	if(total_spawned >= max_total_spawns || living_creatures() >= max_creatures)
		return null
	var/static/list/creature_weights = list(
		/mob/living/basic/aquila_hellhound = 3,
		/mob/living/basic/skeleton = 3,
		/mob/living/basic/creature = 2,
		/mob/living/basic/migo = 2,
		/mob/living/basic/blankbody = 2,
		/mob/living/basic/faithless = 2,
	)
	var/mob/living/creature = aquila_hex_rift_spawn(get_turf(portal), pickweight(creature_weights))
	if(!creature)
		return null
	total_spawned++
	var/datum/weakref/creature_ref = WEAKREF(creature)
	creature_refs += creature_ref
	portal.creature_refs += creature_ref
	creature.visible_message("<span class='danger'>Z [portal] wyłania się [creature]!</span>")
	return creature

/// Ile stworów inwazji jeszcze żyje
/datum/round_event/aquila_hex_demon_incursion/proc/living_creatures()
	. = 0
	for(var/datum/weakref/creature_ref as anything in creature_refs)
		var/mob/living/creature = creature_ref.resolve()
		if(!QDELETED(creature) && creature.stat != DEAD)
			.++

/// Otwiera nowy portal do 6 pól od losowego portalu, w tym samym pomieszczeniu i w jego zasięgu wzroku (nie obok innego portalu), dopóki nie ma ich max_portals; zwraca portal
/datum/round_event/aquila_hex_demon_incursion/proc/spread()
	next_spread = world.time + spread_interval
	if(!length(portals) || length(portals) >= max_portals)
		return null
	var/obj/structure/aquila_hex_demon_portal/source = pick(portals)
	var/turf/source_turf = get_turf(source)
	if(!source_turf)
		return null
	var/area/source_area = get_area(source_turf)
	var/list/spots = list()
	for(var/turf/T as anything in RANGE_TURFS(6, source_turf))
		if(get_area(T) != source_area || !aquila_hex_free_safe_turf(T) || !aquila_hex_clear_line(source_turf, T, 6))
			continue
		var/too_close = FALSE
		for(var/obj/structure/aquila_hex_demon_portal/other as anything in portals)
			if(get_dist(other, T) < 3)
				too_close = TRUE
				break
		if(!too_close)
			spots += T
	if(!length(spots))
		return null
	var/obj/structure/aquila_hex_demon_portal/portal = open_portal(pick(spots))
	portal?.visible_message("<span class='danger'>Powietrze pęka i otwiera się kolejny [portal.name]!</span>")
	return portal

/// Wywoływane, gdy portal zostaje zniszczony
/datum/round_event/aquila_hex_demon_incursion/proc/portal_gone(obj/structure/aquila_hex_demon_portal/portal)
	portals -= portal

/// Portal z zaświatów: wypuszcza stwory inwazji, a zniszczony zabiera połowę z nich
/obj/structure/aquila_hex_demon_portal
	name = "demoniczny portal"
	desc = "Wirujące przejście do wymiaru, w którym nikt nie chciałby się znaleźć. Lepiej je zniszczyć, zanim przejdzie przez nie coś jeszcze."
	icon = 'icons/mob/nest.dmi'
	icon_state = "nether"
	color = "#ff3030"
	anchored = TRUE
	density = FALSE
	layer = BELOW_MOB_LAYER
	max_integrity = 150
	light_range = 4
	light_power = 2
	light_color = "#780606"
	/// Inwazja, do której należy portal
	var/datum/round_event/aquila_hex_demon_incursion/incursion
	/// Kiedy portal wypuści następnego stwora
	var/next_spawn = 0
	/// Stwory z tego portalu (weakrefy)
	var/list/datum/weakref/creature_refs = list()
	/// Czy portal zniszczyła załoga (bronią, narzędziem albo ogniem), a nie zamknął go koniec inwazji
	var/destroyed_by_crew = FALSE

/obj/structure/aquila_hex_demon_portal/Initialize(mapload, datum/round_event/aquila_hex_demon_incursion/new_incursion)
	. = ..()
	incursion = new_incursion
	playsound(src, 'sound/magic/enter_blood.ogg', 80, TRUE)

/obj/structure/aquila_hex_demon_portal/obj_destruction(damage_flag)
	destroyed_by_crew = TRUE
	return ..()

/obj/structure/aquila_hex_demon_portal/Destroy()
	if(destroyed_by_crew)
		take_creatures()
	incursion?.portal_gone(src)
	incursion = null
	creature_refs.Cut()
	return ..()

/// Zniszczony przez załogę portal zapada się i zabiera ze sobą połowę swoich stworów
/obj/structure/aquila_hex_demon_portal/proc/take_creatures()
	for(var/datum/weakref/creature_ref as anything in creature_refs)
		var/mob/living/creature = creature_ref.resolve()
		if(!QDELETED(creature) && creature.stat != DEAD && prob(50))
			creature.visible_message("<span class='danger'>[creature] rozpada się, gdy [src] się zamyka!</span>")
			creature.death()
	playsound(src, 'sound/magic/demon_dies.ogg', 80, TRUE)
	visible_message("<span class='notice'>[capitalize(name)] zapada się w sobie i znika.</span>")
