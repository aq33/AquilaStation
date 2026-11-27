// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Assertion failed: [message || "No message"]. Expected [b], got [a]") }

/// AQUILA - wspólny rdzeń kartoteki (aquila/code/modules/security/criminal_status.dm):
/// status ląduje w rekordzie ochrony (także gdy podano ogólny), dopisuje historię i ogłasza jeden komunikat na właściwych kanałach.
/// Regresja: GenPop pisał „Incarcerated”/„Discharged” do rekordu ogólnego, więc HUD ochrony go nie widział.
/datum/unit_test/aquila_criminal_status
	var/list/announcements = list()
	var/list/created_records = list()

/datum/unit_test/aquila_criminal_status/proc/on_announce(datum/source, message, list/channels)
	SIGNAL_HANDLER
	announcements += list(list(message, channels.Copy()))

/datum/unit_test/aquila_criminal_status/proc/make_records(name)
	var/id = "aquila_test_[name]_[world.time]_[rand(1, 99999)]"
	var/datum/data/record/general = new
	general.fields["name"] = name
	general.fields["id"] = id
	GLOB.data_core.general += general
	var/datum/data/record/security = new
	security.fields["name"] = name
	security.fields["id"] = id
	security.fields["criminal"] = "None"
	security.fields["crim"] = list()
	security.fields["citation"] = list()
	GLOB.data_core.security += security
	created_records += general
	created_records += security
	return list(general, security)

/datum/unit_test/aquila_criminal_status/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_AQ_SECURITY_ANNOUNCE)
	for(var/datum/data/record/record as anything in created_records)
		GLOB.data_core.general -= record
		GLOB.data_core.security -= record
		qdel(record)
	created_records = null
	return ..()

/datum/unit_test/aquila_criminal_status/Run()
	RegisterSignal(SSdcs, COMSIG_GLOB_AQ_SECURITY_ANNOUNCE, PROC_REF(on_announce))

	// Rdzeń: rekord ogólny na wejściu, zmiana w rekordzie ochrony, historia i jedno ogłoszenie (Arrest idzie też do Dowództwa)
	var/list/records = make_records("Testowy Podejrzany")
	var/datum/data/record/general = records[1]
	var/datum/data/record/security = records[2]
	TEST_ASSERT(GLOB.data_core.set_criminal_status(general, "Arrest", "Testowy Żandarm", "kradzież"), "set_criminal_status nie zgłosił zmiany")
	TEST_ASSERT_EQUAL(security.fields["criminal"], "Arrest", "Status nie trafił do rekordu ochrony")
	TEST_ASSERT(isnull(general.fields["criminal"]), "Status trafił do rekordu ogólnego")
	TEST_ASSERT(findtext(security.fields["com_1"], "kradzież"), "Historia rekordu nie ma powodu: [security.fields["com_1"]]")
	TEST_ASSERT_EQUAL(length(announcements), 1, "Liczba ogłoszeń po zmianie statusu")
	var/list/channels = announcements[1][2]
	TEST_ASSERT((RADIO_CHANNEL_SECURITY in channels) && (RADIO_CHANNEL_COMMAND in channels), "Aresztowanie nie poszło na kanały Żandarmerii i Dowództwa")

	// Ten sam status: bez zmiany i bez ogłoszenia; Monitor tylko na kanał Żandarmerii
	TEST_ASSERT(!GLOB.data_core.set_criminal_status(security, "Arrest", "Testowy Żandarm"), "Powtórzony status liczy się jako zmiana")
	TEST_ASSERT_EQUAL(length(announcements), 1, "Powtórzony status został ogłoszony")
	GLOB.data_core.set_criminal_status(security, "Monitor", "Testowy Żandarm")
	TEST_ASSERT_EQUAL(length(announcements), 2, "Liczba ogłoszeń po drugiej zmianie")
	channels = announcements[2][2]
	TEST_ASSERT(!(RADIO_CHANNEL_COMMAND in channels), "Obserwacja poszła do Dowództwa")
	TEST_ASSERT(security.fields["com_2"], "Druga zmiana nie dopisała historii")

	// Regresja GenPop: osadzenie przez terminal i koniec wyroku na karcie zmieniają rekord ochrony
	var/list/prisoner_records = make_records("Testowy Więzień")
	var/datum/data/record/prisoner_security = prisoner_records[2]
	var/mob/living/carbon/human/officer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/machinery/genpop_interface/genpop = allocate(/obj/machinery/genpop_interface, run_loc_floor_bottom_left)
	genpop.desired_name = "Testowy Więzień"
	genpop.print_id(officer, "Kradzież", 10 MINUTES)
	TEST_ASSERT_EQUAL(prisoner_security.fields["criminal"], "Incarcerated", "GenPop nie ustawił statusu w rekordzie ochrony")
	var/obj/item/card/id/prisoner/card = locate() in run_loc_floor_bottom_left
	TEST_ASSERT(card, "GenPop nie wydrukował karty więźnia")
	card.served_time = card.sentence
	card.process(1)
	TEST_ASSERT_EQUAL(prisoner_security.fields["criminal"], "Discharged", "Koniec wyroku nie ustawił statusu w rekordzie ochrony")
	for(var/obj/item/leftover in run_loc_floor_bottom_left)
		if(istype(leftover, /obj/item/card/id/prisoner) || istype(leftover, /obj/item/paper))
			qdel(leftover)

	// Mandat po terminie: niespłacony daje wykroczenie i „do aresztowania”, spłacony nic nie zmienia, osadzony zostaje osadzonym
	var/list/fined_records = make_records("Testowy Dłużnik")
	var/datum/data/record/fined = fined_records[2]
	var/datum/data/crime/citation = GLOB.data_core.createCrimeEntry("Drobny wandalizm", "", "Testowy Żandarm", station_time_timestamp(), 100)
	GLOB.data_core.addCitation(fined.fields["id"], citation)
	citation.paid = 100
	TEST_ASSERT(!GLOB.data_core.aq_citation_deadline(fined.fields["id"], citation.dataId), "Spłacony mandat uznany za zaległy")
	TEST_ASSERT_EQUAL(fined.fields["criminal"], "None", "Spłacony mandat zmienił status")
	citation.paid = 50
	TEST_ASSERT(GLOB.data_core.aq_citation_deadline(fined.fields["id"], citation.dataId), "Częściowo spłacony mandat nie jest zaległy")
	TEST_ASSERT_EQUAL(fined.fields["criminal"], "Arrest", "Zaległy mandat nie wystawił nakazu")
	var/list/fined_crimes = fined.fields["crim"]
	TEST_ASSERT_EQUAL(length(fined_crimes), 1, "Zaległy mandat nie dopisał wykroczenia")
	GLOB.data_core.set_criminal_status(fined, "Incarcerated", "Testowy Żandarm", announce = FALSE)
	GLOB.data_core.aq_citation_deadline(fined.fields["id"], citation.dataId)
	TEST_ASSERT_EQUAL(fined.fields["criminal"], "Incarcerated", "Zaległy mandat cofnął osadzonego do poszukiwanego")

	// Alarm śmierci: zgon nosiciela daje jeden komunikat na kanały Żandarmerii i Medyczny
	var/mob/living/carbon/human/victim = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	victim.real_name = "Testowy Nieboszczyk"
	var/obj/item/implant/security_down/crew/alarm = new
	TEST_ASSERT(alarm.implant(victim, null, TRUE, TRUE), "Implant alarmu śmierci się nie wszczepił")
	victim.death()
	var/before = length(announcements)
	var/death_message = flush_death_alarms()
	TEST_ASSERT(findtext(death_message, "Testowy Nieboszczyk"), "Alarm śmierci nie podał imienia: [death_message]")
	TEST_ASSERT_EQUAL(length(announcements), before + 1, "Liczba komunikatów alarmu śmierci")
	channels = announcements[length(announcements)][2]
	TEST_ASSERT((RADIO_CHANNEL_SECURITY in channels) && (RADIO_CHANNEL_MEDICAL in channels), "Alarm śmierci nie poszedł na kanały Żandarmerii i Medyczny")
	TEST_ASSERT(isnull(flush_death_alarms()), "Pusta kolejka alarmów nadała komunikat")

	// Zegar celi: start z osadzonym daje „w areszcie”, ostrzeżenie przed końcem, pauza trzyma czas, ułaskawienie zwalnia
	var/list/cell_records = make_records("Testowy Osadzony")
	var/datum/data/record/cell_security = cell_records[2]
	var/obj/machinery/door_timer/cell = allocate(/obj/machinery/door_timer, run_loc_floor_bottom_left)
	cell.set_machine_stat(NONE)
	cell.prisoner_name = "Testowy Osadzony"
	cell.prisoner_crimes = "Drobny wandalizm"
	TEST_ASSERT(aq_sentence_for_crimes(list("Drobny wandalizm")) > 0, "Kodeks nie podał wyroku za drobny wandalizm")
	cell.set_timer(2 MINUTES)
	TEST_ASSERT(cell.timer_start(), "Zegar celi się nie uruchomił")
	TEST_ASSERT_EQUAL(cell_security.fields["criminal"], "Incarcerated", "Start zegara nie ustawił statusu")
	cell.set_timer(20 SECONDS)
	cell.process()
	TEST_ASSERT(cell.end_warned, "Zegar nie ostrzegł przed końcem wyroku")
	TEST_ASSERT(cell.pause_timer(), "Zegar się nie zapauzował")
	TEST_ASSERT(!cell.timing && cell.paused_left > 0 && cell.paused_left <= 20 SECONDS, "Pauza nie zachowała pozostałego czasu: [cell.paused_left]")
	TEST_ASSERT(cell.resume_timer() && cell.timing, "Zegar nie wznowił odliczania")
	TEST_ASSERT(cell.pardon(null), "Ułaskawienie nie zadziałało")
	TEST_ASSERT_EQUAL(cell_security.fields["criminal"], "Discharged", "Ułaskawienie nie dało statusu po odbyciu kary")
	TEST_ASSERT(isnull(cell.prisoner_name), "Po zwolnieniu zegar dalej pamięta osadzonego")
	// Ręczne zatrzymanie przed końcem: zwolnienie warunkowe
	cell.prisoner_name = "Testowy Osadzony"
	cell.set_timer(2 MINUTES)
	cell.timer_start()
	cell.timer_end(forced = TRUE)
	TEST_ASSERT_EQUAL(cell_security.fields["criminal"], "Paroled", "Zatrzymanie zegara nie dało zwolnienia warunkowego")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
