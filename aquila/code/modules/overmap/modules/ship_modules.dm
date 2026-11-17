/// AQUILA - moduły okrętu na siatce wnętrza (plan walki na overmapie: raport/overmapa_06_plan_realizacji.html, etap „moduły”).
/// Moduł = pomieszczenie wnętrza abordażu (tools/overmap_modules/module_layouts.py -> ship_module_layouts.dm), więc trafiony
/// reaktor na siatce to ten sam reaktor we wnętrzu. Okręty bez wnętrza dostają zastępczy układ z proporcji kadłuba.
/// Trafienie: punkt na obrysie kadłuba (overmap_visual_scale.dm) -> układ okrętu (x od rufy do dziobu, y od lewej burty
/// do prawej) -> głębokość zależna od pancerza ćwiartki i dziur po wcześniejszych trafieniach -> obrażenia modułów na drodze.
/// Skutki dotyczą okrętów AI (okręt gracza ma prawdziwe wnętrze): silniki, broń, mostek, sensory, maskowanie, interdyktor,
/// hangar, FTL, reaktor (sprawność wszystkiego) i magazyn amunicji (wtórny wybuch).

#define SHIP_MODULE_MAX_HOLES 30
/// Poniżej tej części pancerza ćwiartki pocisk wchodzi w głąb kadłuba
#define SHIP_MODULE_ARMOUR_BREACH 0.5

GLOBAL_LIST_INIT(ship_module_names, list(
	"engine" = "silniki",
	"reactor" = "reaktor",
	"ftl" = "napęd FTL",
	"power" = "zasilanie",
	"bridge" = "mostek",
	"sensors" = "sensory",
	"flak" = "flak i PDC",
	"aa" = "działka przeciwlotnicze",
	"gauss" = "działo Gaussa",
	"vls" = "wyrzutnie rakiet",
	"torpedo" = "wyrzutnie torped",
	"mac" = "działo główne",
	"ammo" = "magazyn amunicji",
	"armory" = "zbrojownia",
	"quarters" = "kwatery",
	"medbay" = "ambulatorium",
	"cargo" = "ładownia",
	"hangar" = "hangar",
	"cloak" = "maskowanie",
	"interdictor" = "interdyktor",
))

/datum/ship_module
	var/kind
	/// Prostokąt w układzie okrętu (pola wnętrza)
	var/x0
	var/y0
	var/x1
	var/y1
	var/cells = 1
	var/max_integrity = 100
	var/integrity = 100

/datum/ship_module/New(kind, x0, y0, x1, y1, cells, max_integrity)
	src.kind = kind
	src.x0 = x0
	src.y0 = y0
	src.x1 = x1
	src.y1 = y1
	src.cells = cells
	src.max_integrity = max_integrity
	integrity = max_integrity

/datum/ship_module/proc/fraction()
	return max_integrity ? integrity / max_integrity : 1

/datum/ship_module/proc/destroyed()
	return integrity <= 0

/datum/ship_module/proc/contains(x, y)
	return x >= x0 - 0.5 && x <= x1 + 0.5 && y >= y0 - 0.5 && y <= y1 + 0.5

/datum/ship_module/proc/display_name()
	return GLOB.ship_module_names[kind] || kind

/// Moduły jednego okrętu
/datum/ship_modules
	var/obj/structure/overmap/ship
	/// Wymiary układu (pola): długość od rufy do dziobu, szerokość od lewej do prawej burty
	var/length = 40
	var/width = 16
	var/list/datum/ship_module/modules = list()
	/// Dziury w kadłubie: list(x, y, głębokość); trafienie blisko dziury wchodzi głębiej
	var/list/holes = list()
	/// Wartości okrętu sprzed uszkodzeń modułów
	var/list/base_values = list()
	/// Sprawność zasilania z reaktora (mnoży resztę)
	var/power = 1
	/// Szansa (%), że AI pominie tik decyzji przez zniszczony mostek
	var/bridge_disruption = 0
	var/cloak_disabled = FALSE
	var/interdictor_disabled = FALSE
	var/hangar_disabled = FALSE
	var/ftl_disabled = FALSE

/datum/ship_modules/New(obj/structure/overmap/ship)
	src.ship = ship
	var/list/layout = ship.ship_module_layout()
	if(layout)
		length = layout[1]
		width = layout[2]
		for(var/list/row in layout[3])
			add_module(row[1], row[2], row[3], row[4], row[5], row[6])
	else
		default_layout()
	if(!length(modules_of("engine"))) // ręczne mapy NSV mają routery silników przy reaktorze: silniki na rufie
		add_module("engine", 0, 0, max(1, round(length * 0.12)), width - 1, round(length * 0.12) * width)
	base_values = list(
		"forward" = ship.forward_maxthrust,
		"backward" = ship.backward_maxthrust,
		"side" = ship.side_maxthrust,
		"angular" = ship.max_angular_acceleration,
		"weapon_range" = ship.max_weapon_range,
	)

/datum/ship_modules/Destroy(force)
	ship = null
	QDEL_LIST(modules)
	return ..()

/datum/ship_modules/proc/add_module(kind, x0, y0, x1, y1, cells)
	var/hp = max(40, round(ship.max_integrity * 0.15 * clamp(cells / 60, 0.6, 2)))
	modules += new /datum/ship_module(kind, x0, y0, x1, y1, cells, hp)

/// Układ dla okrętów bez wnętrza: rufa silniki, potem reaktor, broń po burtach według broni okrętu, na dziobie mostek
/datum/ship_modules/proc/default_layout()
	length = 40
	width = 16
	add_module("engine", 0, 0, 5, 15, 96)
	add_module("power", 6, 0, 11, 4, 30)
	add_module("reactor", 6, 5, 11, 10, 36)
	add_module("ftl", 6, 11, 11, 15, 30)
	var/list/kinds = list()
	for(var/datum/overmap_ship_weapon/weapon in ship.overmap_weapon_datums)
		var/kind = ship_weapon_module_kind(weapon)
		if(kind && !(kind in kinds))
			kinds += kind
	var/list/slots = list(list(12, 0, 19, 4), list(12, 11, 19, 15), list(20, 0, 27, 4), list(20, 11, 27, 15))
	for(var/i in 1 to min(length(kinds), length(slots)))
		var/list/slot = slots[i]
		add_module(kinds[i], slot[1], slot[2], slot[3], slot[4], 40)
	add_module("ammo", 12, 5, 27, 10, 96)
	add_module("quarters", 28, 0, 33, 7, 48)
	add_module("medbay", 28, 8, 33, 15, 48)
	add_module("sensors", 34, 0, 39, 4, 30)
	add_module("bridge", 34, 5, 39, 10, 36)
	add_module("armory", 34, 11, 39, 15, 30)

/datum/ship_modules/proc/modules_of(kind)
	. = list()
	for(var/datum/ship_module/module as anything in modules)
		if(module.kind == kind)
			. += module

/datum/ship_modules/proc/has_kind(kind)
	for(var/datum/ship_module/module as anything in modules)
		if(module.kind == kind)
			return TRUE
	return FALSE

/// Średnia sprawność modułów danego rodzaju (1, gdy okręt takich nie ma)
/datum/ship_modules/proc/kind_efficiency(kind)
	var/total = 0
	var/count = 0
	for(var/datum/ship_module/module as anything in modules)
		if(module.kind != kind)
			continue
		total += module.fraction()
		count++
	return count ? total / count : 1

/// Moduł w punkcie układu: najmniejszy prostokąt, który go zawiera
/datum/ship_modules/proc/module_at(x, y)
	var/datum/ship_module/best
	for(var/datum/ship_module/module as anything in modules)
		if(!module.contains(x, y))
			continue
		if(!best || module.cells < best.cells)
			best = module
	return best

/// Część pancerza w ćwiartce, w którą weszło trafienie (bez ćwiartek: stan kadłuba)
/datum/ship_modules/proc/armour_fraction(x, y)
	if(!ship.use_armour_quadrants)
		return ship.max_integrity ? ship.obj_integrity / ship.max_integrity : 1
	var/quadrant = "[(x >= length / 2) ? "forward" : "aft"]_[(y < width / 2) ? "port" : "starboard"]"
	var/list/armour = ship.armour_quadrants[quadrant]
	if(!length(armour) || !armour["max_armour"])
		return 1
	return armour["current_armour"] / armour["max_armour"]

/// Głębokość wejścia pocisku (pola): pełny pancerz zatrzymuje go na poszyciu, zbity wpuszcza w głąb, stara dziura pogłębia.
/// ignore_armour: rakieta albo torpeda, która nie przebija się przez burtę, tylko wybucha w module
/datum/ship_modules/proc/penetration_depth(x, y, damage, ignore_armour = FALSE)
	var/armour = ignore_armour ? 0 : armour_fraction(x, y)
	var/depth = 0
	if(armour < SHIP_MODULE_ARMOUR_BREACH)
		depth = clamp(damage / 8, 2, 12) * (1 - armour / SHIP_MODULE_ARMOUR_BREACH)
	for(var/list/hole as anything in holes)
		if(abs(hole[1] - x) <= 3 && abs(hole[2] - y) <= 3)
			depth += hole[3] * 0.5
			break
	return depth

/// Zapisuje dziurę (łączy z bliską istniejącą)
/datum/ship_modules/proc/add_hole(x, y, depth)
	if(depth <= 0)
		return
	for(var/list/hole as anything in holes)
		if(abs(hole[1] - x) <= 1.5 && abs(hole[2] - y) <= 1.5)
			hole[3] = max(hole[3], depth)
			return
	holes += list(list(x, y, depth))
	if(length(holes) > SHIP_MODULE_MAX_HOLES)
		holes.Cut(1, 2)

/// Trafienie w punkcie układu (x, y) z kierunkiem lotu (dx, dy) w układzie; zwraca listę trafionych modułów
/datum/ship_modules/proc/hit(x, y, dx, dy, damage, ignore_armour = FALSE)
	. = list()
	var/depth = penetration_depth(x, y, damage, ignore_armour)
	add_hole(x, y, depth)
	if(depth <= 0)
		return
	var/norm = sqrt(dx * dx + dy * dy)
	if(!norm)
		return
	dx /= norm
	dy /= norm
	var/share = 1
	for(var/step in 0 to round(depth * 2))
		var/datum/ship_module/module = module_at(x + dx * step / 2, y + dy * step / 2)
		if(!module || (module in .))
			continue
		. += module
		damage_module(module, damage * share)
		share *= 0.5
	on_inside_hit(., depth, damage)
	apply_effects()

/datum/ship_modules/proc/damage_module(datum/ship_module/module, amount)
	if(module.destroyed() || amount <= 0)
		return
	module.integrity = max(0, module.integrity - amount)
	if(module.destroyed())
		on_module_destroyed(module)

/// Zniszczony magazyn amunicji wybucha: kadłub i sąsiednie moduły
/datum/ship_modules/proc/on_module_destroyed(datum/ship_module/module)
	if(module.kind != "ammo")
		return
	ship.take_damage(ship.max_integrity * 0.05, BRUTE, "overmap_heavy", nsv_damagesound = TRUE)
	var/mid_x = (module.x0 + module.x1) / 2
	var/mid_y = (module.y0 + module.y1) / 2
	for(var/datum/ship_module/other as anything in modules)
		if(other == module)
			continue
		if(abs((other.x0 + other.x1) / 2 - mid_x) <= 8 && abs((other.y0 + other.y1) / 2 - mid_y) <= 6)
			damage_module(other, other.max_integrity * 0.3)

/// Przelicza zdolności okrętu z sprawności modułów
/datum/ship_modules/proc/apply_effects()
	power = 0.4 + 0.6 * kind_efficiency("reactor")
	var/engines = kind_efficiency("engine") * power
	ship.forward_maxthrust = base_values["forward"] * max(0.15, engines)
	ship.backward_maxthrust = base_values["backward"] * max(0.15, engines)
	ship.side_maxthrust = base_values["side"] * max(0.15, engines)
	ship.max_angular_acceleration = base_values["angular"] * max(0.25, engines)
	// ślepe sensory: AI podejmuje walkę z mniejszej odległości
	if(base_values["weapon_range"])
		ship.max_weapon_range = round(base_values["weapon_range"] * (0.4 + 0.6 * kind_efficiency("sensors") * power))
	bridge_disruption = has_kind("bridge") ? round((1 - kind_efficiency("bridge")) * 60) : 0
	if(has_kind("cloak") && !cloak_disabled && kind_efficiency("cloak") * power < 0.3)
		cloak_disabled = TRUE
		ship.handle_cloak(FALSE)
	interdictor_disabled = has_kind("interdictor") && kind_efficiency("interdictor") * power < 0.3
	hangar_disabled = has_kind("hangar") && kind_efficiency("hangar") * power < 0.3
	if(hangar_disabled)
		ship.ai_can_launch_fighters = FALSE
	ftl_disabled = has_kind("ftl") && kind_efficiency("ftl") * power < 0.2

/// Sprawność broni w module tego rodzaju (1, gdy okręt nie ma takiego modułu)
/datum/ship_modules/proc/weapon_efficiency(kind)
	if(!kind || !has_kind(kind))
		return 1
	return kind_efficiency(kind) * power

/// Rodzaj modułu, z którego strzela broń okrętu
/proc/ship_weapon_module_kind(datum/overmap_ship_weapon/weapon)
	var/path = "[weapon.type]"
	if(findtext(path, "torpedo"))
		return "torpedo"
	if(findtext(path, "flak") || findtext(path, "pdc"))
		return "flak"
	if(findtext(path, "aa_guns") || findtext(path, "laser_ams") || findtext(path, "hailstorm"))
		return "aa"
	if(findtext(path, "gauss"))
		return "gauss"
	if(findtext(path, "missile") || findtext(path, "vls") || findtext(path, "light_cannon"))
		return "vls"
	if(findtext(path, "mac") || findtext(path, "railgun") || findtext(path, "heavy_cannon") || findtext(path, "broadside") || findtext(path, "bsa") || findtext(path, "plasma_caster"))
		return "mac"
	return null

/obj/structure/overmap
	/// AQUILA - moduły na siatce wnętrza (tylko okręty AI, tworzone przy pierwszym trafieniu albo podglądzie)
	var/datum/ship_modules/ship_modules

/obj/structure/overmap/Destroy()
	QDEL_NULL(ship_modules)
	return ..()

/// Czy okręt ma moduły: duże okręty bez prawdziwego wnętrza gracza (myśliwce i okręt główny nie)
/obj/structure/overmap/proc/uses_ship_modules()
	if(istype(src, /obj/structure/overmap/small_craft) || mass <= MASS_TINY)
		return FALSE
	return role != MAIN_OVERMAP

/obj/structure/overmap/proc/get_ship_modules()
	if(!ship_modules && uses_ship_modules())
		ship_modules = new(src)
	return ship_modules

/// Układ modułów z pierwszego wnętrza abordażu okrętu, które ma siatkę
/obj/structure/overmap/proc/ship_module_layout()
	for(var/template_type in possible_interior_maps)
		var/list/layout = GLOB.ship_module_layouts[template_type]
		if(layout)
			return layout
	return null

/// Trafienie pociskiem: punkt na obrysie kadłuba -> układ modułów
/obj/structure/overmap/proc/ship_module_projectile_hit(obj/item/projectile/P, damage)
	var/datum/ship_modules/modules = get_ship_modules()
	if(!modules)
		return
	if(istype(P, /obj/item/projectile/guided_munition))
		return guided_module_hit(P, damage)
	var/list/local = overmap_hull_local((P.x - x) * 32 + P.pixel_x + 16, (P.y - y) * 32 + P.pixel_y + 16)
	if(!local)
		return
	// local: punkt w układzie okrętu (dziób = +y, prawa burta = +x) i półosie kadłuba
	var/u = clamp(local[2] / local[4], -1, 1)
	var/v = clamp(local[1] / local[3], -1, 1)
	var/layout_x = (u + 1) / 2 * modules.length
	var/layout_y = (v + 1) / 2 * modules.width
	// kierunek lotu pocisku w układzie okrętu (kąt pocisku: 0 = północ, zgodnie z zegarem)
	var/wx = sin(P.Angle)
	var/wy = cos(P.Angle)
	var/c = cos(angle)
	var/s = sin(angle)
	var/sx = wx * c - wy * s
	var/sy = wx * s + wy * c
	var/dir_x = sy * modules.length / (2 * local[4])
	var/dir_y = sx * modules.width / (2 * local[3])
	return modules.hit(layout_x, layout_y, dir_x, dir_y, damage)

/// Rakieta albo torpeda ignoruje burty: wybucha w module, który wybrał strzelec w konsoli taktycznej (bez wyboru w losowym),
/// z pominięciem pancerza ćwiartki. Odłamki idą od punktu wybuchu w losowym kierunku.
/obj/structure/overmap/proc/guided_module_hit(obj/item/projectile/P, damage)
	var/datum/ship_modules/modules = get_ship_modules()
	if(!length(modules?.modules))
		return
	var/datum/ship_module/module
	var/index = LAZYACCESS(P.overmap_firer?.aim_modules, src)
	if(index && index <= length(modules.modules))
		module = modules.modules[index]
	if(!module)
		module = pick(modules.modules)
	var/x = module.x0 + rand() * (module.x1 - module.x0)
	var/y = module.y0 + rand() * (module.y1 - module.y0)
	var/heading = rand(0, 359)
	return modules.hit(x, y, sin(heading), cos(heading), damage, TRUE)

/// Obrażenia, które pocisk zadaje modułom: po pancerzu okrętu na klasę pocisku (lekki, średni, ciężki) i po przebiciu,
/// jak kadłub. Pocisk przeciwpancerny wchodzi więc głębiej w opancerzony okręt, a lekki ledwo drapie ciężko opancerzony.
/obj/structure/overmap/proc/module_damage_from(obj/item/projectile/P)
	if(!P)
		return 0
	return run_obj_armor(P.damage, P.damage_type, P.flag, null, P.armour_penetration)

/obj/structure/overmap/bullet_act(obj/item/projectile/P)
	var/damage = module_damage_from(P)
	. = ..()
	if(QDELETED(src) || QDELETED(P))
		return
	if(. == BULLET_ACT_FORCE_PIERCE || (!isnull(.) && !.)) // tarcza
		return
	if(!damage || P.damage_type == STAMINA)
		return
	ship_module_projectile_hit(P, damage)

// Zniszczony mostek: AI czasem nie podejmuje decyzji w tym tiku
/obj/structure/overmap/ai_process()
	if(ship_modules?.bridge_disruption && prob(ship_modules.bridge_disruption))
		return
	return ..()

// Zniszczony moduł maskowania nie pozwala wrócić do maskowania
/obj/structure/overmap/handle_cloak(state)
	if(state && ship_modules?.cloak_disabled)
		return
	return ..()

// Zniszczony hangar: lotniskowiec nie wypuszcza myśliwców
/obj/structure/overmap/add_enemy(atom/target)
	if(ship_modules?.hangar_disabled)
		ai_can_launch_fighters = FALSE
	return ..()

// Zniszczony interdyktor nie trzyma okrętów w systemie
/datum/component/interdiction/check_interdict(datum/source, obj/structure/overmap/interdicted)
	if(owner?.ship_modules?.interdictor_disabled)
		return
	return ..()

// Broń z uszkodzonego modułu strzela rzadziej, ze zniszczonego wcale
/datum/overmap_ship_weapon/can_fire(atom/target, list/inplace_report)
	. = ..()
	if(!.)
		return
	var/datum/ship_modules/modules = linked_overmap?.ship_modules
	if(!modules)
		return
	var/efficiency = modules.weapon_efficiency(ship_weapon_module_kind(src))
	if(efficiency >= 1)
		return
	if(efficiency <= 0.05 || !prob(round(100 * sqrt(efficiency))))
		if(inplace_report)
			inplace_report[1] = "Błąd - uszkodzony moduł broni. ([src])"
		return FALSE

#undef SHIP_MODULE_MAX_HOLES
#undef SHIP_MODULE_ARMOUR_BREACH
