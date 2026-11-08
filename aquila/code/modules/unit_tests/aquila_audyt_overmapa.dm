// AQUILA - regressions from the overmap / jukebox audit group (fleets, station boarding, Syndicate troopers, fighters, jukebox, distant shots).
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// The last warship of a defence (boss) fleet does not run: its escape used to take the whole fleet out of the system.
/// Other fleets, and a defence fleet with more warships left, still can.
/datum/unit_test/aquila_audyt_defense_fleet_last_ship

/datum/unit_test/aquila_audyt_defense_fleet_last_ship/Run()
	var/obj/structure/overmap/syndicate/ai/gunboat/morale_test/ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	var/obj/structure/overmap/syndicate/ai/gunboat/morale_test/escort = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	var/datum/fleet/fleet = new
	fleet.all_ships = list(ship)
	ship.fleet = fleet
	TEST_ASSERT(ship.can_ai_flee(), "A lone ship of an ordinary fleet may not flee, the test cannot check the defence fleet")
	fleet.fleet_trait = FLEET_TRAIT_DEFENSE
	var/lone_can_flee = ship.can_ai_flee()
	ship.ai_fleeing = TRUE
	ship.update_ai_morale()
	var/still_fleeing = ship.ai_fleeing
	fleet.all_ships += escort
	escort.fleet = fleet
	var/escorted_can_flee = ship.can_ai_flee()
	for(var/obj/structure/overmap/OM as anything in fleet.all_ships)
		OM.fleet = null
	fleet.all_ships = list()
	TEST_ASSERT(!lone_can_flee, "The last warship of a defence fleet may still flee (it would take the whole fleet out of the system)")
	TEST_ASSERT(!still_fleeing, "The last warship of a defence fleet kept running after it lost the way out")
	TEST_ASSERT(escorted_can_flee, "A defence fleet ship with another warship beside it may not flee any more")

/// Station boarding: a counterattack fleet that retreats counts as repelled (the objective used to wait only for the fleet to be deleted)
/datum/unit_test/aquila_audyt_board_station_retreat
	var/list/saved_alignment = list()
	var/list/saved_mission = list()

/datum/unit_test/aquila_audyt_board_station_retreat/Run()
	var/datum/star_system/player_system = SSstar_system.find_main_overmap()?.current_system
	var/datum/star_system/home
	for(var/datum/star_system/system as anything in SSstar_system.systems)
		if(system == player_system || system.hidden || !length(system.adjacency_list))
			continue
		var/has_way_out = FALSE
		for(var/system_name in system.adjacency_list)
			var/datum/star_system/next = SSstar_system.system_by_id(system_name)
			if(next && !next.hidden && next != player_system)
				has_way_out = TRUE
				break
		if(has_way_out)
			home = system
			break
	if(!home)
		return // No connected star systems in this run
	var/list/touched = list(home)
	for(var/system_name in home.adjacency_list)
		var/datum/star_system/next = SSstar_system.system_by_id(system_name)
		if(next)
			touched += next
	for(var/datum/star_system/system as anything in touched)
		saved_alignment[system] = system.alignment
		saved_mission[system] = system.mission_sector
	var/list/saved_contested = SSstar_system.contested_systems.Copy()

	var/datum/overmap_objective/board_station/objective = new(home)
	objective.target_station = new /datum // Only unregistered from on completion
	var/obj/structure/overmap/syndicate/ai/gunboat/morale_test/ship = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	var/datum/fleet/fleet = new
	fleet.current_system = home
	fleet.hide_movements = TRUE
	fleet.can_reinforce = FALSE
	fleet.ai_retreat_paid = TRUE // No reward maths in a test
	fleet.all_ships = list(ship)
	home.fleets += fleet
	objective.reinforcements = fleet
	objective.watch_counterattack_retreat()
	fleet.try_ai_retreat_jump()
	var/moved = fleet.current_system != home
	var/complete = objective.defense_complete
	var/status = objective.status

	fleet.current_system?.fleets -= fleet
	home.fleets -= fleet
	fleet.current_system = null
	fleet.all_ships = list()
	for(var/datum/star_system/system as anything in touched)
		system.alignment = saved_alignment[system]
		system.mission_sector = saved_mission[system]
	SSstar_system.contested_systems = saved_contested
	qdel(objective)
	TEST_ASSERT(moved, "The test counterattack fleet did not retreat to a neighbouring system")
	TEST_ASSERT(complete, "A counterattack fleet that retreated did not count as repelled")
	TEST_ASSERT_EQUAL(status, 1, "The station boarding objective was not completed after the counterattack retreated")

/// The armed Syndicate trooper in a space suit on the boarding maps actually fires a bullet
/datum/unit_test/aquila_audyt_space_syndicate_shoots

/datum/unit_test/aquila_audyt_space_syndicate_shoots/Run()
	var/mob/living/simple_animal/hostile/nsv/syndicate/space/ranged/trooper = allocate(/mob/living/simple_animal/hostile/nsv/syndicate/space/ranged)
	var/turf/target_turf = locate(trooper.x + 3, trooper.y, trooper.z)
	trooper.Shoot(target_turf)
	var/obj/item/ammo_casing/casing = locate() in get_turf(trooper)
	TEST_ASSERT(casing, "The armed Syndicate trooper in a space suit fired without any bullet")
	TEST_ASSERT(!casing.BB, "The trooper's casing still holds its bullet after the shot")

/// A deleted torpedo ship leaves the cached ship list of its fleet's salvo (hard delete when nobody fires at that target again)
/datum/unit_test/aquila_audyt_salvo_forgets_dead_ship

/datum/unit_test/aquila_audyt_salvo_forgets_dead_ship/Run()
	var/was_enabled = GLOB.ai_morale_enabled
	GLOB.ai_morale_enabled = TRUE
	var/obj/structure/overmap/syndicate/ai/gunboat/morale_test/torpedo/first = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test/torpedo)
	var/obj/structure/overmap/syndicate/ai/gunboat/morale_test/torpedo/second = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test/torpedo)
	var/obj/structure/overmap/small_craft/enemy = allocate(/obj/structure/overmap/small_craft/combat/light)
	enemy.faction = "nanotrasen"
	enemy.forceMove(locate(first.x + 10, first.y, first.z))
	var/datum/fleet/fleet = new
	fleet.ai_salvo_chance = 100
	fleet.all_ships = list(first, second)
	for(var/obj/structure/overmap/ship as anything in fleet.all_ships)
		ship.fleet = fleet
		ship.last_target = enemy
		ship.ai_temperament = "zwykły"
		ship.ai_fleeing = FALSE
	fleet.ai_salvo_allows(first, enemy)
	var/list/salvo = LAZYACCESS(fleet.ai_salvos, enemy)
	var/list/ships = salvo?[4]
	var/counted = (second in ships)
	second.destruction_effects = FALSE
	qdel(second)
	var/kept = (second in ships)
	first.fleet = null
	first.last_target = null
	fleet.all_ships = list()
	fleet.ai_salvos = null
	GLOB.ai_morale_enabled = was_enabled
	TEST_ASSERT(counted, "The second torpedo ship was not part of the salvo, the test cannot check the cleanup")
	TEST_ASSERT(!kept, "A destroyed torpedo ship stayed in its fleet's salvo ship list (hard delete)")

/// A fighter component destroyed in place gives back all of its weight drag once: the turn rate too, and the armour path not twice
/datum/unit_test/aquila_audyt_fighter_component_drag

/datum/unit_test/aquila_audyt_fighter_component_drag/Run()
	var/obj/structure/overmap/small_craft/combat/light/fighter = allocate(/obj/structure/overmap/small_craft/combat/light)
	var/obj/item/fighter_component/armour = fighter.loadout.get_slot(HARDPOINT_SLOT_ARMOUR)
	TEST_ASSERT(armour?.weight, "The test fighter has no armour with weight")
	var/turn_before = fighter.max_angular_acceleration
	var/weight = armour.weight
	qdel(armour)
	TEST_ASSERT_EQUAL(fighter.max_angular_acceleration, turn_before + weight * 10, "A deleted fighter component did not give back its turn rate drag")

	// The armour broken by hits: take_damage() deletes it, then small_craft/take_damage() removes it from its slot again
	var/obj/structure/overmap/small_craft/combat/light/second = allocate(/obj/structure/overmap/small_craft/combat/light)
	second.loadout.remove_hardpoint(HARDPOINT_SLOT_CANOPY, FALSE) // No canopy, so the hit cannot break it as well
	armour = second.loadout.get_slot(HARDPOINT_SLOT_ARMOUR)
	weight = armour.weight
	var/speed_before = second.speed_limit
	turn_before = second.max_angular_acceleration
	second.take_damage(armour.max_integrity * 100, BRUTE, "bomb", FALSE)
	TEST_ASSERT(QDELETED(armour), "The armour survived a hit far above its integrity, the test cannot check the armour path")
	TEST_ASSERT_EQUAL(second.speed_limit, speed_before + weight, "Armour broken by hits gave back its speed drag a wrong number of times")
	TEST_ASSERT_EQUAL(second.max_angular_acceleration, turn_before + weight * 10, "Armour broken by hits gave back its turn rate drag a wrong number of times")

/// Stand-ins for a client and its chat panel: SSjukeboxes only reads mob and tgui_panel and calls these four procs
/datum/aq_audyt_fake_panel
	var/ready = TRUE
	var/plays = 0
	var/stops = 0
	var/gains = 0

/datum/aq_audyt_fake_panel/proc/is_ready()
	return ready

/datum/aq_audyt_fake_panel/proc/play_music(url, extra_data)
	plays++

/datum/aq_audyt_fake_panel/proc/stop_music()
	stops++

/datum/aq_audyt_fake_panel/proc/set_music_gain(gain, echo = 0, muffle = 0)
	gains++

/datum/aq_audyt_fake_client
	var/mob/mob
	var/datum/aq_audyt_fake_panel/tgui_panel

/// Heard at a set gain, whoever listens
/datum/music_emitter/aq_audyt_test
	var/test_gain = 1

/datum/music_emitter/aq_audyt_test/hearing_gain(mob/M)
	return test_gain

/datum/music_emitter/aq_audyt_test/echo_amount(mob/M)
	return 0

/datum/music_emitter/aq_audyt_test/muffle_amount(mob/M)
	return 0

/obj/machinery/jukebox/aq_audyt_test
	var/datum/music_emitter/aq_audyt_test/test_emitter

/obj/machinery/jukebox/aq_audyt_test/Initialize()
	. = ..()
	test_emitter = new(src)

/obj/machinery/jukebox/aq_audyt_test/Destroy()
	QDEL_NULL(test_emitter)
	return ..()

/obj/machinery/jukebox/aq_audyt_test/active_emitters()
	return list(test_emitter)

/obj/machinery/jukebox/aq_audyt_test/emitter_max_gain(datum/music_emitter/source)
	return 1

/// Jukebox music in the browser: not marked as playing before the chat panel is ready (reconnect), sent again after someone else
/// stopped it (defeated fleet, admin) or the panel reloaded, and someone else's music is neither turned down nor cut off
/datum/unit_test/aquila_audyt_jukebox_foreign_music
	var/datum/aq_audyt_fake_client/listener
	var/obj/machinery/jukebox/aq_audyt_test/jukebox

/datum/unit_test/aquila_audyt_jukebox_foreign_music/Run()
	listener = new
	listener.tgui_panel = new
	jukebox = allocate(/obj/machinery/jukebox/aq_audyt_test)
	jukebox.yt_stream_url = "https://example.com/track.ogg"
	jukebox.yt_extra = list()
	jukebox.yt_track_started = world.time
	SSjukeboxes.yt_jukeboxes |= jukebox
	var/fail = check_music()
	SSjukeboxes.yt_jukeboxes -= jukebox
	SSjukeboxes.listening -= listener
	jukebox.yt_stream_url = null
	if(fail)
		return Fail(fail)

/datum/unit_test/aquila_audyt_jukebox_foreign_music/proc/check_music()
	var/datum/aq_audyt_fake_panel/panel = listener.tgui_panel
	// Reconnect: the panel is still loading and play_music would be dropped, so nothing may count as playing
	panel.ready = FALSE
	SSjukeboxes.update_client(listener)
	if(panel.plays || SSjukeboxes.listening[listener])
		return "The jukebox counted its track as playing for a chat panel that was not ready"
	panel.ready = TRUE
	SSjukeboxes.update_client(listener)
	if(panel.plays != 1)
		return "The jukebox did not send its track once the chat panel was ready ([panel.plays] plays)"
	SSjukeboxes.update_client(listener)
	if(panel.plays != 1)
		return "The jukebox sent the same track again on the next tick"
	// A defeated fleet (or an admin) stops the music in the browser: the track goes out again
	SSjukeboxes.on_foreign_music(listener, TRUE)
	SSjukeboxes.update_client(listener)
	if(panel.plays != 2)
		return "After someone else stopped the music the jukebox never sent its track again"
	// The chat panel reloaded (Fix chat): the new player is empty, the track goes out again
	SSjukeboxes.on_foreign_music(listener, TRUE)
	SSjukeboxes.update_client(listener)
	if(panel.plays != 3)
		return "After the chat panel reloaded the jukebox never sent its track again"
	// The player silenced the sounds on purpose (Zatrzymaj Dźwięki): the same track does not come back
	SSjukeboxes.on_foreign_music(listener, TRUE)
	SSjukeboxes.on_music_silenced(listener)
	SSjukeboxes.update_client(listener)
	if(panel.plays != 3)
		return "After the player silenced the sounds the jukebox sent the same track again"
	// An admin plays internet music: the jukebox leaves it alone, does not turn it down, and does not cut it off when the player walks away
	SSjukeboxes.on_foreign_music(listener, FALSE)
	var/gains_before = panel.gains
	jukebox.test_emitter.test_gain = 0.5
	SSjukeboxes.update_client(listener)
	if(panel.gains != gains_before || panel.plays != 3)
		return "The jukebox turned down or replaced music someone else was playing"
	jukebox.test_emitter.test_gain = 0
	SSjukeboxes.update_client(listener)
	if(panel.stops || SSjukeboxes.listening[listener])
		return "The jukebox stopped someone else's music when the player walked away"

/// The jukebox is processed by SSmachines only, also after Stop and Play again (it used to land in SSobj too, twice the shock countdown)
/datum/unit_test/aquila_audyt_jukebox_processing

/datum/unit_test/aquila_audyt_jukebox_processing/Run()
	var/obj/machinery/jukebox/jukebox = allocate(/obj/machinery/jukebox)
	var/list/track = list("title" = "Test", "webpage_url" = "https://example.com")
	jukebox.yt_start_track("https://example.com/track.ogg", track, 60)
	jukebox.yt_stop()
	jukebox.yt_start_track("https://example.com/track.ogg", track, 60)
	var/in_obj = (jukebox in SSobj.processing)
	var/in_machines = (jukebox in SSmachines.processing)
	jukebox.yt_stop()
	TEST_ASSERT(!in_obj, "A jukebox started again after Stop is processed by SSobj as well as SSmachines")
	TEST_ASSERT(in_machines, "A playing jukebox is not processed by SSmachines")

/// A bow and the toy crossbow are quiet: no distant gunshot for listeners far away. A laser still has one.
/datum/unit_test/aquila_audyt_bow_no_distant_shot

/datum/unit_test/aquila_audyt_bow_no_distant_shot/Run()
	var/mob/living/carbon/human/archer = allocate(/mob/living/carbon/human)
	var/obj/item/gun/ballistic/bow/bow = allocate(/obj/item/gun/ballistic/bow)
	var/obj/item/gun/ballistic/shotgun/toy/crossbow/crossbow = allocate(/obj/item/gun/ballistic/shotgun/toy/crossbow)
	var/obj/item/gun/energy/laser/laser = allocate(/obj/item/gun/energy/laser)
	bow.shoot_live_shot(archer)
	crossbow.shoot_live_shot(archer)
	laser.shoot_live_shot(archer)
	TEST_ASSERT(laser.last_distant_shot, "A laser sent no distant shot, the test cannot check the bow")
	TEST_ASSERT(!bow.last_distant_shot, "A bow sounded like a gunshot to listeners far away")
	TEST_ASSERT(!crossbow.last_distant_shot, "The toy crossbow sounded like a gunshot to listeners far away")

/// Voice pitch is a character setting in the preferences window again (it disappeared with the HTML menu)
/datum/unit_test/aquila_audyt_voice_pitch_preference

/datum/unit_test/aquila_audyt_voice_pitch_preference/Run()
	var/datum/preference/numeric/voice_pitch = GLOB.preference_entries_by_key["voice_pitch"]
	TEST_ASSERT(istype(voice_pitch), "There is no voice pitch entry in the preferences window")
	TEST_ASSERT_EQUAL(voice_pitch.feature_key, "voice_pitch", "The voice pitch entry does not write features\[\"voice_pitch\"\]")
	TEST_ASSERT(voice_pitch.should_show_on_page(PREFERENCE_TAB_CHARACTER_PREFERENCES), "The voice pitch entry is not on the character page")
	TEST_ASSERT_EQUAL(voice_pitch.deserialize("9"), VOICE_PITCH_MAX, "A pitch above the maximum was not clamped")
	TEST_ASSERT_EQUAL(voice_pitch.deserialize(-2.4), -2, "A pitch was not rounded to whole semitones")
	var/random_pitch = voice_pitch.create_random_value()
	TEST_ASSERT(random_pitch >= VOICE_PITCH_MIN && random_pitch <= VOICE_PITCH_MAX, "A random voice pitch is out of range ([random_pitch])")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
