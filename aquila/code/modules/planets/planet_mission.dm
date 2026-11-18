// AQUILA - misje dowództwa na planecie, na wzór „Opuszczonej stacji” (derelict_ruin.dm). Dowództwo dodaje planetę
// losowego typu z mission_target (dla misji wiertniczych: z żyłą wymaganej klasy) w układzie sektora 2 i wysyła na okręt skrzynię ze sprzętem. Badanie planety: zebrać cztery rodzaje
// próbek, dowieźć je na okręt i postawić sondę badawczą w punkcie badawczym, póki nie skończy skanu. Ewakuacja:
// koloniści w schronie na powierzchni (role duchów, a bez chętnych KNPC idący za załogą) mają żywi trafić na okręt.

// Kopie definicji z overmap_mode.dm, które są tam #undef na końcu pliku
#define STATUS_INPROGRESS 0
#define STATUS_COMPLETED 1
#define STATUS_FAILED 2
#define REMINDER_COMBAT_DELAY 2

/// Rodzaje próbek
#define PLANET_SAMPLE_ROCK "rock"
#define PLANET_SAMPLE_FLORA "flora"
#define PLANET_SAMPLE_FAUNA "fauna"
#define PLANET_SAMPLE_ATMOSPHERE "atmosphere"
#define PLANET_SAMPLE_TYPES list(PLANET_SAMPLE_ROCK, PLANET_SAMPLE_FLORA, PLANET_SAMPLE_FAUNA, PLANET_SAMPLE_ATMOSPHERE)
/// Jak długo skanuje sonda badawcza
#define PLANET_PROBE_SCAN_TIME (3 MINUTES)
/// Ilu kolonistów jest w schronie i ilu musi przeżyć
/// Ile zapasowych sond wysyła dowództwo, zanim badanie przepadnie
#define PLANET_SURVEY_PROBE_RESENDS 2
#define PLANET_COLONISTS 4
#define PLANET_COLONISTS_REQUIRED 3

/proc/planet_sample_name(sample_type)
	switch(sample_type)
		if(PLANET_SAMPLE_ROCK)
			return "skały"
		if(PLANET_SAMPLE_FLORA)
			return "flory"
		if(PLANET_SAMPLE_FAUNA)
			return "fauny"
		if(PLANET_SAMPLE_ATMOSPHERE)
			return "atmosfery"

/datum/overmap_gamemode/planet_survey
	name = "Badanie planety"
	config_tag = "planet_survey"
	desc = "Tryb badania planety – zebrać próbki z powierzchni planety i postawić na niej sondę badawczą"
	brief = "Dowództwo chce zbadać planetę na skraju sektora. Na pokład dotrze skrzynia ze sprzętem badawczym: zbierzcie próbki z powierzchni i postawcie sondę w wyznaczonym punkcie."
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = REMINDER_COMBAT_DELAY
	combat_delay = 10 MINUTES
	selection_weight = 5
	required_players = 5
	fixed_objectives = list(/datum/overmap_objective/planet/survey)

/datum/overmap_gamemode/planet_evacuation
	name = "Ewakuacja kolonii"
	config_tag = "planet_evacuation"
	desc = "Tryb ewakuacji kolonii – zabrać żywych kolonistów z powierzchni planety na okręt"
	brief = "Kolonia na skraju sektora wzywa pomocy. Wylądujcie na planecie, odnajdźcie schron kolonistów i dowieźcie ich żywych na pokład."
	starting_system = "Argo"
	starting_faction = "nanotrasen"
	objective_reminder_setting = REMINDER_COMBAT_DELAY
	combat_delay = 10 MINUTES
	selection_weight = 5
	required_players = 5
	fixed_objectives = list(/datum/overmap_objective/planet/evacuation)

/datum/overmap_objective/planet
	name = "Misja na planecie"
	desc = "Wylądować na planecie i wykonać zadanie dowództwa."
	brief = "Wylądujcie na planecie i wykonajcie zadanie."
	var/datum/star_system/target_system
	var/obj/structure/overmap/planet/target_planet
	/// Nagroda w kredytach i punktach badań
	var/payout = 20000
	var/research_payout = 5000
	/// Skrzynia ze sprzętem dla załogi (typy przedmiotów)
	var/list/equipment = list()
	/// Klasa żyły, którą musi mieć typ planety (misje wiertnicze); null = dowolny typ
	var/required_vein_class

/datum/overmap_objective/planet/New(datum/star_system/passed_input)
	. = ..()
	if(passed_input)
		target_system = passed_input
	if(!target_system && SSstar_system.initialized)
		target_system = pick_planet_system()

/datum/overmap_objective/planet/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	if(target_planet)
		UnregisterSignal(target_planet, COMSIG_PLANET_SURFACE_READY)
	target_planet = null
	target_system = null
	return ..()

/// Te same zasady co przy opuszczonej stacji: sektor 2, bez Rubikonu, czarnej dziury i systemu startowego
/datum/overmap_objective/planet/proc/pick_planet_system()
	var/list/candidates = list()
	var/datum/star_system/start_system = SSovermap_mode.mode ? SSstar_system.system_by_id(SSovermap_mode.mode.starting_system) : null
	for(var/datum/star_system/S in SSstar_system.neutral_zone_systems)
		if(S.hidden || S.sector != 2 || S.name == "Rubicon" || S.has_anomaly_type(/obj/effect/overmap_anomaly/singularity) || S == start_system)
			continue
		candidates += S
	if(length(candidates))
		return pick(candidates)

/datum/overmap_objective/planet/instance()
	. = ..()
	if(!target_system)
		message_admins("Cel [name] nie znajduje układu docelowego, oznaczam go jako wykonany.")
		status = STATUS_COMPLETED
		return
	target_planet = target_system.add_planet(pick_planet_type())
	target_planet.set_scanned()
	target_system.objective_sector = TRUE
	RegisterSignal(target_planet, COMSIG_PLANET_SURFACE_READY, PROC_REF(on_surface_ready))
	update_brief()
	send_equipment()
	START_PROCESSING(SSprocessing, src)

/datum/overmap_objective/planet/proc/update_brief()
	return

/// Typ planety misji: losowy typ dla misji, z żyłą wymaganej klasy, jeśli misja jej potrzebuje
/datum/overmap_objective/planet/proc/pick_planet_type()
	var/list/candidates = list()
	for(var/planet_type in GLOB.planet_type_prototypes)
		var/datum/planet_type/prototype = GLOB.planet_type_prototypes[planet_type]
		if(!prototype.mission_target || !prototype.can_land || prototype.scenery)
			continue
		if(required_vein_class && !LAZYACCESS(prototype.mission_veins, "[required_vein_class]"))
			continue
		candidates += planet_type
	if(length(candidates))
		return pick(candidates)
	return /datum/planet_type/lava

/// Skrzynia ze sprzętem trafia na okręt kapsułą zaopatrzeniową
/datum/overmap_objective/planet/proc/send_equipment()
	if(!length(equipment))
		return
	var/obj/structure/overmap/main_ship = SSstar_system.find_main_overmap()
	if(!main_ship)
		return
	var/obj/structure/closet/crate/crate = new
	crate.name = "skrzynia sprzętu: [name]"
	for(var/item_type in equipment)
		new item_type(crate)
	main_ship.send_supplypod(crate, null, TRUE)

/datum/overmap_objective/planet/proc/on_surface_ready(obj/structure/overmap/planet/planet, success)
	SIGNAL_HANDLER
	// Powierzchnia powstaje od nowa po każdym powrocie okrętu: zakończona misja nie stawia już schronu ani żyły
	if(success && status == STATUS_INPROGRESS)
		INVOKE_ASYNC(src, PROC_REF(setup_site))

/// Przygotowuje miejsce misji na świeżo zbudowanej powierzchni
/datum/overmap_objective/planet/proc/setup_site()
	return

/// Pole na powierzchni z dala od lądowisk (dla punktu badawczego i schronu). clearance: promień, w którym nie może
/// być pól ruin ani lądowisk (schron stawia szablon wokół pola)
/datum/overmap_objective/planet/proc/pick_site_turf(min_zone_distance = 20, clearance = 0)
	var/datum/planet_surface/surface = target_planet?.surface
	if(!surface)
		return
	var/list/inner = surface.inner_turfs()
	var/turf/fallback
	for(var/attempt in 1 to (clearance ? 150 : 50))
		var/turf/T = pick(inner)
		if(is_planet_hazard_turf(T) || T.loc != surface.surface_area || (T.flags_1 & NO_RUINS_1))
			continue
		if(clearance && !site_clear(surface, T, clearance))
			continue
		fallback = T
		var/far_enough = TRUE
		for(var/turf/zone as anything in surface.landing_zones)
			if(get_dist(zone, T) < min_zone_distance)
				far_enough = FALSE
				break
		if(far_enough)
			return T
	if(fallback)
		return fallback
	// Na małej planecie z dużą ilością lawy dobre pola to kilka procent powierzchni i losowe próby potrafiły nie trafić
	// w żadne (misja zostawała bez punktu): wtedy przegląd wszystkich pasujących pól w losowej kolejności
	var/list/candidates = list()
	for(var/turf/T as anything in inner)
		if(!is_planet_hazard_turf(T) && T.loc == surface.surface_area && !(T.flags_1 & NO_RUINS_1))
			candidates += T
	shuffle_inplace(candidates)
	for(var/turf/T as anything in candidates)
		if(!clearance || site_clear(surface, T, clearance))
			return T

/// Czy w promieniu radius od pola nie ma ruin, lądowisk ani krawędzi planety
/datum/overmap_objective/planet/proc/site_clear(datum/planet_surface/surface, turf/center, radius)
	for(var/turf/T as anything in RANGE_TURFS(radius, center))
		if(!surface.contains(T) || (T.flags_1 & NO_RUINS_1) || (T.loc != surface.surface_area && T.loc != surface.cave_area))
			return FALSE
	return TRUE

/datum/overmap_objective/planet/process(delta_time)
	if(status != STATUS_INPROGRESS)
		return PROCESS_KILL
	check_completion()

/// Misja wykonana: nagroda i zaliczenie bez czekania na okresowe sprawdzenie
/datum/overmap_objective/planet/proc/complete_mission()
	if(status != STATUS_INPROGRESS)
		return
	status = STATUS_COMPLETED
	SSeconomy.distribute_funds(payout)
	SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = research_payout))
	priority_announce("Zadanie na [target_planet] wykonane. [payout] kr rozdzielono między budżety działów, a dział badań dostał [research_payout] punktów.", "Dowództwo floty", SSstation.announcer.get_rand_report_sound())
	SSovermap_mode.update_reminder(objective = TRUE)
	if(SSovermap_mode.mode)
		INVOKE_ASYNC(SSovermap_mode.mode, TYPE_PROC_REF(/datum/overmap_gamemode, check_completion))

/// Czy przedmiot albo mob dotarł na okręt (a nie został na planecie)
/datum/overmap_objective/planet/proc/is_delivered(atom/movable/AM)
	var/obj/structure/overmap/main_ship = SSstar_system.find_main_overmap()
	return main_ship && AM.get_overmap() == main_ship

// Badanie planety: próbki i sonda

/datum/overmap_objective/planet/survey
	name = "Badanie planety"
	desc = "Zebrać z planety próbki skały, flory, fauny i atmosfery, dowieźć je na okręt i postawić sondę badawczą w punkcie badawczym."
	equipment = list(/obj/item/planet_sample_kit, /obj/item/planet_sample_kit, /obj/item/planet_survey_probe, /obj/item/gps/mining)
	var/obj/structure/planet_survey_site/site
	/// Sonda skończyła skan
	var/probe_done = FALSE
	/// Ile zapasowych sond już wysłano
	var/probes_resent = 0

/datum/overmap_objective/planet/survey/Destroy()
	QDEL_NULL(site)
	return ..()

/datum/overmap_objective/planet/survey/update_brief()
	brief = "Dowództwo chce zbadać [target_planet] w układzie [target_system]. Na pokład dotrze skrzynia ze sprzętem: zestawami do próbek, sondą badawczą i GPS. Zbierzcie z powierzchni próbki skały, flory, fauny i atmosfery i dowieźcie je na okręt. Punkt badawczy pojawi się na GPS po pierwszym lądowaniu: postawcie w nim sondę i brońcie jej przez [DisplayTimeText(PLANET_PROBE_SCAN_TIME)]. Nagroda: [payout] kr i [research_payout] punktów badań."

/datum/overmap_objective/planet/survey/setup_site()
	var/turf/T = pick_site_turf()
	if(T)
		site = new(T, src)

/datum/overmap_objective/planet/survey/check_completion()
	if(status != STATUS_INPROGRESS || !target_planet)
		return
	if(!probe_done)
		// Sonda (przedmiot albo rozłożona) przepadła: zniszczona, w lawie albo została na zwolnionej powierzchni
		if(!length(GLOB.planet_survey_probes))
			probe_lost()
		return
	var/list/delivered = list()
	for(var/obj/item/planet_sample/sample as anything in GLOB.planet_samples)
		if(sample.planet_ref == target_planet && is_delivered(sample))
			delivered |= sample.sample_type
	if(length(delivered) >= length(PLANET_SAMPLE_TYPES))
		complete_mission()

/// Bez sondy badania nie da się skończyć: dowództwo wysyła zapasową, a po kilku stratach misja przepada
/datum/overmap_objective/planet/survey/proc/probe_lost()
	if(probes_resent >= PLANET_SURVEY_PROBE_RESENDS)
		status = STATUS_FAILED
		priority_announce("Sonda badawcza na [target_planet] przepadła, a zapasowych już nie ma. Badanie się nie powiodło.", "Dowództwo floty")
		return
	var/obj/structure/overmap/main_ship = SSstar_system.find_main_overmap()
	if(!main_ship)
		return
	probes_resent++
	var/obj/structure/closet/crate/probe_crate = new
	probe_crate.name = "skrzynia: zapasowa sonda badawcza"
	new /obj/item/planet_survey_probe(probe_crate)
	main_ship.send_supplypod(probe_crate, null, TRUE)
	priority_announce("Sonda badawcza na [target_planet] przepadła. Dowództwo wysyła zapasową ([probes_resent] z [PLANET_SURVEY_PROBE_RESENDS]).", "Dowództwo floty")

/// Punkt badawczy: tu stawia się sondę (widać go na GPS)
/obj/structure/planet_survey_site
	name = "punkt badawczy"
	desc = "Boja z nadajnikiem wyznaczająca miejsce badań. Postaw sondę badawczą w pobliżu."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "tdoppler"
	anchored = TRUE
	density = FALSE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/datum/overmap_objective/planet/survey/mission

/obj/structure/planet_survey_site/Initialize(mapload, datum/overmap_objective/planet/survey/new_mission, gps_tag = "Punkt badawczy")
	. = ..()
	mission = new_mission
	AddComponent(/datum/component/gps, gps_tag)
	set_light(3, 1, LIGHT_COLOR_CYAN)

/obj/structure/planet_survey_site/Destroy()
	// Punkt znika razem z powierzchnią: misja nie może go trzymać (po powrocie setup_site stawia nowy)
	if(mission?.site == src)
		mission.site = null
	mission = null
	return ..()

/// Zestaw do próbek: działa tylko na powierzchni planety
/obj/item/planet_sample_kit
	name = "zestaw do pobierania próbek"
	desc = "Pojemniki i narzędzia do pobierania próbek z obcej planety. Użyj na skale, roślinie albo zwierzęciu na planecie, a w ręce pobierzesz próbkę atmosfery."
	icon = 'icons/obj/device.dmi'
	icon_state = "health"
	w_class = WEIGHT_CLASS_SMALL
	var/uses = 8

/obj/item/planet_sample_kit/examine(mob/user)
	. = ..()
	. += span_notice("Zostało pojemników: [uses].")

/obj/item/planet_sample_kit/attack_self(mob/user)
	take_sample(user, get_turf(user), PLANET_SAMPLE_ATMOSPHERE)

/obj/item/planet_sample_kit/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	var/sample_type
	if(istype(target, /turf/closed/mineral))
		sample_type = PLANET_SAMPLE_ROCK
	else if(istype(target, /obj/structure/flora))
		sample_type = PLANET_SAMPLE_FLORA
	else if(isanimal_or_basicmob(target))
		sample_type = PLANET_SAMPLE_FAUNA
	if(sample_type)
		take_sample(user, get_turf(target), sample_type)

/obj/item/planet_sample_kit/proc/take_sample(mob/user, turf/where, sample_type)
	var/obj/structure/overmap/planet/planet = get_planet_of(where)
	if(!planet)
		var/datum/turf_reservation/reservation = SSmapping.used_turfs[where]
		planet = reservation?.overmap_fallback
		if(!istype(planet) || planet.surface?.reservation != reservation)
			to_chat(user, span_warning("Tu nie ma czego badać: zestaw działa na powierzchni planety."))
			return
	if(uses <= 0)
		to_chat(user, span_warning("W zestawie nie ma już pustych pojemników."))
		return
	to_chat(user, span_notice("Pobierasz próbkę [planet_sample_name(sample_type)]..."))
	if(!do_after(user, 3 SECONDS, TRUE, where))
		return
	uses--
	var/obj/item/planet_sample/sample = new(get_turf(user), planet, sample_type)
	user.put_in_hands(sample)
	to_chat(user, span_notice("Masz próbkę [planet_sample_name(sample_type)] z [planet]."))

GLOBAL_LIST_EMPTY(planet_samples)
/// Sondy badawcze w grze (przedmioty i rozłożone): misja wie, kiedy sonda przepadła
GLOBAL_LIST_EMPTY(planet_survey_probes)

/obj/item/planet_sample
	name = "próbka"
	desc = "Szczelny pojemnik z próbką z obcej planety."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "beakerlarge"
	w_class = WEIGHT_CLASS_TINY
	var/obj/structure/overmap/planet/planet_ref
	var/sample_type

/obj/item/planet_sample/Initialize(mapload, obj/structure/overmap/planet/planet, new_sample_type)
	. = ..()
	planet_ref = planet
	sample_type = new_sample_type
	name = "próbka [planet_sample_name(sample_type)] ([planet])"
	GLOB.planet_samples += src

/obj/item/planet_sample/Destroy()
	GLOB.planet_samples -= src
	planet_ref = null
	return ..()

/// Sonda badawcza do rozłożenia w punkcie badawczym
/obj/item/planet_survey_probe
	name = "sonda badawcza"
	desc = "Składana sonda geologiczna. Rozłóż ją w punkcie badawczym na planecie i pilnuj, póki nie skończy skanu."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "tdoppler"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/planet_survey_probe/Initialize(mapload)
	. = ..()
	GLOB.planet_survey_probes += src

/obj/item/planet_survey_probe/Destroy()
	GLOB.planet_survey_probes -= src
	return ..()

/obj/item/planet_survey_probe/attack_self(mob/user)
	var/obj/structure/planet_survey_site/site = locate() in range(5, user)
	if(!site?.mission)
		to_chat(user, span_warning("Sondę stawia się w punkcie badawczym (pokazuje go GPS ze skrzyni)."))
		return
	to_chat(user, span_notice("Rozkładasz sondę..."))
	if(!do_after(user, 5 SECONDS, TRUE, get_turf(user)) || QDELETED(site))
		return
	new /obj/machinery/planet_survey_probe(get_turf(user), site.mission)
	qdel(src)

/obj/machinery/planet_survey_probe
	name = "sonda badawcza"
	desc = "Sonda skanuje skały pod powierzchnią. Pilnuj jej, póki nie skończy."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "tdoppler"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	max_integrity = 200
	var/datum/overmap_objective/planet/survey/mission
	var/scan_started = 0

/obj/machinery/planet_survey_probe/Initialize(mapload, datum/overmap_objective/planet/survey/new_mission)
	. = ..()
	GLOB.planet_survey_probes += src
	mission = new_mission
	scan_started = world.time
	START_PROCESSING(SSprocessing, src)
	set_light(3, 1, LIGHT_COLOR_CYAN)
	say("Sonda rozłożona. Skan potrwa [DisplayTimeText(PLANET_PROBE_SCAN_TIME)].")

/obj/machinery/planet_survey_probe/Destroy()
	GLOB.planet_survey_probes -= src
	mission = null
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/machinery/planet_survey_probe/examine(mob/user)
	. = ..()
	. += span_notice("Postęp skanu: [round(min(100, (world.time - scan_started) / PLANET_PROBE_SCAN_TIME * 100))]%.")

/obj/machinery/planet_survey_probe/process(delta_time)
	if(world.time < scan_started + PLANET_PROBE_SCAN_TIME)
		return
	say("Skan zakończony. Dane wysłane na okręt.")
	if(mission && !QDELETED(mission))
		mission.probe_done = TRUE
		mission.check_completion()
	return PROCESS_KILL

// Ewakuacja kolonii

/datum/overmap_objective/planet/evacuation
	name = "Ewakuacja kolonii"
	desc = "Dowieźć żywych kolonistów z planety na okręt."
	equipment = list(/obj/item/gps/mining, /obj/item/storage/firstaid/regular, /obj/item/tank/internals/emergency_oxygen/engi, /obj/item/tank/internals/emergency_oxygen/engi, /obj/item/clothing/mask/breath, /obj/item/clothing/mask/breath)
	var/list/mob/living/carbon/human/colonists = list()
	/// Schron już stoi
	var/colony_ready = FALSE
	/// Koloniści przepadli razem z powierzchnią po odlocie okrętu (a nie zginęli)
	var/colonists_abandoned = FALSE

/datum/overmap_objective/planet/evacuation/Destroy()
	colonists = null
	return ..()

/datum/overmap_objective/planet/evacuation/update_brief()
	brief = "Kolonia na [target_planet] w układzie [target_system] wzywa pomocy. Wylądujcie, odnajdźcie schron kolonistów (nadaje sygnał GPS „Schron kolonii”) i dowieźcie na okręt co najmniej [PLANET_COLONISTS_REQUIRED] z [PLANET_COLONISTS] kolonistów żywych. Nagroda: [payout] kr i [research_payout] punktów badań."

/datum/overmap_objective/planet/evacuation/setup_site()
	var/datum/map_template/shelter/alpha/shelter = new
	var/turf/T = pick_site_turf(clearance = round(max(shelter.width, shelter.height) / 2) + 1)
	if(!T)
		return
	var/datum/planet_surface/surface = target_planet.surface
	for(var/turf/area_turf as anything in shelter.get_affected_turfs(T, TRUE))
		if(!surface.contains(area_turf))
			continue
		if(is_planet_hazard_turf(area_turf))
			area_turf = surface.make_ground(area_turf)
		for(var/atom/movable/AM as anything in area_turf)
			if(isanimal_or_basicmob(AM) || istype(AM, /obj/structure/flora))
				qdel(AM)
	shelter.load(T, centered = TRUE)
	var/obj/structure/planet_survey_site/beacon = new(T, null, "Schron kolonii")
	beacon.name = "nadajnik schronu"
	beacon.desc = "Nadajnik wzywający pomocy dla kolonistów w schronie."
	var/list/spots = list()
	for(var/turf/open/floor/F in range(2, T))
		if(!is_blocked_turf(F, TRUE))
			spots += F
	for(var/i in 1 to PLANET_COLONISTS)
		var/turf/spot = length(spots) ? pick(spots) : T
		var/mob/living/carbon/human/ai_boarder/planet_colonist/colonist = new(spot)
		colonists += colonist
		RegisterSignal(colonist, COMSIG_PARENT_QDELETING, PROC_REF(on_colonist_deleted))
	colony_ready = TRUE
	INVOKE_ASYNC(src, PROC_REF(offer_colonists_to_ghosts))

/// Kolonista usunięty (np. razem z powierzchnią po odlocie okrętu: KNPC nie trzymają jej na mapie) nie zostaje na liście
/datum/overmap_objective/planet/evacuation/proc/on_colonist_deleted(mob/living/carbon/human/colonist)
	SIGNAL_HANDLER
	if(QDELETED(src) || !colonists)
		return
	colonists -= colonist
	if(target_planet && target_planet.surface?.state != PLANET_SURFACE_READY && !is_delivered(colonist))
		colonists_abandoned = TRUE

/// Duchy mogą przejąć kolonistów; reszta zostaje KNPC
/datum/overmap_objective/planet/evacuation/proc/offer_colonists_to_ghosts()
	var/list/candidates = pollGhostCandidates("Czy chcesz zagrać jako kolonista czekający na ewakuację z obcej planety?", ROLE_SENTIENCE, null, 20 SECONDS)
	for(var/mob/living/carbon/human/colonist as anything in colonists)
		if(!length(candidates))
			break
		if(QDELETED(colonist) || colonist.stat == DEAD || colonist.client)
			continue
		var/mob/dead/observer/candidate = pick_n_take(candidates)
		if(!candidate?.key)
			continue
		colonist.key = candidate.key
		to_chat(colonist, span_boldnotice("Jesteś kolonistą na wrogiej planecie. Załoga okrętu Nanotrasen leci po was: przeżyj, dołącz do niej i daj się zabrać na pokład. Pamiętaj o masce i butli: atmosfera planety nie nadaje się do oddychania."))

/datum/overmap_objective/planet/evacuation/check_completion()
	if(status != STATUS_INPROGRESS || !colony_ready)
		return
	var/alive = 0
	var/rescued = 0
	for(var/mob/living/carbon/human/colonist as anything in colonists)
		if(QDELETED(colonist) || colonist.stat == DEAD)
			continue
		alive++
		if(is_delivered(colonist))
			rescued++
	if(rescued >= PLANET_COLONISTS_REQUIRED)
		complete_mission()
	else if(alive < PLANET_COLONISTS_REQUIRED)
		status = STATUS_FAILED
		if(colonists_abandoned)
			priority_announce("Koloniści pozostawieni na [target_planet] przepadli, gdy okręt opuścił układ. Ewakuacja się nie powiodła.", "Dowództwo floty")
		else
			priority_announce("Za mało kolonistów z [target_planet] przeżyło. Ewakuacja się nie powiodła.", "Dowództwo floty")

/// Kolonista: idzie za najbliższym człowiekiem z załogi, nie walczy
/mob/living/carbon/human/ai_boarder/planet_colonist
	faction = list("neutral", "Nanotrasen")
	knpc_traits = KNPC_IS_DODGER | KNPC_IS_MERCIFUL
	outfit = list(/datum/outfit/planet_colonist)
	taunts = list("Nie strzelajcie!")
	call_lines = list("Pomocy!")
	response_lines = list("Idę za wami!")
	difficulty_override = TRUE

/datum/outfit/planet_colonist
	name = "Kolonista"
	uniform = /obj/item/clothing/under/rank/cargo/miner/lavaland
	suit = /obj/item/clothing/suit/hooded/explorer
	shoes = /obj/item/clothing/shoes/workboots/mining
	mask = /obj/item/clothing/mask/gas/explorer
	r_pocket = /obj/item/tank/internals/emergency_oxygen/engi
	// Butla podłączona od razu: KNPC bez plecaka sam jej nie włączy
	internals_slot = ITEM_SLOT_RPOCKET

/// Kolonista KNPC idzie za najbliższym człowiekiem z załogi (z umysłem), którego widzi
/datum/ai_goal/human/follow_rescuer
	name = "Follow rescuer"
	score = AI_SCORE_HIGH_PRIORITY

/datum/ai_goal/human/follow_rescuer/check_score(datum/component/knpc/HA)
	if(!..() || !istype(HA.parent, /mob/living/carbon/human/ai_boarder/planet_colonist))
		return 0
	return find_rescuer(HA) ? score : 0

/datum/ai_goal/human/follow_rescuer/proc/find_rescuer(datum/component/knpc/HA)
	var/mob/living/carbon/human/H = HA.parent
	var/mob/living/carbon/human/best
	var/best_dist = INFINITY
	for(var/mob/living/carbon/human/rescuer in view(HA.view_range, H))
		if(rescuer == H || !rescuer.mind || rescuer.stat != CONSCIOUS || istype(rescuer, /mob/living/carbon/human/ai_boarder))
			continue
		var/dist = get_dist(H, rescuer)
		if(dist < best_dist)
			best = rescuer
			best_dist = dist
	return best

/datum/ai_goal/human/follow_rescuer/action(datum/component/knpc/HA)
	if(!can_action(HA))
		return
	var/mob/living/carbon/human/H = HA.parent
	var/mob/living/carbon/human/rescuer = find_rescuer(HA)
	if(rescuer && get_dist(H, rescuer) > 2)
		HA.pathfind_to(rescuer)

#undef STATUS_INPROGRESS
#undef STATUS_COMPLETED
#undef STATUS_FAILED
#undef REMINDER_COMBAT_DELAY
#undef PLANET_SAMPLE_ROCK
#undef PLANET_SAMPLE_FLORA
#undef PLANET_SAMPLE_FAUNA
#undef PLANET_SAMPLE_ATMOSPHERE
#undef PLANET_SAMPLE_TYPES
#undef PLANET_PROBE_SCAN_TIME
#undef PLANET_SURVEY_PROBE_RESENDS
#undef PLANET_COLONISTS
#undef PLANET_COLONISTS_REQUIRED
