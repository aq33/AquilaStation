/// AQUILA - skala wizualna overmapy (aquila/code/modules/overmap/overmap_visual_scale.dm): poza overmapą myśliwiec rysuje się
/// dwa razy większy (prom bez zmian), na overmapie dostaje nowy sprite 1:1 z hitboksem z jego klatki, a po powrocie na pokład
/// dawny; okręty z nowymi sprite'ami mają swoje stany i obrysy; stary sprite zostawia dzisiejszy hitbox i środek, a efekt
/// trafienia trafia na obrys kadłuba.
/datum/unit_test/aquila_overmap_visual_scale
	var/obj/structure/overmap/small_craft/ship
	var/obj/structure/overmap/small_craft/old_sprite

/// Okręt testowy rysowany starym sprite'em lotniskowca Syndykatu z hitboksem dzisiejszego
/obj/structure/overmap/small_craft/combat/light/aquila_visual_scale_test
	icon = 'nsv13/icons/overmap/syndicate/syn_carrier.dmi'
	icon_state = "carrier"
	overmap_display_proportion = 1
	overmap_hitbox_icon = 'nsv13/icons/overmap/new/syndicate/carrier.dmi'
	overmap_hitbox_state = "redtip"
	overmap_sprite_icon = null

/datum/unit_test/aquila_overmap_visual_scale/Run()
	ship = allocate(/obj/structure/overmap/small_craft/combat/light)
	old_sprite = allocate(/obj/structure/overmap/small_craft/combat/light/aquila_visual_scale_test)
	var/fail = check_off_overmap() || check_damage_states() || check_on_overmap()
	if(fail)
		return Fail(fail)

/datum/unit_test/aquila_overmap_visual_scale/proc/check_off_overmap()
	ship.forceMove(locate(10, 10, run_loc_floor_bottom_left.z))
	if(ship.overmap_display_scale() != 2)
		return "Na pokładzie myśliwiec ma skalę [ship.overmap_display_scale()] zamiast 2"
	var/matrix/M = matrix()
	ship.apply_overmap_display(M, 0)
	if(M.a != 2 || M.e != 2)
		return "Na pokładzie macierz rysowania myśliwca nie jest podwojona ([M.a], [M.e])"
	if(ship.bound_width != 64 || ship.bound_height != 64)
		return "Na pokładzie myśliwiec zmienił hitbox na [ship.bound_width]x[ship.bound_height]"
	var/obj/structure/overmap/small_craft/escapepod/shuttle = allocate(/obj/structure/overmap/small_craft/escapepod)
	shuttle.forceMove(locate(14, 10, run_loc_floor_bottom_left.z))
	if(shuttle.overmap_display_scale() != 1)
		return "Kapsuła ratunkowa na pokładzie ma skalę [shuttle.overmap_display_scale()] zamiast 1"
	var/obj/structure/overmap/small_craft/combat/light/syndicate/pvp = allocate(/obj/structure/overmap/small_craft/combat/light/syndicate)
	pvp.forceMove(locate(18, 10, run_loc_floor_bottom_left.z))
	if(pvp.overmap_display_scale() != 1)
		return "Myśliwiec Syndykatu (PvP) na pokładzie ma skalę [pvp.overmap_display_scale()] zamiast 1"
	// Stary sprite: hitbox z dzisiejszej ikony (klatka 96 px), nie ze starej (256 px)
	var/list/ref = overmap_sprite_bounds_of(old_sprite.overmap_hitbox_icon, old_sprite.overmap_hitbox_state)
	if(!ref)
		return "Brak obrysu dzisiejszego sprite'a lotniskowca w tabeli overmap_sprite_bounds"
	if(old_sprite.pixel_collision_size_x != ref[1] || old_sprite.pixel_collision_size_y != ref[2])
		return "Hitbox starego sprite'a to [old_sprite.pixel_collision_size_x]x[old_sprite.pixel_collision_size_y] zamiast [ref[1]]x[ref[2]]"

/datum/unit_test/aquila_overmap_visual_scale/proc/check_damage_states()
	// Okręty AI ze starymi sprite'ami: każdy, który ma stany uszkodzeń, musi je mieć w nowej ikonie
	for(var/obj/structure/overmap/type as anything in list(
		/obj/structure/overmap/syndicate/ai/submarine, /obj/structure/overmap/syndicate/ai/submarine/elite))
		var/list/states = icon_states(initial(type.icon))
		if(!(initial(type.icon_state) in states))
			return "[type]: ikona [initial(type.icon)] nie ma stanu [initial(type.icon_state)]"
		if(initial(type.damage_states))
			for(var/progress in list(100, 75, 50, 25, 0))
				if(!("[initial(type.icon_state)]-[progress]" in states))
					return "[type]: brak stanu uszkodzeń [initial(type.icon_state)]-[progress]"
		if(!overmap_sprite_bounds_of(initial(type.icon), initial(type.icon_state)))
			return "[type]: brak obrysu starego sprite'a w tabeli overmap_sprite_bounds"
		if(!overmap_sprite_bounds_of(initial(type.overmap_hitbox_icon), initial(type.overmap_hitbox_state)))
			return "[type]: brak obrysu dzisiejszego sprite'a w tabeli overmap_sprite_bounds"
	// Nowe sprite'y (ship_sprites.dm): każdy typ ma swój stan w ikonie i obrys, a nowy sprite nie udaje stanów uszkodzeń
	for(var/obj/structure/overmap/type as anything in subtypesof(/obj/structure/overmap))
		var/sprite_icon = initial(type.overmap_sprite_icon)
		var/sprite_state = initial(type.overmap_sprite_state)
		if(!sprite_icon && initial(type.overmap_native_sprite))
			sprite_icon = initial(type.icon)
			sprite_state = initial(type.icon_state)
			if(initial(type.damage_states))
				return "[type]: nowy sprite ze stanami uszkodzeń, których ikona nie ma"
		if(!sprite_icon)
			continue
		if(!(sprite_state in icon_states(sprite_icon)))
			return "[type]: ikona [sprite_icon] nie ma stanu [sprite_state]"
		if(!overmap_sprite_bounds_of(sprite_icon, sprite_state))
			return "[type]: brak obrysu [sprite_icon]|[sprite_state] w tabeli overmap_sprite_bounds"

/datum/unit_test/aquila_overmap_visual_scale/proc/check_on_overmap()
	var/list/overmap_levels = SSmapping.levels_by_trait(ZTRAIT_OVERMAP)
	if(!length(overmap_levels))
		return // Ten przebieg testów nie ma overmapy
	var/overmap_z = overmap_levels[1]
	// Myśliwiec na overmapie: nowy sprite 1:1, hitbox z jego klatki; po powrocie na pokład dawny sprite ×2
	ship.forceMove(locate(100, 100, overmap_z))
	if(ship.icon != ship.overmap_sprite_icon || ship.icon_state != ship.overmap_sprite_state)
		return "Myśliwiec na overmapie rysuje się [ship.icon]|[ship.icon_state] zamiast nowego sprite'a"
	if(ship.overmap_display_scale() != 1)
		return "Myśliwiec na overmapie ma skalę [ship.overmap_display_scale()] zamiast 1"
	var/icon/frame = icon(ship.overmap_sprite_icon, ship.overmap_sprite_state)
	if(ship.pixel_collision_size_x != frame.Width() || ship.pixel_collision_size_y != frame.Height())
		return "Hitbox myśliwca na overmapie to [ship.pixel_collision_size_x]x[ship.pixel_collision_size_y] zamiast klatki nowego sprite'a"
	ship.forceMove(locate(10, 10, run_loc_floor_bottom_left.z))
	if(ship.icon != initial(ship.icon) || ship.icon_state != initial(ship.icon_state) || ship.overmap_display_scale() != 2)
		return "Po powrocie na pokład myśliwiec rysuje się [ship.icon]|[ship.icon_state] w skali [ship.overmap_display_scale()]"

	// Okręt bez nowego sprite'a zostaje przy proporcjach
	old_sprite.forceMove(locate(120, 100, overmap_z))
	old_sprite.overmap_display_proportion = 1.5
	if(abs(old_sprite.overmap_display_scale() - OVERMAP_VISUAL_SCALE * 1.5) > 0.001)
		return "Proporcja 1,5 dała skalę [old_sprite.overmap_display_scale()]"
	old_sprite.overmap_display_proportion = 1

	// Stary sprite: macierz skaluje i przesuwa środek kadłuba na środek dzisiejszego sprite'a
	old_sprite.angle = 0
	old_sprite.pixel_x = 0
	old_sprite.pixel_y = 0
	var/k = old_sprite.overmap_display_scale()
	var/list/disp = overmap_sprite_bounds_of(old_sprite.icon, initial(old_sprite.icon_state))
	var/list/ref = overmap_sprite_bounds_of(old_sprite.overmap_hitbox_icon, old_sprite.overmap_hitbox_state)
	var/matrix/M = matrix()
	old_sprite.apply_overmap_display(M, 0)
	var/expected_x = (ref[1] - disp[1]) / 2 + ref[5] - k * disp[5]
	var/expected_y = (ref[2] - disp[2]) / 2 + ref[6] - k * disp[6]
	if(abs(M.a - k) > 0.001 || abs(M.c - expected_x) > 0.01 || abs(M.f - expected_y) > 0.01)
		return "Macierz starego sprite'a: skala [M.a], przesunięcie [M.c],[M.f] zamiast [k], [expected_x],[expected_y]"

	// Pocisk daleko przed dziobem: efekt ląduje na dziobie (półoś długości kadłuba po skali), nie przy rogu hitboksu
	var/cx = ref[1] / 2 + ref[5]
	var/cy = ref[2] / 2 + ref[6]
	var/list/point = old_sprite.overmap_hull_point(cx, cy + 1000)
	var/half_length = disp[4] * k / 2
	if(!point || abs(point[1] - cx) > 0.5 || abs(point[2] - (cy + half_length)) > 0.5)
		return "Efekt trafienia od dziobu wylądował w [point?[1]],[point?[2]] zamiast [cx],[cy + half_length]"
	// Ten sam kierunek po obrocie okrętu o 90° (dziób na wschód): punkt na burcie, w odległości półosi szerokości
	old_sprite.angle = 90
	point = old_sprite.overmap_hull_point(cx, cy + 1000)
	var/half_width = disp[3] * k / 2
	if(!point || abs(point[2] - cy) > half_width + 0.5)
		return "Po obrocie o 90° efekt od północy wylądował w [point?[1]],[point?[2]] (środek [cx],[cy], półoś [half_width])"
	// Pocisk już w obrysie zostaje tam, gdzie jest
	old_sprite.angle = 0
	point = old_sprite.overmap_hull_point(cx + 1, cy + 1)
	if(!point || abs(point[1] - (cx + 1)) > 0.01 || abs(point[2] - (cy + 1)) > 0.01)
		return "Punkt wewnątrz kadłuba został przesunięty do [point?[1]],[point?[2]]"
