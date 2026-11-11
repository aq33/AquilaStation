// Kontroler wojny gangów: dochód z terenu co 15 s, przejęcie dowodzenia, zrzuty jak w Goonstation.
// Skrzynie z bronią: pierwsza po 15 min, potem co 20 min; wszystkie gangi słyszą o miejscu 5 min wcześniej.
// Skrzynię otwiera tylko szafka gangu, więc trzeba ją do niej dociągnąć; każdy członek dostaje 3000 pkt, co trzecia jest lepsza.
// Torby z łupem: pierwsze po 8 min, potem co 20 min, po dwie na gang; o miejscu wie tylko ten gang. Podniesienie daje 1000 pkt.

GLOBAL_DATUM(gang_controller, /datum/gang_controller)

/proc/aq_gang_controller()
	if(!GLOB.gang_controller)
		GLOB.gang_controller = new
	return GLOB.gang_controller

/datum/gang_controller
	/// Ile skrzyń już spadło
	var/crate_drops = 0
	/// Gdzie wyląduje następna skrzynia
	var/turf/pending_drop

/datum/gang_controller/New()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(territory_tick)), GANG_TERRITORY_INTERVAL, TIMER_LOOP)
	addtimer(CALLBACK(src, PROC_REF(warn_crate)), GANG_CRATE_FIRST_DROP - GANG_CRATE_WARNING)
	addtimer(CALLBACK(src, PROC_REF(drop_duffles)), GANG_DUFFLE_FIRST_DROP)

/datum/gang_controller/proc/territory_tick()
	aq_gang_territory_tick()
	for(var/datum/team/gang/G as anything in GLOB.gangs)
		G.check_takeover()

/datum/gang_controller/proc/message_all_gangs(message)
	for(var/datum/team/gang/G as anything in GLOB.gangs)
		G.message_gang(message)

/datum/gang_controller/proc/warn_crate()
	if(!length(GLOB.gangs))
		return
	pending_drop = get_safe_random_station_turfs()
	if(!pending_drop)
		addtimer(CALLBACK(src, PROC_REF(warn_crate)), 1 MINUTES)
		return
	message_all_gangs("<b>Za 5 minut przyleci zrzut broni:</b> [get_area_name(pending_drop)] (X [pending_drop.x], Y [pending_drop.y]). Kto pierwszy dociągnie skrzynię do swojej szafki, ten ją otworzy.")
	addtimer(CALLBACK(src, PROC_REF(remind_crate)), GANG_CRATE_WARNING - 30 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(land_crate)), GANG_CRATE_WARNING)

/datum/gang_controller/proc/remind_crate()
	if(pending_drop)
		message_all_gangs("<b>Zrzut broni za 30 sekund:</b> [get_area_name(pending_drop)] (X [pending_drop.x], Y [pending_drop.y]).")

/datum/gang_controller/proc/land_crate()
	var/turf/T = pending_drop
	pending_drop = null
	addtimer(CALLBACK(src, PROC_REF(warn_crate)), GANG_CRATE_INTERVAL - GANG_CRATE_WARNING)
	if(!T)
		return
	crate_drops++
	var/obj/structure/closet/supplypod/centcompod/pod = new
	new /obj/structure/closet/crate/secure/weapon/gang_drop(pod, crate_drops % 3 == 0)
	new /obj/effect/pod_landingzone(T, pod)
	log_game("Gang weapon drop #[crate_drops] sent to [AREACOORD(T)]")

/datum/gang_controller/proc/drop_duffles()
	addtimer(CALLBACK(src, PROC_REF(drop_duffles)), GANG_DUFFLE_INTERVAL)
	INVOKE_ASYNC(src, PROC_REF(hide_duffles))

/// Szuka zwykłych szafek na stacji (pętla po świecie raz na 20 minut, z CHECK_TICK) i chowa w nich torby
/datum/gang_controller/proc/hide_duffles()
	if(!length(GLOB.gangs))
		return
	var/list/closets = list()
	for(var/obj/structure/closet/C in world)
		if(C.type == /obj/structure/closet || istype(C, /obj/structure/closet/emcloset) || istype(C, /obj/structure/closet/firecloset) || istype(C, /obj/structure/closet/wardrobe))
			if(!C.opened && !C.locked && !C.welded && is_station_level(C.z))
				closets += C
		CHECK_TICK
	for(var/datum/team/gang/G as anything in GLOB.gangs)
		if(!length(G.members))
			continue
		for(var/i in 1 to GANG_DUFFLES_PER_GANG)
			var/atom/spot
			var/where
			if(length(closets) && prob(80))
				spot = pick_n_take(closets)
				where = "w szafce"
			else
				spot = get_safe_random_station_turfs()
				where = "na podłodze"
			if(!spot)
				continue
			new /obj/item/storage/backpack/duffelbag/gang_loot(spot)
			G.message_gang("Informator ukrył dla nas torbę z łupem [where]: [get_area_name(spot)]. Kto ją podniesie, ten zgarnie [GANG_DUFFLE_POINTS] pkt dla każdego z nas.")

///////////////////
// Skrzynia ze zrzutu
///////////////////

/obj/structure/closet/crate/secure/weapon/gang_drop
	name = "skrzynia ze zrzutu"
	desc = "Opancerzona skrzynia bez czytnika kart. Zamek ma gniazdo, które pasuje tylko do szafki gangu."
	/// Ktoś już otworzył skrzynię przy szafce
	var/claimed = FALSE
	/// Lepsza zawartość (co trzecia skrzynia)
	var/bonus = FALSE
	/// Do tej chwili zamek jest zablokowany po lądowaniu
	var/unlock_time = 0

/obj/structure/closet/crate/secure/weapon/gang_drop/Initialize(mapload, bonus = FALSE)
	src.bonus = bonus
	. = ..()
	unlock_time = world.time + 15 SECONDS + GANG_CRATE_LOCK_TIME

/obj/structure/closet/crate/secure/weapon/gang_drop/PopulateContents()
	new /obj/item/gun/ballistic/automatic/pistol(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/switchblade(src)
	new /obj/item/kitchen/knife/gang_throwing(src)
	new /obj/item/kitchen/knife/gang_throwing(src)
	new /obj/item/melee/baseball_bat(src)
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/storage/firstaid/shifty/battle(src)
	if(bonus)
		new /obj/item/gun/ballistic/automatic/mini_uzi(src)
		new /obj/item/ammo_box/magazine/uzim9mm(src)
		new /obj/item/ammo_box/magazine/uzim9mm(src)
		new /obj/item/katana/gang_cheap(src)

/obj/structure/closet/crate/secure/weapon/gang_drop/togglelock(mob/living/user, silent)
	if(user)
		to_chat(user, "<span class='warning'>Ten zamek nie ma czytnika kart. Otworzy go tylko szafka gangu.</span>")

/obj/structure/closet/crate/secure/weapon/gang_drop/can_open(mob/living/user)
	if(!claimed && !broken)
		if(world.time < unlock_time)
			if(user)
				to_chat(user, "<span class='warning'>Zamek jeszcze się nie zwolnił.</span>")
			return FALSE
		var/obj/structure/gang_locker/L
		for(var/obj/structure/gang_locker/nearby in range(1, src))
			if(!nearby.hidden)
				L = nearby
				break
		if(!L)
			if(user)
				to_chat(user, "<span class='warning'>Skrzynię otworzy tylko szafka gangu. Dociągnij ją do szafki.</span>")
			return FALSE
		if(!L.is_member(user))
			if(user)
				to_chat(user, "<span class='warning'>Szafka obok nie należy do twojego gangu.</span>")
			return FALSE
		claimed = TRUE
		locked = FALSE
		L.gang.add_income(GANG_CRATE_POINTS, GANG_SCORE_EVENT, user.mind)
		L.gang.message_gang("[user.real_name] otwiera zrzut przy szafce: każdy z nas dostaje [GANG_CRATE_POINTS] pkt!")
	return ..()

///////////////////
// Torba z łupem
///////////////////

/obj/item/storage/backpack/duffelbag/gang_loot
	name = "zapięta torba podróżna"
	desc = "Ciężka torba podróżna. Ktoś tu coś schował."
	/// Gang już zgarnął za nią punkty
	var/claimed = FALSE

/obj/item/storage/backpack/duffelbag/gang_loot/PopulateContents()
	new /obj/item/holochip(src, rand(3, 10) * 100)
	new /obj/item/kitchen/knife/gang_throwing(src)
	var/drug = pick(/obj/item/storage/pill_bottle/happy, /obj/item/storage/pill_bottle/zoom, /obj/item/storage/pill_bottle/happiness)
	new drug(src)

/obj/item/storage/backpack/duffelbag/gang_loot/pickup(mob/user)
	. = ..()
	if(claimed)
		return
	var/datum/antagonist/gang/GA = user.mind?.has_antag_datum(/datum/antagonist/gang)
	if(!GA?.gang)
		return
	claimed = TRUE
	GA.gang.add_income(GANG_DUFFLE_POINTS, GANG_SCORE_EVENT, user.mind)
	GA.gang.message_gang("[user.real_name] zgarnia torbę z łupem: każdy z nas dostaje [GANG_DUFFLE_POINTS] pkt.")
