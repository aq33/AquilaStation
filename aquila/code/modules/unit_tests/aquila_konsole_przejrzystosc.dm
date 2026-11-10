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
	SSeconomy.bank_accounts -= buyer
	qdel(buyer)

/// AQUILA - gablota DNA pokazuje, jaką mutację daje iniektor
/datum/unit_test/aquila_gene_fridge_desc

/datum/unit_test/aquila_gene_fridge_desc/Run()
	var/obj/machinery/smartfridge/genetics/fridge = allocate(/obj/machinery/smartfridge/genetics)
	var/obj/item/dnainjector/xraymut/injector = allocate(/obj/item/dnainjector/xraymut)
	TEST_ASSERT(fridge.accept_check(injector), "Gablota nie przyjmuje iniektora DNA")
	var/datum/mutation/xray = GET_INITIALIZED_MUTATION(injector.add_mutations[1])
	var/desc = fridge.gene_fridge_desc(injector)
	TEST_ASSERT(findtext(desc, xray.name), "Opis iniektora nie podaje mutacji: [desc]")
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

#undef TEST_ASSERT

