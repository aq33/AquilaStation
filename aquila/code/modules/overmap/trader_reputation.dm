// AQUILA - reputacja okrętu u handlarza (przywracanie misji NSV, raport/nsv_martwe_08_specyfikacja.md, punkt 10).
// Handlarze mieli już jedną „reputację”: oferty specjalne (special_offers) odblokowują punkty wpływów frakcji okrętu
// (faction.tickets), ale tylko u stacji, których system_type to frakcja okrętu. Tu dochodzi reputacja u konkretnej
// stacji: rośnie za misje (trader_missions.dm), spada za porażki. Daje zniżkę na cały towar stacji, a od poziomu
// „zaufany partner” otwiera też oferty specjalne, niezależnie od wpływów frakcji (hook AQ EDIT w stock_items()).
// Zniżka nie zmienia item.price (to cena katalogowa, którą ruszają też wiadomości gospodarcze), tylko cenę zakupu
// (aq_price(), hook w attempt_purchase()) i cenę pokazaną w oknie.

#define TRADER_REP_GOOD 20
#define TRADER_REP_TRUSTED 50
#define TRADER_REP_HONOR 100
#define TRADER_REP_MAX 150

/datum/trader
	/// Reputacja okrętu gracza u tej stacji (0–TRADER_REP_MAX)
	var/aq_reputation = 0

/// Poziom reputacji: list(nazwa, zniżka w %, próg następnego poziomu albo null)
/datum/trader/proc/aq_reputation_level()
	if(aq_reputation >= TRADER_REP_HONOR)
		return list("honorowy kontrahent", 15, null)
	if(aq_reputation >= TRADER_REP_TRUSTED)
		return list("zaufany partner", 10, TRADER_REP_HONOR)
	if(aq_reputation >= TRADER_REP_GOOD)
		return list("dobry klient", 5, TRADER_REP_TRUSTED)
	return list("obcy", 0, TRADER_REP_GOOD)

/datum/trader/proc/aq_discount()
	var/list/level = aq_reputation_level()
	return level[2]

/// Cena zakupu po zniżce za reputację
/datum/trader/proc/aq_price(datum/trader_item/item)
	return max(1, round(item.price * (100 - aq_discount()) / 100))

/// Oferty specjalne za reputację (obok wpływów frakcji w stock_items())
/datum/trader/proc/aq_special_unlocked()
	return aq_reputation >= TRADER_REP_TRUSTED

/datum/trader/proc/aq_adjust_reputation(amount)
	var/was_special = aq_special_unlocked()
	var/old_level = aq_reputation_level()[1]
	aq_reputation = clamp(aq_reputation + amount, 0, TRADER_REP_MAX)
	var/new_level = aq_reputation_level()[1]
	if(new_level == old_level)
		return
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	if(amount > 0)
		ship?.hail("Wasza reputacja u nas rośnie: jesteście teraz dla nas „[new_level]” (zniżka [aq_discount()]%).", name)
	else
		ship?.hail("Zawiedliście nas. Jesteście teraz dla nas „[new_level]” (zniżka [aq_discount()]%).", name)
	// Nowo odblokowane oferty specjalne pojawiają się od razu, a nie przy następnej dostawie towaru
	if(!was_special && aq_special_unlocked() && length(special_offers))
		next_restock = 0

/datum/trader/ui_data(mob/user)
	. = ..()
	var/discount = aq_discount()
	if(discount)
		for(var/list/item_info as anything in .["items_info"])
			var/datum/trader_item/item = locate(item_info["id"])
			if(!istype(item))
				continue
			var/price = aq_price(item)
			item_info["price"] = price
			item_info["desc"] = "[price]$ - [item.desc]"
	var/list/level = aq_reputation_level()
	.["aq_reputation"] = list(
		"points" = aq_reputation,
		"level" = level[1],
		"discount" = level[2],
		"next" = level[3],
		"special" = aq_special_unlocked() && length(special_offers),
	)

#undef TRADER_REP_GOOD
#undef TRADER_REP_TRUSTED
#undef TRADER_REP_HONOR
#undef TRADER_REP_MAX
