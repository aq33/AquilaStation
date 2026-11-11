// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - automat ekstraktów: wystawiony ekstrakt kupuje się kartą, pieniądze idą na konto nauki
/datum/unit_test/aquila_extract_vendor

/datum/unit_test/aquila_extract_vendor/Run()
	var/obj/machinery/slime_extract_requestor/vendor = allocate(/obj/machinery/slime_extract_requestor)
	var/obj/item/slime_extract/grey/extract = allocate(/obj/item/slime_extract/grey)
	extract.forceMove(vendor)
	vendor.stock_extract(extract)
	TEST_ASSERT(vendor.prices[/obj/item/slime_extract/grey] == initial(extract.plort_value), "Nowy ekstrakt nie dostał ceny domyślnej")
	vendor.prices[/obj/item/slime_extract/grey] = 40

	var/datum/bank_account/buyer = new /datum/bank_account("Kupujący test", SSjob.GetJobType(/datum/job/assistant))
	buyer.account_balance = 100
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	card.registered_account = buyer
	var/datum/bank_account/science = SSeconomy.get_dep_account(ACCOUNT_SCI)
	var/science_before = science.account_balance
	var/points_before = GLOB.slime_market.points

	var/obj/item/slime_extract/bought = vendor.buy_extract(null, /obj/item/slime_extract/grey, card)
	TEST_ASSERT(bought == extract, "Automat nie wydał wystawionego ekstraktu")
	TEST_ASSERT(bought.loc != vendor, "Kupiony ekstrakt został w automacie")
	TEST_ASSERT(buyer.account_balance == 60, "Z konta kupującego zeszło [100 - buyer.account_balance] kr zamiast 40")
	TEST_ASSERT(science.account_balance == science_before + 40, "Konto nauki nie dostało zapłaty")
	TEST_ASSERT(GLOB.slime_market.points > points_before, "Rynek nie doliczył xenobio points")
	TEST_ASSERT(!vendor.buy_extract(null, /obj/item/slime_extract/grey, card), "Automat sprzedał ekstrakt, którego już nie ma")

	// Za mało kredytów: ekstrakt zostaje w automacie
	var/obj/item/slime_extract/grey/second = allocate(/obj/item/slime_extract/grey)
	second.forceMove(vendor)
	vendor.stock_extract(second)
	vendor.prices[/obj/item/slime_extract/grey] = 500
	TEST_ASSERT(!vendor.buy_extract(null, /obj/item/slime_extract/grey, card), "Automat sprzedał ekstrakt bez pieniędzy na koncie")
	TEST_ASSERT(second.loc == vendor && buyer.account_balance == 60, "Nieudany zakup zabrał ekstrakt albo kredyty")
	// Ekstrakt wystawiony z własnego konta: kredyty przechodzą, ale punktów xenobio nie ma
	second.forceMove(get_turf(vendor)) // automat wydaje pierwszy pasujący ekstrakt
	var/obj/item/slime_extract/grey/own = allocate(/obj/item/slime_extract/grey)
	own.forceMove(vendor)
	vendor.stock_extract(own)
	vendor.stocked_by[own] = buyer
	vendor.prices[/obj/item/slime_extract/grey] = 10
	buyer.account_balance = 100
	var/points_own = GLOB.slime_market.points
	TEST_ASSERT(vendor.buy_extract(null, /obj/item/slime_extract/grey, card) == own, "Nie udało się kupić własnego ekstraktu")
	TEST_ASSERT(GLOB.slime_market.points == points_own, "Kupno własnego ekstraktu dało xenobio points")
	TEST_ASSERT(!(own in vendor.stocked_by), "Automat pamięta wystawiającego po wydaniu ekstraktu")
	SSeconomy.bank_accounts -= buyer
	qdel(buyer)

/// AQUILA - gablota DNA pokazuje, jaką mutację daje iniektor
/datum/unit_test/aquila_gene_fridge_desc

/datum/unit_test/aquila_gene_fridge_desc/Run()
	var/obj/machinery/smartfridge/genetics/fridge = allocate(/obj/machinery/smartfridge/genetics)
	var/obj/item/dnainjector/xraymut/injector = allocate(/obj/item/dnainjector/xraymut)
	TEST_ASSERT(fridge.accept_check(injector), "Gablota nie przyjmuje iniektora DNA")
	var/datum/mutation/xray = GET_INITIALIZED_MUTATION(injector.add_mutations[1])
	var/list/desc = fridge.gene_fridge_desc(injector)
	TEST_ASSERT(("Daje: [xray.name]") in desc, "Opis iniektora nie podaje mutacji: [jointext(desc, " | ")]")
	// Dwa aktywatory o tej samej nazwie, ale z innymi mutacjami, to dwa osobne wiersze gabloty
	var/obj/item/dnainjector/activator/first = allocate(/obj/item/dnainjector/activator)
	var/obj/item/dnainjector/activator/second = allocate(/obj/item/dnainjector/activator)
	first.add_mutations = list(injector.add_mutations[1])
	second.add_mutations = list(/datum/mutation/telekinesis)
	TEST_ASSERT(first.name == second.name, "Test setup: aktywatory mają różne nazwy")
	TEST_ASSERT(fridge.smartfridge_item_key(first) != fridge.smartfridge_item_key(second), "Gablota łączy aktywatory z różnymi mutacjami w jeden wiersz")
	injector.used = TRUE
	TEST_ASSERT(!fridge.accept_check(injector), "Gablota przyjęła zużyty iniektor")
	TEST_ASSERT(!fridge.accept_check(allocate(/obj/item/reagent_containers/glass/beaker)), "Gablota przyjęła zlewkę")

/// AQUILA - okno analizatora: Maskarada wampira ukrywa ubytek krwi jak tryb tekstowy, rany trafiają na sylwetkę
/datum/unit_test/aquila_health_analyzer_window

/datum/unit_test/aquila_health_analyzer_window/Run()
	var/mob/living/carbon/human/patient = allocate(/mob/living/carbon/human)
	patient.blood_volume = 200
	var/list/data = get_health_analyzer_data(null, patient, FALSE)
	TEST_ASSERT(data["blood_volume"] == 200, "Okno pokazuje [data["blood_volume"]] cl zamiast 200")
	var/low_blood = FALSE
	for(var/list/injury as anything in data["injuries"]["body"])
		if(injury["name"] == "Niski poziom krwi")
			low_blood = TRUE
	TEST_ASSERT(low_blood, "Okno nie zgłasza niskiego poziomu krwi")

	ADD_TRAIT(patient, TRAIT_MASQUERADE, "aquila_test")
	data = get_health_analyzer_data(null, patient, FALSE)
	TEST_ASSERT(data["blood_volume"] == BLOOD_VOLUME_NORMAL, "Maskarada nie ukrywa ubytku krwi w oknie ([data["blood_volume"]] cl)")
	for(var/list/injury as anything in data["injuries"]["body"])
		TEST_ASSERT(injury["name"] != "Niski poziom krwi", "Okno zgłasza niski poziom krwi przy Maskaradzie")
	REMOVE_TRAIT(patient, TRAIT_MASQUERADE, "aquila_test")

	var/datum/wound/blunt/fracture = new /datum/wound/blunt/fracture()
	fracture.apply_wound(patient.get_bodypart(BODY_ZONE_L_LEG), silent = TRUE)
	data = get_health_analyzer_data(null, patient, TRUE)
	var/list/leg_wounds = data["wounds"][BODY_ZONE_L_LEG]
	TEST_ASSERT(length(leg_wounds) == 1, "Złamanie nogi nie trafiło na sylwetkę")
	TEST_ASSERT(leg_wounds[1]["type"] == WOUND_BLUNT, "Rana na sylwetce ma rodzaj [leg_wounds[1]["type"]]")
	TEST_ASSERT(!data["wounds"][BODY_ZONE_R_LEG], "Zdrowa noga ma ranę na sylwetce")
	TEST_ASSERT(length(data["senses"]) == 2, "Tryb zaawansowany nie pokazuje oczu i uszu")
	TEST_ASSERT(findtext(data["body_temperature"], "°F"), "Brak temperatury w °F")

/// AQUILA - zakładka „Zlecenia” w konsoli zgłoszeń zbiera ogłoszenia z newscastera
/datum/unit_test/aquila_requests_console_bounties

/datum/unit_test/aquila_requests_console_bounties/Run()
	var/obj/machinery/requests_console/console = allocate(/obj/machinery/requests_console)
	var/datum/station_request/request = new("Tester zleceń", 150, "Przynieście kubek", 1, null)
	GLOB.request_list += request
	var/found = FALSE
	for(var/list/entry as anything in console.requests_console_bounty_list(null))
		if(entry["name"] == "Ogłoszenie: Tester zleceń" && entry["reward"] == "150 kr")
			found = TRUE
	GLOB.request_list -= request
	qdel(request)
	TEST_ASSERT(found, "Zakładka zleceń nie pokazuje ogłoszenia z newscastera")

/// AQUILA - każdy węzeł sieci badań trafia do jednej ze znanych kategorii okna R&D
/datum/unit_test/aquila_techweb_categories

/datum/unit_test/aquila_techweb_categories/Run()
	var/list/known = list("medical", "robotics", "exosuits", "weapons", "ship", "bluespace", "computing", "engineering")
	for(var/node_id in SSresearch.techweb_nodes)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_id]
		TEST_ASSERT(node.aq_category() in known, "Węzeł [node.id] ma nieznaną kategorię [node.aq_category()]")
	var/list/expected = list("mech_gygax" = "exosuits", "nanite_base" = "computing", "fighter_tier1" = "ship", "adv_surgery" = "medical", "beam_weapons" = "weapons", "bluespace_travel" = "bluespace", "cyborg" = "robotics", "basic_mining" = "engineering")
	for(var/node_id in expected)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_id]
		if(!node)
			continue
		TEST_ASSERT(node.aq_category() == expected[node_id], "Węzeł [node_id] trafił do [node.aq_category()] zamiast [expected[node_id]]")

/// AQUILA - kategorie sieci badań są niezależne: wymagania z innej kategorii tylko jako wyjątki, każdy węzeł osiągalny od podstaw lub węzła startowego
/datum/unit_test/aquila_techweb_independent_categories

/datum/unit_test/aquila_techweb_independent_categories/Run()
	for(var/category in GLOB.techweb_category_roots)
		var/datum/techweb_node/root = SSresearch.techweb_nodes[GLOB.techweb_category_roots[category]]
		TEST_ASSERT(root, "Brak węzła startowego kategorii [category]")
		TEST_ASSERT(length(root.prereq_ids) == 1 && ("base" in root.prereq_ids), "Węzeł startowy [root.id] wymaga [jointext(root.prereq_ids, ", ")] zamiast samych podstaw")
	for(var/node_id in SSresearch.techweb_nodes)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_id]
		var/category = node.aq_category()
		for(var/prereq_id in node.prereq_ids)
			var/datum/techweb_node/prereq = SSresearch.techweb_nodes[prereq_id]
			if(prereq_id == "base" || prereq.aq_category() == category)
				continue
			TEST_ASSERT(prereq_id in GLOB.techweb_cross_prereq_keep[node.id], "Węzeł [node.id] ([category]) wymaga [prereq_id] z kategorii [prereq.aq_category()]")
		// Każdy węzeł z wymaganiami dochodzi do podstaw bez cyklu
		if(!length(node.prereq_ids) || node.id == "base")
			continue
		var/list/seen = list()
		var/list/stack = node.prereq_ids.Copy()
		var/reached_base = FALSE
		while(length(stack))
			var/current = stack[length(stack)]
			stack.len--
			if(current == "base")
				reached_base = TRUE
				continue
			TEST_ASSERT(current != node.id, "Cykl wymagań przez węzeł [node.id]")
			if(seen[current])
				continue
			seen[current] = TRUE
			var/datum/techweb_node/next = SSresearch.techweb_nodes[current]
			if(!next)
				continue
			// Węzły startowe (zbadane od początku rundy) nie mają wymagań i też są dobrym początkiem
			if(!length(next.prereq_ids))
				reached_base = TRUE
				continue
			stack += next.prereq_ids
		TEST_ASSERT(reached_base, "Węzeł [node.id] nie prowadzi do podstaw ani do węzła startowego")

#undef TEST_ASSERT

