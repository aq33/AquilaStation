// AQUILA - nemezis: bossowie z mapy gwiezdnej (SSV Fist of Sol w Romulusie, SGV Alicorn w Veneto) mają stałych dowódców
// w systemie dowódców wojny. Flota bossa stoi w swoim układzie jak garnizon (poza sztabem), a jej dowódca ma imię, cechy,
// historię i urazę jak inni. Pokonany ucieka i wraca po czasie z odbudowanym okrętem do swojego układu albo ginie
// i nie wraca do końca kampanii.

/// id nemezis -> dowódca, jego flota i układ
GLOBAL_LIST_INIT(hex_nemeses, list(
	"fistofsol" = list(
		"faction" = "syndicate",
		"first" = "Lucan",
		"last" = "Draven",
		"nick" = "Młot Sol",
		"rank" = 3,
		"traits" = list("strategist", "armored", "vengeful"),
		"fleet" = /datum/fleet/syndicate/fistofsol_boss,
		"home" = "Romulus",
	),
	"alicorn" = list(
		"faction" = "hostile",
		"first" = "Seraphine",
		"last" = "Vael",
		"nick" = "Miliard",
		"rank" = 3,
		"traits" = list("cunning", "cautious"),
		"fleet" = /datum/fleet/hostile/alicorn_boss,
		"home" = "Veneto",
	),
))

/datum/hex_commander
	/// Nemezis: id z GLOB.hex_nemeses. Dowodzi tylko swoim bossem i wraca tylko do swojego układu.
	var/nemesis

// Alicorn i jego myśliwce mają frakcję okrętów "hostile". Flota z frakcją Syndykatu dostawała z domyślnych list
// niszczyciel i krążownik Syndykatu, które strzelały do Alicorna, a flota uznawała okręty Syndykatu za swoje.
/datum/fleet/hostile/alicorn_boss
	alignment = "hostile"
	destroyer_types = list()
	battleship_types = list()

/// Stały dowódca bossa: z zapisu kampanii albo nowy
/datum/hex_war/proc/nemesis_commander(id)
	for(var/datum/hex_commander/existing as anything in commanders)
		if(existing.nemesis == id)
			return existing
	var/list/info = GLOB.hex_nemeses[id]
	if(!info)
		return
	var/datum/hex_commander/C = new
	C.id = next_commander_id++
	C.nemesis = id
	C.faction = info["faction"]
	C.first_name = info["first"]
	C.last_name = info["last"]
	C.nickname = info["nick"]
	C.rank = info["rank"]
	var/list/traits = info["traits"]
	C.traits = traits.Copy()
	commanders += C
	return C

/// Flota bossa danego typu w układzie
/proc/hex_nemesis_fleet(datum/star_system/S, fleet_type)
	for(var/datum/fleet/F as anything in S?.fleets)
		if(!QDELETED(F) && istype(F, fleet_type))
			return F

/// Start rundy, po zapisie i garnizonach: boss dostaje swojego dowódcę. Ranny albo poległy dowódca nie stoi w układzie,
/// a boss, którego brakuje w mapie gwiezdnej trwającej kampanii (zapisanej przed jego dodaniem), pojawia się w układzie.
/datum/hex_war/proc/setup_nemeses()
	for(var/id in GLOB.hex_nemeses)
		var/list/info = GLOB.hex_nemeses[id]
		var/datum/star_system/home = SSstar_system.system_by_id(info["home"])
		if(!home?.hex)
			continue
		var/datum/hex_commander/C = nemesis_commander(id)
		var/datum/fleet/boss = hex_nemesis_fleet(home, info["fleet"])
		if(C.status != HEX_CMD_ACTIVE)
			boss?.hex_war_dispose()
			continue
		if(!boss)
			// Układ trzyma wróg (garnizon nie wrócił do zajętego układu): dowódca odbije go później
			if(hex_factions_hostile(home.owner, home.alignment))
				C.status = HEX_CMD_WOUNDED
				C.return_at = world.time + rand(HEX_WAR_RETURN_MIN, HEX_WAR_RETURN_MAX)
				continue
			boss = home.spawn_fleet(info["fleet"])
			if(!boss)
				continue
		C.take_fleet(boss)

/// Ranny nemezis wraca z odbudowanym okrętem do swojego układu, a nie do stoczni frakcji jak zwykli dowódcy
/datum/hex_war/proc/nemesis_return(datum/hex_commander/C)
	var/list/info = GLOB.hex_nemeses[C.nemesis]
	if(!info)
		return
	var/datum/star_system/home = SSstar_system.system_by_id(info["home"])
	if(!home)
		return
	var/held = home.alignment
	var/datum/fleet/F = home.spawn_fleet(info["fleet"])
	if(!F)
		return
	// Jak przy ruchu floty (fleet.move): przy wrogiej flocie w układzie zajmie go dopiero zwycięzca walki
	if(F.hex_occupation_blocked(home))
		home.alignment = held
	C.take_fleet(F)
	C.add_history("wrócił do układu [home]")
	if(home.hidden)
		return
	if(C.grudge)
		mini_announce("Wywiad: [C.rank_name()] [C.full_name()] wraca do układu [home] na odbudowanym okręcie i szuka zemsty na [station_name()].", "White Rapids EAS")
	else
		mini_announce("Wywiad: [C.rank_name()] [C.full_name()] wraca do układu [home] na odbudowanym okręcie.", "White Rapids EAS")
