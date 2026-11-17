// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Opróżnia kapsułę i ją usuwa. Destroy kapsuły wypuszcza jej gaz na pole, a pola testowe są wspólne dla kolejnych testów:
/// 50 moli plazmy albo N2O w 150 °C czy −90 °C przerywało akcje człowieka w późniejszych testach (np. monke_ingame)
/proc/aquila_test_drop_pod(obj/machinery/atmospherics/components/binary/xenoflora_pod/pod)
	if(QDELETED(pod))
		return
	pod.internal_gases.remove(pod.internal_gases.total_moles())
	qdel(pod)

/// Przywraca polom testowym początkowe powietrze. Woła je Destroy testów kapsuły po usunięciu przydzielonych obiektów,
/// więc działa też po nieudanej asercji, gdy kapsuła z Run() nie została opróżniona i oddała gaz przy usuwaniu
/proc/aquila_test_reset_air(list/room)
	for(var/turf/open/room_turf in room)
		room_turf.air.copy_from_turf(room_turf)
		room_turf.update_visuals()

/datum/unit_test/aquila_botany_ksenoflora/Destroy()
	var/list/room = block(run_loc_floor_bottom_left, run_loc_floor_top_right)
	. = ..()
	aquila_test_reset_air(room)

/datum/unit_test/aquila_botany_kseno_gazowe/Destroy()
	var/list/room = block(run_loc_floor_bottom_left, run_loc_floor_top_right)
	. = ..()
	aquila_test_reset_air(room)

/datum/unit_test/aquila_botany_kseno_rasy/Destroy()
	var/list/room = block(run_loc_floor_bottom_left, run_loc_floor_top_right)
	. = ..()
	aquila_test_reset_air(room)

/datum/unit_test/aquila_botany_kseno_adhomai/Destroy()
	var/list/room = block(run_loc_floor_bottom_left, run_loc_floor_top_right)
	. = ..()
	aquila_test_reset_air(room)

/datum/unit_test/aquila_xenoflora_pod_fixes/Destroy()
	var/list/room = block(run_loc_floor_bottom_left, run_loc_floor_top_right)
	. = ..()
	aquila_test_reset_air(room)

/// AQUILA - ksenoflora rośnie tylko w kapsule: miotlarz z azotem pod kopułą rośnie i owocuje, bez azotu stoi, a w zwykłej tacce nie da się go zasadzić
/datum/unit_test/aquila_botany_ksenoflora

/datum/unit_test/aquila_botany_ksenoflora/Run()
	var/turf/origin = run_loc_floor_bottom_left
	var/turf/pod_turf = locate(origin.x + 1, origin.y + 1, origin.z)
	var/mob/living/carbon/human/user = allocate(/mob/living/carbon/human, origin)

//Kapsuła z azotem: rośnie, owocuje, zużywa azot, zbiór daje liść miotlarza
	var/obj/machinery/atmospherics/components/binary/xenoflora_pod/pod = allocate(/obj/machinery/atmospherics/components/binary/xenoflora_pod, pod_turf)
	pod.reagents.add_reagent(/datum/reagent/water, 200)
	var/datum/component/plant/plant = plant_broombush(pod)
	TEST_ASSERT(istype(plant), "Miotlarz nie dał się posadzić w kapsule")
	TEST_ASSERT(plant.plant_item.loc == pod, "Miotlarz nie trafił do kapsuły")
	pod.internal_gases.set_moles(GAS_N2, 50)
	pod.internal_gases.set_temperature(T20C)
	var/datum/plant_feature/body/body = locate() in plant.plant_features
	var/datum/plant_feature/fruit/fruit = locate() in plant.plant_features
	grow(body, fruit)
	TEST_ASSERT(body.current_stage >= body.growth_stages, "Miotlarz w kapsule z azotem nie urósł (etap [body.current_stage]/[body.growth_stages])")
	TEST_ASSERT(length(fruit.fruits), "Miotlarz w kapsule z azotem nie zawiązał owoców")
	TEST_ASSERT(pod.internal_gases.get_moles(GAS_N2) < 50, "Miotlarz nie zużył azotu z kapsuły")
	fruit.catch_attack_hand(null, user)
	var/obj/item/leaf = locate(/obj/item/food/grown/xenoflora/broombush) in get_turf(user)
	TEST_ASSERT(leaf, "Zbiór miotlarza nie dał liścia miotlarza")
	qdel(leaf)
	aquila_test_drop_pod(pod)

//Kapsuła bez azotu: ani wzrostu, ani owoców
	pod = allocate(/obj/machinery/atmospherics/components/binary/xenoflora_pod, pod_turf)
	pod.reagents.add_reagent(/datum/reagent/water, 200)
	plant = plant_broombush(pod)
	TEST_ASSERT(istype(plant), "Miotlarz nie dał się posadzić w drugiej kapsule")
	body = locate() in plant.plant_features
	fruit = locate() in plant.plant_features
	grow(body, fruit)
	TEST_ASSERT(body.current_stage < body.growth_stages, "Miotlarz urósł w kapsule bez azotu")
	TEST_ASSERT(!length(fruit.fruits), "Miotlarz zawiązał owoce w kapsule bez azotu")
	aquila_test_drop_pod(pod)

//Zwykła tacka: nasiona nie wschodzą
	var/obj/item/plant_tray/tray = allocate(/obj/item/plant_tray, pod_turf)
	var/datum/component/planter/tray_planter = tray.GetComponent(/datum/component/planter)
	tray_planter.set_substrate(/datum/plant_subtrate/fairy)
	tray.reagents.add_reagent(/datum/reagent/water, 150)
	TEST_ASSERT(!plant_broombush(tray), "Miotlarz dał się posadzić w zwykłej tacce")
	TEST_ASSERT(!length(tray_planter.plants), "W zwykłej tacce pojawiła się ksenoflora")
	//Ani na podłożu wodnym akwakultury (osobny bit podłoża)
	tray_planter.set_substrate(/datum/plant_subtrate/water)
	TEST_ASSERT(!plant_broombush(tray), "Miotlarz dał się posadzić w tacce z podłożem wodnym")
	TEST_ASSERT(!length(tray_planter.plants), "W tacce z podłożem wodnym pojawiła się ksenoflora")

/datum/unit_test/aquila_botany_ksenoflora/proc/plant_broombush(atom/target)
	var/obj/item/plant_seeds/seeds = allocate(/obj/item/plant_seeds/preset/alien/xenoflora/broombush, get_turf(target))
	return seeds.plant(target, null, TRUE, null, TRUE)

/// Kilka cykli wzrostu z czasami skróconymi do jednego cyklu
/datum/unit_test/aquila_botany_ksenoflora/proc/grow(datum/plant_feature/body/body, datum/plant_feature/fruit/fruit)
	body.growth_time = 1
	fruit.growth_time = 1
	for(var/i in 1 to 4)
		body.process(2)
		fruit.process(2)

#undef TEST_ASSERT
