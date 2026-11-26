// AQUILA - testy eventów z kafli mapy hex, etap E6 (znaleziska, ładunki i goście): pule terenów, skrzynie z surowcami,
// kapsuły z zasobami, tajemniczy prezent, porzucony satelita, stary Vendotron, wędrowny handlarz, przemytnicza paczka
// i gniazdo kryształów bluespace
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Each E6 event is in the pool of its own terrain only and does not roll as a plain ship event.
/// Base of the other E6 tests: they clean up whatever appeared on their turfs and use tools without waiting.
/datum/unit_test/aquila_hex_finds
	/// Pola testu => to, co na nich było przed testem
	var/list/watched_turfs = list()

/datum/unit_test/aquila_hex_finds/proc/watch(turf/T)
	if(T && !watched_turfs[T])
		watched_turfs[T] = T.contents.Copy()
	return T

/datum/unit_test/aquila_hex_finds/Destroy()
	for(var/turf/T as anything in watched_turfs)
		var/list/before = watched_turfs[T]
		for(var/atom/movable/AM as anything in T.contents)
			if(!(AM in before) && !QDELETED(AM))
				qdel(AM)
	watched_turfs.Cut()
	return ..()

/// Człowiek trzymający przedmiot typu tool_type (narzędzia bez czasu użycia)
/datum/unit_test/aquila_hex_finds/proc/hand_tool(mob/living/carbon/human/user, tool_type)
	var/obj/item/tool = allocate(tool_type, get_turf(user))
	tool.toolspeed = 0
	user.put_in_active_hand(tool, forced = TRUE)
	return tool

/datum/unit_test/aquila_hex_finds/Run()
	var/list/event_terrains = list(
		/datum/round_event_control/aquila_hex_resource_drift = HEX_TERRAIN_ASTEROIDS,
		/datum/round_event_control/aquila_hex_resource_pods = HEX_TERRAIN_SIGNAL,
		/datum/round_event_control/aquila_hex_mystery_gift = HEX_TERRAIN_WORMHOLE,
		/datum/round_event_control/aquila_hex_derelict_satellite = HEX_TERRAIN_SIGNAL,
		/datum/round_event_control/aquila_hex_old_vendotron = HEX_TERRAIN_JUNK,
		/datum/round_event_control/aquila_hex_travelling_trader = HEX_TERRAIN_WORMHOLE,
		/datum/round_event_control/aquila_hex_intercepted_contraband = HEX_TERRAIN_MINES,
		/datum/round_event_control/aquila_hex_bluespace_crystal_infestation = HEX_TERRAIN_ASTEROIDS,
	)
	hex_terrain(HEX_TERRAIN_EMPTY)
	for(var/path in event_terrains)
		var/datum/round_event_control/control = hex_event_control(path)
		TEST_ASSERT(control, "No event control of [path]")
		for(var/id in GLOB.hex_terrains)
			var/datum/hex_terrain/terrain = GLOB.hex_terrains[id]
			var/in_pool = (path in terrain.events) || (path in terrain.antags)
			if(id == event_terrains[path])
				TEST_ASSERT((path in terrain.events) && !(path in terrain.antags), "[control.name] is not among the events of [id]")
			else
				TEST_ASSERT(!in_pool, "[control.name] is also in a pool of [id]")
		TEST_ASSERT(hex_tile_environment_events()[path], "[control.name] still rolls as a plain ship event")

/// Drifting crates hold only common materials in sane amounts and carry a GPS; space spots are only space;
/// resource pods carry a crate; the shared room finder gives free safe turfs of one room
/datum/unit_test/aquila_hex_finds/resources

/datum/unit_test/aquila_hex_finds/resources/Run()
	var/turf/floor = watch(run_loc_floor_bottom_left)
	var/static/list/allowed = typecacheof(list(
		/obj/item/stack/sheet/iron,
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/rglass,
		/obj/item/stack/rods,
		/obj/item/stack/sheet/mineral/wood,
		/obj/item/stack/sheet/plastic,
		/obj/item/stack/sheet/cardboard,
		/obj/item/stack/cable_coil,
		/obj/item/stack/sheet/plasteel,
		/obj/item/stack/tile/plasteel,
	))
	var/obj/structure/closet/crate/aquila_resource_cache/probe = allocate(/obj/structure/closet/crate/aquila_resource_cache, floor)
	for(var/set_name in probe.resource_sets())
		var/obj/structure/closet/crate/aquila_resource_cache/cache = allocate(/obj/structure/closet/crate/aquila_resource_cache, floor, set_name)
		TEST_ASSERT_EQUAL(cache.resource_set, set_name, "The crate did not take the asked set")
		TEST_ASSERT(length(cache.contents), "The [set_name] crate is empty")
		for(var/obj/item/stack/stack in cache)
			TEST_ASSERT(is_type_in_typecache(stack, allowed), "The [set_name] crate holds [stack.type]")
			TEST_ASSERT(stack.amount <= 30, "The [set_name] crate holds [stack.amount] [stack.name]")

	var/datum/round_event/aquila_hex_resource_drift/drift = new(FALSE)
	drift.kill()
	var/obj/structure/closet/crate/aquila_resource_cache/drifting = drift.make_cache(floor)
	TEST_ASSERT(drifting.GetComponent(/datum/component/gps), "A drifting crate has no GPS")
	TEST_ASSERT(!length(aquila_hex_free_space_near(floor, 3, 1)), "A ship floor was taken for a space spot")
	qdel(drift)

	var/datum/round_event/aquila_hex_resource_pods/pods = new(FALSE)
	pods.kill()
	for(var/i in 1 to 5)
		var/obj/structure/closet/crate/crate = pods.make_crate()
		allocated += crate
		TEST_ASSERT(istype(crate) && !crate.locked, "A resource pod carries no unlocked crate")
	pods.sender = "syndicate"
	TEST_ASSERT_EQUAL(pods.pod_style(), STYLE_SYNDICATE, "The seized goods do not come in a Syndicate pod")
	qdel(pods)

	var/list/room = aquila_hex_room_turfs(2)
	if(length(room))
		var/turf/first = room[1]
		TEST_ASSERT_EQUAL(length(room), 2, "The room finder gave a wrong number of turfs")
		for(var/turf/T as anything in room)
			TEST_ASSERT(aquila_hex_free_safe_turf(T), "The room finder gave a turf that is not free and safe")
			TEST_ASSERT(get_area(T) == get_area(first), "The room finder mixed rooms")
			TEST_ASSERT(!istype(get_area(T), /area/maintenance), "The room finder picked maintenance")

/// The mystery gift is a wrapped, unlocked crate of a harmless pack; unwrapping drops it; no pack hands out weapons or access
/datum/unit_test/aquila_hex_finds/mystery_gift

/datum/unit_test/aquila_hex_finds/mystery_gift/Run()
	var/turf/floor = watch(run_loc_floor_bottom_left)
	var/datum/round_event/aquila_hex_mystery_gift/event = new(FALSE)
	event.kill()
	var/list/packs = event.gift_packs()
	TEST_ASSERT(length(packs), "The mystery gift has no packs to pick from")
	for(var/pack_type in packs)
		var/datum/supply_pack/pack = SSshuttle.supply_packs[pack_type]
		TEST_ASSERT(!pack.access && !pack.access_any && !pack.dangerous && !pack.hidden && !pack.contraband, "The mystery gift may pick [pack_type]")
		TEST_ASSERT(!ispath(pack_type, /datum/supply_pack/security), "The mystery gift may pick the security pack [pack_type]")
		for(var/item_type in pack.contains)
			TEST_ASSERT(!ispath(item_type, /obj/item/gun) && !ispath(item_type, /obj/item/grenade), "The mystery gift may hand out [item_type] from [pack_type]")
	TEST_ASSERT(isnull(event.make_gift(null)), "A gift appeared nowhere")
	var/obj/structure/big_delivery/gift = event.make_gift(floor)
	TEST_ASSERT(istype(gift) && gift.loc == floor, "No gift appeared")
	var/obj/structure/closet/crate/crate = locate() in gift
	TEST_ASSERT(crate && !crate.locked && !length(crate.req_access), "The gift holds no unlocked crate")
	for(var/obj/item/content in crate)
		TEST_ASSERT(findtext(content.name, "z tajemniczego prezentu"), "[content] is not marked as a mystery gift")
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, floor)
	gift.interact(user)
	TEST_ASSERT(QDELETED(gift), "Unwrapping did not remove the wrapping")
	TEST_ASSERT(crate.loc == floor, "The crate did not come out of the wrapping")
	qdel(event)

/// The satellite comes apart with a wrench and a welder, in that order, and its data core gives research points and sells
/datum/unit_test/aquila_hex_finds/satellite

/datum/unit_test/aquila_hex_finds/satellite/Run()
	var/turf/floor = watch(run_loc_floor_bottom_left)
	var/turf/side = watch(get_step(floor, EAST))
	var/obj/structure/aquila_derelict_satellite/satellite = new(side)
	TEST_ASSERT(satellite.GetComponent(/datum/component/gps), "The satellite has no GPS")
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, floor)
	var/obj/item/weldingtool/welder = hand_tool(user, /obj/item/weldingtool)
	welder.attack_self(user)
	welder.melee_attack_chain(user, satellite)
	TEST_ASSERT(!QDELETED(satellite), "The welder cut the satellite before its cover came off")
	user.dropItemToGround(welder)
	var/obj/item/wrench/wrench = hand_tool(user, /obj/item/wrench)
	wrench.melee_attack_chain(user, satellite)
	TEST_ASSERT(satellite.stage != 0, "The wrench did not take the cover off")
	user.dropItemToGround(wrench)
	user.put_in_active_hand(welder)
	welder.melee_attack_chain(user, satellite)
	TEST_ASSERT(QDELETED(satellite), "The welder did not cut the satellite apart")
	TEST_ASSERT(locate(/obj/item/aquila_satellite_data_core) in side, "The satellite left no data core")
	var/obj/item/stack/sheet/iron/iron = locate() in side
	TEST_ASSERT(iron?.amount == 6, "The satellite left [iron?.amount || 0] iron sheets")
	TEST_ASSERT(locate(/obj/item/stack/rods) in side, "The satellite left no rods")
	TEST_ASSERT(locate(/obj/item/circuitboard) in side, "The satellite left no circuit board")
	var/list/points = SSresearch.techweb_point_items[/obj/item/aquila_satellite_data_core]
	TEST_ASSERT(points?[TECHWEB_POINT_TYPE_GENERIC] > 0, "The data core gives no research points")
	TEST_ASSERT(locate(/datum/export/aquila_satellite_data_core) in GLOB.exports_list, "The data core cannot be exported")

/// The old vendotron stocks 6-12 harmless items at prices within 30% of their base price and runs without power
/datum/unit_test/aquila_hex_finds/vendotron

/datum/unit_test/aquila_hex_finds/vendotron/Run()
	var/turf/floor = watch(run_loc_floor_bottom_left)
	var/obj/machinery/vending/aquila_old_vendotron/vendor = new(floor)
	TEST_ASSERT(length(vendor.product_records) >= 6 && length(vendor.product_records) <= 12, "The vendotron stocks [length(vendor.product_records)] items")
	for(var/datum/data/vending_product/record as anything in vendor.product_records)
		var/base_price = vendor.stock_prices[record.product_path]
		TEST_ASSERT(base_price, "The vendotron sells [record.product_path], which is not on its list")
		TEST_ASSERT(record.custom_price >= round(base_price * 0.7) && record.custom_price <= base_price * 1.3 + 1, "[record.name] costs [record.custom_price] for base [base_price]")
		TEST_ASSERT(record.amount >= 1 && record.amount <= 3, "[record.name] is stocked [record.amount] times")
		TEST_ASSERT(!ispath(record.product_path, /obj/item/gun) && !ispath(record.product_path, /obj/item/melee), "The vendotron sells the weapon [record.product_path]")
	TEST_ASSERT(!(vendor.machine_stat & NOPOWER), "The vendotron needs power")

/// The trader refuses the wrong thing, takes the right one, pays and vanishes; the event clears a trader nobody served
/datum/unit_test/aquila_hex_finds/trader

/datum/unit_test/aquila_hex_finds/trader/Run()
	var/turf/floor = watch(run_loc_floor_bottom_left)
	var/turf/side = watch(get_step(floor, EAST))
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, floor)
	var/datum/round_event/aquila_hex_travelling_trader/event = new(FALSE)
	event.kill()
	var/mob/living/carbon/human/dummy/aquila_hex_trader/chef/trader = event.spawn_trader(side, /mob/living/carbon/human/dummy/aquila_hex_trader/chef)
	TEST_ASSERT(istype(trader) && trader.loc == side, "No trader appeared")
	TEST_ASSERT(ispath(trader.requested_item, /obj/item/food), "The chef asks for [trader.requested_item]")
	TEST_ASSERT(trader.status_flags & GODMODE, "The trader can be hurt")
	trader.requested_item = /obj/item/food/donkpocket
	var/obj/item/wrench/wrong = allocate(/obj/item/wrench, floor)
	user.put_in_active_hand(wrong)
	wrong.melee_attack_chain(user, trader)
	TEST_ASSERT(!QDELETED(trader) && !QDELETED(wrong), "The trader took a wrench for a donk pocket")
	user.dropItemToGround(wrong)
	var/obj/item/food/donkpocket/dish = allocate(/obj/item/food/donkpocket, floor)
	user.put_in_active_hand(dish)
	dish.melee_attack_chain(user, trader)
	TEST_ASSERT(QDELETED(dish), "The trader did not take the dish")
	TEST_ASSERT(QDELETED(trader), "The trader did not vanish after the trade")
	TEST_ASSERT(isnull(event.trader), "The event kept the vanished trader")
	var/obj/item/holochip/payment = user.is_holding_item_of_type(/obj/item/holochip)
	TEST_ASSERT(payment?.credits >= 300, "The trader did not pay")

	var/mob/living/carbon/human/dummy/aquila_hex_trader/bartender/bartender = event.spawn_trader(side, /mob/living/carbon/human/dummy/aquila_hex_trader/bartender)
	TEST_ASSERT(ispath(bartender.requested_item, /datum/reagent/consumable/ethanol), "The bartender asks for [bartender.requested_item]")
	var/obj/item/reagent_containers/glass/beaker/glass = allocate(/obj/item/reagent_containers/glass/beaker, floor)
	glass.reagents.add_reagent(bartender.requested_item, 20)
	TEST_ASSERT(!bartender.check_item(glass), "The bartender took 20 units for 30")
	glass.reagents.add_reagent(bartender.requested_item, 10)
	TEST_ASSERT(bartender.check_item(glass), "The bartender refused 30 units of his drink")
	event.end()
	TEST_ASSERT(QDELETED(bartender), "The trader stayed after the event ended")
	qdel(event)

/// The parcel holds the ciphered note and petty contraband; the stash opens with a crowbar, the strongbox too, and the
/// ledger registered at a security records console with armory access pays the security budget once
/datum/unit_test/aquila_hex_finds/contraband

/datum/unit_test/aquila_hex_finds/contraband/Run()
	var/turf/floor = watch(run_loc_floor_bottom_left)
	var/turf/side = watch(get_step(floor, EAST))
	var/plain = "Skrytka pod płytką, Żółw i Ćma. G."
	var/ciphered = aquila_hex_caesar(plain, 3)
	TEST_ASSERT(ciphered != plain, "The cipher did not change the text")
	TEST_ASSERT_EQUAL(aquila_hex_caesar(ciphered, -3), plain, "The cipher does not decode back")

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, floor)
	var/obj/item/aquila_smuggler_parcel/parcel = new(floor, "Jan Testowy", "tunel testowy")
	user.put_in_active_hand(parcel)
	parcel.attack_self(user)
	TEST_ASSERT(QDELETED(parcel), "The parcel did not open")
	var/obj/item/paper/aquila_smuggler_note/note = locate() in floor
	TEST_ASSERT(note && !note.decoded && findtext(note.plain_text, "tunel testowy"), "The parcel held no note about the stash")
	TEST_ASSERT(!(locate(/obj/item/gun) in floor) && !(locate(/obj/item/card/emag) in floor), "The parcel held a gun or an emag")
	TEST_ASSERT(note.decode(user) && note.decoded, "The note did not decode")

	var/obj/structure/aquila_smuggler_stash/stash = new(side, "Jan Testowy")
	var/obj/item/crowbar/crowbar = hand_tool(user, /obj/item/crowbar)
	crowbar.melee_attack_chain(user, stash)
	TEST_ASSERT(stash.opened, "The crowbar did not open the stash")
	var/obj/item/storage/lockbox/aquila_smuggler/box = locate() in side
	TEST_ASSERT(box, "The stash held no strongbox")
	TEST_ASSERT(SEND_SIGNAL(box, COMSIG_IS_STORAGE_LOCKED), "The strongbox came unlocked")
	crowbar.melee_attack_chain(user, box)
	TEST_ASSERT(box.broken && !SEND_SIGNAL(box, COMSIG_IS_STORAGE_LOCKED), "The crowbar did not force the strongbox")
	var/obj/item/aquila_smuggler_ledger/ledger = locate() in box
	TEST_ASSERT(ledger?.smuggler_name == "Jan Testowy", "The strongbox held no ledger of the smuggler")
	var/cash = 0
	for(var/obj/item/stack/spacecash/bill in box)
		cash += bill.value * bill.amount
	TEST_ASSERT_EQUAL(cash, 250, "The strongbox held a wrong sum")

	user.dropItemToGround(crowbar)
	var/obj/machinery/computer/secure_data/console = allocate(/obj/machinery/computer/secure_data, side)
	console.machine_stat &= ~(NOPOWER|BROKEN)
	ledger.forceMove(floor)
	user.put_in_active_hand(ledger)
	var/datum/bank_account/budget = SSeconomy.get_dep_account(ACCOUNT_SEC)
	var/money_before = budget?.account_balance
	ledger.melee_attack_chain(user, console)
	TEST_ASSERT(!ledger.registered, "The ledger was registered without armory access")
	var/obj/item/card/id/card = allocate(/obj/item/card/id, floor)
	card.access = list(ACCESS_ARMORY)
	user.put_in_inactive_hand(card)
	ledger.melee_attack_chain(user, console)
	TEST_ASSERT(ledger.registered, "The ledger was not registered")
	if(budget)
		TEST_ASSERT_EQUAL(budget.account_balance, money_before + 300, "The security budget was not paid")
	ledger.melee_attack_chain(user, console)
	if(budget)
		TEST_ASSERT_EQUAL(budget.account_balance, money_before + 300, "The ledger paid twice")
	TEST_ASSERT(locate(/obj/item/paper) in side, "The console printed no receipt")

/// The untouched nest throws nearby loose things to safe turfs of the ship; cutting it gives one-use shards and ends it
/datum/unit_test/aquila_hex_finds/nest

/datum/unit_test/aquila_hex_finds/nest/Run()
	var/turf/floor = watch(run_loc_floor_bottom_left)
	var/turf/side = watch(get_step(floor, EAST))
	var/obj/structure/aquila_bluespace_nest/nest = new(side)
	TEST_ASSERT(nest.crystals >= 3 && nest.crystals <= 5, "The nest grew [nest.crystals] crystals")
	TEST_ASSERT(!nest.density, "The nest blocks the tunnel")
	var/obj/item/wrench/loose = allocate(/obj/item/wrench, side)
	var/pulses = nest.pulses_left
	var/moved = nest.pulse()
	TEST_ASSERT_EQUAL(nest.pulses_left, pulses - 1, "The pulse was not counted")
	if(moved)
		var/turf/landed = get_turf(loose)
		TEST_ASSERT(landed != side, "The pulse threw nothing away")
		var/area/landed_area = get_area(landed)
		TEST_ASSERT(landed && !isspaceturf(landed) && landed_area && !aquila_hex_unsafe_area_type(landed_area.type), "The pulse threw the wrench to [landed]")
	else
		TEST_ASSERT(isnull(aquila_hex_safe_teleport_turf()), "The nest threw nothing although the ship has safe turfs")

	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, floor)
	var/obj/item/wirecutters/cutters = hand_tool(user, /obj/item/wirecutters)
	var/crystals = nest.crystals
	for(var/i in 1 to crystals)
		cutters.melee_attack_chain(user, nest)
	TEST_ASSERT(QDELETED(nest), "The nest stayed after its last crystal was cut")
	var/shards = 0
	for(var/obj/item/aquila_bluespace_shard/shard in floor.contents + side.contents + user.contents)
		shards++
	TEST_ASSERT_EQUAL(shards, crystals, "Cutting gave a wrong number of shards")
	var/obj/item/aquila_bluespace_shard/held = locate() in user.held_items
	if(!held)
		held = locate() in (floor.contents + side.contents)
		user.dropItemToGround(cutters)
		user.put_in_active_hand(held)
	TEST_ASSERT(!length(held.custom_materials) && !SSresearch.techweb_point_items[held.type], "The shard is worth materials or research")
	held.attack_self(user)
	TEST_ASSERT(QDELETED(held), "The crushed shard stayed")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
