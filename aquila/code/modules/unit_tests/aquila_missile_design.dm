// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - projekt pocisku: stół przerabia silnik i naprowadzanie, a projekt z części przechodzi na torpedę i pocisk
/datum/unit_test/missile_design
	var/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/casing
	var/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/plain_casing
	var/obj/item/ship_weapon/parts/missile/warhead/torpedo/warhead
	var/obj/item/ship_weapon/parts/missile/warhead/torpedo/plain_warhead
	var/obj/item/ship_weapon/ammunition/torpedo/built
	var/obj/item/ship_weapon/ammunition/torpedo/plain_built
	var/obj/item/projectile/guided_munition/torpedo/proj

/datum/unit_test/missile_design/Run()
	var/datum/missile_design/D = new
	D.name = "Test"
	D.engine = "sprint"
	D.seeker = "brak"
	TEST_ASSERT(abs(D.mult("speed") - 0.6 * 0.9) < 0.001, "Speed modifiers of the design don't multiply")
	TEST_ASSERT(D.mult("integrity") == 1, "A design without a body option changes integrity")
	TEST_ASSERT(D.mult("turn") == 0, "An unguided design can still turn")
	qdel(D)

	// Stół przerabia układ napędowy leżący na nim
	casing = new(run_loc_floor_bottom_left)
	var/obj/item/ship_weapon/parts/missile/propulsion_system/engine = new(casing)
	var/obj/item/ship_weapon/parts/missile/guidance_system/guidance = new(casing)
	TEST_ASSERT(engine.aq_design_option == "standardowy", "A new propulsion system isn't standard")
	TEST_ASSERT(guidance.aq_design_option == "radar", "A new guidance system doesn't use radar")
	var/obj/machinery/missile_design_table/rework_table = allocate(/obj/machinery/missile_design_table, run_loc_floor_bottom_left)
	engine.forceMove(rework_table)
	rework_table.loaded_part = engine
	rework_table.finish_rework(engine, "sprint")
	TEST_ASSERT(engine.aq_design_option == "sprint", "The design table didn't rework the propulsion system")
	engine.forceMove(casing)
	TEST_ASSERT(!rework_table.loaded_part, "The table still holds a part that was taken off")
	guidance.set_design_option("brak")

	// Składanie: projekt wynika z części w obudowie
	warhead = new(casing)
	built = new /obj/item/ship_weapon/ammunition/torpedo(run_loc_floor_bottom_left)
	transfer_forged_munition(warhead, built)
	var/datum/component/missile_design/MD = built.GetComponent(/datum/component/missile_design)
	TEST_ASSERT(MD && MD.design.engine == "sprint" && MD.design.seeker == "brak", "The design didn't pass from the reworked parts to the finished torpedo")

	// Niezmienione części nie dają projektu
	plain_casing = new(run_loc_floor_bottom_left)
	new /obj/item/ship_weapon/parts/missile/propulsion_system(plain_casing)
	new /obj/item/ship_weapon/parts/missile/guidance_system(plain_casing)
	plain_warhead = new(plain_casing)
	plain_built = new /obj/item/ship_weapon/ammunition/torpedo(run_loc_floor_bottom_left)
	transfer_forged_munition(plain_warhead, plain_built)
	TEST_ASSERT(!plain_built.GetComponent(/datum/component/missile_design), "Standard parts gave the torpedo a design")

	// Z torpedy na pocisk: parametry i brak naprowadzania
	proj = new(run_loc_floor_bottom_left)
	var/base_speed = proj.speed
	var/base_range = proj.range
	transfer_forged_munition(built, proj)
	TEST_ASSERT(abs(proj.speed - base_speed * 0.6 * 0.9) < 0.001, "The design didn't change the projectile speed")
	TEST_ASSERT(proj.range == round(base_range * 0.6), "The sprint engine didn't shorten the range")
	TEST_ASSERT(!proj.homing, "An unguided projectile still homes")

	// Podczerwień gubi zimny cel
	var/datum/component/missile_design/PMD = proj.GetComponent(/datum/component/missile_design)
	PMD.design.seeker = "podczerwień"
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	if(ship)
		var/old_heat = ship.thrust_heat
		var/old_damp = ship.inertial_dampeners
		var/old_fire = ship.last_weapon_fire
		ship.thrust_heat = 0
		ship.inertial_dampeners = FALSE
		ship.last_weapon_fire = -INFINITY
		if(ship.get_signature_heat() < 0.12)
			TEST_ASSERT(isnull(PMD.seek(proj, ship)), "An infrared seeker kept a cold target")
		ship.thrust_heat = 2
		TEST_ASSERT(PMD.seek(proj, ship) == ship, "An infrared seeker lost a hot target")
		ship.thrust_heat = old_heat
		ship.inertial_dampeners = old_damp
		ship.last_weapon_fire = old_fire

	// Regresja: zapisane projekty po trwałym numerze; usunięcie wcześniejszego nie przesuwa celu load/delete
	// (okno wysyła numer jako liczbę, text2num zwraca ją bez zmian; tekst też działa)
	var/obj/machinery/missile_design_table/table = allocate(/obj/machinery/missile_design_table, run_loc_floor_bottom_left)
	var/list/old_designs = GLOB.missile_designs.Copy()
	var/datum/missile_design/first = new
	first.id = 900001
	var/datum/missile_design/second = new
	second.id = 900002
	second.name = "Drugi"
	GLOB.missile_designs += list(first, second)
	TEST_ASSERT(table.find_saved_design(900002) == second, "A saved design isn't found by its numeric id")
	TEST_ASSERT(table.find_saved_design("900002") == second, "A saved design isn't found by its id sent as text")
	GLOB.missile_designs -= first
	TEST_ASSERT(table.find_saved_design(900002) == second, "Deleting an earlier design moved the id of a later one")
	TEST_ASSERT(isnull(table.find_saved_design(900001)), "A deleted design is still found by its id")
	GLOB.missile_designs = old_designs
	qdel(first)
	qdel(second)

/datum/unit_test/missile_design/Destroy()
	QDEL_NULL(proj)
	QDEL_NULL(built)
	QDEL_NULL(plain_built)
	QDEL_NULL(warhead)
	QDEL_NULL(plain_warhead)
	QDEL_NULL(casing)
	QDEL_NULL(plain_casing)
	return ..()

#undef TEST_ASSERT
