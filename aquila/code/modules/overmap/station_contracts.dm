// AQUILA - zlecenia działów ze stacji handlowych (rework systemów okrętu, etap E2).
// Każda stacja handlowa ma kilka ofert dla działów. Zaopatrzenie (albo dowództwo) przyjmuje je w oknie handlarza.
// Zlecenia dostawy rozlicza stacja przy odbiorze torpedy transportowej (check_objectives). Pozostałe działają na
// statku: abordaż do odparcia (ochrona), ranni do wyleczenia i zwłoki do ożywienia (medyczny), goście w
// restauracji (serwis). Nagroda: budżet działu, premia dla załogi działu (department_commission.dm) i punkty badań.

#define CONTRACT_OFFERED "oferta"
#define CONTRACT_ACTIVE "w toku"
#define CONTRACT_DONE "wykonane"
#define CONTRACT_FAILED "nieudane"
/// Ile zleceń naraz może mieć okręt
#define CONTRACT_MAX_ACTIVE 3
/// Ile ofert ma stacja
#define CONTRACT_OFFERS_PER_STATION 3
#define CONTRACT_DEADLINE (30 MINUTES)

/// Przyjęte zlecenia głównego okrętu (także wykonane i nieudane, do historii w oknach)
GLOBAL_LIST_EMPTY(aq_ship_contracts)

/datum/aq_contract
	var/name = "zlecenie"
	var/desc = ""
	/// Dział: ACCOUNT_* i nazwa
	var/account = ACCOUNT_CAR
	var/department_name = "Zaopatrzenie"
	var/reward = 1500
	var/research_points = 0
	var/state = CONTRACT_OFFERED
	var/deadline = 0
	/// Stacja, która dała zlecenie
	var/obj/structure/overmap/trader/station
	/// Ile wykonać (sztuk, gości, abordażników...)
	var/amount = 1
	var/static/next_id = 0
	var/id
	/// Dlaczego zlecenie się nie udało
	var/fail_reason

/datum/aq_contract/New(obj/structure/overmap/trader/station)
	. = ..()
	src.station = station
	id = "c[++next_id]"
	setup()

/datum/aq_contract/Destroy(force, ...)
	station = null
	GLOB.aq_ship_contracts -= src
	return ..()

/// Losuje szczegóły (ilość, rodzaj przedmiotu) i ustawia nazwę i opis
/datum/aq_contract/proc/setup()
	return

/datum/aq_contract/proc/accept(mob/user)
	if(state != CONTRACT_OFFERED)
		return FALSE
	state = CONTRACT_ACTIVE
	deadline = world.time + CONTRACT_DEADLINE
	GLOB.aq_ship_contracts += src
	START_PROCESSING(SSprocessing, src)
	on_accept(user)
	return TRUE

/datum/aq_contract/proc/on_accept(mob/user)
	return

/// Powód, dla którego okręt nie może teraz przyjąć zlecenia (albo null)
/datum/aq_contract/proc/accept_error()
	return null

/datum/aq_contract/process(delta_time)
	if(state != CONTRACT_ACTIVE)
		return PROCESS_KILL
	if(world.time > deadline)
		fail("minął termin")
		return PROCESS_KILL
	check_progress()

/// Zlecenia działające na statku sprawdzają tu postęp
/datum/aq_contract/proc/check_progress()
	return

/// Zlecenia dostawy: czy przesyłka je spełnia (bez zabierania przedmiotów)
/datum/aq_contract/proc/check_shipment(list/contents)
	return FALSE

/datum/aq_contract/proc/complete()
	if(state != CONTRACT_ACTIVE)
		return
	state = CONTRACT_DONE
	STOP_PROCESSING(SSprocessing, src)
	var/datum/bank_account/D = SSeconomy.get_dep_account(account)
	D?.adjust_money(reward)
	add_department_commission(account, reward)
	if(research_points)
		SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = research_points))
	announce("Zlecenie wykonane: [name]. Dział [department_name] otrzymuje [reward] kredytów[research_points ? " i [research_points] punktów badań" : ""].")
	on_end()

/datum/aq_contract/proc/fail(reason)
	if(state != CONTRACT_ACTIVE)
		return
	state = CONTRACT_FAILED
	fail_reason = reason
	STOP_PROCESSING(SSprocessing, src)
	announce("Zlecenie nieudane: [name] ([reason]).")
	on_end()

/// Stany do sprawdzania spoza tego pliku (konsola zgłoszeń, testy): define'y stanów są tu #undef
/datum/aq_contract/proc/is_active()
	return state == CONTRACT_ACTIVE

/datum/aq_contract/proc/is_done()
	return state == CONTRACT_DONE

/datum/aq_contract/proc/is_failed()
	return state == CONTRACT_FAILED

/// Sprzątanie po zakończeniu (zamknięcie restauracji itp.)
/datum/aq_contract/proc/on_end()
	return

/datum/aq_contract/proc/announce(message)
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	ship?.relay(null, "<span class='notice'><b>[station ? station.name : "Stacja"]:</b> [message]</span>")

/// Gdzie oddać zlecenie (konsola zgłoszeń)
/datum/aq_contract/proc/where_to_deliver()
	return "na okręcie"

/datum/aq_contract/delivery/where_to_deliver()
	return "torpeda transportowa, DRADIS zaopatrzenia"

/datum/aq_contract/wounded/where_to_deliver()
	return "ambulatorium"

/datum/aq_contract/corpse/where_to_deliver()
	return "ambulatorium"

/datum/aq_contract/customers/where_to_deliver()
	var/datum/venue/venue = get_venue()
	return lowertext(venue.display_name)

/datum/aq_contract/proc/ui_entry()
	return list(
		"id" = id,
		"name" = name,
		"desc" = desc,
		"department" = department_name,
		"reward" = reward,
		"research" = research_points,
		"state" = state,
		"time_left" = state == CONTRACT_ACTIVE ? max(0, round((deadline - world.time) / 600)) : null
	)

// ---------------------------------------------------------------- dostawy

/datum/aq_contract/delivery
	/// Typ przedmiotu (z podtypami, chyba że exact_type)
	var/item_type
	var/exact_type = FALSE
	var/item_name = "przedmioty"

/datum/aq_contract/delivery/setup()
	name = "Dostawa: [amount] × [item_name]"
	desc = "Wyślijcie torpedą transportową [amount] × [item_name]. Zaopatrzenie ładuje torpedę i wysyła ją z konsoli DRADIS zaopatrzenia."

/datum/aq_contract/delivery/proc/item_value(atom/movable/A)
	if(exact_type ? A.type != item_type : !istype(A, item_type))
		return 0
	if(istype(A, /obj/item/stack))
		var/obj/item/stack/S = A
		return S.amount
	return 1

/datum/aq_contract/delivery/check_shipment(list/contents)
	var/total = 0
	for(var/atom/movable/A as anything in contents)
		total += item_value(A)
	return total >= amount

/datum/aq_contract/delivery/food
	account = ACCOUNT_SRV
	department_name = "Serwis"
	item_type = /obj/item/food/grown
	item_name = "plony z hydroponiki"
	reward = 1200

/datum/aq_contract/delivery/food/setup()
	amount = rand(10, 20)
	. = ..()
	desc += " Kolonia głoduje: liczy się każdy plon."

/datum/aq_contract/delivery/trash
	account = ACCOUNT_SRV
	department_name = "Serwis"
	item_type = /obj/item/trash
	item_name = "śmieci"
	reward = 800

/datum/aq_contract/delivery/trash/setup()
	amount = rand(15, 25)
	. = ..()

/datum/aq_contract/delivery/materials
	account = ACCOUNT_CAR
	department_name = "Zaopatrzenie"
	reward = 2000

/datum/aq_contract/delivery/materials/setup()
	var/static/list/options = list(
		/obj/item/stack/sheet/iron = list("arkusze stali", 50, 1200),
		/obj/item/stack/sheet/glass = list("arkusze szkła", 50, 1200),
		/obj/item/stack/sheet/plasteel = list("arkusze plastali", 20, 2200),
		/obj/item/stack/sheet/mineral/silver = list("arkusze srebra", 10, 2000),
		/obj/item/stack/sheet/mineral/gold = list("arkusze złota", 10, 2500),
		/obj/item/stack/sheet/mineral/uranium = list("arkusze uranu", 10, 2500)
	)
	item_type = pick(options)
	var/list/option = options[item_type]
	item_name = option[1]
	amount = option[2]
	reward = option[3]
	. = ..()

/datum/aq_contract/delivery/ammo
	account = ACCOUNT_MUN
	department_name = "Uzbrojenie"
	exact_type = TRUE
	reward = 1500

/datum/aq_contract/delivery/ammo/setup()
	var/static/list/options = list(
		/obj/item/ammo_box/magazine/wt550m9 = "magazynki WT-550",
		/obj/item/ammo_box/magazine/wt550m9/rubber = "magazynki WT-550 z gumowymi kulami",
		/obj/item/ammo_box/magazine/m10mm = "magazynki 10 mm",
		/obj/item/ammo_box/magazine/pistolm9mm = "magazynki 9 mm",
		/obj/item/ammo_box/magazine/m45 = "magazynki .45"
	)
	item_type = pick(options)
	item_name = options[item_type]
	amount = rand(4, 8)
	. = ..()

/datum/aq_contract/delivery/energy
	account = ACCOUNT_ENG
	department_name = "Inżynieria"
	item_type = /obj/item/stock_parts/cell
	item_name = "energia w ogniwach"
	reward = 1800

/datum/aq_contract/delivery/energy/setup()
	amount = rand(4, 8) * 10000
	name = "Energia: [amount / 1000] kJ w ogniwach"
	desc = "Stacji brakuje prądu. Wyślijcie torpedą transportową naładowane ogniwa o łącznym ładunku co najmniej [amount / 1000] kJ."

/datum/aq_contract/delivery/energy/item_value(atom/movable/A)
	var/obj/item/stock_parts/cell/C = A
	return istype(C) ? C.charge : 0

/datum/aq_contract/delivery/artifact
	account = ACCOUNT_SCI
	department_name = "Nauka"
	item_type = /obj/item/xenoartifact
	item_name = "artefakty ksenoarcheologiczne"
	reward = 1500
	research_points = 2500

/datum/aq_contract/delivery/artifact/setup()
	amount = rand(1, 2)
	. = ..()

/datum/aq_contract/delivery/slime
	account = ACCOUNT_SCI
	department_name = "Nauka"
	item_type = /obj/item/slime_extract
	item_name = "ekstrakty śluzowców"
	reward = 1200
	research_points = 1500

/datum/aq_contract/delivery/slime/setup()
	amount = rand(4, 8)
	. = ..()

// ---------------------------------------------------------------- na statku

/// Ochrona: przyjęcie zlecenia oznacza abordaż na nasz statek
/datum/aq_contract/boarding
	name = "Przyjęcie abordażu"
	account = ACCOUNT_SEC
	department_name = "Ochrona"
	reward = 3000
	/// Abordażnicy z tego zlecenia (weakrefy)
	var/list/boarders = list()
	var/spawned = FALSE

/datum/aq_contract/boarding/setup()
	amount = rand(3, 5)
	desc = "Stacja przekazuje nam namierzoną grupę abordażową ([amount] osób). Po przyjęciu zlecenia wejdą na nasz pokład w ciągu dwóch minut. Odeprzyjcie ich."

/datum/aq_contract/boarding/accept_error()
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	for(var/obj/effect/landmark/patrol_node/node in GLOB.landmarks_list)
		if(node.get_overmap() == ship)
			return null
	return "Okręt nie ma punktów patrolowych, abordażnicy nie mają gdzie wejść."

/datum/aq_contract/boarding/on_accept(mob/user)
	addtimer(CALLBACK(src, PROC_REF(launch_boarders)), 2 MINUTES)
	announce("Grupa abordażowa namierzyła nasz okręt. Ochrona: przygotujcie się.")

/datum/aq_contract/boarding/proc/launch_boarders()
	if(state != CONTRACT_ACTIVE)
		return
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	if(!ship)
		fail("brak okrętu")
		return
	var/list/before = list()
	for(var/mob/living/carbon/human/ai_boarder/B in GLOB.mob_living_list)
		before += B
	try
		ship.spawn_knpcs(amount, "pirate")
	catch(var/exception/E)
		fail("abordaż się nie odbył")
		stack_trace("Abordaż ze zlecenia: [E]")
		return
	for(var/mob/living/carbon/human/ai_boarder/B in GLOB.mob_living_list)
		if(!(B in before))
			boarders += WEAKREF(B)
	spawned = TRUE

/datum/aq_contract/boarding/check_progress()
	if(!spawned)
		return
	for(var/datum/weakref/ref as anything in boarders)
		var/mob/living/B = ref.resolve()
		if(B && B.stat != DEAD)
			return
	complete()

/// Medyczny: ranni rozbitkowie do wyleczenia
/datum/aq_contract/wounded
	name = "Ranni rozbitkowie"
	account = ACCOUNT_MED
	department_name = "Medyczny"
	reward = 2000
	var/list/patients = list()

/datum/aq_contract/wounded/setup()
	amount = rand(2, 3)
	desc = "Stacja przysyła kapsułą [amount] rannych rozbitków do ambulatorium. Wyleczcie wszystkich; zlecenie przepada, jeśli któryś umrze."

/datum/aq_contract/wounded/on_accept(mob/user)
	var/obj/structure/closet/supplypod/pod = make_medical_pod()
	if(!pod)
		fail("brak ambulatorium")
		return
	for(var/i in 1 to amount)
		var/mob/living/carbon/human/H = new(pod)
		H.real_name = "rozbitek [i]"
		H.name = H.real_name
		// Najwyżej 70 obrażeń: ciężko ranny, ale nie w stanie krytycznym, zanim dotrze do ambulatorium
		H.adjustBruteLoss(rand(30, 50))
		H.adjustFireLoss(rand(10, 20))
		patients += WEAKREF(H)
	launch_medical_pod(pod)

/// Kapsuła czeka w strefie przeładunkowej CentComu, aż włożymy do niej pacjentów (jak w spawn_knpcs)
/datum/aq_contract/proc/make_medical_pod()
	medical_drop = find_medbay_turf()
	if(!medical_drop)
		return null
	var/obj/structure/closet/supplypod/pod = new
	pod.forceMove(GLOB.areas_by_type[/area/centcom/supplypod/supplypod_temp_holding])
	return pod

/datum/aq_contract/proc/launch_medical_pod(obj/structure/closet/supplypod/pod)
	new /obj/effect/pod_landingzone(medical_drop, pod)
	announce("Kapsuła medyczna leci do ambulatorium.")

/datum/aq_contract/var/turf/medical_drop

/datum/aq_contract/proc/find_medbay_turf()
	var/obj/structure/overmap/ship = SSstar_system.find_main_overmap()
	if(!ship)
		return null
	var/list/medical_areas = list()
	for(var/area/medical/A in GLOB.sortedAreas)
		if(A.get_overmap() == ship)
			medical_areas += A
	if(!length(medical_areas))
		return null
	return get_safe_random_station_turfs(medical_areas)

/datum/aq_contract/wounded/accept_error()
	return find_medbay_turf() ? null : "Okręt nie ma ambulatorium."

/datum/aq_contract/corpse/accept_error()
	return find_medbay_turf() ? null : "Okręt nie ma ambulatorium."

/datum/aq_contract/wounded/check_progress()
	for(var/datum/weakref/ref as anything in patients)
		var/mob/living/carbon/human/H = ref.resolve()
		if(!H || H.stat == DEAD)
			fail("rozbitek zmarł")
			return
		if(H.health < H.maxHealth * 0.9)
			return
	complete()

/// Medyczny: zwłoki do ożywienia albo autopsji
/datum/aq_contract/corpse
	name = "Zwłoki do zbadania"
	account = ACCOUNT_MED
	department_name = "Medyczny"
	reward = 2500
	var/datum/weakref/body

/datum/aq_contract/corpse/setup()
	desc = "Stacja przysyła ciało członka załogi, który zginął niedawno. Ożywcie go albo zróbcie autopsję i ustalcie przyczynę śmierci."

/datum/aq_contract/corpse/on_accept(mob/user)
	var/obj/structure/closet/supplypod/pod = make_medical_pod()
	if(!pod)
		fail("brak ambulatorium")
		return
	var/mob/living/carbon/human/H = new(pod)
	H.real_name = "zmarły z [station ? station.name : "stacji"]"
	H.name = H.real_name
	// Poniżej progu defibrylatora (MAX_REVIVE_*_DAMAGE): da się ożywić bez operacji, ale lepiej najpierw leczyć
	switch(rand(1, 3))
		if(1)
			H.adjustBruteLoss(120)
		if(2)
			H.adjustFireLoss(120)
		if(3)
			H.adjustToxLoss(120)
	H.death()
	body = WEAKREF(H)
	launch_medical_pod(pod)

/datum/aq_contract/corpse/check_progress()
	var/mob/living/carbon/human/H = body?.resolve()
	if(!H)
		fail("ciało zniknęło")
		return
	// Cecha autopsji z aquila/code/modules/surgery/autopsy.dm (TRAIT_AUTOPSIED, tam #undef)
	if(H.stat != DEAD || HAS_TRAIT(H, "autopsied"))
		complete()

/// Serwis: goście w restauracji albo w barze (system restauracji, aquila/code/modules/restaurant/).
/// Portal lokalu otwiera się tylko na czas tego zlecenia, a miejsca rozstawia sam lokal.
/datum/aq_contract/customers
	name = "Goście ze stacji"
	account = ACCOUNT_SRV
	department_name = "Serwis"
	reward = 1500
	/// Typ lokalu (/datum/venue/restaurant albo /datum/venue/bar)
	var/venue_path = /datum/venue/restaurant
	var/served_at_start = 0

/datum/aq_contract/customers/setup()
	venue_path = pick(/datum/venue/restaurant, /datum/venue/bar)
	var/datum/venue/venue = SSrestaurant.get_venue(venue_path)
	amount = rand(5, 8)
	name = "Goście ze stacji: [lowertext(venue.display_name)]"
	desc = "Stacja wysyła przez portal ([lowertext(venue.display_name)]) [amount] gości. Obsłużcie ich; portal otwiera się tylko na czas zlecenia, a miejsca rozstawiają się same."

/datum/aq_contract/customers/proc/get_venue()
	return SSrestaurant.get_venue(venue_path)

/datum/aq_contract/customers/accept_error()
	var/datum/venue/venue = get_venue()
	if(!venue.restaurant_portal)
		return "Okręt nie ma portalu: [lowertext(venue.display_name)]."
	if(aq_venue_contract(venue))
		return "[venue.display_name] ma już gości z innego zlecenia."
	return null

/datum/aq_contract/customers/on_accept(mob/user)
	var/datum/venue/venue = get_venue()
	if(!venue?.restaurant_portal)
		fail("brak portalu: [lowertext(venue.display_name)]")
		return
	served_at_start = venue.customers_served
	if(!venue.open)
		venue.open(user)

/datum/aq_contract/customers/check_progress()
	var/datum/venue/venue = get_venue()
	if(!venue.open)
		// Portal zniknął albo lokal zamknął się sam
		fail("lokal się zamknął")
		return
	if(venue.customers_served - served_at_start >= amount)
		complete()

/datum/aq_contract/customers/on_end()
	var/datum/venue/venue = get_venue()
	if(venue.open && !aq_venue_contract(venue))
		venue.close()

/// Aktywne zlecenie gości dla tego lokalu
/proc/aq_venue_contract(datum/venue/venue)
	for(var/datum/aq_contract/customers/C in GLOB.aq_ship_contracts)
		if(C.venue_path == venue.type && C.state == CONTRACT_ACTIVE)
			return C
	return null

/// Dane zlecenia dla terminala lokalu (albo null)
/proc/aq_venue_contract_entry(datum/venue/venue)
	var/datum/aq_contract/customers/C = aq_venue_contract(venue)
	if(!C)
		return null
	var/list/entry = C.ui_entry()
	entry["served"] = min(venue.customers_served - C.served_at_start, C.amount)
	entry["amount"] = C.amount
	return entry

// ---------------------------------------------------------------- stacje handlowe

/// Rodzaje zleceń losowane na stacjach
GLOBAL_LIST_INIT(aq_contract_types, list(
	/datum/aq_contract/delivery/food,
	/datum/aq_contract/delivery/trash,
	/datum/aq_contract/delivery/materials,
	/datum/aq_contract/delivery/ammo,
	/datum/aq_contract/delivery/energy,
	/datum/aq_contract/delivery/artifact,
	/datum/aq_contract/delivery/slime,
	/datum/aq_contract/boarding,
	/datum/aq_contract/wounded,
	/datum/aq_contract/corpse,
	/datum/aq_contract/customers
))

/obj/structure/overmap/trader
	/// AQUILA - oferty zleceń dla działów
	var/list/aq_contract_offers

/obj/structure/overmap/trader/proc/aq_get_offers()
	if(isnull(aq_contract_offers))
		aq_contract_offers = list()
	while(length(aq_contract_offers) < CONTRACT_OFFERS_PER_STATION)
		var/contract_type = pick(GLOB.aq_contract_types)
		aq_contract_offers += new contract_type(src)
	return aq_contract_offers

/obj/structure/overmap/trader/proc/aq_active_contracts()
	. = list()
	for(var/datum/aq_contract/C as anything in GLOB.aq_ship_contracts)
		if(C.station == src && C.state == CONTRACT_ACTIVE)
			. += C

/proc/aq_active_contract_count()
	. = 0
	for(var/datum/aq_contract/C as anything in GLOB.aq_ship_contracts)
		if(C.state == CONTRACT_ACTIVE)
			.++

/// Przyjęcie oferty z okna handlarza; zwraca komunikat błędu albo null
/obj/structure/overmap/trader/proc/aq_accept_contract(id, mob/user)
	if(aq_active_contract_count() >= CONTRACT_MAX_ACTIVE)
		return "Okręt ma już [CONTRACT_MAX_ACTIVE] przyjęte zlecenia."
	for(var/datum/aq_contract/C as anything in aq_get_offers())
		if(C.id != id)
			continue
		var/error = C.accept_error()
		if(error)
			return error
		aq_contract_offers -= C
		if(!C.accept(user))
			return "Nie udało się przyjąć zlecenia."
		// on_accept mógł od razu zakończyć zlecenie porażką (np. portal albo ambulatorium zniknęły po sprawdzeniu)
		if(C.is_failed())
			log_game("[key_name(user)] przyjął zlecenie [C.name] od [src], ale nie mogło się zacząć: [C.fail_reason]")
			return "Zlecenie nie mogło się zacząć: [C.fail_reason]."
		log_game("[key_name(user)] przyjął zlecenie [C.name] od [src]")
		return null
	return "Ta oferta już wygasła."

/// Zlecenia dostawy rozliczane przy odbiorze torpedy transportowej
/obj/structure/overmap/trader/check_objectives(datum/freight_delivery_receipt/receipt)
	var/list/contents = receipt?.shipment?.GetAllContents()
	if(length(contents))
		for(var/datum/aq_contract/C as anything in aq_active_contracts())
			if(C.check_shipment(contents))
				C.complete()
				received_cargo += receipt
				approve_shipment(receipt)
				return TRUE
	return ..()

/datum/trader/ui_data(mob/user)
	. = ..()
	var/obj/structure/overmap/trader/T = current_location
	if(!istype(T))
		return
	var/list/offers = list()
	for(var/datum/aq_contract/C as anything in T.aq_get_offers())
		offers += list(C.ui_entry())
	var/list/active = list()
	for(var/datum/aq_contract/C as anything in GLOB.aq_ship_contracts)
		if(C.station == T)
			active += list(C.ui_entry())
	.["aq_contracts"] = list("offers" = offers, "active" = active, "max_active" = CONTRACT_MAX_ACTIVE, "active_count" = aq_active_contract_count())

/datum/trader/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(action != "aq_accept_contract")
		return ..()
	var/obj/structure/overmap/trader/T = current_location
	var/mob/living/user = usr
	if(!istype(T) || !istype(user))
		return TRUE
	if(!T.z || get_dist(user.get_overmap(), T) >= 30)
		to_chat(user, "<span class='warning'>Poza zasięgiem łączności dwukierunkowej.</span>")
		return TRUE
	var/obj/item/card/id/card = user.get_idcard(TRUE)
	var/list/access = card?.GetAccess()
	if(!issilicon(user) && !(ACCESS_CARGO in access) && !(ACCESS_HEADS in access))
		to_chat(user, "<span class='warning'>Zlecenia przyjmuje zaopatrzenie albo dowództwo: potrzebna jest karta z ich dostępem.</span>")
		return TRUE
	var/error = T.aq_accept_contract(params["id"], user)
	if(error)
		to_chat(user, "<span class='warning'>[error]</span>")
	else
		SEND_SOUND(user, 'nsv13/sound/effects/ship/freespace2/computer/textdraw.wav')
	return TRUE

#undef CONTRACT_OFFERED
#undef CONTRACT_ACTIVE
#undef CONTRACT_DONE
#undef CONTRACT_FAILED
#undef CONTRACT_MAX_ACTIVE
#undef CONTRACT_OFFERS_PER_STATION
#undef CONTRACT_DEADLINE
