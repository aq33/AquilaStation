// AQUILA - misje okrętu od handlarzy (przywrócony stary system misji NSV, raport/nsv_martwe_08_specyfikacja.md, punkt 10).
// W NSV handlarze dawali misje /datum/nsv_mission (nsv13/code/datums/missions.dm, komponenty w
// nsv13/code/datums/components/missions.dm, skrzynie w nsv13/code/modules/cargo/mission_cargos.dm; wszystko poza buildem,
// hooki w traders.dm zakomentowane). Tamten kod zakładał starą mapę gwiazd (alignment układów, send_fleet() frakcji,
// sygnały ładunku wysyłane do stacji zamiast do skrzyń), więc zamiast włączać go do buildu misje są tu napisane od nowa
// jako rodzaj zleceń stacji (station_contracts.dm): to samo okno handlarza, ten sam termin, anulowanie i rozliczanie,
// konsola zgłoszeń. Różnice: osobna pula ofert (MISSION_OFFERS_PER_STATION) i osobny limit przyjętych misji, nagroda dla
// budżetu zaopatrzenia + rzeczy kapsułą + reputacja u stacji (trader_reputation.dm) + wpływy NT jak w NSV.
// Rodzaje (jak w NSV): nagroda za okręty, oczyszczenie kafla z floty, obrona układu stacji przed falami, plombowane
// skrzynie (zwykłe i wysokiego ryzyka), uzbrojona głowica do „dostarczenia”, rozpoznanie trasy. Cele leżą na kaflach
// mapy hex i są zaznaczone na mapie nawigacji. Misje wybierane przez kapitana (mission_choice.dm, war_missions.dm) to
// cele trybu i działają niezależnie; tu niczego z nich nie powielamy (abordaże, wrak, skan zostają tylko tam).

#define MISSION_OFFERS_PER_STATION 2
#define MISSION_MAX_ACTIVE 3
#define MISSION_FAIL_REPUTATION 10
/// Wpływy NT za wykonaną misję (ticket_bounty z NSV)
#define MISSION_INFLUENCE 100
/// Za otwartą skrzynię płacimy tyle stawki (NSV: 0,25)
#define MISSION_TAMPERED_SHARE 0.25
/// Najdroższy towar, jaki stacja dorzuca jako sprzęt w nagrodę
#define MISSION_GEAR_MAX_PRICE 10000

/// Losowanie rodzaju misji (wagi z possible_mission_types w NSV)
GLOBAL_LIST_INIT(aq_mission_types, list(
	/datum/aq_contract/mission/kill_ships = 10,
	/datum/aq_contract/mission/clear_system = 6,
	/datum/aq_contract/mission/waves = 8,
	/datum/aq_contract/mission/cargo = 10,
	/datum/aq_contract/mission/cargo/high_risk = 7,
	/datum/aq_contract/mission/cargo/nuke = 1,
	/datum/aq_contract/mission/explore = 10,
))

/// Głowica trafia się najwyżej raz na rundę (w NSV waga malała po każdym losowaniu)
GLOBAL_VAR_INIT(aq_mission_nuke_offered, FALSE)

/proc/aq_max_missions()
	return MISSION_MAX_ACTIVE

/obj/structure/overmap/trader
	/// AQUILA - oferty misji okrętu (trader_missions.dm)
	var/list/aq_mission_offers

/// Czy stacja zleca misje okrętowi gracza (Syndykat nie zleca ich okrętom NT, jak check_eligible() w NSV)
/obj/structure/overmap/trader/proc/aq_gives_missions()
	return inhabited_trader && inhabited_trader.faction_type != FACTION_ID_SYNDICATE

/obj/structure/overmap/trader/proc/aq_get_mission_offers()
	if(isnull(aq_mission_offers))
		aq_mission_offers = list()
	if(!aq_gives_missions())
		return aq_mission_offers
	var/tries = 0
	while(length(aq_mission_offers) < MISSION_OFFERS_PER_STATION && tries++ < 10)
		var/list/types = GLOB.aq_mission_types.Copy()
		if(GLOB.aq_mission_nuke_offered)
			types -= /datum/aq_contract/mission/cargo/nuke
		var/mission_type = pickweight(types)
		var/datum/aq_contract/mission/M = new mission_type(src)
		if(M.invalid)
			qdel(M)
			continue
		aq_mission_offers += M
	return aq_mission_offers

// ---------------------------------------------------------------- wspólne

/datum/aq_contract/mission
	name = "misja"
	is_mission = TRUE
	account = ACCOUNT_CAR
	department_name = "Zaopatrzenie"
	duration = 45 MINUTES
	reputation = 10
	fail_reputation = MISSION_FAIL_REPUTATION
	/// Nie da się jej teraz zlecić (np. brak celu na mapie): generator ofert ją odrzuca
	var/invalid = FALSE
	/// Sprzęt w nagrodę: losowy towar ze sklepu stacji (do MISSION_GEAR_MAX_PRICE), za darmo kapsułą
	var/gear_reward = FALSE

/// Flota wystawiona przez misję zostaje po jej końcu tylko wtedy, gdy okręt gracza z nią walczy; inaczej znika
/// (floty obronne nie odlatują same, a w układzie stacji trzymałyby go jako zajęty przez wroga)
/datum/aq_contract/mission/proc/dispose_fleet(datum/weakref/ref)
	var/datum/fleet/F = ref?.resolve()
	if(!F || QDELETED(F))
		return
	if(F.current_system && ship()?.current_system == F.current_system)
		return
	F.hex_war_dispose()

/datum/aq_contract/mission/proc/ship()
	RETURN_TYPE(/obj/structure/overmap)
	return SSstar_system.find_main_overmap()

/// Kafel celu, zaznaczany na mapie nawigacji (albo null)
/datum/aq_contract/mission/proc/target_hex()
	return null

/datum/aq_contract/mission/on_accept(mob/user)
	var/datum/trader/T = station?.inhabited_trader
	ship()?.hail("[T ? "[pick(T.on_mission_give)] " : ""]Szczegóły misji: [desc]", station ? station.name : "Stacja")

/datum/aq_contract/mission/give_extra_rewards()
	. = ..()
	var/datum/faction/NT = SSstar_system.faction_by_id(FACTION_ID_NT)
	NT?.gain_influence(MISSION_INFLUENCE)
	if(gear_reward)
		give_gear()

/// Towar ze sklepu stacji za darmo (bez zmniejszania zapasu); bez pasującego towaru zostają kredyty i reszta nagród
/datum/aq_contract/mission/proc/give_gear()
	var/obj/structure/overmap/player = ship()
	var/datum/trader/T = station?.inhabited_trader
	if(!player || !T)
		return null
	var/list/options = list()
	for(var/datum/trader_item/item as anything in T.stonks)
		if(QDELETED(item) || !item.unlock_path || istype(item, /datum/trader_item/yellow_pages) || item.price > MISSION_GEAR_MAX_PRICE)
			continue
		options += item
	if(!length(options))
		return null
	var/datum/trader_item/gift = pick(options)
	gift.on_purchase(player)
	player.hail("W podziękowaniu dorzucamy z naszego magazynu: [gift.name].", station.name)
	return gift

/datum/aq_contract/mission/where_to_deliver()
	var/datum/hex/H = target_hex()
	return H ? "kafel [H.display_name()] ([hex_sector_name(H.sector)])" : "na okręcie"

/datum/aq_contract/mission/ui_entry()
	. = ..()
	.["where"] = where_to_deliver()
	if(gear_reward)
		var/list/items = .["items"]
		items += "towar ze sklepu stacji"

/// Misje w oknie handlarza (oferty tej stacji i misje od niej przyjęte)
/datum/trader/ui_data(mob/user)
	. = ..()
	var/obj/structure/overmap/trader/T = current_location
	if(!istype(T))
		return
	var/list/offers = list()
	for(var/datum/aq_contract/C as anything in T.aq_get_mission_offers())
		offers += list(C.ui_entry())
	var/list/active = list()
	for(var/datum/aq_contract/mission/M in GLOB.aq_ship_contracts)
		if(M.station == T)
			active += list(M.ui_entry())
	.["aq_missions"] = list(
		"available" = T.aq_gives_missions(),
		"offers" = offers,
		"active" = active,
		"max_active" = MISSION_MAX_ACTIVE,
		"active_count" = aq_active_contract_count(TRUE),
	)

/// Kafel w zasięgu min_range–max_range skoków od origin; empty_only: tylko pusty kafel bez celu i bez flot
/proc/aq_mission_pick_hex(datum/hex/origin, min_range, max_range, empty_only = FALSE)
	if(!GLOB.hexmap?.built || !origin)
		return null
	var/list/field = hex_mission_distance_field(list(origin), max_range)
	var/list/candidates = list()
	for(var/datum/hex/H as anything in field)
		if(field[H] < min_range)
			continue
		if(GLOB.hexmap.blocks(H) || GLOB.hexmap.is_edge(H) || H.system?.hidden)
			continue
		if(empty_only && H.system && (!istype(H.system, /datum/star_system/random/hex_empty) || H.system.objective_sector || length(H.system.fleets)))
			continue
		candidates += H
	return length(candidates) ? pick(candidates) : null

/proc/aq_hex_label(datum/hex/H)
	return "[H.display_name()] ([hex_sector_name(H.sector)])"

/// Cele misji na mapie nawigacji, obok celów trybu
/obj/machinery/computer/ship/navigation/hex_build_ui_data()
	. = ..()
	var/list/hexes = .["objective_hexes"]
	if(!islist(hexes))
		return
	for(var/datum/aq_contract/mission/M in GLOB.aq_ship_contracts)
		if(!M.is_active())
			continue
		var/datum/hex/H = M.target_hex()
		if(H)
			hexes |= H.id

// ---------------------------------------------------------------- nagroda za okręty

/datum/aq_contract/mission/kill_ships
	name = "Nagroda za okręty"
	reward_items = list(/obj/structure/closet/crate/nsv_mission_rewards = "skrzynia amunicji")
	var/kills = 0

/datum/aq_contract/mission/kill_ships/setup()
	amount = rand(2, 6)
	reward = 2500 + 750 * amount
	reputation = 5 + 2 * amount
	desc = "Nasze linie zaopatrzenia mocno ostatnio oberwały. Zniszczcie okręty Syndykatu albo piratów (liczba: [amount]) w dowolnym układzie. Liczą się okręty zestrzelone przez wasz okręt albo wasze myśliwce; wrogie myśliwce się nie liczą."

/datum/aq_contract/mission/kill_ships/progress_text()
	return "zniszczono [kills]/[amount]"

/datum/aq_contract/mission/kill_ships/check_progress()
	if(kills >= amount)
		complete()

/// Zniszczony okręt AI: czy liczy się do nagrody (wróg NT, nie myśliwiec, w układzie okrętu gracza, ostatni strzał od graczy)
/datum/aq_contract/mission/kill_ships/proc/report_kill(obj/structure/overmap/OM)
	if(!is_active() || OM.mass < MASS_SMALL || OM.mass >= MASS_IMMOBILE || !OM.last_hit_by_players)
		return
	if(!hex_factions_hostile("nanotrasen", OM.faction))
		return
	var/obj/structure/overmap/player = ship()
	if(!player || !OM.current_system || OM.current_system != player.current_system)
		return
	kills++

/// Okręt zniszczony (wytrzymałość 0, jak w statystykach postaci), a nie tylko usunięty
/obj/structure/overmap/Destroy()
	if(obj_integrity <= 0 && ai_controlled && length(GLOB.aq_ship_contracts))
		for(var/datum/aq_contract/mission/kill_ships/M in GLOB.aq_ship_contracts)
			M.report_kill(src)
	return ..()

// ---------------------------------------------------------------- oczyszczenie kafla

/datum/aq_contract/mission/clear_system
	name = "Oczyszczenie układu"
	reward = 5000
	reputation = 15
	gear_reward = TRUE
	reward_items = list(/obj/structure/closet/crate/nsv_mission_rewards = "skrzynia amunicji")
	var/datum/hex/target
	var/fleet_type
	var/datum/weakref/fleet_ref

/datum/aq_contract/mission/clear_system/setup()
	target = aq_mission_pick_hex(station?.current_system?.hex, 3, 8, TRUE)
	if(!target)
		invalid = TRUE
		return
	fleet_type = pick(/datum/fleet/light_defense, /datum/fleet/pirate/scout)
	var/enemy = ispath(fleet_type, /datum/fleet/pirate) ? "piraci zbierają" : "Syndykat zbiera"
	desc = "Wywiad donosi, że [enemy] siły na kaflu [aq_hex_label(target)]. Lećcie tam i rozbijcie tę flotę; liczy się, jeśli wasz okręt będzie na miejscu. Cel jest zaznaczony na mapie nawigacji."

/datum/aq_contract/mission/clear_system/target_hex()
	return target

/datum/aq_contract/mission/clear_system/accept_error()
	if(!GLOB.hexmap?.built)
		return "Ta misja wymaga mapy sektora."
	if(target.system && length(target.system.fleets))
		return "Na kaflu celu jest już inna flota. Wybierzcie inną misję."
	return null

/datum/aq_contract/mission/clear_system/on_accept(mob/user)
	..()
	var/datum/star_system/S = GLOB.hexmap.system_for(target)
	var/datum/fleet/F = S.spawn_fleet(fleet_type, rand(3, 5))
	if(!F)
		fail("wróg się nie pojawił")
		return
	fleet_ref = WEAKREF(F)

/// Flota rozbita albo wycofana z kafla: wykonane, jeśli okręt gracza jest na miejscu
/datum/aq_contract/mission/clear_system/check_progress()
	var/datum/fleet/F = fleet_ref?.resolve()
	if(F && F.current_system?.hex == target)
		return
	if(ship()?.current_hex() == target)
		complete()
	else
		fail("wroga flota opuściła kafel bez walki z wami")

/datum/aq_contract/mission/clear_system/on_end()
	. = ..()
	dispose_fleet(fleet_ref)

/datum/aq_contract/mission/clear_system/progress_text()
	return "cel: [aq_hex_label(target)]"

// ---------------------------------------------------------------- obrona układu stacji

/datum/aq_contract/mission/waves
	name = "Obrona układu"
	duration = 40 MINUTES
	gear_reward = TRUE
	reward_items = list(/obj/structure/closet/crate/nsv_mission_rewards = "skrzynia amunicji")
	var/waves_done = 0
	var/started = FALSE
	var/next_wave = 0
	var/datum/weakref/wave_ref

/datum/aq_contract/mission/waves/setup()
	amount = rand(2, 4)
	reward = 5000 * amount
	reputation = 10 + 5 * amount
	desc = "Potrzebujemy osłony. Zostańcie przy naszej stacji w układzie [station?.current_system] i odeprzyjcie fale wrogich okrętów (liczba fal: [amount]). Pierwsza nadejdzie 2 minuty po waszym przybyciu; jeśli odlecicie w trakcie obrony, misja przepada."

/datum/aq_contract/mission/waves/target_hex()
	return station?.current_system?.hex

/datum/aq_contract/mission/waves/accept_error()
	return station?.current_system ? null : "Stacja nie ma układu."

/datum/aq_contract/mission/waves/check_progress()
	var/datum/star_system/S = station?.current_system
	if(!S)
		fail("stacja zniknęła")
		return
	var/obj/structure/overmap/player = ship()
	if(player?.current_system != S)
		if(started)
			fail("okręt opuścił układ w trakcie obrony")
		return
	if(!started)
		started = TRUE
		next_wave = world.time + 2 MINUTES
		announce("Wykryto sygnatury napędów FTL zmierzające do układu [S]. Pierwsza fala za 2 minuty.")
		return
	if(wave_ref)
		var/datum/fleet/wave = wave_ref.resolve()
		if(wave && wave.current_system == S)
			return // walka trwa
		wave_ref = null
		waves_done++
		if(waves_done >= amount)
			complete()
			return
		next_wave = world.time + rand(30, 60) SECONDS
		announce("Fala odparta ([waves_done]/[amount]). Kolejna wkrótce.")
		return
	if(world.time >= next_wave)
		spawn_wave(S)

/datum/aq_contract/mission/waves/proc/spawn_wave(datum/star_system/S)
	var/datum/fleet/F = S.spawn_fleet(pick(/datum/fleet/light_defense, /datum/fleet/pirate/scout), FLEET_DIFFICULTY_EASY + waves_done)
	if(!F)
		fail("wróg się nie pojawił")
		return
	wave_ref = WEAKREF(F)
	announce("Nadchodzi fala [waves_done + 1]/[amount]!")

/datum/aq_contract/mission/waves/on_end()
	. = ..()
	dispose_fleet(wave_ref)

/datum/aq_contract/mission/waves/progress_text()
	if(!started)
		return "czeka na okręt w układzie [station?.current_system]"
	return "odparte fale: [waves_done]/[amount]"

// ---------------------------------------------------------------- rozpoznanie trasy

/datum/aq_contract/mission/explore
	name = "Rozpoznanie trasy"
	reward = 5000
	reputation = 10
	var/datum/hex/target

/datum/aq_contract/mission/explore/setup()
	target = aq_mission_pick_hex(station?.current_system?.hex, 5, 9)
	if(!target)
		invalid = TRUE
		return
	desc = "Od dawna próbujemy wytyczyć trasę do kafla [aq_hex_label(target)]. Każdy zwiadowca, którego tam wysyłamy, ginie bez śladu. Jeśli zdołacie tam dolecieć, zapłacimy za dane o waszej trasie. Cel jest zaznaczony na mapie nawigacji."

/datum/aq_contract/mission/explore/target_hex()
	return target

/datum/aq_contract/mission/explore/check_progress()
	if(ship()?.current_hex() == target)
		complete()

/datum/aq_contract/mission/explore/progress_text()
	return "cel: [aq_hex_label(target)]"

// ---------------------------------------------------------------- plombowane skrzynie

/datum/aq_contract/mission/cargo
	name = "Ładunek plombowany"
	reward = 4000
	reputation = 10
	/// Skrzynie do przewiezienia (typ -> waga)
	var/list/crate_types = list(/obj/structure/closet/crate/large/freight_objective/aq_sealed = 1)
	var/datum/weakref/target_ref
	/// Pełna stawka, gdy wszystko dotrze nienaruszone
	var/max_reward
	var/max_reputation
	/// Śledzony ładunek: przedmiot -> TRUE nienaruszony, FALSE skrzynia otwarta
	var/list/cargo = list()
	var/delivered_intact = 0
	var/delivered_tampered = 0
	var/lost = 0

/datum/aq_contract/mission/cargo/setup()
	amount = 4
	var/obj/structure/overmap/trader/target = pick_target()
	if(!target)
		invalid = TRUE
		return
	target_ref = WEAKREF(target)
	max_reward = reward
	max_reputation = reputation
	set_desc(target)

/datum/aq_contract/mission/cargo/proc/set_desc(obj/structure/overmap/trader/target)
	desc = "Przewieźcie zaplombowane skrzynie (liczba: [amount]) do stacji [target] w układzie [target.current_system]. Skrzynie i darmowa torpeda transportowa przylecą kapsułą do ładowni; wyślijcie je torpedą z konsoli DRADIS zaopatrzenia. Nie otwierajcie skrzyń: za otwartą płacimy ćwierć stawki, a za zgubioną nic."

/// Inna stacja Nanotrasen w zasięgu (jak stacje misji ładunkowych trybu, hex_mission_stations())
/datum/aq_contract/mission/cargo/proc/pick_target()
	var/list/stations = list()
	for(var/datum/trader/T as anything in SSstar_system.traders)
		var/obj/structure/overmap/trader/S = T.current_location
		if(QDELETED(S) || S == station || T.faction_type != FACTION_ID_NT || !S.current_system)
			continue
		stations += S
	if(!length(stations))
		return null
	return pick(hex_mission_stations(stations, station))

/datum/aq_contract/mission/cargo/proc/target_station()
	return target_ref?.resolve()

/datum/aq_contract/mission/cargo/target_hex()
	var/obj/structure/overmap/trader/target = target_station()
	return target?.current_system?.hex

/datum/aq_contract/mission/cargo/accept_error()
	if(!target_station())
		return "Stacji docelowej już nie ma."
	if(!ship())
		return "Brak okrętu."
	return null

/datum/aq_contract/mission/cargo/on_accept(mob/user)
	..()
	var/obj/structure/overmap/player = ship()
	for(var/i in 1 to amount)
		var/crate_type = pickweight(crate_types)
		var/obj/structure/closet/crate/large/freight_objective/aq_sealed/crate = new crate_type()
		bind_crate(crate)
		player.send_supplypod(crate, station, TRUE)
	player.send_supplypod(/obj/item/ship_weapon/ammunition/torpedo/freight, station)

/// Skrzynia należy do misji, a jej zawartość jest śledzonym ładunkiem
/datum/aq_contract/mission/cargo/proc/bind_crate(obj/structure/closet/crate/large/freight_objective/aq_sealed/crate)
	crate.aq_mission = src
	for(var/atom/movable/item as anything in crate.contents)
		cargo[item] = TRUE
		RegisterSignal(item, COMSIG_PARENT_QDELETING, PROC_REF(cargo_deleted))

/// Skrzynia otwarta albo rozbita: zawartość dalej trzeba dowieźć, ale za mniej
/datum/aq_contract/mission/cargo/proc/mark_tampered(list/items)
	for(var/atom/movable/item as anything in items)
		if(item in cargo)
			cargo[item] = FALSE

/datum/aq_contract/mission/cargo/proc/cargo_deleted(datum/source)
	SIGNAL_HANDLER
	if(!(source in cargo))
		return
	cargo -= source
	lost++

/// Dostawa torpedą do stacji docelowej; zwraca liczbę rozliczonych przedmiotów
/datum/aq_contract/mission/cargo/proc/deliver(list/contents)
	var/list/crates = list()
	. = 0
	for(var/atom/movable/item as anything in contents)
		if(!(item in cargo))
			continue
		if(cargo[item])
			delivered_intact++
		else
			delivered_tampered++
		cargo -= item
		UnregisterSignal(item, COMSIG_PARENT_QDELETING)
		if(istype(item.loc, /obj/structure/closet/crate/large/freight_objective/aq_sealed))
			crates |= item.loc
		qdel(item)
		.++
	QDEL_LIST(crates)

/datum/aq_contract/mission/cargo/check_progress()
	if(length(cargo))
		if(!target_station())
			fail("stacja docelowa zniszczona")
		return
	var/delivered = delivered_intact + delivered_tampered
	if(!delivered)
		fail("ładunek przepadł")
		return
	reward = round(max_reward * (delivered_intact + MISSION_TAMPERED_SHARE * delivered_tampered) / amount)
	reputation = round(max_reputation * delivered / amount)
	complete()

/datum/aq_contract/mission/cargo/progress_text()
	var/text = "dostarczone [delivered_intact + delivered_tampered]/[amount]"
	var/opened = 0
	for(var/item in cargo)
		if(!cargo[item])
			opened++
	if(opened || delivered_tampered)
		text += ", otwarte [opened + delivered_tampered]"
	if(lost)
		text += ", stracone [lost]"
	return text

/datum/aq_contract/mission/cargo/on_end()
	for(var/atom/movable/item as anything in cargo)
		UnregisterSignal(item, COMSIG_PARENT_QDELETING)
	cargo.Cut()

/datum/aq_contract/mission/cargo/high_risk
	name = "Ładunek wysokiego ryzyka"
	reward = 5000
	reputation = 15
	crate_types = list(
		/obj/structure/closet/crate/large/freight_objective/aq_sealed = 1,
		/obj/structure/closet/crate/large/freight_objective/aq_sealed/high_risk = 4,
	)

/datum/aq_contract/mission/cargo/high_risk/setup()
	. = ..()
	amount = 2
	var/obj/structure/overmap/trader/target = target_station()
	if(target)
		set_desc(target)
		desc += " Uwaga: zawartość jest niebezpieczna."

// ---------------------------------------------------------------- uzbrojona głowica

/// Ogłoszenie podrzucone przez agenta Syndykatu: skrzynia z uzbrojoną głowicą, która ma zniszczyć stację docelową.
/// Stacja zlecająca po kolei ostrzega załogę. Dostarczenie: wypłata i zniszczenie stacji docelowej; otwarcie skrzyni
/// albo wyrzucenie jej w kosmos kończy misję bez kary. Głowica, której nikt się nie pozbył, po godzinie wybucha na okręcie.
/datum/aq_contract/mission/cargo/nuke
	name = "Pilna przesyłka"
	reward = 100000
	reputation = 0
	fail_reputation = 0
	duration = 55 MINUTES
	crate_types = list(/obj/structure/closet/crate/large/freight_objective/aq_sealed/nuke = 1)
	var/warnings = 0

/datum/aq_contract/mission/cargo/nuke/setup()
	. = ..()
	amount = 1
	if(!invalid)
		GLOB.aq_mission_nuke_offered = TRUE

/datum/aq_contract/mission/cargo/nuke/set_desc(obj/structure/overmap/trader/target)
	desc = "Przetransportuj 9999\"; DROP CONNECTION ; NEW CONNECTION(\" Hej, potrzebuję, żebyś przewiózł jedną skrzynię z ładunkiem do [target]. Znajdziesz ich w układzie [target.current_system]. NIE otwieraj skrzyni i ignoruj tykanie, to zabytkowy budzik. Musi zostać dostarczona w mniej niż godzinę."

/datum/aq_contract/mission/cargo/nuke/on_accept(mob/user)
	..()
	message_admins("[ADMIN_LOOKUPFLW(user)] przyjął misję z uzbrojoną głowicą od [station]. Za 60 minut wybuchnie na okręcie, jeśli nikt jej nie dostarczy ani nie wyrzuci w kosmos.")
	log_game("[key_name(user)] accepted the armed warhead mission from [station]")
	addtimer(CALLBACK(src, PROC_REF(warn)), 15 MINUTES)

/datum/aq_contract/mission/cargo/nuke/proc/warn()
	if(!is_active())
		return
	var/obj/structure/overmap/player = ship()
	var/obj/structure/overmap/trader/target = target_station()
	var/sender = station ? station.name : "Stacja"
	warnings++
	switch(warnings)
		if(1)
			player?.hail("[player], zauważyliśmy, że przydzielono wam misję dostarczenia skrzyni z ładunkiem do [target]. Nie mamy jednak od nich formularza zamówienia, by wysłać skrzynię. Wstrzymajcie się z dostawą, dopóki nie ustalimy, co się dzieje.", sender)
		if(2)
			player?.hail("Sprawdziliśmy skrzynię, którą mieliście dostarczyć do [target], i odkryliśmy, że ktoś manipulował tym ogłoszeniem o zleceniu. Znaleźliśmy winnego i spróbujemy ustalić, po co chciał, żebyście przewieźli tę skrzynię.", sender)
		if(3)
			player?.hail("Osoba, która manipulowała ogłoszeniem, po krótkiej „rozmowie” przyznała, że jest agentem Syndykatu. Musicie zniszczyć lub pozbyć się tej skrzyni, bo zamierzali sprawić, że zniszczycie [target]. Wyrzućcie ją w kosmos.", sender)
			return
	addtimer(CALLBACK(src, PROC_REF(warn)), 15 MINUTES)

/// Otwarcie skrzyni kończy misję (w NSV: report_tampered_cargo), ale głowica dalej odlicza: stacja każe ją wyrzucić
/datum/aq_contract/mission/cargo/nuke/mark_tampered(list/items)
	. = ..()
	for(var/item in cargo)
		if(!cargo[item])
			fail("skrzynia otwarta")
			ship()?.hail("Otworzyliście skrzynię? W środku jest uzbrojona głowica Syndykatu i dalej odlicza. Wyrzućcie ją w kosmos, zanim wybuchnie na waszym okręcie.", station ? station.name : "Stacja")
			return

/datum/aq_contract/mission/cargo/nuke/check_progress()
	if(length(cargo) || delivered_intact || delivered_tampered)
		return ..()
	// Głowica zniknęła, zanim dotarła do celu: załoga się jej pozbyła
	fail("skrzynia zniszczona")
	ship()?.hail("Skrzynia zniknęła z waszego manifestu. Jeśli to wy się jej pozbyliście: dziękujemy.", station ? station.name : "Stacja")

/datum/aq_contract/mission/cargo/nuke/complete()
	var/obj/structure/overmap/trader/target = target_station()
	. = ..()
	if(!target)
		return
	ship()?.hail("Dzięki, ale chyba nie zamawialiśmy tej skrzyni? Chwila, czemu słyszę tykanie...", target.name)
	message_admins("Głowica z misji handlarza dotarła do [target]: stacja zostanie zniszczona za 10 sekund.")
	log_game("The armed warhead mission destroyed the trader station [target]")
	QDEL_IN(target, 10 SECONDS)

/// Przesyłka do stacji docelowej misji ładunkowej; reszta idzie do zleceń działów i celów trybu (..())
/obj/structure/overmap/trader/check_objectives(datum/freight_delivery_receipt/receipt)
	if(!receipt?.shipment)
		return ..()
	var/list/contents = receipt.shipment.GetAllContents()
	var/delivered = 0
	for(var/datum/aq_contract/mission/cargo/M in GLOB.aq_ship_contracts)
		if(M.is_active() && M.target_station() == src)
			delivered += M.deliver(contents)
	if(!delivered)
		return ..()
	received_cargo += receipt
	if(receipt.vessel)
		SEND_SOUND(receipt.courier, 'nsv13/sound/effects/ship/freespace2/computer/textdraw.wav')
		receipt.vessel.hail("Odebraliśmy ładunek misji. Dziękujemy.", src)
		addtimer(CALLBACK(src, PROC_REF(return_approved_form), receipt), speed_cargo_return)
	return TRUE

// ---------------------------------------------------------------- skrzynie i głowica

/// Zaplombowana skrzynia misji (wygląd i ostrzeżenie przy łomie jak skrzynie celów trybu, objective_cargo.dm)
/obj/structure/closet/crate/large/freight_objective/aq_sealed
	name = "zaplombowana skrzynia"
	var/datum/aq_contract/mission/cargo/aq_mission
	var/list/possible_contents = list(
		/obj/machinery/portable_atmospherics/canister/oxygen,
		/obj/machinery/portable_atmospherics/canister/air,
		/obj/machinery/portable_atmospherics/canister/water_vapor,
		/obj/structure/reagent_dispensers/beerkeg,
		/obj/machinery/portable_atmospherics/scrubber,
		/obj/machinery/portable_atmospherics/pump,
	)

/// Rodzic rejestruje budzenie okazów w New(), już po Initialize(), więc podmiana musi przyjść po nim.
/// W tych skrzyniach nie ma zwierząt, a otwarcie ma obniżyć zapłatę.
/obj/structure/closet/crate/large/freight_objective/aq_sealed/New()
	. = ..()
	RegisterSignal(src, COMSIG_FREIGHT_TAMPERED, PROC_REF(aq_tampered), override = TRUE)

/obj/structure/closet/crate/large/freight_objective/aq_sealed/PopulateContents()
	var/content_type = pick(possible_contents)
	new content_type(src)

/obj/structure/closet/crate/large/freight_objective/aq_sealed/proc/aq_tampered()
	SIGNAL_HANDLER
	if(aq_mission)
		INVOKE_ASYNC(aq_mission, TYPE_PROC_REF(/datum/aq_contract/mission/cargo, mark_tampered), contents.Copy())

/// Rozbita skrzynia (ostrzał, wybuch) też zrywa plombę
/obj/structure/closet/crate/large/freight_objective/aq_sealed/Destroy()
	aq_mission?.mark_tampered(contents.Copy())
	aq_mission = null
	..() // Destroy() skrzyni celu trybu nie zwraca wskazówki
	return QDEL_HINT_QUEUE

/obj/structure/closet/crate/large/freight_objective/aq_sealed/examine(mob/user)
	. = ..()
	var/obj/structure/overmap/trader/target = aq_mission?.target_station()
	if(target)
		. += "<span class='warning'>Ładunek misji dla stacji [target] w układzie [target.current_system]. Otwarcie skrzyni obniży zapłatę do ćwierci stawki.</span>"

/obj/structure/closet/crate/large/freight_objective/aq_sealed/high_risk
	possible_contents = list(
		/obj/structure/alien/egg/grown,
		/obj/machinery/portable_atmospherics/canister/toxins,
	)

/obj/structure/closet/crate/large/freight_objective/aq_sealed/nuke
	possible_contents = list(/obj/machinery/nuclearbomb/aq_mission_cargo)

/obj/structure/closet/crate/large/freight_objective/aq_sealed/nuke/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/radioactive, 1, RAD_LIGHT_INSULATION, 1)

/// Wyrzucona w kosmos (każdą drogą: przeniesienie, pchnięcie, rzut, dryf) znika razem z głowicą (jak w NSV)
/obj/structure/closet/crate/large/freight_objective/aq_sealed/nuke/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	if(isspaceturf(loc) && !QDELETED(src))
		for(var/atom/movable/inside as anything in contents)
			qdel(inside)
		qdel(src)

/// Uzbrojona głowica z odliczaniem (fake_cargo z NSV). Zamiast detonacji kończącej rundę robi duży wybuch tam, gdzie jest.
/obj/machinery/nuclearbomb/aq_mission_cargo
	proper_bomb = FALSE

/obj/machinery/nuclearbomb/aq_mission_cargo/Initialize(mapload)
	. = ..()
	timer_set = 3600
	safety = FALSE
	timing = TRUE
	detonation_timer = world.time + (timer_set * 10)
	countdown.start()
	update_icon()

/obj/machinery/nuclearbomb/aq_mission_cargo/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	if(isspaceturf(loc) && !QDELETED(src))
		qdel(src)

/obj/machinery/nuclearbomb/aq_mission_cargo/explode()
	if(exploding)
		return
	exploding = TRUE
	timing = FALSE
	var/turf/T = get_turf(src)
	if(T)
		message_admins("Głowica z misji handlarza wybuchła w [ADMIN_VERBOSEJMP(T)].")
		log_game("The armed warhead from a trader mission exploded at [AREACOORD(T)]")
		explosion(T, 3, 7, 14, 20)
	qdel(src)

/// Bez zmiany poziomu alarmu przy usuwaniu (set_safety() wraca do previous_level tylko, gdy odlicza)
/obj/machinery/nuclearbomb/aq_mission_cargo/Destroy()
	timing = FALSE
	return ..()

#undef MISSION_OFFERS_PER_STATION
#undef MISSION_MAX_ACTIVE
#undef MISSION_FAIL_REPUTATION
#undef MISSION_INFLUENCE
#undef MISSION_TAMPERED_SHARE
#undef MISSION_GEAR_MAX_PRICE
