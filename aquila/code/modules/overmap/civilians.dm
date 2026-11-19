/// AQUILA - cywile i rozpoznanie (plan walki na overmapie, etap E6).
/// - Ruch cywilny: w układach pojawiają się frachtowce (Nanotrasen i niezależne). Latają pasywnie, po kilku-kilkunastu
///   minutach skaczą dalej. AI Nanotrasen i SolGov ich nie atakuje (dla nich cywil nie jest celem), Syndykat i piraci tak.
/// - Rozpoznanie krokami: nierozpoznany kontakt pokazuje klasę wielkości, rozpoznany nadaje transponder IFF (nazwa, na
///   DRADIS kolor cywila), a z bliska (CIVILIAN_VISUAL_RANGE) albo po strzale wychodzi prawdziwa tożsamość.
/// - Fałszywy IFF: część wrogich okrętów nadaje cywilny transponder, dopóki nie strzeli albo nie zostanie obejrzana z bliska.
/// - Kary: trafienie własnego (Nanotrasen) albo neutralnego cywila przez okręt gracza ogłasza Centrala, a reputacja okrętu
///   u frakcji ofiary spada. Kupcy tej frakcji biorą wtedy drożej, a przy złej reputacji nie handlują. Wrogie transportowce
///   (cywile Syndykatu i piratów) się nie liczą.

#define CIVILIAN_COLOUR "#66ccff"
/// Z tej odległości (pola overmapy) widać okręt wzrokowo: fałszywy IFF przestaje działać
#define CIVILIAN_VISUAL_RANGE 8
#define CIVILIAN_ANNOUNCE_COOLDOWN (2 MINUTES)
/// Spadek reputacji za trafienie (raz na CIVILIAN_ANNOUNCE_COOLDOWN na statek) i za zniszczenie
#define CIVILIAN_HIT_STANDING 5
#define CIVILIAN_KILL_STANDING 30
/// Ile cywil zostaje w układzie, zanim skoczy dalej
#define CIVILIAN_STAY_MIN (8 MINUTES)
#define CIVILIAN_STAY_MAX (14 MINUTES)
/// Zniszczenie liczy się na konto gracza, jeśli trafił cywila w tym czasie przed śmiercią
#define CIVILIAN_KILL_CREDIT_TIME (30 SECONDS)

/// Szansa (%), że wrogi okręt AI nadaje fałszywy cywilny IFF (w testach 0, żeby nazwy były przewidywalne)
#ifdef UNIT_TESTS
GLOBAL_VAR_INIT(civilian_fake_iff_chance, 0)
#else
GLOBAL_VAR_INIT(civilian_fake_iff_chance, 15)
#endif

/// Reputacja okrętu gracza u frakcji (100 = neutralnie, poniżej 0 kupcy nie handlują, powyżej zniżki: trader_reputation.dm).
/// Wpisy innych frakcji powstają przy pierwszej misji ich stacji.
GLOBAL_LIST_INIT(civilian_standing, list("nanotrasen" = 100, "unaligned" = 100))

/// Nazwy, pod którymi wróg z fałszywym IFF udaje cywila
GLOBAL_LIST_INIT(civilian_fake_iff_names, list("frachtowiec niezależny", "transportowiec pasażerski", "statek górniczy"))

/obj/structure/overmap
	/// AQUILA - cywilny statek (kary za ostrzał, AI Nanotrasen go nie atakuje)
	var/civilian = FALSE
	/// AQUILA - nazwa z fałszywego cywilnego transpondera IFF; null = prawdziwy IFF
	var/fake_iff_name
	/// AQUILA - cywil: kiedy znowu wolno ogłosić ostrzał i obniżyć reputację
	var/civilian_next_penalty = 0
	/// AQUILA - cywil: okręt gracza, który ostatnio go trafił, i kiedy
	var/datum/weakref/civilian_last_attacker
	var/civilian_last_hit = 0

// ---- Cywilne statki ----

/obj/structure/overmap/nanotrasen/mining_cruiser/aquila_hex_freighter/civilian
	name = "frachtowiec Nanotrasen"
	desc = "Powolny frachtowiec Nanotrasen w rejsie handlowym. Ma tylko działka obrony punktowej i ucieka przed walką."
	civilian = TRUE
	ai_behaviour = AI_PASSIVE

/obj/structure/overmap/nanotrasen/mining_cruiser/aquila_hex_freighter/civilian/independent
	name = "frachtowiec niezależny"
	desc = "Frachtowiec niezależnego armatora. Nie należy do żadnej floty, wozi ładunki między stacjami handlowymi."
	faction = "unaligned"

/obj/structure/overmap/nanotrasen/mining_cruiser/aquila_hex_freighter/civilian/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(civilian_depart)), rand(CIVILIAN_STAY_MIN, CIVILIAN_STAY_MAX))

/// Cywil skacze dalej, chyba że właśnie oberwał (wtedy próbuje za minutę)
/obj/structure/overmap/proc/civilian_depart()
	if(QDELETED(src))
		return
	if(world.time < civilian_last_hit + 1 MINUTES)
		addtimer(CALLBACK(src, PROC_REF(civilian_depart)), 1 MINUTES)
		return
	if(z)
		visible_message("<span class='notice'>[src] rozkręca napęd FTL i znika.</span>")
	qdel(src)

/obj/structure/overmap/Initialize(mapload)
	. = ..()
	if(ai_controlled && !civilian && (faction == "syndicate" || faction == "pirate") && !istype(src, /obj/structure/overmap/small_craft) && mass >= MASS_SMALL && prob(GLOB.civilian_fake_iff_chance))
		fake_iff_name = pick(GLOB.civilian_fake_iff_names)

/// Czy okręt wygląda na cywila (prawdziwy cywil albo fałszywy IFF, którego jeszcze nikt nie zdemaskował)
/obj/structure/overmap/proc/looks_civilian()
	return civilian || fake_iff_name

/// Demaskuje fałszywy IFF: od teraz wszyscy widzą prawdziwą nazwę
/obj/structure/overmap/proc/reveal_fake_iff(reason)
	if(!fake_iff_name)
		return
	var/old_name = fake_iff_name
	fake_iff_name = null
	for(var/obj/structure/overmap/OM as anything in current_system?.system_contents)
		if(!OM.ai_controlled && length(OM.linked_areas) && OM.z == z)
			OM.relay('nsv13/sound/effects/ship/freespace2/computer/escape.wav', "<span class='warning'>Rozpoznanie: „[old_name]” nadawał fałszywy transponder IFF ([reason]). To [name]!</span>")

// Wróg z fałszywym IFF zdradza się strzałem
/obj/structure/overmap/fire_projectile(proj_type, atom/target, pixel_speed = null, user_override = null, firing_flags = NONE, ai_aim = FALSE, miss_chance = 5, max_miss_distance = 5, spread_override = null, projectile_speed = null)
	if(fake_iff_name)
		reveal_fake_iff("otworzył ogień")
	return ..()

// ---- Rozpoznanie krokami ----

/// Klasa wielkości kontaktu, którą da się podać przed rozpoznaniem
/proc/contact_size_class(obj/structure/overmap/target)
	if(target.mass <= MASS_TINY)
		return "bardzo mały"
	if(target.mass <= MASS_MEDIUM_SMALL)
		return "mały"
	if(target.mass <= MASS_MEDIUM_LARGE)
		return "średni"
	return "duży"

/obj/structure/overmap/get_contact_label(obj/structure/overmap/target, identified)
	if(!identified)
		return "[..()] ([contact_size_class(target)])"
	if(target.fake_iff_name)
		if(!ai_controlled && overmap_dist(src, target) <= CIVILIAN_VISUAL_RANGE)
			target.reveal_fake_iff("identyfikacja wzrokowa")
		else
			return target.fake_iff_name
	return ..()

// DRADIS: rozpoznany cywil (albo wróg z fałszywym IFF) ma kolor cywila i nazwę z transpondera
/obj/machinery/computer/ship/dradis/ui_data(mob/user)
	. = ..()
	var/list/data = .
	if(!linked)
		return
	for(var/list/blip as anything in data["ships"])
		var/obj/structure/overmap/OM = locate(blip["id"])
		if(!istype(OM) || OM == linked || !OM.looks_civilian() || !linked.is_contact_identified(OM, sensor_range))
			continue
		blip["colour"] = CIVILIAN_COLOUR
		blip["alignment"] = "unaligned"
		blip["name"] = linked.get_contact_label(OM, TRUE)

// AI Nanotrasen i SolGov nie bierze cywilów na cel (seek_new_target wymaga SENSOR_VISIBILITY_TARGETABLE)
/obj/structure/overmap/is_sensor_visible(obj/structure/overmap/observer)
	. = ..()
	if(civilian && observer?.ai_controlled && !civilian_hunter(observer))
		return min(., SENSOR_VISIBILITY_FAINT)

/// Czy AI tego okrętu poluje na cywilów (Syndykat i piraci)
/proc/civilian_hunter(obj/structure/overmap/observer)
	return observer.faction == "syndicate" || observer.faction == "pirate"

// ---- Kary za ostrzał cywilów ----

/// Okręt gracza, za którego strzały odpowiada załoga (okręt główny, inne okręty z wnętrzem, pilotowane myśliwce)
/obj/structure/overmap/proc/is_crewed_nanotrasen()
	return faction == "nanotrasen" && !ai_controlled

/// Czy trafienie tego cywila się liczy (własny Nanotrasen albo neutralny; wrogie transportowce nie)
/obj/structure/overmap/proc/civilian_counts()
	return civilian && (faction == "nanotrasen" || faction == "unaligned")

/obj/structure/overmap/bullet_act(obj/item/projectile/P)
	var/obj/structure/overmap/shooter = P?.overmap_firer
	var/mob/gunner_mob = ismob(P?.firer) ? P.firer : null
	. = ..()
	if(civilian_counts() && istype(shooter) && shooter.is_crewed_nanotrasen() && !QDELETED(src))
		civilian_hit_by(shooter, gunner_mob)

/// Trafienie cywila przez okręt gracza: ogłoszenie Centrali, wpis w logach i spadek reputacji (z przerwą między karami)
/obj/structure/overmap/proc/civilian_hit_by(obj/structure/overmap/shooter, mob/gunner_mob)
	civilian_last_attacker = WEAKREF(shooter)
	civilian_last_hit = world.time
	var/who = gunner_mob ? key_name(gunner_mob) : "brak strzelca"
	log_game("[shooter] ([who]) hit civilian ship [src] ([faction])")
	if(world.time < civilian_next_penalty)
		return
	civilian_next_penalty = world.time + CIVILIAN_ANNOUNCE_COOLDOWN
	adjust_civilian_standing(faction, -CIVILIAN_HIT_STANDING)
	message_admins("[shooter] ostrzelał cywilny statek [src] ([faction]). Strzelec: [gunner_mob ? key_name_admin(gunner_mob) : "brak"].")
	var/owners = faction == "nanotrasen" ? "własnych armatorów" : "niezależnych kupców"
	priority_announce("[shooter] ostrzelał cywilny statek [src]. Ostrzał cywilów łamie zasady walki i szkodzi reputacji Nanotrasen u [owners]. Natychmiast przerwać ogień.", "Centrala Nanotrasen")

/obj/structure/overmap/obj_destruction(damage_flag)
	if(civilian_counts() && world.time < civilian_last_hit + CIVILIAN_KILL_CREDIT_TIME)
		var/obj/structure/overmap/shooter = civilian_last_attacker?.resolve()
		if(shooter)
			adjust_civilian_standing(faction, -CIVILIAN_KILL_STANDING)
			message_admins("[shooter] zniszczył cywilny statek [src] ([faction]).")
			log_game("[shooter] destroyed civilian ship [src] ([faction])")
			var/owners = faction == "nanotrasen" ? "armatorzy Nanotrasen" : "niezależni kupcy"
			priority_announce("[shooter] zniszczył cywilny statek [src]. Centrala odnotowuje incydent w aktach okrętu, a [owners] tracą do was zaufanie.", "Centrala Nanotrasen")
	return ..()

/proc/adjust_civilian_standing(faction_key, delta)
	if(isnull(GLOB.civilian_standing[faction_key]))
		return
	GLOB.civilian_standing[faction_key] = clamp(GLOB.civilian_standing[faction_key] + delta, -100, 250)

// ---- Reputacja u kupców ----

/// Klucz reputacji dla frakcji kupca (te same nazwy co frakcje okrętów cywilnych)
/datum/trader/proc/civilian_standing_key()
	switch(faction_type)
		if(FACTION_ID_NT)
			return "nanotrasen"
		if(FACTION_ID_UNALIGNED)
			return "unaligned"
		if(FACTION_ID_SYNDICATE)
			return "syndicate"
		if(FACTION_ID_SOLGOV)
			return "solgov"
		if(FACTION_ID_UNATHI)
			return "unathi"
		if(FACTION_ID_PIRATES)
			return "pirate"
	return null

/// Narzut za złą reputację: neutralna i wyższa 1, zero reputacji 1,5 (zniżki za dobrą: trader_reputation.dm)
/datum/trader/proc/civilian_price_mult()
	var/key = civilian_standing_key()
	if(!key || isnull(GLOB.civilian_standing[key]))
		return 1
	var/standing = GLOB.civilian_standing[key]
	return standing >= 100 ? 1 : 1 + (100 - max(standing, 0)) / 200

/datum/trader/proc/refuses_trade()
	var/key = civilian_standing_key()
	return key && !isnull(GLOB.civilian_standing[key]) && GLOB.civilian_standing[key] < 0

// Cena z narzutem i zniżką liczy aq_price() (trader_reputation.dm)
/datum/trader/attempt_purchase(datum/trader_item/item, mob/living/carbon/user)
	if(refuses_trade())
		to_chat(user, "<span class='warning'>[name] odmawia handlu: wasz okręt strzela do cywilów.</span>")
		return FALSE
	return ..()

// ---- Ruch cywilny w układach ----

/datum/star_system
	/// AQUILA - ruch cywilny już rozmieszczony
	var/civilians_generated = FALSE

/// Szansa (%) na cywilny ruch w układzie
/datum/star_system/proc/civilian_traffic_chance()
	if(istype(src, /datum/star_system/random/hex_empty))
		return 25
	switch(alignment)
		if("unaligned", "uncharted")
			return 60
		if("nanotrasen", "solgov")
			return 50
		if("syndicate")
			return 15
		if("pirate")
			return 10
	return 30

/// Rozmieszcza 1-2 cywilne frachtowce (raz na układ); zwraca liczbę
/datum/star_system/proc/spawn_civilian_traffic()
	if(civilians_generated)
		return 0
	civilians_generated = TRUE
	if(!prob(civilian_traffic_chance()))
		return 0
	var/amount = rand(1, 2)
	for(var/i in 1 to amount)
		var/nt_share = (alignment == "nanotrasen" || alignment == "solgov") ? 60 : 20
		var/civ_type = prob(nt_share) ? /obj/structure/overmap/nanotrasen/mining_cruiser/aquila_hex_freighter/civilian : /obj/structure/overmap/nanotrasen/mining_cruiser/aquila_hex_freighter/civilian/independent
		SSstar_system.spawn_ship(civ_type, src)
	return amount

/datum/star_system/apply_system_effects()
	. = ..()
	spawn_civilian_traffic()

/datum/star_system/random/hex_empty/apply_hex_terrain()
	. = ..()
	spawn_civilian_traffic()

// Pusty kafel bez nikogo zwalnia się razem ze swoim tłem (cywile, strefy zagrożeń): inaczej nigdy by się nie zwolnił.
// Przy ponownym wejściu na kafel tło losuje się od nowa (apply_hex_terrain). Wrak, flota albo inna rzecz zostawia wszystko.
/datum/star_system/random/hex_empty/try_release()
	if(!occupying_z)
		release_ambient_contents()
	return ..()

/datum/star_system/random/hex_empty/proc/release_ambient_contents()
	var/list/ambient = list()
	for(var/atom/movable/A as anything in system_contents)
		var/obj/structure/overmap/OM = A
		if(istype(A, /obj/effect/overmap_anomaly/hazard) || (istype(OM) && OM.civilian))
			ambient += A
		else
			return
	// Cywile niewczytanego układu czekają w enemy_queue jako typy (spawn_ship), dopiero przy wejściu stają się okrętami
	var/list/queued_civilians = list()
	for(var/entry in enemy_queue)
		var/obj/structure/overmap/queued = entry
		if(ispath(entry, /obj/structure/overmap) && initial(queued.civilian))
			queued_civilians += entry
		else
			return
	enemy_queue -= queued_civilians
	for(var/atom/movable/A as anything in ambient)
		system_contents -= A
		qdel(A)

#undef CIVILIAN_COLOUR
#undef CIVILIAN_VISUAL_RANGE
#undef CIVILIAN_ANNOUNCE_COOLDOWN
#undef CIVILIAN_HIT_STANDING
#undef CIVILIAN_KILL_STANDING
#undef CIVILIAN_STAY_MIN
#undef CIVILIAN_STAY_MAX
#undef CIVILIAN_KILL_CREDIT_TIME
