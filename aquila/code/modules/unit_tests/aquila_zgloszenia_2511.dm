// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - zgłoszenia 25.11: czerwona ikonka ubikacji wcześniej, horror w nosicielu, rakiety AI na myśliwce

/// Ikonka ubikacji: zwykła od 100, czerwona już od 140 (ok. 7 min później), popuszczenie dalej od 200
/datum/unit_test/aquila_toilet_alert_thresholds

/datum/unit_test/aquila_toilet_alert_thresholds/Run()
	var/old_shitting = CONFIG_GET(flag/shitting_enabled)
	CONFIG_SET(flag/shitting_enabled, TRUE)
	var/mob/living/carbon/human/pooper = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	pooper.set_defecation(120)
	pooper.dna.species.handle_digestion(pooper)
	var/alert_at_120 = pooper.alerts["defecation"]
	pooper.set_defecation(145)
	pooper.dna.species.handle_digestion(pooper)
	var/alert_at_145 = pooper.alerts["defecation"]
	CONFIG_SET(flag/shitting_enabled, old_shitting)
	TEST_ASSERT(istype(alert_at_120, /atom/movable/screen/alert/need_to_shit) && !istype(alert_at_120, /atom/movable/screen/alert/about_to_shit_myself), "At 120 the toilet alert is not the plain one")
	TEST_ASSERT(istype(alert_at_145, /atom/movable/screen/alert/about_to_shit_myself), "At 145 the toilet alert did not turn red")
	TEST_ASSERT(pooper.defecation >= 145, "The red alert came with an accident, the accident threshold must stay at 200")

/// Horror: mutacja dostępna w nosicielu, a Stłum opór odsuwa odzyskanie ciała przez nosiciela za chemikalia
/datum/unit_test/aquila_horror_host_control

/datum/unit_test/aquila_horror_host_control/Run()
	var/mob/living/simple_animal/horror/horror = allocate(/mob/living/simple_animal/horror, run_loc_floor_bottom_left)
	var/datum/action/innate/horror/mutate/mutate = horror.has_ability(/datum/action/innate/horror/mutate)
	TEST_ASSERT(mutate && ("infest" in mutate.category), "Mutation is not available inside a host")
	TEST_ASSERT(horror.has_ability(/datum/action/innate/horror/suppress_resistance), "A new horror has no Suppress resistance ability")

	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/captive_brain/brain = new(horror)
	brain.H = horror
	horror.host_brain = brain
	horror.victim = host
	horror.controlling = TRUE
	horror.chemicals = 100
	TEST_ASSERT(!horror.suppress_resistance(), "Suppressing worked while the host was not resisting")
	TEST_ASSERT(horror.chemicals == 100, "Suppressing without resistance used chemicals")

	brain.resist_timer = addtimer(CALLBACK(brain, TYPE_PROC_REF(/mob/living/captive_brain, return_control)), 20 SECONDS, TIMER_STOPPABLE)
	var/suppressed = horror.suppress_resistance()
	var/left = timeleft(brain.resist_timer)
	var/chems_after = horror.chemicals
	horror.chemicals = 10
	var/broke = horror.suppress_resistance()
	var/left_poor = timeleft(brain.resist_timer)

	deltimer(brain.resist_timer)
	brain.resist_timer = null
	horror.controlling = FALSE
	horror.victim = null
	horror.host_brain = null
	qdel(brain)
	TEST_ASSERT(suppressed, "Suppressing a resisting host failed")
	TEST_ASSERT(left >= 39 SECONDS, "Suppressing did not push the host's return back by 20 s (left [left])")
	TEST_ASSERT(chems_after == 50, "Suppressing did not cost 50 chemicals (left [chems_after])")
	TEST_ASSERT(!broke && left_poor == left, "Suppressing worked without enough chemicals")

/// Rakiety AI: w myśliwiec tylko z zasięgu dział, a po 8 s lotu gubią namiar na myśliwiec (okręt gonią dalej)
/datum/unit_test/aquila_missile_vs_fighter

/datum/unit_test/aquila_missile_vs_fighter/Run()
	var/was_enabled = GLOB.overmap_scale_enabled
	GLOB.overmap_scale_enabled = TRUE
	var/z = run_loc_floor_bottom_left.z
	var/obj/structure/overmap/small_craft/combat/light/ship = allocate(/obj/structure/overmap/small_craft/combat/light)
	var/obj/structure/overmap/small_craft/combat/light/fighter = allocate(/obj/structure/overmap/small_craft/combat/light)
	fighter.faction = "syndicate"
	ship.forceMove(locate(100, 60, z))
	var/datum/overmap_ship_weapon/guided = new /datum/overmap_ship_weapon/missile_launcher(ship)
	var/size_ok = guided.is_target_size_valid(fighter)
	fighter.forceMove(locate(100, 80, z)) // 20 pól
	var/near_ok = guided.is_valid_ai_target(fighter)
	fighter.forceMove(locate(100, 100, z)) // 40 pól
	var/far_ok = guided.is_valid_ai_target(fighter)
	qdel(guided)

	var/obj/item/projectile/guided_munition/missile/missile = new(run_loc_floor_bottom_left)
	missile.homing = TRUE
	missile.homing_target = fighter
	missile.check_fighter_lock()
	var/fighter_lock = missile.homing
	var/obj/structure/overmap/small_craft/combat/light/big = allocate(/obj/structure/overmap/small_craft/combat/light)
	big.mass = MASS_SMALL
	missile.homing = TRUE
	missile.homing_target = big
	missile.check_fighter_lock()
	var/ship_lock = missile.homing
	qdel(missile)
	GLOB.overmap_scale_enabled = was_enabled

	if(size_ok)
		TEST_ASSERT(near_ok, "A guided weapon refused a fighter 20 tiles away")
		TEST_ASSERT(!far_ok, "A guided weapon fired at a fighter 40 tiles away, beyond gun range")
	TEST_ASSERT(!fighter_lock, "A missile kept chasing a fighter after the lock time")
	TEST_ASSERT(ship_lock, "A missile lost its lock on a ship")

#undef TEST_ASSERT
