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
	brain.H = null
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
	var/obj/structure/overmap/small_craft/combat/light/big = allocate(/obj/structure/overmap/small_craft/combat/light)
	big.mass = MASS_SMALL
	// Rakieta leci w okręt dłużej niż czas namiaru: dalej go goni
	missile.homing = TRUE
	missile.homing_target = big
	missile.check_fighter_lock()
	missile.fighter_lock_since = world.time - 20 SECONDS
	missile.check_fighter_lock()
	var/ship_lock = missile.homing
	// Przełącza się na myśliwiec w locie: czas liczy się od przełączenia, nie od wystrzału
	missile.homing_target = fighter
	missile.check_fighter_lock()
	var/fresh_fighter_lock = missile.homing
	missile.check_fighter_lock()
	var/still_locked = missile.homing
	missile.fighter_lock_since = world.time - 9 SECONDS
	missile.check_fighter_lock()
	var/fighter_lock = missile.homing
	// Łącze danych AI próbuje znów naprowadzić rakietę na ten sam myśliwiec: namiar już wygasł
	missile.set_homing_target(fighter)
	var/relocked = missile.homing
	// Nowa rakieta namierzona na myśliwiec przy wystrzale liczy czas od razu, nie od pierwszego sprawdzenia
	var/obj/item/projectile/guided_munition/missile/fresh = new(run_loc_floor_bottom_left)
	fresh.set_homing_target(fighter)
	var/fresh_since = fresh.fighter_lock_since
	var/fresh_time = world.time
	qdel(fresh)
	qdel(missile)
	GLOB.overmap_scale_enabled = was_enabled

	TEST_ASSERT(size_ok, "A missile launcher does not accept a fighter as a target")
	TEST_ASSERT(near_ok, "A guided weapon refused a fighter 20 tiles away")
	TEST_ASSERT(!far_ok, "A guided weapon fired at a fighter 40 tiles away, beyond gun range")
	TEST_ASSERT(fresh_fighter_lock && still_locked, "A missile that switched to a fighter lost the lock at once")
	TEST_ASSERT(!fighter_lock, "A missile kept chasing a fighter after the lock time")
	TEST_ASSERT(!relocked, "The AI datalink locked the missile back onto a fighter after the lock ran out")
	TEST_ASSERT(fresh_since == fresh_time, "Locking onto a fighter did not start the countdown at once")
	TEST_ASSERT(ship_lock, "A missile lost its lock on a ship")

/// Telewizorek w menu lobby odlicza do rundy: menu odświeża się w podsystemie, który działa w fazie lobby
/// (SSprocessing w niej nie działa), a odświeżenie zmienia odliczanie
/datum/unit_test/aquila_lobby_tv_processing

/// Menu bez prawdziwego klienta: tylko telewizorek z tekstem i start odświeżania jak w zwykłym menu
/datum/aq_lobby_hud/test_tv/New(mob/player)
	owner = player
	tv_text = new(null, src)
	elements += tv_text
	start_refreshing()

/datum/unit_test/aquila_lobby_tv_processing/Run()
	var/mob/living/carbon/human/viewer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/aq_lobby_hud/test_tv/hud = new(viewer)
	var/in_lobby_ss = (hud in SSlobby_hud.processing)
	var/old_state = SSticker.current_state
	var/old_time = SSticker.timeLeft
	SSticker.current_state = GAME_STATE_PREGAME
	SSticker.timeLeft = 120 SECONDS
	hud.process(1)
	var/first = hud.tv_text?.shown_text
	SSticker.timeLeft = 119 SECONDS
	hud.process(1)
	var/second = hud.tv_text?.shown_text
	SSticker.current_state = old_state
	SSticker.timeLeft = old_time
	STOP_PROCESSING(SSlobby_hud, hud)
	if(!QDELETED(hud))
		QDEL_NULL(hud.tv_text)
		hud.elements.Cut()
		hud.owner = null
	TEST_ASSERT(in_lobby_ss, "The lobby menu is not refreshed by SSlobby_hud")
	TEST_ASSERT(SSlobby_hud.runlevels & RUNLEVEL_LOBBY, "The lobby menu subsystem does not run in the lobby, the countdown would stand still")
	TEST_ASSERT(findtext(first, "120 s") && findtext(second, "119 s"), "The lobby TV did not follow the countdown ([first] -> [second])")

/// Wgniecenie czaszki: znika z głową odciętą od ciała i nie wraca przy obrocie; u małpy siedzi na jej głowie
/datum/unit_test/aquila_skull_dent_decap

/datum/unit_test/aquila_skull_dent_decap/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/item/bodypart/head = patient.get_bodypart(BODY_ZONE_HEAD)
	var/datum/wound/blunt/fracture/crack = new()
	crack.apply_wound(head, silent = TRUE)
	TEST_ASSERT(patient.aq_skull_dent, "A cracked skull shows no dent")
	head.drop_limb()
	TEST_ASSERT(!patient.aq_skull_dent, "The dent stayed on the body after the head was cut off")
	patient.setDir(NORTH)
	patient.setDir(SOUTH)
	TEST_ASSERT(!patient.aq_skull_dent, "Turning the headless body brought the dent back")
	head.attach_limb(patient)
	TEST_ASSERT(patient.aq_skull_dent, "The dent did not come back with the reattached cracked head")

	var/mob/living/carbon/monkey/monkey = allocate(/mob/living/carbon/monkey, run_loc_floor_bottom_left)
	var/list/head_offset = monkey.dna?.species?.offset_features?[OFFSET_HEAD]
	var/datum/wound/blunt/fracture/monkey_crack = new()
	monkey_crack.apply_wound(monkey.get_bodypart(BODY_ZONE_HEAD), silent = TRUE)
	monkey.setDir(SOUTH)
	TEST_ASSERT(monkey.aq_skull_dent, "A monkey with a cracked skull shows no dent")
	if(length(head_offset))
		TEST_ASSERT(monkey.aq_skull_dent.pixel_y == head_offset[2], "The monkey dent ignores the head offset ([monkey.aq_skull_dent.pixel_y] instead of [head_offset[2]])")

#undef TEST_ASSERT
