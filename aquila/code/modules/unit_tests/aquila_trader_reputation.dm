// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

/// AQUILA - reputacja u handlarza (trader_reputation.dm): zniżka rośnie z poziomem, od „zaufanego partnera” są oferty
/// specjalne dochodzą od razu do obecnego towaru (bez losowania na nowo), a cena katalogowa zostaje bez zmian
/datum/unit_test/aquila_trader_reputation

/datum/unit_test/aquila_trader_reputation/Run()
	var/datum/trader/T = new /datum/trader/shallowstone
	var/datum/trader_item/item = new
	item.price = 1000
	T.special_offers = list(/datum/trader_item/ship_repair/tier3)
	T.next_restock = world.time + 10 MINUTES
	var/datum/trader_item/stocked = new
	T.stonks = list(stocked)
	TEST_ASSERT(T.aq_price(item) == 1000, "A trader without reputation gave a discount ([T.aq_price(item)])")
	T.aq_adjust_reputation(20)
	TEST_ASSERT(T.aq_price(item) == 950, "A good client didn't get 5% off ([T.aq_price(item)])")
	TEST_ASSERT(!T.aq_special_unlocked(), "Special offers unlocked at the first reputation level")
	T.aq_adjust_reputation(30)
	TEST_ASSERT(T.aq_price(item) == 900, "A trusted partner didn't get 10% off ([T.aq_price(item)])")
	TEST_ASSERT(T.aq_special_unlocked(), "A trusted partner doesn't see special offers")
	TEST_ASSERT(T.next_restock > world.time, "Unlocking special offers rerolled the whole stock")
	TEST_ASSERT(stocked in T.stonks, "Unlocking special offers threw away the current stock")
	TEST_ASSERT(locate(/datum/trader_item/ship_repair/tier3) in T.stonks, "Unlocking special offers didn't add them to the stock")
	// Wyprzedany sklep z jedną ofertą specjalną już na półce: druga dochodzi, pierwsza zostaje ta sama
	T.aq_adjust_reputation(-1000)
	QDEL_LIST(T.stonks)
	var/datum/trader_item/ship_repair/tier3/kept = new
	T.stonks = list(kept)
	T.special_offers = list(/datum/trader_item/ship_repair/tier3, /datum/trader_item/mac)
	T.aq_adjust_reputation(50)
	TEST_ASSERT(kept in T.stonks, "A special offer already on the shelf was replaced")
	TEST_ASSERT(locate(/datum/trader_item/mac) in T.stonks, "A missing special offer wasn't added next to an existing one")
	var/repairs = 0
	for(var/datum/trader_item/ship_repair/tier3/R in T.stonks)
		repairs++
	TEST_ASSERT(repairs == 1, "A special offer already on the shelf was added twice")
	T.aq_adjust_reputation(1000)
	TEST_ASSERT(T.aq_reputation == 150, "Reputation went over the cap ([T.aq_reputation])")
	TEST_ASSERT(T.aq_price(item) == 850, "The top reputation level didn't give 15% off ([T.aq_price(item)])")
	T.aq_adjust_reputation(-1000)
	TEST_ASSERT(T.aq_reputation == 0 && T.aq_price(item) == 1000, "Losing all reputation didn't bring the full price back")
	// Cena katalogowa zostaje nietknięta (ruszają ją wiadomości gospodarcze)
	TEST_ASSERT(item.price == 1000, "The discount changed the list price of the item")

	QDEL_LIST(T.stonks)
	qdel(item)
	qdel(T)

#undef TEST_ASSERT
