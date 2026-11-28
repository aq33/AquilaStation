// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }
#define TEST_ASSERT_EQUAL(a, b, message) if ((a) != (b)) { return Fail("Assertion failed: [message || "No message"]. Expected [b], got [a]") }

/// AQUILA - narzędzia detektywa, część 3 planu Żandarmerii (aquila/code/modules/detectivework/):
/// czas śladu, zacieranie śladów, alkomat, BloodTrak, okulary śledcze, mikrofon pluskwy, lampa UV, tryb noir. Jedna scena.
/datum/unit_test/aquila_detective_tools
	/// Licznik nadań mikrofonu pluskwy (lista, żeby handler zmieniał tę samą)
	var/list/transmission_counter

/datum/unit_test/aquila_detective_tools/proc/count_transmission(datum/source)
	SIGNAL_HANDLER
	transmission_counter[1]++

/datum/unit_test/aquila_detective_tools/Run()
	var/turf/center = run_loc_floor_bottom_left
	var/mob/living/carbon/human/suspect = allocate(/mob/living/carbon/human, center)
	suspect.real_name = "Testowy Podejrzany"
	suspect.name = suspect.real_name

	// Czas śladu: odcisk dostaje znacznik, skaner pokazuje przybliżony wiek, starcie czyści znacznik
	var/obj/item/pen/evidence = allocate(/obj/item/pen, center)
	evidence.add_fingerprint(suspect)
	var/datum/component/forensics/D = evidence.GetComponent(/datum/component/forensics)
	TEST_ASSERT(D && length(D.fingerprints), "Długopis nie ma odcisku")
	var/print = D.fingerprints[1]
	TEST_ASSERT(LAZYACCESS(D.print_times, print), "Odcisk nie ma znacznika czasu")
	D.print_times[print] = world.time - 12 MINUTES
	TEST_ASSERT(findtext(evidence.aq_trace_age("print", print), "ok. 10 min"), "Zły wiek odcisku: [evidence.aq_trace_age("print", print)]")
	TEST_ASSERT(findtext(aq_trace_age_text(world.time), "mniej niż minutę"), "Świeży ślad bez opisu")
	TEST_ASSERT_EQUAL(aq_trace_age_text(null), "", "Ślad bez znacznika ma dopisek")

	// Zwykłe sprzątanie nie ściera odcisków (regresja balansu), zacieranie ściera i zostawia ślad czyszczenia
	SEND_SIGNAL(evidence, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_MEDIUM)
	TEST_ASSERT(length(D.fingerprints), "Zwykłe sprzątanie starło odcisk")
	D.add_blood_DNA(list("TESTDNA" = "O+"))
	evidence.add_gunshot_residue("9mm")
	evidence.aq_wipe_evidence("ślady mydła")
	TEST_ASSERT(evidence.return_gunshot_residue()?["9mm"] != null, "Zacieranie zmyło ślady prochu")
	TEST_ASSERT(!length(D.fingerprints) && !length(D.blood_DNA), "Zacieranie nie starło odcisków i krwi")
	TEST_ASSERT(!LAZYACCESS(D.print_times, print), "Starty odcisk zostawił znacznik czasu")
	TEST_ASSERT(D.latent_blood_DNA?["TESTDNA"], "Zacieranie skasowało krew dla luminolu")
	var/list/residue = evidence.return_cleaning_residue()
	TEST_ASSERT(residue?["ślady mydła"] != null, "Brak śladu czyszczenia")
	D.cleaning_residue["ślady mydła"] = world.time - 25 MINUTES
	TEST_ASSERT(!evidence.return_cleaning_residue(), "Stary ślad czyszczenia nie zniknął")

	// Alkomat: pasma i nazwa napoju
	var/obj/item/aq_breathalyzer/breathalyzer = allocate(/obj/item/aq_breathalyzer)
	TEST_ASSERT(findtext(breathalyzer.breath_report(suspect), "trzeźwy"), "Trzeźwy nie jest trzeźwy")
	suspect.drunkenness = 45
	suspect.reagents.add_reagent(/datum/reagent/consumable/ethanol/beer, 10)
	var/report = breathalyzer.breath_report(suspect)
	TEST_ASSERT(findtext(report, "pijany") && findtext(report, "‰"), "Zły wynik alkomatu: [report]")
	var/datum/reagent/beer = /datum/reagent/consumable/ethanol/beer
	TEST_ASSERT(findtext(report, initial(beer.name)), "Alkomat nie podał napoju: [report]")
	suspect.drunkenness = 0
	suspect.reagents.clear_reagents()

	// BloodTrak: świeża krew wskazuje właściciela, zaschnięta nie
	var/obj/effect/decal/cleanable/blood/puddle = allocate(/obj/effect/decal/cleanable/blood, run_loc_floor_top_right)
	puddle.add_blood_DNA(list(suspect.dna.unique_enzymes = suspect.dna.blood_type))
	var/obj/item/pinpointer/aq_bloodtrak/tracker = allocate(/obj/item/pinpointer/aq_bloodtrak)
	TEST_ASSERT(tracker.track_blood(puddle) == TRUE, "BloodTrak nie złapał tropu")
	TEST_ASSERT_EQUAL(tracker.target, suspect, "BloodTrak wskazuje kogoś innego")
	puddle.make_old()
	TEST_ASSERT(istext(tracker.track_blood(puddle)), "BloodTrak śledzi zaschniętą krew")
	tracker.toggle_on()

	// Okulary śledcze: obserwator z okularami widzi, na co patrzy podejrzany; bez okularów nic
	var/mob/living/carbon/human/watcher = allocate(/mob/living/carbon/human, locate(center.x + 1, center.y, center.z))
	var/obj/item/pen/looked_at = allocate(/obj/item/pen, center)
	TEST_ASSERT_EQUAL(suspect.aq_report_gaze(looked_at), 0, "Spojrzenie widać bez okularów")
	var/obj/item/clothing/glasses/hud/security/sunglasses/aq_investigation/glasses = allocate(/obj/item/clothing/glasses/hud/security/sunglasses/aq_investigation)
	watcher.equip_to_slot_if_possible(glasses, ITEM_SLOT_EYES)
	TEST_ASSERT(HAS_TRAIT(watcher, TRAIT_AQ_EYE_TRACKING), "Okulary nie dały śledzenia wzroku")
	TEST_ASSERT_EQUAL(suspect.aq_report_gaze(looked_at), 1, "Okulary nie pokazały spojrzenia")
	// Regresja z review: raport tylko po udanych oględzinach (sygnał z bazy), także przez prawdziwe run_examinate
	var/reports_before = suspect.aq_gaze_reports
	suspect.run_examinate(looked_at)
	TEST_ASSERT_EQUAL(suspect.aq_gaze_reports, reports_before + 1, "Udane oględziny nie trafiły do okularów")
	var/obj/item/pen/gone = new(center)
	qdel(gone)
	suspect.run_examinate(gone)
	TEST_ASSERT_EQUAL(suspect.aq_gaze_reports, reports_before + 1, "Nieudane oględziny trafiły do okularów")
	// niewidomy ogląda ten sam, nieusunięty przedmiot: oględziny przechodzą, ale spojrzenia nie ma
	suspect.eye_blind = 10
	suspect.run_examinate(looked_at)
	suspect.eye_blind = 0
	TEST_ASSERT_EQUAL(suspect.aq_gaze_reports, reports_before + 1, "Okulary pokazały spojrzenie niewidomego")

	// Pluskwa: mikrofon na częstotliwości, którą da się nastawić na zwykłym radiu; nadaje tylko przez etui (bez podwójnych wiadomości)
	var/obj/item/clothing/accessory/spy_bug/bug = allocate(/obj/item/clothing/accessory/spy_bug)
	TEST_ASSERT(bug.microphone, "Pluskwa nie ma mikrofonu")
	TEST_ASSERT(!bug.microphone.broadcasting, "Mikrofon w etui nadaje sam, wypowiedzi pójdą podwójnie")
	TEST_ASSERT(bug.microphone.frequency >= MIN_FREQ && bug.microphone.frequency <= MAX_FREQ, "Mikrofon poza zakresem zwykłego radia: [bug.microphone.frequency]")
	var/obj/item/radio/aq_bug_mic/cigarettes/cig_bug = allocate(/obj/item/radio/aq_bug_mic/cigarettes)
	TEST_ASSERT(cig_bug.broadcasting, "Pluskwa papierosowa nie nadaje")
	// Regresja z review: jedna wypowiedź obok etui to jedno nadanie (słyszą ją i etui, i radio w środku)
	var/list/transmissions = list(0)
	RegisterSignal(bug.microphone, COMSIG_RADIO_MESSAGE, PROC_REF(count_transmission))
	transmission_counter = transmissions
	bug.Hear("test", suspect, /datum/language/common, "test", null, list(), list())
	bug.microphone.Hear("test", suspect, /datum/language/common, "test", null, list(), list())
	UnregisterSignal(bug.microphone, COMSIG_RADIO_MESSAGE)
	TEST_ASSERT_EQUAL(transmissions[1], 1, "Wypowiedź obok pluskwy nadana inną liczbę razy")

	// Lampa UV: ujawnia zmytą krew w zasięgu na krótko i nie skraca świecenia po luminolu
	var/turf/near = locate(center.x + 2, center.y, center.z)
	var/turf/far = locate(center.x + 5, center.y, center.z)
	var/obj/effect/blood_trace/near_trace = allocate(/obj/effect/blood_trace, near)
	near_trace.add_latent_blood_DNA(list("TESTDNA" = "O+"))
	var/obj/effect/blood_trace/far_trace = allocate(/obj/effect/blood_trace, far)
	far_trace.add_latent_blood_DNA(list("TESTDNA" = "O+"))
	var/obj/item/aq_uv_light/lamp = allocate(/obj/item/aq_uv_light, center)
	lamp.on = TRUE
	lamp.uv_scan()
	lamp.on = FALSE
	TEST_ASSERT(near_trace.revealed, "Lampa nie ujawniła śladu w zasięgu")
	TEST_ASSERT(!far_trace.revealed, "Lampa ujawniła ślad poza zasięgiem")
	TEST_ASSERT(near_trace.revealed_until <= world.time + 5 SECONDS, "Lampa ujawnia na długo")
	near_trace.reveal() // luminol
	lamp.on = TRUE
	lamp.uv_scan()
	lamp.on = FALSE
	TEST_ASSERT(near_trace.revealed_until >= world.time + LUMINOL_DURATION - 1 SECONDS, "Lampa skróciła świecenie po luminolu")

	// Tryb noir: krew i łuski w celach, przedmiot bez śladów nie; efekt da się włączyć i zdjąć
	var/obj/effect/decal/cleanable/blood/stain = allocate(/obj/effect/decal/cleanable/blood, locate(center.x + 1, center.y + 1, center.z))
	var/obj/item/ammo_casing/casing = allocate(/obj/item/ammo_casing, locate(center.x + 2, center.y + 1, center.z))
	var/obj/item/stack/sheet/iron/clean_item = allocate(/obj/item/stack/sheet/iron, locate(center.x + 3, center.y + 1, center.z))
	var/list/targets = aq_noir_targets(suspect)
	TEST_ASSERT((stain in targets) && (casing in targets), "Noir nie podświetla krwi albo łuski")
	TEST_ASSERT(!(clean_item in targets), "Noir podświetla przedmiot bez śladów")
	// Regresja z review: przedmiot z samą zmytą krwią nie świeci w noir (od tego luminol i lampa)
	var/obj/item/stack/sheet/iron/washed = allocate(/obj/item/stack/sheet/iron, locate(center.x + 3, center.y + 2, center.z))
	washed.add_latent_blood_DNA(list("TESTDNA" = "O+"))
	TEST_ASSERT(!(washed in aq_noir_targets(suspect)), "Noir pokazuje zmytą krew")
	suspect.apply_status_effect(/datum/status_effect/aq_noir)
	TEST_ASSERT(suspect.has_status_effect(/datum/status_effect/aq_noir), "Tryb noir się nie włączył")
	suspect.remove_status_effect(/datum/status_effect/aq_noir)
	TEST_ASSERT(!suspect.has_status_effect(/datum/status_effect/aq_noir), "Tryb noir się nie wyłączył")
	TEST_ASSERT(!aq_is_detective(suspect), "Każdy jest detektywem")

/// Plamy krwi usuwane z allocated zostawiają utajone ślady na kafelkach pokoju: sprzątamy je dla kolejnych testów
/datum/unit_test/aquila_detective_tools/Destroy()
	var/list/room = (run_loc_floor_bottom_left && run_loc_floor_top_right) ? block(run_loc_floor_bottom_left, run_loc_floor_top_right) : list()
	. = ..() // usuwa allocated, plamy krwi zostawiają wtedy ślady
	for(var/turf/T as anything in room)
		for(var/obj/effect/blood_trace/trace in T)
			qdel(trace)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
