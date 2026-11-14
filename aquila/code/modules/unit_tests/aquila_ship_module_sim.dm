/// AQUILA - symulacja wnętrza wroga (aquila/code/modules/overmap/modules/ship_module_sim.dm): trafienie w głąb zapala
/// moduł, ogień go niszczy w kolejnych tikach, zniszczony moduł traci całą załogę, a wyłom zabija załogę dalej.
/datum/unit_test/aquila_ship_module_sim
	var/obj/structure/overmap/ship

/datum/unit_test/aquila_ship_module_sim/Run()
	ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	var/datum/ship_modules/modules = ship.get_ship_modules()
	if(!modules)
		return Fail("Fregata przeciwlotnicza AI nie ma modułów")
	var/datum/ship_module/target = modules.modules_of("bridge")[1]
	// trafienie w głąb: ogień i wyłom w pierwszym module
	modules.on_inside_hit(list(target), 4, 200)
	if(!target.fire)
		return Fail("Trafienie za 200 nie zapaliło modułu")
	if(!target.breached)
		return Fail("Głębokie trafienie nie zrobiło wyłomu")
	if(target.crew_lost <= 0)
		return Fail("Trafienie nie zabiło nikogo z załogi modułu")
	// ogień i wyłom w tiku: moduł traci wytrzymałość, załoga ginie dalej
	var/integrity_before = target.integrity
	var/crew_before = target.crew_lost
	target.fire = 3
	modules.sim_tick()
	if(target.integrity >= integrity_before)
		return Fail("Pożar nie uszkodził modułu ([target.integrity] z [integrity_before])")
	if(target.crew_lost <= crew_before)
		return Fail("Pożar i wyłom nie zabiły załogi modułu")
	// zniszczony moduł: cała załoga martwa, ogień gaśnie
	modules.damage_module(target, target.max_integrity)
	target.fire = 2
	modules.sim_tick()
	if(target.crew_lost < 1 || target.fire)
		return Fail("Zniszczony moduł ma załogę [target.crew_lost] i ogień [target.fire]")
	// mostek zniszczony: AI traci część tików decyzji
	modules.apply_effects()
	if(modules.bridge_disruption <= 0)
		return Fail("Zniszczony mostek nie zakłócił decyzji AI")
