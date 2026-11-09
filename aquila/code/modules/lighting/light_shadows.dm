// PROTOTYP: cienie od ścian dla świateł ruchomych (latarki, kaski, PDA, borgi; overlay_lighting).
// Bez tego plama światła latarki to sam sprite i wizualnie świeci przez ściany.
//
// Każde włączone światło ruchome ma obiekt w swoim kaflu z trójkątami cienia za nieprzezroczystymi kaflami w zasięgu
// swojej plamy (light_shadow_geometry.dm). Obiekt się nie rysuje (render_target z gwiazdką), tylko służy za odwrotną maskę
// plamy TEGO światła (filtr na visible_mask). Światło stałe (narożnikowe) i inne latarki zostają bez zmian.
// Wcześniej maska była wspólna dla płaszczyzny O_LIGHTING_VISUAL_PLANE i cień jednej latarki wycinał światło drugiej
// (czarne kliny w oświetlonych miejscach, gdy za ścianą świeciła inna latarka).
//
// Ograniczenia:
// - cień liczony ze środka kafla światła; w trakcie kroku maska jedzie razem z plamą, więc cień przez chwilę
//   jest przesunięty o część kafla względem ścian,
// - bufor render_target jest przycinany do narysowanej zawartości, więc obiekt ma KEEP_TOGETHER i dwie prawie
//   przezroczyste kotwice (alfa 1) w rogach kwadratu wokół kafla światła: środek maski wypada na środku kafla.

/// Wyłącznik prototypu. Zmieniaj przez aq_set_light_shadows() (Advanced ProcCall), wtedy od razu chowa i odtwarza cienie.
GLOBAL_VAR_INIT(aq_light_shadows_enabled, TRUE)

/// Włączone światła ruchome stojące na kaflu. Dla zmian nieprzezroczystości kafli i wyłącznika.
GLOBAL_LIST_EMPTY(aq_shadow_lights)

/// Kolejny numer maski (nazwa render_target obiektu cienia)
GLOBAL_VAR_INIT(aq_light_shadow_serial, 0)

/// "dx,dy,ściany,zasięg" -> lista wyglądów trójkątów cienia kafla przesuniętego o (dx, dy) od światła. Wspólne dla wszystkich świateł.
GLOBAL_LIST_EMPTY(aq_light_shadow_cache)

#define AQ_OVERLAY_LIGHTING_ON (1<<0) // kopia LIGHTING_ON z overlay_lighting.dm (tam #undef na końcu pliku)

/proc/aq_light_shadow_appearances(dx, dy, hidden_faces, reach)
	var/key = "[dx],[dy],[hidden_faces],[reach]"
	. = GLOB.aq_light_shadow_cache[key]
	if(.)
		return
	var/list/appearances = list()
	for(var/matrix/triangle as anything in aq_light_shadow_matrices(dx, dy, hidden_faces, reach))
		var/mutable_appearance/shadow = mutable_appearance('aquila/icons/effects/light_shadow.dmi', "tri", FLOAT_LAYER, FLOAT_PLANE)
		shadow.transform = triangle
		appearances += shadow
	GLOB.aq_light_shadow_cache[key] = appearances
	return appearances

/// Dwa prawie przezroczyste trójkąty na kwadrat o połowie boku half wokół środka kafla światła (kotwice bufora maski)
/proc/aq_light_shadow_anchors(half)
	var/key = "anchor[half]"
	. = GLOB.aq_light_shadow_cache[key]
	if(.)
		return
	var/list/appearances = list()
	for(var/matrix/triangle in list(aq_shadow_triangle_matrix(-half, -half, half, -half, -half, half), aq_shadow_triangle_matrix(half, half, -half, half, half, -half)))
		var/mutable_appearance/anchor = mutable_appearance('aquila/icons/effects/light_shadow.dmi', "tri", FLOAT_LAYER, FLOAT_PLANE)
		anchor.transform = triangle
		anchor.alpha = 1
		appearances += anchor
	GLOB.aq_light_shadow_cache[key] = appearances
	return appearances

/// Włącza albo wyłącza cienie wszystkim światłom od razu
/proc/aq_set_light_shadows(enabled)
	GLOB.aq_light_shadows_enabled = !!enabled
	for(var/datum/component/overlay_lighting/light as anything in GLOB.aq_shadow_lights)
		light.aq_update_shadow()

/// Trójkąty cienia jednego światła. Stoi w kaflu światła i przeskakuje razem z nim (bez ślizgu).
/obj/effect/abstract/aq_light_shadow
	name = ""
	icon = null
	plane = AQ_LIGHT_SHADOW_PLANE
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	animate_movement = NO_STEPS
	// Bez KEEP_TOGETHER obiekt bez ikony, z samymi nakładkami, nie daje maski albo daje ją przesuniętą (sprawdzone na 516)
	appearance_flags = KEEP_TOGETHER

/obj/effect/abstract/aq_light_shadow/New(loc, ...)
	// Własna maska tego światła (gwiazdka: obiekt się nie rysuje). W New, bo komponent czyta nazwę od razu,
	// a w trakcie ładowania mapy Initialize przychodzi później
	render_target = "*AQ_LIGHT_SHADOW_[++GLOB.aq_light_shadow_serial]"
	return ..()

/obj/effect/abstract/aq_light_shadow/Initialize(mapload)
	. = ..()
	// Miękki brzeg cienia zamiast schodków po rozciągnięciu trójkąta
	add_filter("aq_shadow_soft", 1, gauss_blur_filter(1.5))

/atom/movable/screen/plane_master/aq_light_shadows
	name = "light shadows plane master"
	plane = AQ_LIGHT_SHADOW_PLANE
	appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	// Nazwa z gwiazdką, więc płaszczyzna nigdy się nie rysuje (obiekty cienia mają własne render_target)
	render_target = "*AQ_LIGHT_SHADOWS_UNUSED"

// Drzwi, żaluzje, budowa i rozbiórka ścian: światła ruchome w pobliżu przeliczają cień, także gdy stoją
/turf/reconsider_lights()
	. = ..()
	for(var/datum/component/overlay_lighting/light as anything in GLOB.aq_shadow_lights)
		var/turf/light_turf = light.aq_shadow?.loc
		if(!light_turf)
			light_turf = get_turf(light.current_holder)
		if(light_turf?.z == z && get_dist(light_turf, src) <= light.range + light.cast_range + 2)
			light.aq_update_shadow()

/datum/component/overlay_lighting
	/// PROTOTYP: trójkąty cienia tego światła
	var/obj/effect/abstract/aq_light_shadow/aq_shadow
	/// Zestaw trójkątów ostatnio położony na aq_shadow, żeby nie wysyłać tych samych nakładek ponownie
	var/aq_shadow_key
	/// Maska cienia ostatnio ustawiona na visible_mask (render_source i przesunięcie), null: bez maski
	var/aq_mask_key

/datum/component/overlay_lighting/Destroy()
	GLOB.aq_shadow_lights -= src
	QDEL_NULL(aq_shadow)
	return ..()

/datum/component/overlay_lighting/get_new_turfs()
	. = ..()
	aq_update_shadow()

/datum/component/overlay_lighting/remove_dynamic_lumi()
	. = ..()
	aq_hide_shadow()

/datum/component/overlay_lighting/make_luminosity_update()
	. = ..()
	if(!isturf(current_holder?.loc))
		aq_hide_shadow()

/datum/component/overlay_lighting/proc/aq_hide_shadow()
	GLOB.aq_shadow_lights -= src
	aq_shadow_key = null
	if(aq_shadow?.loc)
		aq_shadow.overlays.Cut()
		aq_shadow.abstract_move(null)

/// Przelicza trójkąty cienia dla nieprzezroczystych kafli w zasięgu plamy światła
/datum/component/overlay_lighting/proc/aq_update_shadow()
	var/turf/light_turf = get_turf(current_holder)
	if(!(overlay_lighting_flags & AQ_OVERLAY_LIGHTING_ON) || !light_turf || !isturf(current_holder.loc))
		aq_hide_shadow()
		return
	GLOB.aq_shadow_lights |= src
	if(!GLOB.aq_light_shadows_enabled)
		aq_set_shadow_mask(null)
		aq_shadow_key = null
		if(aq_shadow?.loc)
			aq_shadow.overlays.Cut()
			aq_shadow.abstract_move(null)
		return
	// Środek plamy światła w kaflach: przy świetle kierunkowym plama jest przesunięta przed trzymającego
	var/center_x = 0
	var/center_y = 0
	if(directional)
		center_x = round((directional_offset_x + (range - 1) * world.icon_size) / world.icon_size, 1)
		center_y = round((directional_offset_y + (range - 1) * world.icon_size) / world.icon_size, 1)
	var/turf/center_turf = locate(light_turf.x + center_x, light_turf.y + center_y, light_turf.z) || light_turf
	var/radius = CEILING(range, 1) + 1
	// Koniec cienia: najdalszy brzeg plamy od światła
	var/reach = round((sqrt(center_x * center_x + center_y * center_y) + radius) * world.icon_size, world.icon_size)
	var/static/list/face_dirs = list(SOUTH, EAST, NORTH, WEST)
	var/list/shadow_overlays = list()
	var/key = ""
	// Kafle z kwadratu wokół plamy, nie z view(): view() z kafla w ciemności nie widzi kafli poza blaskiem trzymającego,
	// a dalekie ściany snopa latarki zostałyby bez cienia. Ściany schowane za innymi dokładają cień, który i tak jest zakryty.
	for(var/turf/occluder as anything in RANGE_TURFS(radius, center_turf))
		if(!IS_OPAQUE_TURF(occluder))
			continue
		var/hidden_faces = 0
		for(var/face in 1 to 4)
			var/turf/neighbour = get_step(occluder, face_dirs[face])
			if(neighbour && IS_OPAQUE_TURF(neighbour))
				hidden_faces |= (1 << (face - 1))
		if(hidden_faces == 15)
			continue
		var/dx = occluder.x - light_turf.x
		var/dy = occluder.y - light_turf.y
		shadow_overlays += aq_light_shadow_appearances(dx, dy, hidden_faces, reach)
		key += "[dx],[dy],[hidden_faces];"
	if(!length(shadow_overlays))
		aq_set_shadow_mask(null)
		aq_shadow_key = null
		if(aq_shadow?.loc)
			aq_shadow.overlays.Cut()
			aq_shadow.abstract_move(null)
		return
	if(!aq_shadow)
		aq_shadow = new
	// Środek plamy (visible_mask) względem środka kafla światła w pikselach; maska ma leżeć środkiem na kaflu światła
	var/mask_x = current_holder.pixel_x + current_holder.pixel_w
	var/mask_y = current_holder.pixel_y + current_holder.pixel_z
	if(directional)
		mask_x += directional_offset_x + (range - 1) * world.icon_size
		mask_y += directional_offset_y + (range - 1) * world.icon_size
	aq_set_shadow_mask(aq_shadow.render_target, -mask_x, -mask_y)
	key = "[reach]|[key]"
	if(aq_shadow.loc == light_turf && aq_shadow_key == key)
		return
	if(aq_shadow.loc != light_turf)
		aq_shadow.abstract_move(light_turf)
	// Kotwice dalej niż najdalszy wierzchołek trójkąta (zasięg do 1,5 raza dalej przy ścianach na brzegu plamy)
	shadow_overlays += aq_light_shadow_anchors(CEILING(reach * 1.5 + 72, world.icon_size))
	aq_shadow.overlays = shadow_overlays
	aq_shadow_key = key

/// Ustawia odwrotną maskę cienia na plamie światła. Wołać tylko, gdy światło jest włączone i stoi na kaflu
/// (visible_mask wisi wtedy w underlays trzymającego), bo zmiana wyglądu wymaga zdjęcia i ponownego założenia plamy.
/datum/component/overlay_lighting/proc/aq_set_shadow_mask(render_source, offset_x = 0, offset_y = 0)
	var/key = render_source ? "[render_source];[offset_x];[offset_y]" : null
	if(aq_mask_key == key)
		return
	aq_mask_key = key
	current_holder.underlays -= visible_mask
	visible_mask.filters = render_source ? filter(type = "alpha", render_source = render_source, flags = MASK_INVERSE, x = offset_x, y = offset_y) : null
	current_holder.underlays += visible_mask

#undef AQ_OVERLAY_LIGHTING_ON
