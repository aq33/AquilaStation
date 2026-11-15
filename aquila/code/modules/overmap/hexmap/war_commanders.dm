// AQUILA - dowódcy flot sztabów (część D): imię, ranga, cechy, blizny, uraza do okrętu gracza i historia.
// Cechy działają w walce kośćmi poza okiem graczy (ship_fire), w progu odwrotu i w polowaniu na okręt gracza.

/// id cechy -> list(nazwa, rodzaj: "s" zaleta / "w" słabość / "x" charakter, opis, cecha po bliźnie, opis blizny)
GLOBAL_LIST_INIT(hex_commander_traits, list(
	"aggressive" = list("Agresywny", "x", "+20% siły ataku", null, null),
	"cautious" = list("Ostrożny", "x", "+20% obrony, -10% ataku", null, null),
	"armored" = list("Pancerne kadłuby", "s", "+25% obrony", null, null),
	"thin_hull" = list("Cienkie poszycie", "w", "-25% obrony", "armored", "Przeżył ostrzał i wzmocnił pancerz"),
	"strategist" = list("Strateg", "s", "+20% obrony we własnym układzie", null, null),
	"cunning" = list("Przebiegły", "s", "+30% ataku w mgławicy i polu asteroid", null, null),
	"clumsy" = list("Niezdarny", "w", "-20% ataku", "aggressive", "Klęska nauczyła go zaciekłości"),
	"coward" = list("Tchórzliwy", "w", "wycofuje się już przy 60% sił", "cautious", "Ucieczka nauczyła go ostrożności"),
	"fanatic" = list("Fanatyk", "x", "nigdy się nie wycofuje, +20% ataku", null, null),
	"vengeful" = list("Mściwy", "x", "po porażce awansuje i poluje na zwycięzcę", null, null),
))

GLOBAL_LIST_INIT(hex_commander_ranks, list("Kapitan", "Komandor", "Kontradmirał", "Admirał"))

GLOBAL_LIST_INIT(hex_commander_names, list(
	"syndicate" = list(
		list("Vex", "Darra", "Kael", "Mirek", "Orla", "Sabin", "Ivo", "Tess", "Grom", "Nadia"),
		list("Halloran", "Krask", "Voss", "Morrow", "Sztyl", "Daggett", "Rook", "Varga", "Czarny", "Malek"),
		list("Rzeźnik", "Szakal", "Żelazny", "Lis", "Krwawy", "Cichy", "Kat", "Wilk")),
	"pirate" = list(
		list("Jack", "Rosa", "Bart", "Ulla", "Fenn", "Zuza", "Grim", "Mags"),
		list("Hak", "Rdza", "Kotwica", "Szrapnel", "Bosman", "Rum", "Sztorm", "Kord"),
		list("Jednooki", "Szczur", "Ośmiornica", "Kufel", "Łajza", "Harpun")),
	"nanotrasen" = list(
		list("Anna", "Marek", "Helena", "Jonas", "Iga", "Victor", "Lena", "Tomasz"),
		list("Kowal", "Reyes", "Lindqvist", "Nowak", "Okafor", "Brandt", "Sato", "Wilk"),
		list("Księgowy", "Tarcza", "Kompas", "Pewniak")),
	"solgov" = list(
		list("Elena", "Marcus", "Aiko", "Diego", "Ruth", "Pavel"),
		list("Hart", "Moreau", "Tanaka", "Silva", "Grant", "Orlov"),
		list("Weteran", "Kamień", "Kurier")),
))

/datum/hex_commander
	var/id
	var/faction
	var/first_name
	var/last_name
	var/nickname
	var/rank = 0
	var/list/traits = list()
	/// Cechy poznane przez załogę (po spotkaniu floty)
	var/list/known_traits = list()
	var/wins = 0
	var/losses = 0
	var/status = HEX_CMD_ACTIVE
	var/grudge = 0
	var/list/scars = list()
	var/list/history = list()
	var/return_at = 0
	/// Załoga widziała jego flotę (zakładka „Dowódcy”)
	var/seen = FALSE
	var/datum/fleet/fleet

/datum/hex_war/proc/new_commander(faction)
	var/datum/hex_commander/C = new
	C.id = next_commander_id++
	C.faction = faction
	var/list/names = GLOB.hex_commander_names[faction] || GLOB.hex_commander_names["syndicate"]
	C.first_name = pick(names[1])
	C.last_name = pick(names[2])
	if(prob(60))
		C.nickname = pick(names[3])
	C.rank = pick(70; 0, 25; 1, 5; 2)
	C.roll_traits()
	commanders += C
	return C

/datum/hex_commander/proc/roll_traits()
	var/list/strengths = list()
	var/list/weaknesses = list()
	var/list/characters = list()
	for(var/id in GLOB.hex_commander_traits)
		switch(GLOB.hex_commander_traits[id][2])
			if("s")
				strengths += id
			if("w")
				weaknesses += id
			if("x")
				characters += id
	traits += pick(strengths)
	if(prob(70))
		traits += pick(weaknesses)
	if(prob(60))
		traits |= pick(characters)

/datum/hex_commander/proc/has_trait(id)
	return (id in traits)

/datum/hex_commander/proc/rank_name()
	return GLOB.hex_commander_ranks[clamp(rank + 1, 1, length(GLOB.hex_commander_ranks))]

/datum/hex_commander/proc/full_name()
	return "[first_name][nickname ? " „[nickname]”" : ""] [last_name]"

/datum/hex_commander/proc/add_history(text)
	history.Insert(1, "[station_time_timestamp("hh:mm")] [text]")
	if(length(history) > 6)
		history.Cut(7)

/// Dowódca obejmuje flotę: jego imię pojawia się w nazwie floty (powitania, groźby, ogłoszenia)
/datum/hex_commander/proc/take_fleet(datum/fleet/F)
	fleet = F
	F.commander = src
	status = HEX_CMD_ACTIVE
	F.name = "[initial(F.name)] ([rank_name()] [full_name()])"

/// Spotkanie z okrętem gracza: załoga poznaje cechy dowódcy
/datum/hex_commander/proc/reveal()
	seen = TRUE
	known_traits |= traits

/datum/hex_commander/proc/add_win(datum/hex_commander/loser)
	wins++
	add_history(loser ? "pokonał [loser.rank_name()] [loser.full_name()]" : "wygrał bitwę")
	if(wins >= 2 + rank * 2 && rank < length(GLOB.hex_commander_ranks) - 1)
		rank++
		add_history("awans na: [rank_name()]")
		if(fleet)
			take_fleet(fleet)

/// Flota dowódcy zniszczona: ucieczka (rany, blizna, ewentualna uraza) albo śmierć
/datum/hex_commander/proc/fleet_lost(player_caused)
	losses++
	fleet = null
	var/escape = has_trait("coward") ? 85 : (has_trait("fanatic") ? 25 : 60)
	if(!prob(escape))
		status = HEX_CMD_DEAD
		add_history(player_caused ? "zginął w walce z okrętem [station_name()]" : "zginął razem z flotą")
		return
	status = HEX_CMD_WOUNDED
	return_at = world.time + rand(HEX_WAR_RETURN_MIN, HEX_WAR_RETURN_MAX)
	for(var/id in traits)
		var/list/info = GLOB.hex_commander_traits[id]
		if(info[2] == "w" && info[4])
			traits -= id
			traits |= info[4]
			known_traits -= id
			scars += info[5]
			add_history("blizna: [info[5]]")
			break
	if(player_caused)
		grudge++
		add_history("przysięga zemstę okrętowi [station_name()]")
	if(has_trait("vengeful") && rank < length(GLOB.hex_commander_ranks) - 1)
		rank++
	add_history("uciekł z wraku floty")

/// Ranni dowódcy wracają z nową flotą; z urazą do okrętu gracza od razu na niego polują
/datum/hex_war/proc/commander_returns()
	for(var/datum/hex_commander/C as anything in commanders)
		if(C.status != HEX_CMD_WOUNDED || C.return_at > world.time)
			continue
		// Dowódca czeka na wolne miejsce: powroty też liczą się do limitu flot frakcji
		if(length(faction_fleets(C.faction)) >= (C.faction == "pirate" ? HEX_WAR_MAX_PIRATE_FLEETS : HEX_WAR_MAX_FLEETS))
			continue
		var/datum/star_system/home
		for(var/facility in list(HEX_FAC_YARD, HEX_FAC_DEPOT, HEX_FAC_HQ))
			var/list/sites = faction_sites(C.faction, facility)
			if(length(sites))
				home = sites[1]
				break
		if(!home)
			continue
		var/datum/fleet/F = launch_fleet(C.faction, home, C, 2 + C.rank)
		if(!F)
			continue
		C.add_history("wrócił do służby w układzie [home]")
		var/obj/structure/overmap/player = SSstar_system.find_main_overmap()
		if(C.grudge && player && hex_factions_hostile(C.faction, player.faction))
			F.hex_war_set_order(HEX_ORDER_HUNT, player.current_system)
			if(!home.hidden)
				mini_announce("Wywiad: [C.rank_name()] [C.full_name()] wraca z nową flotą i poluje na [station_name()].", "White Rapids EAS")

/datum/fleet/defeat()
	var/datum/star_system/where = current_system
	var/player_caused = FALSE
	for(var/obj/structure/overmap/OM in where?.system_contents)
		if(!QDELETED(OM) && length(OM.mobs_in_ship))
			player_caused = TRUE
			break
	if(where)
		// Łup z konwoju dla piratów, zwycięstwo dla dowódców wrogich flot w układzie
		if(war_cargo)
			for(var/datum/fleet/P as anything in where.fleets)
				if(P != src && P.alignment == "pirate")
					P.war_loot += war_cargo_amount
					break
		for(var/datum/fleet/W as anything in where.fleets)
			if(W != src && W.commander && hex_factions_hostile(W.alignment, alignment))
				W.commander.add_win(commander)
	commander?.fleet_lost(player_caused)
	commander = null
	if(!war_cargo)
		GLOB.hex_war?.add_tension(3)
	return ..()

/datum/fleet/encounter(obj/structure/overmap/OM)
	if(commander && OM?.role == MAIN_OVERMAP)
		commander.reveal()
	return ..()

/// Mnożnik ataku dowódcy floty, która strzela w tym układzie
/proc/hex_commander_attack(datum/fleet/F, datum/star_system/S)
	. = 1
	var/datum/hex_commander/C = F?.commander
	if(!C)
		return
	if(C.has_trait("aggressive"))
		. *= 1.2
	if(C.has_trait("fanatic"))
		. *= 1.2
	if(C.has_trait("cautious"))
		. *= 0.9
	if(C.has_trait("clumsy"))
		. *= 0.8
	if(C.has_trait("cunning") && (S?.hex?.terrain in list(HEX_TERRAIN_NEBULA, HEX_TERRAIN_ASTEROIDS)))
		. *= 1.3

/// Mnożnik obrony dowódcy floty, w którą strzelają
/proc/hex_commander_defence(datum/fleet/F, datum/star_system/S)
	. = 1
	var/datum/hex_commander/C = F?.commander
	if(!C)
		return
	if(C.has_trait("cautious"))
		. *= 1.2
	if(C.has_trait("armored"))
		. *= 1.25
	if(C.has_trait("thin_hull"))
		. *= 0.75
	if(C.has_trait("strategist") && S?.owner == F.alignment)
		. *= 1.2

/// Walka kośćmi poza okiem graczy: przewaga dowódcy to szansa na dodatkowy strzał, słabość to szansa na chybienie
/datum/star_system/ship_fire(obj/structure/overmap/firing, obj/structure/overmap/target)
	var/ratio = hex_commander_attack(firing?.fleet, src) / hex_commander_defence(target?.fleet, src)
	if(ratio >= 1)
		..()
		if(ratio > 1 && prob((ratio - 1) * 100) && !QDELETED(target))
			..()
		return
	if(prob(ratio * 100))
		..()
