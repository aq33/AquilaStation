// AQUILA - misja „Głęboki odwiert”: port z Shiptesta (AGPLv3) code/modules/missions/outpost/industrial_drill.dm
// (/datum/mission/acquire/industrial_drill, wiertło /obj/machinery/drill/sampler_mission, próbka /obj/item/drill_sample
// i pojemnik /obj/item/drill_core_container) na nasze misje dowództwa na planecie (planet_mission.dm). Sprite'y próbki
// i pojemnika to nasze icons/obj/nuke_tools.dmi (te same stany, których Shiptest używa jako zastępczych).
// Dowództwo dodaje planetę wulkaniczną z żyłą klasy 4 i wysyła na okręt wiertło do próbek głębinowych oraz skrzynię
// z pojemnikiem na próbkę, skanerem gruntu, GPS, instrukcją i zapasowymi częściami. Wiertło na żyle klasy 4 wierci
// samples_required cykli (6-10), po czym wyrzuca jedną próbkę geologiczną. Próbkę trzeba zamknąć w pojemniku
// i dowieźć pojemnik na okręt; wiertło przywiezione razem z nim to premia.
// Zmiany względem Shiptesta:
// - Shiptest daje tę misję tylko na planetach dżunglowych, lodowych i skalnych; u nas jest tylko planeta wulkaniczna,
//   więc misja idzie na nią, a setup_site() stawia na niej żyłę klasy 4 z dala od lądowisk;
// - nagroda w skali naszych misji na planecie (Shiptest: 18000 + 2000 za zwrot wiertła);
// - pojemnik zabiera próbkę z ręki dopiero po udanym do_after (w Shiptest przerwane zamykanie gubiło próbkę),
//   a nieużywanego w Shiptest seal() nie ma;
// - wiertło nie rusza drugi raz po wydobyciu próbki (w Shiptest wierciło dalej bez efektu), a próbka nie spada do lawy;
// - zniszczenie pojemnika, próbki albo wiertła przed wydobyciem próbki oblewa misję (Shiptest: misji nie da się oddać).

// Kopie definicji z overmap_mode.dm, które są tam #undef na końcu pliku
#define STATUS_INPROGRESS 0
#define STATUS_COMPLETED 1
#define STATUS_FAILED 2
#define REMINDER_COMBAT_DELAY 2

/// Premia za wiertło dowiezione na okręt razem z próbką
#define PLANET_DEEP_VEIN_DRILL_BONUS 5000

/datum/overmap_gamemode/planet_deep_vein
	name = "Głęboki odwiert"
	config_tag = "planet_deep_vein"
	desc = "Tryb głębokiego odwiertu – wywiercić próbkę z żyły klasy 4 na planecie i dowieźć ją w pojemniku na okręt"
	brief = "Dowództwo szuka złóż dla przemysłu ciężkiego, a takie leżą głęboko pod powierzchnią. Na pokład dotrze wiertło do próbek głębinowych: postawcie je na żyle klasy 4, brońcie go, póki nie wydobędzie próbki, i dowieźcie próbkę w pojemniku na okręt."
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = REMINDER_COMBAT_DELAY
	combat_delay = 10 MINUTES
	selection_weight = 3
	required_players = 5
	fixed_objectives = list(/datum/overmap_objective/planet/deep_vein)

/datum/overmap_objective/planet/deep_vein
	name = "Głęboki odwiert"
	desc = "Wywiercić próbkę z żyły klasy 4 na planecie, zamknąć ją w pojemniku i dowieźć pojemnik na okręt."
	payout = 50000
	research_payout = 15000
	equipment = list(
		/obj/item/pinpointer/mineral,
		/obj/item/gps/mining,
		/obj/item/paper/guides/drill,
		/obj/item/stock_parts/capacitor,
		/obj/item/stock_parts/micro_laser,
		/obj/item/stock_parts/scanning_module,
	)
	/// Wiertło misji
	var/obj/machinery/drill/sampler_mission/sampler
	/// Pojemnik, który ma wrócić na okręt z próbką
	var/obj/item/drill_core_container/container
	/// Wydobyta próbka
	var/obj/item/drill_sample/sample

/datum/overmap_objective/planet/deep_vein/Destroy()
	for(var/atom/movable/tracked as anything in list(sampler, container, sample))
		if(tracked)
			UnregisterSignal(tracked, COMSIG_PARENT_QDELETING)
	if(sampler)
		sampler.mission = null
	sampler = null
	container = null
	sample = null
	return ..()

/datum/overmap_objective/planet/deep_vein/update_brief()
	brief = "Dowództwo szuka złóż dla przemysłu ciężkiego na [target_planet] w układzie [target_system]. Takie złoża leżą głęboko pod powierzchnią: tylko żyła klasy 4 ma wystarczającą głębokość. Na pokład dotrą dwie skrzynie: wiertło do próbek głębinowych z ogniwem oraz pojemnik na próbkę, skaner gruntu, GPS, instrukcja i zapasowe części. Znajdźcie skanerem żyłę klasy 4, przykręćcie na niej wiertło kluczem i brońcie go przed rozwścieczoną fauną, póki nie wydobędzie próbki. Zamknijcie próbkę w pojemniku i dowieźcie go na okręt. Nagroda: [payout] kr i [research_payout] punktów badań, a za wiertło przywiezione razem z próbką [PLANET_DEEP_VEIN_DRILL_BONUS] kr więcej."

/// Oprócz zwykłej skrzyni ze sprzętem (z pojemnikiem) osobna skrzynia z wiertłem
/datum/overmap_objective/planet/deep_vein/send_equipment()
	. = ..()
	var/obj/structure/overmap/main_ship = SSstar_system.find_main_overmap()
	if(!main_ship)
		return
	var/obj/structure/closet/crate/container_crate = new
	container_crate.name = "skrzynia: pojemnik na próbkę"
	container = new(container_crate)
	RegisterSignal(container, COMSIG_PARENT_QDELETING, PROC_REF(on_tracked_deleted))
	main_ship.send_supplypod(container_crate, null, TRUE)
	var/obj/structure/closet/crate/drill_crate = new
	drill_crate.name = "skrzynia: wiertło do próbek głębinowych"
	sampler = new(drill_crate)
	sampler.mission = src
	RegisterSignal(sampler, COMSIG_PARENT_QDELETING, PROC_REF(on_tracked_deleted))
	main_ship.send_supplypod(drill_crate, null, TRUE)

/// Żyła klasy 4 z dala od lądowisk (generator zwykle jej nie stawia)
/datum/overmap_objective/planet/deep_vein/setup_site()
	var/turf/T = pick_site_turf()
	if(!T)
		return
	new /obj/structure/vein/lavaland/classfour(T)
	log_game("Planet [target_planet] deep vein mission vein placed at [AREACOORD(T)]")

/// Wiertło wydobyło próbkę
/datum/overmap_objective/planet/deep_vein/proc/on_sample_created(obj/item/drill_sample/new_sample)
	if(sample)
		UnregisterSignal(sample, COMSIG_PARENT_QDELETING)
	sample = new_sample
	RegisterSignal(sample, COMSIG_PARENT_QDELETING, PROC_REF(on_tracked_deleted))

/// Zniszczony pojemnik albo próbka, albo wiertło przed wydobyciem próbki: misja oblana (lost_name w bierniku)
/datum/overmap_objective/planet/deep_vein/proc/on_tracked_deleted(atom/movable/source)
	SIGNAL_HANDLER
	var/lost_name
	if(source == sampler)
		sampler = null
		if(sample)
			return
		lost_name = "wiertło do próbek głębinowych"
	else if(source == container)
		container = null
		lost_name = "pojemnik na próbkę"
	else if(source == sample)
		sample = null
		lost_name = "próbkę geologiczną"
	else
		return
	if(status != STATUS_INPROGRESS)
		return
	status = STATUS_FAILED
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(priority_announce), "Misja na [target_planet] nie powiodła się: zniszczono [lost_name].", "Dowództwo floty")

/datum/overmap_objective/planet/deep_vein/check_completion()
	if(status != STATUS_INPROGRESS || !target_planet || QDELETED(container) || QDELETED(sample))
		return
	if(container.core != sample || !is_delivered(container))
		return
	if(!QDELETED(sampler) && is_delivered(sampler))
		payout += PLANET_DEEP_VEIN_DRILL_BONUS
	complete_mission()

/// Wiertło do próbek głębinowych: działa tylko na żyle klasy 4 i po samples_required cyklach wyrzuca próbkę
/obj/machinery/drill/sampler_mission
	name = "wiertło do próbek głębinowych"
	desc = "Laserowe wiertło do głębokich odwiertów w mikroskali. Solidnie zbudowane, jak na warunki, które zwykle znosi: póki laser jest cały, łatwo je naprawić."
	circuit = null
	preload_cell_type = /obj/item/stock_parts/cell/high
	/// Wywiercone cykle
	var/num_current = 0
	/// Ile cykli do próbki
	var/samples_required = 10
	var/datum/overmap_objective/planet/deep_vein/mission

/obj/machinery/drill/sampler_mission/Initialize(mapload)
	. = ..()
	samples_required = rand(6, 10)

/obj/machinery/drill/sampler_mission/Destroy()
	mission = null
	return ..()

/obj/machinery/drill/sampler_mission/examine(mob/user)
	. = ..()
	if(num_current >= samples_required)
		. += span_notice("Wiertło skończyło pracę! Dowieźcie je na okręt, a dostaniecie premię.")
	else
		. += span_notice("Wiertło dotarło do [round(num_current / samples_required * 100)]% wymaganej głębokości.")

/obj/machinery/drill/sampler_mission/start_mining()
	if(!vein_on_planet(mission?.target_planet))
		say("Błąd: ta żyła nie leży na planecie wskazanej w misji ([mission.target_planet]).")
		return
	if(our_vein && our_vein.vein_class < 4)
		say("Błąd: za płytka żyła. Znajdźcie żyłę klasy 4.")
		return
	if(num_current >= samples_required)
		say("Próbka już wydobyta. Dalsze wiercenie nic nie da.")
		return
	return ..()

/obj/machinery/drill/sampler_mission/mine_success()
	playsound(src, 'sound/effects/podwoosh.ogg', 50)
	num_current++
	if(num_current < samples_required)
		return
	say("Próbka wydobyta.")
	var/turf/drop_turf = get_step(src, SOUTH)
	if(!drop_turf || isclosedturf(drop_turf) || islava(drop_turf))
		drop_turf = get_turf(src)
	var/obj/item/drill_sample/new_sample = new(drop_turf)
	mission?.on_sample_created(new_sample)
	if(active)
		stop_mining()

/obj/item/drill_sample
	name = "próbka geologiczna"
	desc = "Próbka minerałów z głębokości kilku kilometrów pod twoimi stopami. Idealna do dalszych badań geologicznych. Zamknij ją w pojemniku na próbkę."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "plutonium_core"
	item_state = "plutoniumcore"
	w_class = WEIGHT_CLASS_HUGE

/// Pojemnik na próbkę z głębokiego odwiertu
/obj/item/drill_core_container
	name = "pojemnik na próbkę minerałów"
	desc = "Solidny pojemnik do bezpiecznego transportu próbki minerałów z pierwszego głębokiego odwiertu w okolicy."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "core_container_empty"
	item_state = "tile"
	lefthand_file = 'icons/mob/inhands/misc/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/sheets_righthand.dmi'
	var/obj/item/drill_sample/core

/obj/item/drill_core_container/Destroy()
	QDEL_NULL(core)
	return ..()

/obj/item/drill_core_container/examine(mob/user)
	. = ..()
	. += span_notice(core ? "W środku jest zamknięta próbka geologiczna." : "Pojemnik jest pusty. Włóż do niego próbkę geologiczną.")

/obj/item/drill_core_container/proc/load(obj/item/drill_sample/new_core, mob/user)
	if(core || !istype(new_core))
		return FALSE
	new_core.forceMove(src)
	core = new_core
	icon_state = "core_container_loaded"
	return TRUE

/obj/item/drill_core_container/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/drill_sample))
		return ..()
	if(core)
		to_chat(user, span_warning("W pojemniku już jest próbka."))
		return TRUE
	to_chat(user, span_notice("Zaczynasz zamykać próbkę w pojemniku."))
	if(!do_after(user, 5 SECONDS, TRUE, src) || core || QDELETED(I))
		return TRUE
	if(!user.temporarilyRemoveItemFromInventory(I))
		to_chat(user, span_warning("[I] przywarła ci do ręki!"))
		return TRUE
	load(I, user)
	playsound(src, 'sound/items/deconstruct.ogg', 60, TRUE)
	to_chat(user, span_notice("Próbka jest zamknięta w pojemniku."))
	return TRUE

#undef STATUS_INPROGRESS
#undef STATUS_COMPLETED
#undef STATUS_FAILED
#undef REMINDER_COMBAT_DELAY
#undef PLANET_DEEP_VEIN_DRILL_BONUS
