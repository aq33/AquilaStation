// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - lodowy meteor z komety (aquila/code/modules/events/hexmap/comet_expulsion.dm): po rozbiciu zostawia śnieg,
/// oszronioną podłogę i wychładza człowieka, który stał w miejscu uderzenia
/datum/unit_test/aquila_hex_ice_meteor

/datum/unit_test/aquila_hex_ice_meteor/Run()
	var/turf/open/impact = run_loc_floor_bottom_left
	// allocate() stawia wszystko na tym polu; przesuwanie meteoru taranowałoby podłogę wybuchem
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	victim.bodytemperature = BODYTEMP_NORMAL
	// Pył się rozbija od jednego trafienia i nie wybucha, więc sprawdza całą ścieżkę uderzenia bez niszczenia sali testowej
	var/obj/effect/meteor/aquila_ice/dust/meteor = allocate(/obj/effect/meteor/aquila_ice/dust)
	meteor.get_hit()
	TEST_ASSERT(QDELETED(meteor), "Lodowy pył nie rozbił się po jednym trafieniu")
	TEST_ASSERT(locate(/obj/item/stack/sheet/mineral/snow) in impact, "Lodowy meteor nie zostawił śniegu")
	TEST_ASSERT(impact.GetComponent(/datum/component/wet_floor), "Lodowy meteor nie oszronił podłogi")
	TEST_ASSERT(victim.bodytemperature < BODYTEMP_NORMAL, "Lodowy meteor nie wychłodził człowieka w miejscu uderzenia")
	impact.ClearWet()
	for(var/obj/item/stack/sheet/mineral/snow/snow in impact)
		qdel(snow)
	// Fale komet mają w sobie lodowe meteory (spawn_meteors losuje z tej listy)
	var/datum/round_event/aquila_hex_comet_tail/tail = new /datum/round_event/aquila_hex_comet_tail(FALSE)
	tail.kill()
	TEST_ASSERT(length(tail.wave), "Ogon komety nie wybrał listy meteorów")
	for(var/meteor_type in tail.wave)
		TEST_ASSERT(ispath(meteor_type, /obj/effect/meteor/aquila_ice), "Ogon komety sypie nielodowym meteorem [meteor_type]")
	TEST_ASSERT(tail.endWhen > tail.startWhen, "Ogon komety kończy się, zanim się zacznie")
	qdel(tail)

/// AQUILA - eventy overmapy z kafli hex (aquila/code/modules/events/hexmap/): bogata kometa i wrak pojawiają się w układzie okrętu
/// w zasięgu magnesu, a atak na frachtowiec stawia frachtowiec Nanotrasen i piratów, którzy w niego celują.
/// Bez okrętu w układzie gwiezdnym nic się nie pojawia i nic się nie sypie.
/datum/unit_test/aquila_hex_overmap_events
	var/datum/star_system/system
	var/obj/structure/overmap/ship
	var/list/spawned = list()

/datum/unit_test/aquila_hex_overmap_events/Run()
	system = new /datum/star_system(name = "Aquila hex event test", system_traits = STARSYSTEM_NO_ANOMALIES | STARSYSTEM_NO_ASTEROIDS)
	system.occupying_z = run_loc_floor_bottom_left.z
	ship = allocate(/obj/structure/overmap/small_craft/combat/light)
	ship.faction = "nanotrasen"
	ship.forceMove(locate(40, 40, run_loc_floor_bottom_left.z))
	var/fail = check_no_system() || check_rich_comet() || check_wreck() || check_freighter()
	for(var/atom/movable/thing as anything in spawned)
		system.system_contents -= thing
		if(!QDELETED(thing))
			qdel(thing)
	ship.current_system = null
	QDEL_NULL(system)
	if(fail)
		return Fail(fail)

/datum/unit_test/aquila_hex_overmap_events/proc/check_no_system()
	ship.current_system = null
	var/datum/round_event/aquila_hex_rich_comet/comet_event = new /datum/round_event/aquila_hex_rich_comet(FALSE)
	comet_event.kill()
	var/datum/round_event/aquila_hex_freighter_attack/attack = new /datum/round_event/aquila_hex_freighter_attack(FALSE)
	attack.kill()
	var/datum/round_event/aquila_hex_wreck_graveyard/graveyard = new /datum/round_event/aquila_hex_wreck_graveyard(FALSE)
	graveyard.kill()
	. = null
	if(comet_event.spawn_comet(ship))
		. = "Bogata kometa pojawiła się, choć okręt nie jest w układzie gwiezdnym"
	else if(attack.spawn_attack(ship) || attack.freighter_ref)
		. = "Atak na frachtowiec postawił okręty, choć okręt gracza nie jest w układzie gwiezdnym"
	else if(graveyard.spawn_wreck(ship))
		. = "Wrak pojawił się, choć okręt nie jest w układzie gwiezdnym"
	else if(comet_event.spawn_comet(null) || attack.spawn_attack(null) || graveyard.spawn_wreck(null))
		. = "Event overmapy bez okrętu postawił obiekt"
	qdel(comet_event)
	qdel(attack)
	qdel(graveyard)
	ship.current_system = system

/datum/unit_test/aquila_hex_overmap_events/proc/check_rich_comet()
	var/datum/round_event/aquila_hex_rich_comet/comet_event = new /datum/round_event/aquila_hex_rich_comet(FALSE)
	comet_event.kill()
	var/obj/structure/overmap/asteroid/comet = comet_event.spawn_comet(ship)
	qdel(comet_event)
	if(!comet)
		return "Bogata kometa się nie pojawiła"
	spawned += comet
	if(!(comet in system.system_contents))
		return "Bogata kometa nie trafiła do układu okrętu"
	if(comet.current_system != system)
		return "Bogata kometa ma zły układ gwiezdny"
	if(!(comet in orange(5, ship)))
		return "Bogata kometa stoi poza zasięgiem magnesu (orange(5) od okrętu)"
	for(var/ore in list(/turf/closed/mineral/diamond, /turf/closed/mineral/bscrystal, /turf/closed/mineral/uranium))
		if(!(ore in comet.core_composition))
			return "Rdzeń bogatej komety nie ma [ore]"

/datum/unit_test/aquila_hex_overmap_events/proc/check_wreck()
	var/datum/round_event/aquila_hex_wreck_graveyard/graveyard = new /datum/round_event/aquila_hex_wreck_graveyard(FALSE)
	graveyard.kill()
	var/obj/structure/overmap/asteroid/shipbreak_wreck/wreck = graveyard.spawn_wreck(ship)
	var/duration = graveyard.endWhen
	var/message
	for(var/i in 1 to 30)
		message = graveyard.pick_distress_message()
		if(message)
			break
	qdel(graveyard)
	if(!wreck)
		return "Cmentarzysko wraków nie postawiło wraku"
	spawned += wreck
	if(!istype(wreck) || !(wreck in system.system_contents))
		return "Wrak nie trafił do układu okrętu"
	if(!(wreck in orange(5, ship)))
		return "Wrak stoi poza zasięgiem magnesu (orange(5) od okrętu)"
	if(duration < 300 || duration > 600)
		return "Cmentarzysko trwa [duration] ticków zamiast 300–600"
	if(!message)
		return "Cmentarzysko w 30 próbach nie wylosowało żadnego wezwania pomocy"

/datum/unit_test/aquila_hex_overmap_events/proc/check_freighter()
	var/datum/round_event/aquila_hex_freighter_attack/attack = new /datum/round_event/aquila_hex_freighter_attack(FALSE)
	attack.kill()
	var/spawned_ok = attack.spawn_attack(ship)
	var/obj/structure/overmap/freighter = attack.freighter_ref?.resolve()
	var/list/pirates = list()
	for(var/datum/weakref/pirate_ref as anything in attack.pirate_refs)
		var/obj/structure/overmap/pirate = pirate_ref.resolve()
		if(pirate)
			pirates += pirate
	qdel(attack)
	if(freighter)
		spawned += freighter
	spawned += pirates
	if(!spawned_ok || !freighter)
		return "Atak na frachtowiec nie postawił frachtowca"
	if(freighter.faction != "nanotrasen" || !freighter.ai_controlled)
		return "Frachtowiec nie jest okrętem Nanotrasen sterowanym przez AI (frakcja [freighter.faction])"
	if(!(freighter in system.system_contents))
		return "Frachtowiec nie trafił do układu okrętu"
	if(length(pirates) < 1 || length(pirates) > 2)
		return "Zamiast 1–2 piratów pojawiło się [length(pirates)]"
	for(var/obj/structure/overmap/pirate as anything in pirates)
		if(pirate.faction != "pirate" || !pirate.ai_controlled)
			return "[pirate.type] nie jest piratem sterowanym przez AI (frakcja [pirate.faction])"
		if(!(pirate in system.system_contents))
			return "[pirate.type] nie trafił do układu okrętu"
		if(pirate.last_target != freighter)
			return "[pirate.type] nie celuje we frachtowiec"

#undef TEST_ASSERT
