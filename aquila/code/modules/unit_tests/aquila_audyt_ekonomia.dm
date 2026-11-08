// AQUILA - testy regresji do poprawek z audytu: giełda, aquilosy, bitrunning, pad zamówień xenobio, eksport kuźni
// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - zamówienie z giełdy materiałów kosztuje tyle, ile arkusze są warte przy odlocie promu, a nie przy zamówieniu
/datum/unit_test/aquila_market_order_current_price

/datum/unit_test/aquila_market_order_current_price/Run()
	var/datum/material/mat = /datum/material/titanium
	var/old_price = SSstock_market.materials_prices[mat]
	var/old_quantity = SSstock_market.materials_quantity[mat]
	var/datum/bank_account/cargo = SSeconomy.get_dep_account(ACCOUNT_CAR)
	var/old_balance = cargo.account_balance
	SSstock_market.materials_prices[mat] = 62
	SSstock_market.materials_quantity[mat] = 100

	var/datum/supply_pack/custom/minerals/pack = new("Tester")
	pack.add_sheets(initial(mat.sheet_type), mat, 10)
	var/cost_when_ordered = pack.get_cost()
	// cena rośnie, zanim prom poleci
	SSstock_market.materials_prices[mat] = 375
	var/cost_at_departure = pack.get_cost()
	// na rynku zostały tylko 4 arkusze: zwrot za 6 brakujących po cenie, którą prom właśnie pobrał
	SSstock_market.materials_quantity[mat] = 4
	pack.adjust_market(null)
	var/refund = cargo.account_balance - old_balance

	qdel(pack)
	cargo.account_balance = old_balance
	SSstock_market.materials_prices[mat] = old_price
	SSstock_market.materials_quantity[mat] = old_quantity

	TEST_ASSERT_EQUAL(cost_when_ordered, 620, "A market order did not cost the market price")
	TEST_ASSERT_EQUAL(cost_at_departure, 3750, "A market order kept the price from when it was placed, so waiting for a price rise was free profit")
	TEST_ASSERT_EQUAL(refund, 6 * 375, "Sheets missing from the market were not refunded at the price charged")

/// AQUILA - na koniec rundy liczy się osobiste konto postaci, nie karta budżetu działu w ręce, i każde konto tylko raz
/datum/unit_test/aquila_endround_personal_account

/datum/unit_test/aquila_endround_personal_account/Run()
	var/mob/living/carbon/human/body = allocate(/mob/living/carbon/human)
	var/datum/bank_account/personal = new("Test Holder", SSjob.GetJobType(/datum/job/assistant))
	body.account_id = personal.account_id
	var/obj/item/card/id/departmental_budget/sci/budget_card = allocate(/obj/item/card/id/departmental_budget/sci)
	body.put_in_hands(budget_card)

	var/datum/bank_account/held_account = body.get_bank_account()
	var/datum/bank_account/counted_account = body.get_personal_bank_account()

	var/list/old_claims = GLOB.endround_claimed_bank_accounts
	GLOB.endround_claimed_bank_accounts = list()
	var/first_claim = claim_endround_bank_account(personal, "tester_one")
	var/second_claim = claim_endround_bank_account(personal, "tester_two")
	var/repeat_claim = claim_endround_bank_account(personal, "tester_one")
	GLOB.endround_claimed_bank_accounts = list()
	var/peek = claim_endround_bank_account(personal, "tester_two", FALSE)
	var/after_peek = claim_endround_bank_account(personal, "tester_one")
	GLOB.endround_claimed_bank_accounts = old_claims

	body.account_id = null
	qdel(personal)

	TEST_ASSERT(held_account == SSeconomy.get_dep_account(ACCOUNT_SCI), "Test setup: the held budget card did not give the science account")
	TEST_ASSERT(counted_account == personal, "The end of round counted the held department budget card instead of the personal account")
	TEST_ASSERT(first_claim == personal, "The first player could not claim their account")
	TEST_ASSERT(isnull(second_claim), "Two players were paid for the same bank account")
	TEST_ASSERT(repeat_claim == personal, "Claiming the own account twice failed")
	TEST_ASSERT(peek == personal && after_peek == personal, "Checking an account without reserving it reserved it")

/// AQUILA - wygnaniec rozerwany w trakcie odliczania do odrodzenia budzi się w Pętli
/datum/unit_test/aquila_exile_respawn_after_gib

/datum/unit_test/aquila_exile_respawn_after_gib/Run()
	var/datum/exile_loop/loop = SSbitrunning.get_exile_loop()
	TEST_ASSERT(loop, "Exile loop failed to load")
	var/mob/living/carbon/human/template = allocate(/mob/living/carbon/human)
	var/mob/living/carbon/human/exile = loop.create_exile_avatar(template)
	TEST_ASSERT(exile, "Exile loop failed to create an avatar")
	var/datum/mind/exile_mind = new("exile_gib_test")
	exile_mind.current = exile
	exile.mind = exile_mind
	exile.AddComponent(/datum/component/digital_exile, exile_mind)

	exile.gib(TRUE, TRUE, TRUE)
	sleep(1)
	var/mob/living/carbon/human/new_avatar = exile_mind.current
	var/respawned = istype(new_avatar) && new_avatar != exile && !QDELETED(new_avatar)
	var/has_component = respawned && new_avatar.GetComponent(/datum/component/digital_exile)
	if(respawned)
		qdel(new_avatar.GetComponent(/datum/component/digital_exile))
		qdel(new_avatar)
	GLOB.digital_exiles -= exile_mind

	TEST_ASSERT(respawned, "A gibbed exile never respawned in the loop")
	TEST_ASSERT(has_component, "The respawned exile is not an exile any more")

/// AQUILA - dwa nakładające się ładowania domen nie zostawiają atmosfery wyłączonej
/datum/unit_test/aquila_lazy_template_overlapping_loads

/datum/unit_test/aquila_lazy_template_overlapping_loads/Run()
	var/old_loads = GLOB.lazy_template_loads
	GLOB.lazy_template_loads = 0
	SSair.can_fire = TRUE
	lazy_template_load_started() // A
	lazy_template_load_started() // B, zanim A skończy
	lazy_template_load_finished() // A
	var/air_during_b = SSair.can_fire
	lazy_template_load_finished() // B
	var/air_after = SSair.can_fire
	GLOB.lazy_template_loads = old_loads
	SSair.can_fire = TRUE

	TEST_ASSERT(!air_during_b, "Atmos restarted while a domain was still loading")
	TEST_ASSERT(air_after, "Two overlapping domain loads left atmos disabled for the rest of the round")

/// AQUILA - pad zamówień ekstraktów nie przyjmuje nagrody z budżetu nauki, na który ta nagroda wraca
/datum/unit_test/aquila_extract_request_science_budget

/datum/unit_test/aquila_extract_request_science_budget/Run()
	var/obj/machinery/slime_extract_requestor/pad = allocate(/obj/machinery/slime_extract_requestor)
	var/obj/item/card/id/departmental_budget/sci/budget_card = allocate(/obj/item/card/id/departmental_budget/sci)
	var/datum/bank_account/personal = new("Test Holder", SSjob.GetJobType(/datum/job/assistant))
	var/science_allowed = pad.can_pay_from(budget_card.registered_account)
	var/personal_allowed = pad.can_pay_from(personal)
	qdel(personal)

	TEST_ASSERT(!science_allowed, "The science budget card can pay a reward that goes back to the science budget")
	TEST_ASSERT(personal_allowed, "A personal account cannot pay an extract reward")

/// AQUILA - wykute pudełko sprzedane promem daje tyle, ile pokazuje skaner, a nie 0 kr
/datum/unit_test/aquila_forged_box_shuttle_export

/datum/unit_test/aquila_forged_box_shuttle_export/Run()
	var/obj/item/ammo_box/c9mm/box = allocate(/obj/item/ammo_box/c9mm)
	TEST_ASSERT(GLOB.munition_products[box.type], "Test setup: the forge does not make 9mm boxes")
	var/datum/munition_material/material = get_munition_material(/datum/material/uranium)
	var/datum/munition_quality/quality = get_munition_quality(/datum/munition_quality)
	for(var/obj/item/ammo_casing/casing in box.stored_ammo)
		casing.AddComponent(/datum/component/forged_munition, material, quality)
	var/expected = forged_munition_value(box)
	TEST_ASSERT(expected > 0, "Test setup: the forged box has no value")

	var/datum/export_report/scan = export_item_and_contents(box, EXPORT_CARGO, dry_run = TRUE)
	var/scanned = 0
	for(var/datum/export/E in scan.total_amount)
		scanned += scan.total_value[E]

	// tak jak prom: sprzedaż kasuje towar, potem total_printout i wpłata
	var/datum/export_report/sale = export_item_and_contents(box, EXPORT_CARGO, dry_run = FALSE)
	var/paid = 0
	for(var/datum/export/E in sale.total_amount)
		E.total_printout(sale)
		paid += sale.total_value[E]

	TEST_ASSERT(abs(scanned - expected) < 1, "The export scanner shows [scanned] kr for a box worth [expected] kr")
	TEST_ASSERT_EQUAL(paid, expected, "Selling a forged box on the cargo shuttle did not pay its value")
	TEST_ASSERT(QDELETED(box), "The sold box was not removed")

/// AQUILA - wygnaniec wchodzący bramą Pętli staje obok drabiny wyjścia, a nie na niej
/datum/unit_test/aquila_exile_gate_arrival

/datum/unit_test/aquila_exile_gate_arrival/Run()
	var/turf/ladder_turf = locate(run_loc_floor_bottom_left.x + 1, run_loc_floor_bottom_left.y + 1, run_loc_floor_bottom_left.z)
	var/obj/structure/hololadder/ladder = allocate(/obj/structure/hololadder, ladder_turf)
	var/obj/structure/exile_gate/gate = allocate(/obj/structure/exile_gate, run_loc_floor_bottom_left)
	var/turf/arrival = gate.get_arrival_turf(get_turf(ladder))

	TEST_ASSERT(arrival != ladder_turf, "The exile arrives on the exit ladder and gets disconnected at once")
	TEST_ASSERT(!(locate(/obj/structure/hololadder) in arrival), "The exile arrives on another exit ladder")
	TEST_ASSERT_EQUAL(get_dist(arrival, ladder_turf), 1, "The exile does not arrive next to the exit ladder")

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
