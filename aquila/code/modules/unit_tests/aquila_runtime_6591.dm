// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Expected [isnull(a) ? "null" : a] to be equal to [isnull(b) ? "null" : b].[message ? " [message]" : ""]") }

/// AQUILA - runda 6591: span_* z aquila/code/__DEFINES/span.dm nie miały nawiasów wokół argumentu,
/// więc span_deadsay(warunek ? "a" : "b") liczyło "<span ...>" + warunek (oględziny martwego kota i kozy)
/datum/unit_test/aquila_span_macro_ternary

/datum/unit_test/aquila_span_macro_ternary/Run()
	var/naive = FALSE
	TEST_ASSERT_EQUAL(span_deadsay(naive ? "spi" : "martwy"), "<span class='deadsay'>martwy</span>", "span_deadsay() does not wrap a ternary argument")

/// AQUILA - runda 6591: wybiórcze oczyszczanie krwi w nosicielu bez reagentów sypało runtime'em co tick (306 razy)
/datum/unit_test/aquila_nanite_purging_no_reagents

/datum/unit_test/aquila_nanite_purging_no_reagents/Run()
	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human)
	QDEL_NULL(host.reagents)
	var/datum/nanite_program/purging_advanced/program = new
	program.host_mob = host
	TEST_ASSERT(!program.check_conditions(), "The program reported work on a host without toxins or reagents")
	program.active_effect()
	program.host_mob = null
	qdel(program)

/// AQUILA - runda 6591: cień światła jechał z promem, światło chowało go w trakcie ruchu i afterShuttleMove() czytało null.z
/datum/unit_test/aquila_light_shadow_shuttle_move

/datum/unit_test/aquila_light_shadow_shuttle_move/Run()
	var/turf/old_turf = run_loc_floor_bottom_left
	var/turf/new_turf = locate(old_turf.x + 1, old_turf.y, old_turf.z)
	var/obj/effect/abstract/aq_light_shadow/shadow = allocate(/obj/effect/abstract/aq_light_shadow, old_turf)
	TEST_ASSERT(!shadow.onShuttleMove(new_turf, old_turf, list(0, 0, 0), NORTH), "The light shadow joins the shuttle move list")
	TEST_ASSERT_EQUAL(shadow.loc, old_turf, "The shuttle moved the light shadow itself")

/// AQUILA - runda 6591: ponowne Grant() akcji temu samemu mobowi rejestrowało sygnał drugi raz (ostrzeżenie „overridden”)
/datum/unit_test/aquila_mob_cooldown_regrant

/datum/unit_test/aquila_mob_cooldown_regrant/Run()
	var/mob/living/carbon/human/frog = allocate(/mob/living/carbon/human)
	var/datum/action/cooldown/mob_cooldown/sticky_tongue/tongue = new(frog)
	tongue.Grant(frog)
	tongue.Grant(frog) // transfer_actions() przy transfer_to() na ten sam mob
	TEST_ASSERT_EQUAL(tongue.owner, frog, "The action lost its owner after the second Grant()")
	tongue.Remove(frog)
	TEST_ASSERT(!length(tongue.signal_procs?[frog]), "The action still listens to the mob after Remove()")
	qdel(tongue)

/// AQUILA - runda 6591: checkTurfVis() z celem w nullspace czytało null.x
/datum/unit_test/aquila_cameranet_null_turf

/datum/unit_test/aquila_cameranet_null_turf/Run()
	TEST_ASSERT(!GLOB.cameranet.checkTurfVis(null), "A null turf counts as visible to cameras")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
