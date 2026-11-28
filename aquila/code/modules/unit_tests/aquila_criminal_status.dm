// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Assertion failed: [message || "No message"]. Expected [b], got [a]") }

/// AQUILA - wspólny rdzeń kartoteki (aquila/code/modules/security/criminal_status.dm):
/// status ląduje w rekordzie ochrony (także gdy podano ogólny), dopisuje historię i ogłasza jeden komunikat na właściwych kanałach.
/// Regresja: GenPop pisał „Incarcerated”/„Discharged” do rekordu ogólnego, więc HUD ochrony go nie widział.
/datum/unit_test/aquila_criminal_status
	var/list/announcements = list()
	var/list/created_records = list()
	var/old_security_level

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
	if(!isnull(old_security_level))
		GLOB.security_level = old_security_level
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

	// Kaucja: stawka za minutę wyroku, nie przy dożywociu ani alarmie bojowym; wpłata zwalnia warunkowo
	var/list/bail_records = make_records("Testowy Poręczony")
	var/datum/data/record/bail_security = bail_records[2]
	var/obj/item/card/id/prisoner/bail_card = allocate(/obj/item/card/id/prisoner, run_loc_floor_bottom_left, 600, "Drobny wandalizm", "Testowy Poręczony")
	var/old_level = GLOB.security_level
	old_security_level = old_level
	GLOB.security_level = SEC_LEVEL_GREEN
	TEST_ASSERT_EQUAL(aq_bail_for_card(bail_card), 200, "Kaucja za 10 minut wyroku")
	GLOB.security_level = SEC_LEVEL_RED
	TEST_ASSERT(isnull(aq_bail_for_card(bail_card)), "Kaucja przyjęta przy alarmie bojowym")
	GLOB.security_level = SEC_LEVEL_GREEN
	var/obj/item/card/id/prisoner/life_card = allocate(/obj/item/card/id/prisoner, run_loc_floor_bottom_left, 3600, "Zabójstwo", "Testowy Dożywotni")
	TEST_ASSERT(isnull(aq_bail_for_card(life_card)), "Kaucja za dożywocie")
	aq_release_on_bail(bail_card, "Testowy Poręczyciel")
	TEST_ASSERT(bail_card.served_time >= bail_card.sentence, "Kaucja nie zakończyła wyroku")
	TEST_ASSERT_EQUAL(bail_security.fields["criminal"], "Paroled", "Kaucja nie dała zwolnienia warunkowego")
	cell.prisoner_name = "Testowy Poręczony"
	cell.set_timer(2 MINUTES)
	cell.timer_start()
	TEST_ASSERT(aq_bail_for_timer(cell) >= 20, "Brak kaucji za celę z zegarem")
	cell.release_on_bail("Testowy Poręczyciel")
	TEST_ASSERT(!cell.timing, "Kaucja nie zatrzymała zegara")
	TEST_ASSERT_EQUAL(bail_security.fields["criminal"], "Paroled", "Kaucja za celę nie dała zwolnienia warunkowego")
	GLOB.security_level = old_level

	// Planer zarzutów: wgrywa osadzonego, zarzuty i wyrok do stojącego zegara celi
	var/obj/item/law_planner/planner = allocate(/obj/item/law_planner)
	planner.charges = list("Drobny wandalizm")
	planner.suspect_name = "Testowy Osadzony"
	cell.req_access = null
	TEST_ASSERT(planner.load_timer(cell, officer), "Planer nie wgrał zarzutów do zegara")
	TEST_ASSERT_EQUAL(cell.prisoner_name, "Testowy Osadzony", "Planer nie wpisał osadzonego")
	TEST_ASSERT_EQUAL(cell.timer_duration, aq_sentence_for_crimes(list("Drobny wandalizm")), "Planer nie ustawił wyroku")
	cell.prisoner_name = null
	cell.prisoner_crimes = null

	// Kod Żandarmerii: te same słowa dają te same kody, różne słowa różne, format „10-42 Bravo”
	var/datum/language/police_code/code = new
	var/coded = code.scramble("potrzebne wsparcie w maszynowni")
	TEST_ASSERT_EQUAL(code.scramble("potrzebne wsparcie w maszynowni"), coded, "Kod nie jest stały w rundzie")
	TEST_ASSERT(coded != code.scramble("więzień uciekł z celi numer dwa"), "Różne meldunki dały ten sam kod")
	var/regex/code_format = regex(@"^\d+-\d+ [A-Z][a-z]+")
	TEST_ASSERT(code_format.Find(coded), "Kod ma zły format: [coded]")
	qdel(code)

	// Projektor nakazu: nakaz przeszukania po autoryzacji otwiera drzwi wybranego obszaru, zmiana statusu go unieważnia
	var/list/warrant_records = make_records("Testowy Przeszukiwany")
	var/datum/data/record/warrant_security = warrant_records[2]
	GLOB.data_core.set_criminal_status(warrant_security, "Search", "Testowy Żandarm", "kontrabanda", announce = FALSE)
	var/obj/item/holowarrant/warrant = allocate(/obj/item/holowarrant)
	var/obj/machinery/door/airlock/door = allocate(/obj/machinery/door/airlock, run_loc_floor_top_right)
	warrant.load_warrant(warrant_security, get_area(door))
	TEST_ASSERT_EQUAL(warrant.reason, "kontrabanda", "Nakaz nie wziął powodu z historii rekordu")
	TEST_ASSERT(!warrant.grant_search_access(officer, door), "Nieautoryzowany nakaz otwiera drzwi")
	warrant.authorize("Testowy Kapitan")
	TEST_ASSERT(warrant.grant_search_access(officer, door), "Autoryzowany nakaz przeszukania nie otwiera drzwi obszaru")
	GLOB.data_core.set_criminal_status(warrant_security, "None", "Testowy Żandarm", announce = FALSE)
	TEST_ASSERT(isnull(warrant.target_name), "Zmiana statusu nie unieważniła nakazu")
	TEST_ASSERT(!warrant.grant_search_access(officer, door), "Unieważniony nakaz dalej otwiera drzwi")
	// Regresja z review: rekord usunięty z kartoteki (bez sygnału zmiany statusu) też unieważnia dostęp
	GLOB.data_core.set_criminal_status(warrant_security, "Search", "Testowy Żandarm", "kontrabanda", announce = FALSE)
	warrant.load_warrant(warrant_security, get_area(door))
	warrant.authorize("Testowy Kapitan")
	GLOB.data_core.security -= warrant_security
	TEST_ASSERT(!warrant.grant_search_access(officer, door), "Nakaz z usuniętego rekordu dalej otwiera drzwi")
	GLOB.data_core.security += warrant_security

	// Regresje z review: zarzuty bez wyroku zerują czas zegara; kaucja nie dla zegara bez zasilania;
	// koniec kary w GenPopie nie kasuje nowego nakazu
	cell.set_timer(5 MINUTES)
	planner.charges = list("Sen na służbie") // przewinienie dyscyplinarne, wyrok 0
	planner.load_timer(cell, officer)
	TEST_ASSERT_EQUAL(cell.timer_duration, 0, "Zarzuty bez wyroku zostawiły stary czas zegara")
	cell.prisoner_name = "Testowy Poręczony"
	cell.set_timer(2 MINUTES)
	cell.timer_start()
	cell.set_machine_stat(NOPOWER)
	TEST_ASSERT(isnull(aq_bail_for_timer(cell)), "Kaucja przyjmowana za zegar bez zasilania")
	cell.set_machine_stat(NONE)
	cell.timer_end(forced = TRUE)
	var/list/rearrest_records = make_records("Testowy Recydywista")
	var/datum/data/record/rearrest_security = rearrest_records[2]
	var/obj/item/card/id/prisoner/rearrest_card = allocate(/obj/item/card/id/prisoner, run_loc_floor_bottom_left, 60, "Drobny wandalizm", "Testowy Recydywista")
	GLOB.data_core.set_criminal_status(rearrest_security, "Arrest", "Testowy Żandarm", "nowe przestępstwo", announce = FALSE)
	rearrest_card.served_time = rearrest_card.sentence
	rearrest_card.process(1)
	TEST_ASSERT_EQUAL(rearrest_security.fields["criminal"], "Arrest", "Koniec starej kary skasował nowy nakaz")

	// Regresja z review: nieudany skan planera nie zostawia poprzedniej osoby
	var/mob/living/carbon/human/known = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	known.real_name = "Testowy Osadzony"
	known.name = known.real_name
	var/mob/living/carbon/human/stranger = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	stranger.real_name = "Testowy Nieznajomy Bez Akt"
	stranger.name = stranger.real_name
	TEST_ASSERT(planner.scan_suspect(known), "Planer nie rozpoznał osoby z kartoteki")
	TEST_ASSERT(!planner.scan_suspect(stranger), "Planer rozpoznał osobę bez akt")
	TEST_ASSERT(isnull(planner.suspect_name), "Nieudany skan zostawił poprzednią osobę: [planner.suspect_name]")

	// Regresja z review: „Uruchom” zapauzowanego zegara wymaga dostępu
	cell.req_access = list(ACCESS_SECURITY)
	cell.prisoner_name = "Testowy Osadzony"
	cell.set_timer(2 MINUTES)
	cell.timer_start()
	cell.pause_timer()
	TEST_ASSERT(!cell.ui_act("start", list()), "Zapauzowany zegar wznowiony bez dostępu")
	TEST_ASSERT(!cell.timing && !isnull(cell.paused_left), "Zegar ruszył bez dostępu")

	// Regresja z review: wpłata kaucji holożetonem pobiera kwotę i zwalnia, zegar bez zasilania niczego nie pobiera
	var/obj/machinery/computer/warrant/desk = allocate(/obj/machinery/computer/warrant, run_loc_floor_top_right)
	var/obj/item/holochip/chip = new(run_loc_floor_bottom_left, 2000)
	officer.put_in_hands(chip)
	cell.set_machine_stat(NOPOWER)
	TEST_ASSERT(!desk.pay_bail(officer, cell, TRUE), "Kaucja pobrana za zegar bez zasilania")
	TEST_ASSERT_EQUAL(chip.credits, 2000, "Zegar bez zasilania pobrał pieniądze")
	cell.set_machine_stat(NONE)
	var/bail_amount = aq_bail_for_timer(cell)
	TEST_ASSERT(desk.pay_bail(officer, cell, TRUE), "Kaucja holożetonem nie przeszła")
	TEST_ASSERT_EQUAL(chip.credits, 2000 - bail_amount, "Kaucja pobrała złą kwotę")
	TEST_ASSERT(!cell.timing && isnull(cell.paused_left), "Kaucja nie zwolniła więźnia z celi")
	qdel(chip)

	// Formularze kserokopiarki: poprawny JSON, unikalne kody, są formularze Żandarmerii
	var/list/blanks = json_decode(file2text("config/blanks.json"))
	TEST_ASSERT(length(blanks), "config/blanks.json jest pusty albo uszkodzony")
	var/list/codes = list()
	var/security_forms = 0
	for(var/list/blank as anything in blanks)
		TEST_ASSERT(blank["code"] && blank["category"] && blank["name"] && length(blank["info"]), "Formularz bez kodu, kategorii, nazwy albo treści: [blank["code"]]")
		TEST_ASSERT(!(blank["code"] in codes), "Powtórzony kod formularza: [blank["code"]]")
		codes += blank["code"]
		if(blank["category"] == "Żandarmeria")
			security_forms++
	TEST_ASSERT(security_forms >= 10, "Za mało formularzy Żandarmerii: [security_forms]")

	// Skrzynka skarg: skarga dostaje numer i trafia na listę; czyta ją tylko dowództwo i prawnik
	var/obj/machinery/complaint_box/box = allocate(/obj/machinery/complaint_box, run_loc_floor_bottom_left)
	var/complaints_before = length(GLOB.aq_complaints)
	var/number = box.add_complaint("Testowa skarga", "Treść testowej skargi na Żandarmerię.", officer)
	TEST_ASSERT_EQUAL(length(GLOB.aq_complaints), complaints_before + 1, "Skarga nie trafiła na listę")
	TEST_ASSERT_EQUAL(GLOB.aq_complaints[length(GLOB.aq_complaints)]["number"], number, "Skarga ma zły numer")
	TEST_ASSERT(!box.can_read(officer), "Osoba bez dostępu czyta skargi")
	GLOB.aq_complaints.len = complaints_before

	// Stopnie: progi ze stażu do automatycznego limitu, ręczne awanse i degradacje ze statystyk
	var/list/ladder = GLOB.aq_rank_ladders["Żandarm"]
	TEST_ASSERT_EQUAL(aq_rank_index_from_stats(ladder, list()), 1, "Nowy Żandarm nie zaczyna od najniższego stopnia")
	TEST_ASSERT_EQUAL(aq_rank_index_from_stats(ladder, list("rounds" = 50, "arrests" = 50)), 2, "Staż nie dał automatycznego awansu albo dał ponad próg")
	TEST_ASSERT_EQUAL(aq_rank_index_from_stats(ladder, list("rounds" = 50, "arrests" = 50, "rank_up_sec" = 1)), 3, "Ręczny awans nie podniósł stopnia ponad próg")
	TEST_ASSERT_EQUAL(aq_rank_index_from_stats(ladder, list("rounds" = 50, "arrests" = 50, "rank_down_sec" = 5)), 1, "Degradacja zeszła poniżej najniższego stopnia")
	var/datum/mind/test_mind = new("aquila_test_ranks")
	test_mind.name = "Testowy Bosman"
	test_mind.aq_rank_job = "Żandarm"
	test_mind.aq_rank_index = 2
	TEST_ASSERT_EQUAL(aq_change_rank(test_mind, 1, "Testowy Komendant"), "st. bosm.", "Awans nie dał następnego stopnia")
	TEST_ASSERT_EQUAL(test_mind.aquila_stats["rank_up_sec"], 1, "Awans nie trafił do statystyk postaci")
	TEST_ASSERT(isnull(aq_change_rank(test_mind, 1, "Testowy Komendant")), "Awans ponad najwyższy stopień")
	TEST_ASSERT_EQUAL(aq_change_rank(test_mind, -1, "Testowy Komendant"), "bosm.", "Degradacja nie obniżyła stopnia")

	// Kartoteka między rundami: wyrok od 15 minut trafia do zapisu, krótszy nie
	SSticker.minds += test_mind
	TEST_ASSERT(!aq_record_sentence("Testowy Bosman", "Drobny wandalizm", 5 MINUTES), "Krótki wyrok trafił do kartoteki")
	TEST_ASSERT(aq_record_sentence("Testowy Bosman", "Zabójstwo", 60 MINUTES), "Dożywocie nie trafiło do kartoteki")
	var/list/history = GLOB.aq_round_sentences["aquilatestranks|Testowy Bosman"]
	TEST_ASSERT(length(history) == 1 && findtext(history[1], "dożywocie"), "Zły wpis w kartotece: [json_encode(history)]")
	GLOB.aq_round_sentences -= "aquilatestranks|Testowy Bosman"
	SSticker.minds -= test_mind

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
