// AQUILA - misje na losowych kaflach (raport/ftl_mapa_06_plan_pr.md, część F). Decyzja: misje, które da się przenieść,
// dzieją się na losowych kaflach, żeby załoga zaglądała w różne miejsca mapy:
// - abordaż okrętu i abordaż stacji: losowy pusty kafel sektora neutralnego (zamiast układu z mapy);
// - Opuszczona stacja (aq33/AquilaStation#585): losowy pusty kafel sektora neutralnego;
// - skan anomalii: skupiska anomalii na kaflach pól anomalii;
// - zniszczenie floty: prawdziwe floty z mapy (bez zmian); misje z ładunkiem zostają przy stacjach.
// Część misji ma w nagrodę torpedę termojądrową.

#define HEX_MISSION_NUKE_CHANCE 35
#define HEX_OBJECTIVE_COMPLETED 1

/// Losowy pusty kafel bez zagrożeń w sektorze, z dala od okrętu gracza; zwraca jego układ albo fallback bez mapy hex
/proc/hex_mission_system(datum/star_system/fallback, sector = SECTOR_NEUTRAL, min_distance = 3)
	if(!GLOB.hexmap?.built)
		return fallback
	var/datum/hex/player_hex = SSstar_system.find_main_overmap()?.current_hex()
	var/list/candidates = list()
	for(var/datum/hex/H as anything in GLOB.hexmap.free_hexes(sector))
		if(player_hex && player_hex.sector == H.sector && GLOB.hexmap.distance(player_hex, H) < min_distance)
			continue
		candidates += H
	if(!length(candidates))
		return fallback
	return GLOB.hexmap.system_for(pick(candidates))

/datum/overmap_objective/board_station/New(datum/star_system/passed_input)
	return ..(passed_input || hex_mission_system(null))

/datum/overmap_objective
	/// Nagroda za wykonanie: torpeda termojądrowa w kapsule
	var/hex_nuke_reward = FALSE
	var/hex_nuke_given = FALSE

/// Część misji płaci atomówką: losowane przy starcie misji, dopisane do opisu
/datum/overmap_objective/proc/hex_roll_nuke_reward()
	if(!GLOB.hexmap?.built || !prob(HEX_MISSION_NUKE_CHANCE))
		return
	hex_nuke_reward = TRUE
	brief = "[brief] W nagrodę Dowództwo przyśle torpedę termojądrową."

/datum/overmap_objective/board_ship/instance()
	. = ..()
	hex_roll_nuke_reward()

/datum/overmap_objective/board_station/instance()
	. = ..()
	hex_roll_nuke_reward()

/datum/overmap_objective/derelict_ruin/instance()
	. = ..()
	hex_roll_nuke_reward()

/// Wykonane misje z nagrodą: atomówka kapsułą na okręt gracza (sprawdzane w turze sztabów)
/datum/hex_war/proc/mission_rewards()
	var/obj/structure/overmap/OM = SSstar_system.find_main_overmap()
	if(!OM || !SSovermap_mode?.mode)
		return
	for(var/datum/overmap_objective/O as anything in SSovermap_mode.mode.objectives)
		if(!O.hex_nuke_reward || O.hex_nuke_given || O.status != HEX_OBJECTIVE_COMPLETED)
			continue
		O.hex_nuke_given = TRUE
		OM.send_supplypod(/obj/item/ship_weapon/ammunition/torpedo/nuke)
		priority_announce("Za wykonanie misji „[O.name]” Dowództwo wysyła kapsułą torpedę termojądrową.", "Dowództwo Floty White Rapids")
		log_game("HEXWAR: mission [O.name] rewarded with a nuclear torpedo")

// ===== skupiska anomalii do skanowania =====

/obj/effect/overmap_anomaly/aquila_anomaly_cluster
	name = "Skupisko anomalii"
	desc = "Splot niestabilnych zjawisk w polu anomalii. Skan albo sonda dadzą sporo danych badawczych."
	icon = 'nsv13/goonstation/icons/effects/overmap_anomalies/tearmed.dmi'
	icon_state = "tear"
	research_points = 6000

/// Pole anomalii od razu dostaje układ ze skupiskiem, żeby misja skanowania je widziała
/datum/hex/proc/hex_spawn_anomaly_cluster()
	var/datum/star_system/S = GLOB.hexmap.system_for(src)
	for(var/obj/effect/overmap_anomaly/aquila_anomaly_cluster/A in S.system_contents)
		return
	SSstar_system.spawn_anomaly(/obj/effect/overmap_anomaly/aquila_anomaly_cluster, S)

#undef HEX_MISSION_NUKE_CHANCE
#undef HEX_OBJECTIVE_COMPLETED
