// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - stopnie marynarki: każdy zawód ma stopień z config/ranks/marynarka.txt, każdy stopień jest w pecking_order.txt,
/// a porównanie stopni działa mimo spacji („kmdr por. ”) i w dobrą stronę (góra listy to najwyższy stopień)
/datum/unit_test/aquila_navy_ranks

/datum/unit_test/aquila_navy_ranks/Run()
	var/path = "[global.config.directory]/ranks/marynarka.txt"
	TEST_ASSERT(fexists(path), "No navy rank file at [path]")
	var/rank_text = "\n[file2text(path)]"
	for(var/datum/job/job as anything in SSjob.occupations)
		TEST_ASSERT(findtext(rank_text, "\n[job.title]="), "The job [job.title] has no rank in marynarka.txt")
	// Serwer wczytał stopnie z configu przy starcie: przeładowanie (wolne) tylko, gdy config wskazuje inny plik
	var/configured = CONFIG_GET(string/rank_file)
	if(configured != "marynarka.txt")
		SSjob.LoadRanks(path)
	for(var/datum/job/job as anything in SSjob.occupations)
		TEST_ASSERT(job.display_rank, "The job [job.title] got no rank from marynarka.txt")
		TEST_ASSERT(LAZYFIND(GLOB.pecking_order, replacetext(job.display_rank, " ", "")), "The rank [job.display_rank] ([job.title]) isn't in pecking_order.txt")
		TEST_ASSERT(job.display_rank in GLOB.aq_navy_ranks, "The rank [job.display_rank] ([job.title]) isn't in GLOB.aq_navy_ranks, so the EN version won't translate it")

	// compose_rank() zwraca stopień ze spacją na końcu: tak trafia do porównania przy wyborze dowódcy drużyny
	TEST_ASSERT(check_rank_pecking_order("kmdr ", "mar. "), "The captain's rank doesn't outrank a seaman")
	TEST_ASSERT(!check_rank_pecking_order("mar. ", "kmdr "), "A seaman outranks the captain")
	TEST_ASSERT(check_rank_pecking_order("kmdr por. ", "kmdr ppor. "), "kmdr por. doesn't outrank kmdr ppor.")
	TEST_ASSERT(!check_rank_pecking_order("st. bosm. ", "st. bosm. "), "The same rank outranks itself")
	TEST_ASSERT(!check_rank_pecking_order("CPU ", "kmdr "), "The AI rank outranks the captain")

	// W linijce wypowiedzi stopień jest osobnym tekstem (wersja EN tłumaczy go słownikiem)
	TEST_ASSERT(aq_rank_span("kmdr por. ") == "<span class='rank'>kmdr por. </span>", "The rank in a speech line isn't in its own span")
	TEST_ASSERT(aq_rank_span(null) == "", "A missing rank left an empty span")

	// Opis postaci: examine woła check_outranks(oglądany, oglądający), a komunikat czyta oglądający
	if(CONFIG_GET(flag/show_ranks))
		var/mob/living/carbon/human/captain = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
		var/mob/living/carbon/human/seaman = allocate(/mob/living/carbon/human, get_step(run_loc_floor_bottom_left, EAST))
		give_test_rank(captain, JOB_NAME_CAPTAIN)
		give_test_rank(seaman, JOB_NAME_ASSISTANT)
		var/seen_by_seaman = check_outranks(captain, seaman)
		TEST_ASSERT(findtext(seen_by_seaman, "[captain] ma wyższy stopień"), "A seaman examining the captain reads: [seen_by_seaman]")
		var/seen_by_captain = check_outranks(seaman, captain)
		TEST_ASSERT(findtext(seen_by_captain, "Masz wyższy stopień"), "The captain examining a seaman reads: [seen_by_captain]")

	if(configured != "marynarka.txt")
		SSjob.LoadRanks("[global.config.directory]/ranks/[configured]")

/// Karta z zawodem: z niej compose_rank() bierze stopień
/datum/unit_test/aquila_navy_ranks/proc/give_test_rank(mob/living/carbon/human/H, title)
	H.equip_to_slot_or_del(new /obj/item/clothing/under/color/grey(H), ITEM_SLOT_ICLOTHING) // bez kombinezonu nie ma miejsca na kartę
	var/obj/item/card/id/card = new(H)
	card.assignment = title
	H.equip_to_slot_or_del(card, ITEM_SLOT_ID)

#undef TEST_ASSERT
