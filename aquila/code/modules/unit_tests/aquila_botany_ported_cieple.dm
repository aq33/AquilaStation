// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - mutacje w piecu dzikiej flory ciepłych planet (cieple_flora.dm): kaktus popielny -> gwiaździsty kaktus
/// (dopisek przez /datum/plant_mutation_set/cieple), opuncja -> kaktus San Pedro -> pejotl. Nowa część pasuje do ciała rodzica.
/datum/unit_test/aquila_botany_ported_cieple
	/// Nasiona rodzica -> cecha owocu, w którą ma zmutować
	var/list/chains = list(
		/obj/item/plant_seeds/preset/cactus = /datum/plant_feature/fruit/star_cactus,
		/obj/item/plant_seeds/preset/prickly_pear = /datum/plant_feature/fruit/san_pedro,
		/obj/item/plant_seeds/preset/san_pedro = /datum/plant_feature/fruit/peyote,
	)

/datum/unit_test/aquila_botany_ported_cieple/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/list/failures = list()
	for(var/seed_type in chains)
		var/new_type = chains[seed_type]
		var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, origin)
		var/datum/component/planter/planter = tray.GetComponent(/datum/component/planter)
		planter.set_substrate(/datum/plant_subtrate/fairy)
		var/obj/item/plant_seeds/seeds = allocate(seed_type, origin)
		var/datum/component/plant/plant = seeds.plant(tray, null, TRUE, null, TRUE)
		if(!istype(plant))
			failures += "[seed_type]: nie da się posadzić"
			continue
		var/datum/plant_feature/fruit/fruit = locate() in plant.plant_features
		if(!(new_type in fruit.mutations))
			failures += "[fruit.type]: brak mutacji w piecu w [new_type]"
			continue
		var/datum/plant_feature/new_feature = plant.mutate_feature(fruit, new_type)
		if(!istype(new_feature, new_type))
			failures += "[seed_type]: mutacja w [new_type] nie pasuje do ciała i korzeni rodzica"
		qdel(tray)
	TEST_ASSERT(!length(failures), "Mutacje flory ciepłych planet z błędami:\n[jointext(failures, "\n")]")

#undef TEST_ASSERT
