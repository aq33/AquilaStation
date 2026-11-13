// AQUILA - Mechanik: czytnik schematów (odpowiednik Ruckingenur kit z Goona, napisany od nowa).
// Bierze skany ze skanera, czyta je po kolei i wpisuje do bazy schematów techwebu, którą widzą wszystkie flatpackery.

/obj/machinery/schematic_reader
	name = "czytnik schematów"
	desc = "Odczytuje skany maszyn i wpisuje schematy do bazy sieci badań. Każdy flatpacker podłączony do tej sieci może potem robić paczki z tymi maszynami."
	icon = 'aquila/icons/obj/mechanic/schematic_reader.dmi'
	icon_state = "reader"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 500
	layer = BELOW_OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/schematic_reader
	/// Sieć badań, do której trafiają schematy
	var/datum/techweb/stored_research
	/// Skany czekające na odczyt
	var/list/datum/machine_schematic/queue = list()
	/// Skan czytany teraz
	var/datum/machine_schematic/current
	/// Kiedy skończy się bieżący odczyt i ile trwa
	var/read_end_time = 0
	var/read_duration = 0
	/// Średni tier modułów skanujących, skraca odczyt
	var/scan_rating = 1
	var/read_timer

/obj/machinery/schematic_reader/Initialize(mapload)
	. = ..()
	stored_research = SSresearch.science_tech

/obj/machinery/schematic_reader/Destroy()
	if(read_timer)
		deltimer(read_timer)
	QDEL_NULL(current)
	QDEL_LIST(queue)
	stored_research = null
	return ..()

/obj/machinery/schematic_reader/RefreshParts()
	var/total = 0
	var/count = 0
	for(var/obj/item/stock_parts/scanning_module/module in component_parts)
		total += module.rating
		count++
	scan_rating = count ? total / count : 1

/obj/machinery/schematic_reader/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>Wyświetlacz stanu pokazuje: czas odczytu <b>[round(100 / scan_rating)]%</b>, w kolejce [length(queue)] skanów.</span>"
		if(stored_research)
			. += "<span class='notice'>W bazie sieci badań jest [length(stored_research.machine_schematics)] schematów.</span>"

/obj/machinery/schematic_reader/update_icon_state()
	if(panel_open)
		icon_state = "reader_open"
	else if(current && is_operational)
		icon_state = "reader_working"
	else
		icon_state = "reader"
	return ..()

/obj/machinery/schematic_reader/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/machine_scanner))
		upload_scans(I, user)
		return TRUE
	if(!current && default_deconstruction_screwdriver(user, "reader_open", "reader", I))
		update_appearance()
		return TRUE
	if(default_deconstruction_crowbar(I))
		return TRUE
	return ..()

/// Przenosi skany ze skanera do kolejki; pomija schematy, które już są w bazie albo w kolejce
/obj/machinery/schematic_reader/proc/upload_scans(obj/item/machine_scanner/scanner, mob/user)
	if(!length(scanner.scans))
		to_chat(user, "<span class='warning'>Skaner nie ma zapisanych skanów.</span>")
		return 0
	var/added = 0
	var/skipped = 0
	for(var/datum/machine_schematic/schematic as anything in scanner.scans)
		if(is_known(schematic.get_key()))
			skipped++
			continue
		queue += schematic.copy()
		added++
	QDEL_LIST(scanner.scans)
	to_chat(user, "<span class='notice'>Wgrywasz skany do [src]: nowe [added], znane [skipped].</span>")
	if(added)
		start_next()
	return added

/// TRUE, jeśli schemat jest już w bazie, w kolejce albo właśnie czytany
/obj/machinery/schematic_reader/proc/is_known(key)
	if(stored_research?.machine_schematics[key])
		return TRUE
	if(current?.get_key() == key)
		return TRUE
	for(var/datum/machine_schematic/queued as anything in queue)
		if(queued.get_key() == key)
			return TRUE
	return FALSE

/// Czas odczytu schematu: wyższy tier części czyta się dłużej, lepsze moduły skanujące przyspieszają
/obj/machinery/schematic_reader/proc/read_time(datum/machine_schematic/schematic)
	return round((8 SECONDS + 4 SECONDS * schematic.tier) / max(scan_rating, 1))

/obj/machinery/schematic_reader/proc/start_next()
	if(current || !length(queue) || !is_operational)
		return
	current = queue[1]
	queue.Cut(1, 2)
	read_duration = read_time(current)
	read_end_time = world.time + read_duration
	use_power = ACTIVE_POWER_USE
	read_timer = addtimer(CALLBACK(src, PROC_REF(finish_reading)), read_duration, TIMER_STOPPABLE)
	update_appearance()

/obj/machinery/schematic_reader/proc/finish_reading()
	read_timer = null
	if(!current)
		return
	var/datum/machine_schematic/done = current
	current = null
	if(stored_research?.add_machine_schematic(done))
		say("Odczytano schemat: [done.display_name()].")
	else
		qdel(done)
	use_power = IDLE_POWER_USE
	update_appearance()
	start_next()

/obj/machinery/schematic_reader/power_change()
	. = ..()
	if(is_operational)
		start_next()
	else
		pause_reading()

/// Bez prądu bieżący skan wraca na początek kolejki i czeka na zasilanie
/obj/machinery/schematic_reader/proc/pause_reading()
	if(!current)
		return
	if(read_timer)
		deltimer(read_timer)
		read_timer = null
	queue.Insert(1, current)
	current = null
	use_power = IDLE_POWER_USE
	update_appearance()

/obj/machinery/schematic_reader/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SchematicReader")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/schematic_reader/ui_data(mob/user)
	var/list/data = list()
	data["current"] = current?.display_name()
	data["progress"] = current && read_duration ? clamp(1 - (read_end_time - world.time) / read_duration, 0, 1) : 0
	var/list/queued = list()
	for(var/datum/machine_schematic/schematic as anything in queue)
		queued += schematic.display_name()
	data["queue"] = queued
	var/list/known = list()
	for(var/key in stored_research?.machine_schematics)
		var/datum/machine_schematic/schematic = stored_research.machine_schematics[key]
		known += list(list(
			"name" = schematic.name,
			"tier" = schematic.tier,
			"illegal" = schematic.illegal,
		))
	data["known"] = known
	return data

/obj/item/circuitboard/machine/schematic_reader
	name = "czytnik schematów (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/schematic_reader
	req_components = list(
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1)
