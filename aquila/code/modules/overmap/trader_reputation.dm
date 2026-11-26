// AQUILA - reputacja okrętu u handlarzy. Jedna reputacja u frakcji kupca (GLOB.civilian_standing, civilians.dm):
// ostrzał własnych i neutralnych cywilów ją obniża, misje stacji (trader_missions.dm, station_contracts.dm) podnoszą,
// a porażki obniżają. Od niej zależy cena u wszystkich kupców tej frakcji: poniżej neutralnej (100) drożej, poniżej zera
// kupcy nie handlują, powyżej zniżka, a od poziomu „zaufany partner” też oferty specjalne, niezależnie od wpływów frakcji
// NSV (hook AQ EDIT w stock_items()). Cena katalogowa (item.price, ruszają ją też wiadomości gospodarcze) zostaje, zmienia
// się tylko cena zakupu (aq_price(), hook w attempt_purchase()) i cena pokazana w oknie.

#define TRADER_REP_NEUTRAL 100
#define TRADER_REP_GOOD 120
#define TRADER_REP_TRUSTED 150
#define TRADER_REP_HONOR 200

/// Reputacja okrętu gracza u frakcji tego kupca (neutralnie 100); kupiec bez frakcji w tabeli: neutralnie
/datum/trader/proc/aq_reputation()
	var/key = civilian_standing_key()
	if(!key)
		return TRADER_REP_NEUTRAL
	if(isnull(GLOB.civilian_standing[key]))
		GLOB.civilian_standing[key] = TRADER_REP_NEUTRAL
	return GLOB.civilian_standing[key]

/// Poziom reputacji: list(nazwa, zniżka w %, próg następnego poziomu albo null)
/datum/trader/proc/aq_reputation_level()
	var/points = aq_reputation()
	if(points >= TRADER_REP_HONOR)
		return list("honorowy kontrahent", 15, null)
	if(points >= TRADER_REP_TRUSTED)
		return list("zaufany partner", 10, TRADER_REP_HONOR)
	if(points >= TRADER_REP_GOOD)
		return list("dobry klient", 5, TRADER_REP_TRUSTED)
	if(points >= TRADER_REP_NEUTRAL)
		return list("obcy", 0, TRADER_REP_GOOD)
	if(points >= 0)
		return list("podejrzany", 0, TRADER_REP_NEUTRAL)
	return list("wróg", 0, 0)

/datum/trader/proc/aq_discount()
	var/list/level = aq_reputation_level()
	return level[2]

/// Cena zakupu: zniżka za dobrą reputację albo narzut za złą (ostrzał cywilów)
/datum/trader/proc/aq_price(datum/trader_item/item)
	return max(1, round(item.price * civilian_price_mult() * (100 - aq_discount()) / 100))

/// Oferty specjalne za reputację (obok wpływów frakcji w stock_items())
/datum/trader/proc/aq_special_unlocked()
	return aq_reputation() >= TRADER_REP_TRUSTED

/datum/trader/proc/aq_adjust_reputation(amount)
	var/key = civilian_standing_key()
	if(!key)
		return
	var/was_special = aq_special_unlocked()
	var/old_level = aq_reputation_level()[1]
	aq_reputation() // tworzy wpis frakcji, jeśli go nie było
	adjust_civilian_standing(key, amount)
	var/new_level = aq_reputation_level()[1]
	if(new_level == old_level)
		return
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	if(amount > 0)
		ship?.hail("Wasza reputacja u nas rośnie: jesteście teraz dla nas „[new_level]” (zniżka [aq_discount()]%).", name)
	else
		ship?.hail("Zawiedliście nas. Jesteście teraz dla nas „[new_level]” (zniżka [aq_discount()]%).", name)
	// Nowo odblokowane oferty specjalne pojawiają się od razu, a reszta towaru i cen zostaje (bez losowania na nowo)
	if(!was_special && aq_special_unlocked())
		aq_add_special_offers()

/// Dokłada oferty specjalne do obecnego towaru, jak stock_items() (nazwa, cena i ilość losowane tak samo)
/datum/trader/proc/aq_add_special_offers()
	if(!next_restock)
		return // sklep jeszcze nie był otwierany: stock_items() przy pierwszym otwarciu i tak doda oferty (wyprzedany ma next_restock)
	var/list/present = list()
	for(var/datum/trader_item/existing as anything in stonks)
		present |= existing.type
	for(var/item_path in special_offers)
		if(item_path in present)
			continue // ta oferta już jest: jej cena i zapas zostają
		var/datum/trader_item/TI = new item_path()
		TI.name = "SPECJALNA OFERTA! " + TI.name
		TI.price = round(rand((2 * TI.price) / 3, TI.price * 2))
		TI.stock = round(rand(TI.stock / 2, TI.stock * 2))
		TI.owner = src
		stonks += TI

/datum/trader/ui_data(mob/user)
	. = ..()
	if(refuses_trade())
		.["greeting"] = "Nie handlujemy z okrętem, który strzela do cywilów."
	for(var/list/item_info as anything in .["items_info"])
		var/datum/trader_item/item = locate(item_info["id"])
		if(!istype(item))
			continue
		var/price = aq_price(item)
		if(price == item.price)
			continue
		item_info["price"] = price
		item_info["desc"] = "[price]$ - [item.desc]"
	var/list/level = aq_reputation_level()
	.["aq_reputation"] = list(
		"points" = aq_reputation(),
		"level" = level[1],
		"discount" = level[2],
		"next" = level[3],
		"special" = aq_special_unlocked() && length(special_offers),
	)

#undef TRADER_REP_NEUTRAL
#undef TRADER_REP_GOOD
#undef TRADER_REP_TRUSTED
#undef TRADER_REP_HONOR
