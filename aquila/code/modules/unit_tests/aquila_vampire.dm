// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - wampir z BeeStation: nadanie i zdjęcie antagonisty, moce, klany, Sol, torpor, kołek i wasal bez runtime'ów
/datum/unit_test/aquila_vampire

/datum/unit_test/aquila_vampire/Run()
	var/runtimes_before = GLOB.total_runtimes

	var/mob/living/carbon/human/vampire_mob = allocate(/mob/living/carbon/human)
	vampire_mob.mind_initialize()
	var/datum/antagonist/vampire/vampire = new
	vampire.silent = TRUE
	vampire_mob.mind.add_antag_datum(vampire)

	TEST_ASSERT(IS_VAMPIRE(vampire_mob) == vampire, "IS_VAMPIRE does not see the vampire")
	TEST_ASSERT(HAS_TRAIT(vampire_mob.mind, TRAIT_VAMPIRE_ALIGNED), "The vampire's mind is not vampire aligned")
	TEST_ASSERT(HAS_TRAIT(vampire_mob, TRAIT_NOBREATH), "The vampire did not get its traits")
	TEST_ASSERT(length(vampire.objectives), "The vampire got no objectives")
	TEST_ASSERT(locate(/datum/action/vampire/targeted/feed) in vampire.powers, "The vampire did not get Feed")
	// Clan selection is granted on the first life tick while the vampire has no clan
	vampire.life_tick(vampire_mob, 1)
	TEST_ASSERT(locate(/datum/action/vampire/clanselect) in vampire.powers, "The vampire did not get the clan selection")
	for(var/datum/action/vampire/power as anything in vampire.powers)
		TEST_ASSERT(power.owner == vampire_mob, "[power.type] was not granted to the vampire")
		TEST_ASSERT(initial(power.abstract_type) != power.type, "The abstract power [power.type] was granted")

	// Every vampire power can be created and granted without runtimes
	for(var/power_type in valid_subtypesof(/datum/action/vampire))
		var/datum/action/vampire/power = new power_type
		power.Grant(vampire_mob)
		power.update_desc()
		power.update_buttons()
		power.Remove(vampire_mob)
		qdel(power)

	// The team HUD shows the vampire icon
	var/image/holder = vampire_mob.hud_list[ANTAG_HUD]
	TEST_ASSERT(holder.icon == 'aquila/icons/vampires/vampire_hud.dmi', "The vampire HUD icon file is [holder.icon]")
	TEST_ASSERT(holder.icon_state == vampire.antag_hud_name, "The vampire HUD icon is [holder.icon_state], not [vampire.antag_hud_name]")

	// Clan, rank up and the life tick
	vampire.my_clan = new /datum/vampire_clan/brujah(vampire)
	vampire.my_clan.on_apply()
	TEST_ASSERT(length(vampire.owned_disciplines), "The Brujah clan gave no disciplines")
	vampire.rank_up(1)
	vampire.life_tick(vampire_mob, 1)
	vampire.adjust_vitae(-50)
	vampire.update_blood()

	// Frenzy, Masquerade and the Sol debuff can be applied and removed
	vampire_mob.apply_status_effect(/datum/status_effect/frenzy)
	TEST_ASSERT(vampire.frenzied, "The frenzy status effect did not frenzy the vampire")
	vampire_mob.status_effect_examines()
	vampire_mob.remove_status_effect(/datum/status_effect/frenzy)
	TEST_ASSERT(!vampire.frenzied, "The vampire stayed frenzied")
	vampire_mob.apply_status_effect(/datum/status_effect/masquerade)
	TEST_ASSERT(HAS_TRAIT(vampire_mob, TRAIT_MASQUERADE), "The Masquerade status effect gave no TRAIT_MASQUERADE")
	vampire_mob.remove_status_effect(/datum/status_effect/masquerade)
	vampire_mob.apply_status_effect(/datum/status_effect/vampire_sol)
	vampire_mob.remove_status_effect(/datum/status_effect/vampire_sol)

	// Humanity is gained from petting animals
	var/old_humanity = vampire.humanity
	for(var/i in 1 to vampire.humanity_petting_goal)
		var/mob/living/simple_animal/pet/dog/corgi/pet = allocate(/mob/living/simple_animal/pet/dog/corgi)
		SEND_SIGNAL(vampire_mob, COMSIG_LIVING_PET_ANIMAL, pet)
	TEST_ASSERT(vampire.humanity > old_humanity, "Petting [vampire.humanity_petting_goal] animals gave no humanity")

	// Sol outside of a coffin hurts, inside a coffin puts the vampire in torpor
	vampire.sol_near_start()
	vampire.handle_sol()
	vampire.on_sol_end()
	var/obj/structure/closet/crate/coffin/coffin = allocate(/obj/structure/closet/crate/coffin)
	vampire_mob.forceMove(coffin)
	vampire_mob.adjustBruteLoss(30)
	vampire.check_begin_torpor()
	TEST_ASSERT(vampire.is_in_torpor(), "The hurt vampire did not enter torpor in a coffin")
	vampire_mob.fully_heal(TRUE)
	vampire.check_end_torpor()
	TEST_ASSERT(!vampire.is_in_torpor(), "The healed vampire did not leave torpor")
	vampire_mob.forceMove(run_loc_floor_bottom_left)

	// A real stake attack (combat mode, chest) embeds the stake and is detected
	var/mob/living/carbon/human/hunter = allocate(/mob/living/carbon/human)
	hunter.forceMove(get_step(vampire_mob, EAST) || run_loc_floor_bottom_left)
	var/obj/item/stake/stake = allocate(/obj/item/stake)
	hunter.put_in_active_hand(stake)
	hunter.set_combat_mode(TRUE)
	hunter.zone_selected = BODY_ZONE_CHEST
	stake.melee_attack_chain(hunter, vampire_mob)
	TEST_ASSERT(vampire.check_if_staked(), "A stake attack in combat mode at the chest did not stake the vampire")

	// Vassals
	var/mob/living/carbon/human/vassal_mob = allocate(/mob/living/carbon/human)
	vassal_mob.mind_initialize()
	vampire.make_vassal(vassal_mob)
	var/datum/antagonist/vassal/vassal = IS_VASSAL(vassal_mob)
	TEST_ASSERT(vassal, "make_vassal did not make a vassal")
	TEST_ASSERT(vassal.master == vampire, "The vassal has the wrong master")
	TEST_ASSERT(HAS_TRAIT(vassal_mob.mind, TRAIT_VAMPIRE_ALIGNED), "The vassal's mind is not vampire aligned")
	vassal_mob.mind.remove_antag_datum(/datum/antagonist/vassal)
	TEST_ASSERT(!IS_VASSAL(vassal_mob), "The vassal could not be freed")

	// Breaking the Masquerade changes the HUD icon
	vampire.break_masquerade()
	TEST_ASSERT(holder.icon_state == "masquerade_broken", "Breaking the Masquerade did not change the HUD icon")

	vampire_mob.mind.remove_antag_datum(/datum/antagonist/vampire)
	TEST_ASSERT(!IS_VAMPIRE(vampire_mob), "The vampire datum could not be removed")
	TEST_ASSERT(!HAS_TRAIT(vampire_mob, TRAIT_NOBREATH), "The vampire traits stayed after losing the datum")
	TEST_ASSERT(holder.icon == 'icons/mob/hud.dmi', "The vampire HUD icon stayed after losing the datum")

	// Final Death dusts a second vampire and frees it from its datum's life tick
	var/mob/living/carbon/human/doomed_mob = allocate(/mob/living/carbon/human)
	doomed_mob.mind_initialize()
	var/datum/antagonist/vampire/doomed = new
	doomed.silent = TRUE
	doomed_mob.mind.add_antag_datum(doomed)
	doomed.final_death()
	TEST_ASSERT(doomed.final_death, "final_death() did not mark the vampire as dead")

	TEST_ASSERT(GLOB.total_runtimes == runtimes_before, "[GLOB.total_runtimes - runtimes_before] runtimes while testing the vampire")

#undef TEST_ASSERT
