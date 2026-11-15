// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - maskowanie generatora tarcz: sygnatura i radar wroga spadają, tarcza nie chroni, po zdjęciu tarcza wraca
/datum/unit_test/shield_cloak
	var/obj/machinery/shield_generator/gen
	var/obj/structure/overmap/ship
	var/old_shields

/datum/unit_test/shield_cloak/Run()
	ship = SSstar_system.find_main_overmap()
	TEST_ASSERT(ship, "No main ship for the cloak test")
	old_shields = ship.shields
	gen = new(run_loc_floor_bottom_left)
	ship.shields = gen

	var/size = ship.get_signature_size()
	var/heat = ship.get_signature_heat()
	gen.cloaked = TRUE
	TEST_ASSERT(ship.is_cloaked(), "The ship isn't cloaked with a cloaking shield generator")
	TEST_ASSERT(abs(ship.get_signature_size() - size * 0.2) < 0.001, "The cloak doesn't cut the signature size")
	TEST_ASSERT(abs(ship.get_signature_heat() - heat * 0.2) < 0.001, "The cloak doesn't cut the signature heat")

	// Tarcza w masce nie pochłania trafień
	gen.active = TRUE
	gen.shield["integrity"] = 1000
	var/obj/item/projectile/proj = new(run_loc_floor_bottom_left)
	proj.damage = 10
	TEST_ASSERT(gen.absorb_hit(proj) == SHIELD_NOEFFECT, "A cloaking shield generator still absorbs hits")
	qdel(proj)

	// Regresja: impuls radaru gracza wobec zamaskowanego celu ma 20% zasięgu, liczone raz (get_player_lidar_range)
	var/old_pulse = ship.last_radar_pulse
	var/old_width = ship.radar_pulse_width
	ship.last_radar_pulse = world.time
	ship.radar_pulse_width = 0
	var/cloaked_reach = ship.get_player_lidar_range(ship)
	gen.cloaked = FALSE
	var/open_reach = ship.get_player_lidar_range(ship)
	gen.cloaked = TRUE
	TEST_ASSERT(open_reach > 0 && abs(cloaked_reach - open_reach * 0.2) < 0.01, "A cloaked target cuts the player radar pulse to [cloaked_reach] of [open_reach] instead of 20%")
	if(!ship.ai_controlled)
		TEST_ASSERT(abs(ship.get_suite_range(SENSOR_LIDAR, ship) - cloaked_reach) < 0.01, "The cloak is applied twice on the player radar suite range")
	ship.last_radar_pulse = old_pulse
	ship.radar_pulse_width = old_width

	// Zdjęcie maski: koniec ukrycia, bez stygnięcia (jak tarcza)
	gen.end_cloak("test")
	TEST_ASSERT(!ship.is_cloaked(), "The ship stayed cloaked after the cloak ended")
	TEST_ASSERT(!gen.cloaked, "The generator stayed in the cloak mode after the cloak ended")

	// Regresja: tarcza podniesiona przed maską wraca po jej zdjęciu
	gen.cloaked = TRUE
	gen.cloak_restore_active = TRUE
	gen.active = FALSE
	gen.end_cloak("test")
	TEST_ASSERT(gen.active, "The shield stayed down after the cloak ended")

	// Regresja: maskę przełącza tylko inżynieria albo dowództwo
	var/mob/living/carbon/human/stranger = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	TEST_ASSERT(!gen.can_toggle_cloak(stranger), "Someone without engineering or command access can toggle the cloak")

	// Regresja: zniszczony generator w masce nie zostawia okrętu zamaskowanego
	gen.cloaked = TRUE
	TEST_ASSERT(ship.is_cloaked(), "The ship didn't count as cloaked")
	var/obj/machinery/shield_generator/destroyed = gen
	gen = null
	qdel(destroyed)
	TEST_ASSERT(!ship.is_cloaked(), "The ship stayed cloaked after its shield generator was destroyed")
	TEST_ASSERT(ship.shields != destroyed, "The ship still points at its destroyed shield generator")

	// Regresja: burza z pulsara trwa, dopóki konsola jej nie wygasi
	var/datum/weather/rad_storm/pulsar/storm_type = /datum/weather/rad_storm/pulsar
	TEST_ASSERT(initial(storm_type.perpetual), "The pulsar storm still ends on its own timer")

/datum/unit_test/shield_cloak/Destroy()
	if(ship)
		ship.shields = old_shields
		ship.alpha = 255
	QDEL_NULL(gen)
	return ..()

#undef TEST_ASSERT
