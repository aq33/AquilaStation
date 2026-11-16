// Kompaktowy HUD za sterami statku (domyślny): radar w prawym górnym rogu i niski pasek nad dłońmi zamiast
// dużego panelu konsoli (ship_console_hud.dm) i samootwierającego się okna DRADIS. Na czas siedzenia za sterami
// HUD postaci przechodzi w tryb zredukowany (bez ekwipunku). Stary panel zostaje jako preferencja „Klasyczny panel sterowania”.
// Radar pokazuje to samo co DRADIS: widoczność i kolory liczy aq_radar_contacts() według tych samych zasad co ui_data().

/// Promień tarczy radaru w pikselach (aquila/icons/overmap/gui/compact/radar_bg.png ma 160x160)
#define AQ_RADAR_RADIUS 76
/// Wysokość segmentu paska (bar_segment.png)
#define AQ_BAR_HEIGHT 20
/// Odstęp między segmentami paska
#define AQ_BAR_GAP 2
/// Ile czasu po pierwszym kliknięciu katapulty czeka na potwierdzenie
#define AQ_BAR_EJECT_ARM_TIME (5 SECONDS)
/// Ile znaków nazwy broni mieści segment paska
#define AQ_SHIP_BAR_WEAPON_CHARS 9

/datum/preferences
	/// Stary duży panel konsoli i okno DRADIS przy siadaniu za stery zamiast radaru i paska
	var/ship_hud_classic = FALSE

/datum/preference/toggle/player/ship_hud_classic
	db_key = "ship_hud_classic"
	category = PREFERENCE_CATEGORY_GAME_PREFERENCES
	player_var = "ship_hud_classic"

/mob
	/// Kompaktowy HUD statku tej osoby (radar i pasek)
	var/datum/aq_ship_hud/aq_ship_hud

/mob
	/// Wymusza układ HUD-u statku bez patrzenia na preferencje: "compact", "classic" albo null (preferencja; testy bez klienta)
	var/aq_ship_hud_override

/// Czy ta osoba za sterami dostaje kompaktowy HUD (preferencja, domyślnie tak)
/mob/proc/aq_wants_compact_ship_hud()
	if(aq_ship_hud_override)
		return aq_ship_hud_override == "compact"
	return !client?.prefs?.ship_hud_classic

// DRADIS otwiera się sam tylko w klasycznym układzie; w kompaktowym klik w radar
/obj/structure/overmap/skip_dradis_popup(position)
	if(..())
		return TRUE
	var/mob/living/user = (position & OVERMAP_USER_ROLE_PILOT) ? pilot : gunner
	return user?.aq_wants_compact_ship_hud()

/datum/aq_ship_hud
	var/mob/living/user
	var/obj/structure/overmap/ship
	var/atom/movable/screen/aq_ship_radar/radar
	/// id segmentu => obiekt ekranu
	var/list/segments = list()
	/// Wersja HUD-u postaci sprzed siadania za stery
	var/saved_hud_version
	var/eject_armed_until = 0
	var/last_layout

/datum/aq_ship_hud/New(mob/living/user, obj/structure/overmap/ship)
	src.user = user
	src.ship = ship
	radar = new
	radar.ship_hud = src
	RegisterSignal(ship, COMSIG_PARENT_QDELETING, PROC_REF(on_ship_deleted))
	if(user.hud_used && user.hud_used.hud_version != HUD_STYLE_REDUCED)
		saved_hud_version = user.hud_used.hud_version
		user.hud_used.show_hud(HUD_STYLE_REDUCED)
	START_PROCESSING(SSprocessing, src)
	update()

/datum/aq_ship_hud/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	if(ship)
		UnregisterSignal(ship, COMSIG_PARENT_QDELETING)
	if(user)
		remove_from_screen()
		if(saved_hud_version && user.hud_used && user.hud_used.hud_version == HUD_STYLE_REDUCED)
			user.hud_used.show_hud(saved_hud_version)
		if(user.aq_ship_hud == src)
			user.aq_ship_hud = null
	QDEL_NULL(radar)
	for(var/id in segments)
		qdel(segments[id])
	segments.Cut()
	user = null
	ship = null
	return ..()

/datum/aq_ship_hud/proc/on_ship_deleted(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/aq_ship_hud/process(delta_time)
	if(QDELETED(user) || QDELETED(ship) || user.overmap_ship != ship || (ship.pilot != user && ship.gunner != user))
		qdel(src)
		return PROCESS_KILL
	// impulsy aktywnego radaru wysyła tylko ui_data() okna DRADIS, a w kompaktowym układzie okno jest zwykle zamknięte;
	// niezależnie od tego, czy radar jest widoczny (czasownik chowania panelu)
	var/obj/machinery/computer/ship/dradis/dradis = ship.dradis
	if(dradis?.sensor_mode == SENSOR_MODE_RADAR)
		dradis.send_radar_pulse()
	update()

/datum/aq_ship_hud/proc/remove_from_screen()
	if(!user?.client)
		return
	user.client.screen -= radar
	for(var/id in segments)
		user.client.screen -= segments[id]

/datum/aq_ship_hud/proc/update()
	var/client/C = user.client
	if(!C)
		return
	if(user.aquila_console_hidden)
		remove_from_screen()
		return
	radar.refresh(C)
	update_bar(C)

/// Segmenty paska: id => tekst. Kolejność listy to kolejność na ekranie.
/datum/aq_ship_hud/proc/bar_contents()
	. = list()
	var/is_pilot = ship.pilot == user
	var/is_gunner = ship.gunner == user
	if(is_pilot)
		.["brakes"] = ship.brakes ? "Hamulec: wł." : "Hamulec: wył."
		.["rotation"] = ship.move_by_mouse ? "Ster: mysz" : "Ster: klawisze"
	if(is_gunner)
		var/datum/overmap_ship_weapon/weapon = ship.controlled_weapon_datum?[user]
		// długie nazwy („Główne stanowisko wyposażenia”) rozpychały pasek poza ekran; pełna nazwa jest w Shift+klik
		var/weapon_name = weapon ? weapon.name : "brak"
		if(length_char(weapon_name) > AQ_SHIP_BAR_WEAPON_CHARS)
			weapon_name = "[copytext_char(weapon_name, 1, AQ_SHIP_BAR_WEAPON_CHARS)]…"
		.["weapon"] = "Broń: [weapon_name]"
		if(weapon)
			.["ammo"] = "[weapon.get_ammo()]/[weapon.get_max_ammo()]"
	.["hull"] = "Kadłub [aq_ship_hull_percent(ship)]%"
	if(is_pilot && istype(ship, /obj/structure/overmap/small_craft))
		// okno myśliwca (silnik, dokowanie, owiewka, paliwo); bez segmentu otwierało się tylko przy wsiadaniu
		.["controls"] = "Panel"
		.["eject"] = (eject_armed_until > world.time) ? "Potwierdź katapultę!" : "Katapulta"
	if(ship.dradis)
		.["dradis"] = "DRADIS"

/proc/aq_ship_hull_percent(obj/structure/overmap/ship)
	if(!ship.max_integrity || ship.structure_crit)
		return 0
	return clamp(round(ship.obj_integrity / ship.max_integrity * 100), 0, 100)

/// Kolor tekstu segmentu (ostrzeżenia na czerwono)
/datum/aq_ship_hud/proc/segment_colour(id)
	switch(id)
		if("hull")
			var/percent = aq_ship_hull_percent(ship)
			if(percent < 25)
				return "#ff5050"
			if(percent < 50)
				return "#ffb340"
		if("brakes")
			return ship.brakes ? "#ffb340" : null
		if("eject")
			return (eject_armed_until > world.time) ? "#ff5050" : "#c0c0c0"
		if("dradis")
			return "#7fd6ff"

/datum/aq_ship_hud/proc/update_bar(client/C)
	var/list/contents = bar_contents()
	// segmenty, których już nie ma (np. ktoś przejął stanowisko strzelca)
	for(var/id in segments.Copy())
		if(!(id in contents))
			C.screen -= segments[id]
			qdel(segments[id])
			segments -= id
	var/list/widths = list()
	var/total = 0
	for(var/id in contents)
		var/width = aq_ship_bar_width(contents[id])
		widths[id] = width
		total += width + AQ_BAR_GAP
	total -= AQ_BAR_GAP
	var/x = -round(total / 2)
	for(var/id in contents)
		var/atom/movable/screen/aq_ship_bar_segment/segment = segments[id]
		if(!segment)
			segment = new
			segment.ship_hud = src
			segment.segment_id = id
			segments[id] = segment
		segment.set_content(contents[id], segment_colour(id), widths[id], "CENTER:[x],SOUTH+1:4")
		if(!(segment in C.screen))
			C.screen += segment
		x += widths[id] + AQ_BAR_GAP

/// Szerokość segmentu dla tekstu (czcionka maptekstu ma ok. 5 px na znak)
/proc/aq_ship_bar_width(text)
	return clamp(length_char(text) * 5 + 14, 40, 160)

/datum/aq_ship_hud/proc/use_segment(id)
	switch(id)
		if("brakes")
			ship.toggle_brakes()
		if("rotation")
			ship.toggle_move_mode()
		if("weapon", "ammo")
			ship.cycle_firemode(user)
		if("dradis")
			ship.dradis?.attack_hand(user)
			return
		if("eject")
			try_eject()
			return
		if("controls")
			ship.ui_interact(user)
			return
		if("hull")
			return
	if(ship.helm && prob(80))
		playsound(ship.helm, pick(GLOB.computer_beeps), 100, 1)
	addtimer(CALLBACK(src, PROC_REF(update)), 1)

/// Katapulta: pierwsze kliknięcie uzbraja, drugie w ciągu AQ_BAR_EJECT_ARM_TIME katapultuje (zamiast dwóch przełączników panelu)
/datum/aq_ship_hud/proc/try_eject()
	var/obj/structure/overmap/small_craft/craft = ship
	if(!istype(craft))
		return
	ship.relay('nsv13/sound/effects/fighters/switch.ogg')
	if(eject_armed_until <= world.time)
		eject_armed_until = world.time + AQ_BAR_EJECT_ARM_TIME
		to_chat(user, "<span class='warning'>Katapulta uzbrojona. Kliknij ją jeszcze raz w ciągu [DisplayTimeText(AQ_BAR_EJECT_ARM_TIME)], żeby wystrzelić kapsułę.</span>")
		update()
		addtimer(CALLBACK(src, PROC_REF(update)), AQ_BAR_EJECT_ARM_TIME + 1)
		return
	eject_armed_until = 0
	if(craft.aquila_can_manual_eject(user))
		craft.aquila_manual_eject(user)

// ---------------------------------------------------------------- pasek

/atom/movable/screen/aq_ship_bar_segment
	name = "pasek statku"
	plane = HUD_PLANE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	maptext_height = AQ_BAR_HEIGHT
	maptext_y = 5
	var/datum/aq_ship_hud/ship_hud
	var/segment_id
	var/last_key

/atom/movable/screen/aq_ship_bar_segment/Destroy()
	ship_hud = null
	return ..()

/// Tło to rozciągnięta nakładka (rozciąganie samego obiektu rozciągałoby też tekst)
/atom/movable/screen/aq_ship_bar_segment/proc/set_content(text, colour, width, new_screen_loc)
	if(screen_loc != new_screen_loc)
		screen_loc = new_screen_loc
	var/key = "[text]|[colour]|[width]"
	if(key == last_key)
		return
	last_key = key
	name = text
	cut_overlays()
	var/image/background = image('aquila/icons/overmap/gui/compact/bar_segment.png')
	var/scale = width / 32
	background.transform = matrix(scale, 0, (scale - 1) * 16, 0, 1, 0)
	add_overlay(background)
	maptext_width = width
	maptext = MAPTEXT("<div align='center'><font color='[colour || "#e8e8e8"]'>[text]</font></div>")

/atom/movable/screen/aq_ship_bar_segment/Click(location, control, params)
	if(!ship_hud || usr != ship_hud.user)
		return
	if(LAZYACCESS(params2list(params), SHIFT_CLICK))
		to_chat(usr, "<span class='notice'>Pasek statku: kliknij segment, żeby przełączyć hamulec, sterowanie albo broń; Panel otwiera okno myśliwca (silnik, dokowanie, owiewka), a DRADIS pełne okno radaru. Skróty: Alt (hamulec), C (sterowanie), spacja (broń). Stary duży panel włączysz w preferencjach („Klasyczny panel sterowania”).</span>")
		var/datum/overmap_ship_weapon/weapon = ship_hud.ship.controlled_weapon_datum?[usr]
		if(segment_id == "weapon" && weapon)
			to_chat(usr, "<span class='notice'>Wybrana broń: [weapon.name].</span>")
		return
	ship_hud.use_segment(segment_id)

// ---------------------------------------------------------------- radar

/atom/movable/screen/aq_ship_radar
	name = "radar"
	icon = 'aquila/icons/overmap/gui/compact/radar_bg.png'
	plane = HUD_PLANE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	screen_loc = "EAST-4:-8,NORTH-4:-8"
	var/datum/aq_ship_hud/ship_hud

/atom/movable/screen/aq_ship_radar/Destroy()
	ship_hud = null
	return ..()

/atom/movable/screen/aq_ship_radar/Click(location, control, params)
	if(!ship_hud || usr != ship_hud.user)
		return
	if(LAZYACCESS(params2list(params), SHIFT_CLICK))
		to_chat(usr, "<span class='notice'>Radar: twój statek w środku (strzałka), sojusznicy na zielono, wrogowie na czerwono, nierozpoznane kontakty na pomarańczowo. Zasięg tarczy to zasięg sensorów DRADIS. Kliknięcie otwiera pełne okno DRADIS.</span>")
		return
	ship_hud.ship.dradis?.attack_hand(usr)

/atom/movable/screen/aq_ship_radar/proc/refresh(client/C)
	if(!(src in C.screen))
		C.screen += src
	var/obj/structure/overmap/ship = ship_hud.ship
	cut_overlays()
	var/obj/machinery/computer/ship/dradis/dradis = ship.dradis
	var/range = max(dradis ? dradis.sensor_range : SENSOR_RANGE_DEFAULT, 1)
	for(var/list/contact as anything in aq_radar_contacts(ship, dradis))
		var/atom/thing = contact["atom"]
		var/dx = (thing.x - ship.x) / range * AQ_RADAR_RADIUS
		var/dy = (thing.y - ship.y) / range * AQ_RADAR_RADIUS
		var/dist = sqrt(dx * dx + dy * dy)
		var/alpha_mult = contact["alpha"]
		if(dist > AQ_RADAR_RADIUS - 4) // poza tarczą: na krawędzi, przygaszony
			dx *= (AQ_RADAR_RADIUS - 4) / dist
			dy *= (AQ_RADAR_RADIUS - 4) / dist
			alpha_mult *= 0.5
		var/image/blip = image('aquila/icons/overmap/gui/compact/radar_blip.png')
		blip.color = contact["colour"]
		blip.alpha = round(255 * clamp(alpha_mult, 0.2, 1))
		blip.pixel_x = round(80 - 3.5 + dx)
		blip.pixel_y = round(80 - 3.5 + dy)
		add_overlay(blip)
	var/image/self = image('aquila/icons/overmap/gui/compact/radar_self.png')
	self.color = "#00ffff"
	self.pixel_x = 80 - 4.5
	self.pixel_y = 80 - 4.5
	self.transform = turn(matrix(), ship.angle)
	add_overlay(self)

/// Kontakty radaru jak w DRADIS (ui_data w nsv13/code/modules/overmap/radar.dm): lista list("atom", "colour", "alpha")
/proc/aq_radar_contacts(obj/structure/overmap/ship, obj/machinery/computer/ship/dradis/dradis)
	. = list()
	var/sensor_range = dradis ? dradis.sensor_range : SENSOR_RANGE_DEFAULT
	for(var/obj/structure/overmap/OM as anything in GLOB.overmap_objects)
		if(OM == ship || OM.z != ship.z)
			continue
		var/friendly = OM.faction == ship.faction
		var/sensor_visible = friendly ? SENSOR_VISIBILITY_FULL : ((overmap_dist(ship, OM) > max(sensor_range * 2, OM.sensor_profile)) ? 0 : OM.is_sensor_visible(ship))
		if(sensor_visible < SENSOR_VISIBILITY_FAINT && !ship.target_painted[OM])
			continue
		var/in_range = (overmap_dist(ship, OM) <= max(sensor_range, OM.sensor_profile)) || friendly || ship.target_painted[OM]
		var/colour
		if(istype(OM, /obj/structure/overmap/asteroid))
			if(!dradis?.show_asteroids)
				continue
			var/obj/structure/overmap/asteroid/AS = OM
			if(AS.required_tier > dradis.mining_sensor_tier)
				continue
			colour = "#80523c"
		else
			colour = friendly ? "#32cd32" : "#ff3030"
		if(!in_range)
			colour = "#a66300"
		var/alpha = (sensor_visible <= SENSOR_VISIBILITY_FAINT && !ship.target_painted[OM]) ? sensor_visible : 1
		. += list(list("atom" = OM, "colour" = colour, "alpha" = alpha))
	for(var/obj/effect/overmap_anomaly/OA in ship.current_system?.system_contents)
		if(OA.z == ship.z)
			. += list(list("atom" = OA, "colour" = "#eb9534", "alpha" = 0.8))

#undef AQ_RADAR_RADIUS
#undef AQ_BAR_HEIGHT
#undef AQ_BAR_GAP
#undef AQ_BAR_EJECT_ARM_TIME
#undef AQ_SHIP_BAR_WEAPON_CHARS
