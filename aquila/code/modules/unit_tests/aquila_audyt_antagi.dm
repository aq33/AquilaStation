// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - audyt: noktowizja thralla działa, guz thralla zastępuje paciorek, macki rzucają do celu poza zasięgiem ręki
/datum/unit_test/aquila_audyt_antagi_darkspawn
	var/datum/team/darkspawn/old_team

/datum/unit_test/aquila_audyt_antagi_darkspawn/Destroy()
	if(GLOB.darkspawn_team != old_team)
		QDEL_NULL(GLOB.darkspawn_team)
		GLOB.darkspawn_team = old_team
	return ..()

/datum/unit_test/aquila_audyt_antagi_darkspawn/Run()
	old_team = GLOB.darkspawn_team
	GLOB.darkspawn_team = null
	var/turf/left = run_loc_floor_bottom_left

	var/mob/living/carbon/human/fighter = allocate(/mob/living/carbon/human, left)
	fighter.mind_initialize()
	var/datum/antagonist/darkspawn/antag = fighter.mind.add_antag_datum(/datum/antagonist/darkspawn)
	TEST_ASSERT(antag, "No darkspawn datum")

	// Zniewolona ofiara ma paciorek z Pożarcia woli: dostaje guz thralla zamiast niego
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(left, EAST))
	victim.mind_initialize()
	var/obj/item/organ/shadowtumor/bead = new
	bead.Insert(victim, FALSE, FALSE)
	TEST_ASSERT(victim.add_thrall(), "Could not thrall the victim")
	var/obj/item/organ/shadowtumor/tumor = get_shadow_tumor(victim)
	TEST_ASSERT(istype(tumor, /obj/item/organ/shadowtumor/thrall), "The thrall kept the plain shadow bead instead of a thrall tumor")
	TEST_ASSERT(QDELETED(bead), "The shadow bead was not removed")
	TEST_ASSERT_EQUAL(tumor.antag_team, antag.team, "The thrall tumor has no team")

	// Noktowizja nadaje cechę, którą czyta update_sight()
	var/datum/action/cooldown/spell/toggle/nightvision/nightvision = locate() in victim.actions
	TEST_ASSERT(nightvision, "Thrall has no nightvision")
	nightvision.Trigger()
	TEST_ASSERT(HAS_TRAIT(victim, TRAIT_TRUE_NIGHT_VISION), "Nightvision did not give TRAIT_TRUE_NIGHT_VISION")
	nightvision.reset_spell_cooldown()
	nightvision.Trigger()
	TEST_ASSERT(!HAS_TRAIT(victim, TRAIT_TRUE_NIGHT_VISION), "Nightvision stayed after turning it off")
	victim.remove_thrall()

	// Rzut mackami w cel trzy pola dalej (prawy klik poza zasięgiem ręki)
	var/obj/item/umbral_tendrils/tendrils = allocate(/obj/item/umbral_tendrils)
	fighter.put_in_active_hand(tendrils)
	var/mob/living/carbon/human/runner = allocate(/mob/living/carbon/human, locate(left.x + 3, left.y, left.z))
	antag.psi = 100
	TEST_ASSERT_EQUAL(tendrils.afterattack_secondary(runner, fighter, TRUE, null), SECONDARY_ATTACK_CALL_NORMAL, "Adjacent right click did not go the normal way")
	TEST_ASSERT_EQUAL(antag.psi, 100, "Psi spent by the adjacent afterattack")
	TEST_ASSERT_EQUAL(tendrils.afterattack_secondary(runner, fighter, FALSE, null), SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN, "Ranged right click did not throw the tendrils")
	TEST_ASSERT_EQUAL(antag.psi, 70, "Ranged tendril throw did not spend 30 Psi")

	fighter.mind.remove_antag_datum(/datum/antagonist/darkspawn)

/// AQUILA - audyt: moce z BP_CANT_USE_IN_TORPOR są zablokowane w torporze, żerowanie siłą działa też przy chwycie za szyję
/datum/unit_test/aquila_audyt_antagi_vampire

/datum/unit_test/aquila_audyt_antagi_vampire/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/mob/living/carbon/human/vampire_mob = allocate(/mob/living/carbon/human, left)
	vampire_mob.mind_initialize()
	var/datum/antagonist/vampire/vampire = new
	vampire.silent = TRUE
	vampire_mob.mind.add_antag_datum(vampire)

	var/datum/action/vampire/fortitude/fortitude = new
	fortitude.Grant(vampire_mob)
	TEST_ASSERT(fortitude.can_use(), "Fortitude cannot be used outside torpor")
	vampire.torpor_begin()
	TEST_ASSERT(vampire.is_in_torpor(), "torpor_begin() did not start torpor")
	TEST_ASSERT(!fortitude.can_use(), "Fortitude can be used in torpor")
	vampire.torpor_end()
	TEST_ASSERT(fortitude.can_use(), "Fortitude stayed blocked after torpor")
	fortitude.Remove(vampire_mob)
	qdel(fortitude)

	// Żerowanie siłą przy chwycie za szyję
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, get_step(left, EAST))
	var/datum/action/vampire/targeted/feed/feed = locate() in vampire.powers
	TEST_ASSERT(feed, "The vampire has no Feed")
	vampire_mob.set_combat_mode(TRUE)
	vampire_mob.start_pulling(victim)
	vampire_mob.setGrabState(GRAB_NECK)
	TEST_ASSERT(vampire_mob.pulling == victim && vampire_mob.grab_state == GRAB_NECK, "Could not set up a neck grab")
	feed.FireTargetedPower(victim)
	TEST_ASSERT(feed.currently_feeding, "Combat feed did not start with a neck grab")
	TEST_ASSERT(HAS_TRAIT_FROM(vampire_mob, TRAIT_IMMOBILIZED, TRAIT_FEED), "Combat feed with a neck grab did not hold the vampire in place")
	feed.deactivate_power()
	vampire_mob.stop_pulling() // przy sprzątaniu testu wampir znika przed ofiarą, a puszczanie chwytu bez rąk daje runtime

	vampire_mob.mind.remove_antag_datum(/datum/antagonist/vampire)

/// AQUILA - audyt: hulk ma cechę TRAIT_HULK (płaszcz cieni go odrzuca), ghul odzyskuje brakujące organy i kończyny
/datum/unit_test/aquila_audyt_antagi_heretic

/datum/unit_test/aquila_audyt_antagi_heretic/Run()
	var/mob/living/carbon/human/hulk = allocate(/mob/living/carbon/human)
	hulk.dna.add_mutation(HULK)
	TEST_ASSERT(hulk.dna.check_mutation(HULK), "Could not give the Hulk mutation")
	TEST_ASSERT(HAS_TRAIT(hulk, TRAIT_HULK), "The Hulk mutation does not give TRAIT_HULK")
	var/datum/action/cooldown/spell/shadow_cloak/cloak = new(hulk)
	TEST_ASSERT(!cloak.is_valid_target(hulk), "Shadow Cloak works on a hulk")
	hulk.dna.remove_mutation(HULK)
	TEST_ASSERT(!HAS_TRAIT(hulk, TRAIT_HULK), "TRAIT_HULK stayed after losing the mutation")
	TEST_ASSERT(cloak.is_valid_target(hulk), "Shadow Cloak does not work after losing the Hulk mutation")
	qdel(cloak)

	// Zwłoki bez serca i ręki wstają jako ghul z kompletem
	var/mob/living/carbon/human/corpse = allocate(/mob/living/carbon/human)
	var/obj/item/organ/heart/heart = corpse.getorganslot(ORGAN_SLOT_HEART)
	heart.Remove(corpse)
	qdel(heart)
	var/obj/item/bodypart/arm = corpse.get_bodypart(BODY_ZONE_L_ARM)
	arm.drop_limb()
	qdel(arm)
	corpse.death()
	TEST_ASSERT(corpse.apply_status_effect(/datum/status_effect/ghoul, 50), "Could not make a ghoul")
	TEST_ASSERT(corpse.stat != DEAD, "The ghoul is still dead")
	TEST_ASSERT(corpse.getorganslot(ORGAN_SLOT_HEART), "The ghoul got no heart back")
	TEST_ASSERT(corpse.get_bodypart(BODY_ZONE_L_ARM), "The ghoul got no arm back")
	corpse.remove_status_effect(/datum/status_effect/ghoul)

/// AQUILA - audyt: księga kultu rani i daje oddanie, puste ostrze dusz nie robi cienia z osoby spoza kultu
/datum/unit_test/aquila_audyt_antagi_bloodcult

/datum/unit_test/aquila_audyt_antagi_bloodcult/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/mob/living/carbon/human/cultist_mob = allocate(/mob/living/carbon/human, left)
	cultist_mob.mind_initialize()
	var/datum/antagonist/cult/new_cultist = new
	new_cultist.ignore_implant = TRUE
	var/datum/antagonist/cult/cultist = cultist_mob.mind.add_antag_datum(new_cultist)
	TEST_ASSERT(cultist, "Could not make a cultist")

	var/mob/living/carbon/human/crew = allocate(/mob/living/carbon/human, get_step(left, EAST))
	crew.mind_initialize()
	var/obj/item/tome/tome = allocate(/obj/item/tome)
	cultist_mob.put_in_active_hand(tome)
	var/devotion_before = cultist.devotion
	tome.attack(crew, cultist_mob)
	TEST_ASSERT(crew.getOrganLoss(ORGAN_SLOT_STOMACH) > 0, "The tome did not burn the stomach of a living target")
	TEST_ASSERT(cultist.devotion > devotion_before, "Hitting the crew with the tome gave no devotion")

	// Osoba spoza kultu i puste ostrze: zwykłe samobójstwo, bez cienia
	var/obj/item/melee/soulblade/blade = allocate(/obj/item/melee/soulblade, get_turf(crew))
	TEST_ASSERT_EQUAL(blade.suicide_act(crew), BRUTELOSS, "Soulblade suicide by a non-cultist was not a plain suicide")
	TEST_ASSERT(!blade.shade, "A non-cultist became a shade in the soulblade")
	TEST_ASSERT(crew.mind?.current == crew, "A non-cultist's mind left the body")

	cultist_mob.mind.remove_antag_datum(/datum/antagonist/cult)

/// AQUILA - audyt: zbudowane konstrukty kultu kończą rytuał „Po jednym z każdego”
/datum/unit_test/aquila_audyt_antagi_constructs
	var/datum/team/cult/used_team
	var/old_ritual

/datum/unit_test/aquila_audyt_antagi_constructs/Destroy()
	if(used_team)
		used_team.rituals[RITUAL_FACTION_1] = old_ritual
		used_team = null
	return ..()

/datum/unit_test/aquila_audyt_antagi_constructs/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/mob/living/carbon/human/cultist_mob = allocate(/mob/living/carbon/human, left)
	cultist_mob.mind_initialize()
	var/datum/antagonist/cult/new_cultist = new
	new_cultist.ignore_implant = TRUE
	var/datum/antagonist/cult/cultist = cultist_mob.mind.add_antag_datum(new_cultist, locate_team(/datum/team/cult))
	TEST_ASSERT(cultist, "Could not make a cultist")
	used_team = locate_team(/datum/team/cult)
	TEST_ASSERT(used_team && cultist.get_team() == used_team, "The cultist is not in the located cult team")
	old_ritual = used_team.rituals[RITUAL_FACTION_1]
	var/datum/bloodcult_ritual/produce_constructs/ritual = new
	ritual.init_ritual()
	used_team.rituals[RITUAL_FACTION_1] = ritual

	var/list/construct_types = list(
		/mob/living/simple_animal/hostile/construct/builder,
		/mob/living/simple_animal/hostile/construct/wraith,
		/mob/living/simple_animal/hostile/construct/armored,
	)
	var/list/constructs = list()
	for(var/construct_type in construct_types)
		TEST_ASSERT(used_team.rituals[RITUAL_FACTION_1] == ritual, "The ritual ended before all three constructs were built")
		var/mob/living/simple_animal/hostile/construct/construct = allocate(construct_type, left)
		construct.mind_initialize()
		var/datum/antagonist/cult/construct_cultist = new
		construct_cultist.ignore_implant = TRUE
		construct.mind.add_antag_datum(construct_cultist, used_team)
		construct.report_construct_built(cultist_mob)
		constructs += construct
	TEST_ASSERT(!used_team.rituals[RITUAL_FACTION_1], "Building an artificer, a wraith and a juggernaut did not complete the ritual")

	for(var/mob/living/simple_animal/hostile/construct/construct as anything in constructs)
		construct.mind.remove_antag_datum(/datum/antagonist/cult)
	cultist_mob.mind.remove_antag_datum(/datum/antagonist/cult)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
