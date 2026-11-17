// Kopie makr z code/modules/unit_tests/_unit_tests.dm (tam są #undef na końcu)
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

// AQUILA - regresje cykli referencji, przez które obiekty nie zwalniały się po qdel. W CI każde takie
// twarde usunięcie odpalało ~3-minutowe szukanie referencji, które zamraża świat (część testów 2/3 trwała do 35 min).

/// Usunięty gang zabiera rolę członkom i usuwa swój cel (gang -> członek -> rola -> gang, gang -> cel -> gang)
/datum/unit_test/aquila_gc_gang_team
	var/list/saved_possible
	var/list/saved_gangs
	var/datum/team/gang/gang

/datum/unit_test/aquila_gc_gang_team/Run()
	saved_possible = GLOB.possible_gangs.Copy()
	saved_gangs = GLOB.gangs.Copy()

	var/mob/living/carbon/human/boss = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	boss.mind_initialize()
	var/datum/antagonist/gang/boss/boss_datum = boss.mind.add_antag_datum(/datum/antagonist/gang/boss)
	gang = boss_datum?.gang
	TEST_ASSERT(gang, "The gang boss got no gang")
	var/mob/living/carbon/human/member = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	member.mind_initialize()
	member.mind.add_antag_datum(/datum/antagonist/gang, gang)
	var/datum/objective/objective = locate(/datum/objective/gang_dominate) in gang.objectives
	TEST_ASSERT(objective, "The gang got no dominator objective")

	qdel(gang)
	TEST_ASSERT(!boss.mind.has_antag_datum(/datum/antagonist/gang) && !member.mind.has_antag_datum(/datum/antagonist/gang), "Members of a deleted gang kept their gang role, which still points at the gang")
	TEST_ASSERT(!length(gang.members) && !length(gang.leaders), "A deleted gang still lists its members")
	TEST_ASSERT(!length(gang.objectives) && QDELETED(objective), "A deleted gang kept its objective, which still points at the gang")

/// Sprząta także po nieudanej asercji: gang z puli i lista gangów wracają do stanu sprzed testu
/datum/unit_test/aquila_gc_gang_team/Destroy()
	if(gang && !QDELETED(gang))
		qdel(gang)
	gang = null
	if(saved_possible)
		GLOB.possible_gangs = saved_possible
	if(saved_gangs)
		GLOB.gangs = saved_gangs
	return ..()

/// Każda usunięta drużyna usuwa swoje cele (team.objectives -> cel -> team), także gdy ma ich kilka
/datum/unit_test/aquila_gc_team_objectives

/datum/unit_test/aquila_gc_team_objectives/Run()
	var/datum/team/team = new
	var/list/datum/objective/objectives = list()
	for(var/i in 1 to 3)
		var/datum/objective/objective = new
		objective.team = team
		team.objectives += objective
		objectives += objective
	team.add_member(new /datum/mind("aquila_gc_team_member"))

	qdel(team)
	for(var/datum/objective/objective as anything in objectives)
		TEST_ASSERT(QDELETED(objective), "A deleted team left one of its objectives alive, still pointing at the team")
	TEST_ASSERT(!length(team.objectives), "A deleted team still lists its objectives")
	TEST_ASSERT(!length(team.members), "A deleted team still lists its members")

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
	var/obj/structure/overmap/small_craft/combat/light/fighter

/datum/unit_test/aquila_gc_fighter_loadout/Run()
	var/turf/center = SSmapping.get_station_center()
	TEST_ASSERT(center, "No station center")
	fighter = new(center)
	var/datum/component/ship_loadout/loadout = fighter.loadout
	TEST_ASSERT(loadout?.holder == fighter, "The light fighter has no loadout component")
	var/obj/structure/overmap/home = fighter.get_overmap()
	TEST_ASSERT(home && (fighter in home.overmaps_in_ship), "A fighter spawned in the hangar is not on its ship's list, the test cannot check the cleanup")
	TEST_ASSERT(fighter.last_overmap == home, "A fighter spawned in the hangar does not remember its ship in last_overmap")

	qdel(fighter)
	TEST_ASSERT(!(fighter in home.overmaps_in_ship), "The deleted fighter stayed on its ship's overmaps_in_ship list")
	TEST_ASSERT(QDELETED(loadout), "The loadout component outlived its fighter")
	TEST_ASSERT(isnull(loadout.holder), "The deleted loadout component still points at its fighter")
	TEST_ASSERT(isnull(fighter.loadout), "The deleted fighter still points at its loadout component")
	TEST_ASSERT(!(loadout in SSobj.processing), "The deleted loadout component is still processing")

/// Po nieudanej asercji myśliwiec nie zostaje na liście okrętu (fighter_docking bierze pierwszy myśliwiec z tej listy)
/datum/unit_test/aquila_gc_fighter_loadout/Destroy()
	QDEL_NULL(fighter)
	return ..()

/// Lista zmiennych wbudowanych GLOB nie trzyma listy vars tymczasowego kontrolera (a przez nią samego kontrolera)
/datum/unit_test/aquila_gc_global_vars_controller

/datum/unit_test/aquila_gc_global_vars_controller/Run()
	TEST_ASSERT("vars" in GLOB.gvars_datum_in_built_vars, "Built-in var names are missing from GLOB")
	TEST_ASSERT(isnull(GLOB.gvars_datum_in_built_vars["vars"]), "GLOB keeps the vars list of the throwaway controller, so it is never collected")

#undef TEST_ASSERT
