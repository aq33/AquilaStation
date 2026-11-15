// AQUILA - atomówka i DEFCON (raport/ftl_mapa_06_plan_pr.md, część E). Decyzje 14.11:
// - torpeda termojądrowa ładowana do zwykłej wyrzutni i VLS (taktycznie: ogromne obrażenia + nuclear_impact() w środku okrętu),
//   a z konsoli nawigacji strzał strategiczny w kafel w zasięgu 9, gdy atomówka leży w wyrzutni i DEFCON <= 2;
// - pocisk strategiczny leci po kaflach, śledzi cel, floty wroga po drodze mogą go zestrzelić; w kaflu okrętu gracza
//   zamienia się w prawdziwą torpedę z krawędzi overmapy (PD i flak mogą ją zestrzelić) z komunikatem z simulate_nuke();
// - DEFCON 5–1 z napięcia wojny; AI (NT, SolGov, Syndykat) odpala od DEFCON 2, zapasy po 1; każde odpalenie = DEFCON 1;
// - jedna atomówka na rundę w zamkniętej skrzyni przy wyrzutni (dostęp kapitana albo XO); kolejne ze stacji i misji (część F).

/obj/item/ship_weapon/ammunition/torpedo/nuke
	name = "\improper termojądrowa torpeda NTNK „Nadchodząca Burza” 700 mm"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "nuke"
	desc = "Torpeda klasy NTX IV z ładunkiem termojądrowym. Niszczy okręty, stacje i całe floty bez wybierania celów. Z konsoli nawigacji można ją wystrzelić w odległy kafel, gdy DEFCON spadnie do 2."
	projectile_type = /obj/item/projectile/guided_munition/torpedo/nuclear
	volatility = 3

/obj/item/projectile/guided_munition/torpedo/nuclear
	icon_state = "torpedo_nuke"
	name = "torpeda termojądrowa"
	damage = 1200
	obj_integrity = 60
	max_integrity = 60
	impact_effect_type = /obj/effect/temp_visual/nuke_impact
	shotdown_effect_type = /obj/effect/temp_visual/nuke_impact

/obj/item/projectile/guided_munition/torpedo/nuclear
	/// Frakcja pocisku strategicznego, który zszedł do walki taktycznej (hex_incoming_nuke); zwykła torpeda: null
	var/hex_strategic_faction

/obj/item/projectile/guided_munition/torpedo/nuclear/spec_overmap_hit(obj/structure/overmap/target)
	if(length(target.occupying_levels) || length(target.mobs_in_ship))
		target.nuclear_impact()
	hex_detonate(target.current_hex())

/// Skutki na mapie po trafieniu. Pocisk strategiczny dopiero teraz robi to, co robiłby w kaflu bez okrętu gracza
/// (floty, skażenie); zestrzelony nie robi nic. Zwykła torpeda podnosi tylko napięcie i DEFCON.
/obj/item/projectile/guided_munition/torpedo/nuclear/proc/hex_detonate(datum/hex/where)
	if(hex_strategic_faction && where)
		hex_nuke_blast(where, hex_strategic_faction)
		return
	GLOB.hex_war?.nuclear_detonation(where)

/obj/structure/closet/crate/secure/weapon/aquila_nuke
	name = "skrzynia z atomówką"
	desc = "Opancerzona skrzynia z jedną torpedą termojądrową. Otwiera ją dostęp kapitana albo pierwszego oficera."
	req_access = null
	req_one_access = list(ACCESS_CAPTAIN, ACCESS_HOP)

/obj/structure/closet/crate/secure/weapon/aquila_nuke/PopulateContents()
	new /obj/item/ship_weapon/ammunition/torpedo/nuke(src)

/// Na starcie rundy: skrzynia z atomówką przy wyrzutni torped okrętu gracza
/proc/hex_spawn_nuke_crate()
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	if(!main)
		return
	var/list/launchers = list()
	for(var/obj/machinery/ship_weapon/W in GLOB.machines)
		if((istype(W, /obj/machinery/ship_weapon/torpedo_launcher) || istype(W, /obj/machinery/ship_weapon/vls)) && W.get_overmap() == main)
			launchers += W
	for(var/obj/machinery/ship_weapon/W as anything in shuffle(launchers))
		for(var/turf/open/T in range(3, W))
			if(isspaceturf(T) || is_blocked_turf(T, TRUE))
				continue
			new /obj/structure/closet/crate/secure/weapon/aquila_nuke(T)
			log_game("HEXWAR: the round's nuclear torpedo crate was placed at [AREACOORD(T)]")
			return

/datum/hex_war
	/// Napięcie wojny: rośnie z bitew, zniszczonych flot, okupacji i napadów, co turę spada
	var/tension = 0
	var/defcon = 5
	/// Po każdym odpaleniu DEFCON 1 do tej chwili
	var/defcon_lock_until = 0
	var/list/nuke_stocks = list("nanotrasen" = 1, "solgov" = 1, "syndicate" = 1)
	/// Kiedy frakcja złożyła ostatnią atomówkę (HEX_WAR_NUKE_COOLDOWN)
	var/list/nuke_built_at = list()
	/// Pociski strategiczne w locie
	var/list/missiles = list()
	/// Zajęte układy w poprzedniej turze (nowe okupacje podnoszą napięcie)
	var/list/occupied_last = list()

/datum/hex_war/proc/add_tension(amount)
	tension += amount

/// Napięcie z tej tury, DEFCON i decyzje AI o atomówkach (wołane w run_turn)
/datum/hex_war/proc/nuclear_turn()
	add_tension(length(SSstar_system.contested_systems))
	var/list/occupied = list()
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(S.hex && (S.owner in GLOB.hex_war_factions) && hex_factions_hostile(S.owner, S.alignment))
			occupied += S.name
			if(!(S.name in occupied_last))
				add_tension(2)
	occupied_last = occupied
	tension *= 0.75
	update_defcon()
	if(defcon > 2)
		return
	for(var/faction in nuke_stocks)
		if(nuke_stocks[faction] > 0 && prob(defcon == 1 ? 5 : 2))
			ai_launch(faction)

/datum/hex_war/proc/update_defcon()
	var/old = defcon
	if(world.time < defcon_lock_until)
		defcon = 1
	else if(tension >= 22)
		defcon = 2
	else if(tension >= 13)
		defcon = 3
	else if(tension >= 6)
		defcon = 4
	else
		defcon = 5
	if(defcon == old)
		return
	log_game("HEXWAR: DEFCON [old] -> [defcon] (tension [round(tension, 0.1)])")
	if(defcon < old && defcon <= 3)
		priority_announce("Stan gotowości sektora: DEFCON [defcon]. [defcon <= 2 ? "Strony konfliktu mogą użyć broni jądrowej." : "Napięcie między frakcjami rośnie."]", "Dowództwo Floty White Rapids")
	else
		minor_announce("Stan gotowości sektora: DEFCON [defcon].", "Dowództwo Floty White Rapids")

/// Każda detonacja jądrowa: DEFCON 1 na HEX_WAR_DEFCON_LOCK
/datum/hex_war/proc/nuclear_detonation(datum/hex/where)
	tension = max(tension, 30)
	defcon_lock_until = world.time + HEX_WAR_DEFCON_LOCK
	update_defcon()

/// AI wybiera cel: najliczniejsza wroga flota albo okręt gracza w zasięgu 9 kafli od układu frakcji
/datum/hex_war/proc/ai_launch(faction)
	var/list/sites = list()
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(S.hex && S.owner == faction && !hex_factions_hostile(faction, S.alignment))
			sites += S
	if(!length(sites))
		return
	var/best_score = 0
	var/datum/star_system/best_site
	var/datum/fleet/best_fleet
	var/obj/structure/overmap/best_ship
	var/obj/structure/overmap/player = SSstar_system.find_main_overmap()
	var/datum/hex/player_hex = player?.current_hex()
	for(var/datum/star_system/site as anything in sites)
		if(player_hex && hex_factions_hostile(faction, player.faction) && GLOB.hexmap.war_distance(site.hex, player_hex) <= 9 && 4 > best_score)
			best_score = 4
			best_site = site
			best_ship = player
			best_fleet = null
		for(var/datum/fleet/F as anything in hex_all_fleets())
			if(F.war_cargo || !hex_factions_hostile(faction, F.alignment) || !F.current_system?.hex)
				continue
			var/ships = F.hex_war_ship_count()
			if(ships > best_score && GLOB.hexmap.war_distance(site.hex, F.current_system.hex) <= 9)
				best_score = ships
				best_site = site
				best_fleet = F
				best_ship = null
	if(!best_site || best_score < 3)
		return
	nuke_stocks[faction]--
	launch_missile(faction, best_site.hex, best_fleet, best_ship)

/datum/hex_war/proc/launch_missile(faction, datum/hex/from, datum/fleet/target_fleet, obj/structure/overmap/target_ship, datum/hex/target_hex)
	var/datum/hex_nuke/N = new
	N.faction = faction
	N.hex = from
	N.target_fleet = target_fleet
	N.target_ship = target_ship
	N.target_hex = target_hex || target_fleet?.current_system?.hex || target_ship?.current_hex()
	N.trail = list(from.id)
	missiles += N
	nuclear_detonation_warning(N)
	addtimer(CALLBACK(N, TYPE_PROC_REF(/datum/hex_nuke, advance)), 30 SECONDS)
	log_game("HEXWAR: [faction] launches a nuclear missile from [from.id] at [N.target_hex?.id]")
	return N

/// Odpalenie: DEFCON 1 od razu, ogłoszenie dla całego sektora
/datum/hex_war/proc/nuclear_detonation_warning(datum/hex_nuke/N)
	defcon_lock_until = world.time + HEX_WAR_DEFCON_LOCK
	tension = max(tension, 30)
	update_defcon()
	var/target_name = N.target_hex?.display_name() || "nieznany" // osobny literał: generator słownika nie rozpoznaje || we wstawce
	priority_announce("Wykryto odpalenie pocisku termojądrowego ([hex_war_faction_name(N.faction)]) w [N.hex.display_name()]. Cel: [target_name].", "Dowództwo Floty White Rapids", 'nsv13/sound/effects/ship/incoming_missile.ogg')

/datum/hex_nuke
	var/faction
	var/datum/hex/hex
	var/datum/fleet/target_fleet
	var/obj/structure/overmap/target_ship
	var/datum/hex/target_hex
	var/list/trail
	var/warned = FALSE

/datum/hex_nuke/proc/destination()
	if(target_fleet && !QDELETED(target_fleet) && target_fleet.current_system?.hex)
		target_hex = target_fleet.current_system.hex
	else if(target_ship && !QDELETED(target_ship) && target_ship.current_hex())
		target_hex = target_ship.current_hex()
	return target_hex

/datum/hex_nuke/proc/advance()
	var/datum/hex/dest = destination()
	if(!dest || !hex)
		finish()
		return
	if(hex != dest)
		var/list/route = GLOB.hexmap.route(hex, dest, null, 5000)
		if(!route)
			finish()
			return
		var/list/full = route["full"]
		var/datum/hex/next = full[2]
		// Floty wroga po drodze próbują zestrzelić pocisk
		for(var/datum/fleet/F as anything in next.system?.fleets)
			if(!QDELETED(F) && !F.war_cargo && hex_factions_hostile(faction, F.alignment) && prob(25))
				mini_announce("Flota [F.name] zestrzeliła pocisk termojądrowy w [next.display_name()].", "White Rapids EAS")
				log_game("HEXWAR: [F.name] shot down a nuclear missile at [next.id]")
				finish()
				return
		hex = next
		trail += next.id
	var/obj/structure/overmap/player = SSstar_system.find_main_overmap()
	var/datum/hex/player_hex = player?.current_hex()
	if(!warned && player_hex && hex_factions_hostile(faction, player.faction) && (target_ship == player || dest == player_hex) && GLOB.hexmap.war_distance(hex, player_hex) <= 2)
		warned = TRUE
		player.relay('nsv13/sound/effects/ship/incoming_missile.ogg', message = "<h1>Nieuchronne trafienie pociskiem</h1><br/><span class='danger'>Wykryto odpalenie głowicy termojądrowej. Cała załoga, przygotować się na uderzenie.</span>")
	if(hex == dest)
		impact(player, player_hex)
		return
	addtimer(CALLBACK(src, PROC_REF(advance)), 30 SECONDS)

/// Wybuch w kaflu: floty tracą okręty (3 w kaflu, 1 obok), pusty kafel zostaje skażony; okręt gracza dostaje prawdziwą torpedę
/datum/hex_nuke/proc/impact(obj/structure/overmap/player, datum/hex/player_hex)
	// Tylko wrogi pocisk schodzi do walki taktycznej z okrętem gracza. Własny pocisk gracza (śledzi flotę celu, która
	// mogła wejść w jego kafel) wybucha strategicznie: niszczy floty w kaflu, okrętu gracza nie dotyka.
	if(hits_player(player, player_hex))
		// Okręt gracza w kaflu: rakieta schodzi do walki taktycznej jako prawdziwa torpeda, którą da się zestrzelić.
		// Skutki strategiczne (floty, skażenie, DEFCON) liczy dopiero jej trafienie, nie samo wejście do kafla.
		player.hex_incoming_nuke(faction)
		log_game("HEXWAR: nuclear missile ([faction]) handed over to tactical combat at [hex.id]")
		finish()
		return
	hex_nuke_blast(hex, faction)
	finish()

/// Pocisk schodzi do walki taktycznej z okrętem gracza: tylko wrogi i tylko w jego kaflu
/datum/hex_nuke/proc/hits_player(obj/structure/overmap/player, datum/hex/player_hex)
	return player && player_hex == hex && hex_factions_hostile(faction, player.faction)

/// Skutki wybuchu na mapie: floty tracą okręty (3 w kaflu, 1 obok), pusty kafel zostaje skażony, DEFCON i napięcie
/proc/hex_nuke_blast(datum/hex/where, faction)
	for(var/datum/fleet/F as anything in where.system?.fleets)
		hex_nuke_damage_fleet(F, 3)
	for(var/datum/hex/N as anything in GLOB.hexmap.neighbours(where))
		for(var/datum/fleet/F as anything in N.system?.fleets)
			hex_nuke_damage_fleet(F, 1)
	if(!where.system || istype(where.system, /datum/star_system/random/hex_empty))
		var/previous = where.terrain
		GLOB.hexmap.contaminate(where, hex_terrain(previous)?.moving ? HEX_TERRAIN_EMPTY : previous, 50 MINUTES)
	mini_announce("Detonacja jądrowa w [where.display_name()].", "White Rapids EAS")
	GLOB.hex_war?.nuclear_detonation(where)
	log_game("HEXWAR: nuclear missile ([faction]) detonates at [where.id]")

/datum/hex_nuke/proc/finish()
	GLOB.hex_war?.missiles -= src
	qdel(src)

/proc/hex_nuke_damage_fleet(datum/fleet/F, ships)
	if(QDELETED(F))
		return
	for(var/obj/structure/overmap/OM as anything in F.all_ships.Copy())
		if(ships <= 0)
			break
		if(!QDELETED(OM) && !length(OM.mobs_in_ship))
			ships--
			qdel(OM)

/// Pocisk wchodzi w kafel okrętu gracza: prawdziwa torpeda z krawędzi overmapy, którą PD i flak mogą zestrzelić
/obj/structure/overmap/proc/hex_incoming_nuke(faction)
	set waitfor = FALSE
	relay('nsv13/sound/effects/ship/incoming_missile.ogg', message = "<h1>Nieuchronne trafienie pociskiem</h1><br/><span class='danger'>Wykryto odpalenie głowicy termojądrowej. Cała załoga, przygotować się na uderzenie.</span>")
	sleep(5 SECONDS)
	if(QDELETED(src) || !z)
		return
	var/turf/start = locate(clamp(x + pick(-30, 30), 2, world.maxx - 2), clamp(y + pick(-30, 30), 2, world.maxy - 2), z)
	var/turf/goal = get_turf(src)
	if(!start || !goal)
		return
	var/obj/item/projectile/guided_munition/torpedo/nuclear/proj = new(start)
	proj.hex_strategic_faction = faction || "unknown"
	proj.starting = start
	proj.firer = null
	proj.def_zone = "chest"
	proj.original = src
	proj.faction = faction
	proj.spread = 0
	if(physics2d?.collider2d)
		proj.setup_collider()
	// Naprowadzanie jak przy fire_projectile() (physics.dm): bez niego torpeda leci w miejsce, gdzie okręt stał,
	// i chybia każdy manewrujący okręt, a skutki strategiczne liczy dopiero trafienie
	proj.set_homing_target(src)
	proj.fire(get_angle(start, goal))

// ===== strzał strategiczny gracza =====

/// Atomówka załadowana do wyrzutni okrętu (do strzału z konsoli nawigacji)
/obj/structure/overmap/proc/hex_loaded_nukes()
	. = list()
	for(var/obj/machinery/ship_weapon/W in GLOB.machines)
		if(!(istype(W, /obj/machinery/ship_weapon/torpedo_launcher) || istype(W, /obj/machinery/ship_weapon/vls)) || W.get_overmap() != src)
			continue
		for(var/obj/item/ship_weapon/ammunition/torpedo/nuke/N as anything in W.hex_ready_nukes())
			.[N] = W

/// Atomówki, które wolno zabrać z wyrzutni do strzału strategicznego
/obj/machinery/ship_weapon/proc/hex_ready_nukes()
	. = list()
	if(state in list(STATE_FEEDING, STATE_CHAMBERING, STATE_FIRING))
		return // wyrzutnia w trakcie cyklu (chamber() śpi z torpedą w ammo): zabranie jej teraz zepsułoby cykl
	for(var/obj/item/ship_weapon/ammunition/torpedo/nuke/N in ammo)
		. += N

/// Powód, dla którego okręt nie może teraz odpalić atomówki w ten kafel, albo null
/obj/structure/overmap/proc/hex_nuke_blocker(datum/hex/target, cached = FALSE)
	if(!GLOB.hex_war?.ready)
		return "Brak łączności ze sztabem."
	if(target && GLOB.hexmap.blocks(target)) // czarna dziura: trasy nie ma, a pocisk przepadłby po cichu po odpaleniu
		return "Pocisk nie doleci do tego kafla."
	if(GLOB.hex_war.defcon > 2)
		return "Użycie broni jądrowej wymaga DEFCON 2 albo niższego (teraz [GLOB.hex_war.defcon])."
	if(!(cached ? hex_loaded_nuke_count() : length(hex_loaded_nukes())))
		return "Żadna wyrzutnia nie ma załadowanej atomówki."
	var/datum/hex/here = current_hex()
	if(!here || !target || here == target)
		return "Wybierz inny kafel."
	if(GLOB.hexmap.war_distance(here, target) > 9)
		return "Cel poza zasięgiem 9 kafli."

/obj/structure/overmap/proc/hex_fire_strategic_nuke(datum/hex/target, mob/user)
	var/reason = hex_nuke_blocker(target)
	if(reason)
		if(user)
			to_chat(user, "<span class='warning'>[reason]</span>")
		return FALSE
	var/list/loaded = hex_loaded_nukes()
	var/obj/item/ship_weapon/ammunition/torpedo/nuke/N = loaded[1]
	var/obj/machinery/ship_weapon/W = loaded[N]
	if(W.chambered == N)
		W.chambered = null
	W.ammo -= N
	W.state = length(W.ammo) ? STATE_LOADED : STATE_NOTLOADED
	W.update_icon()
	qdel(N)
	var/datum/fleet/target_fleet
	for(var/datum/fleet/F as anything in target.system?.fleets)
		if(!QDELETED(F) && hex_factions_hostile(faction, F.alignment))
			target_fleet = F
			break
	GLOB.hex_war.launch_missile(faction, current_hex(), target_fleet, null, target)
	if(user)
		log_game("[key_name(user)] fired a strategic nuclear missile from [src] at [target.id]")
		message_admins("[ADMIN_LOOKUPFLW(user)] wystrzelił atomówkę strategiczną w kafel [target.display_name()].")
	return TRUE

// ===== skażenie po detonacji (zapisywane w kampanii) =====

/datum/hexmap
	/// id kafla -> list("previous" = teren po wygaszeniu, "until" = world.time wygaszenia)
	var/list/contamination = list()

/datum/hexmap/proc/contaminate(datum/hex/H, previous, duration)
	var/list/old = contamination[H.id]
	if(old) // kolejne trafienie: teren po wygaszeniu ten sam co przy pierwszym, a nie samo skażenie
		previous = old["previous"]
	H.set_terrain(HEX_TERRAIN_RADIATION)
	contamination[H.id] = list("previous" = previous, "until" = world.time + duration)
	addtimer(CALLBACK(src, PROC_REF(decontaminate), H.id), duration, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/hexmap/proc/decontaminate(hex_id)
	var/list/entry = contamination[hex_id]
	contamination -= hex_id
	var/datum/hex/H = hex_by_id(hex_id)
	if(entry && H && H.terrain == HEX_TERRAIN_RADIATION)
		H.set_terrain(entry["previous"])

/// Do zapisu kampanii: id kafla -> list(teren po wygaszeniu, pozostały czas)
/datum/hexmap/proc/save_contamination()
	. = list()
	for(var/hex_id in contamination)
		var/list/entry = contamination[hex_id]
		.[hex_id] = list(entry["previous"], max(0, entry["until"] - world.time))

/// Start rundy: skażenie z zapisu dalej wygasa w swoim czasie (sam teren odtwarza generate_terrain())
/datum/hexmap/proc/restore_contamination(list/saved)
	if(!islist(saved))
		return
	for(var/hex_id in saved)
		var/list/entry = saved[hex_id]
		var/datum/hex/H = hex_by_id(hex_id)
		if(!H || !islist(entry) || length(entry) < 2)
			continue
		contaminate(H, entry[1], max(1 SECONDS, entry[2]))

/obj/structure/overmap
	var/hex_nuke_count = 0
	var/hex_nuke_count_time = -INFINITY

/// Liczba załadowanych atomówek dla okna konsoli: przegląd wszystkich maszyn świata najwyżej co 5 s, nie przy każdym
/// odświeżeniu (pamiętana tylko liczba, bez referencji do torped). Odpalenie sprawdza wyrzutnie na bieżąco.
/obj/structure/overmap/proc/hex_loaded_nuke_count()
	if(world.time >= hex_nuke_count_time + 5 SECONDS)
		hex_nuke_count = length(hex_loaded_nukes())
		hex_nuke_count_time = world.time
	return hex_nuke_count
