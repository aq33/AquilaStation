// AQUILA - żyły rud do laserowego wiertła górniczego. Port z Shiptesta (AGPLv3): code/modules/mining/ore_veins.dm
// (/obj/structure/vein i podtypy planety lawowej) oraz wyrwa sejsmiczna z code/modules/mob_spawner/spawner.dm
// (/obj/effect/drill_spawner) z cząsteczkami /particles/smoke/drill_vent. Ikony są nasze: gejzer z
// icons/obj/lavaland/terrain.dmi, nora z icons/mob/nest.dmi.
// Wiertło na żyle co jakiś czas otwiera wokół niej wyrwy, z których przez kilkadziesiąt sekund wychodzi fauna planety
// (fale). Po waves_per_break falach z rzędu przychodzi przerwa.
// Zmiany względem Shiptesta:
// - tylko żyły planety wulkanicznej (klasy 1-3 i rzadkie odmiany); klasa 4 i żyły innych planet pominięte, bo mamy
//   tylko ten typ planety, a misja klasy 4 (industrial_drill.dm) nie jest portowana;
// - fauna to nasze basic moby: goliat z tg za goliath/beast/nest, pradawny goliat za goliath/beast/ancient, legion
//   i karłowaty legion w odmianie spawner_made (zostawiają zwęglony szkielet, jak legion/nest w Shiptest bez łupów),
//   brimdemon z shiptest_fauna/;
// - nasz komponent spawnera nie zna wag ani dźwięku wyjścia, więc robi to podtyp /datum/component/spawner/vein_breach;
//   moby pojawiają się na polu wyrwy (Shiptest: do 1 pola obok);
// - przerwa po serii fal trwa wave_downtime (w Shiptest odliczała wave_length, choć komunikat podawał wave_downtime);
// - wyrwy szukają miejsca tylko na powierzchni tej samej planety (planety dzielą poziom z w rezerwacji) i omijają lawę;
// - efekt zawalenia (dźwięk i komunikat) tylko przy wyczerpaniu żyły albo awarii wiertła, nie przy każdym usunięciu
//   (inaczej grzmiałby przy sprzątaniu powierzchni planety).

GLOBAL_LIST_EMPTY(ore_veins)

/obj/structure/vein
	name = "żyła rudy"
	desc = "Złoże rudy, w większości ukryte pod powierzchnią. Wydobędzie je laserowe wiertło górnicze."
	icon = 'icons/obj/lavaland/terrain.dmi'
	icon_state = "geyser"
	anchored = TRUE
	layer = LOW_ITEM_LAYER
	move_resist = INFINITY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// Czy skaner gruntu może ją namierzyć
	var/detectable = TRUE
	/// Ile razy wiertło wyciągnie z niej rudę (losowane ±2 przy tworzeniu)
	var/mining_charges = 6
	/// Klasa żyły (1-3): ile rodzajów rudy, ile rudy na cykl, ile wyrw naraz
	var/vein_class = 1
	/// Rudy, które mogą się w niej znaleźć (typ -> waga)
	var/list/ore_list = list(
		/obj/item/stack/ore/iron = 20,
		/obj/item/stack/ore/plasma = 20,
		)
	/// Wylosowane rudy (to pokazuje skaner); jeśli lista jest ustawiona z góry, nie jest losowana
	var/list/vein_contents = list()
	/// Mnożnik czasu jednego cyklu wiercenia
	var/mine_time_multiplier = 1
	/// Ile rudy wypada za jedno losowanie
	var/drop_rate_amount_min = 15
	var/drop_rate_amount_max = 20
	/// Ile mobów naraz może mieć jedna wyrwa
	var/max_mobs = 3
	/// Co ile wyrwa wypuszcza moba
	var/spawn_time = 10 SECONDS
	/// Fauna z wyrw (typ -> waga)
	var/list/mob_types = list(
		/mob/living/basic/mining/goliath = 60,
		/mob/living/basic/mining/legion/spawner_made = 20,
		/mob/living/basic/mining/brimdemon = 20,
		)
	var/spawn_text = "wyłania się z"
	var/list/faction = list("mining")
	var/spawn_sound = 'sound/effects/break_stone.ogg'
	/// W jakiej odległości od żyły otwierają się wyrwy
	var/spawn_distance_min = 4
	var/spawn_distance_max = 6
	/// Czy żyła właśnie otwiera wyrwy (wiertło pracuje)
	var/currently_spawning = FALSE
	/// Otwarte wyrwy
	var/list/obj/effect/drill_spawner/active_spawners = list()
	/// Ile fal z rzędu przed przerwą
	var/waves_per_break = 3
	/// Która fala z rzędu trwa
	var/wave_tally = 0
	/// Jak długo trwa fala (wyrwy żyją o 5 s krócej)
	var/wave_length = 45 SECONDS
	/// Jak długo trwa przerwa po serii fal
	var/wave_downtime = 1 MINUTES
	COOLDOWN_DECLARE(wave_timer)
	/// Wiertło, które jest na niej zamocowane
	var/obj/machinery/drill/our_drill

/obj/structure/vein/Initialize(mapload)
	. = ..()
	mining_charges = rand(round(mining_charges - 2), mining_charges + 2)
	if(!length(vein_contents))
		var/ore_type_amount
		switch(vein_class)
			if(1)
				ore_type_amount = rand(2, 6)
			if(2)
				ore_type_amount = rand(6, 10)
			if(3)
				ore_type_amount = rand(8, 14)
			if(4)
				ore_type_amount = rand(10, 18)
			else
				ore_type_amount = 1
		var/list/ore_pool = ore_list.Copy()
		for(var/ore_count in 1 to ore_type_amount)
			var/picked = pickweight(ore_pool)
			vein_contents += picked
			ore_pool -= picked
			if(!length(ore_pool))
				break
	GLOB.ore_veins += src

/obj/structure/vein/examine(mob/user)
	. = ..()
	. += span_notice("Klasa żyły: <b>[vein_class]</b>. Zawartość pokaże skaner gruntu przyłożony do żyły.")
	if(!detectable)
		. += span_notice("Żyła jest oznaczona jako bez znaczenia i nie pojawia się w skanach gruntu.")

/obj/structure/vein/Destroy()
	stop_spawning()
	for(var/obj/effect/drill_spawner/breach as anything in active_spawners)
		breach.our_vein = null
	active_spawners.Cut()
	GLOB.ore_veins -= src
	if(our_drill)
		var/obj/machinery/drill/drill = our_drill
		our_drill = null
		drill.on_vein_gone()
	return ..()

/obj/structure/vein/proc/begin_spawning()
	currently_spawning = TRUE
	START_PROCESSING(SSprocessing, src)

/obj/structure/vein/proc/stop_spawning()
	if(!currently_spawning)
		return TRUE
	currently_spawning = FALSE
	STOP_PROCESSING(SSprocessing, src)
	COOLDOWN_RESET(src, wave_timer)
	return FALSE

/obj/structure/vein/process(delta_time)
	if(!currently_spawning)
		return PROCESS_KILL
	try_spawning_spawner()

/// Otwiera nowe wyrwy, jeśli minęła fala (albo przerwa)
/obj/structure/vein/proc/try_spawning_spawner()
	if(!COOLDOWN_FINISHED(src, wave_timer))
		return
	COOLDOWN_START(src, wave_timer, wave_length)
	if(!increment_wave_tally())
		return
	var/breaches_to_spawn = max(1, vein_class - length(active_spawners))
	for(var/breach_index in 1 to breaches_to_spawn)
		if(length(active_spawners) >= vein_class)
			return
		var/turf/open/spawning_tile = pick_tile()
		if(!spawning_tile)
			return
		var/obj/effect/drill_spawner/bug_breach = new(spawning_tile, src, wave_length - 5 SECONDS)
		active_spawners += bug_breach

/// Wolne pole w pierścieniu spawn_distance_min..spawn_distance_max wokół żyły (na tej samej planecie)
/obj/structure/vein/proc/pick_tile()
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return
	var/datum/turf_reservation/our_reservation = SSmapping.used_turfs[our_turf]
	var/list/ring = list()
	var/list/fallback = list()
	for(var/turf/open/candidate in RANGE_TURFS(spawn_distance_max, our_turf))
		if(our_reservation && SSmapping.used_turfs[candidate] != our_reservation)
			continue
		if(is_blocked_turf(candidate, TRUE) || (locate(/obj/effect/drill_spawner) in candidate))
			continue
		fallback += candidate
		if(islava(candidate) || get_dist(our_turf, candidate) < spawn_distance_min)
			continue
		ring += candidate
	if(length(ring))
		return pick(ring)
	if(length(fallback))
		return pick(fallback)

/// Liczy fale z rzędu; FALSE oznacza przerwę
/obj/structure/vein/proc/increment_wave_tally()
	if(!our_drill?.active)
		wave_tally = 0
		return TRUE
	wave_tally += 1
	if(wave_tally > waves_per_break)
		wave_tally = 0
		COOLDOWN_START(src, wave_timer, wave_downtime)
		our_drill.say("Wstrząsy sejsmiczne słabną. Kolejne za około [drill_time_text(wave_downtime)].")
		return FALSE
	return TRUE

/// Wyrzuca rudę obok wiertła: vein_class losowań z zawartości żyły
/obj/structure/vein/proc/drop_ore(multiplier, obj/machinery/drill/current)
	var/list/adjacent_turfs = get_adjacent_open_turfs(current || src)
	var/turf/drop_location = length(adjacent_turfs) ? pick(adjacent_turfs) : get_turf(src)
	for(var/vein_content_count in 1 to vein_class)
		var/picked = pick(vein_contents)
		new picked(drop_location, round(rand(drop_rate_amount_min, drop_rate_amount_max) * multiplier, 1))

/// Żyła się zawala (wyczerpana albo po awarii wiertła)
/obj/structure/vein/proc/collapse()
	playsound(loc, 'sound/effects/explosionfar.ogg', 200, TRUE)
	visible_message(span_boldannounce("Żyła rudy się zawala!"))
	qdel(src)

/// Słowny opis zagrożenia dla skanera
/obj/structure/vein/proc/threat_text()
	switch(vein_class)
		if(1)
			return "minimalne"
		if(2)
			return "umiarkowane"
		if(3)
			return "poważne"
		if(4)
			return "EKSTREMALNE"
	return "nieznane"

// Podtypy planety wulkanicznej. Bilans Shiptesta, który sam zapowiada dalsze zmiany.

/obj/structure/vein/lavaland

/obj/structure/vein/lavaland/classtwo
	mining_charges = 8
	vein_class = 2
	ore_list = list(
		/obj/item/stack/ore/iron = 10,
		/obj/item/stack/ore/plasma = 10,
		/obj/item/stack/ore/gold = 1,
		)
	max_mobs = 2
	mob_types = list(
		/mob/living/basic/mining/goliath = 60,
		/mob/living/basic/mining/legion/spawner_made = 30,
		/mob/living/basic/mining/brimdemon = 20,
		/mob/living/basic/mining/goliath/ancient/immortal = 1,
		/mob/living/basic/mining/legion/dwarf/spawner_made = 5,
		)

/obj/structure/vein/lavaland/classtwo/rare
	ore_list = list(
		/obj/item/stack/ore/plasma = 20,
		/obj/item/stack/ore/gold = 20,
		/obj/item/stack/ore/diamond = 5,
		/obj/item/stack/ore/bluespace_crystal = 5,
		)

/obj/structure/vein/lavaland/classthree
	mining_charges = 10
	vein_class = 3
	ore_list = list(
		/obj/item/stack/ore/iron = 6,
		/obj/item/stack/ore/plasma = 6,
		/obj/item/stack/ore/gold = 1,
		)
	max_mobs = 3
	spawn_time = 8 SECONDS
	mob_types = list(
		/mob/living/basic/mining/goliath = 60,
		/mob/living/basic/mining/legion/spawner_made = 30,
		/mob/living/basic/mining/brimdemon = 20,
		/mob/living/basic/mining/goliath/ancient/immortal = 5,
		/mob/living/basic/mining/legion/dwarf/spawner_made = 10,
		)

/obj/structure/vein/lavaland/classthree/rare
	ore_list = list(
		/obj/item/stack/ore/plasma = 10,
		/obj/item/stack/ore/gold = 10,
		/obj/item/stack/ore/diamond = 8,
		/obj/item/stack/ore/bluespace_crystal = 5,
		)

/// Karłowaty legion z wyrwy: jak legion z wyrwy zostawia tylko zwęglony szkielet
/mob/living/basic/mining/legion/dwarf/spawner_made
	corpse_type = /obj/effect/mob_spawn/human/corpse/charredskeleton

// Wyrwa sejsmiczna: tymczasowy spawner fauny otwierany przez żyłę podczas wiercenia

/obj/effect/drill_spawner
	name = "wyrwa sejsmiczna"
	desc = "Świeże pęknięcie w gruncie, z którego wydostaje się rozwścieczona fauna."
	icon = 'icons/mob/nest.dmi'
	icon_state = "hole"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/obj/structure/vein/our_vein
	var/obj/effect/abstract/particle_holder/vent_smoke

/obj/effect/drill_spawner/Initialize(mapload, obj/structure/vein/new_vein, lifetime = 40 SECONDS)
	. = ..()
	our_vein = new_vein
	vent_smoke = new(src, /particles/smoke/drill_vent)
	if(our_vein)
		AddComponent(/datum/component/spawner/vein_breach, our_vein.mob_types, our_vein.spawn_time, our_vein.faction, our_vein.spawn_text, our_vein.max_mobs, our_vein.spawn_sound)
	QDEL_IN(src, lifetime)

/obj/effect/drill_spawner/Destroy()
	if(our_vein)
		our_vein.active_spawners -= src
		our_vein = null
	QDEL_NULL(vent_smoke)
	return ..()

/particles/smoke/drill_vent
	color = COLOR_YELLOW
	spawning = 2
	lifespan = 2.5 SECONDS
	fade = 1 SECONDS
	position = generator("sphere", 16, 24, NORMAL_RAND)

/// Spawner wyrwy: losuje moby z wagami i odtwarza dźwięk wyjścia
/datum/component/spawner/vein_breach
	/// Fauna (typ -> waga)
	var/list/weighted_mob_types
	var/spawn_sound

/datum/component/spawner/vein_breach/Initialize(_mob_types, _spawn_time, _faction, _spawn_text, _max_mobs, _spawn_sound)
	weighted_mob_types = _mob_types
	spawn_sound = _spawn_sound
	return ..(_mob_types, _spawn_time, _faction, _spawn_text, _max_mobs)

/datum/component/spawner/vein_breach/try_spawn_mob()
	if(length(weighted_mob_types))
		mob_types = list(pickweight(weighted_mob_types))
	var/mobs_before = length(spawned_mobs)
	. = ..()
	if(spawn_sound && length(spawned_mobs) > mobs_before)
		playsound(parent, spawn_sound, 50, TRUE)

/// Czas jako „M:SS” (Shiptest: time2text(czas, "mm:ss"))
/proc/drill_time_text(time_value)
	var/total_seconds = max(0, round(time_value / 10))
	var/seconds = total_seconds % 60
	return "[round(total_seconds / 60)]:[seconds < 10 ? "0" : ""][seconds]"
