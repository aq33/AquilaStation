// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - a skeleton examining the chef's crazy burger gets quality 8, the description list has 7 entries
/datum/unit_test/aquila_audyt_food_quality_examine

/datum/unit_test/aquila_audyt_food_quality_examine/Run()
	var/mob/living/carbon/human/skeleton = allocate(/mob/living/carbon/human)
	skeleton.set_species(/datum/species/skeleton)
	var/obj/item/food/burger/crazy/burger = allocate(/obj/item/food/burger/crazy)
	ADD_TRAIT(burger, TRAIT_FOOD_CHEF_MADE, "aquila_audyt")
	var/datum/component/edible/edible = burger.GetComponent(/datum/component/edible)
	TEST_ASSERT(edible.get_perceived_food_quality(skeleton) > FOOD_QUALITY_TOP, "The test case no longer goes above FOOD_QUALITY_TOP")
	var/list/lines = list()
	try
		edible.examine(burger, skeleton, lines)
	catch(var/exception/error)
		return Fail("Examining food above the top quality caused a runtime: [error]")
	TEST_ASSERT(findtext(jointext(lines, "\n"), GLOB.food_quality_description[FOOD_QUALITY_TOP]), "Examine did not show the top quality description")

/// AQUILA - the holocarp fishsticks from the uplink point at an icon state that exists
/datum/unit_test/aquila_audyt_holocarp_icon

/datum/unit_test/aquila_audyt_holocarp_icon/Run()
	var/obj/item/guardiancreator/carp/carp = /obj/item/guardiancreator/carp
	TEST_ASSERT(icon_exists(initial(carp.icon), initial(carp.icon_state)), "Holocarp fishsticks have no icon state [initial(carp.icon_state)] in [initial(carp.icon)]")

/// AQUILA - a right click with a beaker pours into the plumbed water tank, a normal click still fills the beaker
/datum/unit_test/aquila_audyt_plumbed_tank_refill

/datum/unit_test/aquila_audyt_plumbed_tank_refill/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/obj/structure/reagent_dispensers/plumbed/tank = allocate(/obj/structure/reagent_dispensers/plumbed)
	tank.reagents.remove_any(100)
	var/start_volume = tank.reagents.total_volume
	var/obj/item/reagent_containers/glass/beaker/beaker = allocate(/obj/item/reagent_containers/glass/beaker)
	beaker.reagents.add_reagent(/datum/reagent/water, 30)
	user.put_in_active_hand(beaker)
	var/amount = beaker.amount_per_transfer_from_this

	beaker.melee_attack_chain(user, tank, "right=1")
	TEST_ASSERT_EQUAL(tank.reagents.total_volume, start_volume + amount, "A right click did not pour the beaker into the tank")
	TEST_ASSERT_EQUAL(beaker.reagents.total_volume, 30 - amount, "The beaker did not lose what it poured")

	beaker.melee_attack_chain(user, tank, "")
	TEST_ASSERT_EQUAL(beaker.reagents.total_volume, 30, "A normal click no longer fills the beaker from the tank")

/// AQUILA - composting a pill in a tray neither doubles its reagents (pipes drain the tray) nor runtimes in the pill
/datum/unit_test/aquila_audyt_tray_compost

/datum/unit_test/aquila_audyt_tray_compost/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, get_step(run_loc_floor_bottom_left, EAST))
	var/obj/item/reagent_containers/pill/pill = allocate(/obj/item/reagent_containers/pill)
	pill.reagents.add_reagent(/datum/reagent/medicine/omnizine, 20)
	user.put_in_active_hand(pill)
	try
		pill.melee_attack_chain(user, tray, "")
	catch(var/exception/error)
		return Fail("Composting a pill in a tray caused a runtime: [error]")
	TEST_ASSERT(QDELETED(pill), "The tray did not compost the pill")
	TEST_ASSERT_EQUAL(tray.reagents.total_volume, 20, "Composting changed the amount of reagents")

/// AQUILA - a syringe puts one dose into a tray, not two
/datum/unit_test/aquila_audyt_tray_syringe

/datum/unit_test/aquila_audyt_tray_syringe/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, get_step(run_loc_floor_bottom_left, EAST))
	var/obj/item/reagent_containers/syringe/syringe = allocate(/obj/item/reagent_containers/syringe)
	syringe.reagents.add_reagent(/datum/reagent/water, 15)
	user.put_in_active_hand(syringe)
	var/amount = syringe.amount_per_transfer_from_this
	syringe.melee_attack_chain(user, tray, "")
	TEST_ASSERT_EQUAL(tray.reagents.total_volume, amount, "The tray got the wrong dose from the syringe")
	TEST_ASSERT_EQUAL(syringe.reagents.total_volume, 15 - amount, "The syringe lost the wrong amount")

/// AQUILA - the plant analyser only removes what is saved on its disk, never a datum picked by a ref from the client
/datum/unit_test/aquila_audyt_analyser_remove_ref

/datum/unit_test/aquila_audyt_analyser_remove_ref/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	usr = user
	var/obj/machinery/plant_machine/plant_analyser/analyser = allocate(/obj/machinery/plant_machine/plant_analyser)
	var/obj/item/bikehorn/victim = allocate(/obj/item/bikehorn)
	analyser.ui_act("remove_feature", list("key" = REF(victim)))
	TEST_ASSERT(!QDELETED(victim), "remove_feature deleted an object that was not on the disk")
	analyser.ui_act("remove_trait", list("key" = REF(victim)))
	TEST_ASSERT(!QDELETED(victim), "remove_trait deleted an object that was not on the disk")

	var/obj/item/disk/plant_disk/disk = allocate(/obj/item/disk/plant_disk)
	var/datum/plant_feature/feature = new /datum/plant_feature/fruit/lemon(null)
	disk.set_saved(feature)
	disk.forceMove(analyser)
	analyser.disk = disk
	analyser.ui_act("remove_feature", list("key" = REF(victim)))
	TEST_ASSERT(QDELETED(feature), "remove_feature did not delete the feature saved on the disk")
	TEST_ASSERT(!disk.saved, "The disk still points at the removed feature")
	TEST_ASSERT(!QDELETED(victim), "remove_feature deleted the object from the ref as well")

/// AQUILA - lime and ambrosia plants give the item types that juicers, recipes and bounties ask for
/datum/unit_test/aquila_audyt_fruit_products

/datum/unit_test/aquila_audyt_fruit_products/Run()
	var/datum/plant_feature/fruit/lime = /datum/plant_feature/fruit/lemon/lime
	var/obj/item/food/grown/lime_product = initial(lime.fruit_product)
	TEST_ASSERT(ispath(lime_product, /obj/item/food/grown/citrus/lime), "The lime plant gives [lime_product]")
	TEST_ASSERT(initial(lime_product.abstract_type) != lime_product, "The lime plant gives an abstract type")
	TEST_ASSERT_EQUAL(initial(lime_product.juice_typepath), /datum/reagent/consumable/limejuice, "Limes from the plant do not juice into lime juice")
	var/datum/plant_feature/fruit/ambrosia = /datum/plant_feature/fruit/ambrosia
	TEST_ASSERT(ispath(initial(ambrosia.fruit_product), /obj/item/food/grown/ambrosia/vulgaris), "The ambrosia vulgaris plant gives [initial(ambrosia.fruit_product)]")

/// AQUILA - a right click with seeds outside combat mode plants once, not twice
/datum/unit_test/aquila_audyt_seeds_right_click

/datum/unit_test/aquila_audyt_seeds_right_click/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human)
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, get_step(run_loc_floor_bottom_left, NORTH))
	var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
	planter.set_substrate(/datum/plant_subtrate/dirt)
	planter.plant_slots = PLANT_BODY_SLOT_SIZE_LARGEST * 4 // room for two tomatoes, like two small plants in a normal tray
	var/obj/item/plant_seeds/seeds = allocate(/obj/item/plant_seeds/preset/tomato)
	seeds.seeds = 2
	user.put_in_active_hand(seeds)
	TEST_ASSERT(!user.combat_mode, "The test user starts in combat mode")
	seeds.melee_attack_chain(user, tray, "right=1")
	TEST_ASSERT_EQUAL(length(planter.plants), 1, "One right click planted the wrong number of plants")
	TEST_ASSERT_EQUAL(seeds.seeds, 1, "One right click used the wrong number of seeds")

/// AQUILA - the Yamato terminal drops a deleted machine from its menu and relinking does not register signals twice
/datum/unit_test/aquila_audyt_plant_computer_unlink

/datum/unit_test/aquila_audyt_plant_computer_unlink/Run()
	var/turf/origin = get_step(run_loc_floor_bottom_left, NORTHEAST)
	var/obj/machinery/plant_machine/plant_analyser/machine = allocate(/obj/machinery/plant_machine/plant_analyser, origin)
	var/obj/machinery/computer/plant_machine_controller/computer = allocate(/obj/machinery/computer/plant_machine_controller, get_step(origin, EAST))
	computer.locate_machines()
	TEST_ASSERT(machine in computer.machines, "The terminal did not link the analyser")
	TEST_ASSERT_EQUAL(machine.controller, computer, "The analyser does not know its terminal")
	var/machine_key = "[machine]"
	qdel(machine)
	TEST_ASSERT(!(machine in computer.machines), "The terminal kept the deleted analyser")
	TEST_ASSERT(!computer.machine_options[machine_key], "The terminal menu still shows the deleted analyser")
	for(var/key in computer.option_links)
		TEST_ASSERT(computer.option_links[key] != machine, "The terminal menu still links the deleted analyser")

	var/obj/machinery/plant_machine/plant_analyser/second = allocate(/obj/machinery/plant_machine/plant_analyser, origin)
	computer.locate_machines()
	TEST_ASSERT_EQUAL(second.controller, computer, "Relinking did not link the new analyser")
	qdel(computer)
	TEST_ASSERT(isnull(second.controller), "The analyser kept a deleted terminal")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
