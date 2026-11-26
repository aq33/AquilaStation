// AQUILA - testy eventów z kafli mapy hex, etap E2 (awarie okrętu dla inżynierii i medyków): pule terenów, kanał APC,
// pożar instalacji, blokada śluz, wyciek promieniowania, wyciek gazu, pęknięty kanister, zatkany zsyp, skażone pomieszczenie,
// pylenie roślin i splątanie szafek
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Every E2 event is in the pool of its own terrain only; the empty space ones still spawn as plain ship events
/datum/unit_test/aquila_hex_failures_pools

/datum/unit_test/aquila_hex_failures_pools/Run()
	var/list/allowed_terrains = list(
		/datum/round_event_control/aquila_hex_apc_scramble = HEX_TERRAIN_ELECTRICAL,
		/datum/round_event_control/aquila_hex_electrical_fire = HEX_TERRAIN_ELECTRICAL,
		/datum/round_event_control/aquila_hex_door_runtime = HEX_TERRAIN_ION,
		/datum/round_event_control/aquila_hex_radiation_leak = HEX_TERRAIN_RADIATION,
		/datum/round_event_control/aquila_hex_atmos_leak = HEX_TERRAIN_EMPTY,
		/datum/round_event_control/aquila_hex_canister_leak = HEX_TERRAIN_EMPTY,
		/datum/round_event_control/aquila_hex_disposals_clog = HEX_TERRAIN_EMPTY,
		/datum/round_event_control/aquila_hex_disease_outbreak_floor = HEX_TERRAIN_RADIATION,
		/datum/round_event_control/aquila_hex_station_incident_hay_fever = HEX_TERRAIN_EMPTY,
		/datum/round_event_control/aquila_hex_locker_entanglement = HEX_TERRAIN_GRAVITY,
	)
	hex_terrain(HEX_TERRAIN_EMPTY)
	for(var/path in allowed_terrains)
		var/datum/round_event_control/control = hex_event_control(path)
		TEST_ASSERT(control, "No event control of [path]")
		var/terrain_id = allowed_terrains[path]
		TEST_ASSERT(path in hex_terrain(terrain_id).events, "[control.name] is not in the pool of [terrain_id]")
		for(var/id in GLOB.hex_terrains)
			if(id != terrain_id)
				TEST_ASSERT(!(path in hex_terrain(id).events), "[control.name] is also in the pool of [id]")
		if(terrain_id == HEX_TERRAIN_EMPTY)
			TEST_ASSERT(!hex_tile_environment_events()[path], "[control.name] of empty space is dropped from the ship events")
			if(GLOB.hexmap?.built)
				TEST_ASSERT(hex_random_event_allowed(control), "SSevents cannot roll [control.name] with the hex map built")
		else
			TEST_ASSERT(hex_tile_environment_events()[path], "[control.name] still rolls as a plain ship event")

/// The APC scramble switches one channel of a working APC off and nothing else
/datum/unit_test/aquila_hex_failures_apc_scramble

/datum/unit_test/aquila_hex_failures_apc_scramble/Run()
	var/datum/round_event/aquila_hex_apc_scramble/scramble = new(FALSE)
	scramble.kill()
	var/obj/machinery/power/apc/apc
	for(var/obj/machinery/power/apc/candidate as anything in GLOB.apcs_list)
		if(scramble.can_scramble(candidate))
			apc = candidate
			break
	TEST_ASSERT(apc, "No working APC with a channel on in the test world")
	var/list/before = list(apc.lighting, apc.equipment, apc.environ)
	var/channels_before = length(scramble.channels_on(apc))
	var/channel = scramble.scramble_apc(apc)
	TEST_ASSERT(channel, "The APC scramble switched nothing off")
	TEST_ASSERT_EQUAL(length(scramble.channels_on(apc)), channels_before - 1, "The scramble did not switch exactly one channel off")
	TEST_ASSERT(!apc.machine_stat, "The scramble broke the APC")
	apc.lighting = before[1]
	apc.equipment = before[2]
	apc.environ = before[3]
	apc.update_appearance()
	apc.update()
	qdel(scramble)

/// The electrical fire sets a burning puddle under a powered machine
/datum/unit_test/aquila_hex_failures_electrical_fire

/datum/unit_test/aquila_hex_failures_electrical_fire/Run()
	var/turf/open/fire_turf = run_loc_floor_bottom_left
	aquila_liquids_cleanup(fire_turf)
	var/obj/machinery/microwave/microwave = allocate(/obj/machinery/microwave, fire_turf)
	var/datum/round_event/aquila_hex_electrical_fire/fire = new(FALSE)
	fire.kill()
	TEST_ASSERT_EQUAL(fire.ignite_machine(microwave), fire_turf, "The machine did not catch fire")
	TEST_ASSERT(!QDELETED(fire_turf.liquids) && fire_turf.liquids.fire_state, "There is no burning puddle under the machine")
	aquila_liquids_cleanup(fire_turf)
	qdel(fire)

/// The door runtime bolts and electrifies an airlock, then releases it without opening a door that was shut
/datum/unit_test/aquila_hex_failures_door_runtime

/datum/unit_test/aquila_hex_failures_door_runtime/Run()
	var/obj/machinery/door/airlock/door = allocate(/obj/machinery/door/airlock, get_step(run_loc_floor_bottom_left, NORTH))
	TEST_ASSERT(door.density, "The test airlock does not start closed")
	var/list/locked = list()
	aquila_hex_door_runtime_lock(list(door), locked)
	TEST_ASSERT_EQUAL(length(locked), 1, "The airlock is not on the locked list")
	TEST_ASSERT(door.locked, "The lockdown did not bolt the airlock")
	TEST_ASSERT(door.isElectrified(), "The lockdown did not electrify the airlock")
	var/datum/round_event/aquila_hex_door_runtime/runtime = new(FALSE)
	runtime.kill()
	TEST_ASSERT(!runtime.can_lock(door), "A bolted airlock can be locked again")
	aquila_hex_door_runtime_release(locked)
	TEST_ASSERT(!door.locked, "The release did not unbolt the airlock")
	TEST_ASSERT(!door.isElectrified(), "The release left the airlock electrified")
	TEST_ASSERT(door.safe, "The release left the airlock crushing")
	TEST_ASSERT(door.density, "The release opened an airlock that was shut")
	if(runtime.can_lock(door))
		var/mob/living/carbon/human/blocker = allocate(/mob/living/carbon/human, get_turf(door))
		TEST_ASSERT(!runtime.can_lock(door), "An airlock with [blocker] in the doorway can be locked")
	qdel(runtime)

/// The radiation leak puffs smoke, hints the repair tools on examine and stops when repaired
/datum/unit_test/aquila_hex_failures_radiation_leak

/datum/unit_test/aquila_hex_failures_radiation_leak/Run()
	var/obj/machinery/modular_fabricator/autolathe/machine = allocate(/obj/machinery/modular_fabricator/autolathe, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	var/datum/round_event/aquila_hex_radiation_leak/leak = new(FALSE)
	TEST_ASSERT(leak.can_leak(machine), "An autolathe cannot leak")
	leak.start_leak(machine)
	TEST_ASSERT_EQUAL(leak.leaking_machine, machine, "The leak did not start at the machine")
	TEST_ASSERT(length(leak.fix_methods) >= 1 && length(leak.fix_methods) <= 3, "The leak has [length(leak.fix_methods)] repair methods")
	var/smoke_found = FALSE
	for(var/obj/effect/particle_effect/smoke/chem/smoke in range(2, machine))
		smoke_found = TRUE
		qdel(smoke)
	TEST_ASSERT(smoke_found, "The leak puffed no smoke")
	var/examine_text = jointext(machine.examine(user), "\n")
	TEST_ASSERT(findtext(examine_text, leak.fix_methods[1]), "Examining the machine does not tell how to stop the leak")
	leak.finish_repair()
	TEST_ASSERT(isnull(leak.leaking_machine), "The repaired machine still leaks")
	TEST_ASSERT(!(leak in SSevents.running), "The event still runs after the repair")
	TEST_ASSERT(!findtext(jointext(machine.examine(user), "\n"), "zielony dym"), "The repaired machine still shows the leak")
	for(var/obj/effect/particle_effect/smoke/smoke in range(4, machine))
		qdel(smoke)
	qdel(leak)

/// The gas leak adds the gas to the turf; the broken canister lets all its gas out
/datum/unit_test/aquila_hex_failures_gas_leaks

/datum/unit_test/aquila_hex_failures_gas_leaks/Run()
	var/turf/open/leak_turf = run_loc_floor_top_right
	var/co2_before = leak_turf.air.get_moles(GAS_CO2)
	var/datum/round_event/aquila_hex_atmos_leak/atmos = new(FALSE)
	atmos.kill()
	atmos.gas_type = GAS_CO2
	atmos.leak_gas(leak_turf)
	TEST_ASSERT(leak_turf.air.get_moles(GAS_CO2) >= co2_before + 9 * MOLES_CELLSTANDARD, "The gas leak did not add the gas")
	TEST_ASSERT_EQUAL(aquila_hex_gas_name(GAS_CO2), "dwutlenek węgla", "The gas has no Polish name")
	leak_turf.air.set_moles(GAS_CO2, co2_before)
	qdel(atmos)

	var/obj/machinery/portable_atmospherics/canister/carbon_dioxide/canister = allocate(/obj/machinery/portable_atmospherics/canister/carbon_dioxide, leak_turf)
	var/datum/round_event/aquila_hex_canister_leak/canister_leak = new(FALSE)
	canister_leak.kill()
	var/canister_moles = canister.air_contents.total_moles()
	TEST_ASSERT(canister_moles >= MOLES_CELLSTANDARD, "The CO2 canister is empty")
	canister_leak.break_canister(canister)
	TEST_ASSERT(canister.machine_stat & BROKEN, "The canister did not break")
	TEST_ASSERT(canister.air_contents.total_moles() < 1, "The broken canister kept its gas")
	TEST_ASSERT(leak_turf.air.get_moles(GAS_CO2) >= co2_before + canister_moles * 0.9, "The canister gas did not reach the turf")
	TEST_ASSERT_EQUAL(canister_leak.leak_area, get_area(leak_turf), "The canister leak does not know where it broke")
	TEST_ASSERT(!canister_leak.can_break(canister), "A broken canister can break again")
	leak_turf.air.set_moles(GAS_CO2, co2_before)
	qdel(canister_leak)

/// A clogged disposal bin throws out trash, the last one also vermin
/datum/unit_test/aquila_hex_failures_disposals_clog

/datum/unit_test/aquila_hex_failures_disposals_clog/Run()
	var/obj/machinery/disposal/bin/bin = allocate(/obj/machinery/disposal/bin, run_loc_floor_bottom_left)
	var/datum/round_event/aquila_hex_disposals_clog/clog = new(FALSE)
	clog.kill()
	clog.control = hex_event_control(/datum/round_event_control/aquila_hex_disposals_clog)
	var/list/spawned = clog.spew(bin, with_vermin = TRUE)
	allocated += spawned
	var/trash = 0
	var/vermin = 0
	for(var/atom/movable/thing as anything in spawned)
		if(istype(thing, /obj/item/trash))
			trash++
		else if(istype(thing, /mob/living/basic/mouse) || istype(thing, /mob/living/basic/cockroach))
			vermin++
	TEST_ASSERT(trash >= 4 && trash <= 8, "The bin threw out [trash] pieces of trash")
	TEST_ASSERT(vermin >= 2 && vermin <= 4, "The last bin let out [vermin] vermin")
	var/list/plain = clog.spew(bin)
	allocated += plain
	for(var/mob/living/stowaway in plain)
		TEST_ASSERT(FALSE, "A bin without vermin let out [stowaway]")
	TEST_ASSERT_EQUAL(clog.spewed, 2, "The spewed bin count is wrong")
	qdel(clog)

/// The infected room leaves stains that carry the mild disease
/datum/unit_test/aquila_hex_failures_disease_floor

/datum/unit_test/aquila_hex_failures_disease_floor/Run()
	var/datum/round_event/aquila_hex_disease_outbreak_floor/outbreak = new(FALSE)
	outbreak.kill()
	TEST_ASSERT(istype(outbreak.chosen_disease, /datum/disease/cold) || istype(outbreak.chosen_disease, /datum/disease/flu), "The outbreak picked [outbreak.chosen_disease]")
	TEST_ASSERT(length(outbreak.chosen_disease.cures), "The outbreak disease has no cure")
	var/list/turfs = list(run_loc_floor_bottom_left, get_step(run_loc_floor_bottom_left, EAST), get_step(run_loc_floor_bottom_left, NORTH))
	var/list/stains = outbreak.contaminate(turfs, 3)
	allocated += stains
	TEST_ASSERT_EQUAL(length(stains), 3, "The outbreak did not leave three stains")
	for(var/obj/effect/decal/cleanable/stain as anything in stains)
		var/carries_disease = FALSE
		for(var/datum/component/infective/infection as anything in stain.GetComponents(/datum/component/infective))
			if(outbreak.chosen_disease in infection.diseases)
				carries_disease = TRUE
		TEST_ASSERT(carries_disease, "[stain] does not carry the outbreak disease")
	qdel(outbreak)

/// A ripe tray gives histamine to a breathing human once and stops pollinating after the harvest
/datum/unit_test/aquila_hex_failures_hay_fever

/datum/unit_test/aquila_hex_failures_hay_fever/Run()
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, get_step(run_loc_floor_bottom_left, EAST))
	var/mob/living/carbon/human/sneezer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/round_event/aquila_hex_station_incident_hay_fever/pollen = new(FALSE)
	pollen.kill()
	pollen.tray_ref = WEAKREF(tray)
	pollen.pollen_area = get_area(tray)
	TEST_ASSERT(isnull(pollen.pollen_source()), "An empty tray pollinates")
	tray.harvestable_components["aquila_test"] = list("aquila_test")
	if(is_station_level(tray.z))
		TEST_ASSERT_EQUAL(pollen.pollen_source(), tray, "A ripe tray does not pollinate")
	TEST_ASSERT(pollen.expose(sneezer), "The pollen did not reach a breathing human")
	TEST_ASSERT(sneezer.reagents.has_reagent(/datum/reagent/toxin/histamine), "The pollen gave no histamine")
	TEST_ASSERT(!pollen.expose(sneezer), "The pollen reached the same human twice")
	tray.harvestable_components.Cut()
	TEST_ASSERT(isnull(pollen.pollen_source()), "A harvested tray still pollinates")
	qdel(pollen)

/// What goes into an entangled closet comes out of its partner, and only while they are entangled
/datum/unit_test/aquila_hex_failures_locker_entanglement

/datum/unit_test/aquila_hex_failures_locker_entanglement/Run()
	var/obj/structure/closet/first = allocate(/obj/structure/closet, run_loc_floor_bottom_left)
	var/obj/structure/closet/second = allocate(/obj/structure/closet, run_loc_floor_top_right)
	var/obj/item/toy/crayon/red/crayon = allocate(/obj/item/toy/crayon/red, first)
	TEST_ASSERT(!first.opened && crayon.loc == first, "The test closet does not start closed with the crayon inside")
	var/datum/round_event/aquila_hex_locker_entanglement/entanglement = new(FALSE)
	TEST_ASSERT_EQUAL(entanglement.entangle(list(first, second)), 2, "The two closets were not entangled")
	first.open()
	TEST_ASSERT_EQUAL(crayon.loc, get_turf(second), "The crayon did not come out of the partner closet")
	first.close()
	crayon.forceMove(first)
	entanglement.kill()
	TEST_ASSERT(isnull(first.aquila_entangled_closet) && isnull(second.aquila_entangled_closet), "The closets stay entangled after the event")
	first.open()
	TEST_ASSERT_EQUAL(crayon.loc, get_turf(first), "A disentangled closet still sends its contents away")
	qdel(entanglement)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
