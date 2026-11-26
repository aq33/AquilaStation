// AQUILA - planeta na niebie: okręt w układzie z planetą widzi ją za oknami (warstwa paralaksy, jak planeta na orbicie).
// Obraz składa się w kliencie: płaska mapa powierzchni (aquila/icons/effects/planet_sky_surface.dmi, odwzorowanie walcowe)
// leży pod tarczą, filtr displace z mapą kuli zgina ją w globus, maska alpha obcina do tarczy, a na wierzchu leżą cień
// i poświata atmosfery. Planeta stoi w miejscu (obrót wyglądał źle).
// Tekstury generuje tools/planets/sky_planets.py (z ziarna, bez cudzych grafik).

/// Szerokość tekstury powierzchni (cały obwód planety)
#define PLANET_SKY_TEXTURE_WIDTH 512
/// Bok tarczy w pikselach (planet_sky_disk.dmi), przed skalowaniem
#define PLANET_SKY_DISK_SIZE 192
/// Największe przesunięcie zapisane w mapie displace (musi się zgadzać z DISPLACE_SIZE w sky_planets.py)
#define PLANET_SKY_DISPLACE_SIZE 128
/// Co ile sprawdzać, czy okręt nie podleciał bliżej innej planety układu
#define PLANET_SKY_RECHECK_DELAY (10 SECONDS)
/// Przesunięcie środka planety względem środka ekranu (w dół, żeby okręt „wisiał” nad nią)
#define PLANET_SKY_OFFSET_X 0
#define PLANET_SKY_OFFSET_Y -32

/datum/planet_type
	/// Stan z planet_sky_surface.dmi widoczny z okrętu w układzie. null: planety nie widać na niebie (pole asteroid)
	var/sky_state
	/// Stan chmur z planet_sky_surface.dmi albo null (bez chmur)
	var/sky_clouds
	/// Barwa chmur (popiół, opary)
	var/sky_cloud_color = "#ffffff"
	/// Barwa poświaty atmosfery albo null (bez atmosfery)
	var/sky_atmosphere_color
	/// Powiększenie tarczy (192 px, planeta ma 163 px średnicy): 2,5 dla zwykłych planet (ok. 13 z 15 pól widoku),
	/// mniej dla karłowatych i księżyców, więcej dla olbrzymów
	var/sky_scale = 2.5

/// Najbliższa okrętowi planeta układu, którą widać na niebie (planeta poza mapą układu liczy się jako daleka)
/proc/pick_sky_planet(list/planets, atom/viewer)
	RETURN_TYPE(/obj/structure/overmap/planet)
	var/best_dist = INFINITY
	for(var/obj/structure/overmap/planet/planet in planets)
		var/datum/planet_type/planet_type = planet.planet_type
		if(!istype(planet_type) || !planet_type.sky_state)
			continue
		var/dist = (viewer?.z && planet.z == viewer.z) ? get_dist(viewer, planet) : 1000000
		if(dist < best_dist || !.)
			best_dist = dist
			. = planet

/// Część obrazu planety (w vis_contents warstwy): bez kliknięć, płaszczyzna z rodzica
/obj/effect/overlay/planet_sky_part
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	plane = FLOAT_PLANE
	layer = FLOAT_LAYER
	appearance_flags = PIXEL_SCALE
	vis_flags = VIS_INHERIT_PLANE

/atom/movable/screen/parallax_layer/planet_sky
	icon = 'aquila/icons/effects/planet_sky_disk.dmi'
	icon_state = "base"
	blend_mode = BLEND_OVERLAY
	absolute = TRUE
	tesselate = FALSE
	speed = 0.2
	// Powiększona tarcza z filtrem displace wystaje poza widok, a BYOND poszerza mapę tak, żeby zmieścić obiekty ekranu:
	// za HUD-em pojawiała się kolumna bez światła i postać zjeżdżała ze środka (po zmianie rozmiaru okna, wejściu w postać,
	// dołożeniu czegokolwiek na ekran). TILE_BOUND liczy warstwę tylko w jej kafelku, a planeta rysuje się w całości.
	appearance_flags = APPEARANCE_UI | TILE_BOUND
	// Nad warstwą FTL (mgławice itp. mają HUD_LAYER), a gwiazdy z pozostałych warstw zostają za planetą
	layer = HUD_LAYER + 1
	/// Typ planety, który teraz widać (null: niebo bez planety)
	var/datum/planet_type/shown_type
	/// Układ z ostatniego sprawdzenia, wybrana wtedy planeta i kiedy sprawdzić go znowu
	var/datum/star_system/checked_system
	var/datum/planet_type/checked_type
	var/next_check = 0
	/// Sprawdzanie co PLANET_SKY_RECHECK_DELAY także wtedy, gdy pasażer stoi w miejscu (paralaksa odświeża się tylko przy ruchu)
	var/recheck_timer
	/// Tarcza z powierzchnią i chmurami (KEEP_TOGETHER, filtry displace i alpha)
	var/obj/effect/overlay/planet_sky_part/body
	var/obj/effect/overlay/planet_sky_part/shade
	var/obj/effect/overlay/planet_sky_part/atmosphere
	/// Tekstura powierzchni i chmur (listy, bo pokaz zejścia i testy biorą je razem)
	var/list/surface_strips
	var/list/cloud_strips

/// Okręt mógł podlecieć do innej planety układu, a pasażer stoi przy oknie: wtedy update_parallax() nic nie woła.
/// Bez klienta timer się kończy (rdzeń nie usuwa warstw paralaksy po wyjściu gracza, a pętla trzymałaby warstwę
/// i postać na zawsze); następne update_status() uruchamia go znowu
/atom/movable/screen/parallax_layer/planet_sky/proc/recheck_sky()
	var/mob/M = current_mob
	if(QDELETED(M) || !(src in M.client?.parallax_layers))
		stop_recheck()
		return
	force_recheck(M)

/atom/movable/screen/parallax_layer/planet_sky/proc/stop_recheck()
	if(recheck_timer)
		deltimer(recheck_timer)
		recheck_timer = null
	current_mob = null

/// Świeży wybór planety z pominięciem zapamiętanego (timer nie trafia w next_check, więc bez tego wynik
/// mógł być starszy niż PLANET_SKY_RECHECK_DELAY)
/atom/movable/screen/parallax_layer/planet_sky/proc/force_recheck(mob/M)
	next_check = 0
	update_status(M)

/atom/movable/screen/parallax_layer/planet_sky/Destroy()
	stop_recheck()
	vis_contents.Cut()
	if(body)
		body.vis_contents.Cut()
	QDEL_LIST(surface_strips)
	QDEL_LIST(cloud_strips)
	QDEL_NULL(body)
	QDEL_NULL(shade)
	QDEL_NULL(atmosphere)
	shown_type = null
	checked_system = null
	checked_type = null
	return ..()

/atom/movable/screen/parallax_layer/planet_sky/update_o(view)
	view_sized = view || world.view

/atom/movable/screen/parallax_layer/planet_sky/update_status(mob/M)
	. = ..()
	// Bez klienta pętla sama się zatrzyma przy pierwszym sprawdzeniu (recheck_sky)
	if(!recheck_timer && M)
		recheck_timer = addtimer(CALLBACK(src, PROC_REF(recheck_sky)), PLANET_SKY_RECHECK_DELAY, TIMER_STOPPABLE | TIMER_LOOP)
	var/datum/planet_type/wanted = find_sky_planet_type(M)
	if(wanted != shown_type)
		show_planet(wanted)

/// Typ planety do pokazania temu mobowi: okręt w układzie (nie w FTL), oko poza overmapą (pilot przy konsoli)
/atom/movable/screen/parallax_layer/planet_sky/proc/find_sky_planet_type(mob/M)
	var/turf/T = get_turf(M?.client?.eye || M)
	if(!T || SSmapping.level_trait(T.z, ZTRAIT_OVERMAP))
		return null
	var/obj/structure/overmap/ship = M.get_overmap()
	// Na powierzchni planety (rezerwacja należy do planety) jej samej na niebie nie widać
	if(!istype(ship) || !ship.current_system || istype(ship, /obj/structure/overmap/planet)) // get_overmap() bywa 0 (lobby)
		return null
	var/list/ship_data = SSstar_system.ships[ship]
	if(ship_data && ship_data["target_system"]) // skok FTL: niebo należy do warstwy FTL
		return null
	// Zapamiętany wybór, nie to, co akurat widać: po powrocie z overmapy (planeta schowana) niebo od razu wraca
	if(ship.current_system == checked_system && world.time < next_check)
		return checked_type
	checked_system = ship.current_system
	next_check = world.time + PLANET_SKY_RECHECK_DELAY
	var/obj/structure/overmap/planet/planet = pick_sky_planet(checked_system.system_contents, ship)
	checked_type = planet?.planet_type
	return checked_type

/// Składa obraz planety danego typu (null chowa planetę)
/atom/movable/screen/parallax_layer/planet_sky/proc/show_planet(datum/planet_type/planet_type)
	shown_type = planet_type
	vis_contents.Cut()
	if(!planet_type)
		return
	if(!body)
		build_parts()
	var/matrix/scale = matrix(planet_type.sky_scale, 0, 0, 0, planet_type.sky_scale, 0)
	// Środek tarczy na środku ekranu: warstwa leży lewym dolnym rogiem na CENTER-7, środek ekranu jest 7,5 pola dalej
	var/center = 7.5 * world.icon_size - PLANET_SKY_DISK_SIZE / 2
	for(var/obj/effect/overlay/planet_sky_part/part as anything in list(body, shade, atmosphere))
		part.transform = scale
		part.pixel_x = center + PLANET_SKY_OFFSET_X
		part.pixel_y = center + PLANET_SKY_OFFSET_Y
	for(var/obj/effect/overlay/planet_sky_part/strip as anything in surface_strips)
		strip.icon_state = planet_type.sky_state
	body.vis_contents.Cut()
	body.vis_contents += surface_strips
	if(planet_type.sky_clouds)
		for(var/obj/effect/overlay/planet_sky_part/strip as anything in cloud_strips)
			strip.icon_state = planet_type.sky_clouds
			strip.color = planet_type.sky_cloud_color
		body.vis_contents += cloud_strips
	vis_contents += body
	vis_contents += shade
	if(planet_type.sky_atmosphere_color)
		atmosphere.color = planet_type.sky_atmosphere_color
		vis_contents += atmosphere

/atom/movable/screen/parallax_layer/planet_sky/proc/build_parts()
	body = new
	body.icon = icon
	body.icon_state = "base"
	body.appearance_flags = KEEP_TOGETHER | PIXEL_SCALE | RESET_TRANSFORM
	body.layer = layer
	body.filters += filter(type = "displace", icon = icon(icon, "displace"), size = PLANET_SKY_DISPLACE_SIZE)
	body.filters += filter(type = "alpha", icon = icon(icon, "mask"))
	shade = new
	shade.icon = icon
	shade.icon_state = "shade"
	shade.appearance_flags = PIXEL_SCALE | RESET_TRANSFORM
	shade.layer = layer + 0.01
	atmosphere = new
	atmosphere.icon = icon
	atmosphere.icon_state = "atmosphere"
	atmosphere.appearance_flags = PIXEL_SCALE | RESET_TRANSFORM | RESET_COLOR
	atmosphere.layer = layer + 0.02
	surface_strips = make_strips(1)
	cloud_strips = make_strips(2)

/// Tekstura środkiem na środku tarczy (wewnątrz KEEP_TOGETHER płaszczyzna i warstwa lokalne)
/atom/movable/screen/parallax_layer/planet_sky/proc/make_strips(strip_layer)
	var/obj/effect/overlay/planet_sky_part/strip = new
	strip.icon = 'aquila/icons/effects/planet_sky_surface.dmi'
	strip.vis_flags = NONE
	strip.layer = strip_layer
	strip.pixel_x = PLANET_SKY_DISK_SIZE / 2 - PLANET_SKY_TEXTURE_WIDTH / 2
	strip.pixel_y = PLANET_SKY_DISK_SIZE / 2 - PLANET_SKY_TEXTURE_WIDTH / 4
	return list(strip)

/// Warstwa planety dochodzi do warstw paralaksy klienta niezależnie od limitu z ustawień (to jedna warstwa)
/datum/hud/create_parallax(mob/viewmob)
	. = ..()
	var/mob/screenmob = viewmob || mymob
	var/client/C = screenmob?.client
	if(!C?.parallax_layers)
		return
	var/atom/movable/screen/parallax_layer/planet_sky/sky = locate() in C.parallax_layers_cached
	if(!sky)
		sky = new(null, C.view)
		C.parallax_layers_cached += sky
	C.parallax_layers |= sky
	C.screen |= sky
	// Warstwa z cache'u po ponownym włączeniu paralaksy: timer mógł się zatrzymać, a nieruchome oko nie wywoła
	// update_status(); świeże sprawdzenie od razu pokazuje planetę i wznawia pętlę
	sky.force_recheck(screenmob)

#undef PLANET_SKY_TEXTURE_WIDTH
#undef PLANET_SKY_DISK_SIZE
#undef PLANET_SKY_DISPLACE_SIZE
#undef PLANET_SKY_RECHECK_DELAY
#undef PLANET_SKY_OFFSET_X
#undef PLANET_SKY_OFFSET_Y
