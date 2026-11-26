// AQUILA - Krystalizator (plan maszynowni E14), port z Yogstation
// (code/modules/atmospherics/machinery/components/gas_recipe_machines/crystallizer.dm), okno z tg (Crystallizer.tsx).
// Urządzenie dwururowe: zielona rura (strona dir) to wlot gazów receptury, czerwona (przeciwna) to obieg
// chłodzący albo grzejący. Gaz z wlotu trafia do wnętrza, wymienia ciepło z obiegiem, a trzymany w oknie
// temperatury receptury zamienia się w przedmiot. Im bliżej środka okna, tym mniej gazu idzie w straty.
// Różnice względem Yoga: receptury tylko na naszych gazach (crystallizer_recipes.dm), wymagania do okna idą
// jako dane (tekst składa okno, więc tłumaczy się po stronie TSX), jakość w nazwie tylko dla przedmiotów,
// które nie są stosem (stos z przymiotnikiem nie łączyłby się nazwą z resztą). Ikony z tg
// (icons/obj/machines/atmospherics/machines.dmi, CC-BY-SA 3.0).

#define CRYSTALLIZER_MIN_PROGRESS_AMOUNT 3
#define CRYSTALLIZER_MIN_DEVIATION_RATE 0.90
#define CRYSTALLIZER_MAX_DEVIATION_RATE 1.1
#define CRYSTALLIZER_HIGH_CONDUCTIVITY_RATIO 0.95

/obj/machinery/atmospherics/components/binary/crystallizer
	name = "krystalizator"
	desc = "Zamienia gazy w kryształy i ciała stałe. Zielona rura doprowadza gazy receptury, czerwona chłodzi albo grzeje wnętrze."
	icon = 'aquila/icons/obj/atmospherics/crystallizer.dmi'
	icon_state = "crystallizer-off"
	layer = ABOVE_MOB_LAYER
	density = TRUE
	max_integrity = 300
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 100, "rad" = 100, "fire" = 80, "acid" = 30, "stamina" = 0, "bleed" = 0)
	circuit = /obj/item/circuitboard/machine/crystallizer
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	idle_power_usage = 50
	active_power_usage = 500

	/// Bazowy stan ikony
	var/base_icon = "crystallizer"
	/// Wewnętrzna mieszanka, w której gazy się krystalizują
	var/datum/gas_mixture/internal
	/// Ile moli każdego gazu receptury wpuszczać z wlotu na tik
	var/gas_input = 0
	/// Górna granica gas_input
	var/max_gas_input = 250
	/// Postęp bieżącego przedmiotu, 0–100
	var/progress_bar = 0
	/// Utracona jakość (więcej = więcej gazu w straty i gorsza nazwa)
	var/quality_loss = 0
	/// Wybrana receptura
	var/datum/gas_recipe/selected_recipe = null
	/// Suma moli potrzebnych na jeden przedmiot wybranej receptury
	var/total_recipe_moles = 0

/obj/machinery/atmospherics/components/binary/crystallizer/Initialize(mapload)
	. = ..()
	internal = new

/obj/machinery/atmospherics/components/binary/crystallizer/Destroy()
	selected_recipe = null
	QDEL_NULL(internal)
	return ..()

/obj/machinery/atmospherics/components/binary/crystallizer/attackby(obj/item/I, mob/user, params)
	if(!on)
		if(default_deconstruction_screwdriver(user, "[base_icon]-open", "[base_icon]-off", I))
			return
	if(default_change_direction_wrench(user, I))
		return
	if(default_deconstruction_crowbar(I))
		return
	return ..()

/obj/machinery/atmospherics/components/binary/crystallizer/default_change_direction_wrench(mob/user, obj/item/I)
	if(!..())
		return FALSE
	disconnect_nodes()
	set_init_directions()
	connect_nodes()
	update_icon()
	return TRUE

/obj/machinery/atmospherics/components/binary/crystallizer/update_icon()
	cut_overlays()
	if(panel_open)
		icon_state = "[base_icon]-open"
	else if(on && is_operational)
		icon_state = "[base_icon]-on"
	else
		icon_state = "[base_icon]-off"
	add_overlay(get_pipe_image(icon, "pipe", dir, COLOR_LIME, piping_layer))
	add_overlay(get_pipe_image(icon, "pipe", turn(dir, 180), COLOR_RED, piping_layer))

/obj/machinery/atmospherics/components/binary/crystallizer/power_change()
	. = ..()
	update_icon()

/obj/machinery/atmospherics/components/binary/crystallizer/AltClick(mob/user)
	if(!can_interact(user))
		return
	set_on(!on)
	investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)

/obj/machinery/atmospherics/components/binary/crystallizer/set_on(active)
	. = ..()
	use_power = on ? ACTIVE_POWER_USE : IDLE_POWER_USE

/// Czy na wlocie albo we wnętrzu jest każdy gaz receptury
/obj/machinery/atmospherics/components/binary/crystallizer/proc/check_gas_requirements()
	var/datum/gas_mixture/contents = airs[2]
	for(var/gas_type in selected_recipe.requirements)
		if(!contents.get_moles(gas_type) && !internal.get_moles(gas_type))
			return FALSE
	return TRUE

/// Czy wnętrze mieści się w oknie temperatury receptury (z małym zapasem)
/obj/machinery/atmospherics/components/binary/crystallizer/proc/check_temp_requirements()
	var/temperature = internal.return_temperature()
	return temperature >= selected_recipe.min_temp * CRYSTALLIZER_MIN_DEVIATION_RATE && temperature <= selected_recipe.max_temp * CRYSTALLIZER_MAX_DEVIATION_RATE

/// Wpuszcza z wlotu do wnętrza po gas_input moli każdego gazu receptury
/obj/machinery/atmospherics/components/binary/crystallizer/proc/inject_gases()
	var/datum/gas_mixture/contents = airs[2]
	for(var/gas_type in selected_recipe.requirements)
		var/filtered_amount = min(gas_input, contents.get_moles(gas_type))
		if(filtered_amount <= 0)
			continue
		var/datum/gas_mixture/filtered = new
		filtered.set_temperature(contents.return_temperature())
		filtered.set_moles(gas_type, filtered_amount)
		contents.adjust_moles(gas_type, -filtered_amount)
		internal.merge(filtered)

/// Czy we wnętrzu jest już cały gaz na jeden przedmiot
/obj/machinery/atmospherics/components/binary/crystallizer/proc/internal_check()
	for(var/gas_type in selected_recipe.requirements)
		if(internal.get_moles(gas_type) < selected_recipe.requirements[gas_type])
			return FALSE
	return TRUE

/// Ciepło reakcji i jakość: blisko krawędzi okna jakość spada, blisko środka rośnie
/obj/machinery/atmospherics/components/binary/crystallizer/proc/heat_calculations()
	var/progress_amount_to_quality = CRYSTALLIZER_MIN_PROGRESS_AMOUNT * 4.5 / (round(log(10, total_recipe_moles * 0.1), 0.01))
	var/temperature = internal.return_temperature()

	if((temperature >= (selected_recipe.min_temp * CRYSTALLIZER_MIN_DEVIATION_RATE) && temperature <= selected_recipe.min_temp) || \
		(temperature >= selected_recipe.max_temp && temperature <= (selected_recipe.max_temp * CRYSTALLIZER_MAX_DEVIATION_RATE)))
		quality_loss = min(quality_loss + progress_amount_to_quality, 100)

	var/median_temperature = (selected_recipe.max_temp + selected_recipe.min_temp) / 2
	if(temperature >= (median_temperature * CRYSTALLIZER_MIN_DEVIATION_RATE) && temperature <= (median_temperature * CRYSTALLIZER_MAX_DEVIATION_RATE))
		quality_loss = max(quality_loss - progress_amount_to_quality, -85)

	internal.set_temperature(max(temperature + (selected_recipe.energy_release / internal.heat_capacity()), TCMB))

/// Wymiana ciepła między wnętrzem a obiegiem chłodzącym (czerwona rura)
/obj/machinery/atmospherics/components/binary/crystallizer/proc/heat_conduction()
	var/datum/gas_mixture/cooling_port = airs[1]
	if(cooling_port.total_moles() <= MINIMUM_MOLE_COUNT || internal.total_moles() <= 0)
		return
	var/coolant_temperature_delta = cooling_port.return_temperature() - internal.return_temperature()
	var/cooling_heat_capacity = cooling_port.heat_capacity()
	var/internal_heat_capacity = internal.heat_capacity()
	var/cooling_heat_amount = CRYSTALLIZER_HIGH_CONDUCTIVITY_RATIO * coolant_temperature_delta * (cooling_heat_capacity * internal_heat_capacity / (cooling_heat_capacity + internal_heat_capacity))
	cooling_port.set_temperature(max(cooling_port.return_temperature() - cooling_heat_amount / cooling_heat_capacity, TCMB))
	internal.set_temperature(max(internal.return_temperature() + cooling_heat_amount / internal_heat_capacity, TCMB))

/obj/machinery/atmospherics/components/binary/crystallizer/proc/moles_calculations()
	var/amounts = 0
	for(var/gas_type in selected_recipe.requirements)
		amounts += selected_recipe.requirements[gas_type]
	total_recipe_moles = amounts

/// Oddaje gaz z wnętrza z powrotem na wlot (przy zmianie receptury)
/obj/machinery/atmospherics/components/binary/crystallizer/proc/dump_gases()
	var/datum/gas_mixture/remove = internal.remove(internal.total_moles())
	var/datum/gas_mixture/contents = airs[2]
	contents.merge(remove)

/obj/machinery/atmospherics/components/binary/crystallizer/process_atmos()
	if(!on || !is_operational || !selected_recipe)
		return

	inject_gases()

	if(!internal.total_moles())
		update_parents()
		return

	heat_conduction()

	if(internal_check())
		if(check_temp_requirements())
			heat_calculations()
			progress_bar = min(progress_bar + (CRYSTALLIZER_MIN_PROGRESS_AMOUNT * 5 / (round(log(10, total_recipe_moles * 0.1), 0.01))), 100)
		else
			quality_loss = min(quality_loss + 0.5, 100)
			progress_bar = max(progress_bar - 1, 0)
	if(progress_bar != 100)
		update_parents()
		return
	finish_product()
	update_parents()

/// Zużywa gaz (z naddatkiem za utraconą jakość) i tworzy przedmioty receptury pod maszyną od południa
/obj/machinery/atmospherics/components/binary/crystallizer/proc/finish_product()
	progress_bar = 0
	for(var/gas_type in selected_recipe.requirements)
		var/required_gas_moles = selected_recipe.requirements[gas_type]
		var/amount_consumed = required_gas_moles + (required_gas_moles * (quality_loss * 0.01))
		if(internal.get_moles(gas_type) < amount_consumed)
			quality_loss = min(quality_loss + 10, 100)
		internal.adjust_moles(gas_type, -min(amount_consumed, internal.get_moles(gas_type)))

	var/quality_prefix = crystallizer_quality_name(clamp(50 - quality_loss, 0, 100))
	var/turf/output_turf = get_step(src, SOUTH) || get_turf(src)
	. = list()
	for(var/path in selected_recipe.products)
		for(var/i in 1 to selected_recipe.products[path])
			var/atom/movable/creation = new path(output_turf)
			. += creation
			if(!isstack(creation))
				creation.name = "[quality_prefix] [creation.name]"
			if(istype(creation, /obj/machinery/power/supermatter_crystal))
				var/obj/machinery/power/supermatter_crystal/crystal = creation
				crystal.crystallized = TRUE
			if(selected_recipe.dangerous)
				investigate_log("[selected_recipe.name] has been created in the crystallizer.", INVESTIGATE_ENGINES)
				message_admins("Krystalizator wytworzył: [selected_recipe.name] [ADMIN_JMP(src)].")
	quality_loss = 0

/// Przymiotnik jakości (rodzaj męski: wszystkie produkty to diament, arkusz, pellet, kryształ, odłamek)
/proc/crystallizer_quality_name(total_quality)
	switch(total_quality)
		if(100)
			return "mistrzowski"
		if(95 to 99)
			return "znakomity"
		if(75 to 94)
			return "dobry"
		if(65 to 74)
			return "przyzwoity"
		if(55 to 64)
			return "przeciętny"
		if(35 to 54)
			return "znośny"
		if(15 to 34)
			return "słaby"
		if(5 to 14)
			return "brzydki"
		if(1 to 4)
			return "pęknięty"
	return "fatalny"

/obj/machinery/atmospherics/components/binary/crystallizer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Crystallizer", name)
		ui.open()
		ui.set_autoupdate(TRUE) // postęp, temperatura i gazy zmieniają się co tik

/obj/machinery/atmospherics/components/binary/crystallizer/ui_static_data(mob/user)
	var/list/data = list()
	var/list/recipes = list()
	for(var/recipe_id in GLOB.gas_recipe_meta)
		var/datum/gas_recipe/recipe = GLOB.gas_recipe_meta[recipe_id]
		if(recipe.machine_type != "Crystallizer")
			continue
		var/list/requirements = list()
		for(var/gas_type in recipe.requirements)
			requirements += list(list(
				"id" = gas_type,
				"name" = GLOB.gas_data.names[gas_type],
				"amount" = recipe.requirements[gas_type],
			))
		recipes += list(list(
			"id" = recipe.id,
			"name" = recipe.name,
			"min_temp" = recipe.min_temp,
			"max_temp" = recipe.max_temp == INFINITY ? null : recipe.max_temp, // INFINITY nie przechodzi przez JSON
			"energy_release" = recipe.energy_release,
			"requirements" = requirements,
		))
	data["recipes"] = recipes
	data["max_gas_input"] = max_gas_input
	return data

/obj/machinery/atmospherics/components/binary/crystallizer/ui_data(mob/user)
	var/list/data = list()
	data["on"] = on
	data["selected"] = selected_recipe ? selected_recipe.id : ""
	var/list/internal_gas_data = list()
	for(var/gas_id in internal.get_gases())
		internal_gas_data += list(list(
			"id" = gas_id,
			"name" = GLOB.gas_data.names[gas_id],
			"amount" = round(internal.get_moles(gas_id), 0.01),
		))
	data["internal_gas_data"] = internal_gas_data
	data["internal_temperature"] = internal.total_moles() ? internal.return_temperature() : 0
	data["progress_bar"] = progress_bar
	data["gas_input"] = gas_input
	return data

/obj/machinery/atmospherics/components/binary/crystallizer/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			set_on(!on)
			investigate_log("was turned [on ? "on" : "off"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			return TRUE
		if("recipe")
			select_recipe(GLOB.gas_recipe_meta[params["mode"]])
			investigate_log("was set to recipe [selected_recipe ? selected_recipe.id : "nothing"] by [key_name(usr)]", INVESTIGATE_ATMOS)
			return TRUE
		if("gas_input")
			gas_input = clamp(text2num(params["gas_input"]) || 0, 0, max_gas_input)
			investigate_log("was set to [gas_input] by [key_name(usr)]", INVESTIGATE_ATMOS)
			return TRUE

/// Zmienia recepturę: oddaje gaz z wnętrza na wlot i zeruje postęp
/obj/machinery/atmospherics/components/binary/crystallizer/proc/select_recipe(datum/gas_recipe/recipe)
	if(internal.total_moles())
		dump_gases()
	quality_loss = 0
	progress_bar = 0
	selected_recipe = null
	if(istype(recipe) && recipe.machine_type == "Crystallizer")
		selected_recipe = recipe
		moles_calculations()
	update_parents()

/obj/machinery/atmospherics/components/binary/crystallizer/update_layer()
	return

/obj/item/circuitboard/machine/crystallizer
	name = "krystalizator (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/atmospherics/components/binary/crystallizer
	req_components = list(
		/obj/item/stack/cable_coil = 10,
		/obj/item/stack/sheet/glass = 10,
		/obj/item/stack/sheet/plasteel = 5)

/datum/design/board/crystallizer
	name = "Projekt maszyny (krystalizator)"
	desc = "Płytka drukowana: krystalizator."
	id = "crystallizer"
	build_path = /obj/item/circuitboard/machine/crystallizer
	category = list("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/techweb_node/adv_engi/New()
	. = ..()
	design_ids += "crystallizer"

#undef CRYSTALLIZER_MIN_PROGRESS_AMOUNT
#undef CRYSTALLIZER_MIN_DEVIATION_RATE
#undef CRYSTALLIZER_MAX_DEVIATION_RATE
#undef CRYSTALLIZER_HIGH_CONDUCTIVITY_RATIO
