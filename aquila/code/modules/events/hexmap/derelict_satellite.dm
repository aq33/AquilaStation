// AQUILA - Porzucony satelita: kilka pól od burty okrętu zawisa wycofany satelita łączności; w EVA rozbiera się go kluczem i spawarką, a jego rdzeń danych daje punkty badań (port z BlueMoon-Labs/BlueMoon-Station modular_bluemoon/code/modules/events/minor_incidents/derelict_satellite.dm)
// BlueMoon finds the site with its own outside-the-hull helper and draws its own satellite and data core sprites.
// Ours finds a free space turf 4-8 turfs off a random side of the hull (our shared helpers), uses the meteor shield
// satellite and hard drive sprites we already have, and pays out the data core through our destructive analyzer
// (techweb point item, first core per techweb only, like anomaly cores) or cargo export. The salvage boards are
// telecomms and comms monitor boards like the original; the announcement text is written anew.

#define AQUILA_SATELLITE_INTACT 0
#define AQUILA_SATELLITE_UNBOLTED 1

/datum/round_event_control/aquila_hex_derelict_satellite
	name = "Porzucony satelita"
	typepath = /datum/round_event/aquila_hex_derelict_satellite
	weight = 10
	max_occurrences = 1
	earliest_start = 10 MINUTES

/datum/round_event/aquila_hex_derelict_satellite
	fakeable = FALSE
	startWhen = 1
	announceWhen = 2
	/// Satelita pojawił się w kosmosie
	var/placed = FALSE
	/// Pomieszczenie statku najbliższe satelicie
	var/near_area_name

/datum/round_event/aquila_hex_derelict_satellite/start()
	var/turf/spot = aquila_hex_space_spot_near_hull(4, 8)
	if(!spot)
		log_game("Derelict Satellite: no free space next to the hull, cancelling the event.")
		return kill()
	var/obj/structure/aquila_derelict_satellite/satellite = new(spot)
	placed = TRUE
	near_area_name = aquila_hex_nearest_ship_area_name(spot)
	announce_to_ghosts(satellite)
	log_game("Derelict Satellite: a satellite appeared at [AREACOORD(spot)].")

/datum/round_event/aquila_hex_derelict_satellite/announce(fake)
	if(!placed)
		return
	priority_announce("Wycofany satelita łączności NT-7 „Sroka” zszedł z orbity złomowej i zawisł przy burcie okrętu[near_area_name ? ", w pobliżu: [near_area_name]" : ""]. Sygnał GPS: „Satelita NT-7”. Prosimy rozebrać go na miejscu: kluczem zdjąć osłonę, spawarką rozciąć ramę. Rdzeń danych satelity zawiera telemetrię, którą dział naukowy odczyta w analizatorze destrukcyjnym; ładownia może go też sprzedać. Złom zostaje u was, w księgach Nanotrasen i tak jest już spisany na straty.", "Dział Utylizacji Mienia Orbitalnego Nanotrasen")

/// Wycofany satelita łączności w kosmosie przy kadłubie: osłona na śrubach, rama do rozcięcia, w środku rdzeń danych
/obj/structure/aquila_derelict_satellite
	name = "porzucony satelita łączności"
	desc = "Wycofany satelita łączności serii NT-7. Antena jeszcze się obraca na resztkach zasilania, ale nadajnik dawno zamilkł."
	icon = 'icons/obj/machines/satellite.dmi'
	icon_state = "sat_inactive"
	density = TRUE
	anchored = TRUE
	max_integrity = 200
	/// AQUILA_SATELLITE_INTACT albo AQUILA_SATELLITE_UNBOLTED
	var/stage = AQUILA_SATELLITE_INTACT
	/// Czas odkręcania osłony
	var/unbolt_time = 6 SECONDS
	/// Czas cięcia ramy
	var/cut_time = 8 SECONDS
	/// Płytki, z których jedna wypada przy rozbiórce
	var/static/list/salvage_boards = list(
		/obj/item/circuitboard/machine/telecomms/receiver,
		/obj/item/circuitboard/machine/telecomms/relay,
		/obj/item/circuitboard/computer/comm_monitor,
	)

/obj/structure/aquila_derelict_satellite/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/gps, "Satelita NT-7")

/obj/structure/aquila_derelict_satellite/examine(mob/user)
	. = ..()
	if(stage == AQUILA_SATELLITE_INTACT)
		. += "<span class='notice'>Osłona trzyma się na śrubach: można ją zdjąć kluczem.</span>"
	else
		. += "<span class='notice'>Osłona jest zdjęta, w środku widać rdzeń danych. Ramę można rozciąć spawarką.</span>"

/obj/structure/aquila_derelict_satellite/wrench_act(mob/living/user, obj/item/tool)
	if(stage != AQUILA_SATELLITE_INTACT)
		to_chat(user, "<span class='notice'>Osłona jest już zdjęta. Zostało rozciąć ramę spawarką.</span>")
		return TRUE
	to_chat(user, "<span class='notice'>Zaczynasz odkręcać śruby osłony satelity...</span>")
	if(tool.use_tool(src, user, unbolt_time, volume = 50) && !QDELETED(src))
		unbolt()
	return TRUE

/obj/structure/aquila_derelict_satellite/welder_act(mob/living/user, obj/item/tool)
	if(stage == AQUILA_SATELLITE_INTACT)
		to_chat(user, "<span class='warning'>Najpierw zdejmij osłonę kluczem, inaczej przetniesz rdzeń danych razem z nią.</span>")
		return TRUE
	if(!tool.tool_start_check(user, amount = 1))
		return TRUE
	to_chat(user, "<span class='notice'>Zaczynasz ciąć ramę satelity...</span>")
	if(tool.use_tool(src, user, cut_time, amount = 1, volume = 50) && !QDELETED(src))
		dismantle(user)
	return TRUE

/// Zdejmuje osłonę
/obj/structure/aquila_derelict_satellite/proc/unbolt()
	if(stage != AQUILA_SATELLITE_INTACT)
		return FALSE
	stage = AQUILA_SATELLITE_UNBOLTED
	visible_message("<span class='notice'>Osłona satelity odchodzi, odsłaniając ramę i rdzeń danych.</span>")
	return TRUE

/// Rozcina ramę: pełny odzysk i koniec satelity
/obj/structure/aquila_derelict_satellite/proc/dismantle(mob/living/user)
	if(stage != AQUILA_SATELLITE_UNBOLTED)
		return FALSE
	visible_message("<span class='notice'>Rama satelity rozpada się na części.</span>")
	log_game("Derelict Satellite: dismantled by [user ? key_name(user) : "nobody"] at [AREACOORD(src)].")
	drop_salvage(TRUE)
	qdel(src)
	return TRUE

/// Odzysk: blacha i rdzeń danych, przy pełnej rozbiórce także pręty i płytka
/obj/structure/aquila_derelict_satellite/proc/drop_salvage(full)
	var/turf/drop = drop_location()
	if(!drop)
		return
	new /obj/item/stack/sheet/iron(drop, 6)
	new /obj/item/aquila_satellite_data_core(drop)
	if(!full)
		return
	new /obj/item/stack/rods(drop, 4)
	var/board_type = pick(salvage_boards)
	new board_type(drop)

/obj/structure/aquila_derelict_satellite/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		drop_salvage(FALSE)
	qdel(src)

/// Rdzeń danych satelity: punkty badań w analizatorze destrukcyjnym albo eksport przez ładownię
/obj/item/aquila_satellite_data_core
	name = "rdzeń danych satelity"
	desc = "Zabezpieczony nośnik telemetrii z wycofanego satelity łączności."
	icon = 'icons/obj/module.dmi'
	icon_state = "harddisk"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/aquila_satellite_data_core/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Dział naukowy odczyta z niego telemetrię w analizatorze destrukcyjnym. Ładownia może go też sprzedać.</span>"

/datum/export/aquila_satellite_data_core
	cost = 500
	unit_name = "rdzeń danych satelity"
	export_types = list(/obj/item/aquila_satellite_data_core)

/datum/controller/subsystem/research/Initialize()
	techweb_point_items[/obj/item/aquila_satellite_data_core] = list(TECHWEB_POINT_TYPE_GENERIC = 3000)
	return ..()

#undef AQUILA_SATELLITE_INTACT
#undef AQUILA_SATELLITE_UNBOLTED
