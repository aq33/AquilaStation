// Statek złomiarzy: przerobiona kopia statku pirackiego (aquila/_maps/shuttles/salvager/salvager_default.dmm)
// z platformą skupu złomu i teleporterem zamiast lokalizatora łupów i zagłuszacza.
// FTL: z-level okrętu przy skoku się nie zmienia, więc statek złomiarzy „podczepia się” pod ślad FTL i zostaje w pobliżu.
// Na czas skoku prom złomiarzy nie może startować ani dokować.

// Osobny obszar (nie podtyp pirackiego), żeby cel piratów nie znalazł terminalu złomiarzy
/area/shuttle/salvager
	name = "Statek złomiarzy"
	requires_power = TRUE
	canSmoothWithAreas = /area/shuttle/salvager

/datum/map_template/shuttle/pirate/salvager
	suffix = "salvager"
	name = "statek złomiarzy"
	/// Plik szablonu wkompilowany w .rsc (deploy.sh nie kopiuje aquila/_maps na serwer)
	var/salvager_map = 'aquila/_maps/shuttles/salvager/salvager_default.dmm'

/datum/map_template/shuttle/pirate/salvager/New(path = null, rename = null, cache = FALSE, admin_load = null)
	return ..(path || salvager_map, rename, cache, admin_load)

/obj/docking_port/mobile/pirate/salvager
	name = "statek złomiarzy"
	id = "salvagership"

/obj/machinery/computer/shuttle_flight/pirate/salvager
	name = "konsola statku złomiarzy"
	shuttleId = "salvagership"
	possible_destinations = "salvagership_home;syndicate_n;syndicate_ne;syndicate_nw;syndicate_s;syndicate_se;syndicate_sw;syndicatecutter_n;syndicatecutter_ne;syndicatecutter_nw;syndicatecutter_s;syndicatecutter_se;syndicatecutter_sw"

/obj/machinery/computer/shuttle_flight/pirate/salvager/ui_act(action, params)
	if((action in list("move", "launch", "dock", "gotoPort", "setTarget", "setTargetCoords")) && salvager_main_ship_jumping())
		say("Okręt jest w skoku FTL. Trzymamy się jego śladu, start dopiero po wyjściu ze skoku.")
		return TRUE
	return ..()

/proc/salvager_main_ship_jumping()
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	return main?.ftl_drive?.ftl_state == FTL_STATE_JUMPING

///////////////////
// Skup złomu
///////////////////

/obj/machinery/computer/piratepad_control/salvage
	name = "terminal skupu złomu"
	desc = "Terminal platformy, która przerzuca złom do pośrednika. Ceny jak w eksporcie cargo, płytki i części według cennika złomiarzy."

// Złomiarze nie biorą okupu za ludzi: liczą się płytki, części i to, co kupuje eksport cargo
/obj/machinery/computer/piratepad_control/salvage/recalc()
	if(sending)
		return
	var/value = 0
	var/datum/export_report/ex = new
	for(var/atom/movable/AM in get_turf(pad))
		if(AM == pad || salvage_holds_living(AM))
			continue
		value += salvage_value(AM, TRUE)
		export_item_and_contents(AM, EXPORT_CARGO | EXPORT_CONTRABAND, apply_elastic = FALSE, dry_run = TRUE, external_report = ex)
	for(var/datum/export/E in ex.total_amount)
		value += ex.total_value[E]
	status_report = "Przewidywana wartość: [value] kr."

/obj/machinery/computer/piratepad_control/salvage/send()
	if(!sending)
		return
	var/value = 0
	var/datum/export_report/ex = new
	for(var/atom/movable/AM in get_turf(pad))
		if(AM == pad || salvage_holds_living(AM))
			continue
		value += salvage_value(AM, FALSE)
		if(!QDELETED(AM))
			export_item_and_contents(AM, EXPORT_CARGO | EXPORT_CONTRABAND, apply_elastic = FALSE, delete_unsold = FALSE, external_report = ex)
	for(var/datum/export/E in ex.total_amount)
		value += ex.total_value[E]
	if(!total_report)
		total_report = ex
	points += value
	status_report = value ? "Sprzedano złom za [value] kr." : "Nic tu nie ma wartości."
	pad.visible_message("<span class='notice'>[pad] się aktywuje!</span>")
	flick(pad.sending_state, pad)
	pad.icon_state = pad.idle_state
	sending = FALSE
	ui_update()

/// Wartość płytek i części maszyn (rzecz i to, co w niej leży); przy sprzedaży usuwa je z platformy
/obj/machinery/computer/piratepad_control/salvage/proc/salvage_value(atom/movable/AM, dry_run)
	. = 0
	var/list/things = AM.GetAllContents()
	for(var/atom/movable/thing as anything in things)
		var/price = salvage_price(thing)
		if(!price)
			continue
		. += price
		if(!dry_run)
			qdel(thing)

/// Istota albo pojemnik z istotą w środku: ani wyceny, ani sprzedaży (także jej wyposażenia)
/proc/salvage_holds_living(atom/movable/AM)
	for(var/atom/movable/thing as anything in AM.GetAllContents())
		if(isliving(thing))
			return TRUE
	return FALSE

/proc/salvage_price(atom/movable/thing)
	if(istype(thing, /obj/item/circuitboard/machine))
		return 250
	if(istype(thing, /obj/item/circuitboard/computer))
		return 200
	if(istype(thing, /obj/item/circuitboard))
		return 100
	if(istype(thing, /obj/item/stock_parts/cell))
		return 0 // ogniwa ma już eksport cargo
	if(istype(thing, /obj/item/stock_parts))
		var/obj/item/stock_parts/part = thing
		return 25 * part.rating
	if(istype(thing, /obj/structure/frame))
		return 50
	return 0
