// AQUILA - test wiertła, żył rud (klasy 1-4) i misji „Próbki geologiczne” i „Głęboki odwiert”. Bez czekania na czas gry: cykle wydobycia i wyjścia
// mobów z wyrw są wywoływane wprost.

// Upstreamowe makra asercji są #undef na końcu code/modules/unit_tests/_unit_tests.dm, więc test ma własne kopie
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/datum/unit_test/aquila_vein_drill

/datum/unit_test/aquila_vein_drill/Run()
	var/turf/T = run_loc_floor_bottom_left
	var/obj/structure/vein/lavaland/classtwo/vein = allocate(/obj/structure/vein/lavaland/classtwo)
	TEST_ASSERT(length(vein.vein_contents), "Żyła nie wylosowała rud")
	TEST_ASSERT(vein.mining_charges >= 6 && vein.mining_charges <= 10, "Zły zakres ładunków żyły: [vein.mining_charges]")

	// Wiertło z płytki: części z płytki, bez ogniwa; nie rusza bez żyły ani bez ogniwa
	var/obj/machinery/drill/drill = allocate(/obj/machinery/drill)
	TEST_ASSERT(!drill.cell, "Wiertło zbudowane z płytki ma ogniwo")
	TEST_ASSERT(locate(/obj/item/stock_parts/micro_laser) in drill.component_parts, "Wiertło nie ma mikrolasera")
	drill.start_mining()
	TEST_ASSERT(!drill.active, "Wiertło ruszyło bez żyły")
	drill.our_vein = vein
	vein.our_drill = drill
	drill.setAnchored(TRUE)
	drill.start_mining()
	TEST_ASSERT(!drill.active, "Wiertło ruszyło bez ogniwa")
	drill.cell = new /obj/item/stock_parts/cell/high(drill)
	drill.start_mining()
	TEST_ASSERT(drill.active && drill.current_timerid && vein.currently_spawning, "Wiertło nie ruszyło na żyle z ogniwem")

	// Cykl wydobycia: ładunek mniej, ruda obok
	var/charges_before = vein.mining_charges
	deltimer(drill.current_timerid)
	drill.mine()
	TEST_ASSERT_EQUAL(vein.mining_charges, charges_before - 1, "Cykl nie zużył ładunku żyły")
	var/ore_amount = 0
	for(var/obj/item/stack/ore/ore in range(1, T))
		ore_amount += ore.amount
	TEST_ASSERT(ore_amount > 0, "Cykl nie wyrzucił rudy")

	// Fala: żyła klasy 2 otwiera dwie wyrwy, a wyrwa wypuszcza moba frakcji mining
	vein.try_spawning_spawner()
	TEST_ASSERT_EQUAL(length(vein.active_spawners), 2, "Zła liczba wyrw dla żyły klasy 2")
	var/obj/effect/drill_spawner/breach = vein.active_spawners[1]
	var/datum/component/spawner/vein_breach/spawner = breach.GetComponent(/datum/component/spawner/vein_breach)
	TEST_ASSERT(spawner, "Wyrwa nie ma spawnera")
	spawner.spawn_delay = 0
	spawner.try_spawn_mob()
	TEST_ASSERT(length(spawner.spawned_mobs), "Wyrwa nie wypuściła moba")
	var/mob/living/spawned = spawner.spawned_mobs[1]
	TEST_ASSERT(spawned.type in vein.mob_types, "Wyrwa wypuściła moba spoza listy żyły: [spawned.type]")
	TEST_ASSERT("mining" in spawned.faction, "Mob z wyrwy nie ma frakcji mining")

	// Uszkodzone wiertło przy starcie cyklu dostaje awarię i staje
	drill.stop_mining()
	drill.obj_integrity = drill.max_integrity / 2
	drill.start_mining()
	TEST_ASSERT(!drill.active && drill.malfunction, "Uszkodzone wiertło ruszyło bez awarii")
	drill.malfunction = null
	drill.obj_integrity = drill.max_integrity
	if(drill.missing_part)
		drill.component_parts += new drill.missing_part(null)
		drill.missing_part = null

	// Zniszczenie w trakcie pracy: żyła się zawala, wiertło zostaje zepsute i odczepione
	drill.start_mining()
	TEST_ASSERT(drill.active, "Naprawione wiertło nie ruszyło")
	drill.deconstruct(FALSE)
	TEST_ASSERT(!QDELETED(drill) && (drill.machine_stat & BROKEN), "Zniszczone wiertło zniknęło albo nie jest zepsute")
	TEST_ASSERT(QDELETED(vein), "Żyła nie zawaliła się po awarii wiertła")
	TEST_ASSERT(!drill.our_vein && !drill.anchored && !drill.active, "Wiertło po zawaleniu żyły nadal na niej stoi")

	// Wiertło misji: tylko żyła wymaganej klasy, próbki zamiast rudy, pełny pojemnik blokuje start
	var/obj/structure/vein/lavaland/vein1 = allocate(/obj/structure/vein/lavaland)
	vein1.mining_charges = 10
	var/obj/machinery/drill/mission/sampler = allocate(/obj/machinery/drill/mission)
	TEST_ASSERT(sampler.cell, "Wiertło misji nie ma ogniwa")
	TEST_ASSERT_EQUAL(length(sampler.component_parts), 3, "Wiertło misji ma złe części")
	sampler.mission_class = 2
	sampler.num_wanted = 2
	sampler.our_vein = vein1
	vein1.our_drill = sampler
	sampler.setAnchored(TRUE)
	sampler.start_mining()
	TEST_ASSERT(!sampler.active, "Wiertło misji ruszyło na żyle za niskiej klasy")
	sampler.mission_class = 1
	sampler.start_mining()
	TEST_ASSERT(sampler.active, "Wiertło misji nie ruszyło")
	var/ore_before = 0
	for(var/obj/item/stack/ore/ore in range(1, T))
		ore_before += ore.amount
	deltimer(sampler.current_timerid)
	sampler.mine()
	deltimer(sampler.current_timerid)
	sampler.mine()
	TEST_ASSERT_EQUAL(sampler.num_current, 2, "Wiertło misji nie liczy próbek")
	TEST_ASSERT(!sampler.active, "Wiertło misji nie stanęło po zebraniu wymaganych próbek")
	var/ore_after = 0
	for(var/obj/item/stack/ore/ore in range(1, T))
		ore_after += ore.amount
	TEST_ASSERT_EQUAL(ore_after, ore_before, "Wiertło misji wyrzuciło rudę")
	sampler.num_current = 5
	sampler.start_mining()
	TEST_ASSERT(!sampler.active, "Wiertło misji ruszyło z pełnym pojemnikiem")

	// Cel misji: klasa 1-3 i nagroda zależna od klasy; zniszczenie wiertła oblewa misję
	var/datum/overmap_objective/planet/drill_samples/objective = new
	TEST_ASSERT(isnum(objective.class_wanted) && objective.class_wanted >= 1 && objective.class_wanted <= 3, "Zła klasa celu: [objective.class_wanted]")
	TEST_ASSERT(objective.num_wanted >= 3, "Za mało próbek w celu: [objective.num_wanted]")
	sampler.setup_mission(objective)
	TEST_ASSERT_EQUAL(sampler.num_wanted, objective.num_wanted, "Wiertło nie wzięło liczby próbek z celu")
	objective.sampler = sampler
	objective.RegisterSignal(sampler, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/datum/overmap_objective/planet/drill_samples, on_sampler_deleted))
	qdel(sampler)
	TEST_ASSERT_EQUAL(objective.status, 2, "Cel nie jest oblany po zniszczeniu wiertła")
	qdel(objective)

	// Skaner gruntu wskazuje żyłę
	var/obj/structure/vein/lavaland/vein3 = allocate(/obj/structure/vein/lavaland)
	var/obj/item/pinpointer/mineral/scanner = allocate(/obj/item/pinpointer/mineral)
	TEST_ASSERT(scanner.scan_for_target(), "Skaner nie znalazł żyły")
	TEST_ASSERT(istype(scanner.target, /obj/structure/vein), "Skaner wskazuje coś innego niż żyłę")
	qdel(vein3)

	// Żyła klasy 4: 30 ±2 ładunków, sam bluespace, do 4 wyrw naraz po 6 mobów
	var/obj/structure/vein/lavaland/classfour/vein4 = allocate(/obj/structure/vein/lavaland/classfour)
	TEST_ASSERT(vein4.mining_charges >= 28 && vein4.mining_charges <= 32, "Zły zakres ładunków żyły klasy 4: [vein4.mining_charges]")
	TEST_ASSERT(length(vein4.vein_contents) == 1 && vein4.vein_contents[1] == /obj/item/stack/ore/bluespace_crystal, "Żyła klasy 4 ma inne rudy niż bluespace")
	vein4.try_spawning_spawner()
	TEST_ASSERT(length(vein4.active_spawners) >= 1 && length(vein4.active_spawners) <= 4, "Zła liczba wyrw żyły klasy 4: [length(vein4.active_spawners)]")
	var/obj/effect/drill_spawner/breach4 = vein4.active_spawners[1]
	var/datum/component/spawner/vein_breach/spawner4 = breach4.GetComponent(/datum/component/spawner/vein_breach)
	TEST_ASSERT_EQUAL(spawner4?.max_mobs, 6, "Wyrwa żyły klasy 4 ma zły limit mobów")

	// Wiertło do próbek głębinowych: tylko żyła klasy 4, po samples_required cyklach jedna próbka
	var/obj/structure/vein/lavaland/classtwo/shallow = allocate(/obj/structure/vein/lavaland/classtwo)
	var/obj/machinery/drill/sampler_mission/deep = allocate(/obj/machinery/drill/sampler_mission)
	TEST_ASSERT(deep.samples_required >= 6 && deep.samples_required <= 10, "Zła liczba cykli do próbki: [deep.samples_required]")
	TEST_ASSERT(deep.cell, "Wiertło do próbek głębinowych nie ma ogniwa")
	deep.our_vein = shallow
	shallow.our_drill = deep
	deep.setAnchored(TRUE)
	deep.start_mining()
	TEST_ASSERT(!deep.active, "Wiertło do próbek głębinowych ruszyło na płytkiej żyle")
	shallow.our_drill = null
	deep.our_vein = vein4
	vein4.our_drill = deep
	deep.samples_required = 2
	var/datum/overmap_objective/planet/deep_vein/deep_objective = new
	deep.mission = deep_objective
	deep_objective.sampler = deep
	deep.start_mining()
	TEST_ASSERT(deep.active, "Wiertło do próbek głębinowych nie ruszyło na żyle klasy 4")
	deltimer(deep.current_timerid)
	deep.mine()
	TEST_ASSERT(deep.active && !deep_objective.sample, "Próbka wypadła za wcześnie")
	deltimer(deep.current_timerid)
	deep.mine()
	var/obj/item/drill_sample/drill_sample = deep_objective.sample
	TEST_ASSERT(istype(drill_sample) && !QDELETED(drill_sample), "Wiertło nie wyrzuciło próbki")
	TEST_ASSERT(!deep.active, "Wiertło nie stanęło po wydobyciu próbki")
	deep.start_mining()
	TEST_ASSERT(!deep.active, "Wiertło ruszyło drugi raz po wydobyciu próbki")
	var/obj/item/drill_core_container/core_container = allocate(/obj/item/drill_core_container)
	TEST_ASSERT(core_container.load(drill_sample), "Próbka nie weszła do pojemnika")
	TEST_ASSERT(drill_sample.loc == core_container && core_container.core == drill_sample, "Próbka nie jest w pojemniku")
	// Zniszczenie pojemnika z próbką oblewa misję
	deep_objective.container = core_container
	deep_objective.RegisterSignal(core_container, COMSIG_PARENT_QDELETING, TYPE_PROC_REF(/datum/overmap_objective/planet/deep_vein, on_tracked_deleted))
	qdel(core_container)
	TEST_ASSERT_EQUAL(deep_objective.status, 2, "Cel nie jest oblany po zniszczeniu pojemnika")
	TEST_ASSERT(QDELETED(drill_sample), "Próbka przetrwała zniszczenie pojemnika")
	qdel(deep_objective)
	qdel(deep)

	for(var/obj/effect/drill_spawner/leftover in range(8, T))
		qdel(leftover)
	for(var/mob/living/basic/mining/mob in range(8, T))
		qdel(mob)
	for(var/obj/item/stack/ore/ore in range(2, T))
		qdel(ore)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
