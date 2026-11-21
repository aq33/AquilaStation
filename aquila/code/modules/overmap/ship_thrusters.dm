// AQUILA - silniki okrętowe (rework systemów okrętu, etap A1).
// Duże dysze na rufie to maszyny: biorą prąd z APC obszaru i mieszankę paliwową z podgrzewaczy stojących tuż
// za nimi (zwykle wbudowanych w ścianę rufy, jak dekoracyjne podgrzewacze). Podgrzewacze są podłączone rurą
// paliwową do atmosu, więc o paliwo dba atmosferyka.
// Mieszanka: paliwo (ship_thruster_fuels) i utleniacz (ship_thruster_oxidizers). Czysta plazma daje pełny ciąg,
// utleniacz w proporcji SHIP_THRUSTER_IDEAL_RATIO do paliwa dokłada premię, lepsze paliwa jeszcze więcej, do
// SHIP_THRUSTER_MAX_THRUST. Dysza spala całą mieszankę naraz: nadmiar utleniacza i gazy obojętne uciekają z
// wylotem, więc nic nie zapycha podgrzewaczy.
// Ciąg statku to jego dotychczasowy ciąg razy (suma ciągu działających dysz razy jakość mieszanki) / (ciąg
// wszystkich dysz, jakie statek miał). Statek bez dysz okrętowych (SI, starsze mapy) lata bez zmian.
// Zniszczona dysza zostaje jako wrak do naprawy: najpierw płyty plastali, potem spawarka.

/// Najmniejszy ciąg statku z dyszami okrętowymi, gdy żadna nie działa (manewrowanie awaryjne)
#define SHIP_THRUSTER_MIN_THRUST 0.1
/// Ile plastali trzeba na załatanie zniszczonej dyszy
#define SHIP_THRUSTER_REPAIR_SHEETS 5
/// Na ile kafli za tylną krawędzią dyszy szukamy podgrzewaczy (ściana i kafel za nią)
#define SHIP_THRUSTER_HEATER_REACH 2
/// Na ile kafli za tylną krawędzią dyszy szukamy zasilanego obszaru statku (dysza stoi w próżni, bez APC)
#define SHIP_THRUSTER_POWER_REACH 4
/// Zapasowo: w jakim promieniu od dyszy szukamy zasilanego obszaru (dysze na wysięgnikach kadłuba)
#define SHIP_THRUSTER_POWER_RADIUS 10
/// Jak często szukamy od nowa, gdy w pobliżu nie było zasilanego obszaru
#define SHIP_THRUSTER_POWER_SEARCH_COOLDOWN (30 SECONDS)
/// Największy ciąg statku z najlepszą mieszanką (względem ciągu sprzed reworku)
#define SHIP_THRUSTER_MAX_THRUST 1.5
/// Ile moli utleniacza (w odpowiedniku tlenu) na mol paliwa daje pełną premię
#define SHIP_THRUSTER_IDEAL_RATIO 2
/// Premia do ciągu przy idealnej ilości utleniacza
#define SHIP_THRUSTER_OXIDIZER_BONUS 0.3

/// Paliwa dysz okrętowych: gaz = jakość (plazma = 1)
GLOBAL_LIST_INIT(ship_thruster_fuels, list(
	GAS_PLASMA = 1,
	GAS_TRITIUM = 1.15,
	GAS_CONSTRICTED_PLASMA = 1.15
))
/// Utleniacze: gaz = ile moli tlenu zastępuje jeden mol
GLOBAL_LIST_INIT(ship_thruster_oxidizers, list(
	GAS_O2 = 1,
	GAS_NITROUS = 2
))

/obj/structure/overmap
	/// Dysze okrętowe zgłoszone na tym statku
	var/list/ship_thrusters
	/// Ciąg dysz okrętowych, które teraz mogą odpalić
	var/engine_thrust_active = 0
	/// Największy ciąg dysz okrętowych, jaki statek miał. Zniszczona dysza go nie obniża.
	var/engine_thrust_design = 0
	/// Łączny czas ciągu (s) liczony w fizyce; dysze spalają paliwo za czas od swojego ostatniego ticku
	var/aq_thrust_seconds = 0
	/// Ile dysz działało przy ostatnim przeliczeniu ciągu (null przed pierwszym), do ostrzeżeń dla pilota
	var/engine_working_seen
	/// Najwcześniejszy czas kolejnego ostrzeżenia o silnikach
	var/engine_status_next_alert = 0

/obj/structure/overmap/Destroy()
	for(var/obj/machinery/ship_thruster/thruster as anything in ship_thrusters)
		thruster.linked_ship = null
	ship_thrusters = null
	return ..()

/// Mnożnik ciągu od dysz okrętowych: 1 dla statków bez nich, inaczej udział działających dysz
/obj/structure/overmap/proc/get_engine_thrust_mult()
	if(engine_thrust_design <= 0)
		return 1
	return clamp(engine_thrust_active / engine_thrust_design, SHIP_THRUSTER_MIN_THRUST, SHIP_THRUSTER_MAX_THRUST)

/// Czy statek właśnie używa ciągu (lot, hamowanie, manewr na boki)
/obj/structure/overmap/proc/is_thrusting()
	return last_thrust_forward != 0 || last_thrust_right != 0

/obj/structure/overmap/proc/recalculate_engine_thrust()
	var/total = 0
	var/active = 0
	// AQUILA - limit napędu z podziału mocy (ship_power.dm)
	var/power_limit = ship_power ? ship_power.limits[SHIP_POWER_ENGINES] : 1
	for(var/obj/machinery/ship_thruster/thruster as anything in ship_thrusters)
		total += thruster.thrust_power
		if(thruster.can_fire)
			active += thruster.thrust_power * thruster.fuel_quality * power_limit
	engine_thrust_design = max(engine_thrust_design, total)
	engine_thrust_active = active
	// Pilot dowiaduje się od razu, gdy dysza gaśnie albo wraca do pracy
	var/working = 0
	for(var/obj/machinery/ship_thruster/thruster as anything in ship_thrusters)
		if(thruster.can_fire)
			working++
	if(isnull(engine_working_seen))
		engine_working_seen = working
	else if(working != engine_working_seen && pilot)
		engine_status_flush()

/// Wysyła pilotowi bieżący stan silników, jeśli zmienił się od ostatniego komunikatu (najwyżej co 10 s). W trakcie przerwy
/// odkłada sprawdzenie na jej koniec: dysza na granicy paliwa potrafi gasnąć i wracać co tick, a ostatnia zmiana nie przepada
/obj/structure/overmap/proc/engine_status_flush()
	var/working = 0
	for(var/obj/machinery/ship_thruster/thruster as anything in ship_thrusters)
		if(thruster.can_fire)
			working++
	if(working == engine_working_seen || !pilot)
		return
	if(world.time < engine_status_next_alert)
		addtimer(CALLBACK(src, PROC_REF(engine_status_flush)), engine_status_next_alert - world.time, TIMER_UNIQUE | TIMER_NO_HASH_WAIT)
		return
	engine_status_next_alert = world.time + 10 SECONDS
	to_chat(pilot, "<span class='[working < engine_working_seen ? "warning" : "notice"]'>[engine_status_text()]</span>")
	engine_working_seen = working

/// Stan silników dla pilota: ile dysz działa i jaki jest ciąg względem pełnego; null dla statku bez dysz okrętowych
/obj/structure/overmap/proc/engine_status_text()
	if(!length(ship_thrusters))
		return null
	var/working = 0
	for(var/obj/machinery/ship_thruster/thruster as anything in ship_thrusters)
		if(thruster.can_fire)
			working++
	return "Silniki: działa [working] z [length(ship_thrusters)] dysz, ciąg [round(get_engine_thrust_mult() * 100)]%."

/obj/machinery/ship_thruster
	name = "dysza okrętowa"
	desc = "Wielka dysza napędowa okrętu. Spala mieszankę paliwową z podgrzewaczy za nią i potrzebuje prądu do zapłonu."
	icon = 'icons/obj/3x3.dmi'
	icon_state = "huge_engine"
	dir = WEST
	density = TRUE
	opacity = TRUE
	anchored = TRUE
	bound_width = 96
	bound_height = 96
	appearance_flags = LONG_GLIDE
	max_integrity = 600
	integrity_failure = 200
	armor = list("melee" = 50, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 20, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 70, "stamina" = 0, "bleed" = 0)
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	use_power = IDLE_POWER_USE
	idle_power_usage = 200
	active_power_usage = 15000
	/// Udział w ciągu statku
	var/thrust_power = 3
	/// Ile moli paliwa (bez utleniacza) dysza spala na sekundę ciągu
	var/fuel_per_second = 0.15
	/// Statek, któremu ta dysza daje ciąg
	var/obj/structure/overmap/linked_ship
	/// Czy dysza może teraz odpalić (sprawna, zasilona, podgrzewacze mają paliwo)
	var/can_fire = FALSE
	/// Jakość mieszanki w podgrzewaczach: mnożnik ciągu tej dyszy
	var/fuel_quality = 0
	/// Czy zniszczona dysza jest już załatana płytami i czeka na spawanie
	var/plated = FALSE
	/// aq_thrust_seconds statku przy ostatnim ticku tej dyszy
	var/thrust_seen = 0
	/// Obszar, z którego dysza ostatnio brała prąd (szukanie w promieniu jest kosztowne)
	var/area/power_area_cache
	var/next_power_search = 0

/obj/machinery/ship_thruster/large
	icon = 'icons/obj/2x2.dmi'
	icon_state = "large_engine"
	bound_width = 64
	bound_height = 64
	max_integrity = 400
	integrity_failure = 130
	active_power_usage = 10000
	thrust_power = 2
	fuel_per_second = 0.1

/obj/machinery/ship_thruster/Destroy()
	unlink_ship()
	return ..()

/obj/machinery/ship_thruster/proc/link_to_ship(obj/structure/overmap/ship)
	if(linked_ship == ship)
		return
	unlink_ship()
	if(!ship)
		return
	linked_ship = ship
	// Licznik ciągu statku liczymy od chwili podłączenia, a nie od początku rundy
	thrust_seen = ship.aq_thrust_seconds
	LAZYOR(ship.ship_thrusters, src)
	ship.recalculate_engine_thrust()

/obj/machinery/ship_thruster/proc/unlink_ship()
	if(!linked_ship)
		return
	var/obj/structure/overmap/ship = linked_ship
	linked_ship = null
	LAZYREMOVE(ship.ship_thrusters, src)
	ship.recalculate_engine_thrust()

/// Rząd kafli tuż za tylną krawędzią dyszy, depth kafli w głąb
/obj/machinery/ship_thruster/proc/get_rear_turfs(depth)
	var/turf/origin = get_turf(src)
	if(!origin)
		return list()
	var/width = bound_width / world.icon_size
	var/height = bound_height / world.icon_size
	switch(turn(dir, 180))
		if(EAST)
			return block(locate(origin.x + width - 1 + depth, origin.y, origin.z), locate(origin.x + width - 1 + depth, origin.y + height - 1, origin.z))
		if(WEST)
			return block(locate(origin.x - depth, origin.y, origin.z), locate(origin.x - depth, origin.y + height - 1, origin.z))
		if(NORTH)
			return block(locate(origin.x, origin.y + height - 1 + depth, origin.z), locate(origin.x + width - 1, origin.y + height - 1 + depth, origin.z))
		if(SOUTH)
			return block(locate(origin.x, origin.y - depth, origin.z), locate(origin.x + width - 1, origin.y - depth, origin.z))
	return list()

/// Podgrzewacze za tylną krawędzią dyszy (do SHIP_THRUSTER_HEATER_REACH kafli w głąb), gotowe do pracy
/obj/machinery/ship_thruster/proc/get_heaters()
	. = list()
	for(var/depth in 1 to SHIP_THRUSTER_HEATER_REACH)
		for(var/turf/T as anything in get_rear_turfs(depth))
			for(var/obj/machinery/atmospherics/components/unary/shuttle/heater/heater in T)
				if(heater.anchored && !heater.panel_open)
					. += heater

/// Dysza stoi w próżni za kadłubem, gdzie obszar kosmosu nigdy nie ma prądu. Prąd bierze z pierwszego zasilanego
/// obszaru statku za swoją tylną krawędzią (maszynownia, technika), do SHIP_THRUSTER_POWER_REACH kafli w głąb.
/obj/machinery/ship_thruster/proc/get_power_area(chan = power_channel)
	var/area/own = get_area(src)
	if(own && !istype(own, /area/space) && own.powered(chan))
		return own
	for(var/depth in 1 to SHIP_THRUSTER_POWER_REACH)
		for(var/turf/T as anything in get_rear_turfs(depth))
			var/area/A = T.loc
			if(istype(A, /area/space))
				continue
			if(A.powered(chan))
				return A
	// Dysze na wysięgnikach (Atlantis): najbliższy zasilany obszar statku w promieniu, zapamiętany
	if(power_area_cache?.powered(chan))
		return power_area_cache
	if(world.time < next_power_search)
		return null
	power_area_cache = null
	var/turf/center = get_turf(src)
	if(!center)
		return null
	var/best_dist = INFINITY
	for(var/turf/T as anything in RANGE_TURFS(SHIP_THRUSTER_POWER_RADIUS, center))
		var/area/A = T.loc
		if(istype(A, /area/space) || !A.powered(chan))
			continue
		var/dist = get_dist(center, T)
		if(dist < best_dist)
			best_dist = dist
			power_area_cache = A
	// Odczekiwanie tylko po pustym wyszukiwaniu: utrata zapamiętanego źródła od razu szuka innego
	if(!power_area_cache)
		next_power_search = world.time + SHIP_THRUSTER_POWER_SEARCH_COOLDOWN
	return power_area_cache

/obj/machinery/ship_thruster/powered(chan = -1)
	if(!loc)
		return FALSE
	if(machine_stat & EMPED)
		return FALSE
	if(chan == -1)
		chan = power_channel
	return !!get_power_area(chan)

/obj/machinery/ship_thruster/use_power(amount, chan = -1)
	if(chan == -1)
		chan = power_channel
	var/area/A = get_power_area(chan)
	A?.use_power(amount, chan)

/// Skład mieszanki we wszystkich podgrzewaczach: list(mole razem, mole paliwa, paliwo razy jakość, utleniacz jako tlen)
/obj/machinery/ship_thruster/proc/analyze_mix(list/heaters = get_heaters())
	var/total = 0
	var/fuel = 0
	var/fuel_value = 0
	var/oxidizer = 0
	for(var/obj/machinery/atmospherics/components/unary/shuttle/heater/heater as anything in heaters)
		var/datum/gas_mixture/air_contents = heater.airs[1]
		total += air_contents.total_moles()
		for(var/gas in GLOB.ship_thruster_fuels)
			var/moles = air_contents.get_moles(gas)
			fuel += moles
			fuel_value += moles * GLOB.ship_thruster_fuels[gas]
		for(var/gas in GLOB.ship_thruster_oxidizers)
			oxidizer += air_contents.get_moles(gas) * GLOB.ship_thruster_oxidizers[gas]
	return list(total, fuel, fuel_value, oxidizer)

/// Mnożnik ciągu z mieszanki: średnia jakość paliwa razy premia za utleniacz; 0 bez paliwa
/proc/ship_thruster_mix_quality(fuel, fuel_value, oxidizer)
	if(fuel <= 0)
		return 0
	var/oxidized = min(oxidizer / (fuel * SHIP_THRUSTER_IDEAL_RATIO), 1)
	return min((fuel_value / fuel) * (1 + SHIP_THRUSTER_OXIDIZER_BONUS * oxidized), SHIP_THRUSTER_MAX_THRUST)

/// Paliwo (bez utleniacza) w podgrzewaczach dyszy, w molach
/obj/machinery/ship_thruster/proc/get_fuel(list/heaters = get_heaters())
	var/list/mix = analyze_mix(heaters)
	return mix[2]

/// Spala tyle mieszanki, żeby zużyć podaną ilość paliwa. Mieszanka schodzi w całości (utleniacz i gazy
/// obojętne razem z paliwem), w tej samej proporcji ze wszystkich podgrzewaczy. mix: wynik analyze_mix(heaters)
/obj/machinery/ship_thruster/proc/burn_fuel(amount, list/heaters = get_heaters(), list/mix = analyze_mix(heaters))
	var/fuel = mix[2]
	if(fuel <= 0)
		return
	var/ratio = min(amount / fuel, 1)
	for(var/obj/machinery/atmospherics/components/unary/shuttle/heater/heater as anything in heaters)
		var/datum/gas_mixture/air_contents = heater.airs[1]
		air_contents.remove_ratio(ratio)
		heater.update_parents()

/obj/machinery/ship_thruster/proc/check_can_fire(delta_time, list/heaters = get_heaters(), list/mix = analyze_mix(heaters))
	if(machine_stat & (BROKEN|NOPOWER))
		return FALSE
	if(!anchored || !linked_ship)
		return FALSE
	return mix[2] >= fuel_per_second * delta_time

/obj/machinery/ship_thruster/process(delta_time)
	if(!linked_ship || QDELETED(linked_ship))
		link_to_ship(get_overmap())
	// Obszar kosmosu nie wysyła zmian zasilania: stan prądu z obszaru za dyszą sprawdzamy co tick
	power_change()
	// Jedna analiza mieszanki na tick: wspólna dla sprawdzenia paliwa, jakości i spalania
	var/list/heaters = get_heaters()
	var/list/mix = analyze_mix(heaters)
	var/new_can_fire = check_can_fire(delta_time, heaters, mix)
	var/new_quality = ship_thruster_mix_quality(mix[2], mix[3], mix[4])
	// Ciąg między tickami (krótkie manewry) też kosztuje paliwo: czas ciągu zlicza fizyka (physics.dm)
	var/thrust_time = 0
	if(linked_ship)
		thrust_time = max(linked_ship.aq_thrust_seconds - thrust_seen, 0)
		thrust_seen = linked_ship.aq_thrust_seconds
		if(!thrust_time && linked_ship.is_thrusting())
			thrust_time = delta_time
	// Manewr już wykonany rozliczamy według tego, czy dysza dawała wtedy ciąg: can_fire z poprzedniego ticku to
	// dokładnie to, co fizyka wzięła do engine_thrust_active (zmienia się dopiero niżej). Gotowość na pełny tick
	// (new_can_fire) decyduje tylko o dalszym ciągu.
	var/firing = thrust_time > 0 && linked_ship && anchored && can_fire && mix[2] > 0
	var/datum/ship_power/power = linked_ship?.ship_power
	if(firing)
		// Limit napędu z podziału mocy skaluje ciąg, więc i spalanie (z tym samym minimum co ciąg statku)
		var/power_limit = power ? max(power.limits[SHIP_POWER_ENGINES], SHIP_THRUSTER_MIN_THRUST) : 1
		burn_fuel(fuel_per_second * thrust_time * power_limit, heaters, mix)
	use_power = firing ? ACTIVE_POWER_USE : IDLE_POWER_USE
	active_power_usage = initial(active_power_usage) * (power ? power.limits[SHIP_POWER_ENGINES] : 1)
	power?.record(SHIP_POWER_ENGINES, firing ? active_power_usage : 0, src, initial(active_power_usage))
	if(new_can_fire != can_fire || abs(new_quality - fuel_quality) > 0.01)
		can_fire = new_can_fire
		fuel_quality = new_quality
		linked_ship?.recalculate_engine_thrust()

/obj/machinery/ship_thruster/obj_break(damage_flag)
	. = ..()
	if(machine_stat & BROKEN)
		do_sparks(5, TRUE, src)
		add_atom_colour("#6a6a6a", FIXED_COLOUR_PRIORITY)
		if(can_fire)
			can_fire = FALSE
			linked_ship?.recalculate_engine_thrust()

/// Zniszczona dysza zostaje jako wrak do naprawy, zamiast się rozpadać
/obj/machinery/ship_thruster/obj_destruction(damage_flag)
	obj_integrity = 1
	obj_break(damage_flag)

/obj/machinery/ship_thruster/proc/finish_repair()
	obj_integrity = max_integrity
	plated = FALSE
	set_machine_stat(machine_stat & ~BROKEN)
	remove_atom_colour(FIXED_COLOUR_PRIORITY)
	update_icon()

/obj/machinery/ship_thruster/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/stack/sheet/plasteel) && (machine_stat & BROKEN))
		if(plated)
			to_chat(user, "<span class='warning'>[src] jest już załatana, teraz trzeba ją zespawać.</span>")
			return
		var/obj/item/stack/sheet/plasteel/sheets = I
		if(sheets.get_amount() < SHIP_THRUSTER_REPAIR_SHEETS)
			to_chat(user, "<span class='warning'>Potrzebujesz [SHIP_THRUSTER_REPAIR_SHEETS] arkuszy plastali, żeby załatać [src].</span>")
			return
		to_chat(user, "<span class='notice'>Zaczynasz łatać rozbitą [src]...</span>")
		if(!do_after(user, 5 SECONDS, target = src) || plated || !sheets.use(SHIP_THRUSTER_REPAIR_SHEETS))
			return
		plated = TRUE
		user.visible_message("<span class='notice'>[user] łata rozbitą [src] plastalą.</span>", "<span class='notice'>Łatasz [src]. Teraz trzeba ją zespawać.</span>")
		return
	return ..()

/obj/machinery/ship_thruster/welder_act(mob/living/user, obj/item/I)
	if(user.combat_mode)
		return FALSE
	if((machine_stat & BROKEN) && !plated)
		to_chat(user, "<span class='warning'>[src] jest rozbita. Najpierw załataj ją [SHIP_THRUSTER_REPAIR_SHEETS] arkuszami plastali.</span>")
		return TRUE
	if(obj_integrity >= max_integrity && !(machine_stat & BROKEN))
		to_chat(user, "<span class='notice'>[src] nie wymaga naprawy.</span>")
		return TRUE
	if(!I.tool_start_check(user, amount = 1))
		return TRUE
	to_chat(user, "<span class='notice'>Zaczynasz spawać [src]...</span>")
	if(!I.use_tool(src, user, (machine_stat & BROKEN) ? 10 SECONDS : 5 SECONDS, volume = 50, amount = 1))
		return TRUE
	// Dysza mogła się rozbić w trakcie spawania: bez plastali naprawy nie ma
	if((machine_stat & BROKEN) && !plated)
		to_chat(user, "<span class='warning'>[src] rozbiła się w trakcie spawania. Najpierw załataj ją plastalą.</span>")
		return TRUE
	finish_repair()
	user.visible_message("<span class='notice'>[user] kończy naprawiać [src].</span>", "<span class='notice'>Naprawiasz [src].</span>")
	return TRUE

/obj/machinery/ship_thruster/examine(mob/user)
	. = ..()
	if(machine_stat & BROKEN)
		if(plated)
			. += "<span class='warning'>Dysza jest załatana plastalą. Trzeba ją jeszcze zespawać.</span>"
		else
			. += "<span class='warning'>Dysza jest rozbita. Załataj ją [SHIP_THRUSTER_REPAIR_SHEETS] arkuszami plastali, a potem zespawaj.</span>"
	else if(obj_integrity < max_integrity)
		. += "<span class='notice'>Osłona jest uszkodzona ([round(obj_integrity / max_integrity * 100)]%). Spawarka ją naprawi.</span>"
	if(machine_stat & NOPOWER)
		. += "<span class='warning'>Dysza nie ma prądu.</span>"
	var/list/heaters = get_heaters()
	if(!length(heaters))
		. += "<span class='warning'>Za dyszą nie ma podgrzewacza paliwa.</span>"
	else
		var/list/mix = analyze_mix(heaters)
		var/quality = ship_thruster_mix_quality(mix[2], mix[3], mix[4])
		. += "<span class='notice'>Paliwo w podgrzewaczach: [round(mix[2], 0.1)] mol, jakość mieszanki: [round(quality * 100)]%.</span>"
		if(mix[2] > 0)
			var/ratio = mix[4] / (mix[2] * SHIP_THRUSTER_IDEAL_RATIO)
			if(ratio <= 0)
				. += "<span class='notice'>Bez utleniacza. Tlen albo podtlenek azotu w rurze paliwowej da premię do ciągu.</span>"
			else if(ratio < 0.9)
				. += "<span class='notice'>Za mało utleniacza: mieszanka spala się niecałkowicie.</span>"
			else if(ratio > 1.1)
				. += "<span class='notice'>Za dużo utleniacza: nadmiar ucieka z wylotem.</span>"
			else
				. += "<span class='notice'>Proporcje paliwa i utleniacza są idealne.</span>"

/// Podgrzewacz dyszy okrętowej: ten sam co w promach, zasilany rurą paliwową z atmosu, na start z zapasem plazmy
/obj/machinery/atmospherics/components/unary/shuttle/heater/ship
	name = "podgrzewacz dyszy okrętowej"
	desc = "Podgrzewacz plazmy dla dyszy okrętowej tuż obok. Paliwo dostaje rurą z atmosu."
	circuit = /obj/item/circuitboard/machine/shuttle/heater/ship
	/// Ile moli plazmy jest w podgrzewaczu na starcie rundy (tylko podgrzewacze z mapy, nie zbudowane)
	var/starting_fuel = 200

/obj/machinery/atmospherics/components/unary/shuttle/heater/ship/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	var/datum/gas_mixture/air_contents = airs[1]
	air_contents.set_moles(gas_type, starting_fuel)
	air_contents.set_temperature(T20C)

/obj/item/circuitboard/machine/shuttle/heater/ship
	name = "podgrzewacz dyszy okrętowej (płytka maszyny)"
	build_path = /obj/machinery/atmospherics/components/unary/shuttle/heater/ship

#undef SHIP_THRUSTER_MIN_THRUST
#undef SHIP_THRUSTER_REPAIR_SHEETS
#undef SHIP_THRUSTER_HEATER_REACH
#undef SHIP_THRUSTER_POWER_REACH
#undef SHIP_THRUSTER_POWER_RADIUS
#undef SHIP_THRUSTER_POWER_SEARCH_COOLDOWN
#undef SHIP_THRUSTER_MAX_THRUST
#undef SHIP_THRUSTER_IDEAL_RATIO
#undef SHIP_THRUSTER_OXIDIZER_BONUS
