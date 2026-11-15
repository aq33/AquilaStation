// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - zlecenia działów ze stacji handlowych: dostawa liczy sztuki i ładunek, nagroda trafia do działu,
/// zwłoki rozlicza ożywienie albo autopsja, a zlecenie gości otwiera lokal i zamyka go po wykonaniu
/datum/unit_test/station_contracts

/datum/unit_test/station_contracts/Run()
	// Dostawa materiałów: liczą się sztuki w stosach, za mało to za mało
	var/datum/aq_contract/delivery/materials/materials = new(null)
	materials.item_type = /obj/item/stack/sheet/iron
	materials.amount = 50
	var/obj/item/stack/sheet/iron/small = allocate(/obj/item/stack/sheet/iron, run_loc_floor_bottom_left, 20)
	TEST_ASSERT(!materials.check_shipment(list(small)), "20 iron sheets counted as a delivery of 50")
	var/obj/item/stack/sheet/iron/big = allocate(/obj/item/stack/sheet/iron, run_loc_floor_top_right, 30) // inne pole, żeby stosy się nie połączyły
	TEST_ASSERT(materials.check_shipment(list(small, big)), "50 iron sheets in two stacks didn't count as a delivery of 50")

	// Energia: liczy się ładunek ogniw, nie ich liczba
	var/datum/aq_contract/delivery/energy/energy = new(null)
	energy.amount = 20000
	var/obj/item/stock_parts/cell/cell = allocate(/obj/item/stock_parts/cell, run_loc_floor_bottom_left)
	cell.charge = 10000
	TEST_ASSERT(!energy.check_shipment(list(cell)), "A cell with half the charge completed the energy contract")
	cell.charge = 20000
	TEST_ASSERT(energy.check_shipment(list(cell)), "A cell with enough charge didn't complete the energy contract")

	// Nagroda: budżet działu
	var/datum/bank_account/cargo = SSeconomy.get_dep_account(ACCOUNT_CAR)
	var/old_balance = cargo.account_balance
	materials.accept()
	TEST_ASSERT(materials in GLOB.aq_ship_contracts, "An accepted contract isn't on the ship's list")
	materials.complete()
	TEST_ASSERT(materials.is_done(), "A completed contract isn't marked as done")
	TEST_ASSERT(cargo.account_balance >= old_balance + materials.reward, "The department budget didn't get the reward")
	cargo.adjust_money(-materials.reward)
	GLOB.department_commission_pending[ACCOUNT_CAR] -= materials.reward
	qdel(materials)
	qdel(energy)

	// Zwłoki: autopsja wystarcza
	var/datum/aq_contract/corpse/corpse = new(null)
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	body.death()
	corpse.body = WEAKREF(body)
	corpse.state = "w toku"
	corpse.deadline = world.time + 10 MINUTES
	corpse.check_progress()
	TEST_ASSERT(corpse.is_active(), "A dead, unexamined body completed the corpse contract")
	ADD_TRAIT(body, "autopsied", "test")
	corpse.check_progress()
	TEST_ASSERT(corpse.is_done(), "An autopsy didn't complete the corpse contract")
	refund_contract(corpse)
	qdel(corpse)

	// Regresja: śmierć drugiego pacjenta kończy zlecenie, choć pierwszy jest jeszcze w leczeniu
	var/datum/aq_contract/wounded/wounded = new(null)
	var/mob/living/carbon/human/hurt = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/dead = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	hurt.adjustBruteLoss(50)
	dead.death()
	wounded.patients = list(WEAKREF(hurt), WEAKREF(dead))
	wounded.state = "w toku"
	wounded.deadline = world.time + 10 MINUTES
	wounded.check_progress()
	TEST_ASSERT(wounded.is_failed(), "The wounded contract kept running after the second patient died")
	qdel(wounded)

	// Regresja: pole w ambulatorium tylko z obszarów głównego okrętu
	var/datum/aq_contract/corpse/finder = new(null)
	var/turf/drop = finder.find_medbay_turf()
	if(drop)
		var/area/drop_area = get_area(drop)
		TEST_ASSERT(istype(drop_area, /area/medical) && drop_area.get_overmap() == SSstar_system.find_main_overmap(), "The medical drop turf isn't in the main ship's medbay")
		TEST_ASSERT(!drop.density && !is_blocked_turf(drop, TRUE), "The medical drop turf is blocked")
	qdel(finder)

	// Goście: zlecenie otwiera lokal, a po wykonaniu go zamyka
	var/datum/venue/restaurant/venue = SSrestaurant.get_venue(/datum/venue/restaurant)
	TEST_ASSERT(!venue.open, "The restaurant is open before any customer contract")
	allocate(/obj/machinery/restaurant_portal/restaurant, run_loc_floor_bottom_left)
	var/datum/aq_contract/customers/customers = new(null)
	customers.venue_path = /datum/venue/restaurant
	customers.amount = 2
	TEST_ASSERT(isnull(customers.accept_error()), "A customer contract can't be accepted with a portal on board")
	customers.accept()
	TEST_ASSERT(venue.open, "Accepting a customer contract didn't open the restaurant")
	var/datum/aq_contract/customers/second = new(null)
	second.venue_path = /datum/venue/restaurant
	TEST_ASSERT(second.accept_error(), "A second customer contract for the same restaurant was accepted")
	qdel(second)
	venue.customers_served += 2
	customers.check_progress()
	TEST_ASSERT(customers.is_done(), "Serving enough customers didn't complete the contract")
	refund_contract(customers)
	TEST_ASSERT(!venue.open, "The restaurant stayed open after the contract was done")
	venue.customers_served -= 2
	qdel(customers)

/// Cofa nagrodę i premię wykonanego zlecenia, żeby kolejne testy widziały niezmienione budżety
/datum/unit_test/station_contracts/proc/refund_contract(datum/aq_contract/contract)
	var/datum/bank_account/account = SSeconomy.get_dep_account(contract.account)
	account?.adjust_money(-contract.reward)
	GLOB.department_commission_pending[contract.account] -= contract.reward

#undef TEST_ASSERT
