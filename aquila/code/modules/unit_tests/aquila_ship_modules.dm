/// AQUILA - moduły okrętu na siatce wnętrza (aquila/code/modules/overmap/modules/ship_modules.dm): siatka z mapy wnętrza,
/// pełny pancerz zatrzymuje trafienie na poszyciu, zbity wpuszcza je w głąb, dziura pogłębia następne trafienie,
/// a zniszczone moduły tną ciąg silników i wyłączają broń swojego rodzaju. Moduły biorą obrażenia po pancerzu okrętu na klasę
/// pocisku i po przebiciu, a pocisk z kuźni z cechą radioaktywną zabija załogę trafionego modułu. Rakiety i torpedy
/// ignorują burty: wybuchają w module wybranym przez strzelca mimo pełnego pancerza, a w okręcie z wnętrzem w losowym punkcie.
/datum/unit_test/aquila_ship_modules
	var/obj/structure/overmap/ship

/datum/unit_test/aquila_ship_modules/Run()
	ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	var/fail = check_layouts() || check_hits() || check_armour_damage() || check_radiation() || check_guided() || check_effects()
	if(fail)
		return Fail(fail)

/datum/unit_test/aquila_ship_modules/proc/check_layouts()
	var/list/layout = GLOB.ship_module_layouts[/datum/map_template/boarding/barracuda]
	if(!layout)
		return "Brak siatki modułów Barracudy w ship_module_layouts"
	var/list/kinds = list()
	for(var/list/row in layout[3])
		kinds |= row[1]
	for(var/kind in list("engine", "reactor", "bridge", "mac", "flak"))
		if(!(kind in kinds))
			return "Siatka Barracudy nie ma modułu [kind] (są: [jointext(kinds, ", ")])"
	if(!ship.uses_ship_modules())
		return "Fregata przeciwlotnicza AI nie używa modułów"
	var/datum/ship_modules/modules = ship.get_ship_modules()
	if(!modules || !modules.has_kind("flak") || !modules.has_kind("engine"))
		return "Fregata przeciwlotnicza nie dostała siatki z wnętrza (flak, silniki)"

/datum/unit_test/aquila_ship_modules/proc/set_armour(fraction)
	if(ship.use_armour_quadrants)
		for(var/quadrant in ship.armour_quadrants)
			var/list/armour = ship.armour_quadrants[quadrant]
			armour["current_armour"] = armour["max_armour"] * fraction
	else
		ship.obj_integrity = ship.max_integrity * max(fraction, 0.01)

/datum/unit_test/aquila_ship_modules/proc/check_hits()
	var/datum/ship_modules/modules = ship.get_ship_modules()
	var/datum/ship_module/bridge = modules.modules_of("bridge")[1]
	// trafienie w środek mostka od dziobu (pocisk leci ku rufie)
	var/x = bridge.x1 + 0.4
	var/y = (bridge.y0 + bridge.y1) / 2
	set_armour(1)
	modules.hit(x, y, -1, 0, 60)
	if(bridge.integrity != bridge.max_integrity)
		return "Pełny pancerz przepuścił trafienie do mostka ([bridge.integrity]/[bridge.max_integrity])"
	set_armour(0)
	var/list/hit = modules.hit(x, y, -1, 0, 30)
	if(!(bridge in hit) || bridge.integrity >= bridge.max_integrity)
		return "Przy zbitym pancerzu trafienie nie uszkodziło mostka"
	var/first_depth = modules.penetration_depth(x + 10, y + 10, 30) // daleko od dziury
	var/hole_depth = modules.penetration_depth(x, y, 30)
	if(hole_depth <= first_depth)
		return "Trafienie w dziurę nie weszło głębiej ([hole_depth] wobec [first_depth])"

/datum/unit_test/aquila_ship_modules/proc/check_effects()
	var/datum/ship_modules/modules = ship.get_ship_modules()
	var/base_thrust = modules.base_values["forward"]
	for(var/datum/ship_module/engine as anything in modules.modules_of("engine"))
		modules.damage_module(engine, engine.max_integrity)
	modules.apply_effects()
	if(ship.forward_maxthrust > base_thrust * 0.5)
		return "Zniszczone silniki zostawiły ciąg [ship.forward_maxthrust] z [base_thrust]"
	for(var/datum/ship_module/flak as anything in modules.modules_of("flak"))
		modules.damage_module(flak, flak.max_integrity)
	if(modules.weapon_efficiency("flak") > 0.05)
		return "Zniszczony flak ma sprawność [modules.weapon_efficiency("flak")]"
	for(var/datum/overmap_ship_weapon/weapon in ship.overmap_weapon_datums)
		if(ship_weapon_module_kind(weapon) != "flak")
			continue
		weapon.next_firetime = 0
		if(weapon.can_fire(null))
			return "Broń [weapon] strzela mimo zniszczonego modułu flak"

/datum/unit_test/aquila_ship_modules/proc/check_armour_damage()
	var/obj/item/projectile/bullet/shell = allocate(/obj/item/projectile/bullet)
	shell.damage = 100
	shell.damage_type = BRUTE
	shell.flag = "overmap_heavy"
	shell.armour_penetration = 0
	var/datum/armor/old_armor = ship.armor
	ship.armor = getArmor(overmap_heavy = 50)
	var/plain = ship.module_damage_from(shell)
	shell.armour_penetration = 50
	var/piercing = ship.module_damage_from(shell)
	shell.flag = "overmap_light"
	shell.armour_penetration = 0
	var/light = ship.module_damage_from(shell)
	ship.armor = old_armor
	if(plain != 50)
		return "Pancerz ciężki 50 przepuścił do modułów [plain] ze 100 zamiast 50"
	if(piercing != 100)
		return "Przebicie 50 przy pancerzu 50 dało modułom [piercing] zamiast 100"
	if(light != 100)
		return "Pocisk lekki przy zerowym pancerzu lekkim dał modułom [light] zamiast 100"

/datum/unit_test/aquila_ship_modules/proc/check_radiation()
	var/datum/ship_modules/modules = ship.get_ship_modules()
	var/before = 0
	for(var/datum/ship_module/module as anything in modules.modules)
		module.crew_lost = 0
	var/datum/munition_trait/radioactive/rad = new(1)
	rad.on_overmap_hit(null, ship, null)
	var/after = 0
	for(var/datum/ship_module/module as anything in modules.modules)
		after += module.crew_lost
	if(after - before < 0.24)
		return "Pocisk radioaktywny zabił tylko [after - before] załogi modułu (oczekiwane co najmniej 0,25)"

/datum/unit_test/aquila_ship_modules/proc/check_guided()
	if(!is_unguided_overmap_projectile(/obj/item/projectile/bullet/mac_round))
		return "Artyleria MAC nie celuje w wybrany moduł"
	if(is_unguided_overmap_projectile(/obj/item/projectile/guided_munition/torpedo))
		return "Torpeda liczy się jak pocisk niekierowany"
	var/datum/ship_modules/modules = ship.get_ship_modules()
	var/datum/ship_module/bridge = modules.modules_of("bridge")[1]
	set_armour(1)
	bridge.integrity = bridge.max_integrity
	var/obj/structure/overmap/firer = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	firer.set_aim_module(ship, modules.modules.Find(bridge))
	var/obj/item/projectile/guided_munition/torpedo/torp = allocate(/obj/item/projectile/guided_munition/torpedo)
	torp.overmap_firer = firer
	var/list/hit = ship.ship_module_projectile_hit(torp, 60)
	if(!(bridge in hit) || bridge.integrity >= bridge.max_integrity)
		return "Torpeda przy pełnym pancerzu nie trafiła wybranego mostka ([bridge.integrity]/[bridge.max_integrity])"
	// okręt z wnętrzem: rakieta trafia w losowy punkt i nie patrzy na pancerz ćwiartki
	ship.remember_hull_hit(torp)
	var/list/hull_hit = ship.last_hull_hit
	ship.last_hull_hit = null
	if(length(hull_hit) < 5 || ship.hull_hit_armour(hull_hit) != 0)
		return "Torpeda w okręcie z wnętrzem zatrzymuje się na pancerzu burty"
