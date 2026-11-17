/// AQUILA - wybór modułu wroga jako punktu celowania w konsoli taktycznej (FireControl.tsx, karta wybranego kontaktu).
/// Strzelec klika moduł na siatce namierzonego okrętu; pociski niekierowane (także artyleria MAC) lecą w ten punkt kadłuba
/// zamiast w środek, a gdzie trafią, rozstrzyga geometria (overmap_visual_scale.dm, ship_modules.dm). Rakiety i torpedy lecą
/// do okrętu jak zawsze, ale wybuchają w wybranym module (guided_module_hit w ship_modules.dm). AI bez zmian.

/obj/structure/overmap
	/// AQUILA - wybrany moduł celu: cel -> indeks w ship_modules.modules
	var/list/aim_modules

/// Siatka modułów okrętu dla okna: list(length, width, modules = list(list(index, name, kind, x0, y0, x1, y1, pct, fire, breached)))
/obj/structure/overmap/proc/ship_modules_report()
	var/datum/ship_modules/modules = get_ship_modules()
	if(!modules)
		return null
	var/list/rows = list()
	for(var/i in 1 to length(modules.modules))
		var/datum/ship_module/module = modules.modules[i]
		rows += list(list(
			"index" = i,
			"name" = module.display_name(),
			"kind" = module.kind,
			"x0" = module.x0,
			"y0" = module.y0,
			"x1" = module.x1,
			"y1" = module.y1,
			"pct" = round(100 * module.fraction()),
			"fire" = module.fire,
			"breached" = module.breached,
		))
	return list("length" = modules.length, "width" = modules.width, "modules" = rows)

/// Pole na mapie, w które celować, żeby trafić wybrany moduł celu; null bez wyboru
/obj/structure/overmap/proc/aim_turf_for(obj/structure/overmap/target)
	var/index = LAZYACCESS(aim_modules, target)
	var/datum/ship_modules/modules = target?.ship_modules
	if(!index || !modules || index > length(modules.modules))
		return null
	var/datum/ship_module/module = modules.modules[index]
	var/list/local = target.overmap_hull_local(0, 0)
	if(!local)
		return null
	// środek modułu w układzie okrętu: u od rufy (-1) do dziobu (1), v od lewej (-1) do prawej burty (1)
	var/u = ((module.x0 + module.x1) / 2 + 0.5) / modules.length * 2 - 1
	var/v = ((module.y0 + module.y1) / 2 + 0.5) / modules.width * 2 - 1
	var/lx = v * local[3]
	var/ly = u * local[4]
	var/c = cos(target.angle)
	var/s = sin(target.angle)
	var/wx = local[5] + lx * c + ly * s
	var/wy = local[6] - lx * s + ly * c
	return locate(target.x + round(wx / 32), target.y + round(wy / 32), target.z)

/obj/structure/overmap/proc/set_aim_module(obj/structure/overmap/target, index)
	if(!index || LAZYACCESS(aim_modules, target) == index)
		LAZYREMOVE(aim_modules, target)
		return
	LAZYSET(aim_modules, target, index)

/obj/structure/overmap/proc/prune_aim_modules()
	for(var/obj/structure/overmap/target as anything in aim_modules)
		if(QDELETED(target) || !LAZYFIND(target_painted, target))
			LAZYREMOVE(aim_modules, target)

/// Pocisk leci prosto, tam gdzie wycelowano (nie kierowany, nie promień). Artyleria MAC tylko lekko się naprowadza
/// (Magneton dłużej), więc przy wybranym module celuje w moduł i traci naprowadzanie.
/proc/is_unguided_overmap_projectile(proj_type)
	if(!ispath(proj_type, /obj/item/projectile) || ispath(proj_type, /obj/item/projectile/guided_munition))
		return FALSE
	var/obj/item/projectile/proj = proj_type
	if(initial(proj.hitscan))
		return FALSE
	return !initial(proj.can_home) || ispath(proj_type, /obj/item/projectile/bullet/mac_round)

// wybrany moduł celu: strzelec gracza celuje w ten punkt kadłuba
/obj/structure/overmap/fire_projectile(proj_type, atom/target, pixel_speed = null, user_override = null, firing_flags = NONE, ai_aim = FALSE, miss_chance = 5, max_miss_distance = 5, spread_override = null, projectile_speed = null)
	var/aimed = FALSE
	if(isovermap(target) && !ai_aim && LAZYLEN(aim_modules) && is_unguided_overmap_projectile(proj_type))
		var/turf/aim = aim_turf_for(target)
		if(aim)
			target = aim
			aimed = TRUE
	. = ..(proj_type, target, pixel_speed, user_override, firing_flags, ai_aim, miss_chance, max_miss_distance, spread_override, projectile_speed)
	var/obj/item/projectile/proj = .
	if(aimed && istype(proj) && proj.homing)
		proj.homing = FALSE // naprowadzanie ściągnęłoby pocisk z wybranego modułu do środka okrętu
		proj.homing_target = null
