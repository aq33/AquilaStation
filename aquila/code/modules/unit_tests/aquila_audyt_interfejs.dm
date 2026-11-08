// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

// Regresje z audytu (grupa interfejs). Każdy test odtwarza zgłoszony przypadek i sprawdza wynik.

/// Gracz w lobby bez klienta: zapisuje, co okno przekazało do Topic(), bo prawdziwy Topic() wymaga klienta
/mob/dead/new_player/aquila_ready_probe
	var/list/last_href

/mob/dead/new_player/aquila_ready_probe/Topic(href, list/href_list)
	last_href = href_list

/// AQUILA - przycisk „Nie gotowy” w lobby przekazuje do Topic() wartość, która przechodzi if(href_list["ready"])
/datum/unit_test/aquila_audyt_lobby_unready

/datum/unit_test/aquila_audyt_lobby_unready/Run()
	var/mob/dead/new_player/aquila_ready_probe/player = allocate(/mob/dead/new_player/aquila_ready_probe)
	var/datum/tgui/ui = new(player, player, "LobbyMenu")
	player.ui_act("ready", list("ready" = PLAYER_NOT_READY), ui)
	qdel(ui)
	TEST_ASSERT(player.last_href, "The ready button did not reach Topic()")
	// new_player.dm: if(href_list["ready"]) — liczba 0 tego nie przechodziła
	TEST_ASSERT(player.last_href["ready"], "Not ready was sent as a falsy value, so Topic() ignores it")
	TEST_ASSERT_EQUAL(text2num(player.last_href["ready"]), PLAYER_NOT_READY, "Not ready reached Topic() as a different value")

/// AQUILA - konsola ID odbiera pojedynczy dostęp z karty (allowed = false z okna)
/datum/unit_test/aquila_audyt_card_access_removal

/datum/unit_test/aquila_audyt_card_access_removal/Run()
	var/mob/living/carbon/human/hop = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/machinery/computer/card/console = allocate(/obj/machinery/computer/card, get_step(run_loc_floor_bottom_left, EAST))
	var/obj/item/card/id/target_id = allocate(/obj/item/card/id, console)
	target_id.access = list(ACCESS_ARMORY)
	console.inserted_modify_id = target_id
	console.authenticated = 2
	var/datum/tgui/ui = new(hop, console, "IdentificationConsole")
	usr = hop
	console.ui_act("access", list("access" = ACCESS_ARMORY, "allowed" = FALSE), ui)
	var/removed = !(ACCESS_ARMORY in target_id.access)
	console.ui_act("access", list("access" = ACCESS_ARMORY, "allowed" = TRUE), ui)
	var/added = (ACCESS_ARMORY in target_id.access)
	usr = null
	console.inserted_modify_id = null
	qdel(ui)
	TEST_ASSERT(removed, "Unticking an access in the ID console did not remove it from the card")
	TEST_ASSERT(added, "Ticking an access in the ID console did not add it back")

/// AQUILA - SI w rdzeniu na baterii zapasowej nie traci zasilania przy padniętym APC; kompresja pamięci nie zawyża puli RAM
/datum/unit_test/aquila_audyt_ai_core_power

/datum/unit_test/aquila_audyt_ai_core_power/Run()
	var/turf/left = run_loc_floor_bottom_left
	var/turf/right = get_step(left, EAST)
	var/turf/up = get_step(left, NORTH)
	var/turf/up_right = get_step(right, NORTH)
	// Działająca konsola komunikacyjna, żeby usunięcie SI nie wezwało promu (autoEvac)
	allocate(/obj/machinery/computer/communications, get_step(right, EAST))
	for(var/turf/cable_turf in list(left, up))
		allocate(/obj/structure/ethernet_cable, cable_turf)
	var/obj/machinery/ai/data_core/primary/core = allocate(/obj/machinery/ai/data_core/primary, left)
	core.integrated_battery = new /obj/item/stock_parts/cell/high(core)
	allocate(/obj/machinery/ai/server_cabinet/prefilled, up)
	var/mob/living/carbon/human/brain_holder = allocate(/mob/living/carbon/human, up_right)
	var/mob/living/silicon/ai/ai = allocate(/mob/living/silicon/ai, up_right, null, brain_holder)
	TEST_ASSERT_EQUAL(ai.loc, core, "AI did not move into the data core")

	// APC komory pada: obszar bez prądu, rdzeń dalej działa na baterii
	var/area/core_area = get_area(core)
	var/old_power_equip = core_area.power_equip
	core_area.power_equip = FALSE
	core.machine_stat |= NOPOWER
	var/lacks_with_battery = ai.lacks_power()
	var/obj/item/stock_parts/cell/battery = core.integrated_battery
	core.integrated_battery = null
	var/lacks_without_battery = ai.lacks_power()
	core.integrated_battery = battery
	core.machine_stat &= ~NOPOWER
	core_area.power_equip = old_power_equip
	TEST_ASSERT(!lacks_with_battery, "AI in a battery-powered data core lost power with the room APC, so it relocated into the same core every Life()")
	TEST_ASSERT(lacks_without_battery, "AI in an unpowered data core without a battery still has power")

	// Kompresja pamięci (free_ram) to RAM doliczany osobno, nie pula serwerów
	var/datum/ai_os/os = core.get_os()
	TEST_ASSERT(os, "Data core has no resource system")
	os.set_ram(ai, 0)
	ai.dashboard.free_ram = 3
	os.set_ram(ai, os.total_ram + 3)
	var/over_assigned = os.ram_assigned[ai]
	os.set_ram(ai, os.total_ram + 3, adjust_overflow = TRUE)
	var/clamped = os.ram_assigned[ai]
	var/total_assigned = os.total_ram_assigned()
	ai.dashboard.free_ram = 0
	os.set_ram(ai, 0)
	TEST_ASSERT(over_assigned <= os.total_ram, "Free RAM let the AI take more RAM than the servers have ([over_assigned] > [os.total_ram])")
	TEST_ASSERT_EQUAL(clamped, os.total_ram, "Clamped RAM is not the whole server pool")
	TEST_ASSERT_EQUAL(total_assigned, clamped, "Total assigned RAM subtracts free RAM")

/// AQUILA - drgawka dezorientacji nie nadpisuje przesunięcia ustawionego w trakcie (upadek)
/datum/unit_test/aquila_audyt_disorient_twitch

/datum/unit_test/aquila_audyt_disorient_twitch/Run()
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human)
	victim.pixel_y = 0
	INVOKE_ASYNC(victim, TYPE_PROC_REF(/atom/movable, twitch))
	// Upadek w trakcie drgawki ustawia przesunięcie leżącego bezwzględnie
	victim.pixel_y = -6
	sleep(1 SECONDS)
	TEST_ASSERT(abs(victim.pixel_y + 6) <= 1, "The twitch restored the old pixel_y over the lying offset (pixel_y = [victim.pixel_y])")

/// AQUILA - otwarte okno VotePanel zamyka się, gdy zaczyna się głosowanie na mapę (okno MapVote)
/datum/unit_test/aquila_audyt_vote_window_kind

/datum/unit_test/aquila_audyt_vote_window_kind/Run()
	if(SSvote.current_vote)
		return
	var/datum/vote/map/map_vote = SSvote.possible_votes["Map"]
	TEST_ASSERT(istype(map_vote), "No map vote datum")
	var/mob/living/carbon/human/voter = allocate(/mob/living/carbon/human)
	var/datum/tgui/panel = new(voter, SSvote, "VotePanel")
	SStgui.on_open(panel)
	SSvote.current_vote = map_vote
	SSvote.close_mismatched_uis()
	SSvote.current_vote = null
	var/closed = panel.closing
	if(!closed)
		SStgui.on_close(panel)
	qdel(panel)
	TEST_ASSERT(closed, "An open VotePanel window stayed open when a map vote started")

/// AQUILA - okno analizatora pokazuje uszkodzone oczy przy głowie
/datum/unit_test/aquila_audyt_analyzer_eyes

/datum/unit_test/aquila_audyt_analyzer_eyes/Run()
	var/mob/living/carbon/human/doctor = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/item/organ/eyes/eyes = patient.getorganslot(ORGAN_SLOT_EYES)
	TEST_ASSERT(eyes, "The patient has no eyes")
	eyes.applyOrganDamage(30)
	var/obj/item/healthanalyzer/analyzer = allocate(/obj/item/healthanalyzer)
	analyzer.ui_target = WEAKREF(patient)
	var/list/data = analyzer.ui_data(doctor)
	var/list/head = data["injuries"][BODY_ZONE_HEAD]
	var/found = FALSE
	for(var/list/injury as anything in head)
		if(findtext(injury["name"], capitalize(eyes.name)))
			found = TRUE
			break
	TEST_ASSERT(found, "Damaged eyes are not listed at the head in the analyzer window")

/// AQUILA - stos włożony do jamy ciała nie traci sztuki
/datum/unit_test/aquila_audyt_cavity_stack

/datum/unit_test/aquila_audyt_cavity_stack/Run()
	var/mob/living/carbon/human/surgeon = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	ADD_TRAIT(surgeon, TRAIT_IGNORE_SURGERY_MODIFIERS, TRAIT_SOURCE_UNIT_TESTS)
	ADD_TRAIT(surgeon, TRAIT_STUNIMMUNE, TRAIT_SOURCE_UNIT_TESTS)
	ADD_TRAIT(patient, TRAIT_STUNIMMUNE, TRAIT_SOURCE_UNIT_TESTS)
	surgeon.zone_selected = BODY_ZONE_CHEST
	patient.set_resting(TRUE)
	patient.toggle_surgery_prep(surgeon, BODY_ZONE_CHEST)
	var/obj/item/bodypart/chest/chest = patient.get_bodypart(BODY_ZONE_CHEST)
	chest.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|SURGERY_CAVITY_WIDENED)
	var/obj/item/stack/telecrystal/crystals = allocate(/obj/item/stack/telecrystal, null, 5)
	surgeon.put_in_active_hand(crystals)
	var/datum/surgery_operation/cavity = GLOB.operations.operations_by_typepath[/datum/surgery_operation/limb/cavity_implant]
	cavity.try_perform(chest, surgeon, crystals, list(OPERATION_TARGET_ZONE = BODY_ZONE_CHEST))
	TEST_ASSERT_EQUAL(chest.cavity_item, crystals, "The telecrystals did not go into the chest cavity")
	TEST_ASSERT(!QDELETED(crystals), "The implanted stack was deleted")
	TEST_ASSERT_EQUAL(crystals.amount, 5, "The implanted stack lost a piece")
	chest.cavity_item = null

/// AQUILA - nastrój po operacji jak w tg: sukces -1, porażka -6
/datum/unit_test/aquila_audyt_surgery_mood

/datum/unit_test/aquila_audyt_surgery_mood/Run()
	var/datum/mood_event/surgery/success/success = new
	var/datum/mood_event/surgery/failure/failure = new
	var/success_change = success.mood_change
	var/failure_change = failure.mood_change
	qdel(success)
	qdel(failure)
	TEST_ASSERT_EQUAL(success_change, -1, "A successful surgery step hurts the mood as much as being cut awake")
	TEST_ASSERT_EQUAL(failure_change, -6, "A failed surgery step has the wrong mood")

/// AQUILA - sprint: druga śluza w blokadzie bumpa i ślizg po ścianie po skosie nie przewracają
/datum/unit_test/aquila_audyt_sprint_bumps

/datum/unit_test/aquila_audyt_sprint_bumps/Run()
	var/mob/living/carbon/human/runner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/wall = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
	var/obj/machinery/door/airlock/airlock = allocate(/obj/machinery/door/airlock, get_step(run_loc_floor_bottom_left, NORTH))
	var/datum/component/carbon_sprint/sprint = runner.GetComponent(/datum/component/carbon_sprint)
	TEST_ASSERT(sprint, "Humans have no sprint component")
	wall.set_combat_mode(TRUE)
	TEST_ASSERT(sprint.is_hard_obstacle(airlock), "A closed airlock is not an obstacle")
	runner.m_intent = MOVE_INTENT_RUN
	SEND_SIGNAL(runner, COMSIG_KB_CARBON_SPRINT_DOWN)

	// Drugi krok skosu po udanym pierwszym: ślizg po przeszkodzie
	sprint.sprinting = TRUE
	sprint.last_sprint_step = world.time
	sprint.sustained_moves = SPRINT_WALLSLAM_MIN_MOVES + 2
	runner.moving_diagonally = SECOND_DIAG_STEP
	SEND_SIGNAL(runner, COMSIG_MOVABLE_BUMP, wall)
	runner.moving_diagonally = 0
	sleep(5)
	var/slammed_diagonal = runner.IsKnockdown()
	runner.SetKnockdown(0)

	// Śluza zaraz po poprzedniej: blokada bumpa (raz na sekundę) trzyma ją zamkniętą
	sprint.sprinting = TRUE
	sprint.last_sprint_step = world.time
	sprint.sustained_moves = SPRINT_WALLSLAM_MIN_MOVES + 2
	runner.last_bumped = world.time
	SEND_SIGNAL(runner, COMSIG_MOVABLE_BUMP, airlock)
	sleep(5)
	var/slammed_door = runner.IsKnockdown()
	runner.SetKnockdown(0)
	TEST_ASSERT(!slammed_diagonal, "Sliding along a wall on the second diagonal step knocked the runner down")
	TEST_ASSERT(!slammed_door, "An airlock kept shut only by the bump cooldown knocked the runner down")

/// AQUILA - po odpięciu kroplówki pacjent wraca na miejsce, także gdy drgawki wyzerowały ciągnięcie
/datum/unit_test/aquila_audyt_iv_tug_jitter

/datum/unit_test/aquila_audyt_iv_tug_jitter/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	var/obj/machinery/iv_drip/drip = allocate(/obj/machinery/iv_drip, get_step(patient, EAST))
	var/start_x = patient.pixel_x
	drip.attached = patient
	drip.update_icon()
	TEST_ASSERT(patient.pixel_x > start_x, "The patient was not pulled towards the drip")
	// Koniec drgawek ustawia przesunięcie bezwzględnie (living.dm do_jitter_animation)
	patient.pixel_x = patient.base_pixel_x + patient.get_standard_pixel_x_offset(patient.lying)
	drip.attached = null
	drip.update_icon()
	TEST_ASSERT_EQUAL(patient.pixel_x, start_x, "The patient was shifted away from the drip after detaching")

/// AQUILA - błąd typu w skrypcie NTSL trafia do logu serwera, a wiadomość przechodzi
/datum/unit_test/aquila_audyt_ntsl_type_error

/datum/unit_test/aquila_audyt_ntsl_type_error/Run()
	var/obj/machinery/telecomms/server/server = allocate(/obj/machinery/telecomms/server)
	var/datum/TCS_Compiler/compiler = server.Compiler
	var/list/errors = compiler.Compile({"def process_signal(sig){
	sig.content = "abc" - 1;
	return sig;
}"})
	TEST_ASSERT(!length(errors), "The type error script did not compile")
	var/mob/living/carbon/human/speaker = allocate(/mob/living/carbon/human)
	var/obj/item/radio/radio = allocate(/obj/item/radio)
	var/atom/movable/virtualspeaker/virt = new(null, speaker, radio)
	var/datum/signal/subspace/vocal/signal = new(radio, FREQ_COMMON, virt, /datum/language/common, "Halo", list(), list())
	var/runtimes_before = GLOB.total_runtimes
	compiler.Run(signal)
	TEST_ASSERT_EQUAL(GLOB.total_runtimes, runtimes_before, "A type error in a script caused a BYOND runtime")
	TEST_ASSERT_EQUAL(signal.data["message"], "Halo", "The message was changed by a failed script")
	TEST_ASSERT(!signal.data["reject"], "The message was rejected by a failed script")
	var/logged = FALSE
	for(var/datum/comm_log_entry/entry in server.log_entries)
		if(entry.input_type == "Błąd wykonania")
			logged = TRUE
			break
	TEST_ASSERT(logged, "The type error is not in the server log")

/// AQUILA - moduł infiltracyjny (COMSIG_TRY_MODIFY_SPEECH) wyłącza syk języka jaszczura
/datum/unit_test/aquila_audyt_infiltrator_speech

/datum/unit_test/aquila_audyt_infiltrator_speech/proc/block_speech(datum/source)
	SIGNAL_HANDLER
	return PREVENT_MODIFY_SPEECH

/datum/unit_test/aquila_audyt_infiltrator_speech/Run()
	var/mob/living/carbon/human/speaker = allocate(/mob/living/carbon/human)
	var/obj/item/organ/tongue/lizard/tongue = allocate(/obj/item/organ/tongue/lizard)
	var/list/speech_args = list("sos", null, null, null, /datum/language/common, null, null)
	tongue.try_handle_speech(speaker, speech_args)
	TEST_ASSERT_EQUAL(speech_args[SPEECH_MESSAGE], "sssosss", "The lizard tongue did not hiss")
	RegisterSignal(speaker, COMSIG_TRY_MODIFY_SPEECH, PROC_REF(block_speech))
	speech_args[SPEECH_MESSAGE] = "sos"
	tongue.try_handle_speech(speaker, speech_args)
	UnregisterSignal(speaker, COMSIG_TRY_MODIFY_SPEECH)
	TEST_ASSERT_EQUAL(speech_args[SPEECH_MESSAGE], "sos", "The infiltrator module did not stop the lizard hiss")

/// AQUILA - licznik S.M.A.R.T. nie liczy pustych łusek w bębnie rewolweru
/datum/unit_test/aquila_audyt_ammo_counter_revolver

/datum/unit_test/aquila_audyt_ammo_counter_revolver/Run()
	var/obj/item/organ/cyberimp/arm/ammo_counter/counter_implant = allocate(/obj/item/organ/cyberimp/arm/ammo_counter)
	var/obj/item/gun/ballistic/revolver/detective/revolver = allocate(/obj/item/gun/ballistic/revolver/detective)
	counter_implant.our_gun = revolver
	TEST_ASSERT_EQUAL(counter_implant.shots_left(), revolver.magazine.ammo_count(FALSE), "A loaded revolver shows the wrong number of shots")
	for(var/obj/item/ammo_casing/casing in revolver.magazine.stored_ammo)
		QDEL_NULL(casing.BB)
	var/shots = counter_implant.shots_left()
	counter_implant.our_gun = null
	TEST_ASSERT_EQUAL(shots, 0, "An emptied revolver still shows shots")

/// AQUILA - instrukcja LTSRBT o akcji dodatkowej idzie przez secondary_click_text()
/datum/unit_test/aquila_audyt_ltsrbt_examine

/datum/unit_test/aquila_audyt_ltsrbt_examine/Run()
	var/mob/living/carbon/human/viewer = allocate(/mob/living/carbon/human)
	var/obj/machinery/ltsrbt/pad = allocate(/obj/machinery/ltsrbt)
	var/examine_text = jointext(pad.examine(viewer), "\n")
	TEST_ASSERT(!findtext(examine_text, "prawy klik"), "LTSRBT still names the right click directly")
	TEST_ASSERT(findtext(examine_text, viewer.secondary_click_text()), "LTSRBT does not tell how to reach the secondary action")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
