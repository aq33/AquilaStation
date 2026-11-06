// Makra asercji z upstreamu są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc ten test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - regresja: zablokowany chwyt (Ctrl+klik) nie może ciągnąć celu
/datum/unit_test/aquila_review_blocked_grab

/datum/unit_test/aquila_review_blocked_grab/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	attacker.mind_initialize()
	ADD_TRAIT(victim, TRAIT_ONEWAYROAD, "aquila_review_test")
	victim.CtrlClick(attacker)
	TEST_ASSERT(attacker.pulling != victim, "A grab blocked by TRAIT_ONEWAYROAD still pulled the target")
	TEST_ASSERT(attacker.next_move > world.time, "A blocked grab did not set the click cooldown")

/// AQUILA - regresja: prawy przycisk strzykawką na podgrzewaczu pobiera z zlewki, a maszyna zapisuje użycie prawym przyciskiem
/datum/unit_test/aquila_review_chem_heater_syringe

/datum/unit_test/aquila_review_chem_heater_syringe/Run()
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/machinery/chem_heater/heater = allocate(/obj/machinery/chem_heater, run_loc_floor_bottom_left)
	var/obj/item/reagent_containers/glass/beaker/beaker = allocate(/obj/item/reagent_containers/glass/beaker)
	beaker.reagents.add_reagent(/datum/reagent/water, 30)
	beaker.forceMove(heater)
	heater.replace_beaker(null, beaker)
	var/obj/item/reagent_containers/syringe/syringe = allocate(/obj/item/reagent_containers/syringe)

	heater.attackby(syringe, user, "right=1")
	TEST_ASSERT(syringe.reagents.total_volume > 0, "Right clicking the heater with a syringe did not draw from the beaker")
	var/drawn = syringe.reagents.total_volume
	heater.attackby(syringe, user, "")
	TEST_ASSERT(syringe.reagents.total_volume < drawn, "Left clicking the heater with a syringe did not inject into the beaker")

	heater.last_used_time = 0
	heater.attackby_secondary(syringe, user, "right=1")
	TEST_ASSERT(heater.last_used_time == world.time, "attackby_secondary on a machine did not update last_used_time")

/// AQUILA - regresja: dwóch chirurgów w jednej strefie, pierwszy kończy, a operacja drugiego dalej jest widoczna
/datum/unit_test/aquila_review_ongoing_operations

/datum/unit_test/aquila_review_ongoing_operations/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/first = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/second = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/datum/surgery_operation/retract = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/retract_skin]
	var/datum/surgery_operation/incise = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/incise_skin]

	patient.add_ongoing_operation(BODY_ZONE_CHEST, first, incise)
	patient.add_ongoing_operation(BODY_ZONE_CHEST, second, retract)
	patient.remove_ongoing_operation(BODY_ZONE_CHEST, first)
	TEST_ASSERT(LAZYACCESS(patient.ongoing_operations, BODY_ZONE_CHEST) == retract, "The first surgeon finishing cleared the second surgeon's ongoing operation")
	patient.remove_ongoing_operation(BODY_ZONE_CHEST, second)
	TEST_ASSERT(isnull(LAZYACCESS(patient.ongoing_operations, BODY_ZONE_CHEST)), "The ongoing operation stayed after both surgeons finished")
	TEST_ASSERT(!LAZYLEN(patient.ongoing_operation_surgeons), "Surgeons stayed tracked after finishing")

/// AQUILA - regresja: stół operacyjny łapie pacjenta przy wejściu i puszcza przy zejściu (TRAIT_NO_BLEEDING nie zostaje)
/datum/unit_test/aquila_review_optable_patient

/datum/unit_test/aquila_review_optable_patient/Run()
	var/obj/structure/table/optable/table = allocate(/obj/structure/table/optable, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, NORTH))
	patient.set_resting(TRUE, TRUE)

	patient.forceMove(table.loc)
	TEST_ASSERT(table.patient == patient, "Lying down on the operating table did not make you its patient")
	TEST_ASSERT(HAS_TRAIT_FROM(patient, TRAIT_NO_BLEEDING, TABLE_TRAIT), "A patient lying on the operating table still bleeds")

	patient.forceMove(get_step(table, NORTH))
	TEST_ASSERT(isnull(table.patient), "The operating table kept a patient who left it")
	TEST_ASSERT(!HAS_TRAIT_FROM(patient, TRAIT_NO_BLEEDING, TABLE_TRAIT), "TRAIT_NO_BLEEDING stayed after leaving the operating table")
	patient.set_resting(FALSE, TRUE)
	patient.set_resting(TRUE, TRUE)
	TEST_ASSERT(!HAS_TRAIT_FROM(patient, TRAIT_NO_BLEEDING, TABLE_TRAIT), "Lying down away from the table gave TRAIT_NO_BLEEDING")

/// AQUILA - regresja: nowa dusza w ciele gracza z DNR dostaje czysty umysł, bez antagonisty i celów poprzedniego gracza
/datum/unit_test/aquila_review_ghostrole_fresh_mind

/datum/unit_test/aquila_review_ghostrole_fresh_mind/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	body.mind_initialize()
	var/datum/mind/old_mind = body.mind
	old_mind.key = "aquila_review_dnr"
	old_mind.assigned_role = JOB_NAME_MEDICALDOCTOR
	old_mind.store_memory("Kod do sejfu: 1234")
	old_mind.add_antag_datum(/datum/antagonist/custom)
	var/datum/component/ghostrole_on_revive/ghostrole = body.AddComponent(/datum/component/ghostrole_on_revive)

	ghostrole.give_fresh_mind(body)
	TEST_ASSERT(body.mind && body.mind != old_mind, "The new soul got the old player's mind")
	TEST_ASSERT(!body.mind.has_antag_datum(/datum/antagonist), "The new soul inherited the old player's antagonist")
	TEST_ASSERT(!body.mind.memory, "The new soul inherited the old player's memories")
	TEST_ASSERT(body.mind.assigned_role == JOB_NAME_MEDICALDOCTOR, "The new soul lost the body's job")
	TEST_ASSERT(isnull(old_mind.current), "The old mind still points at the body")
	qdel(old_mind)

/// AQUILA - regresja: popchnięcie (prawy przycisk) zgłaszane relay_attackers raz i jako popchnięcie, w combat mode i bez
/datum/unit_test/aquila_review_relay_shove
	var/relayed = 0
	var/last_flags = 0

/datum/unit_test/aquila_review_relay_shove/proc/on_attacked(atom/source, atom/attacker, attack_flags, direction)
	SIGNAL_HANDLER
	relayed++
	last_flags = attack_flags

/datum/unit_test/aquila_review_relay_shove/Run()
	var/mob/living/carbon/human/attacker = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	victim.AddElement(/datum/element/relay_attackers)
	RegisterSignal(victim, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked))

	for(var/combat in list(FALSE, TRUE))
		attacker.set_combat_mode(combat)
		relayed = 0
		last_flags = 0
		victim.SetAllImmobility(0)
		victim.forceMove(get_step(attacker, EAST))
		attacker.UnarmedAttack(victim, TRUE, list(RIGHT_CLICK = "1", "button" = RIGHT_CLICK))
		TEST_ASSERT(relayed == 1, "A shove (combat mode [combat]) was relayed [relayed] times")
		// ATTACKER_SHOVING (1<<1) i ATTACKER_DAMAGING_ATTACK (1<<2) są w heretic/_compat/sacrifice.dm, dołączanym po testach
		TEST_ASSERT(last_flags & (1<<1), "A shove (combat mode [combat]) was not relayed as a shove")
		TEST_ASSERT(!(last_flags & (1<<2)), "A shove (combat mode [combat]) was relayed as a damaging attack")

	UnregisterSignal(victim, COMSIG_ATOM_WAS_ATTACKED)

#undef TEST_ASSERT
