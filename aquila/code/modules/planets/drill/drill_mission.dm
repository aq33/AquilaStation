// AQUILA - misja „Próbki geologiczne”: port misji wiertniczej z Shiptesta (AGPLv3)
// code/modules/missions/outpost/drill_mission.dm (/datum/mission/drill i /obj/machinery/drill/mission) na nasze misje
// dowództwa na planecie (planet_mission.dm). Dowództwo dodaje planetę z żyłami wymaganej klasy i wysyła na okręt wiertło do próbek
// (z ogniwem) oraz skrzynię ze skanerem gruntu, GPS, instrukcją i zapasowymi częściami. Załoga przykręca wiertło na żyle
// rudy wymaganej klasy, broni go przed fauną z wyrw, póki nie zbierze próbek, i dowozi je na okręt.
// Zmiany względem Shiptesta:
// - klasa misji (1-3) jest losowana w jednym trybie z wagami Shiptesta (11/9/5) zamiast trzech osobnych misji
//   z placówki; nagroda w skali naszych misji na planecie, dopłata za każdą próbkę ponad wymagane;
// - na planecie misji zawsze stoi żyła wymaganej klasy z ładunkami na wszystkie próbki, z dala od lądowisk (generator
//   może nie postawić żadnej);
// - pojemnik na próbki mieści wymagane + 3 i wiertło nie ruszy, gdy jest pełny (w Shiptest dało się wiercić dalej);
// - bez kart dziurkowanych do namierzania planety (u nas planeta jest od razu przeskanowana); misja klasy 4
//   (industrial_drill.dm) jest osobno w deep_vein_mission.dm.

// Kopie definicji z overmap_mode.dm, które są tam #undef na końcu pliku
#define STATUS_INPROGRESS 0
#define STATUS_COMPLETED 1
#define STATUS_FAILED 2
#define REMINDER_COMBAT_DELAY 2

/// Dopłata za każdą próbkę ponad wymagane (mnożona przez klasę misji)
#define PLANET_DRILL_EXTRA_SAMPLE_PAYOUT 1500
/// Ile próbek ponad wymagane mieści wiertło
#define PLANET_DRILL_EXTRA_SAMPLES 3

/datum/overmap_gamemode/planet_drill
	name = "Próbki geologiczne"
	config_tag = "planet_drill"
	desc = "Tryb próbek geologicznych – wywiercić próbki z żyły rudy na planecie i dowieźć wiertło na okręt"
	brief = "Dowództwo potrzebuje danych geologicznych z planety na skraju sektora. Na pokład dotrze wiertło do próbek: zamocujcie je na żyle rudy, brońcie go przed fauną, póki nie zbierze próbek, i przywieźcie je na okręt."
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = REMINDER_COMBAT_DELAY
	combat_delay = 10 MINUTES
	selection_weight = 5
	required_players = 5
	fixed_objectives = list(/datum/overmap_objective/planet/drill_samples)

/datum/overmap_objective/planet/drill_samples
	name = "Próbki geologiczne"
	desc = "Wywiercić próbki z żyły rudy wymaganej klasy na planecie i dowieźć wiertło do próbek na okręt."
	equipment = list(
		/obj/item/pinpointer/mineral,
		/obj/item/gps/mining,
		/obj/item/paper/guides/drill,
		/obj/item/stock_parts/capacitor,
		/obj/item/stock_parts/micro_laser,
		/obj/item/stock_parts/scanning_module,
	)
	/// Wymagana klasa żyły
	var/class_wanted = 1
	/// Ile próbek trzeba zebrać
	var/num_wanted = 5
	/// Wiertło misji
	var/obj/machinery/drill/mission/sampler

/datum/overmap_objective/planet/drill_samples/New(datum/star_system/passed_input)
	. = ..()
	// Wagi i liczby próbek z Shiptesta: klasa 1 (waga 11, 5 próbek), 2 (9, 6), 3 (5, 8)
	class_wanted = pickweight(list("1" = 11, "2" = 9, "3" = 5))
	class_wanted = text2num(class_wanted)
	required_vein_class = class_wanted
	var/base_wanted = 5
	switch(class_wanted)
		if(2)
			base_wanted = 6
		if(3)
			base_wanted = 8
	num_wanted = rand(base_wanted - 2, base_wanted + 2)
	payout = 10000 + 10000 * class_wanted
	research_payout = 2500 + 2500 * class_wanted

/datum/overmap_objective/planet/drill_samples/Destroy()
	if(sampler)
		UnregisterSignal(sampler, COMSIG_PARENT_QDELETING)
		sampler.mission = null
		sampler = null
	return ..()

/datum/overmap_objective/planet/drill_samples/update_brief()
	brief = "Dowództwo potrzebuje danych geologicznych z [target_planet] w układzie [target_system]. Na pokład dotrą dwie skrzynie: wiertło do próbek z ogniwem oraz skaner gruntu, GPS, instrukcja i zapasowe części. Znajdźcie skanerem żyłę rudy klasy [class_wanted] lub wyższej, przykręćcie na niej wiertło kluczem i brońcie go przed rozwścieczoną fauną, póki nie zbierze [num_wanted] próbek. Potem dowieźcie wiertło na okręt. Każda dodatkowa próbka (do [num_wanted + PLANET_DRILL_EXTRA_SAMPLES]) to [PLANET_DRILL_EXTRA_SAMPLE_PAYOUT * class_wanted] kr więcej. Nagroda: [payout] kr i [research_payout] punktów badań."

/// Oprócz zwykłej skrzyni ze sprzętem osobna skrzynia z wiertłem
/datum/overmap_objective/planet/drill_samples/send_equipment()
	. = ..()
	var/obj/structure/overmap/main_ship = SSstar_system.find_main_overmap()
	if(!main_ship)
		return
	var/obj/structure/closet/crate/drill_crate = new
	drill_crate.name = "skrzynia: wiertło do próbek"
	sampler = new(drill_crate)
	sampler.orevein_wanted = target_planet?.planet_type.vein_root
	sampler.setup_mission(src)
	RegisterSignal(sampler, COMSIG_PARENT_QDELETING, PROC_REF(on_sampler_deleted))
	main_ship.send_supplypod(drill_crate, null, TRUE)

/// Żyła wymaganej klasy z dala od lądowisk, z ładunkami na wszystkie próbki
/datum/overmap_objective/planet/drill_samples/setup_site()
	var/turf/T = pick_site_turf()
	if(!T)
		return
	var/vein_type = target_planet.planet_type.get_mission_vein(class_wanted)
	if(!vein_type)
		return
	var/obj/structure/vein/site_vein = new vein_type(T)
	site_vein.mining_charges = max(site_vein.mining_charges, num_wanted + PLANET_DRILL_EXTRA_SAMPLES)
	log_game("Planet [target_planet] drill mission vein [vein_type] placed at [AREACOORD(T)]")

/datum/overmap_objective/planet/drill_samples/proc/on_sampler_deleted(datum/source)
	SIGNAL_HANDLER
	sampler = null
	if(status != STATUS_INPROGRESS)
		return
	status = STATUS_FAILED
	if(target_planet && target_planet.surface?.state != PLANET_SURFACE_READY)
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(priority_announce), "Wiertło do próbek z misji na [target_planet] zostało na planecie i przepadło po odlocie okrętu. Zadanie się nie powiodło.", "Dowództwo floty")
		return
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(priority_announce), "Wiertło do próbek z misji na [target_planet] zostało zniszczone. Zadanie się nie powiodło.", "Dowództwo floty")

/datum/overmap_objective/planet/drill_samples/check_completion()
	if(status != STATUS_INPROGRESS || !target_planet || QDELETED(sampler))
		return
	if(sampler.num_current < num_wanted || !is_delivered(sampler))
		return
	var/extra_samples = sampler.num_current - num_wanted
	if(extra_samples > 0)
		payout += extra_samples * PLANET_DRILL_EXTRA_SAMPLE_PAYOUT * class_wanted
	complete_mission()

/// Wiertło misji: zamiast rudy zbiera próbki z żyły wymaganej klasy. Nie ma płytki, więc nie da się go rozebrać.
/obj/machinery/drill/mission
	name = "wiertło do próbek geologicznych"
	desc = "Specjalne wiertło laserowe do pobierania próbek geologicznych spod powierzchni planety."
	circuit = null
	preload_cell_type = /obj/item/stock_parts/cell/high
	/// Zebrane próbki
	var/num_current = 0
	/// Wymagana klasa żyły
	var/mission_class = 1
	/// Wymagane próbki
	var/num_wanted = 5
	/// Rodzaj żył, na których działa (vein_root typu planety misji; null = dowolne)
	var/orevein_wanted
	var/datum/overmap_objective/planet/drill_samples/mission

/obj/machinery/drill/mission/Destroy()
	mission = null
	return ..()

/obj/machinery/drill/mission/proc/setup_mission(datum/overmap_objective/planet/drill_samples/new_mission)
	mission = new_mission
	mission_class = new_mission.class_wanted
	num_wanted = new_mission.num_wanted
	name = "[initial(name)] (klasa [mission_class])"

/obj/machinery/drill/mission/examine(mob/user)
	. = ..()
	. += span_notice("Zebrane próbki: [num_current] z [num_wanted] wymaganych. Wymagana klasa żyły: [mission_class] lub wyższa.")
	if(num_current >= num_wanted)
		. += span_notice("Dodatkowe próbki (do [num_wanted + PLANET_DRILL_EXTRA_SAMPLES]) są warte po [PLANET_DRILL_EXTRA_SAMPLE_PAYOUT * mission_class] kr. Dowieźcie wiertło na okręt.")

/// Czy żyła pod wiertłem leży na planecie wskazanej w misji (misja bez planety, np. z testu: wszystko jedno)
/obj/machinery/drill/proc/vein_on_planet(obj/structure/overmap/planet/target)
	if(!target || !our_vein)
		return TRUE
	return target.surface?.contains(get_turf(our_vein))

/obj/machinery/drill/mission/start_mining()
	if(!vein_on_planet(mission?.target_planet))
		say("Błąd: ta żyła nie leży na planecie wskazanej w misji ([mission.target_planet]).")
		return
	if(our_vein && orevein_wanted && !istype(our_vein, orevein_wanted))
		say("Błąd: zły rodzaj planety dla tej operacji.")
		return
	if(our_vein && our_vein.vein_class < mission_class)
		say("Błąd: do tej operacji potrzebna jest żyła klasy [mission_class] lub wyższej.")
		return
	if(num_current >= num_wanted + PLANET_DRILL_EXTRA_SAMPLES)
		say("Pojemnik na próbki jest pełny. Dalsze wiercenie niemożliwe.")
		if(active)
			stop_mining()
		return
	return ..()

/obj/machinery/drill/mission/mine_success()
	num_current++
	if(num_current == num_wanted)
		say("Wymagane próbki zebrane. Dodatkowe próbki są warte po [PLANET_DRILL_EXTRA_SAMPLE_PAYOUT * mission_class] kr. Wyłączam się!")
		if(active)
			stop_mining()
	else if(num_current >= num_wanted + PLANET_DRILL_EXTRA_SAMPLES)
		say("Pojemnik na próbki jest pełny. Dalsze wiercenie niemożliwe.")
		if(active)
			stop_mining()

#undef STATUS_INPROGRESS
#undef STATUS_COMPLETED
#undef STATUS_FAILED
#undef REMINDER_COMBAT_DELAY
#undef PLANET_DRILL_EXTRA_SAMPLE_PAYOUT
#undef PLANET_DRILL_EXTRA_SAMPLES
