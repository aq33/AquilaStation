// Z-Mimic: plane mastery kopii piętra niżej i jego cienia, z rozmyciem jak w tg (tgstation/tgstation#69115).
// Każda głębokość kopii ma własny plan (ZMIMIC_MAX_PLANE - głębokość), więc każda dostaje swój plane master z filtrami.
// Cień (kopie światła piętra niżej) leży na jednym planie nad nimi i mnoży się na wszystko pod spodem.

/datum/preferences
	/// Rozmycie piętra niżej widzianego przez otwartą przestrzeń
	var/zmimic_blur = TRUE

/atom/movable/screen/plane_master/zmimic
	name = "zmimic plane master"
	plane = ZMIMIC_MAX_PLANE
	blend_mode = BLEND_OVERLAY

// Filtry od razu przy tworzeniu: konsole kamer robią własne plane mastery bez backdrop() i też mają odróżniać piętra.
// backdrop() tylko zdejmuje rozmycie, gdy gracz je wyłączył.
/atom/movable/screen/plane_master/zmimic/Initialize(mapload)
	. = ..()
	var/darken = ZMIMIC_DARKENING_FACTOR
	add_filter("zmimic_darken", 1, color_matrix_filter(list(darken, 0, 0, 0, darken, 0, 0, 0, darken)))
	add_filter("zmimic_blur", 2, gauss_blur_filter(ZMIMIC_BLUR_SIZE))

/atom/movable/screen/plane_master/zmimic/backdrop(mob/mymob)
	. = ..()
	remove_filter("zmimic_blur")
	if(!mymob?.client || mymob.client.prefs?.zmimic_blur)
		add_filter("zmimic_blur", 2, gauss_blur_filter(ZMIMIC_BLUR_SIZE))

/atom/movable/screen/plane_master/zmimic/depth_1
	plane = ZMIMIC_MAX_PLANE - 1

/atom/movable/screen/plane_master/zmimic/depth_2
	plane = ZMIMIC_MAX_PLANE - 2

/atom/movable/screen/plane_master/zmimic/depth_3
	plane = ZMIMIC_MAX_PLANE - 3

/atom/movable/screen/plane_master/zmimic/depth_4
	plane = ZMIMIC_MAX_PLANE - 4

/atom/movable/screen/plane_master/zmimic/depth_5
	plane = ZMIMIC_MAX_PLANE - 5

/atom/movable/screen/plane_master/zmimic/depth_6
	plane = ZMIMIC_MAX_PLANE - 6

/atom/movable/screen/plane_master/zmimic/depth_7
	plane = ZMIMIC_MAX_PLANE - 7

/atom/movable/screen/plane_master/zmimic/depth_8
	plane = ZMIMIC_MAX_PLANE - 8

/atom/movable/screen/plane_master/zmimic/depth_9
	plane = ZMIMIC_MAX_PLANE - 9

/atom/movable/screen/plane_master/zmimic/depth_10
	plane = ZMIMIC_MAX_PLANE - 10

/// Cień piętra niżej: kopie obiektów światła z piętra niżej, mnożone na plany kopii pod spodem
/atom/movable/screen/plane_master/zmimic_shadow
	name = "zmimic shadow plane master"
	plane = ZMIMIC_SHADOW_PLANE
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/plane_master/zmimic_shadow/Initialize(mapload)
	. = ..()
	add_filter("zmimic_blur", 1, gauss_blur_filter(ZMIMIC_BLUR_SIZE))

/atom/movable/screen/plane_master/zmimic_shadow/backdrop(mob/mymob)
	. = ..()
	remove_filter("zmimic_blur")
	if(!mymob?.client || mymob.client.prefs?.zmimic_blur)
		add_filter("zmimic_blur", 1, gauss_blur_filter(ZMIMIC_BLUR_SIZE))
	// Ciemność piętra niżej słabnie tak samo jak na planie światła (noktowizja, mezony, duchy)
	alpha = mymob ? mymob.lighting_alpha : LIGHTING_PLANE_ALPHA_VISIBLE

/// Cienie pięter głębszych niż jedno: mnożą się przed cieniem bezpośrednio niższego piętra
/atom/movable/screen/plane_master/zmimic_shadow/deep
	name = "zmimic deep shadow plane master"
	plane = ZMIMIC_DEEP_SHADOW_PLANE

/// Plan cienia piętra niżej dostaje tę samą alfę co plan światła, inaczej noktowizja i duchy widziały ciemne pokoje
/// piętro niżej jako czarne (kopia światła mnożyła się w pełni)
/mob/sync_lighting_plane_alpha()
	. = ..()
	if(!hud_used)
		return
	for(var/plane_key in list("[ZMIMIC_SHADOW_PLANE]", "[ZMIMIC_DEEP_SHADOW_PLANE]"))
		var/atom/movable/screen/plane_master/zmimic_shadow/shadow = hud_used.plane_masters[plane_key]
		if(shadow)
			shadow.alpha = lighting_alpha

/// Odświeża plany Z-Mimic po zmianie preferencji
/client/proc/aq_update_zmimic_planes()
	var/datum/hud/hud = mob?.hud_used
	if(!hud)
		return
	for(var/plane_key in hud.plane_masters)
		var/atom/movable/screen/plane_master/plane_master = hud.plane_masters[plane_key]
		if(istype(plane_master, /atom/movable/screen/plane_master/zmimic) || istype(plane_master, /atom/movable/screen/plane_master/zmimic_shadow))
			plane_master.backdrop(mob)

/datum/preference/toggle/player/zmimic_blur
	db_key = "zmimic_blur"
	player_var = "zmimic_blur"

/datum/preference/toggle/player/zmimic_blur/on_changed(datum/preferences/prefs, client/C, old_value, new_value)
	C?.aq_update_zmimic_planes()
