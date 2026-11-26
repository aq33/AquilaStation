/// AQUILA - celowanie kliknięciem na mapie kosmosu.
/// Klik trafia w najwyższy obiekt pod kursorem, a pocisk leciał w get_turf() tego obiektu, czyli w lewy dolny róg
/// jego sprite'a. Gwiazda, czerwony olbrzym, czarna dziura i wyrwy mają 160x160 px, efekty wybuchów przesunięte
/// pixel_x/pixel_y, więc działo Gaussa (i każde inne) strzelało kilka kafli obok kursora.
/// Teraz cel to kafel faktycznie pod kursorem (icon-x/icon-y z parametrów kliknięcia). Okręty zostają celem,
/// bo pocisk leci w ich środek, a ctrl-klik je namierza. Pociski też, bo rakieta wystrzelona w torpedę ma ją gonić.
/// Sonda skanuje anomalię, gdy wleci w dowolny kafel pod jej sprite'em, a nie tylko w kafel loc (on_entered).

/obj/structure/overmap/InterceptClickOn(mob/user, params, atom/target)
	return ..(user, params, get_click_aim_target(target, params))

/obj/structure/overmap/onMouseDown(object, location, params, mob/M)
	return ..(get_click_aim_target(object, params), location, params, M)

/obj/structure/overmap/onMouseDrag(src_object, over_object, src_location, over_location, params, mob/M)
	return ..(src_object, get_click_aim_target(over_object, params), src_location, over_location, params, M)

/// Kafel pod kursorem, gdy kliknięto coś, co nie jest okrętem, na poziomie mapy kosmosu. W pozostałych przypadkach target bez zmian.
/obj/structure/overmap/proc/get_click_aim_target(atom/target, params)
	if(!ismovable(target) || isovermap(target) || istype(target, /obj/item/projectile) || istype(target, /atom/movable/screen))
		return target
	var/atom/movable/clicked = target
	var/turf/origin = get_turf(clicked)
	if(!origin || clicked.loc != origin || !SSmapping.level_trait(origin.z, ZTRAIT_OVERMAP))
		return target
	var/list/modifiers = params2list(params)
	var/icon_x = text2num(LAZYACCESS(modifiers, ICON_X))
	var/icon_y = text2num(LAZYACCESS(modifiers, ICON_Y))
	if(isnull(icon_x) || isnull(icon_y))
		return target
	// icon-x/icon-y liczą się od 1 w lewym dolnym rogu ikony, która jest przesunięta o pixel_x/pixel_w i step_x
	var/dx = FLOOR((icon_x - 1 + clicked.pixel_x + clicked.pixel_w + clicked.step_x) / world.icon_size, 1)
	var/dy = FLOOR((icon_y - 1 + clicked.pixel_y + clicked.pixel_z + clicked.step_y) / world.icon_size, 1)
	var/turf/aimed = locate(clamp(origin.x + dx, 1, world.maxx), clamp(origin.y + dy, 1, world.maxy), origin.z)
	return aimed || target

/obj/effect/overmap_anomaly
	/// Szerokość i wysokość sprite'a w pikselach, liczone przy pierwszym sprawdzeniu
	var/sprite_width
	var/sprite_height

/// Czy kafel T leży pod sprite'em anomalii (z przesunięciem pixel_x/pixel_w)
/obj/effect/overmap_anomaly/proc/sprite_covers(turf/T)
	if(!T || T.z != z)
		return FALSE
	if(isnull(sprite_width))
		var/icon/sprite = icon(icon, icon_state)
		sprite_width = sprite.Width()
		sprite_height = sprite.Height()
	var/left = x * world.icon_size + pixel_x + pixel_w
	var/bottom = y * world.icon_size + pixel_y + pixel_z
	var/tile_x = T.x * world.icon_size
	var/tile_y = T.y * world.icon_size
	return tile_x + world.icon_size > left && tile_x < left + sprite_width && tile_y + world.icon_size > bottom && tile_y < bottom + sprite_height

/obj/item/projectile/bullet/torpedo/probe/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	if(QDELETED(src) || !isturf(loc))
		return
	for(var/obj/effect/overmap_anomaly/anomaly as anything in GLOB.overmap_anomalies)
		if(QDELETED(anomaly) || anomaly.loc == loc) // kafel loc obsługuje on_entered
			continue
		if(anomaly.sprite_covers(loc))
			anomaly.on_entered(anomaly.loc, src)
			return
