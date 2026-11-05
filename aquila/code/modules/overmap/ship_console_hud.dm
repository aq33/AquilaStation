// Panel konsoli na ekranie osoby za sterami statku (overmapa).
// Grafiki leżały w repo NSV13 bez kodu (nsv13/icons/overmap/gui/*_console, napisy przerysowane po polsku).
// Sternik dużego statku dostaje panel „flight”, strzelec panel „weapons”, pilot małej jednostki panel „fighter”.
// Panel pokazuje hamulec, sterowanie (mysz/klawisze), stan kadłuba i wybraną broń; przyciski na panelu są klikalne.
// Myśliwiec ma dwa przełączniki „KATAPULTA”: oba przestawione w ciągu AQUILA_CONSOLE_ARM_TIME katapultują pilota.

#define AQUILA_CONSOLE_FLIGHT "flight"
#define AQUILA_CONSOLE_FIGHTER "fighter"
#define AQUILA_CONSOLE_WEAPONS "weapons"
/// Jak długo przełącznik katapulty zostaje przestawiony, zanim sam wróci.
#define AQUILA_CONSOLE_ARM_TIME (5 SECONDS)
/// Jak długo przycisk na panelu jest wciśnięty po użyciu skrótu albo kliknięciu.
#define AQUILA_CONSOLE_PRESS_TIME (0.3 SECONDS)

/// Warstwy paneli: rodzaj => nazwa warstwy => plik. Ścieżki muszą być literałami, żeby trafiły do .rsc.
GLOBAL_LIST_INIT(aquila_ship_console_layers, list(
	AQUILA_CONSOLE_FLIGHT = list(
		"monitor" = 'aquila/icons/overmap/gui/flight_console/monitor.png',
		"brake_on" = 'aquila/icons/overmap/gui/flight_console/brake_on.png',
		"brake_off" = 'aquila/icons/overmap/gui/flight_console/brake_off.png',
		"hull0" = 'aquila/icons/overmap/gui/flight_console/hull0.png',
		"hull25" = 'aquila/icons/overmap/gui/flight_console/hull25.png',
		"hull50" = 'aquila/icons/overmap/gui/flight_console/hull50.png',
		"hull75" = 'aquila/icons/overmap/gui/flight_console/hull75.png',
		"hull100" = 'aquila/icons/overmap/gui/flight_console/hull100.png',
		"rotation_mouse" = 'aquila/icons/overmap/gui/flight_console/rotation_mouse.png',
		"rotation_keyboard" = 'aquila/icons/overmap/gui/flight_console/rotation_keyboard.png',
		"flighttoggle" = 'aquila/icons/overmap/gui/flight_console/flighttoggle.png',
		"flighttoggle_pressed" = 'aquila/icons/overmap/gui/flight_console/flighttoggle_pressed.png',
		"rotationtoggle" = 'aquila/icons/overmap/gui/flight_console/rotationtoggle.png',
		"rotationtoggle_pressed" = 'aquila/icons/overmap/gui/flight_console/rotationtoggle_pressed.png',
	),
	AQUILA_CONSOLE_FIGHTER = list(
		"monitor" = 'aquila/icons/overmap/gui/fighter_console/monitor.png',
		"brake_on" = 'aquila/icons/overmap/gui/fighter_console/brake_on.png',
		"brake_off" = 'aquila/icons/overmap/gui/fighter_console/brake_off.png',
		"hull0" = 'aquila/icons/overmap/gui/fighter_console/hull0.png',
		"hull25" = 'aquila/icons/overmap/gui/fighter_console/hull25.png',
		"hull50" = 'aquila/icons/overmap/gui/fighter_console/hull50.png',
		"hull75" = 'aquila/icons/overmap/gui/fighter_console/hull75.png',
		"hull100" = 'aquila/icons/overmap/gui/fighter_console/hull100.png',
		"rotation_mouse" = 'aquila/icons/overmap/gui/fighter_console/rotation_mouse.png',
		"rotation_keyboard" = 'aquila/icons/overmap/gui/fighter_console/rotation_keyboard.png',
		"pdc" = 'aquila/icons/overmap/gui/fighter_console/pdc_on.png',
		"torpedo" = 'aquila/icons/overmap/gui/fighter_console/torpedo_on.png',
		"weptoggle" = 'aquila/icons/overmap/gui/fighter_console/weptoggle.png',
		"weptoggle_pressed" = 'aquila/icons/overmap/gui/fighter_console/weptoggle_pressed.png',
		"flighttoggle" = 'aquila/icons/overmap/gui/fighter_console/flighttoggle.png',
		"flighttoggle_pressed" = 'aquila/icons/overmap/gui/fighter_console/flighttoggle_pressed.png',
		"rotationtoggle" = 'aquila/icons/overmap/gui/fighter_console/rotationtoggle.png',
		"rotationtoggle_pressed" = 'aquila/icons/overmap/gui/fighter_console/rotationtoggle_pressed.png',
		"switch_left" = 'nsv13/icons/overmap/gui/fighter_console/switch_left.png',
		"switch_left_armed" = 'nsv13/icons/overmap/gui/fighter_console/switch_left_armed.png',
		"switch_right" = 'aquila/icons/overmap/gui/fighter_console/switch_right.png',
		"switch_right_armed" = 'nsv13/icons/overmap/gui/fighter_console/switch_right_armed.png',
	),
	AQUILA_CONSOLE_WEAPONS = list(
		"monitor" = 'aquila/icons/overmap/gui/weapons_console/monitor.png',
		"hull0" = 'aquila/icons/overmap/gui/weapons_console/hull0.png',
		"hull25" = 'aquila/icons/overmap/gui/weapons_console/hull25.png',
		"hull50" = 'aquila/icons/overmap/gui/weapons_console/hull50.png',
		"hull75" = 'aquila/icons/overmap/gui/weapons_console/hull75.png',
		"hull100" = 'aquila/icons/overmap/gui/weapons_console/hull100.png',
		"pdc" = 'aquila/icons/overmap/gui/weapons_console/pdc_on.png',
		"torpedo" = 'aquila/icons/overmap/gui/weapons_console/torpedo_on.png',
		"railgun" = 'aquila/icons/overmap/gui/weapons_console/railgun_on.png',
		"weptoggle" = 'aquila/icons/overmap/gui/weapons_console/weptoggle.png',
		"weptoggle_pressed" = 'aquila/icons/overmap/gui/weapons_console/weptoggle_pressed.png',
	),
))

/// Rozmiar paneli w pikselach (szerokość, wysokość).
GLOBAL_LIST_INIT(aquila_ship_console_sizes, list(
	AQUILA_CONSOLE_FLIGHT = list(226, 132),
	AQUILA_CONSOLE_FIGHTER = list(260, 207),
	AQUILA_CONSOLE_WEAPONS = list(186, 133),
))

/// Klikalne miejsca: rodzaj => akcja => list(x0, y0, x1, y1) w pikselach PNG liczonych od lewego górnego rogu.
GLOBAL_LIST_INIT(aquila_ship_console_buttons, list(
	AQUILA_CONSOLE_FLIGHT = list(
		"brakes" = list(26, 87, 77, 114),
		"rotation" = list(79, 87, 201, 114),
	),
	AQUILA_CONSOLE_FIGHTER = list(
		"weapon" = list(16, 162, 67, 189),
		"brakes" = list(69, 162, 120, 189),
		"rotation" = list(122, 162, 244, 189),
		"switch_left" = list(190, 26, 202, 66),
		"switch_right" = list(216, 26, 228, 66),
	),
	AQUILA_CONSOLE_WEAPONS = list(
		"weapon" = list(36, 87, 87, 114),
	),
))

/// Który obrazek broni zapalić na panelu dla danego typu broni okrętowej.
/proc/aquila_console_weapon_category(datum/overmap_ship_weapon/weapon)
	if(!weapon)
		return null
	if(istype(weapon, /datum/overmap_ship_weapon/torpedo_launcher) || istype(weapon, /datum/overmap_ship_weapon/missile_launcher) \
		|| istype(weapon, /datum/overmap_ship_weapon/vls) || istype(weapon, /datum/overmap_ship_weapon/fighter/secondary))
		return "torpedo"
	if(istype(weapon, /datum/overmap_ship_weapon/aa_guns) || istype(weapon, /datum/overmap_ship_weapon/light_cannon) \
		|| istype(weapon, /datum/overmap_ship_weapon/heavy_cannon) || istype(weapon, /datum/overmap_ship_weapon/fighter) \
		|| istype(weapon, /datum/overmap_ship_weapon/flak) || istype(weapon, /datum/overmap_ship_weapon/laser_ams))
		return "pdc"
	return "railgun"

/// Próg stanu kadłuba (0/25/50/75/100) do wyboru obrazka.
/proc/aquila_console_hull_level(obj/structure/overmap/ship)
	if(!ship.max_integrity || ship.structure_crit)
		return 0
	var/percent = ship.obj_integrity / ship.max_integrity * 100
	if(percent >= 87.5)
		return 100
	if(percent >= 62.5)
		return 75
	if(percent >= 37.5)
		return 50
	if(percent >= 12.5)
		return 25
	return 0

/atom/movable/screen/movable/aquila_ship_console
	name = "konsola statku"
	plane = HUD_PLANE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	screen_loc = "CENTER,SOUTH+1"
	/// AQUILA_CONSOLE_FLIGHT / FIGHTER / WEAPONS
	var/kind
	var/obj/structure/overmap/ship
	var/mob/living/user
	/// Kolejność panelu u tej osoby (sternik i strzelec naraz dostają dwa panele obok siebie).
	var/slot = 0
	/// Ostatnio narysowany stan, żeby nie przebudowywać nakładek bez zmiany.
	var/last_state
	var/last_scale
	/// akcja => world.time, do którego przycisk jest wciśnięty
	var/list/pressed_until = list()
	/// world.time, do którego przełącznik katapulty jest przestawiony
	var/left_armed_until = 0
	var/right_armed_until = 0

/atom/movable/screen/movable/aquila_ship_console/Initialize(mapload, obj/structure/overmap/ship, mob/living/user, kind)
	. = ..()
	src.ship = ship
	src.user = user
	src.kind = kind
	var/list/layers = GLOB.aquila_ship_console_layers[kind]
	icon = layers["monitor"]
	RegisterSignal(ship, COMSIG_PARENT_QDELETING, PROC_REF(on_ship_deleted))
	START_PROCESSING(SSprocessing, src)
	refresh()

/atom/movable/screen/movable/aquila_ship_console/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	if(user)
		LAZYREMOVE(user.aquila_consoles, src) // panel bywa usuwany sam (refresh, process, statek usunięty)
		user.client?.screen -= src
	if(ship)
		UnregisterSignal(ship, COMSIG_PARENT_QDELETING)
	ship = null
	user = null
	return ..()

/atom/movable/screen/movable/aquila_ship_console/proc/on_ship_deleted(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/atom/movable/screen/movable/aquila_ship_console/process(delta_time)
	if(QDELETED(user) || QDELETED(ship))
		qdel(src)
		return PROCESS_KILL
	refresh()

/// Czy ta osoba nadal jest na stanowisku, dla którego ma panel.
/atom/movable/screen/movable/aquila_ship_console/proc/still_valid()
	if(user.overmap_ship != ship)
		return FALSE
	if(kind == AQUILA_CONSOLE_WEAPONS)
		return ship.gunner == user
	return ship.pilot == user

/atom/movable/screen/movable/aquila_ship_console/proc/refresh()
	if(!still_valid())
		qdel(src)
		return
	var/client/C = user.client
	if(!C)
		return
	if(!(src in C.screen) && !(user.aquila_console_hidden))
		C.screen += src // po ponownym połączeniu ekran jest pusty
	update_scale(C)
	var/state = build_state()
	if(state == last_state)
		return
	last_state = state
	cut_overlays()
	var/list/layers = GLOB.aquila_ship_console_layers[kind]
	for(var/layer_name in splittext(state, ";"))
		if(layers[layer_name])
			add_overlay(image(layers[layer_name]))

/// Lista warstw do narysowania, jako tekst rozdzielony średnikami (służy też do porównania stanu).
/atom/movable/screen/movable/aquila_ship_console/proc/build_state()
	var/list/parts = list()
	if(kind != AQUILA_CONSOLE_WEAPONS)
		parts += ship.brakes ? "brake_on" : "brake_off"
		parts += ship.move_by_mouse ? "rotation_mouse" : "rotation_keyboard"
	parts += "hull[aquila_console_hull_level(ship)]"
	if(kind != AQUILA_CONSOLE_FLIGHT)
		var/category = aquila_console_weapon_category(ship.controlled_weapon_datum?[user])
		if(category == "railgun" && kind == AQUILA_CONSOLE_FIGHTER)
			category = "torpedo" // myśliwiec ma na panelu tylko działko i torpedę
		if(category)
			parts += category
	var/static/list/button_layers = list("weapon" = "weptoggle", "brakes" = "flighttoggle", "rotation" = "rotationtoggle")
	for(var/button in button_layers)
		var/layer_name = button_layers[button]
		if(!GLOB.aquila_ship_console_layers[kind][layer_name])
			continue
		parts += (pressed_until[button] > world.time) ? "[layer_name]_pressed" : layer_name
	if(kind == AQUILA_CONSOLE_FIGHTER)
		parts += (left_armed_until > world.time) ? "switch_left_armed" : "switch_left"
		parts += (right_armed_until > world.time) ? "switch_right_armed" : "switch_right"
	return jointext(parts, ";")

/// Stała skala panelu przy zwykłym widoku. Panel myśliwca jest duży (260x207 przy widoku 21x15 kafelków),
/// więc jest mniejszy; 0.75 to najmniej, przy którym napisy 5 px dają się jeszcze przeczytać.
GLOBAL_LIST_INIT(aquila_ship_console_base_scale, list(
	AQUILA_CONSOLE_FLIGHT = 1,
	AQUILA_CONSOLE_FIGHTER = 0.75,
	AQUILA_CONSOLE_WEAPONS = 1,
))

/// Skala panelu: stała dla rodzaju razy powiększenie przy oddalonej kamerze (duże statki: kafelki są mniejsze,
/// więc panel rośnie razem z widokiem, żeby napisy dało się przeczytać).
/atom/movable/screen/movable/aquila_ship_console/proc/current_scale(client/C)
	var/list/now = getviewsize(C.view)
	var/list/base = getviewsize(C.view_size?.default || C.view)
	return clamp(now[1] / max(base[1], 1), 1, 2) * GLOB.aquila_ship_console_base_scale[kind]

/// Macierz trzyma lewy dolny róg w miejscu, więc screen_loc zawsze wskazuje lewy dolny róg panelu.
/atom/movable/screen/movable/aquila_ship_console/proc/update_scale(client/C)
	var/scale = current_scale(C)
	if(scale == last_scale)
		return
	last_scale = scale
	var/list/size = GLOB.aquila_ship_console_sizes[kind]
	transform = matrix(scale, 0, (scale - 1) * size[1] / 2, 0, scale, (scale - 1) * size[2] / 2)
	if(moved)
		keep_on_screen(C) // mniejszy widok mógł wypchnąć przeciągnięty panel za krawędź
		return
	// panele obok siebie, razem wyśrodkowane nad dolnym paskiem HUD
	var/total = 0
	var/before = 0
	for(var/atom/movable/screen/movable/aquila_ship_console/panel in user.aquila_consoles)
		var/width = GLOB.aquila_ship_console_sizes[panel.kind][1] * panel.current_scale(C)
		if(panel.slot < slot)
			before += width
		total += width
	screen_loc = "CENTER:[round(before - total / 2)],SOUTH+1"

/// Bazowy MouseDrop zmienia tylko screen_loc; bez `moved` update_scale() wracałby panel na środek.
/atom/movable/screen/movable/aquila_ship_console/MouseDrop(over_object, src_location, over_location, src_control, over_control, params)
	var/old_loc = screen_loc
	. = ..()
	if(screen_loc == old_loc)
		return
	moved = TRUE
	if(user?.client)
		keep_on_screen(user.client)

/// Przycina położenie przeciągniętego panelu tak, żeby cały został na ekranie. Bez tego panel dało się wypchnąć
/// za krawędź, skąd nie było go czym złapać z powrotem.
/atom/movable/screen/movable/aquila_ship_console/proc/keep_on_screen(client/C)
	var/list/view = getviewsize(C.view)
	var/list/size = GLOB.aquila_ship_console_sizes[kind]
	var/scale = current_scale(C)
	var/clamped = aquila_console_clamp_screen_loc(screen_loc, view[1], view[2], size[1] * scale, size[2] * scale)
	if(clamped)
		screen_loc = clamped

/// screen_loc w postaci "X:px,Y:py" (kafelki od 1, tak zapisuje go MouseDrop) przycięty tak, żeby prostokąt
/// width x height pikseli z lewym dolnym rogiem w tym miejscu zmieścił się w widoku view_w x view_h kafelków.
/// Zwraca null dla innych postaci (CENTER, SOUTH), które ustawiamy tylko sami.
/proc/aquila_console_clamp_screen_loc(screen_loc, view_w, view_h, width, height)
	var/static/regex/loc_regex = new(@"^(\d+)(?::(-?\d+))?,(\d+)(?::(-?\d+))?$")
	if(!loc_regex.Find(screen_loc))
		return null
	var/x = (text2num(loc_regex.group[1]) - 1) * world.icon_size + (text2num(loc_regex.group[2]) || 0)
	var/y = (text2num(loc_regex.group[3]) - 1) * world.icon_size + (text2num(loc_regex.group[4]) || 0)
	x = clamp(x, 0, max(0, round(view_w * world.icon_size - width)))
	y = clamp(y, 0, max(0, round(view_h * world.icon_size - height)))
	return "[1 + round(x / world.icon_size)]:[x % world.icon_size],[1 + round(y / world.icon_size)]:[y % world.icon_size]"

/atom/movable/screen/movable/aquila_ship_console/proc/press(button)
	pressed_until[button] = world.time + AQUILA_CONSOLE_PRESS_TIME
	refresh()
	addtimer(CALLBACK(src, PROC_REF(refresh)), AQUILA_CONSOLE_PRESS_TIME + 1)

/atom/movable/screen/movable/aquila_ship_console/Click(location, control, params)
	if(usr != user)
		return
	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		to_chat(usr, examine_text())
		return
	var/list/size = GLOB.aquila_ship_console_sizes[kind]
	var/x = text2num(modifiers["icon-x"]) - 1
	var/y = size[2] - text2num(modifiers["icon-y"]) // PNG liczy wiersze od góry, BYOND od dołu
	var/list/buttons = GLOB.aquila_ship_console_buttons[kind]
	for(var/button in buttons)
		var/list/box = buttons[button]
		if(x >= box[1] && x <= box[3] && y >= box[2] && y <= box[4])
			use_button(button)
			return

/atom/movable/screen/movable/aquila_ship_console/proc/examine_text()
	. = "<span class='notice'>Panel konsoli. Kliknij przycisk na panelu albo użyj skrótu: Alt (hamulec), C (sterowanie myszą/klawiszami), spacja (zmiana broni). Panel można przeciągnąć myszą; ukrywa go czasownik „Pokaż/ukryj panel konsoli” w zakładce Ship.</span>"
	if(kind == AQUILA_CONSOLE_FIGHTER)
		. += "\n<span class='warning'>Katapulta: przestaw oba przełączniki (L i P) w ciągu [DisplayTimeText(AQUILA_CONSOLE_ARM_TIME)], żeby wystrzelić kapsułę ratunkową.</span>"

/atom/movable/screen/movable/aquila_ship_console/proc/use_button(button)
	switch(button)
		if("brakes")
			ship.toggle_brakes()
		if("rotation")
			ship.toggle_move_mode()
		if("weapon")
			ship.cycle_firemode(user)
		if("switch_left")
			left_armed_until = world.time + AQUILA_CONSOLE_ARM_TIME
			arm_switch()
			return
		if("switch_right")
			right_armed_until = world.time + AQUILA_CONSOLE_ARM_TIME
			arm_switch()
			return
	if(ship.helm && prob(80))
		playsound(ship.helm, pick(GLOB.computer_beeps), 100, 1)
	press(button)

/atom/movable/screen/movable/aquila_ship_console/proc/arm_switch()
	ship.relay('nsv13/sound/effects/fighters/switch.ogg')
	refresh()
	addtimer(CALLBACK(src, PROC_REF(refresh)), AQUILA_CONSOLE_ARM_TIME + 1)
	if(left_armed_until <= world.time || right_armed_until <= world.time)
		return
	var/obj/structure/overmap/small_craft/craft = ship
	if(!istype(craft))
		return
	if(!craft.aquila_can_manual_eject(user))
		return
	craft.aquila_manual_eject(user)

// --- Osoba za sterami ---------------------------------------------------------------------

/mob
	/// Panele konsoli statku na ekranie tej osoby.
	var/list/aquila_consoles
	/// Gracz ukrył panel czasownikiem.
	var/aquila_console_hidden = FALSE

/obj/structure/overmap/start_piloting(mob/living/carbon/user, position)
	. = ..()
	if(.)
		aquila_give_consoles(user)

/obj/structure/overmap/proc/aquila_give_consoles(mob/living/user)
	aquila_remove_consoles(user)
	var/list/kinds = list()
	if(istype(src, /obj/structure/overmap/small_craft))
		if(pilot == user)
			kinds += AQUILA_CONSOLE_FIGHTER
	else
		if(pilot == user)
			kinds += AQUILA_CONSOLE_FLIGHT
		if(gunner == user)
			kinds += AQUILA_CONSOLE_WEAPONS
	if(!length(kinds))
		return
	var/index = 0
	for(var/kind in kinds)
		var/atom/movable/screen/movable/aquila_ship_console/panel = new(null, src, user, kind)
		panel.slot = index++
		LAZYADD(user.aquila_consoles, panel)
	for(var/atom/movable/screen/movable/aquila_ship_console/panel as anything in LAZYCOPY(user.aquila_consoles))
		panel.last_scale = null // przelicz położenie, gdy znamy już wszystkie panele
		panel.refresh()
	RegisterSignal(user, COMSIG_STOPPED_PILOTING, PROC_REF(aquila_on_stopped_piloting), override = TRUE)
	RegisterSignal(user, COMSIG_KB_OVERMAP_TOGGLEBRAKES_DOWN, PROC_REF(aquila_on_key_brakes), override = TRUE)
	RegisterSignal(user, COMSIG_KB_OVERMAP_TOGGLEMOUSEMOVE_DOWN, PROC_REF(aquila_on_key_rotation), override = TRUE)
	RegisterSignal(user, COMSIG_KB_OVERMAP_CYCLEFIREMODE_DOWN, PROC_REF(aquila_on_key_weapon), override = TRUE)
	user.add_verb(/mob/living/proc/aquila_toggle_ship_console)
	if(!user.aquila_console_hidden)
		to_chat(user, "<span class='notice'>Na dole ekranu jest panel konsoli. Przyciski na nim działają jak skróty klawiszowe; Shift+klik pokazuje opis.</span>")

/obj/structure/overmap/proc/aquila_remove_consoles(mob/living/user)
	for(var/atom/movable/screen/movable/aquila_ship_console/panel as anything in LAZYCOPY(user.aquila_consoles))
		if(panel.ship == src)
			qdel(panel) // Destroy() zdejmuje panel z listy

/obj/structure/overmap/proc/aquila_on_stopped_piloting(mob/living/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_STOPPED_PILOTING, COMSIG_KB_OVERMAP_TOGGLEBRAKES_DOWN, COMSIG_KB_OVERMAP_TOGGLEMOUSEMOVE_DOWN, COMSIG_KB_OVERMAP_CYCLEFIREMODE_DOWN))
	aquila_remove_consoles(source)
	source.remove_verb(/mob/living/proc/aquila_toggle_ship_console)

// Skrót klawiszowy wciska przycisk na panelu. Sygnał przychodzi przed wykonaniem akcji, więc nic nie blokujemy
// (handler nic nie zwraca), a panel odświeża się chwilę później, już z nowym stanem.
/obj/structure/overmap/proc/aquila_on_key_brakes(mob/living/source)
	SIGNAL_HANDLER
	aquila_press_console_button(source, "brakes")

/obj/structure/overmap/proc/aquila_on_key_rotation(mob/living/source)
	SIGNAL_HANDLER
	aquila_press_console_button(source, "rotation")

/obj/structure/overmap/proc/aquila_on_key_weapon(mob/living/source)
	SIGNAL_HANDLER
	aquila_press_console_button(source, "weapon")

/obj/structure/overmap/proc/aquila_press_console_button(mob/living/source, button)
	for(var/atom/movable/screen/movable/aquila_ship_console/panel as anything in source.aquila_consoles)
		if(panel.ship == src)
			panel.press(button)

/// Czasownik dodawany tylko na czas siedzenia za sterami (add_verb), żeby nie wisiał wszystkim w zakładce Ship.
/mob/living/proc/aquila_toggle_ship_console()
	set name = "Pokaż/ukryj panel konsoli"
	set category = "Ship"
	if(!LAZYLEN(aquila_consoles))
		to_chat(src, "<span class='warning'>Nie siedzisz za sterami ani przy działach statku.</span>")
		return
	aquila_console_hidden = !aquila_console_hidden
	for(var/atom/movable/screen/movable/aquila_ship_console/panel as anything in LAZYCOPY(aquila_consoles))
		if(aquila_console_hidden)
			client?.screen -= panel
		else
			panel.refresh()
	to_chat(src, "<span class='notice'>[aquila_console_hidden ? "Ukrywasz" : "Pokazujesz"] panel konsoli.</span>")

#undef AQUILA_CONSOLE_FLIGHT
#undef AQUILA_CONSOLE_FIGHTER
#undef AQUILA_CONSOLE_WEAPONS
#undef AQUILA_CONSOLE_ARM_TIME
#undef AQUILA_CONSOLE_PRESS_TIME
