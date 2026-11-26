// AQUILA - testy eventów z kafli mapy hex, etap E7 (nowe plagi i potwory): pule terenów, słoneczne larwy, żywy kabel,
// dzikie szlamy, larwy obcych i pasożyt w ciele, mimity, oczny horror, kosmiczny dzik, pleśń i guz złośliwy
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// Each E7 event is in the pool of its own terrain only and does not roll as a plain ship event.
/// Base of the other E7 tests: they clean up whatever appeared on their turfs.
/datum/unit_test/aquila_hex_plagues
	/// Pola testu => to, co na nich było przed testem
	var/list/watched_turfs = list()

/datum/unit_test/aquila_hex_plagues/proc/watch(turf/T)
	if(T && !watched_turfs[T])
		watched_turfs[T] = T.contents.Copy()
	return T

/// Pole testu przesunięte o dx, dy od lewego dolnego rogu, pod obserwacją
/datum/unit_test/aquila_hex_plagues/proc/spot(dx, dy)
	return watch(locate(run_loc_floor_bottom_left.x + dx, run_loc_floor_bottom_left.y + dy, run_loc_floor_bottom_left.z))

/datum/unit_test/aquila_hex_plagues/Destroy()
	for(var/turf/T as anything in watched_turfs)
		var/list/before = watched_turfs[T]
		for(var/atom/movable/AM as anything in T.contents)
			if(!(AM in before) && !QDELETED(AM))
				qdel(AM)
	watched_turfs.Cut()
	return ..()

/datum/unit_test/aquila_hex_plagues/Run()
	var/list/event_terrains = list(
		/datum/round_event_control/aquila_hex_grub_infestation = HEX_TERRAIN_ELECTRICAL,
		/datum/round_event_control/aquila_hex_powercreeper = HEX_TERRAIN_ELECTRICAL,
		/datum/round_event_control/aquila_hex_metroid_infestation = HEX_TERRAIN_COMET,
		/datum/round_event_control/aquila_hex_abominable_infestation = HEX_TERRAIN_COMET,
		/datum/round_event_control/aquila_hex_mimite_infestation = HEX_TERRAIN_JUNK,
		/datum/round_event_control/aquila_hex_eye_horror = HEX_TERRAIN_NEBULA,
		/datum/round_event_control/aquila_hex_hog = HEX_TERRAIN_ASTEROIDS,
		/datum/round_event_control/aquila_hex_mold = HEX_TERRAIN_RADIATION,
		/datum/round_event_control/aquila_hex_spontaneous_malignant_organ = HEX_TERRAIN_RADIATION,
	)
	hex_terrain(HEX_TERRAIN_EMPTY)
	for(var/path in event_terrains)
		var/datum/round_event_control/control = hex_event_control(path)
		TEST_ASSERT(control, "No event control of [path]")
		for(var/id in GLOB.hex_terrains)
			var/datum/hex_terrain/terrain = GLOB.hex_terrains[id]
			var/in_pool = (path in terrain.events) || (path in terrain.antags)
			if(id == event_terrains[path])
				TEST_ASSERT((path in terrain.events) && !(path in terrain.antags), "[control.name] is not among the events of [id]")
			else
				TEST_ASSERT(!in_pool, "[control.name] is also in a pool of [id]")
		TEST_ASSERT(hex_tile_environment_events()[path], "[control.name] still rolls as a plain ship event")

/// Solar grubs come one per vent, grow twice on drained power and no further, and bite through at most two cables
/datum/unit_test/aquila_hex_plagues/grubs

/datum/unit_test/aquila_hex_plagues/grubs/Run()
	var/turf/floor = spot(0, 0)
	var/datum/round_event/aquila_hex_grub_infestation/event = new(FALSE)
	event.kill()
	var/list/grubs = event.spawn_grubs(list(floor), 4)
	TEST_ASSERT_EQUAL(length(grubs), 1, "One vent let out a wrong number of grubs")
	var/mob/living/basic/aquila_solargrub/grub = grubs[1]
	TEST_ASSERT(istype(grub) && grub.loc == floor, "No solar grub at the vent")
	TEST_ASSERT(HAS_TRAIT(grub, TRAIT_SHOCKIMMUNE), "The solar grub is not shock immune")
	TEST_ASSERT(!grub.feed(grub.stage_thresholds[1] - 1), "The grub grew before draining enough")
	TEST_ASSERT(grub.feed(1) && grub.stage == 2 && grub.icon_state == "grub_2", "The grub did not grow on drained power")
	grub.feed(grub.stage_thresholds[2])
	TEST_ASSERT_EQUAL(grub.stage, 3, "The grub did not reach its last stage")
	TEST_ASSERT_EQUAL(grub.maxHealth, 60, "The big grub has the wrong health")
	TEST_ASSERT(!grub.grow() && !grub.feed(100000), "The grub grew past its last stage")
	TEST_ASSERT_EQUAL(grub.stage, 3, "The grub has a fourth stage")

	var/turf/open/floor/plating/bare = spot(1, 0)
	for(var/i in 1 to 3)
		var/obj/structure/cable/cable = new(bare)
		var/chewed = grub.UnarmedAttack(cable, TRUE) && QDELETED(cable)
		if(i <= grub.max_cables_chewed)
			TEST_ASSERT(chewed, "The grub did not bite through cable [i]")
		else
			TEST_ASSERT(!chewed, "The grub bit through more than [grub.max_cables_chewed] cables")
			qdel(cable)
	TEST_ASSERT_EQUAL(aquila_hex_drain_area_power(null, 50), 0, "Power was drained from nowhere")
	TEST_ASSERT(!length(event.spawn_grubs(null, 3)), "Grubs came out with no vents")
	qdel(event)

/// The powercreeper grows from its root up to its limit, shocks a bare hand, is torn out in insulated gloves
/// and withers when the root dies
/datum/unit_test/aquila_hex_plagues/powercreeper

/datum/unit_test/aquila_hex_plagues/powercreeper/Run()
	for(var/dx in 0 to 4)
		for(var/dy in 0 to 2)
			spot(dx, dy)
	var/datum/round_event/aquila_hex_powercreeper/event = new(FALSE)
	event.kill()
	var/obj/structure/aquila_hex_spreader/powercreeper/root = event.plant(spot(2, 1))
	TEST_ASSERT(istype(root) && root.root == root, "No powercreeper root")
	TEST_ASSERT(isnull(event.plant(null)), "A powercreeper sprouted nowhere")
	root.max_pieces = 4
	for(var/i in 1 to 20)
		root.spread()
	TEST_ASSERT_EQUAL(length(root.pieces), 4, "The powercreeper did not stop at its piece limit")
	var/obj/structure/aquila_hex_spreader/powercreeper/piece = root.pieces[2]
	TEST_ASSERT(get_dist(piece, root) <= root.max_radius && piece.root == root, "A powercreeper piece grew away from its root")

	var/mob/living/carbon/human/bare_hands = allocate(/mob/living/carbon/human, spot(0, 0))
	piece.attack_hand(bare_hands)
	TEST_ASSERT(!QDELETED(piece), "A bare hand tore the powercreeper out")
	TEST_ASSERT(bare_hands.getFireLoss() > 0, "The powercreeper did not shock a bare hand")
	var/mob/living/carbon/human/electrician = allocate(/mob/living/carbon/human, spot(4, 0))
	electrician.equip_to_slot_or_del(new /obj/item/clothing/gloves/color/yellow(electrician), ITEM_SLOT_GLOVES)
	piece.attack_hand(electrician)
	TEST_ASSERT(QDELETED(piece), "Insulated gloves did not tear the powercreeper out")
	TEST_ASSERT_EQUAL(electrician.getFireLoss(), 0, "The powercreeper shocked through insulated gloves")
	TEST_ASSERT_EQUAL(length(root.pieces), 3, "The torn piece is still counted by the root")

	var/list/left = root.pieces - root
	qdel(root)
	for(var/obj/structure/aquila_hex_spreader/powercreeper/orphan as anything in left)
		TEST_ASSERT(orphan.withering && isnull(orphan.root), "A powercreeper piece does not wither after its root died")
		qdel(orphan)
	qdel(event)

/// Wild slimes are charged rabid babies that never grow or split
/datum/unit_test/aquila_hex_plagues/wild_slimes

/datum/unit_test/aquila_hex_plagues/wild_slimes/Run()
	var/turf/floor = spot(0, 0)
	var/datum/round_event/aquila_hex_metroid_infestation/event = new(FALSE)
	event.kill()
	var/list/slimes = event.spawn_slimes(list(floor, spot(4, 2)), 5)
	TEST_ASSERT_EQUAL(length(slimes), 2, "Two vents let out a wrong number of wild slimes")
	var/mob/living/simple_animal/slime/aquila_hex_horde/wild/slime = slimes[1]
	TEST_ASSERT(istype(slime) && slime.rabid && !slime.is_adult && slime.powerlevel == 5, "[slime] is not a charged rabid baby slime")
	TEST_ASSERT(slime.colour in list("yellow", "dark blue", "bluespace", "cerulean"), "The wild slime is [slime.colour]")
	slime.amount_grown = SLIME_EVOLUTION_THRESHOLD
	slime.Evolve()
	slime.Reproduce()
	TEST_ASSERT(!slime.is_adult, "The wild slime grew up")
	var/count = 0
	for(var/mob/living/simple_animal/slime/other in get_turf(slime))
		count++
	TEST_ASSERT_EQUAL(count, 1, "The wild slime split")
	qdel(event)

/// Larvae grow into broodlings; the parasitic one burrows into a human as a body egg that pest killer kills,
/// that bursts out as one broodling, and that the scanner shows
/datum/unit_test/aquila_hex_plagues/larvae

/datum/unit_test/aquila_hex_plagues/larvae/Run()
	var/datum/round_event/aquila_hex_abominable_infestation/event = new(FALSE)
	event.kill()
	var/list/larvae = event.spawn_larvae(list(spot(0, 2), spot(1, 2), spot(2, 2)), 3)
	TEST_ASSERT_EQUAL(length(larvae), 3, "Three vents let out a wrong number of larvae")
	var/implanters = 0
	for(var/mob/living/basic/aquila_hex_larva/larva as anything in larvae)
		if(istype(larva, /mob/living/basic/aquila_hex_larva/implanter))
			implanters++
	TEST_ASSERT(implanters >= 1 && implanters <= 2, "The larvae have [implanters] parasitic ones")

	var/mob/living/basic/aquila_hex_larva/plain = allocate(/mob/living/basic/aquila_hex_larva, spot(4, 2))
	var/mob/living/basic/aquila_hex_broodling/brood = plain.mature()
	TEST_ASSERT(istype(brood) && QDELETED(plain), "The larva did not grow into a broodling")

	var/mob/living/carbon/human/host = allocate(/mob/living/carbon/human, spot(1, 0))
	var/mob/living/basic/aquila_hex_larva/implanter/biter = allocate(/mob/living/basic/aquila_hex_larva/implanter, spot(0, 0))
	TEST_ASSERT(biter.implant(host) && QDELETED(biter), "The parasitic larva did not burrow into the human")
	var/obj/item/organ/body_egg/aquila_hex_larva/egg = host.getorganslot("parasite_egg")
	TEST_ASSERT(istype(egg), "The human has no larva inside")
	TEST_ASSERT(findtext(jointext(host.aq_organ_scan_lines(), ""), "Pasożyt w klatce piersiowej"), "The scanner does not show the larva")
	var/mob/living/basic/aquila_hex_larva/implanter/second = allocate(/mob/living/basic/aquila_hex_larva/implanter, spot(0, 0))
	TEST_ASSERT(!second.implant(host) && !QDELETED(second), "A second larva burrowed into the same human")
	host.reagents.add_reagent(/datum/reagent/toxin/pestkiller, 5)
	egg.egg_process()
	TEST_ASSERT(QDELETED(egg) && !host.getorganslot("parasite_egg"), "Pest killer did not kill the larva inside")
	host.reagents.clear_reagents()

	TEST_ASSERT(second.implant(host), "The parasitic larva did not burrow into the cured human")
	egg = host.getorganslot("parasite_egg")
	egg.growth = egg.hatch_growth - 1
	var/brute_before = host.getBruteLoss()
	egg.egg_process()
	TEST_ASSERT(QDELETED(egg) && !host.getorganslot("parasite_egg"), "The grown larva did not leave the body")
	TEST_ASSERT(host.getBruteLoss() > brute_before, "The larva burst out without hurting the host")
	TEST_ASSERT(locate(/mob/living/basic/aquila_hex_broodling) in get_turf(host), "No broodling came out of the host")
	qdel(event)

/// A mimite copies an item, ambushes whoever touches it and replicates only within its count and the round limit
/datum/unit_test/aquila_hex_plagues/mimites

/datum/unit_test/aquila_hex_plagues/mimites/Run()
	var/old_made = GLOB.aquila_hex_mimites_made
	GLOB.aquila_hex_mimites_made = 0
	var/turf/floor = spot(0, 0)
	var/obj/item/wrench/wrench = allocate(/obj/item/wrench, spot(1, 0))
	var/datum/round_event/aquila_hex_mimite_infestation/event = new(FALSE)
	event.kill()
	var/list/mimites = event.spawn_mimites(list(floor), 3)
	TEST_ASSERT_EQUAL(length(mimites), 1, "One vent let out a wrong number of mimites")
	var/mob/living/basic/aquila_mimite/mimite = mimites[1]
	TEST_ASSERT(mimite.disguise(wrench), "The mimite did not copy the wrench")
	TEST_ASSERT_EQUAL(mimite.name, wrench.name, "The mimite does not look like the wrench")
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, spot(0, 1))
	mimite.attack_hand(victim)
	TEST_ASSERT(isnull(mimite.form_ref) && mimite.name == initial(mimite.name), "The mimite stayed disguised after the ambush")
	TEST_ASSERT(victim.IsKnockdown(), "The ambush did not knock the victim down")
	TEST_ASSERT(victim.reagents.has_reagent(/datum/reagent/toxin/morphvenom), "The ambush did not poison the victim")

	mimite.remaining_replications = 1
	var/mob/living/basic/aquila_mimite/child = mimite.replicate()
	TEST_ASSERT(istype(child) && child.remaining_replications == 0, "The mimite did not replicate")
	TEST_ASSERT(isnull(mimite.replicate()) && isnull(child.replicate()), "A mimite replicated past its count")
	mimite.remaining_replications = 5
	GLOB.aquila_hex_mimites_made = 12
	TEST_ASSERT(isnull(mimite.replicate()), "A mimite replicated past the round limit")
	TEST_ASSERT(!length(event.spawn_mimites(list(floor), 3)), "The event let out mimites past the round limit")
	GLOB.aquila_hex_mimites_made = old_made
	qdel(event)

/// The eye horror flashes whoever looks at it, but not through welding goggles
/datum/unit_test/aquila_hex_plagues/eye_horror

/datum/unit_test/aquila_hex_plagues/eye_horror/Run()
	var/datum/round_event/aquila_hex_eye_horror/event = new(FALSE)
	event.kill()
	var/mob/living/carbon/human/onlooker = allocate(/mob/living/carbon/human, spot(0, 0))
	var/mob/living/carbon/human/welder = allocate(/mob/living/carbon/human, spot(0, 2))
	welder.equip_to_slot_or_del(new /obj/item/clothing/glasses/welding(welder), ITEM_SLOT_EYES)
	var/mob/living/basic/aquila_eye_horror/horror = event.spawn_horror(spot(3, 1))
	TEST_ASSERT(istype(horror), "No eye horror")
	TEST_ASSERT(isnull(event.spawn_horror(null)), "An eye horror spawned nowhere")
	TEST_ASSERT(!COOLDOWN_FINISHED(horror, gaze_cooldown), "The eye horror did not flash on arrival")
	var/list/flashed = horror.gaze()
	TEST_ASSERT(onlooker in flashed, "The eye horror did not flash a bare-eyed onlooker")
	TEST_ASSERT(!(welder in flashed), "The eye horror flashed through welding goggles")
	TEST_ASSERT(onlooker.hallucinating(), "The flashed onlooker does not hallucinate")
	qdel(event)

/// The space hog knocks people down, not again right away
/datum/unit_test/aquila_hex_plagues/hog

/datum/unit_test/aquila_hex_plagues/hog/Run()
	var/datum/round_event/aquila_hex_hog/event = new(FALSE)
	event.kill()
	var/mob/living/basic/aquila_space_hog/hog = event.spawn_hog(spot(0, 0))
	TEST_ASSERT(istype(hog), "No space hog")
	TEST_ASSERT(isnull(event.spawn_hog(null)), "A space hog spawned nowhere")
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, spot(1, 0))
	TEST_ASSERT(hog.ram(victim) && victim.IsKnockdown(), "The hog did not knock the victim down")
	TEST_ASSERT(!hog.ram(victim), "The hog knocked down twice in a row")
	qdel(event)

/// The mold core grows up to its limit with bulbs among the pieces, lets out at most three creatures,
/// its bulbs burst once per cooldown and everything withers when the core dies
/datum/unit_test/aquila_hex_plagues/mold

/datum/unit_test/aquila_hex_plagues/mold/Run()
	for(var/dx in 0 to 4)
		for(var/dy in 0 to 2)
			spot(dx, dy)
	var/datum/round_event/aquila_hex_mold/event = new(FALSE)
	event.kill()
	TEST_ASSERT(isnull(event.plant(null, /datum/aquila_hex_mold_type/toxic)), "Mold sprouted nowhere")
	var/obj/structure/aquila_hex_spreader/mold/core = event.plant(spot(2, 1), /datum/aquila_hex_mold_type/radioactive)
	TEST_ASSERT(istype(core) && istype(core.mold_type, /datum/aquila_hex_mold_type/radioactive), "No radioactive mold core")
	core.max_pieces = 5
	for(var/i in 1 to 20)
		core.spread()
	TEST_ASSERT_EQUAL(length(core.pieces), 5, "The mold did not stop at its piece limit")
	for(var/obj/structure/aquila_hex_spreader/mold_resin/resin in core.pieces)
		TEST_ASSERT_EQUAL(resin.color, core.mold_type.mold_color, "A mold piece has the wrong colour")

	var/obj/structure/aquila_hex_spreader/mold_resin/bulb/bulb = new(spot(0, 2), core)
	TEST_ASSERT(bulb.root == core && (bulb in core.pieces), "The bulb does not belong to the core")
	TEST_ASSERT(bulb.burst(), "The bulb did not burst")
	TEST_ASSERT(!bulb.burst(), "The bulb burst twice in a row")

	var/creatures = 0
	for(var/i in 1 to 5)
		var/mob/living/creature = core.spawn_creature()
		if(creature)
			creatures++
			TEST_ASSERT(istype(creature, /mob/living/basic/mouse/aquila_hex_irradiated), "The radioactive mold let out [creature]")
	TEST_ASSERT_EQUAL(creatures, core.max_creatures, "The mold let out a wrong number of creatures")

	var/list/left = core.pieces - core
	qdel(core)
	for(var/obj/structure/aquila_hex_spreader/orphan as anything in left)
		TEST_ASSERT(orphan.withering && isnull(orphan.root), "A mold piece does not wither after the core died")
		qdel(orphan)
	qdel(event)

/// The malignant tumour grows in an organic zone, shows on the scanner from stage two and comes out like an organ
/datum/unit_test/aquila_hex_plagues/tumor

/datum/unit_test/aquila_hex_plagues/tumor/Run()
	var/datum/round_event/aquila_hex_spontaneous_malignant_organ/event = new(FALSE)
	event.kill()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human, spot(0, 0))
	TEST_ASSERT(!event.can_grow_in(patient), "A tumour grows in a body with no player")
	var/obj/item/organ/aquila_hex_tumor/tumor = event.grow_tumor(patient)
	TEST_ASSERT(istype(tumor) && tumor.owner == patient, "No tumour grew")
	TEST_ASSERT(tumor.zone in list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_HEAD), "The tumour grew in [tumor.zone]")
	TEST_ASSERT(isnull(event.grow_tumor(patient)), "A second tumour grew in the same body")
	TEST_ASSERT(!findtext(jointext(patient.aq_organ_scan_lines(), ""), "Guz złośliwy"), "The scanner shows a first-stage tumour")
	tumor.progress = tumor.stage_length - 1
	tumor.on_life()
	TEST_ASSERT_EQUAL(tumor.stage, 2, "The tumour did not grow to stage two")
	TEST_ASSERT(findtext(jointext(patient.aq_organ_scan_lines(), ""), "Guz złośliwy"), "The scanner does not show the tumour")
	tumor.Remove(patient)
	TEST_ASSERT(!patient.getorganslot("aquila_tumor"), "The tumour stayed in the body after removal")
	qdel(tumor)
	qdel(event)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
