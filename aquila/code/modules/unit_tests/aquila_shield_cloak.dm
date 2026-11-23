// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - maskowanie generatora tarcz: sygnatura i radar wroga spadają, tarcza nie chroni, po zdjęciu tarcza wraca
/datum/unit_test/shield_cloak
	var/obj/machinery/shield_generator/gen
	var/obj/structure/overmap/ship
	var/old_shields
	var/old_had_arrays
	var/old_pulse
	var/old_width

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
	old_pulse = ship.last_radar_pulse
	old_width = ship.radar_pulse_width
	// Matryce statku zależą od wcześniejszych testów (zasilanie, uszkodzenia); tu liczy się tylko maska
	old_had_arrays = ship.had_sensor_array
	ship.had_sensor_array = FALSE
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
	ship.had_sensor_array = old_had_arrays

	// Zdjęcie maski: koniec ukrycia, bez stygnięcia (jak tarcza)
	gen.end_cloak("test")
	TEST_ASSERT(!ship.is_cloaked(), "The ship stayed cloaked after the cloak ended")
	TEST_ASSERT(!gen.cloaked, "The generator stayed in the cloak mode after the cloak ended")

	// Odlot w skok zdejmuje maskę od razu (sygnał COMSIG_SHIP_DEPARTED zarejestrowany przy włączeniu)
	gen.cloaked = TRUE
	gen.cloak_ship = WEAKREF(ship)
	gen.RegisterSignal(ship, COMSIG_SHIP_DEPARTED, TYPE_PROC_REF(/obj/machinery/shield_generator, on_ship_departed))
	SEND_SIGNAL(ship, COMSIG_SHIP_DEPARTED)
	TEST_ASSERT(!gen.cloaked, "The cloak survived the ship departing on a jump")
	TEST_ASSERT(!gen.cloak_ship, "The cloak kept a reference to the ship after ending")

	// Regresja: strzał zdejmuje maskę od razu (każda broń przez fire_projectile albo fire_proc_chain)
	gen.cloaked = TRUE
	ship.aq_on_weapon_fired()
	TEST_ASSERT(!gen.cloaked, "A shot didn't drop the cloak at once")

	// Regresja: dyfuzor nie drenuje opuszczonej tarczy
	gen.cloaked = FALSE
	gen.active = FALSE
	gen.shield["integrity"] = 100
	gen.shield["max_integrity"] = 100
	TEST_ASSERT(!ship.aq_diffuse_shields(0.5) && gen.shield["integrity"] == 100, "A diffuser drained a lowered shield")

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

/datum/unit_test/shield_cloak/Destroy()
	if(ship)
		ship.shields = old_shields
		if(!isnull(old_had_arrays))
			ship.had_sensor_array = old_had_arrays
		if(!isnull(old_pulse))
			ship.last_radar_pulse = old_pulse
			ship.radar_pulse_width = old_width
		ship.alpha = 255
	QDEL_NULL(gen)
	return ..()

/// AQUILA - regresja: okręt AI zamaskowany po staremu (NSV handle_cloak) też jest is_cloaked(), więc głowica IR go gubi
/datum/unit_test/shield_cloak_nsv

/datum/unit_test/shield_cloak_nsv/Run()
	var/obj/structure/overmap/syndicate/ai/gunboat/morale_test/ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	TEST_ASSERT(!ship.is_cloaked(), "An AI ship counts as cloaked before cloaking")
	var/size_before = ship.get_signature_size()
	ship.cloak_factor = 100
	ship.handle_cloak(TRUE)
	TEST_ASSERT(ship.is_cloaked(), "An AI ship cloaked the NSV way (handle_cloak) isn't is_cloaked()")
	// Maskowanie NSV już ukrywa okręt przez alpha (radar.dm): kara maski tarczy nie może się na nie nakładać
	TEST_ASSERT(ship.get_signature_size() == size_before, "The NSV cloak also cut the signature size (stealth applied twice)")
	TEST_ASSERT(ship.get_cloak_lidar_mult() == 1, "The NSV cloak also cut the enemy radar range (stealth applied twice)")
	// Efekt, który tylko ściemnia okręt i wyłącza klikanie, nie jest maskowaniem
	ship.handle_cloak(FALSE)
	ship.alpha = 100
	ship.mouse_opacity = FALSE
	TEST_ASSERT(!ship.is_cloaked(), "A faded, unclickable ship counts as cloaked without handle_cloak")
	ship.alpha = 255
	ship.mouse_opacity = TRUE
	ship.handle_cloak(TRUE)
	// Strzał okrętu bez generatora tarcz nie może się wywrócić na zdejmowaniu maski tarczy
	ship.aq_on_weapon_fired()
	ship.handle_cloak(CLOAK_TEMPORARY_LOSS)
	TEST_ASSERT(!ship.is_cloaked(), "An AI ship stayed cloaked while its NSV cloak flickered off to fire")
	ship.handle_cloak(FALSE)
	TEST_ASSERT(!ship.is_cloaked(), "An AI ship stayed cloaked after its NSV cloak ended")

#undef TEST_ASSERT
