// AQUILA - układy FTL w konsoli nawigacji mapy hex (aquila/code/modules/overmap/hexmap/hex_ftl_chip.dm): bonusy skoku,
// zgodność kosztu trasy i zasięgu w oknie, wkładanie i wymiana układu, nadwyżka ładunku, źródła układów
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Ustawia okrętowi układ danego poziomu z bonusem bez konsoli (null = bez układu)
/proc/hexmap_test_set_chip(obj/structure/overmap/ship, obj/item/ftl_slipstream_chip/chip, bonus)
	if(chip)
		chip.hex_bonus = bonus
	ship.hex_chip = chip

/// Bonusy zmieniają koszt kafla i bramy, rozruch, stygnięcie i pojemność napędu; trasa w oknie i zasięg liczą to samo
/datum/unit_test/hexmap_ftl_chip_bonuses

/datum/unit_test/hexmap_ftl_chip_bonuses/Run()
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	if(!ship || !GLOB.hexmap?.built)
		return
	var/obj/item/ftl_slipstream_chip/saved_chip = ship.hex_chip
	var/obj/item/ftl_slipstream_chip/slipstream = allocate(/obj/item/ftl_slipstream_chip)
	var/obj/item/ftl_slipstream_chip/warp/warp = allocate(/obj/item/ftl_slipstream_chip/warp)
	var/list/saved_terrain = hexmap_test_clear_terrain()
	var/fail = check_bonuses(ship, slipstream, warp)
	hexmap_test_restore_terrain(saved_terrain)
	ship.hex_chip = saved_chip
	if(fail)
		return Fail(fail)

/datum/unit_test/hexmap_ftl_chip_bonuses/proc/close(a, b)
	return abs(a - b) < 0.01

/datum/unit_test/hexmap_ftl_chip_bonuses/proc/check_bonuses(obj/structure/overmap/ship, obj/item/ftl_slipstream_chip/slipstream, obj/item/ftl_slipstream_chip/warp)
	hexmap_test_set_chip(ship, null)
	if(!close(ship.hex_cost(0, 1), HEX_FTL_COST_HEX) || !close(ship.hex_cost(1, 0), HEX_FTL_COST_GATE) || ship.hex_capacity() != HEX_FTL_FULL_CHARGE)
		return "Without a chip a jump costs [ship.hex_cost(0, 1)]% per hex and [ship.hex_cost(1, 0)]% per gate with a [ship.hex_capacity()]% drive"
	if(ship.hex_startup_delay() != HEX_FTL_STARTUP || ship.hex_cooldown_time() != HEX_FTL_COOLDOWN)
		return "Without a chip the startup is [ship.hex_startup_delay()] and the cooldown [ship.hex_cooldown_time()]"

	hexmap_test_set_chip(ship, slipstream, HEX_CHIP_CHEAP)
	if(!close(ship.hex_cost(0, 1), 25) || !close(ship.hex_cost(1, 0), 50))
		return "A cheaper jump (tier 2) costs [ship.hex_cost(0, 1)]% per hex and [ship.hex_cost(1, 0)]% per gate"
	hexmap_test_set_chip(ship, warp, HEX_CHIP_CHEAP)
	if(!close(ship.hex_cost(0, 1), 20) || !close(ship.hex_cost(1, 0), 40))
		return "A cheaper jump (tier 3) costs [ship.hex_cost(0, 1)]% per hex and [ship.hex_cost(1, 0)]% per gate"

	hexmap_test_set_chip(ship, slipstream, HEX_CHIP_DOUBLE)
	if(!close(ship.hex_cost(0, 2), HEX_FTL_COST_HEX) || !close(ship.hex_cost(0, 4), HEX_FTL_COST_HEX * 3) || !close(ship.hex_cost(1, 2), HEX_FTL_COST_GATE + HEX_FTL_COST_HEX))
		return "Two hexes for one (tier 2): 2 hexes [ship.hex_cost(0, 2)]%, 4 hexes [ship.hex_cost(0, 4)]%, gate and 2 hexes [ship.hex_cost(1, 2)]%"
	hexmap_test_set_chip(ship, warp, HEX_CHIP_DOUBLE)
	if(!close(ship.hex_cost(0, 1), HEX_FTL_COST_HEX) || !close(ship.hex_cost(0, 2), HEX_FTL_COST_HEX) || !close(ship.hex_cost(0, 6), HEX_FTL_FULL_CHARGE))
		return "Two hexes for one (tier 3): 1 hex [ship.hex_cost(0, 1)]%, 2 hexes [ship.hex_cost(0, 2)]%, 6 hexes [ship.hex_cost(0, 6)]%"

	hexmap_test_set_chip(ship, slipstream, HEX_CHIP_QUICK)
	if(ship.hex_startup_delay() != 5 SECONDS || ship.hex_cooldown_time() != 30 SECONDS)
		return "A quicker drive (tier 2): startup [ship.hex_startup_delay()], cooldown [ship.hex_cooldown_time()]"
	hexmap_test_set_chip(ship, warp, HEX_CHIP_QUICK)
	if(ship.hex_startup_delay() != 2 SECONDS || ship.hex_cooldown_time() != 15 SECONDS)
		return "A quicker drive (tier 3): startup [ship.hex_startup_delay()], cooldown [ship.hex_cooldown_time()]"
	if(!close(ship.hex_cost(0, 1), HEX_FTL_COST_HEX))
		return "The quick bonus changed the jump cost"

	hexmap_test_set_chip(ship, slipstream, HEX_CHIP_RANGE)
	if(ship.hex_capacity() != 150)
		return "A longer range (tier 2) holds [ship.hex_capacity()]%"
	hexmap_test_set_chip(ship, warp, HEX_CHIP_RANGE)
	if(ship.hex_capacity() != 200)
		return "A longer range (tier 3) holds [ship.hex_capacity()]%"

	// Ile kafli w linii prostej sięga pełny napęd, i czy koszt trasy (podgląd w oknie, skok) zgadza się z zasięgiem
	var/datum/hex/start
	for(var/id in GLOB.hexmap.hexes)
		var/datum/hex/H = GLOB.hexmap.hexes[id]
		var/far = 0
		for(var/datum/hex/other as anything in GLOB.hexmap.hexes_in_range(H, 7))
			far = max(far, GLOB.hexmap.distance(H, other))
		if(far >= 7)
			start = H
			break
	if(!start)
		return "No hex with room for a seven hex jump"
	var/list/expected = list(
		list(null, null, 3),
		list(slipstream, HEX_CHIP_CHEAP, 4),
		list(warp, HEX_CHIP_CHEAP, 5),
		list(slipstream, HEX_CHIP_DOUBLE, 4),
		list(warp, HEX_CHIP_DOUBLE, 6),
		list(slipstream, HEX_CHIP_RANGE, 4),
		list(warp, HEX_CHIP_RANGE, 6),
	)
	for(var/list/entry as anything in expected)
		hexmap_test_set_chip(ship, entry[1], entry[2])
		var/label = entry[1] ? "[entry[2]] tier [ship.hex_chip.tier]" : "no chip"
		var/list/reach = GLOB.hexmap.reachable(start, null, ship.hex_capacity(), ship)
		var/longest = 0
		for(var/datum/hex/H as anything in reach)
			if(H.sector == start.sector) // distance() liczy tylko w jednym sektorze
				longest = max(longest, GLOB.hexmap.distance(start, H))
			var/list/route = GLOB.hexmap.route(start, H, null)
			if(!route || !close(ship.hex_route_cost(route), reach[H]))
				return "[label]: the route to [H.id] costs [route ? ship.hex_route_cost(route) : "nothing"]%, the jump range shows [reach[H]]%"
			if(ship.hex_route_cost(route) > ship.hex_capacity() + 0.01)
				return "[label]: [H.id] is in range but costs [ship.hex_route_cost(route)]% of a [ship.hex_capacity()]% drive"
		if(longest != entry[3])
			return "[label]: a full drive reaches [longest] hexes, expected [entry[3]]"
	hexmap_test_set_chip(ship, null)

/// Układ wkłada się do konsoli nawigacji, słabszy wypada przy lepszym, bonus da się przełączyć (nie w rozruchu),
/// a zniszczona konsola wyrzuca układ. Bonus zasięgu ładuje napęd ponad pełny, inny bonus przycina nadwyżkę.
/datum/unit_test/hexmap_ftl_chip_console

/datum/unit_test/hexmap_ftl_chip_console/Run()
	var/turf/inside = SSmapping.get_station_center()
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	if(!inside || !ship?.ftl_drive || !GLOB.hexmap?.built)
		return
	var/obj/machinery/computer/ship/navigation/nav = allocate(/obj/machinery/computer/ship/navigation, inside)
	if(!nav.has_overmap() || nav.linked != ship)
		return // The test turf is not inside the main ship
	var/obj/machinery/computer/ship/ftl_core/drive = ship.ftl_drive
	var/obj/item/ftl_slipstream_chip/saved_chip = ship.hex_chip
	var/saved_progress = drive.progress
	var/saved_state = drive.ftl_state
	var/saved_active = drive.active
	var/saved_icon = drive.icon_state
	var/saved_cooldown = ship.hex_cooldown_until
	var/was_processing = drive.datum_flags & DF_ISPROCESSING
	var/list/info = SSstar_system.ships[ship]
	var/saved_target = info?["target_system"]
	if(info)
		info["target_system"] = null
	ship.hex_chip = null
	var/fail = check_console(ship, nav, drive, inside)
	if(info)
		info["target_system"] = saved_target
	ship.hex_chip = saved_chip
	drive.progress = saved_progress
	drive.ftl_state = saved_state
	drive.active = saved_active
	drive.icon_state = saved_icon
	ship.hex_cooldown_until = saved_cooldown
	ship.hex_pending_cost = 0
	ship.hex_pending_hexes = 0
	if(was_processing)
		START_PROCESSING(SSmachines, drive)
	else
		STOP_PROCESSING(SSmachines, drive)
	if(fail)
		return Fail(fail)

/datum/unit_test/hexmap_ftl_chip_console/proc/check_console(obj/structure/overmap/ship, obj/machinery/computer/ship/navigation/nav, obj/machinery/computer/ship/ftl_core/drive, turf/inside)
	var/thirring = istype(drive, /obj/machinery/computer/ship/ftl_core)
	var/obj/machinery/computer/ship/ftl_computer/legacy = drive
	var/full = thirring ? drive.req_charge : legacy.spoolup_time
	drive.active = TRUE
	drive.ftl_state = FTL_STATE_READY
	drive.progress = full
	ship.hex_cooldown_until = 0

	var/obj/item/ftl_slipstream_chip/slipstream = allocate(/obj/item/ftl_slipstream_chip, inside)
	if(!nav.hex_install_chip(slipstream, null))
		return "The navigation console did not take a slipstream chip"
	if(slipstream.loc != nav || ship.hex_chip != slipstream)
		return "The installed chip is not in the console (in [slipstream.loc]) or not used by the ship ([ship.hex_chip])"
	var/obj/item/ftl_slipstream_chip/second = allocate(/obj/item/ftl_slipstream_chip, inside)
	if(nav.hex_install_chip(second, null) || second.loc == nav)
		return "A second chip of the same tier replaced the installed one"
	var/list/data = nav.hex_build_ui_data()
	if(data["chip"]?["tier"] != 2 || length(data["chip"]?["bonuses"]) != 4)
		return "The console window does not show the installed chip and its four bonuses"
	if(!nav.hex_set_chip_bonus(HEX_CHIP_RANGE, null) || slipstream.hex_bonus != HEX_CHIP_RANGE)
		return "The bonus could not be switched to a longer range"
	data = nav.hex_build_ui_data()
	if(data["ship"]["capacity"] != 150)
		return "The console window shows a [data["ship"]["capacity"]]% drive with the longer range"

	// Pełny napęd z bonusem zasięgu ładuje się dalej
	drive.progress = full
	drive.ftl_state = FTL_STATE_READY
	if(!thirring && legacy.is_operational) // rdzeń Thirringa ładuje się z pylonów, tu sprawdzamy tylko przycięcie nadwyżki niżej
		legacy.process()
		if(legacy.progress <= full || legacy.ftl_state != FTL_STATE_READY)
			return "A full Seegson drive with the longer range did not keep charging ([legacy.progress] of [full], state [legacy.ftl_state])"
	drive.progress = full * 1.2
	if(abs(ship.hex_charge() - 120) > 0.5)
		return "An overcharged drive shows [ship.hex_charge()]%"

	// Lepszy układ wypiera słabszy i przejmuje jego bonus; w rozruchu bonusu nie da się przełączyć
	var/obj/item/ftl_slipstream_chip/warp/warp = allocate(/obj/item/ftl_slipstream_chip/warp, inside)
	if(!nav.hex_install_chip(warp, null))
		return "The navigation console did not take a warp chip over a slipstream chip"
	if(slipstream.loc == nav || ship.hex_chip != warp || warp.hex_bonus != HEX_CHIP_RANGE)
		return "The warp chip did not replace the slipstream chip (old chip in [slipstream.loc], ship chip [ship.hex_chip], bonus [warp.hex_bonus])"
	if(ship.hex_capacity() != 200)
		return "The warp chip with the longer range holds [ship.hex_capacity()]%"
	if(abs(ship.hex_charge() - 120) > 0.5)
		return "Upgrading the chip lost the overcharge ([ship.hex_charge()]% instead of 120%)"
	drive.ftl_state = FTL_STATE_JUMPING
	if(nav.hex_set_chip_bonus(HEX_CHIP_QUICK, null))
		return "The bonus was switched during the jump startup"
	drive.ftl_state = FTL_STATE_READY
	if(!nav.hex_set_chip_bonus(HEX_CHIP_QUICK, null))
		return "The bonus could not be switched to a quicker drive"
	if(abs(ship.hex_charge() - 100) > 0.01 || drive.progress > full + 0.01)
		return "Leaving the longer range kept the overcharge ([ship.hex_charge()]%, progress [drive.progress] of [full])"

	// Skok z bonusem stygnięcia: krótszy cooldown
	drive.ftl_state = FTL_STATE_JUMPING
	ship.hex_set_pending(ship.hex_cost(0, 1), 1)
	if(!ship.hex_on_departure(FALSE))
		return "A hex jump with a chip was not handled on departure"
	if(ship.hex_cooldown_until - world.time != 15 SECONDS)
		return "The warp quick bonus left a cooldown of [(ship.hex_cooldown_until - world.time) / 10] s"
	ship.hex_cooldown_until = 0

	// Zniszczona konsola wyrzuca układ, okręt traci bonus
	qdel(nav)
	if(warp.loc != inside || ship.hex_chip)
		return "The destroyed console did not drop the chip (in [warp.loc], ship chip [ship.hex_chip])"
	if(ship.hex_startup_delay() != HEX_FTL_STARTUP)
		return "The ship kept the bonus after losing its chip"

/// Źródła układów: tunel na mapie hex ma anomalię do skanu sondą (punkty tuneli do badania matrycy strumienia),
/// Minsky sprzedaje układ warp, a badanie napędu warp idzie po matrycy strumienia
/datum/unit_test/hexmap_ftl_chip_sources

/datum/unit_test/hexmap_ftl_chip_sources/Run()
	if(GLOB.hexmap?.built)
		var/datum/hex/empty
		for(var/id in GLOB.hexmap.hexes)
			var/datum/hex/H = GLOB.hexmap.hexes[id]
			if(!H.system && H.terrain == HEX_TERRAIN_EMPTY)
				empty = H
				break
		TEST_ASSERT(empty, "No empty hex on the map")
		empty.terrain = HEX_TERRAIN_WORMHOLE
		var/datum/star_system/random/hex_empty/S = GLOB.hexmap.system_for(empty)
		var/obj/effect/overmap_anomaly/wormhole/found
		for(var/obj/effect/overmap_anomaly/wormhole/W in S.system_contents)
			found = W
		var/research_type = found?.specialist_research_type
		var/points = found?.research_points
		if(found)
			S.system_contents -= found
			S.contents_positions -= found
			qdel(found)
		empty.terrain = HEX_TERRAIN_EMPTY
		S.try_release()
		TEST_ASSERT(found, "A wormhole hex has no wormhole anomaly to probe")
		TEST_ASSERT_EQUAL(research_type, TECHWEB_POINT_TYPE_WORMHOLE, "The wormhole anomaly gives no wormhole research points")
		var/datum/techweb_node/slipstream_node = SSresearch.techweb_nodes["ftl_slipstream"]
		var/needed = slipstream_node ? slipstream_node.research_costs[TECHWEB_POINT_TYPE_WORMHOLE] : INFINITY
		TEST_ASSERT(points >= needed, "One wormhole probe ([points]) does not pay for the slipstream research ([needed])")

	var/datum/trader/minsky/trader = new
	var/sells_warp = (/datum/trader_item/aquila_warp_chip in trader.sold_items)
	qdel(trader)
	TEST_ASSERT(sells_warp, "Minsky Heavy Engineering does not sell the warp chip")
	var/datum/trader_item/aquila_warp_chip/item = new
	var/unlock = item.unlock_path
	qdel(item)
	TEST_ASSERT_EQUAL(unlock, /obj/item/ftl_slipstream_chip/warp, "The warp chip trader item delivers something else")

	var/datum/techweb_node/warp_node = SSresearch.techweb_nodes["ftl_warp"]
	TEST_ASSERT(warp_node, "There is no warp drive research")
	TEST_ASSERT("ftl_slipstream" in warp_node.prereq_ids, "The warp drive research does not come after the slipstream research")
	TEST_ASSERT("ftl_warp_chip" in warp_node.design_ids, "The warp drive research does not unlock the warp chip")
	var/datum/design/design = SSresearch.techweb_designs["ftl_warp_chip"]
	TEST_ASSERT_EQUAL(design?.build_path, /obj/item/ftl_slipstream_chip/warp, "The warp chip design builds something else")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
