/// AQUILA - manewrowanie na dystansie i czekanie na flotę (aquila/code/modules/overmap/ai_formation.dm):
/// okręt trzymający dystans leci do punktu na okręgu wokół celu zamiast stać, a przed zejściem
/// na zasięg dział sprawdza, czy ma przy sobie dość swoich.

/// Podtyp testowy: liczenie wrogów i swoich idzie przez system gwiezdny, którego w teście nie ma,
/// więc obie liczby są tu podstawiane wprost.
/obj/structure/overmap/small_craft/combat/light/formation_test
	var/test_threats = 0
	var/test_support = 0

/obj/structure/overmap/small_craft/combat/light/formation_test/count_ai_threats(range)
	return test_threats

/obj/structure/overmap/small_craft/combat/light/formation_test/count_ai_support()
	return test_support

/obj/structure/overmap/small_craft/combat/light/formation_test/count_ai_threats_allies(range)
	return test_support

/datum/unit_test/aquila_ai_formation
	var/obj/structure/overmap/small_craft/combat/light/formation_test/ship
	var/obj/structure/overmap/small_craft/target

/datum/unit_test/aquila_ai_formation/Run()
	var/was_enabled = GLOB.ai_formation_enabled
	GLOB.ai_formation_enabled = TRUE
	ship = allocate(/obj/structure/overmap/small_craft/combat/light/formation_test)
	target = allocate(/obj/structure/overmap/small_craft/combat/light)
	target.faction = "syndicate"
	ship.ai_controlled = TRUE
	ship.mass = MASS_MEDIUM
	var/fail = check_standoff_point() || check_waiting() || check_guard() || check_disabled()
	ship.ai_controlled = FALSE
	GLOB.ai_formation_enabled = was_enabled
	if(fail)
		return Fail(fail)

/// Punkt trzymania dystansu leży na okręgu wokół celu, obok nas, i trzyma się przez chwilę
/datum/unit_test/aquila_ai_formation/proc/check_standoff_point()
	var/z = run_loc_floor_bottom_left.z
	target.forceMove(locate(60, 60, z))
	ship.forceMove(locate(100, 60, z)) // 40 pól na wschód od celu
	ship.ai_standoff_point = null
	ship.ai_standoff_until = 0
	ship.ai_standoff_side = 0
	var/turf/spot = ship.get_ai_standoff_point(target, 40)
	if(!spot)
		return "Okręt na dystansie nie dostał żadnego punktu do lecenia"
	var/promien = overmap_dist(target, spot)
	if(promien < 30 || promien > 50)
		return "Punkt nie leży na okręgu dystansu (odległość od celu [promien], miało być około 40)"
	if(spot == get_turf(ship))
		return "Punktem okazało się miejsce, w którym okręt już stoi"
	// Bazowe move_toward() odpala silniki dopiero powyżej 12 pól, więc bliższy punkt znaczyłby stanie
	if(overmap_dist(ship, spot) < 13)
		return "Punkt wypadł w martwej strefie silników ([overmap_dist(ship, spot)] pól)"
	// Dopóki nie dolecimy i nie minie czas, trzymamy ten sam punkt, żeby nie zygzakować
	var/turf/znowu = ship.get_ai_standoff_point(target, 40)
	if(znowu != spot)
		return "Okręt zmienił punkt, zanim do niego doleciał"
	// Po wygaśnięciu czasu wybiera nowy
	ship.ai_standoff_until = world.time - 1
	var/turf/kolejny = ship.get_ai_standoff_point(target, 40)
	if(!kolejny)
		return "Po wygaśnięciu punktu okręt nie wybrał nowego"
	var/promien2 = overmap_dist(target, kolejny)
	if(promien2 < 30 || promien2 > 50)
		return "Kolejny punkt spadł z okręgu dystansu ([promien2])"

/// Przewaga wroga każe poczekać na swoich, a brawurowy ma to gdzieś
/datum/unit_test/aquila_ai_formation/proc/check_waiting()
	var/datum/fleet/flota = new /datum/fleet()
	ship.fleet = flota
	ship.last_target = target
	ship.ai_fleeing = FALSE
	var/wynik
	ship.ai_temperament = null
	ship.test_threats = 1
	ship.test_support = 0
	if(ship.ai_waits_for_support(target))
		wynik = "Okręt czekał na flotę przy jednym przeciwniku"
	if(!wynik)
		ship.test_threats = 4
		if(!ship.ai_waits_for_support(target))
			wynik = "Samotny okręt ruszył na czterech wrogów"
	if(!wynik)
		ship.test_support = 4
		if(ship.ai_waits_for_support(target))
			wynik = "Okręt czekał, choć miał przy sobie czterech swoich"
	if(!wynik)
		ship.test_support = 0
		ship.ai_temperament = "brawurowy"
		if(ship.ai_waits_for_support(target))
			wynik = "Brawurowy dowódca czekał na resztę floty"
	if(!wynik)
		ship.ai_temperament = "ostrożny"
		ship.test_threats = 2
		ship.test_support = 1
		if(!ship.ai_waits_for_support(target))
			wynik = "Ostrożny dowódca nie czekał przy przewadze wroga"
	if(!wynik)
		// Uciekającego to nie dotyczy
		ship.ai_temperament = null
		ship.test_threats = 4
		ship.test_support = 0
		ship.ai_fleeing = TRUE
		if(ship.ai_waits_for_support(target))
			wynik = "Uciekający okręt zatrzymał się, żeby czekać na flotę"
	ship.ai_fleeing = FALSE
	ship.last_target = null
	ship.fleet = null
	flota.all_ships = null
	return wynik

/// Eskorta przy osłanianym okręcie krąży zamiast parkować (nadpisanie guard() w ai_formation.dm)
/datum/unit_test/aquila_ai_formation/proc/check_guard()
	var/z = run_loc_floor_bottom_left.z
	var/datum/ai_goal/cel = new /datum/ai_goal/defend()
	var/obj/structure/overmap/small_craft/oslaniany = allocate(/obj/structure/overmap/small_craft/combat/light)
	oslaniany.forceMove(locate(60, 60, z))
	ship.forceMove(locate(66, 60, z)) // 6 pól, czyli w promieniu AI_PDC_RANGE
	ship.brakes = TRUE
	ship.move_mode = null
	cel.guard(ship, oslaniany)
	var/wynik
	if(ship.brakes)
		wynik = "Eskorta w promieniu osłony dalej ma zaciągnięte hamulce"
	else if(!ship.move_mode)
		wynik = "Eskorta w promieniu osłony nie ma ustawionego ciągu"
	if(!wynik)
		// Z wyłączonym przełącznikiem wraca bazowe parkowanie
		GLOB.ai_formation_enabled = FALSE
		ship.brakes = FALSE
		ship.move_mode = NORTH
		cel.guard(ship, oslaniany)
		if(!ship.brakes || ship.move_mode)
			wynik = "Z wyłączonym przełącznikiem eskorta nie wróciła do bazowego parkowania"
		GLOB.ai_formation_enabled = TRUE
	if(!wynik)
		// Okręt osłaniający sam siebie nie ma wokół czego krążyć
		ship.brakes = FALSE
		ship.move_mode = NORTH
		cel.guard(ship, ship)
		if(!ship.brakes || ship.move_mode)
			wynik = "Okręt osłaniający sam siebie próbował krążyć wokół siebie"
	// Gałąź "daleko od osłanianego" to bazowe move_toward(), przepisane bez zmian. Nie da się jej tu wywołać:
	// bazowe omijanie przeszkód czyta current_system.system_contents (ai-skynet.dm), a okręt w teście
	// nie jest w żadnym systemie gwiezdnym.
	qdel(cel)
	return wynik

/// Z wyłączonym przełącznikiem nie ma ani punktu, ani czekania
/datum/unit_test/aquila_ai_formation/proc/check_disabled()
	GLOB.ai_formation_enabled = FALSE
	ship.ai_standoff_until = 0
	if(ship.get_ai_standoff_point(target, 40))
		return "Punkt dystansu powstał mimo wyłączonego przełącznika"
	ship.test_threats = 9
	ship.test_support = 0
	if(ship.ai_waits_for_support(target))
		return "Czekanie na flotę działało mimo wyłączonego przełącznika"
	GLOB.ai_formation_enabled = TRUE
