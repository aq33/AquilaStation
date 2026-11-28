// AQUILA - koniec rundy po zniszczeniu okrętu gracza: zamiast klatek z cudzego filmu kinematyk składany z ikony
// prawdziwego okrętu z overmapy. Seria trafień w kadłub (z nakładkami uszkodzeń, które okręt ma w .dmi), pożary,
// koziołkowanie, biały błysk, wielki wybuch i przypalony wrak w trzech kawałkach, które powoli dryfują do końca planszy.
// Wybuchy to te same ikony Goona co wybuchy okrętów na overmapie (overmap_explosion). Pełne nadpisanie content()
// (wpis w LEGACY_OVERRIDES.md): stara wersja tylko odtwarzała animację z nsv13/icons/effects/station_explosion.dmi.

/// Ikona i stan okrętu, który właśnie ginie (ustawiane w Destroy przed kinematykiem; bez tego domyślna fregata)
GLOBAL_LIST_EMPTY(ship_kaboom_source)

/// Bok sprite'a okrętu po powiększeniu: obrócony z wybuchami i kawałkami wraku mieści się w widoku 15×15 (480 px)
#define KABOOM_SHIP_SIZE 224
#define KABOOM_HITS 5
#define KABOOM_LAYER (SPLASHSCREEN_LAYER + 1)

/obj/structure/overmap/Destroy()
	if(role == MAIN_OVERMAP)
		GLOB.ship_kaboom_source = list(icon, icon_state)
	return ..()

/// Element sceny kinematyku (dziecko vis_contents planszy, nie leży na mapie)
/obj/effect/abstract/ship_kaboom
	icon = null
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = PIXEL_SCALE
	vis_flags = VIS_INHERIT_PLANE
	plane = SPLASHSCREEN_PLANE
	layer = KABOOM_LAYER

/// Plansza ze środkiem w środku widoku: wszystkie elementy sceny są jej dziećmi.
/// Ma przezroczystą ikonę, bo vis_contents obiektu ekranu bez ikony klient rysuje niepewnie.
/atom/movable/screen/cinematic/ship_kaboom_stage
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "transparent"
	screen_loc = "CENTER"
	layer = KABOOM_LAYER

/datum/cinematic/nsv_kaboom
	/// Plansza sceny (tło gwiazd to zwykły ekran kinematyku)
	var/atom/movable/screen/cinematic/ship_kaboom_stage/stage
	/// Biały błysk na cały widok
	var/atom/movable/screen/cinematic/flash
	var/obj/effect/abstract/ship_kaboom/ship
	var/ship_icon = 'nsv13/icons/overmap/new/nanotrasen/frigate.dmi'
	var/ship_state = "frigate"
	var/ship_width = 48
	var/ship_height = 48
	/// Powiększenie sprite'a okrętu (całkowite, żeby piksele zostały ostre)
	var/ship_scale = 6
	/// Punkty trafień w pikselach ikony okrętu (lista par x, y; 1,1 to lewy dolny róg)
	var/list/hit_points = list()
	/// Kawałki wraku
	var/list/obj/effect/abstract/ship_kaboom/wreck = list()
	/// Wszystkie elementy sceny (vis_contents nie puszcza referencji: przed qdel trzeba je odpiąć)
	var/list/obj/effect/abstract/ship_kaboom/parts = list()

/datum/cinematic/nsv_kaboom/New()
	. = ..()
	// Wszystko mieści się w widoku: obiekt ekranu wystający poza widok (duży obraz, powiększenie) każe klientowi
	// poszerzyć pole mapy, a wtedy poza tłem widać nieoświetlone kafle, a środek ekranu się przesuwa. Tło i błysk
	// sięgają kafel dalej, bo HUD postaci sam poszerza pole mapy o kolumnę (stąd 512 px w kinematykach tg)
	screen.icon = 'aquila/icons/effects/ship_kaboom_fill.dmi'
	screen.icon_state = "black"
	screen.screen_loc = "WEST-1,SOUTH-1 to EAST+1,NORTH+1"
	flash = new
	flash.icon = 'aquila/icons/effects/ship_kaboom_fill.dmi'
	flash.icon_state = "white"
	flash.screen_loc = "WEST-1,SOUTH-1 to EAST+1,NORTH+1"
	flash.layer = KABOOM_LAYER + 5
	flash.alpha = 0
	stage = new
	var/list/source = GLOB.ship_kaboom_source
	if(length(source) == 2 && source[1] && (source[2] in icon_states(source[1])))
		ship_icon = source[1]
		ship_state = source[2]
	GLOB.ship_kaboom_source = list()
	build_scene()

/datum/cinematic/nsv_kaboom/Destroy()
	for(var/client/C as anything in watching)
		C?.screen -= list(stage, flash)
	ship?.vis_contents.Cut()
	stage?.vis_contents.Cut()
	wreck.Cut()
	ship = null
	QDEL_LIST(parts)
	QDEL_NULL(stage)
	QDEL_NULL(flash)
	return ..()

/datum/cinematic/nsv_kaboom/show_to(mob/M, client/C)
	..()
	C?.screen |= list(stage, flash)

/// Elementy sceny: gwiazdy (15×15 kafli, najmniejszy widok), okręt (dziobem w prawo) i punkty trafień
/datum/cinematic/nsv_kaboom/proc/build_scene()
	var/icon/ship_sprite = icon(ship_icon, ship_state, SOUTH, 1)
	ship_width = ship_sprite.Width()
	ship_height = ship_sprite.Height()
	ship_scale = max(1, round(KABOOM_SHIP_SIZE / max(ship_width, ship_height)))
	var/obj/effect/abstract/ship_kaboom/stars = new_part()
	stars.icon = 'aquila/icons/effects/ship_kaboom.dmi'
	stars.icon_state = "stars"
	place_centered(stars, 480, 480)
	stage.vis_contents += stars
	ship = new_part()
	ship.icon = ship_icon
	ship.icon_state = ship_state
	ship.layer = KABOOM_LAYER + 1
	place_centered(ship, ship_width, ship_height, -30, 0)
	ship.transform = matrix(ship_scale, MATRIX_SCALE) * matrix(90, MATRIX_ROTATE)
	stage.vis_contents += ship
	hit_points = pick_hit_points(ship_sprite, KABOOM_HITS)

/datum/cinematic/nsv_kaboom/proc/new_part()
	var/obj/effect/abstract/ship_kaboom/part = new
	parts += part
	return part

/// Odpina element ze sceny i usuwa go
/datum/cinematic/nsv_kaboom/proc/remove_part(obj/effect/abstract/ship_kaboom/part)
	ship?.vis_contents -= part
	stage?.vis_contents -= part
	parts -= part
	qdel(part)

/// Ustawia element tak, by jego środek wypadł w środku planszy (plus przesunięcie)
/datum/cinematic/nsv_kaboom/proc/place_centered(atom/movable/thing, width, height, offset_x = 0, offset_y = 0)
	thing.pixel_x = 16 - round(width / 2) + offset_x
	thing.pixel_y = 16 - round(height / 2) + offset_y

/// Kilka nieprzezroczystych pikseli kadłuba, rozrzuconych po całym okręcie
/datum/cinematic/nsv_kaboom/proc/pick_hit_points(icon/sprite, count)
	. = list()
	var/spread = max(ship_width, ship_height) / 5
	for(var/attempt in 1 to 300)
		if(length(.) >= count)
			break
		var/x = rand(1, ship_width)
		var/y = rand(1, ship_height)
		if(!sprite.GetPixel(x, y))
			continue
		var/too_close = FALSE
		for(var/list/other as anything in .)
			if(abs(other[1] - x) + abs(other[2] - y) < spread)
				too_close = TRUE
				break
		if(!too_close)
			. += list(list(x, y))
	if(!length(.))
		. += list(list(round(ship_width / 2), round(ship_height / 2)))

/// Wybuch Goona przypięty do kadłuba w punkcie ikony (dziedziczy obrót i powiększenie okrętu)
/datum/cinematic/nsv_kaboom/proc/hull_effect(list/point, effect_icon, effect_state, size, effect_scale, layer_offset = 2)
	var/obj/effect/abstract/ship_kaboom/effect = new_part()
	effect.icon = effect_icon
	effect.icon_state = effect_state
	effect.layer = KABOOM_LAYER + layer_offset
	effect.pixel_x = point[1] - 1 - round(size / 2)
	effect.pixel_y = point[2] - 1 - round(size / 2)
	effect.transform = matrix(effect_scale / ship_scale, MATRIX_SCALE)
	ship.vis_contents += effect
	return effect

/datum/cinematic/nsv_kaboom/proc/hit(index)
	var/list/point = hit_points[((index - 1) % length(hit_points)) + 1]
	var/obj/effect/abstract/ship_kaboom/boom = hull_effect(point, 'nsv13/goonstation/icons/hugeexplosion2.dmi', "", 80, 1.1, 3)
	flick("explosion", boom)
	addtimer(CALLBACK(src, PROC_REF(remove_part), boom), 2.9 SECONDS)
	hull_effect(point, 'icons/effects/fire.dmi', "1", 32, 1.4, 2)
	var/static/list/damage_states = list("Forward Port", "Aft Starboard", "Forward Starboard", "Aft Port")
	if(index <= length(damage_states) && (damage_states[index] in icon_states(ship_icon)))
		ship.add_overlay(icon(ship_icon, damage_states[index]))
	cinematic_sound(sound(pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg', 'sound/effects/explosion3.ogg')))
	shake(4, 3)

/// Drżenie całej sceny
/datum/cinematic/nsv_kaboom/proc/shake(strength, times)
	animate(stage, pixel_x = rand(-strength, strength), pixel_y = rand(-strength, strength), time = 0.5, flags = ANIMATION_PARALLEL)
	for(var/i in 2 to times)
		animate(pixel_x = rand(-strength, strength), pixel_y = rand(-strength, strength), time = 0.5)
	animate(pixel_x = 0, pixel_y = 0, time = 0.5)

/// Wrak: trzy przypalone pasy kadłuba (dziób, śródokręcie, rufa), które rozlatują się i powoli obracają
/datum/cinematic/nsv_kaboom/proc/break_apart(angle)
	var/list/bands = list(list(round(ship_height * 0.62) + 1, ship_height, 1), list(round(ship_height * 0.32) + 1, round(ship_height * 0.62), 0), list(1, round(ship_height * 0.32), -1))
	var/list/spins = list(-50, 25, 70)
	for(var/i in 1 to length(bands))
		var/list/band = bands[i]
		var/icon/piece_icon = icon(ship_icon, ship_state, SOUTH, 1)
		for(var/overlay_state in list("Forward Port", "Aft Starboard", "Forward Starboard", "Aft Port"))
			if(overlay_state in icon_states(ship_icon))
				piece_icon.Blend(icon(ship_icon, overlay_state), ICON_OVERLAY)
		if(band[1] > 1)
			piece_icon.DrawBox(null, 1, 1, ship_width, band[1] - 1)
		if(band[2] < ship_height)
			piece_icon.DrawBox(null, 1, band[2] + 1, ship_width, ship_height)
		var/obj/effect/abstract/ship_kaboom/piece = new_part()
		piece.icon = piece_icon
		piece.color = "#7a5a48"
		piece.layer = KABOOM_LAYER + 1
		piece.pixel_x = ship.pixel_x
		piece.pixel_y = ship.pixel_y
		piece.transform = ship.transform
		stage.vis_contents += piece
		wreck += piece
		// Kierunek wzdłuż osi okrętu (dziób do przodu, rufa do tyłu) plus trochę w bok
		var/push = band[3] * 45 + rand(-10, 10)
		var/side = rand(-25, 25)
		var/dx = push * sin(angle) + side * cos(angle)
		var/dy = push * cos(angle) - side * sin(angle)
		animate(piece, pixel_x = piece.pixel_x + dx, pixel_y = piece.pixel_y + dy, transform = matrix(ship_scale, MATRIX_SCALE) * matrix(angle + spins[i], MATRIX_ROTATE), time = 4 SECONDS, easing = QUAD_EASING | EASE_OUT)
		animate(pixel_x = piece.pixel_x + dx * 1.3, pixel_y = piece.pixel_y + dy * 1.3, transform = matrix(ship_scale, MATRIX_SCALE) * matrix(angle + spins[i] * 1.8, MATRIX_ROTATE), time = 25 SECONDS)

/datum/cinematic/nsv_kaboom/content()
	// Dryf kończy się przed wybuchem (6,1 s): wybuch i wrak biorą ship.pixel_x, a to już wartość końcowa
	animate(ship, pixel_x = ship.pixel_x + 40, time = 6 SECONDS, flags = ANIMATION_PARALLEL)
	sleep(1 SECONDS)
	for(var/i in 1 to 3)
		hit(i)
		sleep(0.8 SECONDS)
	// Okręt traci sterowność: koziołkuje coraz szybciej
	var/angle = 100
	animate(ship, transform = matrix(ship_scale, MATRIX_SCALE) * matrix(angle, MATRIX_ROTATE), time = 0.6 SECONDS, flags = ANIMATION_PARALLEL)
	for(var/step in 2 to 4)
		angle += step * 10
		animate(transform = matrix(ship_scale, MATRIX_SCALE) * matrix(angle, MATRIX_ROTATE), time = 0.6 SECONDS)
	hit(4)
	sleep(0.7 SECONDS)
	hit(5)
	sleep(1.2 SECONDS)
	// Przed końcem kadłub miga
	animate(ship, color = "#ffb090", time = 0.1 SECONDS, loop = 4, flags = ANIMATION_PARALLEL)
	animate(color = "#ffffff", time = 0.1 SECONDS)
	sleep(0.8 SECONDS)
	// Błysk i wielki wybuch
	flash.alpha = 255
	animate(flash, alpha = 0, time = 0.7 SECONDS)
	var/obj/effect/abstract/ship_kaboom/blast = new_part()
	blast.icon = 'nsv13/goonstation/icons/hugeexplosion2.dmi'
	blast.icon_state = ""
	blast.layer = KABOOM_LAYER + 4
	place_centered(blast, 80, 80, ship.pixel_x - (16 - round(ship_width / 2)), ship.pixel_y - (16 - round(ship_height / 2)))
	blast.transform = matrix(4.5, MATRIX_SCALE)
	stage.vis_contents += blast
	flick("explosion", blast)
	cinematic_sound(sound('nsv13/sound/effects/ship/damage/ship_explode.ogg'))
	cinematic_sound(sound('sound/effects/explosion_distant.ogg'))
	shake(12, 6)
	break_apart(angle)
	ship.alpha = 0
	sleep(3 SECONDS)
	remove_part(blast)
	special()

#undef KABOOM_SHIP_SIZE
#undef KABOOM_HITS
#undef KABOOM_LAYER
