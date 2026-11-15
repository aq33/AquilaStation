// AQUILA - podział mocy okrętu (rework systemów okrętu, etap A2).
// Inżynier w konsoli monitorowania zasilania ustawia każdemu systemowi limit (0-100% jego największego poboru)
// i priorytet (1 najważniejszy, 5 najmniej). Maszyny na kablach pytają statek o zgodę przed poborem:
// odmowa, gdy system przekroczyłby swój limit albo gdy wolny prąd w sieci trzeba zostawić systemom o wyższym
// priorytecie (ich zapotrzebowanie z poprzedniego cyklu, którego jeszcze nie pobrały). Dysze biorą prąd z APC,
// więc u nich działa tylko limit: skaluje ich ciąg i pobór.

#define SHIP_POWER_SHIELD "shield"
#define SHIP_POWER_ENGINES "engines"
#define SHIP_POWER_FTL "ftl"
#define SHIP_POWER_WEAPONS "weapons"
#define SHIP_POWER_SENSORS "sensors"
#define SHIP_POWER_ARMOUR "armour"
/// Długość cyklu rozliczania mocy (tyle trwa tick SSmachines)
#define SHIP_POWER_CYCLE (2 SECONDS)
/// Powody odmowy podziału mocy
#define SHIP_POWER_REFUSED_LIMIT "limit"
#define SHIP_POWER_REFUSED_RESERVE "rezerwa"
#define SHIP_POWER_REFUSED_SURPLUS "brak prądu"

/// Kolejność systemów w konsoli: id = nazwa
GLOBAL_LIST_INIT(ship_power_systems, list(
	SHIP_POWER_SHIELD = "Tarcza",
	SHIP_POWER_ENGINES = "Napęd",
	SHIP_POWER_FTL = "Napęd FTL",
	SHIP_POWER_WEAPONS = "Broń energetyczna",
	SHIP_POWER_SENSORS = "Sensory",
	SHIP_POWER_ARMOUR = "Naprawa pancerza"
))

/// Gotowe ustawienia: nazwa = list(system = list(limit 0-100, priorytet))
GLOBAL_LIST_INIT(ship_power_presets, list(
	"Równowaga" = list(SHIP_POWER_SHIELD = list(100, 2), SHIP_POWER_ENGINES = list(100, 2), SHIP_POWER_FTL = list(100, 3), SHIP_POWER_WEAPONS = list(100, 3), SHIP_POWER_SENSORS = list(100, 2), SHIP_POWER_ARMOUR = list(100, 4)),
	"Walka" = list(SHIP_POWER_SHIELD = list(100, 1), SHIP_POWER_ENGINES = list(100, 3), SHIP_POWER_FTL = list(20, 5), SHIP_POWER_WEAPONS = list(100, 2), SHIP_POWER_SENSORS = list(100, 2), SHIP_POWER_ARMOUR = list(60, 4)),
	"Ucieczka" = list(SHIP_POWER_SHIELD = list(100, 2), SHIP_POWER_ENGINES = list(100, 1), SHIP_POWER_FTL = list(100, 1), SHIP_POWER_WEAPONS = list(30, 5), SHIP_POWER_SENSORS = list(60, 3), SHIP_POWER_ARMOUR = list(30, 4)),
	"Skok" = list(SHIP_POWER_SHIELD = list(60, 2), SHIP_POWER_ENGINES = list(50, 3), SHIP_POWER_FTL = list(100, 1), SHIP_POWER_WEAPONS = list(20, 5), SHIP_POWER_SENSORS = list(50, 3), SHIP_POWER_ARMOUR = list(30, 4)),
	"Cisza" = list(SHIP_POWER_SHIELD = list(40, 2), SHIP_POWER_ENGINES = list(30, 3), SHIP_POWER_FTL = list(0, 5), SHIP_POWER_WEAPONS = list(0, 5), SHIP_POWER_SENSORS = list(20, 1), SHIP_POWER_ARMOUR = list(50, 4))
))

/datum/ship_power
	/// system = 0..1
	var/list/limits = list()
	/// system = 1..5 (1 najważniejszy)
	var/list/priorities = list()
	/// system = W pobrane w bieżącym cyklu
	var/list/drawn = list()
	/// system = W, o które proszono w bieżącym cyklu
	var/list/requested = list()
	/// system = W pobrane w poprzednim cyklu (do wyświetlania)
	var/list/last_drawn = list()
	/// system = W, o które proszono w poprzednim cyklu (rezerwa dla wyższych priorytetów)
	var/list/last_requested = list()
	/// system = list(maszyna = jej największy pobór w W)
	var/list/machines = list()
	/// Rezerwy liczone osobno dla każdej sieci kabli: system = list(sieć = W). Prośba tarczy w odciętej sieci B nie może
	/// blokować broni w sieci A, bo i tak nie zabierze z niej prądu.
	var/list/net_requested = list()
	var/list/net_drawn = list()
	var/list/last_net_requested = list()
	/// Prośby i zgody w bieżącym cyklu po maszynie: REF(maszyna) = list(system, W, klucz sieci). Maszyna przetworzona
	/// drugi raz w tym samym oknie cyklu (SSmachines z SS_KEEP_TIMING po opóźnieniu) zastępuje swoją prośbę, a nie dokłada.
	var/list/source_asked = list()
	var/list/source_granted = list()
	/// Powód ostatniej odmowy: SHIP_POWER_REFUSED_*
	var/last_refusal
	/// Numer bieżącego cyklu
	var/cycle = 0

/datum/ship_power/New()
	. = ..()
	apply_preset("Równowaga")

/datum/ship_power/proc/apply_preset(name)
	var/list/preset = GLOB.ship_power_presets[name]
	if(!preset)
		return FALSE
	for(var/system in preset)
		var/list/values = preset[system]
		limits[system] = values[1] / 100
		priorities[system] = values[2]
	return TRUE

/datum/ship_power/proc/roll_cycle()
	var/now = round(world.time / SHIP_POWER_CYCLE)
	if(now == cycle)
		return
	cycle = now
	last_drawn = drawn
	last_requested = requested
	last_net_requested = net_requested
	drawn = list()
	requested = list()
	net_requested = list()
	net_drawn = list()
	source_asked = list()
	source_granted = list()
	// Rozebrane maszyny wypadają co cykl, a nie dopiero przy capacity() ich systemu (twarde referencje)
	for(var/system in machines)
		var/list/L = machines[system]
		for(var/obj/machinery/M as anything in L)
			if(QDELETED(M))
				L -= M

/// Klucz sieci w listach rezerw (maszyny bez kabla, np. na APC, liczą się razem)
/datum/ship_power/proc/net_key(net)
	return net ? REF(net) : "brak"

/datum/ship_power/proc/add_net(list/L, system, net, amount)
	var/key = net_key(net)
	LAZYINITLIST(L[system])
	L[system][key] += amount

/datum/ship_power/proc/get_net(list/L, system, net)
	var/list/per_net = L[system]
	return per_net ? (per_net[net_key(net)] || 0) : 0

/// Największy pobór systemu: suma największych poborów jego maszyn (zgłoszonych przy poborze)
/datum/ship_power/proc/capacity(system)
	. = 0
	var/list/L = machines[system]
	for(var/obj/machinery/M as anything in L)
		if(QDELETED(M))
			L -= M
			continue
		. += L[M]

/// Limit systemu w W (null = system bez zgłoszonych maszyn)
/datum/ship_power/proc/cap(system)
	var/total = capacity(system)
	if(total <= 0)
		return null
	return limits[system] * total

/// Ile wolnego prądu w sieci `net` trzeba zostawić systemom o wyższym priorytecie
/datum/ship_power/proc/reserved_above(system, net)
	. = 0
	var/mine = priorities[system]
	for(var/other in GLOB.ship_power_systems)
		if(other == system || priorities[other] >= mine)
			continue
		// rezerwa nie większa niż limit tamtego systemu: prośby ponad limit i tak zostaną odrzucone
		var/wanted = get_net(last_net_requested, other, net)
		var/limit = cap(other)
		if(!isnull(limit))
			wanted = min(wanted, limit)
		var/remaining = wanted - get_net(net_drawn, other, net)
		// Nie więcej niż zostało z limitu całego systemu: pobór w innej sieci też go zużywa
		if(!isnull(limit))
			remaining = min(remaining, limit - drawn[other])
		. += max(0, remaining)

/// Cofa prośbę i zgodę tej samej maszyny z bieżącego cyklu (drugie przetworzenie w jednym oknie)
/datum/ship_power/proc/forget_source(source_key)
	var/list/asked = source_asked[source_key]
	if(asked)
		requested[asked[1]] -= asked[2]
		var/list/per_net = net_requested[asked[1]]
		if(per_net)
			per_net[asked[3]] -= asked[2]
		source_asked -= source_key
	var/list/granted = source_granted[source_key]
	if(granted)
		drawn[granted[1]] -= granted[2]
		var/list/per_net = net_drawn[granted[1]]
		if(per_net)
			per_net[granted[3]] -= granted[2]
		source_granted -= source_key

/// Maszyna pyta o pobór `amount` W z sieci `net`, w której jest `surplus` W wolnych. Zwraca TRUE, jeśli może pobrać;
/// przy odmowie last_refusal mówi dlaczego.
/datum/ship_power/proc/request(system, amount, surplus, obj/machinery/source, max_draw, net)
	roll_cycle()
	last_refusal = null
	var/source_key = source ? REF(source) : null
	if(source)
		LAZYINITLIST(machines[system])
		machines[system][source] = max(max_draw, amount)
		forget_source(source_key)
	if(amount <= 0)
		return TRUE
	requested[system] += amount
	// Prośba większa niż cały wolny prąd sieci i tak nie przejdzie (pobór jest wszystko albo nic): nie rezerwujemy
	// jej dla następnego cyklu, bo zagłodziłaby niższe priorytety
	if(surplus >= amount)
		add_net(net_requested, system, net, amount)
		if(source_key)
			source_asked[source_key] = list(system, amount, net_key(net))
	else if(source_key)
		source_asked[source_key] = list(system, amount, null)
	var/limit = limits[system] * max(capacity(system), amount)
	// Limit 0% odcina system całkowicie (tolerancja 1 W tylko na błędy zaokrągleń przy niezerowym limicie)
	if(limit <= 0 || drawn[system] + amount > limit + 1)
		last_refusal = SHIP_POWER_REFUSED_LIMIT
		return FALSE
	if(surplus < amount)
		last_refusal = SHIP_POWER_REFUSED_SURPLUS
		return FALSE
	if(surplus - reserved_above(system, net) < amount)
		last_refusal = SHIP_POWER_REFUSED_RESERVE
		return FALSE
	drawn[system] += amount
	add_net(net_drawn, system, net, amount)
	if(source_key)
		source_granted[source_key] = list(system, amount, net_key(net))
	return TRUE

/// Zapis poboru, którego nie odcinamy (np. PDSR: odcięcie groziłoby utratą zabezpieczenia reaktora)
/datum/ship_power/proc/record(system, amount, obj/machinery/source, max_draw, net)
	roll_cycle()
	var/source_key = source ? REF(source) : null
	if(source)
		LAZYINITLIST(machines[system])
		machines[system][source] = max(max_draw, amount)
		forget_source(source_key)
	requested[system] += amount
	drawn[system] += amount
	add_net(net_requested, system, net, amount)
	add_net(net_drawn, system, net, amount)
	if(source_key)
		source_asked[source_key] = list(system, amount, net_key(net))
		source_granted[source_key] = list(system, amount, net_key(net))

/obj/structure/overmap
	/// AQUILA - podział mocy okrętu (tworzony przy pierwszym użyciu)
	var/datum/ship_power/ship_power

/obj/structure/overmap/proc/get_ship_power()
	RETURN_TYPE(/datum/ship_power)
	if(!ship_power)
		ship_power = new
	return ship_power

/obj/structure/overmap/Destroy()
	QDEL_NULL(ship_power)
	return ..()

/// Sieć kabla pod maszyną
/obj/machinery/proc/ship_power_net()
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T?.get_cable_node()
	return C?.powernet

/// Wolny prąd w sieci kabla pod maszyną
/obj/machinery/proc/ship_power_surplus()
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T?.get_cable_node()
	return C?.powernet ? C.surplus() : 0

/// Zgoda statku na pobór; maszyny poza statkiem zawsze dostają zgodę
/obj/machinery/proc/ship_power_request(system, amount, max_draw = 0)
	var/obj/structure/overmap/ship = get_overmap()
	if(!istype(ship))
		return TRUE
	return ship.get_ship_power().request(system, amount, ship_power_surplus(), src, max_draw, ship_power_net())

// --- Tarcza: moc obcięta do limitu zamiast gaśnięcia ---

/obj/machinery/shield_generator
	/// Pobór już zatwierdzony przez podział mocy w tym ticku (try_use_power nie pyta drugi raz)
	var/aq_power_pregranted = 0

/obj/machinery/shield_generator/process()
	var/obj/structure/overmap/ship = get_overmap()
	if(!istype(ship))
		return ..()
	var/datum/ship_power/power = ship.get_ship_power()
	var/cap = power.cap(SHIP_POWER_SHIELD)
	var/wanted = power_input
	if(!isnull(cap))
		power_input = min(power_input, cap)
	// Upstream przy każdej odmowie opuszcza tarczę (active = FALSE) do ręcznego włączenia. Odmowa z podziału mocy
	// (limit 0%, rezerwa wyższego priorytetu) to tylko przygaszenie: tarcza słabnie, ale zostaje podniesiona.
	// Prawdziwy brak prądu w sieci obsługuje dalej upstream.
	if(wanted > 0 && powered())
		if(power_input <= 0 || !ship_power_request(SHIP_POWER_SHIELD, power_input, max_power_input))
			if(power_input <= 0 || power.last_refusal != SHIP_POWER_REFUSED_SURPLUS)
				if(shield["integrity"] > 0)
					shield["integrity"] = max(0, shield["integrity"] - 2)
				power_input = wanted
				return FALSE
		else
			aq_power_pregranted = power_input
	. = ..()
	aq_power_pregranted = 0
	power_input = wanted

/obj/machinery/shield_generator/try_use_power(amount)
	if(aq_power_pregranted && amount == aq_power_pregranted)
		aq_power_pregranted = 0
		return ..()
	if(!ship_power_request(SHIP_POWER_SHIELD, amount, max_power_input))
		return FALSE
	return ..()

/obj/machinery/atmospherics/components/trinary/defence_screen_reactor/try_use_power(amount)
	. = ..()
	var/obj/structure/overmap/ship = get_overmap()
	if(. && istype(ship))
		ship.get_ship_power().record(SHIP_POWER_SHIELD, amount, src, max_power_input, ship_power_net())

// --- FTL ---

/obj/machinery/atmospherics/components/binary/drive_pylon/power_drain()
	var/amount = power_draw * (1 + power_failure_counter)
	// Brak kabla albo prądu w sieci obsługuje upstream (ostrzeżenie, częściowy pobór); tu tylko odmowa z podziału mocy
	if(power_draw > 0 && ship_power_surplus() >= amount && !ship_power_request(SHIP_POWER_FTL, amount, 100000))
		power_failure_counter++
		if(power_failure_counter > 3)
			visible_message("<span class='warning'>[src] wydaje metaliczny jęk: inżynieria odcięła mu zasilanie.</span>")
			return FALSE
		return TRUE
	return ..()

// --- Broń energetyczna ---

/obj/machinery/ship_weapon/energy/try_use_power(amount)
	// Bez prądu w obszarze upstream odmawia bez poboru: zgoda zjadałaby limit broni sprawnym działom
	if(powered() && !ship_power_request(SHIP_POWER_WEAPONS, amount, initial(charge_rate) * power_modifier_cap))
		return FALSE
	return ..()

/obj/machinery/ship_weapon/hybrid_rail/try_use_power(amount)
	if(!ship_power_request(SHIP_POWER_WEAPONS, amount, capacitor_max_charge_rate))
		return FALSE
	return ..()

// --- Pancerz ---

/obj/machinery/armour_plating_nanorepair_well/try_use_power(amount)
	if(!ship_power_request(SHIP_POWER_ARMOUR, amount, maximum_power_allocation))
		return FALSE
	return ..()

// --- Konsola monitorowania zasilania ---

/obj/machinery/computer/monitor/proc/can_allocate_ship_power(mob/user)
	if(issilicon(user) || IsAdminGhost(user))
		return TRUE
	var/obj/item/card/id/I = user.get_idcard(TRUE)
	return I && (ACCESS_ENGINE in I.GetAccess())

/obj/machinery/computer/monitor/ui_data(mob/user)
	. = ..()
	var/obj/structure/overmap/ship = get_overmap()
	if(!istype(ship))
		return
	var/datum/ship_power/power = ship.get_ship_power()
	power.roll_cycle()
	var/list/systems = list()
	for(var/system in GLOB.ship_power_systems)
		var/capacity = power.capacity(system)
		systems += list(list(
			"id" = system,
			"name" = GLOB.ship_power_systems[system],
			"limit" = round(power.limits[system] * 100, 1),
			"priority" = power.priorities[system],
			"draw" = display_power(power.last_drawn[system] || 0),
			"demand" = display_power(power.last_requested[system] || 0),
			"max" = capacity > 0 ? display_power(capacity) : null,
			"apc" = system == SHIP_POWER_ENGINES
		))
	.["ship_power"] = list(
		"systems" = systems,
		"can_edit" = can_allocate_ship_power(user)
	)
	var/list/preset_names = list()
	for(var/name in GLOB.ship_power_presets)
		preset_names += name
	.["ship_power"]["presets"] = preset_names

/obj/machinery/computer/monitor/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(!(action in list("ship_power_limit", "ship_power_priority", "ship_power_preset")))
		return
	var/obj/structure/overmap/ship = get_overmap()
	if(!istype(ship) || !can_allocate_ship_power(usr))
		return
	var/datum/ship_power/power = ship.get_ship_power()
	switch(action)
		if("ship_power_limit")
			var/system = params["system"]
			if(!(system in GLOB.ship_power_systems))
				return
			var/value = text2num(params["value"])
			if(!isnum_safe(value))
				return
			power.limits[system] = clamp(round(value), 0, 100) / 100
		if("ship_power_priority")
			var/system = params["system"]
			if(!(system in GLOB.ship_power_systems))
				return
			var/value = text2num(params["value"])
			if(!isnum_safe(value))
				return
			power.priorities[system] = clamp(round(value), 1, 5)
		if("ship_power_preset")
			if(!power.apply_preset(params["preset"]))
				return
	ship.recalculate_engine_thrust()
	log_game("[key_name(usr)] zmienił podział mocy statku [ship] ([action] [params["system"] || params["preset"]] [params["value"]]) w [AREACOORD(src)]")
	return TRUE
