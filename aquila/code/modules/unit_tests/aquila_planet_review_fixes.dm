// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

// AQUILA - testy regresji poprawek z przeglądu PR aq33/AquilaStation#639 (planety)

/// Tonięcie zadaje stałe obrażenia na tik (wcześniej liczyło je z tick_interval, który u nas jest czasem świata: śmierć
/// w pierwszym tiku), a pomost nad głęboką wodą chroni przed zanurzeniem
/datum/unit_test/planet_swimming_regressions

/datum/unit_test/planet_swimming_regressions/Run()
	var/mob/living/carbon/human/swimmer = allocate(/mob/living/carbon/human)
	var/datum/status_effect/swimming/swimming = swimmer.apply_status_effect(/datum/status_effect/swimming, 2)
	TEST_ASSERT(swimming, "The swimming status didn't apply")
	// Leży w wodzie: tonie
	swimmer.mobility_flags &= ~MOBILITY_STAND
	TEST_ASSERT(swimming.is_drowning(), "A human lying in deep water isn't drowning")
	var/oxy_before = swimmer.getOxyLoss()
	swimming.drown()
	var/oxy_gained = swimmer.getOxyLoss() - oxy_before
	TEST_ASSERT(oxy_gained > 0, "Drowning dealt no oxygen damage")
	// 2 obrażenia na sekundę przez 5 s tiku: około 10, niezależnie od czasu rundy
	TEST_ASSERT(oxy_gained <= 15, "One drowning tick dealt [oxy_gained] oxygen damage (should be about 10, not scale with world.time)")
	swimmer.remove_status_effect(/datum/status_effect/swimming)

	// Pomost: idzie się po nim suchą nogą
	var/turf/T = run_loc_floor_bottom_left
	var/turf_type_before = T.type
	T = T.ChangeTurf(/turf/open/water/planet/stormy)
	var/mob/living/carbon/human/walker = allocate(/mob/living/carbon/human, run_loc_floor_top_right)
	walker.forceMove(T)
	TEST_ASSERT(HAS_TRAIT(walker, TRAIT_IMMERSED), "Deep water didn't immerse a human (control case)")
	walker.forceMove(run_loc_floor_top_right)
	TEST_ASSERT(!HAS_TRAIT(walker, TRAIT_IMMERSED), "Leaving the water didn't remove the immersion")
	var/obj/structure/lattice/catwalk/catwalk = new(T)
	walker.forceMove(T)
	TEST_ASSERT(!HAS_TRAIT(walker, TRAIT_IMMERSED), "A catwalk over deep water didn't stop the immersion")
	walker.forceMove(run_loc_floor_top_right)
	qdel(catwalk)
	T.ChangeTurf(turf_type_before)

/// Moby na powierzchni planety należą do niej (overmap_fallback), ale nie są jej załogą: planeta z mobami nie może trafiać
/// do FTL okrętu, przejmować poziomu Z ani liczyć się jako okręt gracza. Do tego światło dnia nie dziedziczy alfy pogody.
/datum/unit_test/planet_ftl_stays

/datum/unit_test/planet_ftl_stays/Run()
	var/obj/structure/overmap/planet/planet = new(run_loc_floor_top_right, /datum/planet_type/jungle)
	TEST_ASSERT(planet_test_fast_surface(planet), "The planet surface didn't generate")
	var/datum/planet_surface/surface = planet.surface
	var/mob/living/carbon/human/visitor = allocate(/mob/living/carbon/human, surface.center())
	visitor.update_overmap()
	TEST_ASSERT_EQUAL(visitor.get_overmap(), planet, "A mob on the surface doesn't belong to the planet")
	TEST_ASSERT(!(visitor in planet.mobs_in_ship), "A mob on the surface counts as the planet's crew (the planet would follow the ship through FTL)")
	TEST_ASSERT(!planet.spec_pre_system_unload(), "A planet with mobs on its surface would take over the system's z-level")
	var/obj/effect/fullbright/daylight = surface.surface_area.lighting_overlay
	TEST_ASSERT(daylight, "The jungle surface has no daylight overlay")
	TEST_ASSERT(daylight.appearance_flags & RESET_ALPHA, "The daylight overlay inherits the weather alpha of its area (rain darkens the day)")
	TEST_ASSERT(daylight.appearance_flags & RESET_COLOR, "The daylight overlay inherits the weather colour of its area")
	visitor.forceMove(run_loc_floor_top_right)
	surface.unload()
	var/datum/turf_reservation/releasing = surface.releasing_reservation
	var/wait_until = world.time + 2 MINUTES
	while(!QDELETED(releasing) && world.time < wait_until)
		sleep(world.tick_lag)
	qdel(planet, TRUE)

/// Usunięcie moba nie usuwa akcji, której był celem: konsole kamer i dokowania trzymają akcje i przy każdym użyciu
/// ustawiają w nich target na użytkownika
/datum/unit_test/planet_action_survives_owner

/datum/unit_test/planet_action_survives_owner/Run()
	var/mob/living/carbon/human/user = new(run_loc_floor_bottom_left)
	var/datum/action/innate/action = new
	action.target = user
	action.Grant(user)
	qdel(user)
	TEST_ASSERT(!QDELETED(action), "Deleting the user deleted a console action it was using")
	TEST_ASSERT(!action.target, "The action still points at its deleted owner (hard delete)")
	var/mob/living/carbon/human/next_user = allocate(/mob/living/carbon/human)
	action.target = next_user
	action.Grant(next_user)
	TEST_ASSERT(action in next_user.actions, "The action couldn't be granted to the next user")
	action.Remove(next_user)
	qdel(action)

/// Kliknięcie podłogi pod otwartą śluzą przy ciągnięciu czegoś przeciąga to na pole śluzy, zamiast obsługiwać drzwi
/datum/unit_test/aquila_airlock_floor_click

/datum/unit_test/aquila_airlock_floor_click/Run()
	var/obj/machinery/door/airlock/airlock = allocate(/obj/machinery/door/airlock, run_loc_floor_top_right)
	airlock.locked = TRUE // zaryglowane: klik w drzwi nic nie zmienia, więc test nie zostawia animacji otwierania w tle
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	TEST_ASSERT_EQUAL(airlock.on_attack_hand(run_loc_floor_top_right, user, null), COMPONENT_CANCEL_ATTACK_CHAIN, "A plain floor click under the airlock didn't go to the door")
	var/obj/structure/closet/crate/crate = allocate(/obj/structure/closet/crate, run_loc_floor_bottom_left)
	user.start_pulling(crate)
	TEST_ASSERT_EQUAL(user.pulling, crate, "The user couldn't pull the crate")
	TEST_ASSERT(!airlock.on_attack_hand(run_loc_floor_top_right, user, null), "A floor click under the airlock while pulling went to the door instead of dragging")
	user.stop_pulling()

/// Ruiny z wagą 0 (np. Wielka Dziura) nie wypadają losowo jako ruina główna (pickweight zamienia 0 na 1)
/datum/unit_test/planet_zero_weight_ruins

/datum/unit_test/planet_zero_weight_ruins/Run()
	var/obj/structure/overmap/planet/planet = new(run_loc_floor_top_right, /datum/planet_type/jungle)
	var/zero_weight = 0
	for(var/key in planet.planet_type.get_main_ruin_templates())
		var/datum/map_template/ruin/ruin = planet.planet_type.get_main_ruin_templates()[key]
		if(istype(ruin) && ruin.placement_weight <= 0)
			zero_weight++
	TEST_ASSERT(zero_weight, "No zero-weight main ruin left to check (the jungle Big Hole had placement_weight 0)")
	for(var/i in 1 to 40)
		var/datum/map_template/ruin/picked = planet.surface.pick_main_ruin()
		if(!picked)
			continue
		TEST_ASSERT(picked.placement_weight > 0, "[picked.name] with placement_weight 0 was picked as a main ruin")
	qdel(planet, TRUE)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
