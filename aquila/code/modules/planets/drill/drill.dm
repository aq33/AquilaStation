// AQUILA - laserowe wiertło górnicze. Port z Shiptesta (AGPLv3): code/modules/mining/drill.dm (/obj/machinery/drill,
// /datum/looping_sound/drill, instrukcja /obj/item/paper/guides/drill). Sprite'y z Shiptesta
// icons/obj/machines/drill.dmi (CC BY-SA 3.0), tylko używane stany, w aquila/icons/planets/drill.dmi. Dźwięk pracy
// to nasze sound/machines/gravgen/gravgen_mid*.ogg (te same pliki co w Shiptest).
// Wiertło przykręca się kluczem na żyle rudy i włącza ręką. Każdy cykl (ok. 30 s, krócej z lepszym mikrolaserem) zużywa
// ładunek żyły i wyrzuca obok rudę (więcej z lepszym modułem skanującym), a lepszy kondensator zmniejsza zużycie ogniwa.
// Wiertło uszkodzone do 2/3 wytrzymałości przy starcie cyklu dostaje losową awarię: wymiana mikrolasera, modułu
// skanującego albo kondensatora, spawanie konstrukcji albo kalibracja multitoolem (wszystko przy otwartym panelu).
// Zniszczone wiertło nie rozpada się, tylko psuje: 10 arkuszy plastali, klucz, spawarka.
// Zmiany względem Shiptesta:
// - da się je zbudować z płytki (Shiptest: tylko ze skrzyni cargo), więc części daje płytka, a zbudowane wiertło
//   nie ma ogniwa (bez darmowych ogniw z budowania i rozbierania); łomem przy otwartym panelu wyjmuje się ogniwo,
//   a bez ogniwa rozbiera maszynę;
// - wymiana części porównuje rodzaj części (u nas nie ma part_behaviour), a zepsuta część znika zamiast wisieć w pamięci;
// - wyjęcie ogniwa w trakcie pracy zatrzymuje wiertło (w Shiptest cykl kończył się mimo to);
// - czas do wyczerpania żyły jako „M:SS” zamiast time2text (strefa czasowa serwera).

#define DRILL_MALF_LASER 1
#define DRILL_MALF_SENSOR 2
#define DRILL_MALF_CAPACITOR 3
#define DRILL_MALF_STRUCTURAL 4
#define DRILL_MALF_CALIBRATE 5

#define DRILL_METAL_ABSENT 0
#define DRILL_METAL_PLACED 1
#define DRILL_METAL_SECURED 2

/obj/machinery/drill
	name = "ciężkie laserowe wiertło górnicze"
	desc = "Wielkie wiertło laserowe. Wydobywa ogromne ilości minerałów z płytkich złóż, ale wstrząsy sejsmiczne, które wywołuje, rozwścieczają okoliczną faunę."
	icon = 'aquila/icons/planets/drill.dmi'
	icon_state = "deep_core_drill"
	max_integrity = 400
	density = TRUE
	anchored = FALSE
	use_power = NO_POWER_USE
	layer = LYING_MOB_LAYER
	armor = list("melee" = 50, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 90, "acid" = 90, "stamina" = 0)
	circuit = /obj/item/circuitboard/machine/vein_drill
	/// Bieżąca awaria (DRILL_MALF_*)
	var/malfunction
	/// Wiertło pracuje
	var/active = FALSE
	/// Żyła, na której jest zamocowane
	var/obj/structure/vein/our_vein
	var/datum/looping_sound/drill/soundloop
	var/obj/item/stock_parts/cell/cell
	/// Ogniwo w nowym wiertle (zbudowane z płytki go nie ma)
	var/preload_cell_type
	/// Zużycie ogniwa na cykl (dzielone przez poziom kondensatora)
	var/power_cost = 100
	/// Postęp naprawy zniszczonej konstrukcji (DRILL_METAL_*)
	var/metal_attached = DRILL_METAL_ABSENT
	/// Rodzaj części zabranej przez awarię
	var/missing_part
	var/current_timerid

/obj/machinery/drill/Initialize(mapload)
	. = ..()
	if(!circuit)
		component_parts = list(
			new /obj/item/stock_parts/capacitor(null),
			new /obj/item/stock_parts/micro_laser(null),
			new /obj/item/stock_parts/scanning_module(null),
		)
	if(preload_cell_type)
		cell = new preload_cell_type(src)
	soundloop = new(src, FALSE)
	update_appearance()

/obj/machinery/drill/Destroy()
	if(current_timerid)
		deltimer(current_timerid)
		current_timerid = null
	if(our_vein)
		our_vein.stop_spawning()
		our_vein.our_drill = null
		our_vein = null
	QDEL_NULL(soundloop)
	QDEL_NULL(cell)
	return ..()

/obj/machinery/drill/examine(mob/user)
	. = ..()
	if(panel_open && component_parts)
		. += display_parts(user)
	if(!cell)
		. += span_warning("Nie ma ogniwa zasilającego.")
	else if(cell.charge < power_cost * 5)
		. += span_notice("Miga kontrolka niskiego poziomu zasilania.")
	switch(malfunction)
		if(DRILL_MALF_LASER)
			. += span_notice("Wiertło ma zepsuty <b>mikrolaser</b> do wymiany.")
		if(DRILL_MALF_SENSOR)
			. += span_notice("Wiertło ma zepsuty <b>moduł skanujący</b> do wymiany.")
		if(DRILL_MALF_CAPACITOR)
			. += span_notice("Wiertło ma zepsuty <b>kondensator</b> do wymiany.")
		if(DRILL_MALF_STRUCTURAL)
			. += span_notice("Konstrukcję wiertła trzeba <b>zespawać</b>.")
		if(DRILL_MALF_CALIBRATE)
			. += span_notice("Zawieszenie lasera się rozkalibrowało: trzeba je ustawić <b>multitoolem</b>.")
	switch(metal_attached)
		if(DRILL_METAL_PLACED)
			. += span_notice("Nowe poszycie jest przyłożone, ale trzeba je przykręcić <b>kluczem</b>.")
		if(DRILL_METAL_SECURED)
			. += span_notice("Nowe poszycie jest przykręcone, ale trzeba je jeszcze <b>zespawać</b>.")
	if((machine_stat & BROKEN) && !metal_attached)
		. += span_notice("Konstrukcja jest kompletnie zniszczona: trzeba wymienić poszycie z <b>plastali</b> (10 arkuszy).")
	if(panel_open)
		. += span_notice("Przy otwartym panelu wymienisz części, włożysz ogniwo i wyjmiesz je <b>łomem</b>.")
	. += span_notice("Ręczny wyłącznik awaryjny pociągniesz <b>Alt-klikiem</b>.")

/obj/machinery/drill/process(delta_time)
	if(active && ((machine_stat & BROKEN) || !our_vein))
		stop_mining()
	if(!active && our_vein?.currently_spawning)
		our_vein.stop_spawning()

/// Zniszczone wiertło nie znika, tylko psuje się i wymaga naprawy plastalą (jak w Shiptest)
/obj/machinery/drill/deconstruct(disassembled = TRUE)
	if(disassembled && circuit && !(flags_1 & NODECONSTRUCT_1))
		if(active)
			stop_mining()
		return ..()
	// Wiertło bez płytki (misyjne) nie daje się rozebrać
	if(disassembled)
		return
	if(active && our_vein)
		say("Utrata integralności konstrukcji. Uruchamiam procedurę awaryjnego wyłączenia.")
		var/obj/structure/vein/vein = our_vein
		stop_mining()
		// Żeby żyła nie wypuszczała fauny bez końca i żeby awaria coś kosztowała
		vein.collapse()
	obj_break()
	update_appearance()

/obj/machinery/drill/on_deconstruction()
	if(cell)
		cell.forceMove(drop_location())
		cell = null
	return ..()

/// RPED trywializowałby awarie, więc nie działa (jak w Shiptest)
/obj/machinery/drill/exchange_parts(mob/user, obj/item/storage/part_replacer/W)
	to_chat(user, span_notice("[W] tu nie zadziała: części wiertła trzeba wymieniać ręcznie."))
	return TRUE

/obj/machinery/drill/attackby(obj/item/tool, mob/living/user, params)
	if(machine_stat & BROKEN)
		if(istype(tool, /obj/item/stack/sheet/plasteel) && metal_attached == DRILL_METAL_ABSENT)
			var/obj/item/stack/sheet/plasteel/plating = tool
			if(plating.use(10))
				metal_attached = DRILL_METAL_PLACED
				to_chat(user, span_notice("Przykładasz nowe poszycie do wiertła."))
			else
				to_chat(user, span_warning("Na nowe poszycie potrzeba 10 arkuszy plastali."))
			return TRUE
		if(metal_attached == DRILL_METAL_SECURED && tool.tool_behaviour == TOOL_WELDER)
			if(tool.use_tool(src, user, 3 SECONDS, volume = 50))
				to_chat(user, span_notice("Przyspawasz nowe poszycie. Wiertło jest naprawione."))
				metal_attached = DRILL_METAL_ABSENT
				obj_integrity = max_integrity
				set_machine_stat(machine_stat & ~BROKEN)
				update_appearance()
			return TRUE
	if(tool.tool_behaviour == TOOL_WRENCH)
		wrench_act_drill(user, tool)
		return TRUE
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		update_appearance()
		return TRUE
	if(panel_open && repair_act(tool, user))
		return TRUE
	return ..()

/// Klucz: przykręcanie poszycia, mocowanie na żyle i odczepianie
/obj/machinery/drill/proc/wrench_act_drill(mob/living/user, obj/item/tool)
	if(metal_attached == DRILL_METAL_PLACED && (machine_stat & BROKEN))
		if(tool.use_tool(src, user, 3 SECONDS, volume = 50))
			to_chat(user, span_notice("Przykręcasz nowe poszycie wiertła."))
			metal_attached = DRILL_METAL_SECURED
		return
	if(active)
		to_chat(user, span_warning("Nie odczepisz pracującego wiertła!"))
		return
	if(!anchored)
		var/obj/structure/vein/vein = locate() in loc
		if(!vein)
			to_chat(user, span_warning("Wiertło musi stać na żyle rudy."))
			return
		if(vein.our_drill)
			to_chat(user, span_warning("Na tej żyle już stoi wiertło."))
			return
		if(!tool.use_tool(src, user, 3 SECONDS, volume = 50) || anchored || QDELETED(vein) || vein.our_drill || vein.loc != loc)
			return
		to_chat(user, span_notice("Mocujesz wiertło na żyle rudy."))
		playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
		our_vein = vein
		vein.our_drill = src
		setAnchored(TRUE)
		update_appearance()
		return
	if(!tool.use_tool(src, user, 3 SECONDS, volume = 50) || !anchored || active)
		return
	to_chat(user, span_notice("Odczepiasz wiertło od żyły rudy."))
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	release_vein()
	setAnchored(FALSE)
	update_appearance()

/// Naprawy i obsługa przy otwartym panelu. TRUE, jeśli narzędzie zostało użyte.
/obj/machinery/drill/proc/repair_act(obj/item/tool, mob/living/user)
	var/static/list/part_kinds = list(/obj/item/stock_parts/scanning_module, /obj/item/stock_parts/micro_laser, /obj/item/stock_parts/capacitor)
	for(var/part_kind in part_kinds)
		if(!istype(tool, part_kind))
			continue
		var/obj/item/stock_parts/new_part = tool
		if(missing_part == part_kind)
			if(!user.transferItemToLoc(new_part, src))
				return TRUE
			new_part.moveToNullspace()
			component_parts += new_part
			malfunction = null
			missing_part = null
			obj_integrity = max_integrity
			to_chat(user, span_notice("Wstawiasz [new_part] w miejsce zepsutej części."))
			return TRUE
		var/obj/item/stock_parts/old_part = locate(part_kind) in component_parts
		if(!old_part)
			return TRUE
		if(!user.transferItemToLoc(new_part, src))
			return TRUE
		new_part.moveToNullspace()
		component_parts -= old_part
		component_parts += new_part
		old_part.forceMove(drop_location())
		user.put_in_hands(old_part)
		to_chat(user, span_notice("Wymieniasz [old_part] na [new_part]."))
		return TRUE
	if(tool.tool_behaviour == TOOL_MULTITOOL && malfunction == DRILL_MALF_CALIBRATE)
		user.visible_message(span_notice("[user] zaczyna kalibrować wiertło."), span_notice("Zaczynasz kalibrować wiertło..."))
		if(tool.use_tool(src, user, 10 SECONDS, volume = 50) && malfunction == DRILL_MALF_CALIBRATE)
			malfunction = null
			obj_integrity = max_integrity
		return TRUE
	if(tool.tool_behaviour == TOOL_WELDER && malfunction == DRILL_MALF_STRUCTURAL)
		if(!tool.tool_start_check(user, amount = 0))
			return TRUE
		user.visible_message(span_notice("[user] zaczyna spawać konstrukcję wiertła."), span_notice("Zaczynasz spawać konstrukcję wiertła..."), span_hear("Słyszysz spawanie."))
		if(tool.use_tool(src, user, 10 SECONDS, volume = 50) && malfunction == DRILL_MALF_STRUCTURAL)
			malfunction = null
			obj_integrity = max_integrity
		return TRUE
	if(istype(tool, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/battery = tool
		if(cell)
			to_chat(user, span_warning("W wiertle już jest ogniwo!"))
			return TRUE
		if(battery.maxcharge < power_cost)
			to_chat(user, span_warning("Wiertło potrzebuje pojemniejszego ogniwa."))
			return TRUE
		if(!user.transferItemToLoc(battery, src))
			return TRUE
		cell = battery
		to_chat(user, span_notice("Wkładasz ogniwo do wiertła."))
		return TRUE
	if(tool.tool_behaviour == TOOL_CROWBAR)
		if(cell)
			if(active)
				stop_mining()
			cell.update_icon()
			cell.forceMove(drop_location())
			user.put_in_hands(cell)
			cell = null
			to_chat(user, span_notice("Wyjmujesz ogniwo z wiertła."))
			return TRUE
		if(circuit && !active)
			return default_deconstruction_crowbar(tool)
	return FALSE

/obj/machinery/drill/AltClick(mob/user)
	if(!active || !user.canUseTopic(src, BE_CLOSE))
		return ..()
	to_chat(user, span_notice("Zaczynasz ręcznie wyłączać wiertło."))
	if(!do_after(user, 1 SECONDS, TRUE, src))
		to_chat(user, span_notice("Przerywasz wyłączanie."))
		return
	if(!active)
		to_chat(user, span_warning("Wiertło jest już wyłączone!"))
		return
	say("Ręczne wyłączenie. Wstrzymuję wydobycie.")
	stop_mining()

/obj/machinery/drill/interact(mob/user, special_state)
	. = ..()
	if(machine_stat & BROKEN)
		to_chat(user, span_warning("Wiertło jest zniszczone i trzeba je naprawić."))
		return
	if(malfunction)
		say("Najpierw usuńcie bieżącą awarię.")
		return
	if(!our_vein)
		to_chat(user, span_warning("Wiertło nie jest zamocowane na żyle rudy!"))
		return
	if(active)
		to_chat(user, span_notice("Wiertło już pracuje, poczekaj, aż skończy!"))
		return
	playsound(src, 'sound/machines/click.ogg', 100, TRUE)
	user.visible_message("[user] włącza wiertło.", span_notice("Wciskasz przycisk zapłonu wiertła."), span_hear("Słyszysz, jak wiertło budzi się do życia."))
	start_mining()

/obj/machinery/drill/update_icon_state()
	if(anchored)
		if(machine_stat & BROKEN)
			icon_state = "deep_core_drill-deployed_broken"
		else if(active)
			icon_state = "deep_core_drill-active"
		else
			icon_state = "deep_core_drill-idle"
	else if(machine_stat & BROKEN)
		icon_state = "deep_core_drill-broken"
	else
		icon_state = "deep_core_drill"
	return ..()

/obj/machinery/drill/update_overlays()
	. = ..()
	// Promień lasera świeci w ciemności
	if(active && anchored)
		set_light(3, 1, "#99FFFF")
		. += mutable_appearance(icon, "mining_beam-particles", layer)
		. += emissive_appearance(icon, "mining_beam-particles", layer)
	else
		set_light(0)

/// Poziom części danego rodzaju (0, jeśli jej brak)
/obj/machinery/drill/proc/get_drill_part_rating(part_kind)
	var/obj/item/stock_parts/part = locate(part_kind) in component_parts
	return part ? part.rating : 0

/// Odpina wiertło od żyły
/obj/machinery/drill/proc/release_vein()
	if(!our_vein)
		return
	our_vein.stop_spawning()
	our_vein.our_drill = null
	our_vein = null

/// Żyła zniknęła spod wiertła
/obj/machinery/drill/proc/on_vein_gone()
	our_vein = null
	if(active)
		stop_mining()
	setAnchored(FALSE)
	update_appearance()

/// Natychmiastowe zatrzymanie; destructive: żyła wyczerpana i się zawala
/obj/machinery/drill/proc/stop_mining(destructive = FALSE)
	active = FALSE
	soundloop.stop()
	if(current_timerid)
		deltimer(current_timerid)
		current_timerid = null
	if(our_vein?.currently_spawning)
		our_vein.stop_spawning()
	if(destructive && our_vein)
		our_vein.collapse()
	playsound(src, 'sound/machines/switch2.ogg', 50, TRUE)
	update_appearance()

/// Sprawdzenia przed cyklem wydobycia (średnio 30 s)
/obj/machinery/drill/proc/start_mining()
	var/power_use = power_cost / max(1, get_drill_part_rating(/obj/item/stock_parts/capacitor))
	if(!cell || cell.charge < power_use)
		say("Błąd: wyczerpane ogniwo zasilające.")
		if(active)
			stop_mining()
		return
	if(obj_integrity <= max_integrity / 1.5)
		malfunction(rand(DRILL_MALF_LASER, DRILL_MALF_CALIBRATE))
		if(active)
			stop_mining()
		return
	if(!our_vein)
		return
	if(our_vein.mining_charges < 1)
		say("Błąd: żyła wyczerpana.")
		stop_mining(TRUE)
		return
	active = TRUE
	soundloop.start()
	our_vein.begin_spawning()
	var/mine_time = round((30 SECONDS / sqrt(max(1, get_drill_part_rating(/obj/item/stock_parts/micro_laser)))) * our_vein.mine_time_multiplier)
	cell.use(power_use)
	if(current_timerid)
		deltimer(current_timerid)
	current_timerid = addtimer(CALLBACK(src, PROC_REF(mine)), mine_time, TIMER_STOPPABLE)
	say("Szacowany czas do wyczerpania żyły: [drill_time_text(mine_time * our_vein.mining_charges)].")
	update_appearance()

/// Wyciąga rudę z żyły
/obj/machinery/drill/proc/mine()
	current_timerid = null
	if(!our_vein)
		return FALSE
	if(our_vein.mining_charges < 1)
		say("Błąd: żyła wyczerpana.")
		stop_mining()
		return FALSE
	our_vein.mining_charges--
	mine_success()
	if(!active)
		return FALSE
	if(our_vein.mining_charges < 1)
		say("Żyła wyczerpana, wyłączam się.")
		stop_mining(TRUE)
	else
		start_mining()

/// Wydobycie: ruda z żyły, więcej z lepszym modułem skanującym
/obj/machinery/drill/proc/mine_success()
	our_vein.drop_ore(sqrt(max(1, get_drill_part_rating(/obj/item/stock_parts/scanning_module))), src)

/// Losowa awaria; część zabrana przez awarię znika
/obj/machinery/drill/proc/malfunction(malfunction_type)
	if(our_vein?.currently_spawning)
		our_vein.stop_spawning()
	malfunction = malfunction_type
	var/part_kind
	switch(malfunction_type)
		if(DRILL_MALF_LASER)
			say("Awaria: uszkodzony mikrolaser. Wymieńcie go przed dalszym wydobyciem.")
			part_kind = /obj/item/stock_parts/micro_laser
		if(DRILL_MALF_SENSOR)
			say("Awaria: uszkodzony skaner gruntu. Wymieńcie moduł skanujący przed dalszym wydobyciem.")
			part_kind = /obj/item/stock_parts/scanning_module
		if(DRILL_MALF_CAPACITOR)
			say("Awaria: uszkodzony kondensator ogniwa. Wymieńcie go przed dalszym wydobyciem.")
			part_kind = /obj/item/stock_parts/capacitor
		if(DRILL_MALF_STRUCTURAL)
			say("Awaria: uszkodzone poszycie. Naprawcie konstrukcję przed dalszym wydobyciem.")
		if(DRILL_MALF_CALIBRATE)
			say("Awaria: rozkalibrowany laser. Skalibrujcie go przed dalszym wydobyciem.")
	if(part_kind)
		missing_part = part_kind
		for(var/obj/item/stock_parts/broken_part in component_parts)
			if(istype(broken_part, part_kind))
				component_parts -= broken_part
				qdel(broken_part)

/datum/looping_sound/drill
	mid_sounds = list('sound/machines/gravgen/gravgen_mid1.ogg' = 1, 'sound/machines/gravgen/gravgen_mid2.ogg' = 1, 'sound/machines/gravgen/gravgen_mid3.ogg' = 1, 'sound/machines/gravgen/gravgen_mid4.ogg' = 1)
	mid_length = 4
	volume = 50
	extra_range = 6

/obj/item/circuitboard/machine/vein_drill
	name = "laserowe wiertło górnicze (płytka maszyny)"
	icon_state = "supply"
	build_path = /obj/machinery/drill
	needs_anchored = FALSE
	req_components = list(
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stack/sheet/plasteel = 5,
	)

/datum/design/board/vein_drill
	name = "Projekt maszyny (laserowe wiertło górnicze)"
	desc = "Płytka do budowy laserowego wiertła górniczego, które wydobywa rudę z żył na powierzchni planet."
	id = "aquila_vein_drill"
	build_path = /obj/item/circuitboard/machine/vein_drill
	category = list("Misc. Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SCIENCE

/datum/techweb_node/basic_mining/New()
	. = ..()
	design_ids += list("aquila_vein_drill", "aquila_vein_scanner")

/// Instrukcja obsługi (w skrzyni misji wiertniczej)
/obj/item/paper/guides/drill
	name = "kartka – „Instrukcja obsługi laserowego wiertła górniczego”"
	default_raw_text = "<center><b>Instrukcja obsługi laserowego wiertła górniczego</b></center><br><br>Dziękujemy za udział w płatnych testach nowego, eksperymentalnego wiertła laserowego. Prawo zobowiązuje nas do wspomnienia, że choć to wspaniałe urządzenie jest mniej niebezpieczne od poprzednich modeli (o 75% mniej zapłonów plazmy), wstrząsy sejsmiczne, które wywołuje, rozwścieczają większość obcej fauny. Dział prawny zaleca więc korzystanie z wiertła wyłącznie uzbrojonym ekipom.<br><br><center><b>Jak uruchomić wiertło</b></center><br>1. Znajdźcie odpowiednią żyłę rudy skanerem gruntu.<br>2. Przykręćcie kotwy wiertła kluczem nad żyłą.<br>3. Włączcie wiertło i brońcie go przed rozwścieczoną fauną, póki nie skończy.<br><br>Wiertło jest podatne na awarie po uszkodzeniach. Zabierzcie zapasowe części (mikrolaser, moduł skanujący, kondensator) i narzędzia (śrubokręt, klucz, spawarkę, multitool, łom). Przy całkowitym zniszczeniu konstrukcji potrzeba 10 arkuszy plastali. Ręczny wyłącznik: Alt-klik."

#undef DRILL_MALF_LASER
#undef DRILL_MALF_SENSOR
#undef DRILL_MALF_CAPACITOR
#undef DRILL_MALF_STRUCTURAL
#undef DRILL_MALF_CALIBRATE
#undef DRILL_METAL_ABSENT
#undef DRILL_METAL_PLACED
#undef DRILL_METAL_SECURED
