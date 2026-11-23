// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - projekt pocisku: multitool ustawia silnik i naprowadzanie na obudowie, a ustawienie przechodzi na torpedę i pocisk
/datum/unit_test/missile_design
	var/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/casing
	var/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/plain_casing
	var/obj/item/ship_weapon/parts/missile/warhead/torpedo/warhead
	var/obj/item/ship_weapon/parts/missile/warhead/torpedo/plain_warhead
	var/obj/item/ship_weapon/ammunition/torpedo/built
	var/obj/item/ship_weapon/ammunition/torpedo/plain_built
	var/obj/item/projectile/guided_munition/torpedo/proj

/// Obudowa, która zamiast menu radialnego (wymaga klienta) zwraca kolejne wybory z listy
/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/multitool_test
	var/list/test_choices = list()

/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/multitool_test/aq_pick_missile_option(mob/living/user, obj/item/I)
	if(!length(test_choices))
		return null
	. = test_choices[1]
	test_choices.Cut(1, 2)

/datum/unit_test/missile_design/Run()
	var/datum/missile_design/D = new
	D.engine = "sprint"
	D.seeker = "brak"
	TEST_ASSERT(abs(D.mult("speed") - 0.6 * 0.9) < 0.001, "Speed modifiers of the design don't multiply")
	TEST_ASSERT(D.mult("integrity") == 1, "A design without a body option changes integrity")
	TEST_ASSERT(D.mult("turn") == 0, "An unguided design can still turn")
	qdel(D)

	// Multitool na obudowie: silnik i naprowadzanie z menu radialnego
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/multitool/tool = allocate(/obj/item/multitool)
	user.put_in_hands(tool)
	var/obj/item/ship_weapon/ammunition/torpedo/torpedo_casing/multitool_test/test_casing = new(run_loc_floor_bottom_left)
	casing = test_casing

	// Bez dostępu do zbrojowni (jak dawny stół projektowy) multitool niczego nie zmienia
	test_casing.test_choices = list(list("seeker", "brak"))
	tool.melee_attack_chain(user, casing)
	TEST_ASSERT(!casing.GetComponent(/datum/component/missile_design), "A multitool retuned a torpedo without munitions access")
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.access = list(ACCESS_MUNITIONS)
	user.put_in_inactive_hand(card) // get_idcard sprawdza ręce, a slot ID bez munduru odrzuca kartę
	TEST_ASSERT(casing.aq_can_tune_missile(user), "A munitions ID does not allow retuning a torpedo")

	// Wybór z menu sprawdza się jeszcze raz po jego zamknięciu: bez multitoola w ręce nic się nie zmienia
	user.dropItemToGround(tool)
	TEST_ASSERT(!casing.aq_apply_missile_choice(user, tool, list("seeker", "brak")), "A menu choice applied after the multitool left the hand")
	user.put_in_hands(tool)
	TEST_ASSERT(!casing.aq_apply_missile_choice(user, tool, null), "A closed menu changed the torpedo")
	TEST_ASSERT(!casing.GetComponent(/datum/component/missile_design), "A refused menu choice still left a design")

	test_casing.test_choices = list(list("engine", "sprint"), list("seeker", "brak"))
	tool.melee_attack_chain(user, casing)
	var/datum/component/missile_design/CMD = casing.GetComponent(/datum/component/missile_design)
	TEST_ASSERT(CMD && CMD.design.engine == "sprint", "A multitool didn't set the engine of the torpedo casing")
	tool.melee_attack_chain(user, casing)
	CMD = casing.GetComponent(/datum/component/missile_design)
	TEST_ASSERT(CMD && CMD.design.engine == "sprint" && CMD.design.seeker == "brak", "A multitool didn't set the guidance of the torpedo casing")
	TEST_ASSERT(!casing.aq_set_missile_option("seeker", "laser"), "A torpedo accepted an unknown guidance option")

	// Składanie: ustawienie przechodzi z obudowy na gotową torpedę
	warhead = new(casing)
	built = new /obj/item/ship_weapon/ammunition/torpedo(run_loc_floor_bottom_left)
	transfer_forged_munition(warhead, built)
	var/datum/component/missile_design/MD = built.GetComponent(/datum/component/missile_design)
	TEST_ASSERT(MD && MD.design.engine == "sprint" && MD.design.seeker == "brak", "The setting didn't pass from the casing to the finished torpedo")

	// Ustawienie fabryczne nie daje projektu
	plain_casing = new(run_loc_floor_bottom_left)
	plain_casing.aq_set_missile_option("engine", "marszowy")
	plain_casing.aq_set_missile_option("engine", "standardowy")
	TEST_ASSERT(!plain_casing.GetComponent(/datum/component/missile_design), "Going back to the standard engine kept a design on the casing")
	plain_warhead = new(plain_casing)
	plain_built = new /obj/item/ship_weapon/ammunition/torpedo(run_loc_floor_bottom_left)
	transfer_forged_munition(plain_warhead, plain_built)
	TEST_ASSERT(!plain_built.GetComponent(/datum/component/missile_design), "A standard casing gave the torpedo a design")

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
