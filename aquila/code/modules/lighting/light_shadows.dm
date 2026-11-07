// PROTOTYP: cienie od ścian dla świateł ruchomych (latarki, kaski, PDA, borgi; overlay_lighting).
// Bez tego plama światła latarki to sam sprite i wizualnie świeci przez ściany.
//
// Każde włączone światło ruchome ma obiekt w swoim kaflu z trójkątami cienia za widocznymi nieprzezroczystymi kaflami
// (light_shadow_geometry.dm). Obiekt jest na nierysowanej płaszczyźnie AQ_LIGHT_SHADOW_PLANE, a ta płaszczyzna
// odwrotną maską wycina światło latarek na O_LIGHTING_VISUAL_PLANE. Światło stałe (narożnikowe) zostaje bez zmian.
//
// Ograniczenia prototypu:
// - cień liczony ze środka kafla światła, przy kroku przeskakuje o kafel, a nie przesuwa się płynnie,
// - cień jednej latarki wycina też światło innej latarki w tym samym miejscu (maska jest wspólna dla płaszczyzny),
// - drzwi zamknięte lub otwarte przy stojącej latarce odświeżą cień dopiero przy jej ruchu albo obrocie.

/// Wyłącznik prototypu dla admina (View Variables na GLOB)
GLOBAL_VAR_INIT(aq_light_shadows_enabled, TRUE)

/// "dx,dy,ściany" -> lista wyglądów trójkątów cienia kafla przesuniętego o (dx, dy) od światła. Wspólne dla wszystkich świateł.
GLOBAL_LIST_EMPTY(aq_light_shadow_cache)

/proc/aq_light_shadow_appearances(dx, dy, hidden_faces)
	var/key = "[dx],[dy],[hidden_faces]"
	. = GLOB.aq_light_shadow_cache[key]
	if(.)
		return
	var/list/appearances = list()
	for(var/matrix/triangle as anything in aq_light_shadow_matrices(dx, dy, hidden_faces))
		var/mutable_appearance/shadow = mutable_appearance('aquila/icons/effects/light_shadow.dmi', "tri", FLOAT_LAYER, FLOAT_PLANE)
		shadow.transform = triangle
		appearances += shadow
	GLOB.aq_light_shadow_cache[key] = appearances
	return appearances

/// Trójkąty cienia jednego światła. Stoi w kaflu światła i przeskakuje razem z nim (bez ślizgu).
/obj/effect/abstract/aq_light_shadow
	name = ""
	icon = null
	plane = AQ_LIGHT_SHADOW_PLANE
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	animate_movement = NO_STEPS

/atom/movable/screen/plane_master/aq_light_shadows
	name = "light shadows plane master"
	plane = AQ_LIGHT_SHADOW_PLANE
	appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	// Nazwa z gwiazdką, więc płaszczyzna nigdy się nie rysuje. Właściwą nazwę dostaje tylko plane master HUD-u (backdrop),
	// żeby kopie z okien kamer nie podmieniały maski.
	render_target = "*AQ_LIGHT_SHADOWS_UNUSED"

/atom/movable/screen/plane_master/aq_light_shadows/backdrop(mob/mymob)
	render_target = AQ_LIGHT_SHADOW_RENDER_TARGET
	clear_filters()
	// Miękki brzeg cienia zamiast schodków po rozciągnięciu trójkąta
	add_filter("aq_shadow_soft", 1, gauss_blur_filter(1.5))

/atom/movable/screen/plane_master/o_light_visual/backdrop(mob/mymob)
	. = ..()
	remove_filter("aq_light_shadows")
	add_filter("aq_light_shadows", 1, alpha_mask_filter(render_source = AQ_LIGHT_SHADOW_RENDER_TARGET, flags = MASK_INVERSE))

/datum/component/overlay_lighting
	/// PROTOTYP: trójkąty cienia tego światła
	var/obj/effect/abstract/aq_light_shadow/aq_shadow

/datum/component/overlay_lighting/Destroy()
	QDEL_NULL(aq_shadow)
	return ..()

/datum/component/overlay_lighting/get_new_turfs()
	. = ..()
	aq_update_shadow(.)

/datum/component/overlay_lighting/remove_dynamic_lumi()
	. = ..()
	aq_hide_shadow()

/datum/component/overlay_lighting/make_luminosity_update()
	. = ..()
	if(!isturf(current_holder?.loc))
		aq_hide_shadow()

/datum/component/overlay_lighting/proc/aq_hide_shadow()
	if(aq_shadow?.loc)
		aq_shadow.overlays.Cut()
		aq_shadow.abstract_move(null)

/// Przelicza trójkąty cienia dla widocznych nieprzezroczystych kafli
/datum/component/overlay_lighting/proc/aq_update_shadow(list/lit_turfs)
	var/turf/light_turf = get_turf(current_holder)
	if(!GLOB.aq_light_shadows_enabled || !light_turf)
		aq_hide_shadow()
		return
	// Środek plamy światła: przy świetle kierunkowym plama jest przesunięta przed trzymającego
	var/center_x = 0
	var/center_y = 0
	var/list/turfs = lit_turfs
	if(directional)
		center_x = (directional_offset_x + (range - 1) * world.icon_size) / world.icon_size
		center_y = (directional_offset_y + (range - 1) * world.icon_size) / world.icon_size
		turfs = view(lumcount_range + cast_range, light_turf)
	var/reach = range + 1
	var/list/shadow_overlays = list()
	for(var/turf/occluder in turfs)
		if(!IS_OPAQUE_TURF(occluder))
			continue
		var/dx = occluder.x - light_turf.x
		var/dy = occluder.y - light_turf.y
		// Ściana poza plamą światła nie rzuca widocznego cienia
		if(max(abs(dx - center_x), abs(dy - center_y)) > reach)
			continue
		var/hidden_faces = 0
		var/static/list/face_dirs = list(SOUTH, EAST, NORTH, WEST)
		for(var/face in 1 to 4)
			var/turf/neighbour = get_step(occluder, face_dirs[face])
			if(neighbour && IS_OPAQUE_TURF(neighbour))
				hidden_faces |= (1 << (face - 1))
		shadow_overlays += aq_light_shadow_appearances(dx, dy, hidden_faces)
	if(!length(shadow_overlays))
		aq_hide_shadow()
		return
	if(!aq_shadow)
		aq_shadow = new
	if(aq_shadow.loc != light_turf)
		aq_shadow.abstract_move(light_turf)
	aq_shadow.overlays = shadow_overlays
