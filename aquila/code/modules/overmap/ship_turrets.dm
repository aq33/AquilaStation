/// AQUILA - działa na sprite'cie okrętu, które obracają się tam, gdzie celuje strzelec. Okręt z listą turret_mounts
/// rysuje kadłub bez broni, a każda wieżyczka i działo to osobna warstwa (vis_contents) z własną osią obrotu. Lufa patrzy
/// na punkt, który strzelec kliknął albo trzyma myszą, a po strzale broni swojej grupy na cel tego strzału; obraca się
/// tylko w łuku swojej burty (wieżyczki boczne) albo dziobu (artyleria). Przy strzale gra stan "<stan>-firing".
/// Mocowania: list(stan ikony, oś x, oś y, kierunek spoczynku, grupa), oś w pikselach od środka klatki (y w górę),
/// kierunek jak kąt okrętu (0 dziób, 90 prawa burta, 270 lewa). Grupy: "turret" (PDC, flak, AA, Gauss, lekkie działka),
/// "artillery" (MAC, railgun, ciężkie działa, burtówki).

/// Pół szerokości łuku obrotu lufy wokół kierunku spoczynku (stopnie)
#define SHIP_TURRET_ARC 90
/// Jak długo lufa patrzy na cel strzału, zanim wróci do celu strzelca
#define SHIP_TURRET_FIRE_HOLD (2 SECONDS)

/// Mocowania okrętu z aquilas.dmi (pierwszy okręt z obracanymi działami)
GLOBAL_LIST_INIT(aquilas_turret_mounts, list(
	list("turret-north-west", -10, -0.5, 270, "turret"),
	list("turret-south-west", -10, -11.5, 270, "turret"),
	list("turret-north-east", 10, -0.5, 90, "turret"),
	list("turret-south-east", 10, -11.5, 90, "turret"),
	list("artillery-west", -4.5, 27, 0, "artillery"),
	list("artillery-east", 3.5, 27, 0, "artillery"),
))

/obj/structure/overmap
	/// AQUILA - mocowania obracanych dział na sprite'cie (patrz GLOB.aquilas_turret_mounts); null = działa narysowane w kadłubie
	var/list/turret_mounts
	/// AQUILA - warstwy dział z mocowań
	var/list/obj/effect/overmap_turret/turret_layers
	/// AQUILA - kąt (świat), w który celuje strzelec
	var/turret_aim_angle
	/// AQUILA - grupa -> list(kąt, do kiedy) po strzale broni tej grupy
	var/list/turret_fire_aim

/obj/effect/overmap_turret
	name = "działo"
	icon_state = ""
	appearance_flags = KEEP_APART | RESET_COLOR | PIXEL_SCALE
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// Oś obrotu w pikselach od środka klatki
	var/pivot_x = 0
	var/pivot_y = 0
	/// Kierunek spoczynku względem dziobu
	var/rest_angle = 0
	var/group
	/// Kąt lufy względem okrętu
	var/relative_angle = 0

/obj/structure/overmap/Initialize(mapload)
	. = ..()
	if(length(turret_mounts))
		build_turret_layers()

/obj/structure/overmap/Destroy()
	QDEL_LIST(turret_layers)
	return ..()

/obj/structure/overmap/proc/build_turret_layers()
	QDEL_LIST(turret_layers)
	turret_layers = list()
	for(var/list/mount as anything in turret_mounts)
		var/obj/effect/overmap_turret/layer = new(null)
		layer.icon = icon
		layer.icon_state = mount[1]
		layer.pivot_x = mount[2]
		layer.pivot_y = mount[3]
		layer.rest_angle = mount[4]
		layer.relative_angle = mount[4]
		layer.group = mount[5]
		turret_layers += layer
		vis_contents += layer
	update_turret_layers()

/// Grupa mocowań, z której strzela broń okrętu; null = broń bez widocznego działa (torpedy, rakiety)
/proc/ship_turret_group(datum/overmap_ship_weapon/weapon)
	var/path = "[weapon.type]"
	if(findtext(path, "light_cannon"))
		return "turret"
	switch(ship_weapon_module_kind(weapon))
		if("flak", "aa", "gauss")
			return "turret"
		if("mac")
			return "artillery"
	return null

/// Kąt w świecie, w który ma patrzeć lufa tej grupy: cel ostatniego strzału przez chwilę, potem cel strzelca
/obj/structure/overmap/proc/turret_target_angle(group)
	var/list/fired = LAZYACCESS(turret_fire_aim, group)
	if(fired && world.time < fired[2])
		return fired[1]
	return turret_aim_angle

/// Obraca warstwy dział: kąt względem okrętu w łuku wokół kierunku spoczynku, obrót wokół własnej osi
/obj/structure/overmap/proc/update_turret_layers()
	for(var/obj/effect/overmap_turret/layer as anything in turret_layers)
		var/world_angle = turret_target_angle(layer.group)
		if(!isnull(world_angle))
			var/offset = ((world_angle - angle - layer.rest_angle) % 360 + 540) % 360 - 180 // -180..180 od spoczynku
			layer.relative_angle = ((layer.rest_angle + clamp(offset, -SHIP_TURRET_ARC, SHIP_TURRET_ARC)) % 360 + 360) % 360
		var/matrix/M = matrix()
		M.Translate(-layer.pivot_x, -layer.pivot_y)
		M.Turn(layer.relative_angle - layer.rest_angle)
		M.Translate(layer.pivot_x, layer.pivot_y)
		layer.transform = M

/// Strzelec celuje w punkt na mapie
/obj/structure/overmap/proc/turret_aim_at(atom/location)
	if(!length(turret_layers) || !location)
		return
	var/turf/T = get_turf(location)
	if(!T)
		return
	turret_aim_angle = overmap_angle(get_center(), T)
	update_turret_layers()

/// Broń okrętu wystrzeliła: działa jej grupy patrzą na cel i grają animację strzału
/obj/structure/overmap/proc/turret_fired(datum/overmap_ship_weapon/weapon, atom/target)
	var/group = ship_turret_group(weapon)
	if(!group || !length(turret_layers))
		return
	var/turf/T = get_turf(target)
	if(T)
		LAZYSET(turret_fire_aim, group, list(overmap_angle(get_center(), T), world.time + SHIP_TURRET_FIRE_HOLD))
		update_turret_layers()
	for(var/obj/effect/overmap_turret/layer as anything in turret_layers)
		if(layer.group == group)
			flick("[layer.icon_state]-firing", layer)

/obj/structure/overmap/onMouseDown(object, location, params, mob/M)
	. = ..()
	if(M == gunner || LAZYFIND(gauss_gunners, M))
		turret_aim_at(location || object)

/obj/structure/overmap/onMouseDrag(src_object, over_object, src_location, over_location, params, mob/M)
	. = ..()
	if(M == gunner || LAZYFIND(gauss_gunners, M))
		turret_aim_at(over_location || over_object)

/datum/overmap_ship_weapon/fire(target, mob/living/firer, ai_aim = FALSE)
	. = ..()
	if(. && linked_overmap?.turret_layers)
		linked_overmap.turret_fired(src, target)

// Okręt się obraca: lufy trzymają cel w świecie
/obj/structure/overmap/process()
	var/old_angle = angle
	. = ..()
	if(turret_layers && angle != old_angle)
		update_turret_layers()

#undef SHIP_TURRET_ARC
#undef SHIP_TURRET_FIRE_HOLD
