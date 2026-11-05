// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - runtime'y z rund 6549-6552: każdy przypadek wywołany tak jak w grze
/datum/unit_test/aquila_logi_rund_6552

/datum/unit_test/aquila_logi_rund_6552/Run()
	// Panel lag switchy jest verbem klienta, więc link musi działać bez /datum/admins jako src
	var/link = lag_switch_link(DISABLE_FOOTSTEPS)
	TEST_ASSERT(findtext(link, "change_lag_switch=[DISABLE_FOOTSTEPS]"), "Lag switch link is [link]")

	// Netpod leczy przez SSprocessing; SSmachines czytał use_power, którego komponent nie ma
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/machinery/netpod/pod = allocate(/obj/machinery/netpod)
	var/datum/component/netpod_healing/healing = patient.AddComponent(/datum/component/netpod_healing, pod)
	TEST_ASSERT(healing, "Netpod healing component was not added")
	TEST_ASSERT(healing in SSprocessing.processing, "Netpod healing is not processed by SSprocessing")
	TEST_ASSERT(!(healing in SSmachines.processing), "Netpod healing is still processed by SSmachines")
	patient.adjustBruteLoss(20)
	healing.process(1)
	TEST_ASSERT(patient.getBruteLoss() < 20, "Netpod did not heal: brute [patient.getBruteLoss()]")
	qdel(healing)

	// Harmonijka w slocie maski nie jest ubraniem
	var/mob/living/carbon/human/musician = allocate(/mob/living/carbon/human)
	var/obj/item/instrument/harmonica/harmonica = allocate(/obj/item/instrument/harmonica)
	TEST_ASSERT(musician.equip_to_slot_if_possible(harmonica, ITEM_SLOT_MASK), "Harmonica did not go into the mask slot")
	TEST_ASSERT(!musician.has_smoke_protection(), "Harmonica gives smoke protection")
	musician.dna.species.handle_hair(musician)

	// Naklejka serii: get_stats() zwraca listę, examine jej nie psuje
	var/obj/item/sticker/series_1/smile/sticker = allocate(/obj/item/sticker/series_1/smile)
	var/list/stats = sticker.get_stats()
	TEST_ASSERT(islist(stats), "Sticker stats are [stats]")
	TEST_ASSERT(findtext(stats[1], "Seria 1"), "Sticker stats start with [stats[1]]")
	sticker.examine(musician)

	// Zapisany keybind, którego już nie ma, nie zostaje w prefach
	var/datum/preferences/prefs = new(null)
	var/kb_name = GLOB.keybindings_by_name[1]
	prefs.key_bindings = list("K" = list("aquila_removed_keybind", kb_name), "L" = list("aquila_removed_keybind"))
	prefs.remove_unknown_keybindings()
	TEST_ASSERT(prefs.key_bindings["K"] ~= list(kb_name), "Key K kept [json_encode(prefs.key_bindings["K"])]")
	TEST_ASSERT(!("L" in prefs.key_bindings), "Key with only an unknown keybind was kept")
	// Shift z samym usuniętym skrótem: po wyczyszczeniu dostaje sprint (kolejność jak w load_from_database)
	prefs.key_bindings = list("Shift" = list("aquila_removed_keybind"))
	prefs.remove_unknown_keybindings()
	prefs.add_sprint_keybind()
	TEST_ASSERT(prefs.key_bindings["Shift"] ~= list("sprint"), "Shift got [json_encode(prefs.key_bindings["Shift"])] instead of sprint")
	qdel(prefs)

	// Wybuch, gdy ktoś z player_list nie ma kafla (lobby), nie może przerwać pętli dźwięku dla graczy dalej na liście
	var/mob/lobby_player = allocate(/mob/living/carbon/human)
	lobby_player.moveToNullspace()
	var/mob/living/carbon/human/aquila_explosion_probe/listener = allocate(/mob/living/carbon/human/aquila_explosion_probe)
	GLOB.player_list += lobby_player
	GLOB.player_list += listener
	explosion(run_loc_floor_bottom_left, 0, 0, 0, 0, adminlog = FALSE)
	GLOB.player_list -= lobby_player
	GLOB.player_list -= listener
	TEST_ASSERT(listener.heard_explosion, "A player after the lobby player did not hear the explosion")

	// Trafienie, które zburzyło ścianę (np. laser w ścianę plazmową): odłamki nie wołają procki ściany na podłodze
	var/turf/wall_spot = run_loc_floor_top_right
	var/wall_spot_type = wall_spot.type
	var/old_particles_enabled = GLOB.impact_particles_enabled
	GLOB.impact_particles_enabled = TRUE
	var/turf/closed/wall/collapsing = wall_spot.ChangeTurf(/turf/closed/wall/aquila_collapsing_test)
	var/obj/item/projectile/beam/beam = allocate(/obj/item/projectile/beam)
	collapsing.bullet_act(beam)
	GLOB.impact_particles_enabled = old_particles_enabled
	TEST_ASSERT(!iswallturf(wall_spot), "Test wall did not collapse on hit")
	wall_spot.ChangeTurf(wall_spot_type)

/// Mob, który zapamiętuje, że usłyszał wybuch
/mob/living/carbon/human/aquila_explosion_probe
	var/heard_explosion = FALSE

/mob/living/carbon/human/aquila_explosion_probe/playsound_local(turf/turf_source, soundin, vol, vary, frequency, falloff_exponent, channel, pressure_affected, sound/S, max_distance, falloff_distance, distance_multiplier, use_reverb, volume_pref)
	heard_explosion = TRUE

/// Ściana, która przy trafieniu zamienia się w podłogę przed resztą bullet_act(), jak ściana plazmowa po laserze (bez gazu)
/turf/closed/wall/aquila_collapsing_test

/turf/closed/wall/aquila_collapsing_test/bullet_act(obj/item/projectile/P, def_zone, piercing_hit = FALSE)
	ScrapeAway()
	return ..()

#undef TEST_ASSERT
