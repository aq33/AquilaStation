// AQUILA - ekstraktor gazu: wydobywa gaz ze złoża (gas_vein.dm) do rury. Pomysł z Frontiera
// (new-frontiers-14/frontier-station-14, GasDepositExtractor: 50 mol/s, do ustawionego ciśnienia, 1 kW, ×1,2 na poziom
// manipulatora), napisany od nowa jako nasze urządzenie rurowe na wzór termomaszyny (płytka z warstwą rury, klucz
// obraca wylot przy otwartym panelu). Ikona: syfon z icons/obj/atmos.dmi.
// Stawia się go z płytki w ramie maszyny ustawionej na złożu. Gaz wychodzi jednym wylotem do zwykłej rury (dalej port
// i kanister albo sieć okrętu), do 4500 kPa. Zasilanie 1 kW: z sieci obszaru, a bez niej (planety nie mają APC)
// z ogniwa wkładanego przy otwartym panelu, jak w wiertle. Póki pracuje, złoże otwiera wyrwy z fauną jak żyła rudy.
// Zmiany względem Frontiera: nie da się go przeciągać (to urządzenie rurowe), bez interfejsu ciśnienia (stałe
// 4500 kPa, jak syfon olbrzyma), wyczerpane złoże się zapada.

/obj/machinery/atmospherics/components/unary/gas_extractor
	name = "ekstraktor gazu"
	desc = "Pompa wwiercana w złoże gazu, która tłoczy wydobyty gaz do podłączonej rury. Pracuje z sieci albo z ogniwa, a wstrząsy, które wywołuje, rozwścieczają okoliczną faunę."
	icon = 'icons/obj/atmos.dmi'
	icon_state = "siphon:0"
	color = "#e8d9a0"
	density = TRUE
	max_integrity = 300
	layer = OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/gas_extractor
	use_power = NO_POWER_USE
	processing_flags = NONE
	active_power_usage = 1000
	resistance_flags = FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	armor = list("melee" = 30, "bullet" = 20, "laser" = 20, "energy" = 100, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 70, "stamina" = 0, "bleed" = 0)
	/// Złoże pod ekstraktorem
	var/obj/structure/vein/gas/our_vein
	/// Właśnie tłoczy gaz (włączony, ma złoże, prąd i miejsce w rurze)
	var/extracting = FALSE
	/// Ile moli na sekundę (50 × 1,2^(poziom manipulatora - 1))
	var/extraction_rate = 50
	/// Do jakiego ciśnienia tłoczy (kPa)
	var/target_pressure = 4500
	var/obj/item/stock_parts/cell/cell
	/// Ostatni powód postoju (do oględzin)
	var/status_text = "wyłączony"

/obj/machinery/atmospherics/components/unary/gas_extractor/Initialize(mapload)
	. = ..()
	initialize_directions = dir
	RefreshParts()
	link_vein()
	update_icon()

/obj/machinery/atmospherics/components/unary/gas_extractor/Destroy()
	release_vein()
	QDEL_NULL(cell)
	return ..()

/obj/machinery/atmospherics/components/unary/gas_extractor/on_construction()
	var/obj/item/circuitboard/machine/gas_extractor/board = circuit
	if(board)
		piping_layer = board.pipe_layer
	. = ..(dir, piping_layer)
	link_vein()

/obj/machinery/atmospherics/components/unary/gas_extractor/on_deconstruction()
	if(cell)
		cell.forceMove(drop_location())
		cell = null
	return ..()

/obj/machinery/atmospherics/components/unary/gas_extractor/RefreshParts()
	var/manipulator_rating = 1
	for(var/obj/item/stock_parts/manipulator/manipulator in component_parts)
		manipulator_rating = max(manipulator_rating, manipulator.rating)
	extraction_rate = 50 * (1.2 ** (manipulator_rating - 1))

/obj/machinery/atmospherics/components/unary/gas_extractor/examine(mob/user)
	. = ..()
	. += span_notice("Stan: [status_text]. Wydobycie [round(extraction_rate, 0.1)] mol/s, do [target_pressure] kPa.")
	if(our_vein)
		. += span_notice("W złożu zostało [round(our_vein.remaining_moles())] moli gazu.")
	else
		. += span_warning("Nie stoi na złożu gazu: rama musi stanąć na złożu.")
	. += cell ? span_notice("Ogniwo: [round(cell.percent())]%.") : span_notice("Bez ogniwa: pracuje tylko z sieci obszaru.")
	. += span_notice("Włącza się go ręką. Przy otwartym panelu klucz obraca wylot, a łom wyjmuje ogniwo.")

/obj/machinery/atmospherics/components/unary/gas_extractor/update_icon()
	cut_overlays()
	if(panel_open)
		icon_state = "siphon-open"
	else
		icon_state = "siphon:[extracting ? 1 : 0]"
	add_overlay(get_pipe_image('icons/obj/atmospherics/components/thermomachine.dmi', "pipe", dir, , piping_layer))

/obj/machinery/atmospherics/components/unary/gas_extractor/interact(mob/user)
	. = ..()
	if(panel_open)
		to_chat(user, span_warning("Najpierw zamknij panel."))
		return
	on = !on
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	to_chat(user, span_notice("[on ? "Włączasz" : "Wyłączasz"] [src]."))
	investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)
	if(on)
		begin_processing()
	else
		set_extracting(FALSE, "wyłączony")

/obj/machinery/atmospherics/components/unary/gas_extractor/attackby(obj/item/tool, mob/user, params)
	if(!on && default_deconstruction_screwdriver(user, "siphon-open", "siphon:0", tool))
		change_pipe_connection(panel_open)
		update_icon()
		return
	if(default_change_direction_wrench(user, tool))
		return
	if(panel_open && istype(tool, /obj/item/stock_parts/cell))
		if(cell)
			to_chat(user, span_warning("W ekstraktorze już jest ogniwo!"))
			return
		if(!user.transferItemToLoc(tool, src))
			return
		cell = tool
		to_chat(user, span_notice("Wkładasz ogniwo do ekstraktora."))
		return
	if(panel_open && tool.tool_behaviour == TOOL_CROWBAR && cell)
		cell.update_icon()
		cell.forceMove(drop_location())
		user.put_in_hands(cell)
		cell = null
		to_chat(user, span_notice("Wyjmujesz ogniwo z ekstraktora."))
		return
	if(default_deconstruction_crowbar(tool))
		return
	return ..()

/obj/machinery/atmospherics/components/unary/gas_extractor/default_change_direction_wrench(mob/user, obj/item/tool)
	if(!..())
		return FALSE
	set_init_directions()
	update_icon()
	return TRUE

/obj/machinery/atmospherics/components/unary/gas_extractor/process(delta_time)
	if(!on)
		set_extracting(FALSE, "wyłączony")
		return PROCESS_KILL
	if(panel_open || (machine_stat & BROKEN))
		set_extracting(FALSE, "otwarty panel albo uszkodzenie")
		return
	if(!our_vein && !link_vein())
		set_extracting(FALSE, "brak złoża gazu pod spodem")
		return
	var/datum/gas_mixture/air = airs[1]
	var/pressure = air.return_pressure()
	if(pressure >= target_pressure)
		set_extracting(FALSE, "rura pełna ([round(pressure)] kPa)")
		return
	if(!draw_power())
		set_extracting(FALSE, "brak zasilania")
		return
	// Nie więcej, niż zmieści się do docelowego ciśnienia w samym urządzeniu
	var/room_moles = (target_pressure - pressure) * air.return_volume() / (R_IDEAL_GAS_EQUATION * max(our_vein.gas_temperature, TCMB))
	var/datum/gas_mixture/taken = our_vein.take_gas(min(extraction_rate * delta_time, room_moles))
	if(taken)
		air.merge(taken)
		if(parents[1])
			update_parents()
	set_extracting(TRUE, "wydobywa gaz")
	if(our_vein.remaining_moles() < 1)
		say("Złoże wyczerpane. Wyłączam się.")
		on = FALSE
		var/obj/structure/vein/gas/empty_vein = our_vein
		set_extracting(FALSE, "złoże wyczerpane")
		empty_vein.collapse()

/// Bierze 1 kW na cykl: z sieci obszaru, a bez niej z ogniwa. FALSE, gdy prądu nie ma.
/obj/machinery/atmospherics/components/unary/gas_extractor/proc/draw_power()
	var/area/our_area = get_area(src)
	if(our_area?.powered(power_channel))
		use_power(active_power_usage)
		return TRUE
	return cell?.use(active_power_usage * GLOB.CELLRATE)

/// Przełącza wydobycie; z nim złoże otwiera albo zamyka wyrwy z fauną
/obj/machinery/atmospherics/components/unary/gas_extractor/proc/set_extracting(new_state, reason)
	if(reason)
		status_text = reason
	if(extracting == new_state)
		return
	extracting = new_state
	if(extracting)
		our_vein?.begin_spawning()
	else
		our_vein?.stop_spawning()
	update_icon()

/// Przypina się do złoża pod sobą. TRUE, jeśli stoi na wolnym złożu.
/obj/machinery/atmospherics/components/unary/gas_extractor/proc/link_vein()
	if(our_vein)
		return TRUE
	var/obj/structure/vein/gas/vein = locate() in loc
	if(!vein || vein.our_extractor)
		return FALSE
	our_vein = vein
	vein.our_extractor = src
	return TRUE

/obj/machinery/atmospherics/components/unary/gas_extractor/proc/release_vein()
	if(!our_vein)
		return
	set_extracting(FALSE)
	our_vein.our_extractor = null
	our_vein = null

/// Złoże zniknęło spod ekstraktora
/obj/machinery/atmospherics/components/unary/gas_extractor/proc/on_vein_gone()
	set_extracting(FALSE, "brak złoża gazu pod spodem")
	our_vein = null

/obj/item/circuitboard/machine/gas_extractor
	name = "ekstraktor gazu (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/atmospherics/components/unary/gas_extractor
	var/pipe_layer = PIPING_LAYER_DEFAULT
	req_components = list(
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stack/sheet/plasteel = 2,
	)

/obj/item/circuitboard/machine/gas_extractor/multitool_act(mob/living/user, obj/item/multitool/I)
	. = ..()
	if(istype(I))
		pipe_layer = (pipe_layer >= PIPING_LAYER_MAX) ? PIPING_LAYER_MIN : (pipe_layer + 1)
		to_chat(user, span_notice("Zmieniasz warstwę płytki na [pipe_layer]."))

/obj/item/circuitboard/machine/gas_extractor/examine(mob/user)
	. = ..()
	. += span_notice("Ustawiona na warstwę [pipe_layer]. Ramę maszyny postaw na złożu gazu.")

/datum/design/board/gas_extractor
	name = "Projekt maszyny (ekstraktor gazu)"
	desc = "Płytka do budowy ekstraktora, który wydobywa gaz ze złóż na planetach i asteroidach do rury."
	id = "aquila_gas_extractor"
	build_path = /obj/item/circuitboard/machine/gas_extractor
	category = list("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/techweb_node/engineering/New()
	. = ..()
	design_ids += "aquila_gas_extractor"

/datum/supply_pack/engineering/gas_extractor
	name = "Ekstraktor gazu"
	desc = "Płytka ekstraktora gazu z kompletem części, kablem, plastalą i pojemnym ogniwem. Ramę maszyny trzeba postawić na złożu gazu (znajdzie je georadarowy skaner), a gaz odebrać rurą."
	cost = 2000
	contains = list(
		/obj/item/circuitboard/machine/gas_extractor,
		/obj/item/stock_parts/manipulator,
		/obj/item/stock_parts/matter_bin,
		/obj/item/stack/cable_coil,
		/obj/item/stack/sheet/plasteel/five,
		/obj/item/stock_parts/cell/high,
	)
	crate_name = "skrzynia ekstraktora gazu"
	crate_type = /obj/structure/closet/crate/engineering
