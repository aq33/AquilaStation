/// AQUILA - celowanie kliknięciem na mapie kosmosu.
/// Klik trafia w najwyższy obiekt pod kursorem, a pocisk leciał w get_turf() tego obiektu, czyli w lewy dolny róg
/// jego sprite'a. Gwiazda, czerwony olbrzym, czarna dziura i wyrwy mają 160x160 px, efekty wybuchów przesunięte
/// pixel_x/pixel_y, więc działo Gaussa (i każde inne) strzelało kilka kafli obok kursora.
/// Teraz cel to kafel faktycznie pod kursorem (icon-x/icon-y z parametrów kliknięcia). Okręty zostają celem,
/// bo pocisk leci w ich środek, a ctrl-klik je namierza.

/obj/structure/overmap/InterceptClickOn(mob/user, params, atom/target)
	return ..(user, params, get_click_aim_target(target, params))

/obj/structure/overmap/onMouseDown(object, location, params, mob/M)
	return ..(get_click_aim_target(object, params), location, params, M)

/obj/structure/overmap/onMouseDrag(src_object, over_object, src_location, over_location, params, mob/M)
	return ..(src_object, get_click_aim_target(over_object, params), src_location, over_location, params, M)

/// Kafel pod kursorem, gdy kliknięto coś, co nie jest okrętem, na poziomie mapy kosmosu. W pozostałych przypadkach target bez zmian.
/obj/structure/overmap/proc/get_click_aim_target(atom/target, params)
	if(!ismovable(target) || isovermap(target) || istype(target, /atom/movable/screen))
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
