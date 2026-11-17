// Kopie makr z code/modules/unit_tests/_unit_tests.dm (tam są #undef na końcu)
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

// AQUILA - regresje cykli referencji, przez które obiekty nie zwalniały się po qdel. W CI każde takie
// twarde usunięcie odpalało ~3-minutowe szukanie referencji, które zamraża świat (część testów 2/3 trwała do 35 min).

/// Usunięty gang zabiera rolę członkom i usuwa swój cel (gang -> członek -> rola -> gang, gang -> cel -> gang)
/datum/unit_test/aquila_gc_gang_team

/datum/unit_test/aquila_gc_gang_team/Run()
	var/list/saved_possible = GLOB.possible_gangs.Copy()
	var/list/saved_gangs = GLOB.gangs.Copy()

	var/mob/living/carbon/human/boss = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	boss.mind_initialize()
	var/datum/antagonist/gang/boss/boss_datum = boss.mind.add_antag_datum(/datum/antagonist/gang/boss)
	var/datum/team/gang/gang = boss_datum.gang
	var/mob/living/carbon/human/member = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	member.mind_initialize()
	member.mind.add_antag_datum(/datum/antagonist/gang, gang)
	var/datum/objective/objective = locate(/datum/objective/gang_dominate) in gang.objectives
	TEST_ASSERT(gang && objective, "The gang boss got no gang or no dominator objective")

	qdel(gang)
	var/failure
	if(boss.mind.has_antag_datum(/datum/antagonist/gang) || member.mind.has_antag_datum(/datum/antagonist/gang))
		failure = "Members of a deleted gang kept their gang role, which still points at the gang"
	else if(length(gang.members) || length(gang.leaders))
		failure = "A deleted gang still lists its members"
	else if(length(gang.objectives) || !QDELETED(objective))
		failure = "A deleted gang kept its objective, which still points at the gang"

	GLOB.possible_gangs = saved_possible
	GLOB.gangs = saved_gangs
	TEST_ASSERT(!failure, failure)

/// Rola usunięta razem z umysłem (bez on_removal) zabiera przycisk „Informacje o roli”, który trzymał ją w `target`
/datum/unit_test/aquila_gc_antag_info_button

/datum/unit_test/aquila_gc_antag_info_button/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	body.mind_initialize()
	var/datum/mind/mind = body.mind
	var/datum/antagonist/custom/role = mind.add_antag_datum(/datum/antagonist/custom)
	var/datum/action/antag_info/button = role.info_button_ref?.resolve()
	TEST_ASSERT(button, "The custom role got no info button")

	body.mind = null // jak przy nowej duszy w ciele: umysł odchodzi, ciało zostaje
	qdel(mind)
	TEST_ASSERT(QDELETED(role), "The role was not deleted with its mind")
	TEST_ASSERT(QDELETED(button), "The info button outlived its deleted role")
	TEST_ASSERT(!(button in body.actions), "The body kept the info button of a deleted role")

/// Myśliwiec i jego komponent wyposażenia trzymały się nawzajem (`loadout` i `holder`) po qdel,
/// a myśliwiec z hangaru zostawał na liście `overmaps_in_ship` okrętu
/datum/unit_test/aquila_gc_fighter_loadout

/datum/unit_test/aquila_gc_fighter_loadout/Run()
	var/turf/center = SSmapping.get_station_center()
	TEST_ASSERT(center, "No station center")
	var/obj/structure/overmap/small_craft/combat/light/fighter = new(center)
	var/datum/component/ship_loadout/loadout = fighter.loadout
	TEST_ASSERT(loadout?.holder == fighter, "The light fighter has no loadout component")
	var/obj/structure/overmap/home = fighter.get_overmap()
	TEST_ASSERT(home && (fighter in home.overmaps_in_ship), "A fighter spawned in the hangar is not on its ship's list, the test cannot check the cleanup")

	qdel(fighter)
	TEST_ASSERT(!(fighter in home.overmaps_in_ship), "The deleted fighter stayed on its ship's overmaps_in_ship list")
	TEST_ASSERT(QDELETED(loadout), "The loadout component outlived its fighter")
	TEST_ASSERT(isnull(loadout.holder), "The deleted loadout component still points at its fighter")
	TEST_ASSERT(isnull(fighter.loadout), "The deleted fighter still points at its loadout component")
	TEST_ASSERT(!(loadout in SSobj.processing), "The deleted loadout component is still processing")

/// Lista zmiennych wbudowanych GLOB nie trzyma listy vars tymczasowego kontrolera (a przez nią samego kontrolera)
/datum/unit_test/aquila_gc_global_vars_controller

/datum/unit_test/aquila_gc_global_vars_controller/Run()
	TEST_ASSERT("vars" in GLOB.gvars_datum_in_built_vars, "Built-in var names are missing from GLOB")
	TEST_ASSERT(isnull(GLOB.gvars_datum_in_built_vars["vars"]), "GLOB keeps the vars list of the throwaway controller, so it is never collected")

#undef TEST_ASSERT
