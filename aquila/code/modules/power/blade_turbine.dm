// AQUILA - turbina gazowa z wymiennymi łopatkami i statorem (plan maszynowni, etap E16).
// Port z goonstation code/obj/nuclearreactor/turbine.dm (CC BY-NC-SA 3.0, autorzy: Amylizzle, Sovexe; projekt niekomercyjny).
// Gorący gaz z rury (wejście od zachodu, wyjście na wschód) oddaje 80% ciepła ponad 20°C, energia rozpędza wirnik,
// a obciążenie statora (J na obrót) hamuje go i daje prąd na kabel pod środkiem maszyny. Najwięcej przy 600 obr./min.
// Za szybki wirnik niszczy łopatki, a przy 0 wytrzymałości turbina się rozpada. Łopatki i stator robi autolathe z dowolnego
// twardego materiału; ich właściwości bierze tabela materiałów kuźni amunicji (gęstość, twardość, przewodnictwo).
// Rury do turbiny pękają na wspólnych zasadach z pipe_integrity.dm, turbina tego nie dubluje.

/// Powyżej tej temperatury wejścia (K) turbina ostrzega
#define AQ_TURBINE_OVERTEMP_WARNING 2500
/// Powyżej tej temperatury wejścia (K) zawór awaryjny przepuszcza gaz bez produkcji prądu
#define AQ_TURBINE_OVERTEMP_LIMIT 3000
#define AQ_TURBINE_STATOR_LOAD_MIN 1
#define AQ_TURBINE_STATOR_LOAD_MAX 1e30
#define AQ_TURBINE_FLOW_RATE_MIN 1
/// Nadobroty: powyżej best_rpm × ten mnożnik łopatki się zużywają
#define AQ_TURBINE_OVERSPEED_MULTIPLIER 1.2
/// Ile próbek historii trzyma okno
#define AQ_TURBINE_HISTORY_MAX 50
/// Skala mocy względem Goona (zatwierdzona 26.11). Goon oddaje 2× ciepło odebrane z gazu (ok. 5× TEG z tej samej porcji gazu),
/// ×0,5 daje moc równą odebranemu ciepłu (ok. 2,5× TEG, który potrzebuje jeszcze zimnej pętli).
#define AQ_TURBINE_POWER_SCALE 0.5

/obj/machinery/atmospherics/components/binary/blade_turbine
	name = "turbina gazowa"
	desc = "Duża turbina, która zamienia ciepło gorącego gazu z rury w prąd. Gaz wchodzi od zachodu i wychodzi na wschód, prąd idzie do kabla pod obudową (kabel i rury kładzie się przed budową)."
	icon = 'aquila/icons/obj/machines/turbine/blade_turbine.dmi'
	icon_state = "turbine_main"
	dir = EAST
	initialize_directions = EAST|WEST
	density = TRUE
	anchored = TRUE
	layer = OBJ_LAYER
	plane = GAME_PLANE
	bound_width = 96
	bound_height = 160
	bound_x = -32
	bound_y = -32
	pixel_x = -32
	pixel_y = -32
	use_power = NO_POWER_USE
	pipe_flags = PIPING_ONE_PER_TURF | PIPING_DEFAULT_LAYER_ONLY
	circuit = /obj/item/circuitboard/machine/blade_turbine
	max_integrity = 500
	resistance_flags = FIRE_PROOF | ACID_PROOF
	/// Moc z ostatniego cyklu (W)
	var/lastgen = 0
	/// Obciążenie statora: energia odbierana na jeden obrót (J)
	var/stator_load = 100000
	/// Obroty wirnika (obr./min)
	var/rpm = 0
	/// Bezwładność wirnika, z łopatek: im cięższe, tym wolniej przyspiesza i hamuje
	var/turbine_mass = 1000
	/// Obroty z najwyższą sprawnością
	var/best_rpm = 600
	/// Objętość gazu przerabiana na cykl (l)
	var/flow_rate = 200
	var/flow_rate_max = 1000
	/// Wytrzymałość łopatek: ile uderzeń na nadobrotach zniosą
	var/blade_health = 15
	var/max_blade_health = 15
	/// Rozbita: trzeba zespawać obudowę (i założyć łopatki)
	var/ruined = FALSE
	var/obj/item/turbine_part/blade/current_blade
	var/obj/item/turbine_part/stator/current_stator
	/// Mnożnik mocy ze statora
	var/power_multiplier = 1
	/// Za małe ciepło na obciążenie statora: wirnik staje
	var/stalling = FALSE
	var/overspeed = FALSE
	var/overtemp = FALSE
	var/undertemp = FALSE
	var/last_input_temperature = 0
	var/last_input_pressure = 0
	var/last_output_temperature = 0
	var/last_output_pressure = 0
	/// Próbki do wykresów okna
	var/list/history
	/// Rozpad sypie odłamkami (test jednostkowy to wyłącza, żeby pociski nie leciały w kolejne testy)
	var/tear_shrapnel = TRUE
	COOLDOWN_DECLARE(overheat_alarm_cooldown)
	COOLDOWN_DECLARE(stall_sound_cooldown)

/obj/machinery/atmospherics/components/binary/blade_turbine/Initialize(mapload)
	. = ..()
	history = list()
	// Części fabryczne bez materiałów (liczą się jak żelazo), żeby budowa i rozbiórka nie dawały darmowego żelaza z przetopienia
	if(!current_blade)
		var/obj/item/turbine_part/blade/factory_blade = new(src)
		factory_blade.set_custom_materials(null)
		set_blade(factory_blade)
	if(!current_stator)
		var/obj/item/turbine_part/stator/factory_stator = new(src)
		factory_stator.set_custom_materials(null)
		set_stator(factory_stator)
	update_icon()

/obj/machinery/atmospherics/components/binary/blade_turbine/Destroy()
	QDEL_NULL(current_blade)
	QDEL_NULL(current_stator)
	return ..()

/obj/machinery/atmospherics/components/binary/blade_turbine/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == current_blade)
		current_blade = null
	if(gone == current_stator)
		current_stator = null

// Turbina ma jeden sprite i jedno ustawienie (wejście od zachodu); z ramy zawsze wychodzi tak samo
/obj/machinery/atmospherics/components/binary/blade_turbine/on_construction(obj_color, set_layer)
	setDir(EAST)
	set_init_directions()
	return ..(null, PIPING_LAYER_DEFAULT)

/obj/machinery/atmospherics/components/binary/blade_turbine/set_piping_layer(new_layer)
	piping_layer = PIPING_LAYER_DEFAULT

// Bez końcówek rur: przyłącza leżą pod obudową, a przesunięcie sprite'u rozjechałoby podkłady
/obj/machinery/atmospherics/components/binary/blade_turbine/update_icon()
	plane = GAME_PLANE
	if(ruined || !current_blade || !current_stator)
		icon_state = "ruined"
	else if(rpm >= 1)
		icon_state = "turbine_spin"
	else
		icon_state = "turbine_main"

/obj/machinery/atmospherics/components/binary/blade_turbine/process()
	last_output_temperature = 0
	last_output_pressure = 0
	if(!current_blade || !current_stator)
		ruined = TRUE
	if(ruined)
		rpm = 0

	var/datum/gas_mixture/input = airs[1]
	var/datum/gas_mixture/output = airs[2]
	last_input_pressure = input.return_pressure()
	last_input_temperature = input.return_temperature()
	// Cały gaz z przyłącza wejściowego; jego objętość (flow_rate) wyznacza, ile przechodzi na cykl
	var/datum/gas_mixture/working = input.remove(input.total_moles())

	lastgen = 0
	stalling = FALSE
	var/working_temperature = working ? working.return_temperature() : 0
	overtemp = working_temperature > AQ_TURBINE_OVERTEMP_WARNING
	undertemp = working && working.total_moles() > 0 && working_temperature < T20C
	if(ruined || working_temperature > AQ_TURBINE_OVERTEMP_LIMIT)
		// Zawór awaryjny: gaz idzie dalej bez oddania ciepła
		if(!ruined && COOLDOWN_FINISHED(src, overheat_alarm_cooldown))
			COOLDOWN_START(src, overheat_alarm_cooldown, 10 SECONDS)
			audible_message("<span class='warning'>[src] otwiera awaryjny zawór przegrzania!</span>")
			playsound(src, 'sound/machines/engine_alert2.ogg', 40, FALSE)
		if(working)
			last_output_temperature = working.return_temperature()
			last_output_pressure = working.return_pressure()
			output.merge(working)
	else if(working)
		run_rotor(working)
		last_output_temperature = working.return_temperature()
		last_output_pressure = working.return_pressure()
		output.merge(working)
		var/datum/powernet/net = get_powernet()
		if(net)
			net.newavail += lastgen

	input.set_volume(flow_rate)
	// Nie update_parents(): niepodłączona turbina co cykl zgłaszałaby brak sieci
	for(var/datum/pipeline/parent as anything in parents)
		parent?.update = TRUE
	record_history()
	update_icon()
	if(!ruined && blade_health <= 0)
		if(rpm > best_rpm)
			investigate_log("rozpadła się od zbyt długich nadobrotów.", INVESTIGATE_ENGINES)
			tear_apart()
		else
			// Stojący wirnik nie ma czym rozrzucić odłamków: łopatki po prostu pękają
			visible_message("<span class='warning'>Łopatki [src] pękają!</span>")
			ruined = TRUE
			rpm = 0
			QDEL_NULL(current_blade)
			update_icon()

/// Sieć z kabla pod dowolnym polem obudowy (pola zakrytego turbiną nie da się okablować po budowie)
/obj/machinery/atmospherics/components/binary/blade_turbine/proc/get_powernet()
	for(var/turf/T in locs)
		var/obj/structure/cable/C = T.get_cable_node()
		if(C?.powernet)
			return C.powernet

/// Fizyka wirnika z Goona: ciepło gazu rozpędza wirnik, stator go hamuje i daje prąd.
/obj/machinery/atmospherics/components/binary/blade_turbine/proc/run_rotor(datum/gas_mixture/working)
	var/heat_capacity = max(working.heat_capacity(), 1)
	var/starting_temperature = working.return_temperature()
	var/starting_energy = max(starting_temperature * heat_capacity, 1)
	if(starting_temperature > T20C)
		working.set_temperature(round(max((starting_energy - (starting_energy - heat_capacity * T20C) * 0.8) / heat_capacity, T20C), 0.01))
	var/delta_energy = starting_energy - working.return_temperature() * heat_capacity

	// |a + v| = sqrt(2k/m), liczone dwa razy, żeby wirnik nie skakał między skrajnościami
	var/energy_generated = stator_load * (rpm / 60)
	var/new_rpm = rpm + aq_turbine_rpm_step(delta_energy - energy_generated, turbine_mass)
	var/next_generated = stator_load * (max(new_rpm, 0) / 60)
	var/next_rpm = max(new_rpm, 0) + aq_turbine_rpm_step(delta_energy - next_generated, turbine_mass)
	if(new_rpm < 0 || next_rpm < 0)
		stalling = TRUE
		rpm = 0
		if(COOLDOWN_FINISHED(src, stall_sound_cooldown))
			COOLDOWN_START(src, stall_sound_cooldown, 3 SECONDS)
			playsound(src, 'sound/machines/buzz-two.ogg', 30, FALSE)
	else
		rpm = next_rpm

	lastgen = AQ_TURBINE_POWER_SCALE * power_multiplier * stator_load * (rpm / 30) * aq_sech(0.01 * (rpm - best_rpm))
	overspeed = rpm > best_rpm * AQ_TURBINE_OVERSPEED_MULTIPLIER
	// Przy 3× najlepszych obrotów 45% szans na cykl, niżej liniowo od 15%
	if(overspeed && prob(15 * min(rpm / best_rpm, 3)))
		playsound(src, pick('sound/effects/clang.ogg', 'sound/effects/bang.ogg', 'sound/effects/creak1.ogg'), 40, TRUE)
		Shake(2, 2, 0.5 SECONDS)
		adjust_blade_health(-1)

/// Zmiana obrotów od nadwyżki (albo niedoboru) energii
/proc/aq_turbine_rpm_step(energy, mass)
	if(energy > 0)
		return sqrt(2 * energy / mass)
	return -sqrt(2 * -energy / mass)

/// Secans hiperboliczny (krzywa sprawności turbiny)
/proc/aq_sech(x)
	return 2 / (NUM_E ** x + NUM_E ** -x)

/obj/machinery/atmospherics/components/binary/blade_turbine/proc/record_history()
	if(length(history) >= AQ_TURBINE_HISTORY_MAX)
		history.Cut(1, 2)
	history += list(list(
		"rpm" = rpm,
		"load" = stator_load,
		"power" = lastgen,
		"temperature" = last_input_temperature,
		"pressure" = last_input_pressure,
		"outletTemperature" = last_output_temperature,
		"outletPressure" = last_output_pressure,
	))

/obj/machinery/atmospherics/components/binary/blade_turbine/proc/set_blade(obj/item/turbine_part/blade/new_blade)
	new_blade.forceMove(src)
	current_blade = new_blade
	var/list/props = new_blade.get_turbine_properties()
	turbine_mass = new_blade.blade_mass(props)
	max_blade_health = new_blade.blade_max_health(props)
	blade_health = max_blade_health

/obj/machinery/atmospherics/components/binary/blade_turbine/proc/set_stator(obj/item/turbine_part/stator/new_stator)
	new_stator.forceMove(src)
	current_stator = new_stator
	power_multiplier = new_stator.stator_multiplier(new_stator.get_turbine_properties())

/obj/machinery/atmospherics/components/binary/blade_turbine/proc/adjust_blade_health(amount)
	var/old_health = blade_health
	blade_health = clamp(blade_health + amount, 0, max_blade_health)
	var/spark_line = 0.75 * max_blade_health
	var/smoke_line = 0.5 * max_blade_health
	if(old_health > spark_line && blade_health <= spark_line)
		visible_message("<span class='warning'><b>[src] zaczyna iskrzyć!</b></span>")
		do_sparks(3, TRUE, src)
	if(old_health > smoke_line && blade_health <= smoke_line)
		visible_message("<span class='warning'><b>Z [src] zaczyna lecieć dym!</b></span>")
	if(blade_health <= smoke_line)
		if(!particles)
			particles = new /particles/smoke/steam/aq_pipe_leak
	else if(particles)
		QDEL_NULL(particles)

/obj/machinery/atmospherics/components/binary/blade_turbine/proc/tear_apart()
	playsound(src, 'sound/effects/explosion2.ogg', 60, TRUE)
	visible_message("<span class='userdanger'>[src] rozrywa się od środka!</span>")
	var/turf/T = get_turf(src)
	for(var/i in 1 to (tear_shrapnel ? rand(5, 20) : 0))
		var/obj/item/projectile/bullet/shrapnel/shard = new(T)
		shard.firer = src
		shard.fired_from = src
		shard.fire(rand(0, 359))
	ruined = TRUE
	rpm = 0
	QDEL_NULL(current_blade)
	update_icon()

// Jak u Goona wybuch niszczy części, a nie obudowę; sygnał i zawartość jak w /atom/ex_act
/obj/machinery/atmospherics/components/binary/blade_turbine/ex_act(severity, target)
	if(resistance_flags & INDESTRUCTIBLE)
		return
	contents_explosion(severity, target)
	SEND_SIGNAL(src, COMSIG_ATOM_EX_ACT, severity, target)
	switch(severity)
		if(EXPLODE_LIGHT)
			adjust_blade_health(-rand(1, 3))
		if(EXPLODE_HEAVY)
			if(rpm > 100)
				tear_apart()
			QDEL_NULL(current_blade)
			if(prob(30))
				QDEL_NULL(current_stator)
			ruined = TRUE
		if(EXPLODE_DEVASTATE)
			if(rpm > 100)
				tear_apart()
			QDEL_NULL(current_blade)
			QDEL_NULL(current_stator)
			ruined = TRUE
	update_icon()

/obj/machinery/atmospherics/components/binary/blade_turbine/welder_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!current_blade)
		to_chat(user, "<span class='warning'>Najpierw załóż łopatki turbiny.</span>")
		return
	if(!current_stator)
		to_chat(user, "<span class='warning'>Najpierw załóż stator turbiny.</span>")
		return
	if(!ruined && blade_health >= max_blade_health)
		to_chat(user, "<span class='notice'>[src] nie wymaga naprawy.</span>")
		return
	if(!I.tool_start_check(user, amount = 1))
		return
	user.visible_message("<span class='notice'>[user] spawa uszkodzenia [src].</span>", "<span class='notice'>Zaczynasz spawać uszkodzenia [src]...</span>")
	// Jak u Goona: każde zespawanie naprawia obudowę albo jeden punkt łopatek
	while(ruined || blade_health < max_blade_health)
		if(!I.use_tool(src, user, 1 SECONDS, amount = 1, volume = 50))
			return
		if(ruined)
			ruined = FALSE
			to_chat(user, "<span class='notice'>Naprawiasz obudowę [src].</span>")
			update_icon()
		else
			adjust_blade_health(1)
	to_chat(user, "<span class='notice'>[src] jest w pełni sprawna.</span>")

/obj/machinery/atmospherics/components/binary/blade_turbine/screwdriver_act(mob/living/user, obj/item/I)
	if(..())
		return TRUE
	if(rpm >= 1)
		to_chat(user, "<span class='warning'>Nie otworzysz panelu, gdy wirnik się kręci!</span>")
		return TRUE
	panel_open = !panel_open
	I.play_tool_sound(src)
	to_chat(user, "<span class='notice'>[panel_open ? "Otwierasz" : "Zamykasz"] panel [src].</span>")
	return TRUE

/obj/machinery/atmospherics/components/binary/blade_turbine/crowbar_act(mob/living/user, obj/item/I)
	if(rpm >= 1)
		return FALSE
	return default_deconstruction_crowbar(I)

/obj/machinery/atmospherics/components/binary/blade_turbine/on_deconstruction()
	var/turf/T = drop_location()
	current_blade?.forceMove(T)
	current_stator?.forceMove(T)
	return ..()

/obj/machinery/atmospherics/components/binary/blade_turbine/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/turbine_part))
		if(rpm >= 1)
			to_chat(user, "<span class='warning'>Nie wymienisz części, gdy wirnik się kręci!</span>")
			return TRUE
		user.visible_message("<span class='notice'>[user] zaczyna wymieniać część [src].</span>", "<span class='notice'>Zaczynasz wymieniać część [src]...</span>")
		if(!do_after(user, 4 SECONDS, target = src))
			return TRUE
		replace_part(user, I)
		return TRUE
	return ..()

/obj/machinery/atmospherics/components/binary/blade_turbine/proc/replace_part(mob/living/user, obj/item/turbine_part/part)
	if(rpm >= 1 || QDELETED(part))
		return FALSE
	if(!istype(part, /obj/item/turbine_part/blade) && !istype(part, /obj/item/turbine_part/stator))
		return FALSE
	if(user && !user.temporarilyRemoveItemFromInventory(part))
		return FALSE
	var/obj/item/turbine_part/old_part
	if(istype(part, /obj/item/turbine_part/blade))
		old_part = current_blade
		current_blade = null
		set_blade(part)
		user?.visible_message("<span class='notice'>[user] zakłada [part] na wał [src].</span>", "<span class='notice'>Zakładasz [part] na wał turbiny.</span>")
	else if(istype(part, /obj/item/turbine_part/stator))
		old_part = current_stator
		current_stator = null
		set_stator(part)
		user?.visible_message("<span class='notice'>[user] zakłada [part] w generatorze [src].</span>", "<span class='notice'>Zakładasz [part] w generatorze turbiny.</span>")
	if(old_part)
		old_part.forceMove(drop_location())
		user?.put_in_hands(old_part)
	playsound(src, 'sound/items/ratchet.ogg', 70, TRUE)
	update_icon()
	return TRUE

/obj/machinery/atmospherics/components/binary/blade_turbine/examine(mob/user)
	. = ..()
	if(current_stator)
		. += "Ma stator z materiału: [current_stator.material_name()]."
	else
		. += "<span class='notice'>Brakuje statora.</span>"
	if(!current_blade)
		. += "<span class='notice'>Brakuje łopatek.</span>"
	else
		. += "Ma łopatki z materiału: [current_blade.material_name()]."
		switch(rpm)
			if(0 to 1)
				. += "Łopatki stoją."
			if(1 to 60)
				. += "Łopatki obracają się powoli."
			if(60 to 300)
				. += "Łopatki się kręcą."
			if(300 to 800)
				. += "Łopatki kręcą się szybko."
			else
				. += "<span class='warning'>Łopatki kręcą się bez kontroli!</span>"
	if(ruined)
		. += "<span class='warning'><b>Jest całkowicie rozbita!</b></span>"
	else if(blade_health <= 0.25 * max_blade_health)
		. += "<span class='warning'><b>Jest krytycznie uszkodzona!</b></span>"
	else if(blade_health <= 0.5 * max_blade_health)
		. += "<span class='warning'>Wygląda na mocno uszkodzoną.</span>"
	else if(blade_health <= 0.75 * max_blade_health)
		. += "<span class='notice'>Jest trochę porysowana.</span>"
	else
		. += "Wygląda na sprawną."
	. += "<span class='notice'>Uszkodzenia naprawisz spawarką, a części wymienisz, gdy wirnik stoi.</span>"

// Duża maszyna: sterować można z każdego pola obok obudowy, nie tylko obok środka
/obj/machinery/atmospherics/components/binary/blade_turbine/ui_status(mob/user, datum/ui_state/state)
	. = ..()
	if(. >= UI_INTERACTIVE || state != GLOB.default_state || !isliving(user))
		return
	var/mob/living/L = user
	if(L.stat == CONSCIOUS && !L.incapacitated() && L.Adjacent(src))
		return UI_INTERACTIVE

/obj/machinery/atmospherics/components/binary/blade_turbine/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TurbineControl", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/atmospherics/components/binary/blade_turbine/ui_data(mob/user)
	var/list/data = list()
	data["connected"] = TRUE
	data["rpm"] = rpm
	data["load"] = stator_load
	data["power"] = lastgen
	data["volume"] = flow_rate
	data["volumeMax"] = flow_rate_max
	data["statorLoadMin"] = AQ_TURBINE_STATOR_LOAD_MIN
	data["statorLoadMax"] = AQ_TURBINE_STATOR_LOAD_MAX
	data["flowRateMin"] = AQ_TURBINE_FLOW_RATE_MIN
	data["optimalRPM"] = best_rpm
	data["overspeedRPM"] = best_rpm * AQ_TURBINE_OVERSPEED_MULTIPLIER
	data["minimumTemperature"] = T20C
	data["overtempWarning"] = AQ_TURBINE_OVERTEMP_WARNING
	data["overtempLimit"] = AQ_TURBINE_OVERTEMP_LIMIT
	data["history"] = history
	data["overspeed"] = overspeed
	data["overtemp"] = overtemp
	data["undertemp"] = undertemp
	data["stalling"] = stalling
	data["ruined"] = ruined
	data["inletTemperature"] = last_input_temperature
	data["inletPressure"] = last_input_pressure
	data["outletTemperature"] = last_output_temperature
	data["outletPressure"] = last_output_pressure
	data["blade"] = list(
		"installed" = !!current_blade,
		"healthPercent" = max_blade_health ? clamp(blade_health / max_blade_health * 100, 0, 100) : 0,
		"material" = current_blade?.material_name(),
	)
	data["stator"] = list(
		"installed" = !!current_stator,
		"material" = current_stator?.material_name(),
	)
	return data

/obj/machinery/atmospherics/components/binary/blade_turbine/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/value = text2num("[params["newVal"]]")
	if(isnull(value))
		return
	switch(action)
		if("loadChange")
			stator_load = clamp(value, AQ_TURBINE_STATOR_LOAD_MIN, AQ_TURBINE_STATOR_LOAD_MAX)
			investigate_log("obciążenie statora ustawione na [stator_load] przez [key_name(usr)].", INVESTIGATE_ENGINES)
			return TRUE
		if("volChange")
			flow_rate = clamp(round(value), AQ_TURBINE_FLOW_RATE_MIN, flow_rate_max)
			investigate_log("przepływ ustawiony na [flow_rate] przez [key_name(usr)].", INVESTIGATE_ENGINES)
			return TRUE

// Z ramy maszyny turbina wychodzi dopiero, gdy ma wolne miejsce na całą obudowę (3×5 pól)
/obj/structure/frame/machine/attackby(obj/item/P, mob/living/user, params)
	if(state == 3 && P.tool_behaviour == TOOL_SCREWDRIVER && circuit && ispath(circuit.build_path, /obj/machinery/atmospherics/components/binary/blade_turbine))
		var/turf/blocked = aq_turbine_blocked_turf(loc, src)
		if(blocked)
			to_chat(user, "<span class='warning'>Turbina potrzebuje wolnego miejsca 3×5 pól (rama w dolnym środkowym polu, jedno pole nad dołem). Przeszkadza: [blocked].</span>")
			return
	return ..()

/// Pierwsze zajęte pole pod obudową turbiny z kotwicą na anchor (null = wolne). Pomija ramę, która się w nią zmienia,
/// i istoty: budujący zawsze stoi w obrysie (każde pole przy ramie do niego należy), a z gotowej turbiny po prostu zejdzie.
/proc/aq_turbine_blocked_turf(turf/anchor, atom/ignore)
	if(!anchor)
		return null
	if(anchor.x <= 1 || anchor.y <= 1 || anchor.x >= world.maxx || anchor.y + 3 > world.maxy)
		return anchor
	for(var/turf/T as anything in aq_turbine_footprint(anchor))
		if(T.density || isgroundlessturf(T))
			return T
		for(var/atom/movable/AM in T)
			if(AM != ignore && AM.density && !ismob(AM))
				return AM
	return null

/// Pola obudowy turbiny z kotwicą na anchor: 3 szerokości, od jednego pola pod kotwicą do trzech nad nią
/proc/aq_turbine_footprint(turf/anchor)
	return block(locate(anchor.x - 1, anchor.y - 1, anchor.z), locate(anchor.x + 1, anchor.y + 3, anchor.z))

/obj/item/circuitboard/machine/blade_turbine
	name = "turbina gazowa (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/atmospherics/components/binary/blade_turbine
	req_components = list(
		/obj/item/stack/sheet/plasteel = 10,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stack/cable_coil = 10)

// Części: łopatki i stator z dowolnego twardego materiału (autolathe, jak „!any” w Goonie). Bez materiału = żelazo.
/obj/item/turbine_part
	name = "część turbiny"
	desc = "Część zamienna turbiny gazowej."
	icon = 'aquila/icons/obj/machines/turbine/turbine_parts.dmi'
	w_class = WEIGHT_CLASS_BULKY
	force = 8
	throwforce = 8
	material_flags = MATERIAL_EFFECTS | MATERIAL_COLOR
	custom_materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 3)

/obj/item/turbine_part/Initialize(mapload)
	. = ..()
	update_part_name()

/obj/item/turbine_part/set_custom_materials(list/materials, multiplier = 1)
	. = ..()
	update_part_name()

/obj/item/turbine_part/proc/update_part_name()
	name = "[initial(name)] ([material_name()])"

/// Główny materiał części (największy udział)
/obj/item/turbine_part/proc/main_material()
	var/datum/material/best
	for(var/mat in custom_materials)
		if(!best || custom_materials[mat] > custom_materials[best])
			best = mat
	if(!best)
		return SSmaterials.GetMaterialRef(/datum/material/iron)
	return SSmaterials.GetMaterialRef(best)

/obj/item/turbine_part/proc/material_name()
	return get_turbine_properties()["name"]

/// Gęstość, twardość i przewodnictwo z tabeli materiałów kuźni amunicji; materiały spoza niej z listy poniżej
/obj/item/turbine_part/proc/get_turbine_properties()
	return aq_turbine_material_properties(main_material())

/proc/aq_turbine_material_properties(datum/material/mat)
	var/mat_type = istype(mat) ? mat.type : mat
	var/datum/munition_material/M = get_munition_material(mat_type)
	if(M)
		return list("name" = M.name, "density" = M.density, "hardness" = M.hardness, "conductivity" = M.conductivity)
	var/static/list/extra = list(
		/datum/material/glass = list("name" = "szkło", "density" = 5, "hardness" = 5.5, "conductivity" = 0),
		/datum/material/plastic = list("name" = "plastik", "density" = 2, "hardness" = 2, "conductivity" = 0),
		/datum/material/wood = list("name" = "drewno", "density" = 1.4, "hardness" = 1.5, "conductivity" = 0),
		/datum/material/adamantine = list("name" = "adamantyt", "density" = 30, "hardness" = 9, "conductivity" = 3),
	)
	if(extra[mat_type])
		return extra[mat_type]
	// Nieznany materiał: miękki jak gąbka, jak domyślne w Goonie
	return list("name" = istype(mat) ? mat.name : "nieznany materiał", "density" = 2, "hardness" = 1, "conductivity" = 0)

/obj/item/turbine_part/blade
	name = "łopatki turbiny"
	desc = "Zamienny wirnik z łopatkami do turbiny gazowej. Gęstszy materiał daje cięższy wirnik (wolniej przyspiesza, lepiej trzyma obroty), twardszy wytrzymuje dłużej na nadobrotach."
	icon_state = "blade"
	custom_materials = list(/datum/material/iron = MINERAL_MATERIAL_AMOUNT * 5)

// Skala tak dobrana, żeby żelazo dało wartości stali z Goona (masa 800, 15 wytrzymałości)
/obj/item/turbine_part/blade/proc/blade_mass(list/props)
	return max(200, round(800 * props["density"] / 14))

/obj/item/turbine_part/blade/proc/blade_max_health(list/props)
	return max(1, round(15 * props["hardness"] / 4))

/obj/item/turbine_part/stator
	name = "stator turbiny"
	desc = "Zamienne uzwojenie generatora turbiny gazowej. Lepiej przewodzący materiał daje więcej prądu."
	icon_state = "stator"

/obj/item/turbine_part/stator/proc/stator_multiplier(list/props)
	return max(0.2, 1 + (props["conductivity"] - 1) * 0.08)

/obj/item/turbine_part/blade/examine(mob/user)
	. = ..()
	var/list/props = get_turbine_properties()
	. += "<span class='notice'>Masa wirnika: [blade_mass(props)], wytrzymałość: [blade_max_health(props)].</span>"

/obj/item/turbine_part/stator/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Mnożnik mocy: ×[round(stator_multiplier(get_turbine_properties()), 0.01)].</span>"

/datum/design/turbine_blade
	name = "Łopatki turbiny"
	desc = "Zamienne łopatki turbiny gazowej z wybranego materiału."
	id = "turbine_blade"
	build_type = AUTOLATHE
	materials = list(MAT_CATEGORY_RIGID = MINERAL_MATERIAL_AMOUNT * 5)
	build_path = /obj/item/turbine_part/blade
	category = list("initial", "Construction")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/turbine_stator
	name = "Stator turbiny"
	desc = "Zamienny stator turbiny gazowej z wybranego materiału."
	id = "turbine_stator"
	build_type = AUTOLATHE
	materials = list(MAT_CATEGORY_RIGID = MINERAL_MATERIAL_AMOUNT * 3)
	build_path = /obj/item/turbine_part/stator
	category = list("initial", "Construction")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/blade_turbine
	name = "Projekt maszyny (turbina gazowa)"
	desc = "Płytka drukowana: turbina gazowa z wymiennymi łopatkami."
	id = "blade_turbine"
	build_path = /obj/item/circuitboard/machine/blade_turbine
	category = list("Engineering Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

// Obok TEG w tym samym węźle; dopisane, żeby zmiany upstreamu w węźle nadal działały
/datum/techweb_node/adv_power/New()
	. = ..()
	design_ids += "blade_turbine"

#undef AQ_TURBINE_OVERTEMP_WARNING
#undef AQ_TURBINE_OVERTEMP_LIMIT
#undef AQ_TURBINE_STATOR_LOAD_MIN
#undef AQ_TURBINE_STATOR_LOAD_MAX
#undef AQ_TURBINE_FLOW_RATE_MIN
#undef AQ_TURBINE_OVERSPEED_MULTIPLIER
#undef AQ_TURBINE_HISTORY_MAX
#undef AQ_TURBINE_POWER_SCALE
