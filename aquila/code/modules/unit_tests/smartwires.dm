// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - Smartwires (port BeeStation/BeeStation-Hornet#14275): cables link up with neighbours of their colour, nodes sit on cable ends, cuts split the powernet
/datum/unit_test/smartwires

/datum/unit_test/smartwires/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/east_1 = locate(start.x + 1, start.y, start.z)
	var/turf/east_2 = locate(start.x + 2, start.y, start.z)
	var/turf/north = locate(start.x, start.y + 1, start.z)
	var/turf/north_east = locate(start.x + 1, start.y + 1, start.z)

	// A straight red line: one powernet, nodes only on the ends
	var/obj/structure/cable/left = allocate(/obj/structure/cable, start)
	var/obj/structure/cable/middle = allocate(/obj/structure/cable, east_1)
	var/obj/structure/cable/right = allocate(/obj/structure/cable, east_2)
	TEST_ASSERT(left.powernet, "A cable laid at runtime did not get a powernet")
	TEST_ASSERT_EQUAL(left.powernet, middle.powernet, "Adjacent red cables are not in one powernet")
	TEST_ASSERT_EQUAL(middle.powernet, right.powernet, "Adjacent red cables are not in one powernet")
	TEST_ASSERT_EQUAL(middle.linked_dirs, EAST|WEST, "The middle cable did not link both ways")
	TEST_ASSERT(left.has_power_node, "The west end of the line has no power node")
	TEST_ASSERT(right.has_power_node, "The east end of the line has no power node")
	TEST_ASSERT(!middle.has_power_node, "A cable running through a tile got a power node")

	// Another colour next to it stays separate
	var/obj/structure/cable/yellow/other = allocate(/obj/structure/cable/yellow, north)
	TEST_ASSERT(other.powernet != left.powernet, "A yellow cable joined the red powernet")
	TEST_ASSERT_EQUAL(other.linked_dirs, NONE, "A yellow cable linked to a red one")

	// An omni cable joins both colours
	var/obj/structure/cable/omni/bridge = allocate(/obj/structure/cable/omni, north_east)
	TEST_ASSERT_EQUAL(bridge.powernet, middle.powernet, "The omni cable did not join the red cable under it")
	TEST_ASSERT_EQUAL(bridge.powernet, other.powernet, "The omni cable did not join the yellow cable next to it")
	qdel(bridge)

	// Forcing a node keeps it on a cable that runs through
	middle.add_power_node()
	TEST_ASSERT(middle.has_power_node, "add_power_node() did not give the cable a node")
	TEST_ASSERT(start.get_cable_node() == left, "get_cable_node() did not return the node cable")

	// Cutting the middle splits the line once the powernet is recalculated
	qdel(middle)
	var/datum/powernet/net = left.powernet
	TEST_ASSERT(net.dirty, "Cutting a cable did not queue the powernet for recalculation")
	SSmachines.dirty_powernets -= net
	net.dirty = FALSE
	net.repropogate_cables()
	TEST_ASSERT(left.powernet != right.powernet, "Cutting the middle cable did not split the powernet")
	TEST_ASSERT(right.has_power_node, "The east cable lost its node")

/// AQUILA - a cut that splits off the first cable of the powernet must not move the rest of the grid to a new, unpowered powernet
/datum/unit_test/smartwires_split_keeps_main_grid

/datum/unit_test/smartwires_split_keeps_main_grid/Run()
	var/turf/start = run_loc_floor_bottom_left
	// Laid first, so it is cables[1] of the powernet
	var/obj/structure/cable/stub = allocate(/obj/structure/cable, start)
	var/obj/structure/cable/cut = allocate(/obj/structure/cable, locate(start.x + 1, start.y, start.z))
	var/obj/structure/cable/main_1 = allocate(/obj/structure/cable, locate(start.x + 2, start.y, start.z))
	var/obj/structure/cable/main_2 = allocate(/obj/structure/cable, locate(start.x + 3, start.y, start.z))
	var/datum/powernet/net = stub.powernet
	TEST_ASSERT_EQUAL(main_2.powernet, net, "The test line is not one powernet")
	TEST_ASSERT_EQUAL(net.cables[1], stub, "The stub is not the first cable of the powernet")
	net.avail = 5000
	net.viewavail = 5000

	qdel(cut)
	SSmachines.dirty_powernets -= net
	net.dirty = FALSE
	net.repropogate_cables()

	TEST_ASSERT(stub.powernet != main_1.powernet, "Cutting the cable did not split the powernet")
	TEST_ASSERT_EQUAL(main_1.powernet, net, "The larger part of the grid was moved to a new powernet")
	TEST_ASSERT_EQUAL(main_2.powernet, net, "The larger part of the grid was moved to a new powernet")
	TEST_ASSERT_EQUAL(net.avail, 5000, "The larger part of the grid lost its available power")
	TEST_ASSERT_EQUAL(net.viewavail, 5000, "The power monitor reading of the grid was reset")

/// AQUILA - joining two powernets keeps the power of the absorbed one for the current tick
/datum/unit_test/smartwires_merge_keeps_power

/datum/unit_test/smartwires_merge_keeps_power/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/obj/structure/cable/left = allocate(/obj/structure/cable, start)
	var/obj/structure/cable/right = allocate(/obj/structure/cable, locate(start.x + 2, start.y, start.z))
	TEST_ASSERT(left.powernet != right.powernet, "Two cables with a gap share a powernet")
	left.powernet.avail = 1000
	left.powernet.newavail = 100
	right.powernet.avail = 3000
	right.powernet.newavail = 300

	allocate(/obj/structure/cable, locate(start.x + 1, start.y, start.z))
	var/datum/powernet/net = left.powernet
	TEST_ASSERT_EQUAL(net, right.powernet, "The cable in the gap did not join the powernets")
	TEST_ASSERT_EQUAL(net.avail, 4000, "The joined powernet lost available power")
	TEST_ASSERT_EQUAL(net.newavail, 400, "The joined powernet lost power produced this tick")

/// AQUILA - cutting a multi-z cable removes it and the cables right above and below, without recursing forever or taking the rest of the stack
/datum/unit_test/smartwires_multiz_deconstruct

/datum/unit_test/smartwires_multiz_deconstruct/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/turf/east = locate(start.x + 2, start.y, start.z)
	// Second row for the three-deck stack
	var/turf/stack_1 = locate(start.x, start.y + 2, start.z)
	var/turf/stack_2 = locate(start.x + 2, start.y + 2, start.z)
	var/turf/stack_3 = locate(start.x + 4, start.y + 2, start.z)
	var/obj/structure/cable/multiz/lower = allocate(/obj/structure/cable/multiz, start)
	var/obj/structure/cable/multiz/upper = allocate(/obj/structure/cable/multiz, east)
	// Stand-in for stacked decks: the test room has one z-level
	lower.set_up(upper)
	TEST_ASSERT_EQUAL(upper.down, lower, "set_up() did not link the cables both ways")

	lower.deconstruct()
	TEST_ASSERT(QDELETED(lower), "The cut multi-z cable was not removed")
	TEST_ASSERT(QDELETED(upper), "The linked multi-z cable was not removed")
	var/dropped = 0
	for (var/obj/item/stack/cable_coil/coil in start)
		dropped += coil.amount
		qdel(coil)
	for (var/obj/item/stack/cable_coil/coil in east)
		dropped += coil.amount
		qdel(coil)
	TEST_ASSERT_EQUAL(dropped, 2, "Cutting two multi-z cables did not drop exactly two pieces of cable")

	// Three decks: cutting the bottom one takes the middle one, the top one stays
	var/obj/structure/cable/multiz/bottom = allocate(/obj/structure/cable/multiz, stack_1)
	var/obj/structure/cable/multiz/middle = allocate(/obj/structure/cable/multiz, stack_2)
	var/obj/structure/cable/multiz/third = allocate(/obj/structure/cable/multiz, stack_3)
	bottom.set_up(middle)
	middle.set_up(third)
	bottom.deconstruct()
	for (var/obj/item/stack/cable_coil/coil in stack_1)
		qdel(coil)
	for (var/obj/item/stack/cable_coil/coil in stack_2)
		qdel(coil)
	TEST_ASSERT(QDELETED(middle), "The multi-z cable above the cut was not removed")
	TEST_ASSERT(!QDELETED(third), "Cutting one multi-z cable removed the whole stack")
	TEST_ASSERT(isnull(third.down), "The top cable still links to the removed one")

/// AQUILA - the powernets queued before a machines tick are recalculated in that tick: a deleted one is skipped
/// without losing the rest, and a powernet that re-queues itself while splitting waits for the next tick
/datum/unit_test/smartwires_dirty_queue

/datum/unit_test/smartwires_dirty_queue/Run()
	var/turf/start = run_loc_floor_bottom_left
	var/obj/structure/cable/left = allocate(/obj/structure/cable, start)
	var/obj/structure/cable/right = allocate(/obj/structure/cable, locate(start.x + 2, start.y, start.z))
	// Two unconnected cables in one powernet: recalculating it splits off one and marks it dirty again
	var/datum/powernet/split = left.powernet
	split.add_cable(right)

	var/list/old_queue = SSmachines.dirty_powernets
	var/list/old_run = SSmachines.dirty_run
	SSmachines.dirty_powernets = list()
	var/datum/powernet/first = new
	var/datum/powernet/deleted = new
	var/datum/powernet/last = new
	SSmachines.dirty_run = list(first, deleted, split, last)
	for (var/datum/powernet/net as anything in SSmachines.dirty_run)
		net.dirty = TRUE
	// Deleted while the run is in progress
	qdel(deleted)

	SSmachines.process_dirty_powernets(TRUE, FALSE)
	var/run_left = length(SSmachines.dirty_run)
	var/first_dirty = first.dirty
	var/last_dirty = last.dirty
	var/split_requeued = (split in SSmachines.dirty_powernets)
	var/was_split = left.powernet != right.powernet

	// The next tick takes the re-queued powernet
	SSmachines.process_dirty_powernets(FALSE, FALSE)
	var/queue_left = length(SSmachines.dirty_powernets) + length(SSmachines.dirty_run)

	SSmachines.dirty_powernets = old_queue
	SSmachines.dirty_run = old_run
	first.dirty = FALSE
	last.dirty = FALSE
	qdel(first)
	qdel(last)
	TEST_ASSERT_EQUAL(run_left, 0, "Queued powernets were left for the next tick")
	TEST_ASSERT(!first_dirty && !last_dirty, "A deleted powernet in the queue made the loop skip another one")
	TEST_ASSERT(was_split, "The queued powernet was not recalculated")
	TEST_ASSERT(split_requeued, "A powernet re-queued during the run was processed in the same run or dropped")
	TEST_ASSERT_EQUAL(queue_left, 0, "The re-queued powernet was not recalculated on the next tick")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
