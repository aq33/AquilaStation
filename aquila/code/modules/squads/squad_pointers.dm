// Wskaźniki znaczników na krawędzi ekranu: gdy znacznika drużyny nie widać, przy krawędzi ekranu stoi jego ikona
// ze strzałką w stronę celu i odległością w kratkach. Znacznik na innym pokładzie tego samego okrętu ma dopisek „wyżej”/„niżej”.
// Odświeżane przy ruchu członka drużyny, postawieniu i zdjęciu znacznika.

/// Ile pokładów w górę lub w dół szukamy znacznika
#define SQUAD_POINTER_MAX_DECKS 4

/// Typ znacznika -> pierwsza klatka jego sprite'a (sprite'y TGMC migają, a wskaźnik ma być widoczny cały czas)
GLOBAL_LIST_EMPTY(aq_marker_pointer_icons)

/atom/movable/screen/aq_marker_pointer
	icon = 'aquila/icons/squads/markers.dmi'
	icon_state = "pointer_back"
	plane = ABOVE_HUD_PLANE
	layer = ABOVE_HUD_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = APPEARANCE_UI | KEEP_TOGETHER
	maptext_width = 64
	maptext_height = 16
	maptext_x = -16
	maptext_y = -12
	var/mutable_appearance/arrow
	var/mutable_appearance/marker_icon
	/// Na ekranie klienta
	var/shown = FALSE

/atom/movable/screen/aq_marker_pointer/Initialize(mapload, marker_type, arrow_colour)
	. = ..()
	if(!GLOB.aq_marker_pointer_icons[marker_type])
		GLOB.aq_marker_pointer_icons[marker_type] = icon(icon, "marker_[marker_type]", SOUTH, 1)
	marker_icon = mutable_appearance(GLOB.aq_marker_pointer_icons[marker_type], layer = layer + 0.05, plane = FLOAT_PLANE)
	marker_icon.transform = matrix().Scale(0.75)
	arrow = mutable_appearance(icon, "pointer_arrow", layer + 0.1, FLOAT_PLANE)
	arrow.color = arrow_colour
	arrow.appearance_flags = RESET_COLOR | KEEP_APART

/atom/movable/screen/aq_marker_pointer/Destroy()
	arrow = null
	marker_icon = null
	return ..()

/// Ustawia wskaźnik przy krawędzi ekranu; dx/dy w kratkach od środka ekranu, half_w/half_h to połowa widoku w kratkach
/atom/movable/screen/aq_marker_pointer/proc/aim_at(dx, dy, half_w, half_h, deck_text)
	var/edge_w = max(1, half_w - 1.2) // z dala od kolumn HUD-u przy krawędziach
	var/edge_h = max(1, half_h - 1.2)
	var/scale = 1
	if(dx)
		scale = min(scale, edge_w / abs(dx))
	if(dy)
		scale = min(scale, edge_h / abs(dy))
	screen_loc = "CENTER:[round(dx * scale * world.icon_size)],CENTER:[round(dy * scale * world.icon_size)]"
	cut_overlays()
	add_overlay(marker_icon)
	if(dx || dy)
		var/mutable_appearance/turned_arrow = new /mutable_appearance(arrow)
		// strzałka w pliku wskazuje północ; arctan(x, y) liczy kąt od osi X przeciwnie do zegara, Turn() obraca zgodnie z nim
		turned_arrow.transform = matrix().Turn(90 - arctan(dx, dy))
		add_overlay(turned_arrow)
	var/distance = round(sqrt(dx * dx + dy * dy))
	maptext = MAPTEXT("<span style='text-align:center;-dm-text-outline:1px black'>[deck_text ? "[deck_text] " : ""][distance]</span>")

/datum/aq_squad_marker
	/// Wskaźniki na krawędzi ekranu: klient -> /atom/movable/screen/aq_marker_pointer
	var/list/pointers

/datum/aq_squad_marker/Destroy()
	for(var/client/viewer as anything in pointers)
		var/atom/movable/screen/aq_marker_pointer/pointer = pointers[viewer]
		viewer?.screen -= pointer
		qdel(pointer)
	pointers = null
	return ..()

/// O ile pokładów target_z jest nad from_z (ujemne = pod), null gdy to nie ten sam stos pokładów
/proc/aq_deck_offset(from_z, target_z)
	if(from_z == target_z)
		return 0
	var/z = from_z
	for(var/step in 1 to SQUAD_POINTER_MAX_DECKS)
		if(z > length(SSmapping.multiz_levels) || !SSmapping.multiz_levels[z]?[Z_LEVEL_UP])
			break
		z++
		if(z == target_z)
			return step
	z = from_z
	for(var/step in 1 to SQUAD_POINTER_MAX_DECKS)
		if(z > length(SSmapping.multiz_levels) || !SSmapping.multiz_levels[z]?[Z_LEVEL_DOWN])
			break
		z--
		if(z == target_z)
			return -step
	return null

/datum/aq_squad_marker/proc/update_pointer(mob/member)
	var/client/viewer = member?.client
	if(!viewer)
		return
	var/atom/movable/screen/aq_marker_pointer/pointer = pointers?[viewer]
	var/turf/member_turf = get_turf(member)
	var/deck_offset = (member_turf && target_turf) ? aq_deck_offset(member_turf.z, target_turf.z) : null
	var/dx = isnull(deck_offset) ? 0 : target_turf.x - member_turf.x
	var/dy = isnull(deck_offset) ? 0 : target_turf.y - member_turf.y
	var/list/view_size = getviewsize(viewer.view)
	var/half_w = (view_size[1] - 1) / 2
	var/half_h = (view_size[2] - 1) / 2
	// znacznik widać w świecie (albo jest na innym okręcie): wskaźnik niepotrzebny
	if(isnull(deck_offset) || (!deck_offset && abs(dx) <= half_w && abs(dy) <= half_h))
		if(pointer?.shown)
			viewer.screen -= pointer
			pointer.shown = FALSE
		return
	if(!pointer)
		pointer = new(null, marker_type, squad?.colour)
		LAZYSET(pointers, viewer, pointer)
	pointer.aim_at(dx, dy, half_w, half_h, deck_offset > 0 ? "wyżej" : (deck_offset < 0 ? "niżej" : null))
	viewer.screen |= pointer // Login() czyści client.screen, a flaga shown mogła zostać
	pointer.shown = TRUE

/datum/aq_squad_marker/proc/remove_pointer(mob/member)
	var/client/viewer = member?.client
	var/atom/movable/screen/aq_marker_pointer/pointer = pointers?[viewer]
	if(!pointer)
		return
	viewer.screen -= pointer
	pointers -= viewer
	qdel(pointer)

/datum/squad/proc/aq_update_pointers(mob/living/carbon/human/member)
	for(var/marker_type in aq_markers)
		var/datum/aq_squad_marker/marker = aq_markers[marker_type]
		marker.update_pointer(member)

/datum/squad/proc/aq_on_member_moved(mob/living/carbon/human/source)
	SIGNAL_HANDLER
	if(source.client && length(aq_markers))
		aq_update_pointers(source)

/datum/squad/aq_add_marker_images(mob/living/carbon/human/member)
	. = ..()
	aq_update_pointers(member)

/datum/squad/aq_remove_marker_images(mob/living/carbon/human/member)
	. = ..()
	for(var/marker_type in aq_markers)
		var/datum/aq_squad_marker/marker = aq_markers[marker_type]
		marker.remove_pointer(member)

/datum/squad/add_member(mob/living/carbon/human/H, give_items = FALSE)
	. = ..()
	if(ishuman(H) && (H in members))
		RegisterSignal(H, COMSIG_MOVABLE_MOVED, PROC_REF(aq_on_member_moved), override = TRUE)
		// plany pokładów okrętu od razu, żeby rozkazy znacznikami miały sektor („C2”) bez otwierania mapy
		for(var/z in SSmapping.levels_by_trait(ZTRAIT_STATION))
			if(!GLOB.squad_map_assets["[z]"])
				aq_squad_map_asset(z)

/datum/squad/remove_member(mob/living/carbon/human/H)
	. = ..()
	if(istype(H))
		UnregisterSignal(H, COMSIG_MOVABLE_MOVED)

/datum/squad/aq_place_marker(mob/living/placer, turf/target_turf, marker_type, from_console = FALSE)
	. = ..()
	var/datum/aq_squad_marker/marker = .
	if(!marker)
		return
	for(var/mob/living/carbon/human/member as anything in members)
		marker.update_pointer(member)

#undef SQUAD_POINTER_MAX_DECKS
