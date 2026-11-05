/*
 * AQUILA: okno kanistra rysowane prosto na ekranie gracza, bez okna TGUI.
 * Wygląd i układ z prefabu TabCanister z Unitystation (grafiki CC BY-SA 3.0,
 * aquila/icons/ui/canister_hud/LICENSE.md). Pozycje elementów są w canister_hud_layout.dm.
 */

/// Kolory lampek (zapalona, zgaszona) jak w Unitystation
#define CANISTER_HUD_RED_ON "#ff1c00"
#define CANISTER_HUD_RED_OFF "#730000"
#define CANISTER_HUD_YELLOW_ON "#e4ff02"
#define CANISTER_HUD_YELLOW_OFF "#5e5400"
#define CANISTER_HUD_GREEN_ON "#02ff23"
#define CANISTER_HUD_GREEN_OFF "#005e00"
/// Pełny zakres ciśnienia wylotu to dwa obroty koła
#define CANISTER_HUD_WHEEL_TURN 720
/// Ile razy maptext rysuje czcionkę większą niż podane font-size
#define CANISTER_HUD_FONT_SCALE 1.8

/obj/machinery/portable_atmospherics/canister
	/// Otwarte okna kanistra na ekranach graczy: mob -> /datum/canister_hud
	var/list/canister_huds

/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, datum/tgui/ui)
	if(!user?.client)
		return
	var/datum/canister_hud/hud = LAZYACCESS(canister_huds, user)
	if(hud)
		hud.update()
		return
	LAZYSET(canister_huds, user, new /datum/canister_hud(src, user))

/obj/machinery/portable_atmospherics/canister/Destroy()
	for(var/mob/viewer as anything in canister_huds)
		qdel(canister_huds[viewer])
	canister_huds = null
	return ..()

/// Zawór otwierany z okna na ekranie: to samo logowanie i ostrzeżenia co w ui_act()
/obj/machinery/portable_atmospherics/canister/proc/hud_toggle_valve(mob/user)
	var/logmsg
	valve_open = !valve_open
	if(valve_open)
		logmsg = "Valve was <b>opened</b> by [key_name(user)], starting a transfer into \the [holding || "air"].<br>"
		if(!holding)
			var/list/danger = list()
			for(var/id in air_contents.get_gases())
				if(!(GLOB.gas_data.flags[id] & GAS_FLAG_DANGEROUS))
					continue
				if(air_contents.get_moles(id) > (GLOB.gas_data.visibility[id] || MOLES_GAS_VISIBLE))
					danger[GLOB.gas_data.names[id]] = air_contents.get_moles(id)
			if(length(danger))
				message_admins("[ADMIN_LOOKUPFLW(user)] otwiera kanister z następującą zawartością w [ADMIN_VERBOSEJMP(src)]:")
				log_admin("[key_name(user)] opened a canister that contains the following at [AREACOORD(src)]:")
				for(var/gas_name in danger)
					var/msg = "[gas_name]: [danger[gas_name]] moles."
					log_admin(msg)
					message_admins(msg)
	else
		logmsg = "Valve was <b>closed</b> by [key_name(user)], stopping the transfer into \the [holding || "air"].<br>"
	investigate_log(logmsg, INVESTIGATE_ATMOS)
	release_log += logmsg
	playsound(src, 'aquila/sound/effects/valve_opening.ogg', 50)
	update_icon()

/obj/machinery/portable_atmospherics/canister/proc/hud_set_release(mob/user, pressure)
	pressure = clamp(round(pressure), can_min_release_pressure, can_max_release_pressure)
	if(pressure == release_pressure)
		return
	release_pressure = pressure
	investigate_log("was set to [release_pressure] kPa by [key_name(user)].", INVESTIGATE_ATMOS)

/obj/machinery/portable_atmospherics/canister/proc/hud_eject(mob/user)
	if(!holding)
		return
	if(valve_open)
		message_admins("[ADMIN_LOOKUPFLW(user)] wyjmuje [holding] z [src] przy otwartym zaworze w [ADMIN_VERBOSEJMP(src)] i wypuszcza zawartość <span class='boldannounce'>do powietrza</span>.")
		investigate_log("[key_name(user)] removed the [holding], leaving the valve open and transferring into the <span class='boldannounce'>air</span>.", INVESTIGATE_ATMOS)
	replace_tank(user, FALSE)
	update_icon()

/obj/machinery/portable_atmospherics/canister/proc/hud_relabel(mob/user)
	var/label = input(user, "Nowa etykieta kanistra:", name) as null|anything in sortList(label2types)
	if(!label || QDELETED(src) || !LAZYACCESS(canister_huds, user))
		return
	var/obj/machinery/portable_atmospherics/canister/replacement = label2types[label]
	if(!replacement)
		return
	name = initial(replacement.name)
	desc = initial(replacement.desc)
	icon_state = initial(replacement.icon_state)
	set_greyscale(initial(replacement.greyscale_colors), initial(replacement.greyscale_config))
	update_icon()

/// Jeden element okna na ekranie: obrazek, napis albo strefa kliknięcia
/atom/movable/screen/canister_hud
	plane = ABOVE_HUD_PLANE
	layer = ABOVE_HUD_LAYER
	appearance_flags = RESET_COLOR | RESET_TRANSFORM | NO_CLIENT_COLOR | TILE_BOUND
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// Okno kanistra, do którego należy element
	var/datum/canister_hud/owner
	/// Akcja wywoływana kliknięciem (tylko strefy kliknięcia)
	var/action
	/// Szerokość strefy kliknięcia w pikselach (koło: lewa i prawa połowa)
	var/hit_width = 0

/atom/movable/screen/canister_hud/Click(location, control, params)
	if(owner && action)
		owner.on_action(action, usr, params2list(params))

/atom/movable/screen/canister_hud/MouseWheel(delta_x, delta_y, location, control, params)
	if(owner && action == "wheel")
		owner.on_action(delta_y > 0 ? "wheel_up" : "wheel_down", usr)

/atom/movable/screen/canister_hud/Destroy()
	owner = null
	return ..()

/datum/canister_hud
	var/obj/machinery/portable_atmospherics/canister/canister
	var/mob/user
	/// klucz z układu -> obiekt ekranu
	var/list/atom/movable/screen/canister_hud/parts = list()
	/// klucz napisu -> list(obiekt ekranu, dane z układu)
	var/list/texts = list()
	var/timer_id
	var/shown_angle
	var/shown_valve
	var/shown_tank_valve

/datum/canister_hud/New(obj/machinery/portable_atmospherics/canister/source, mob/viewer)
	canister = source
	user = viewer
	build()
	update()
	for(var/key in parts)
		user.client.screen += parts[key]
	for(var/key in texts)
		user.client.screen += texts[key][1]
	RegisterSignal(user, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_LOGOUT), PROC_REF(close))
	timer_id = addtimer(CALLBACK(src, PROC_REF(tick)), 5, TIMER_STOPPABLE | TIMER_LOOP)

/datum/canister_hud/Destroy()
	deltimer(timer_id)
	if(user)
		UnregisterSignal(user, list(COMSIG_PARENT_QDELETING, COMSIG_MOB_LOGOUT))
		for(var/key in parts)
			user.client?.screen -= parts[key]
		for(var/key in texts)
			user.client?.screen -= texts[key][1]
	if(canister)
		LAZYREMOVE(canister.canister_huds, user)
	for(var/key in parts)
		qdel(parts[key])
	for(var/key in texts)
		qdel(texts[key][1])
	parts = null
	texts = null
	canister = null
	user = null
	return ..()

/datum/canister_hud/proc/close()
	SIGNAL_HANDLER
	qdel(src)

/// screen_loc dla piksela względem lewego dolnego rogu okna (okno na środku widoku)
/datum/canister_hud/proc/screen_loc_for(px, py)
	px += 16 - round(CANISTER_HUD_WIDTH / 2)
	py += 16 - round(CANISTER_HUD_HEIGHT / 2)
	var/tx = FLOOR(px / world.icon_size, 1)
	var/ty = FLOOR(py / world.icon_size, 1)
	var/ox = px - tx * world.icon_size
	var/oy = py - ty * world.icon_size
	return "CENTER[tx < 0 ? "[tx]" : "+[tx]"]:[ox],CENTER[ty < 0 ? "[ty]" : "+[ty]"]:[oy]"

/datum/canister_hud/proc/build()
	for(var/list/entry as anything in layout_images())
		var/atom/movable/screen/canister_hud/part = new
		part.owner = src
		part.icon = entry["icon"]
		part.layer = ABOVE_HUD_LAYER + entry["layer"] * 0.01
		part.screen_loc = screen_loc_for(entry["x"], entry["y"])
		if(entry["hit"])
			part.action = entry["hit"]
			part.mouse_opacity = MOUSE_OPACITY_OPAQUE
			part.name = hit_name(entry["hit"])
			part.hit_width = entry["w"]
		parts[entry["key"]] = part
	for(var/list/entry as anything in layout_texts())
		if(findtext(entry["key"], "CloseWindowButton"))
			continue
		var/atom/movable/screen/canister_hud/label = new
		label.owner = src
		label.layer = ABOVE_HUD_LAYER + 0.09
		label.screen_loc = screen_loc_for(entry["x"], entry["y"])
		label.maptext_width = entry["w"] + 6
		label.maptext_height = max(12, entry["h"])
		texts[entry["key"]] = list(label, entry)

/// Podpowiedź przy najechaniu na strefę kliknięcia
/datum/canister_hud/proc/hit_name(action)
	switch(action)
		if("valve")
			return "zawór kanistra"
		if("tankvalve")
			return "napełnianie butli"
		if("wheel")
			return "koło regulatora (lewa połowa mniej, prawa więcej, kółko myszy)"
		if("minus")
			return "zmniejsz ciśnienie"
		if("plus")
			return "zwiększ ciśnienie"
		if("edit")
			return "wpisz ciśnienie"
		if("eject", "tank")
			return "wyjmij butlę"
		if("label")
			return "zmień etykietę"
		if("close")
			return "zamknij"
	return "kanister"

/datum/canister_hud/proc/can_use()
	if(QDELETED(canister) || QDELETED(user) || !user.client)
		return FALSE
	return canister.ui_status(user, canister.ui_state(user)) >= UI_INTERACTIVE

/datum/canister_hud/proc/tick()
	if(!can_use())
		qdel(src)
		return
	update()

/datum/canister_hud/proc/on_action(action, mob/clicker, list/params)
	if(clicker != user)
		return
	if(action == "close")
		qdel(src)
		return
	if(!can_use())
		qdel(src)
		return
	switch(action)
		if("valve")
			canister.hud_toggle_valve(user)
		if("tankvalve")
			if(canister.holding)
				canister.hud_toggle_valve(user)
			else
				to_chat(user, span_warning("Najpierw włóż butlę do kanistra."))
		if("wheel")
			var/right = text2num(params?["icon-x"]) > parts["hit_wheel"].hit_width / 2
			canister.hud_set_release(user, canister.release_pressure + (right ? 100 : -100))
		if("wheel_up")
			canister.hud_set_release(user, canister.release_pressure + 25)
		if("wheel_down")
			canister.hud_set_release(user, canister.release_pressure - 25)
		if("minus")
			canister.hud_set_release(user, canister.release_pressure - 50)
		if("plus")
			canister.hud_set_release(user, canister.release_pressure + 50)
		if("edit")
			var/pressure = input(user, "Nowe ciśnienie wypuszczania ([canister.can_min_release_pressure]-[canister.can_max_release_pressure] kPa):", canister.name, canister.release_pressure) as num|null
			if(!isnull(pressure) && can_use())
				canister.hud_set_release(user, pressure)
		if("eject", "tank")
			canister.hud_eject(user)
		if("label")
			canister.hud_relabel(user)
	if(!QDELETED(src))
		update()

/datum/canister_hud/proc/set_text(key, text)
	var/list/pair = texts[key]
	if(!pair)
		return
	var/atom/movable/screen/canister_hud/label = pair[1]
	var/list/entry = pair[2]
	// Maptext rysuje Verdanę około 1,8 raza większą niż font-size w px i wyrównuje tekst
	// do dołu pudełka (zmierzone w kliencie 516), więc środkujemy od dołu
	var/size = max(4, round(entry["size"] * 0.7, 0.5))
	var/line = size * CANISTER_HUD_FONT_SCALE
	label.maptext_y = round((entry["h"] - line) / 2)
	var/align = list("left", "center", "right")[entry["align"] + 1]
	label.maptext = "<span style='font-family: Verdana, sans-serif; font-size: [size]px; font-weight: bold; color: [entry["color"]]; text-align: [align]; line-height: 1;'>[text]</span>"

/// Cyfra licznika bębnowego dla miejsca z prefabu ("100k", "10k", "1000"...)
/datum/canister_hud/proc/digit(value, place)
	var/static/list/places = list("100k" = 100000, "10k" = 10000, "1000" = 1000, "100" = 100, "10" = 10, "1" = 1)
	var/divisor = places[place] || 1
	return "[round(max(0, value) / divisor) % 10]"

/datum/canister_hud/proc/update()
	if(QDELETED(canister))
		return
	var/tank_pressure = round(canister.air_contents.return_pressure())
	var/release = canister.release_pressure
	var/obj/item/tank/holding = canister.holding
	var/holding_pressure = holding ? round(holding.air_contents.return_pressure()) : 0
	var/valve = canister.valve_open

	// napisy
	for(var/key in texts)
		var/list/entry = texts[key][2]
		var/list/bits = splittext(key, "/")
		if(length(bits) >= 2 && bits[length(bits)] == "center")
			var/place = bits[length(bits) - 1]
			if(findtext(key, "InternalPressure"))
				set_text(key, digit(tank_pressure, place))
			else if(findtext(key, "ExternalPressure"))
				set_text(key, digit(holding_pressure, place))
			else
				set_text(key, digit(release, place))
			continue
		switch(key)
			if("Internal")
				set_text(key, "Stan kanistra")
			if("Internal/ConnectionStatus/ConnectionStatusText")
				set_text(key, canister.connected_port ? "Podłączony" : "Niepodłączony")
			if("ReleaseValve")
				set_text(key, "Zawór wylotu")
			if("ReleaseValve/MainLeverGrouping/Open")
				set_text(key, "Otwarty")
			if("ReleaseValve/MainLeverGrouping/Closed")
				set_text(key, "Zamknięty")
			if("ExternalTank/SecondaryLeverGrouping/Tank")
				set_text(key, "Napełnij")
			if("ExternalTank/SecondaryLeverGrouping/Valve")
				set_text(key, "Zamknij")
			if("ExternalTank/TankStatusGroup/TankStatusText")
				set_text(key, holding ? format_text(holding.name) : "Brak butli")
			if("ExternalTank/eject/Text")
				set_text(key, "Wyjmij")
			if("LabelFrame/PropertyText")
				set_text(key, format_text(canister.name))
			else
				if(!texts[key][1].maptext)
					set_text(key, entry["text"])

	// lampki: czerwona przy pustym albo przepełnionym kanistrze, żółta przy otwartym zaworze
	var/danger = tank_pressure <= 0 || tank_pressure > 9000
	parts["led_red"].color = danger ? CANISTER_HUD_RED_ON : CANISTER_HUD_RED_OFF
	parts["led_yellow"].color = valve ? CANISTER_HUD_YELLOW_ON : CANISTER_HUD_YELLOW_OFF
	parts["led_green"].color = (!danger && !valve) ? CANISTER_HUD_GREEN_ON : CANISTER_HUD_GREEN_OFF

	// obudowa w rozjaśnionym kolorze kanistra
	var/body_color = length(canister.greyscale_colors) >= 7 ? copytext(canister.greyscale_colors, 1, 8) : "#9aa1ad"
	var/list/rgb = rgb2num(body_color)
	parts["body"].color = rgb(rgb[1] + (255 - rgb[1]) * 0.45, rgb[2] + (255 - rgb[2]) * 0.45, rgb[3] + (255 - rgb[3]) * 0.45)

	// butla w gnieździe
	parts["tank_inserted"].alpha = holding ? 255 : 0
	parts["tank_empty"].alpha = holding ? 0 : 255

	// dźwignie: przy otwartym zaworze obracają się o 90 stopni w stronę strzałek
	if(shown_valve != valve)
		shown_valve = valve
		animate(parts["lever_main"], transform = valve ? matrix().Turn(-90) : matrix(), time = 2)
	var/tank_valve = valve && holding
	if(shown_tank_valve != tank_valve)
		shown_tank_valve = tank_valve
		animate(parts["lever_tank"], transform = tank_valve ? matrix().Turn(-90) : matrix(), time = 2)

	// koło regulatora obraca się razem z ciśnieniem wylotu
	var/span = max(1, canister.can_max_release_pressure - canister.can_min_release_pressure)
	var/angle = round((release - canister.can_min_release_pressure) / span * CANISTER_HUD_WHEEL_TURN)
	if(shown_angle != angle)
		shown_angle = angle
		animate(parts["wheel"], transform = matrix().Turn(-angle), time = 2)

#undef CANISTER_HUD_RED_ON
#undef CANISTER_HUD_RED_OFF
#undef CANISTER_HUD_YELLOW_ON
#undef CANISTER_HUD_YELLOW_OFF
#undef CANISTER_HUD_GREEN_ON
#undef CANISTER_HUD_GREEN_OFF
#undef CANISTER_HUD_WHEEL_TURN
#undef CANISTER_HUD_FONT_SCALE
