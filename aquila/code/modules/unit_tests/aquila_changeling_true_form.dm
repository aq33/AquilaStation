// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA: the changeling true form (Goon Horror Form) keeps the body and its gear, breaks cuffs, hits in both control modes,
/// devours, burns chemicals and goes back to a human (knocked down, or unconscious without chemicals)
/datum/unit_test/aquila_changeling_true_form

/datum/unit_test/aquila_changeling_true_form/Run()
	var/mob/living/carbon/human/ling_body = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	ling_body.mind_initialize()
	var/datum/antagonist/changeling/changeling = new
	changeling.give_objectives = FALSE
	ling_body.mind.add_antag_datum(changeling)
	TEST_ASSERT(changeling.all_powers[/datum/action/changeling/true_form], "The true form is not in the evolution shop")

	var/obj/item/clothing/under/color/grey/uniform = allocate(/obj/item/clothing/under/color/grey)
	TEST_ASSERT(ling_body.equip_to_slot_if_possible(uniform, ITEM_SLOT_ICLOTHING), "Could not dress the changeling")
	var/obj/item/pen/pen = allocate(/obj/item/pen)
	TEST_ASSERT(ling_body.equip_to_slot_if_possible(pen, ITEM_SLOT_LPOCKET), "Could not pocket the pen")
	var/obj/item/restraints/handcuffs/cuffs = new(ling_body)
	ling_body.handcuffed = cuffs
	ling_body.update_handcuffed()

	changeling.chem_charges = 75
	var/mob/living/simple_animal/hostile/changeling_true_form/form = changeling_enter_true_form(ling_body)
	TEST_ASSERT(istype(form), "No true form mob")
	allocated += form
	TEST_ASSERT_EQUAL(ling_body.loc, form, "The human body is not kept inside the form")
	TEST_ASSERT_EQUAL(changeling.owner.current, form, "The mind did not move to the form")
	TEST_ASSERT(!ling_body.handcuffed && QDELETED(cuffs), "The form did not break the handcuffs")
	TEST_ASSERT_EQUAL(ling_body.w_uniform, uniform, "The uniform was lost")
	TEST_ASSERT_EQUAL(ling_body.l_store, pen, "The pocketed item was lost")
	TEST_ASSERT(form.combat_mode_indicator, "The true form has no combat mode indicator")

	// Left click hits, right click (disarm intent) shoves, in both control modes
	for(var/legacy in list(FALSE, TRUE))
		var/mode = legacy ? "legacy intents" : "combat mode"
		set_test_controls(form, legacy)
		var/mob/living/carbon/human/target = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
		var/health_before = target.health
		if(legacy)
			form.a_intent_change(INTENT_HARM)
		else
			form.set_combat_mode(TRUE)
		form.next_click = 0
		form.next_move = 0
		form.ClickOn(target, "icon-x=16;icon-y=16;left=1;button=left")
		TEST_ASSERT(target.health < health_before, "[mode]: the true form did not hit")

		var/obj/item/pen/held = allocate(/obj/item/pen)
		target.put_in_hands(held)
		form.next_click = 0
		form.next_move = 0
		if(legacy)
			form.a_intent_change(INTENT_DISARM)
			form.ClickOn(target, "icon-x=16;icon-y=16;left=1;button=left")
		else
			form.ClickOn(target, "icon-x=16;icon-y=16;right=1;button=right")
		var/shoved = target.IsKnockdown() || !target.is_holding(held) || length(target.bodyparts) < 6
		TEST_ASSERT(shoved, "[mode]: the true form disarm did nothing")
		qdel(target)

	// Devour: new DNA, chemicals, the victim's gear stays on the floor
	var/turf/victim_spot = get_step(run_loc_floor_bottom_left, NORTH)
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, victim_spot)
	randomize_human(victim)
	victim.dna.update_dna_identity()
	var/obj/item/clothing/under/color/grey/victim_uniform = allocate(/obj/item/clothing/under/color/grey)
	victim.equip_to_slot_if_possible(victim_uniform, ITEM_SLOT_ICLOTHING)
	var/profiles_before = changeling.absorbedcount
	changeling.chem_charges = 40
	form.devour(victim)
	TEST_ASSERT(QDELETED(victim), "The devoured victim is still there")
	TEST_ASSERT_EQUAL(changeling.absorbedcount, profiles_before + 1, "Devouring did not add the DNA")
	TEST_ASSERT_EQUAL(changeling.chem_charges, 60, "Devouring did not give chemicals")
	TEST_ASSERT(!QDELETED(victim_uniform) && isturf(victim_uniform.loc), "The victim's gear was lost")

	// The form heals and burns chemicals
	form.adjustHealth(100)
	var/health_before_heal = form.health
	changeling.chem_charges = 50
	form.handle_true_form()
	TEST_ASSERT(form.health > health_before_heal, "The true form does not heal")
	TEST_ASSERT_EQUAL(changeling.chem_charges, 48, "The true form does not burn chemicals")

	// Going back with enough chemicals: knocked down, the gear is still on
	changeling.chem_charges = 40
	var/mob/living/carbon/human/back = form.revert_to_human()
	TEST_ASSERT_EQUAL(back, ling_body, "Reverting did not give the human body back")
	TEST_ASSERT(QDELETED(form), "The true form mob stayed after reverting")
	TEST_ASSERT(isturf(ling_body.loc), "The human body is not on the floor")
	TEST_ASSERT_EQUAL(changeling.owner.current, ling_body, "The mind did not come back to the human")
	TEST_ASSERT_EQUAL(changeling.chem_charges, 10, "Reverting did not cost chemicals")
	TEST_ASSERT(ling_body.IsKnockdown() && !ling_body.IsUnconscious(), "Reverting with chemicals did not just knock down")
	TEST_ASSERT(!(ling_body.status_flags & GODMODE) && !ling_body.notransform, "The human body kept the stasis flags")
	TEST_ASSERT_EQUAL(ling_body.w_uniform, uniform, "The uniform was lost after reverting")
	TEST_ASSERT_EQUAL(ling_body.l_store, pen, "The pocketed item was lost after reverting")

	// Running out of chemicals forces the way back and knocks the changeling out
	ling_body.SetKnockdown(0)
	form = changeling_enter_true_form(ling_body)
	TEST_ASSERT(istype(form), "No second true form")
	allocated += form
	changeling.chem_charges = 1
	form.handle_true_form()
	TEST_ASSERT(QDELETED(form) && isturf(ling_body.loc), "No forced revert without chemicals")
	TEST_ASSERT(ling_body.IsUnconscious(), "The forced revert did not knock the changeling out")
	TEST_ASSERT_EQUAL(changeling.chem_charges, 0, "Chemicals went below zero")

	// Killing the form kills the changeling, the body and its gear stay
	ling_body.SetUnconscious(0)
	form = changeling_enter_true_form(ling_body)
	TEST_ASSERT(istype(form), "No third true form")
	allocated += form
	form.death()
	TEST_ASSERT(isturf(ling_body.loc) && ling_body.stat == DEAD, "The body did not drop dead with the form")
	TEST_ASSERT_EQUAL(changeling.owner.current, ling_body, "The mind did not come back to the dead body")
	TEST_ASSERT_EQUAL(ling_body.w_uniform, uniform, "The uniform was lost when the form died")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
