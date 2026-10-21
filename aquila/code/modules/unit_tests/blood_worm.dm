// Makra asercji z upstreamu są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc ten test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - krwawe robaki: jedzenie krwi, nosiciel, kokon, plucie, tester, mięsożerna krew, szpary pod drzwiami
/datum/unit_test/blood_worm

/datum/unit_test/blood_worm/Run()
	var/runtimes_before = GLOB.total_runtimes
	var/turf/left = run_loc_floor_bottom_left
	var/turf/right = get_step(left, EAST)

	TEST_ASSERT(ispath(/datum/round_event_control/blood_worm), "No blood worm event")
	TEST_ASSERT(ispath(/datum/dynamic_ruleset/midround/from_ghosts/blood_worms), "No blood worm midround ruleset")
	TEST_ASSERT(ispath(/datum/dynamic_ruleset/roundstart/blood_worm), "No blood worm roundstart ruleset")
	find_blood_worm_vent_spawns()

	var/mob/living/simple_animal/hostile/blood_worm/hatchling/worm = allocate(/mob/living/simple_animal/hostile/blood_worm/hatchling, left)
	TEST_ASSERT(worm.leech_action && (worm.leech_action in worm.actions), "Hatchling has no leech action")
	TEST_ASSERT(worm.invade_action && (worm.invade_action in worm.actions), "Hatchling has no invade action")
	TEST_ASSERT(worm.cocoon_action && (worm.cocoon_action in worm.actions), "Hatchling has no cocoon action")
	TEST_ASSERT(!(worm.eject_action in worm.actions), "Hatchling has host actions outside of a host")
	TEST_ASSERT(HAS_TRAIT(worm, TRAIT_BLOOD_HUD), "Blood worm has no blood HUD")
	TEST_ASSERT(worm.ventcrawler, "Hatchling cannot ventcrawl")
	TEST_ASSERT(worm.GetComponent(/datum/component/slide_under_doors), "Hatchling cannot slide under doors")

	// Krew: zwykła i syntetyczna
	worm.adjustBruteLoss(20)
	worm.consume_blood(100, 0)
	TEST_ASSERT_EQUAL(worm.consumed_normal_blood, 100, "Normal blood was not counted")
	TEST_ASSERT(worm.health > worm.maxHealth - 20, "Consumed blood did not heal the worm")
	worm.consume_blood(100, 1)
	TEST_ASSERT_EQUAL(round(worm.consumed_synth_blood), 70, "Synthetic blood efficiency is wrong")

	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, right)
	TEST_ASSERT_EQUAL(victim.get_blood_synth_content(), 0, "Human blood is synthetic")
	var/mob/living/carbon/monkey/monkey = allocate(/mob/living/carbon/monkey, left)
	TEST_ASSERT_EQUAL(monkey.get_blood_synth_content(), 1, "Monkey blood is not synthetic")
	var/obj/item/reagent_containers/blood/pack = allocate(/obj/item/reagent_containers/blood/OMinus, left)
	var/datum/reagent/blood/pack_blood = pack.reagents.has_reagent(/datum/reagent/blood)
	TEST_ASSERT_EQUAL(pack_blood?.data?[BLOOD_DATA_SYNTH_CONTENT], 0.5, "Blood pack blood is not half synthetic")

	// Wnikanie w zwłoki
	var/datum/action/cooldown/spell/blood_worm/invade/invade = worm.invade_action
	TEST_ASSERT(!invade.invade_check(worm, victim), "Blood worm could invade a living human")
	victim.death()
	TEST_ASSERT(invade.invade_check(worm, victim), "Blood worm could not invade a corpse")
	var/consumed_before = worm.get_consumed_blood()
	worm.enter_host(victim, silent = TRUE)
	TEST_ASSERT_EQUAL(worm.host, victim, "Blood worm did not get a host")
	TEST_ASSERT_EQUAL(worm.loc, victim, "Blood worm is not inside its host")
	TEST_ASSERT(HAS_TRAIT(victim, TRAIT_BLOOD_WORM_HOST), "Host has no host trait")
	TEST_ASSERT(worm.get_consumed_blood() >= consumed_before + BLOOD_VOLUME_NORMAL - 1, "Host blood did not count towards growth")
	// Krew nosiciela + zdrowie robaka, przycięte do maksimum robaka: robak w pełnych zwłokach jest zdrowy
	TEST_ASSERT_EQUAL(round(victim.blood_volume), round(worm.maxHealth * BLOOD_WORM_HEALTH_TO_BLOOD), "Host blood was not capped to worm maximum")
	TEST_ASSERT_EQUAL(round(worm.health), worm.maxHealth, "Worm did not heal from a full corpse")
	TEST_ASSERT(victim.get_shown_blood_volume() <= BLOOD_VOLUME_NORMAL + 1, "Host blood looks abnormal on scanners")
	TEST_ASSERT(worm.eject_action in worm.actions, "Blood worm has no host actions in a dead host")
	TEST_ASSERT(!(worm.leech_action in worm.actions), "Blood worm kept innate actions in a host")

	// Zdrowie robaka to krew nosiciela
	victim.blood_volume = worm.maxHealth * BLOOD_WORM_HEALTH_TO_BLOOD * 0.5
	worm.sync_health()
	TEST_ASSERT_EQUAL(round(worm.health), round(worm.maxHealth * 0.5), "Worm health did not follow host blood")
	var/health_before = worm.health
	worm.adjustBruteLoss(30)
	TEST_ASSERT_EQUAL(worm.health, health_before, "Worm took direct damage inside a host")

	// Wyjście z nosiciela zabiera całą krew
	worm.leave_host()
	TEST_ASSERT(!worm.host, "Blood worm still has a host after leaving")
	TEST_ASSERT_EQUAL(worm.loc, right, "Blood worm did not drop out of the host")
	TEST_ASSERT_EQUAL(victim.blood_volume, 0, "Blood worm left blood in the host")
	TEST_ASSERT(!HAS_TRAIT(victim, TRAIT_BLOOD_WORM_HOST), "Old host kept the host trait")
	TEST_ASSERT(worm.leech_action in worm.actions, "Blood worm did not get innate actions back")
	worm.finish_leaving()
	worm.forceMove(left)

	// Dojrzewanie w kokonie
	var/datum/action/cooldown/spell/blood_worm/cocoon/cocoon_action = worm.cocoon_action
	worm.consumed_normal_blood = cocoon_action.total_blood_required
	TEST_ASSERT(cocoon_action.check_consumed_blood(), "Enough blood did not allow maturing")
	var/old_id = worm.id_number
	cocoon_action.cocoon = new cocoon_action.cocoon_type(left)
	worm.forceMove(cocoon_action.cocoon)
	cocoon_action.finalize()
	TEST_ASSERT(QDELETED(worm), "Old hatchling was not deleted after maturing")
	var/mob/living/simple_animal/hostile/blood_worm/juvenile/juvenile = locate() in left
	TEST_ASSERT(juvenile, "Cocoon did not hatch a juvenile")
	TEST_ASSERT_EQUAL(juvenile.id_number, old_id, "Juvenile lost the worm number")
	TEST_ASSERT(juvenile.get_consumed_blood() >= cocoon_action.total_blood_required, "Juvenile lost growth progress")
	TEST_ASSERT(juvenile.spit_action, "Juvenile cannot spit")
	TEST_ASSERT(!locate(/obj/structure/blood_worm_cocoon) in left, "Cocoon was not removed")

	// Plucie kosztuje zdrowie
	var/datum/action/cooldown/spell/blood_worm/spit/spit = juvenile.spit_action
	var/juvenile_health = juvenile.health
	spit.spit(get_step(right, EAST), null, spit.projectile_type)
	TEST_ASSERT(juvenile.health < juvenile_health, "Spitting blood did not cost health")

	// Szpary pod drzwiami
	var/obj/machinery/door/poddoor/door = allocate(/obj/machinery/door/poddoor, right)
	door.density = TRUE
	var/datum/component/slide_under_doors/sliding = juvenile.GetComponent(/datum/component/slide_under_doors)
	TEST_ASSERT(sliding.can_slide_under_door(juvenile, door), "Juvenile cannot slide under a closed door")
	sliding.slide_under_door(juvenile, door)
	TEST_ASSERT_EQUAL(juvenile.loc, door, "Juvenile did not slide under the door")
	sliding.slide_out_from_under_door()
	TEST_ASSERT(isturf(juvenile.loc), "Juvenile did not slide out from under the door")
	for(var/obj/effect/temp_visual/visual in world)
		if(get_turf(visual) == right || get_turf(visual) == left)
			qdel(visual)

	// Tester hemopasożytów
	var/mob/living/carbon/human/doctor = allocate(/mob/living/carbon/human, left)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, right)
	var/obj/item/blood_worm_tester/tester = allocate(/obj/item/blood_worm_tester, left)
	tester.attack(patient, doctor)
	TEST_ASSERT(tester.spent, "Tester was not spent after use")

	// Mięsożerna krew uczy się DNA i zjada krew w pojemniku
	var/obj/item/reagent_containers/glass/beaker/large/beaker = allocate(/obj/item/reagent_containers/glass/beaker/large, left)
	beaker.reagents.add_reagent(/datum/reagent/toxin/carnivorousblood, 10)
	beaker.reagents.add_reagent(/datum/reagent/blood, 10, list("blood_DNA" = "TESTDNA", "blood_type" = "O-"))
	var/datum/reagent/toxin/carnivorousblood/hungry_blood = beaker.reagents.has_reagent(/datum/reagent/toxin/carnivorousblood)
	TEST_ASSERT(hungry_blood, "Carnivorous blood disappeared")
	TEST_ASSERT("TESTDNA" in hungry_blood.data, "Carnivorous blood did not learn the DNA")
	TEST_ASSERT(!beaker.reagents.has_reagent(/datum/reagent/blood), "Carnivorous blood did not eat the blood")
	// Odwrotna kolejność: mięsożerna krew wlana do krwi (jak ze strzykawki)
	var/obj/item/reagent_containers/glass/beaker/large/blood_beaker = allocate(/obj/item/reagent_containers/glass/beaker/large, left)
	blood_beaker.reagents.add_reagent(/datum/reagent/blood, 10, list("blood_DNA" = "OTHERDNA", "blood_type" = "O-"))
	beaker.reagents.trans_to(blood_beaker, 5)
	var/datum/reagent/toxin/carnivorousblood/poured_blood = blood_beaker.reagents.has_reagent(/datum/reagent/toxin/carnivorousblood)
	TEST_ASSERT(poured_blood && ("OTHERDNA" in poured_blood.data) && ("TESTDNA" in poured_blood.data), "Poured carnivorous blood did not learn the DNA")

	qdel(juvenile)
	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "Blood worm test caused runtimes")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
