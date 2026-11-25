// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define TEST_ASSERT_EQUAL(a, b, message) do { \
	var/lhs = ##a; \
	var/rhs = ##b; \
	if (lhs != rhs) { \
		return Fail("Expected [isnull(lhs) ? "null" : lhs] to be equal to [isnull(rhs) ? "null" : rhs].[message ? " [message]" : ""]"); \
	} \
} while (FALSE)

/// AQUILA - konsola zamówień kuchni: bez dostępu nic nie kupuje, bon daje 10 darmowych sztuk,
/// płaci budżet usług (nie konto z karty), a zakupy trafiają jako zamrażarka do zamówień promu
/datum/unit_test/aquila_order_console_cook
	var/datum/bank_account/budget_account
	var/budget_before

/datum/unit_test/aquila_order_console_cook/Destroy()
	if(budget_account)
		budget_account.account_balance = budget_before
		budget_account = null
	return ..()

/datum/unit_test/aquila_order_console_cook/Run()
	var/mob/living/carbon/human/cook = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/machinery/computer/order_console/cook/console = allocate(/obj/machinery/computer/order_console/cook, get_step(run_loc_floor_bottom_left, EAST))
	var/obj/item/card/id/card = allocate(/obj/item/card/id)
	var/datum/bank_account/personal = new("Test Cook", SSjob.GetJobType(/datum/job/cook))
	card.registered_account = personal
	personal.account_balance = 1000

	var/datum/bank_account/budget = SSeconomy.get_dep_account(ACCOUNT_SRV)
	TEST_ASSERT(budget, "No service budget account")
	budget_account = budget
	budget_before = budget.account_balance
	budget.account_balance = 5000

	var/datum/orderable_item/potato = locate(/datum/orderable_item/kitchen_produce/potato) in GLOB.order_console_products
	var/datum/orderable_item/tomato = locate(/datum/orderable_item/kitchen_produce/tomato) in GLOB.order_console_products
	var/datum/orderable_item/carrot = locate(/datum/orderable_item/kitchen_produce/carrot) in GLOB.order_console_products
	TEST_ASSERT(potato && tomato && carrot, "Kitchen produce is missing from the order console products")

	var/obj/item/cooking_voucher/voucher = allocate(/obj/item/cooking_voucher)
	cook.put_in_active_hand(voucher)
	console.attackby(voucher, cook)
	TEST_ASSERT(QDELETED(voucher), "The voucher was not used up")
	TEST_ASSERT_EQUAL(console.free_uses, 10, "A voucher should give 10 free items")
	cook.put_in_active_hand(card) // bez munduru karta nie wejdzie do slotu ID

	var/datum/tgui/ui = new(cook, console, "ProduceConsole")
	usr = cook
	// Bon nie blokuje małych zamówień: minimum liczy się od wartości bez bonu, a zamówienie w całości z bonu przechodzi
	console.ui_act("cart_set", list("target" = REF(potato), "amt" = 10), ui)
	TEST_ASSERT(console.order_minimum_met(), "An order fully covered by the voucher was blocked by the minimum")
	console.ui_act("cart_set", list("target" = REF(potato), "amt" = 20), ui)
	console.ui_act("cart_set", list("target" = REF(tomato), "amt" = 15), ui)
	// 25 płatnych × 20 × 0,65 = 325 kr, ale wartość bez bonu 35 × 20 × 0,65 = 455 kr
	TEST_ASSERT(console.get_final_cost(FALSE) < console.minimum_order_value, "Test setup: the paid part should be below the minimum")
	TEST_ASSERT(console.order_minimum_met(), "The voucher discount pushed an order worth [console.minimum_order_value] kr below the minimum")
	console.ui_act("cart_set", list("target" = REF(tomato), "amt" = 0), ui)
	console.ui_act("cart_set", list("target" = REF(potato), "amt" = 15), ui)
	TEST_ASSERT(!console.order_minimum_met(), "An order below the minimum passed")
	for(var/datum/orderable_item/item as anything in list(potato, tomato, carrot))
		console.ui_act("cart_set", list("target" = REF(item), "amt" = 20), ui)
	// 60 sztuk po 20 kr, 10 za darmo: 50 × 20 × 0,65 = 650 kr
	TEST_ASSERT_EQUAL(console.get_final_cost(FALSE), 650, "Wrong cart cost with the voucher")
	var/list/window_data = console.ui_data(cook)
	var/shown_cost = window_data["cargo_total"]


	var/orders_before = length(SSshuttle.shoppinglist)
	card.access = list()
	console.ui_act("purchase", list(), ui)
	var/budget_without_access = budget.account_balance
	var/orders_without_access = length(SSshuttle.shoppinglist)

	card.access = list(ACCESS_KITCHEN)
	console.ui_act("purchase", list(), ui)
	usr = null
	qdel(ui)

	var/datum/supply_order/new_order
	if(length(SSshuttle.shoppinglist) > orders_before)
		new_order = SSshuttle.shoppinglist[length(SSshuttle.shoppinglist)]
		SSshuttle.shoppinglist -= new_order
	var/budget_after = budget.account_balance
	var/personal_after = personal.account_balance
	card.registered_account = null
	qdel(personal)

	TEST_ASSERT_EQUAL(budget_without_access, 5000, "The console spent the budget for someone without kitchen or bar access")
	TEST_ASSERT_EQUAL(orders_without_access, orders_before, "The console placed an order for someone without kitchen or bar access")
	TEST_ASSERT(new_order, "The purchase did not add an order to the supply shuttle")
	TEST_ASSERT(istype(new_order.pack, /datum/supply_pack/order_console), "The order is not a prepaid order console pack")
	TEST_ASSERT_EQUAL(length(new_order.pack.contains), 60, "The order does not contain every bought item")
	TEST_ASSERT_EQUAL(new_order.pack.crate_type, /obj/structure/closet/crate/freezer, "Kitchen groceries should come in a freezer")
	TEST_ASSERT_EQUAL(budget_after, 5000 - 650, "The service budget paid the wrong amount")
	TEST_ASSERT_EQUAL(5000 - budget_after, shown_cost, "The order button showed a different amount than the console charged")
	TEST_ASSERT_EQUAL(personal_after, 1000, "The cook's personal account was charged")
	TEST_ASSERT_EQUAL(console.free_uses, 0, "The voucher's free items were not used up")
	TEST_ASSERT(!length(console.grocery_list), "The cart was not emptied after the purchase")
	qdel(new_order)

#undef TEST_ASSERT
#undef TEST_ASSERT_EQUAL
