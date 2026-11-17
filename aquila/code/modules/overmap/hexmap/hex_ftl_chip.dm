// AQUILA - układy FTL na mapie hex: matryca strumienia (poziom 2, badanie ftl_slipstream) i układ napędu warp (poziom 3,
// handlarz i późne badanie). Układ wkłada się do konsoli nawigacji z mapą galaktyki, nie do napędu, a w jej oknie
// (HexStarmap.tsx) wybiera się jeden bonus skoku, z możliwością przełączenia. Koszty z bonusem liczy hex_cost():
// skok (hex_drive.dm), trasa i zasięg w oknie (hex_console.dm, hex_grid.dm), więc okno tylko pokazuje liczby z DM.
//
// Bonus                       | poziom 2 (matryca strumienia)      | poziom 3 (układ warp)
// tańszy skok                 | kafel 25%, brama 50%               | kafel 20%, brama 40%
// dwa kafle za cenę jednego   | drugi kafel skoku gratis           | co drugi kafel skoku gratis
// krótszy rozruch i stygnięcie| rozruch 5 s, stygnięcie 30 s       | rozruch 2 s, stygnięcie 15 s
// dłuższy zasięg skoku        | napęd ładuje się do 150% (4 kafle) | do 200% (6 kafli)
// Bez układu: kafel 34%, brama 67%, rozruch 10 s, stygnięcie 60 s, napęd do 100% (3 kafle).

/obj/item/ftl_slipstream_chip
	/// Wybrany bonus skoku na mapie hex (HEX_CHIP_*)
	var/hex_bonus = HEX_CHIP_CHEAP
	/// Okręt, którego konsola nawigacji trzyma ten układ
	var/obj/structure/overmap/hex_ship

/obj/item/ftl_slipstream_chip/Destroy()
	hex_uninstall()
	return ..()

/// Układ opuścił konsolę: okręt traci bonus
/obj/item/ftl_slipstream_chip/proc/hex_uninstall()
	var/obj/structure/overmap/ship = hex_ship
	hex_ship = null
	if(ship?.hex_chip == src)
		ship.hex_chip = null
		ship.hex_bonus_changed()

/obj/structure/overmap
	/// Układ FTL włożony do konsoli nawigacji tego okrętu (leży w tej konsoli)
	var/obj/item/ftl_slipstream_chip/hex_chip

/// Bonusy do wyboru, w kolejności przycisków w oknie
/proc/hex_chip_bonuses()
	return list(HEX_CHIP_CHEAP, HEX_CHIP_DOUBLE, HEX_CHIP_QUICK, HEX_CHIP_RANGE)

/proc/hex_chip_bonus_name(bonus)
	switch(bonus)
		if(HEX_CHIP_CHEAP)
			return "Tańszy skok"
		if(HEX_CHIP_DOUBLE)
			return "Dwa kafle za cenę jednego"
		if(HEX_CHIP_QUICK)
			return "Krótszy rozruch i stygnięcie"
		if(HEX_CHIP_RANGE)
			return "Dłuższy zasięg skoku"

/proc/hex_chip_bonus_desc(bonus, tier)
	var/warp = tier >= 3
	switch(bonus)
		if(HEX_CHIP_CHEAP)
			return warp ? "Kafel kosztuje 20% ładunku zamiast 34%, brama 40% zamiast 67%." : "Kafel kosztuje 25% ładunku zamiast 34%, brama 50% zamiast 67%."
		if(HEX_CHIP_DOUBLE)
			return warp ? "W każdym skoku co drugi kafel jest za darmo (bramy płatne)." : "W każdym skoku drugi kafel jest za darmo (bramy płatne)."
		if(HEX_CHIP_QUICK)
			return warp ? "Rozruch 2 s zamiast 10 s, stygnięcie po skoku 15 s zamiast 60 s." : "Rozruch 5 s zamiast 10 s, stygnięcie po skoku 30 s zamiast 60 s."
		if(HEX_CHIP_RANGE)
			return warp ? "Napęd ładuje się do 200%: jeden skok sięga 6 kafli." : "Napęd ładuje się do 150%: jeden skok sięga 4 kafli."

/// Poziom układu FTL okrętu, jeśli wybrany jest ten bonus, inaczej 0
/obj/structure/overmap/proc/hex_chip_tier(bonus)
	if(!hex_chip || hex_chip.hex_bonus != bonus)
		return 0
	return hex_chip.tier

/// Koszt skoku w procentach ładunku przez tyle bram i zwykłych kafli, z bonusem układu FTL
/obj/structure/overmap/proc/hex_cost(gates, hexes)
	var/paid_hexes = hexes
	var/double = hex_chip_tier(HEX_CHIP_DOUBLE)
	if(double >= 3)
		paid_hexes = CEILING(hexes / 2, 1)
	else if(double && hexes >= 2)
		paid_hexes = hexes - 1
	. = gates * HEX_FTL_COST_GATE + paid_hexes * HEX_FTL_COST_HEX
	var/cheap = hex_chip_tier(HEX_CHIP_CHEAP)
	if(cheap >= 3)
		. *= 0.6
	else if(cheap)
		. *= 0.75

/// Koszt trasy z GLOB.hexmap.route() dla tego okrętu
/obj/structure/overmap/proc/hex_route_cost(list/route)
	return hex_cost(route["gates"], route["hexes"] - route["gates"])

/// Pojemność napędu w procentach (bonus zasięgu ładuje ponad pełny napęd)
/obj/structure/overmap/proc/hex_capacity()
	var/range = hex_chip_tier(HEX_CHIP_RANGE)
	if(range >= 3)
		return 200
	if(range)
		return 150
	return HEX_FTL_FULL_CHARGE

/// Rozruch skoku po hexach
/obj/structure/overmap/proc/hex_startup_delay()
	var/quick = hex_chip_tier(HEX_CHIP_QUICK)
	if(quick >= 3)
		return 2 SECONDS
	if(quick)
		return 5 SECONDS
	return HEX_FTL_STARTUP

/// Stygnięcie napędu po skoku po hexach
/obj/structure/overmap/proc/hex_cooldown_time()
	var/quick = hex_chip_tier(HEX_CHIP_QUICK)
	if(quick >= 3)
		return 15 SECONDS
	if(quick)
		return 30 SECONDS
	return HEX_FTL_COOLDOWN

/// Progi ładunku pokazywanego graczom (hex_charge_text): kafel, brama, pełny napęd
/obj/structure/overmap/proc/hex_charge_thresholds()
	return list(hex_cost(0, 1), hex_cost(1, 0), hex_capacity())

/// Po włożeniu, wyjęciu albo przełączeniu bonusu: ładunek nie przekracza pojemności, a napęd ładuje się do nowej
/obj/structure/overmap/proc/hex_bonus_changed()
	if(!ftl_drive)
		return
	var/fraction = hex_capacity() / 100
	if(istype(ftl_drive, /obj/machinery/computer/ship/ftl_core))
		ftl_drive.progress = min(ftl_drive.progress, ftl_drive.req_charge * fraction)
	else
		var/obj/machinery/computer/ship/ftl_computer/legacy = ftl_drive
		if(istype(legacy))
			legacy.progress = min(legacy.progress, legacy.spoolup_time * fraction)
	if(!hex_in_flight())
		hex_resume_charging()

// Konsola nawigacji z mapą hex przyjmuje układ FTL (na starej mapie gwiezdnej układ dalej idzie do napędu)
/obj/machinery/computer/ship/navigation/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/ftl_slipstream_chip) || !uses_hex_map())
		return ..()
	if(!has_overmap())
		to_chat(user, "<span class='warning'>Konsola nie jest połączona z okrętem.</span>")
		return TRUE
	hex_install_chip(I, user)
	return TRUE

/// Wkłada układ FTL; słabszy albo równy układ okrętu wypada z konsoli, w której leżał. Zwraca TRUE po włożeniu.
/obj/machinery/computer/ship/navigation/proc/hex_install_chip(obj/item/ftl_slipstream_chip/chip, mob/user)
	var/obj/item/ftl_slipstream_chip/old = linked.hex_chip
	if(old && old.tier >= chip.tier)
		if(user)
			to_chat(user, "<span class='warning'>Okręt ma już układ FTL tego samego albo wyższego poziomu.</span>")
		return FALSE
	if(user && !user.transferItemToLoc(chip, src))
		return FALSE
	chip.forceMove(src)
	if(old)
		chip.hex_bonus = old.hex_bonus
	// Nowy układ przejmuje okręt, zanim stary wypadnie: odpięcie starego nie przycina wtedy ładunku do pojemności bez układu
	chip.hex_ship = linked
	linked.hex_chip = chip
	if(old)
		var/atom/old_holder = old.loc
		old.forceMove(old_holder ? old_holder.drop_location() : drop_location()) // Exited() konsoli odpina stary układ
		old.hex_uninstall()
	linked.hex_bonus_changed()
	hex_ui_cache = null
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
	if(user)
		to_chat(user, "<span class='notice'>Wkładasz [chip] do [src]. Bonus skoku wybierz w oknie mapy galaktyki.</span>")
		log_game("[key_name(user)] installed [chip] (tier [chip.tier]) into [src] of [linked].")
	return TRUE

/obj/machinery/computer/ship/navigation/Exited(atom/movable/gone, direction)
	. = ..()
	if(istype(gone, /obj/item/ftl_slipstream_chip))
		var/obj/item/ftl_slipstream_chip/chip = gone
		chip.hex_uninstall()

/obj/machinery/computer/ship/navigation/Destroy()
	for(var/obj/item/ftl_slipstream_chip/chip in src)
		chip.forceMove(drop_location())
	return ..()

/// Dane układu do okna (null bez układu)
/obj/machinery/computer/ship/navigation/proc/hex_chip_ui_data()
	var/obj/item/ftl_slipstream_chip/chip = linked.hex_chip
	if(!chip)
		return null
	var/list/bonuses = list()
	for(var/bonus in hex_chip_bonuses())
		bonuses += list(list("id" = bonus, "name" = hex_chip_bonus_name(bonus), "desc" = hex_chip_bonus_desc(bonus, chip.tier)))
	return list("name" = chip.name, "tier" = chip.tier, "bonus" = chip.hex_bonus, "bonuses" = bonuses)

/// Przełącza bonus układu. Zwraca TRUE, jeśli się zmienił.
/obj/machinery/computer/ship/navigation/proc/hex_set_chip_bonus(bonus, mob/user)
	var/obj/item/ftl_slipstream_chip/chip = linked?.hex_chip
	if(!chip || !(bonus in hex_chip_bonuses()) || chip.hex_bonus == bonus)
		return FALSE
	// koszt skoku jest już policzony, a rozruch i stygnięcie liczą się z bonusu: przełączenie teraz łączyłoby dwa bonusy
	if(linked.ftl_drive?.ftl_state == FTL_STATE_JUMPING)
		if(user)
			to_chat(user, "<span class='warning'>W czasie rozruchu skoku nie można przełączyć bonusu układu FTL.</span>")
		return FALSE
	chip.hex_bonus = bonus
	linked.hex_bonus_changed()
	if(user)
		log_game("[key_name(user)] switched the FTL chip bonus of [linked] to [bonus].")
	return TRUE

// Na mapie hex układ wkłada się do konsoli nawigacji: w napędzie skracał tylko ładowanie
/obj/machinery/computer/ship/ftl_computer/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/ftl_slipstream_chip) && GLOB.hexmap?.built)
		to_chat(user, "<span class='notice'>Ten układ wkłada się do konsoli nawigacji z mapą galaktyki, nie do napędu.</span>")
		return TRUE
	return ..()

/obj/machinery/computer/ship/ftl_core/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/ftl_slipstream_chip) && GLOB.hexmap?.built)
		to_chat(user, "<span class='notice'>Ten układ wkłada się do konsoli nawigacji z mapą galaktyki, nie do napędu.</span>")
		return TRUE
	return ..()

// Opis układu mówi, gdzie go włożyć
/obj/item/ftl_slipstream_chip/examine(mob/user)
	. = ..()
	if(GLOB.hexmap?.built)
		. += "<span class='notice'>Wkłada się go do konsoli nawigacji z mapą galaktyki. Daje jeden bonus skoku do wyboru w jej oknie.</span>"

// Źródła układu warp: Minsky Heavy Engineering (stocznia z częściami) i późne badanie po matrycy strumienia

/datum/trader_item/aquila_warp_chip
	name = "Układ napędu warp"
	desc = "Eksperymentalny układ do konsoli nawigacji. Daje najmocniejszą wersję wybranego bonusu skoku."
	price = 50000
	stock = 1
	unlock_path = /obj/item/ftl_slipstream_chip/warp

/datum/trader/minsky/New()
	. = ..()
	sold_items |= /datum/trader_item/aquila_warp_chip

/datum/design/ftl_warp_chip
	name = "układ napędu warp"
	desc = "Najmocniejszy układ FTL do konsoli nawigacji: wzmacnia wybrany bonus skoku bardziej niż matryca strumienia."
	id = "ftl_warp_chip"
	build_type = PROTOLATHE
	materials = list(/datum/material/plasma = 40000, /datum/material/diamond = 20000, /datum/material/uranium = 15000, /datum/material/bluespace = 10000)
	build_path = /obj/item/ftl_slipstream_chip/warp
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/techweb_node/ftl_warp
	id = "ftl_warp"
	display_name = "Napęd warp"
	description = "Eksperymentalny układ FTL, który zakrzywia przestrzeń zamiast wnikać w bluespace."
	prereq_ids = list("ftl_slipstream", "fighter_tier3")
	design_ids = list("ftl_warp_chip")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 12500, TECHWEB_POINT_TYPE_WORMHOLE = 10000)
	export_price = 30000

// Źródło punktów tuneli na mapie hex: kafel tunelu ma anomalię tunelu do skanu sondą (bez niej badanie
// matrycy strumienia było nieosiągalne, bo tunele z mapy hex nie miały obiektu anomalii)
/datum/hex/proc/hex_spawn_wormhole_anomaly()
	var/datum/star_system/S = GLOB.hexmap.system_for(src)
	for(var/obj/effect/overmap_anomaly/wormhole/W in S.system_contents)
		return W
	return SSstar_system.spawn_anomaly(/obj/effect/overmap_anomaly/wormhole, S, center = TRUE)
