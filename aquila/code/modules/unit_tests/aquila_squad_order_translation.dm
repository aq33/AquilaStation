// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// Drużyna, która zapisuje, komu i jaką treść rozkazu doręczyła (aq_custom: manager nie trzyma jej jako prawdziwej drużyny)
/datum/squad/aq_custom/aq_order_probe
	/// Lista doręczeń: list(treść, odbiorcy, translated)
	var/list/deliveries = list()

/datum/squad/aq_custom/aq_order_probe/aq_deliver_order(mob/living/sender, message, title, list/targets, translated = FALSE)
	deliveries += list(list(message, targets.Copy(), translated))
	return ..()

/// Rozkaz XO: polska załoga dostaje oryginał od razu, obcokrajowiec treść z DeepL (tu z pamięci tłumaczeń, bez sieci)
/datum/unit_test/aquila_squad_order_translation

/datum/unit_test/aquila_squad_order_translation/Run()
	var/datum/squad/aq_custom/aq_order_probe/squad = new("Sonda", "#ffffff")
	var/mob/living/carbon/human/officer = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/crew = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/mob/living/carbon/human/foreigner = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	officer.mind_initialize()
	crew.mind_initialize()
	foreigner.mind_initialize()
	foreigner.aq_make_foreigner()
	squad.members = list(crew, foreigner)
	SStranslation.cache_set(DEEPL_LANG_PL, DEEPL_LANG_EN, "Zabezpieczyć hangar", "Secure the hangar")

	TEST_ASSERT(squad.aq_issue_order(officer, "Zabezpieczyć hangar", from_console = TRUE), "Rozkaz nie przeszedł")
	sleep(1) // wynik z pamięci tłumaczeń przychodzi przez InvokeAsync
	TEST_ASSERT(length(squad.deliveries) == 3, "Zła liczba doręczeń: [length(squad.deliveries)] (oczekiwane: całość, polska część, tłumaczenie)")
	var/list/polish = squad.deliveries[2]
	TEST_ASSERT(polish[1] == "Zabezpieczyć hangar" && length(polish[2]) == 1 && (crew in polish[2]), "Polska załoga nie dostała oryginału osobno")
	var/list/english = squad.deliveries[3]
	TEST_ASSERT(english[3] && english[1] == "Secure the hangar", "Obcokrajowiec nie dostał tłumaczenia: [english[1]]")
	TEST_ASSERT(length(english[2]) == 1 && (foreigner in english[2]), "Tłumaczenie poszło do złych odbiorców")

	// Bez obcokrajowca w drużynie nic nie idzie do tłumacza
	squad.deliveries.Cut()
	squad.aq_next_order = 0
	squad.members = list(crew)
	TEST_ASSERT(squad.aq_issue_order(officer, "Stać", from_console = TRUE), "Drugi rozkaz nie przeszedł")
	sleep(1)
	TEST_ASSERT(length(squad.deliveries) == 1, "Rozkaz dla samych Polaków doręczony [length(squad.deliveries)] razy")

	squad.members = list()
	SStranslation.cache = list()
	qdel(squad)

#undef TEST_ASSERT
