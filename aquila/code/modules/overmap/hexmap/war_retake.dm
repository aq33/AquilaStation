// AQUILA - obrona kwatery Nanotrasen (raport/ftl_mapa_07, decyzja z 15.11): wojna nie kończy się dla NT tak łatwo.
// 1) Ewakuacja: gdy NT drugą rundę z rzędu traci kwaterę, sztab przenosi się na zaplecze (Argo) z nowym garnizonem,
//    a licznik rund zaczyna od zera. Przegrana dopiero po utracie także nowej kwatery.
// 2) Misja dla załogi: kwatera NT w rękach wroga daje misję „Odbij kwaterę” z nagrodą, a tura, w której okręt gracza
//    walczy w kaflu kwatery albo obok, nie liczy się do rund bez kwatery.

#define STATUS_INPROGRESS 0
#define STATUS_COMPLETED 1
#define STATUS_FAILED 2

/// Nagroda za odbicie kwatery z pomocą okrętu, na konto zaopatrzenia
#define HEX_WAR_RETAKE_REWARD 10000
/// Zaplecze NT, do którego sztab ewakuuje się z kwatery (po kolei, pierwszy trzymany przez NT)
GLOBAL_LIST_INIT(hex_war_nt_fallbacks, list("Argo", "Orion's Arm", "Alpha Carinae"))

/datum/hex_war
	/// Przeniesione kwatery: stary układ -> nowy (zapisywane w kampanii, place_facilities stawia kwatery z makiety)
	var/list/hq_relocations = list()
	/// Ogłoszenie ewakuacji do pokazania na starcie następnej rundy
	var/pending_evac_announce
	/// Bieżąca misja „Odbij kwaterę”
	var/datum/overmap_objective/aquila_retake_hq/retake_mission

/// Kwatera Nanotrasen (po ewakuacji: nowa)
/datum/hex_war/proc/nt_hq_system()
	for(var/datum/star_system/S as anything in SSstar_system.systems)
		if(S.owner == "nanotrasen" && S.has_facility(HEX_FAC_HQ))
			return S

/// Czy okręt gracza walczy przy tej kwaterze: w jej kaflu albo w sąsiednim
/datum/hex_war/proc/ship_defends(datum/star_system/hq, datum/hex/ship_hex)
	if(!hq?.hex || !ship_hex || ship_hex.sector != hq.hex.sector)
		return FALSE
	return GLOB.hexmap.distance(ship_hex, hq.hex) <= 1

/// Ewakuacja sztabu NT na zaplecze. Zwraca TRUE, jeśli się udała (wtedy wojna trwa dalej).
/datum/hex_war/proc/evacuate_nt_hq()
	if(length(hq_relocations)) // jedna ewakuacja na kampanię: utrata nowej kwatery to już przegrana
		return FALSE
	var/datum/star_system/old_hq = nt_hq_system()
	if(!old_hq)
		return FALSE
	var/datum/star_system/new_hq
	for(var/name in GLOB.hex_war_nt_fallbacks)
		var/datum/star_system/S = SSstar_system.system_by_id(name)
		if(S && S != old_hq && S.owner == "nanotrasen" && !S.has_facility(HEX_FAC_HQ) && !hex_factions_hostile("nanotrasen", S.alignment))
			new_hq = S
			break
	if(!new_hq)
		return FALSE
	move_hq(old_hq, new_hq)
	hq_relocations[old_hq.name] = new_hq.name
	hq_lost_rounds["nanotrasen"] = 0
	pending_evac_announce = "Sztab Nanotrasen ewakuowany z układu [old_hq] do układu [new_hq]. Nowa kwatera główna dostaje garnizon. Utrata także jej oznacza przegraną wojnę."
	log_game("HEXWAR: Nanotrasen evacuates its headquarters from [old_hq] to [new_hq]")
	return TRUE

/datum/hex_war/proc/move_hq(datum/star_system/from, datum/star_system/to_system)
	LAZYREMOVE(from.war_facilities, HEX_FAC_HQ)
	LAZYOR(to_system.war_facilities, HEX_FAC_HQ)

/// Start rundy: przeniesienia kwater z kampanii (place_facilities ustawia je od nowa z makiety) i ogłoszenie ewakuacji
/datum/hex_war/proc/apply_hq_relocations()
	for(var/name in hq_relocations)
		var/datum/star_system/from = SSstar_system.system_by_id(name)
		var/datum/star_system/to_system = SSstar_system.system_by_id(hq_relocations[name])
		if(from && to_system)
			move_hq(from, to_system)
	if(pending_evac_announce)
		priority_announce(pending_evac_announce, "Dowództwo Floty White Rapids")
		pending_evac_announce = null

/// Co turę: kwatera NT w rękach wroga daje misję „Odbij kwaterę” (jedną naraz), a pomoc okrętu jest zapamiętywana
/datum/hex_war/proc/update_retake_mission(datum/hex/ship_hex)
	var/datum/star_system/hq = nt_hq_system()
	if(!hq)
		return
	var/lost = hex_factions_hostile("nanotrasen", hq.alignment)
	if(retake_mission && (QDELETED(retake_mission) || retake_mission.status != STATUS_INPROGRESS))
		retake_mission = null
	if(lost && !retake_mission && SSovermap_mode.mode)
		retake_mission = new
		retake_mission.target_system = hq
		SSovermap_mode.mode.objectives += retake_mission
		SSovermap_mode.instance_objectives()
		priority_announce("Kwatera główna Nanotrasen w układzie [hq] wpadła w ręce wroga. Nowa misja: odbijcie ją. Dopóki okręt walczy w jej kaflu albo obok, sztab się nie poddaje.", "Dowództwo Floty White Rapids")
	if(retake_mission && lost && ship_defends(hq, ship_hex))
		retake_mission.helped = TRUE

/datum/overmap_objective/aquila_retake_hq
	name = "Odbij kwaterę"
	desc = "Odbij kwaterę główną Nanotrasen z rąk wroga"
	brief = "Odbijcie kwaterę główną Nanotrasen z rąk wroga"
	binary = TRUE
	/// Kwatera do odbicia
	var/datum/star_system/target_system
	/// Okręt walczył w kaflu kwatery albo obok, gdy była w rękach wroga
	var/helped = FALSE

/datum/overmap_objective/aquila_retake_hq/instance()
	brief = "Odbijcie kwaterę główną Nanotrasen w układzie [target_system]: rozbijcie floty wroga w jej kaflu. Nagroda [HEX_WAR_RETAKE_REWARD] kr, jeśli okręt walczył przy kwaterze."
	return ..()

/datum/overmap_objective/aquila_retake_hq/check_completion()
	. = ..()
	if(status != STATUS_INPROGRESS)
		return
	if(!target_system || !target_system.has_facility(HEX_FAC_HQ))
		status = STATUS_FAILED // kwatera przeniesiona (ewakuacja): misja nieaktualna
		return
	if(!hex_factions_hostile("nanotrasen", target_system.alignment))
		status = STATUS_COMPLETED
		if(helped)
			var/datum/bank_account/cargo = SSeconomy.get_dep_account(ACCOUNT_CAR)
			cargo?.adjust_money(HEX_WAR_RETAKE_REWARD)
			priority_announce("Kwatera główna Nanotrasen w układzie [target_system] odbita. Za udział okrętu na konto zaopatrzenia przelano [HEX_WAR_RETAKE_REWARD] kr.", "Dowództwo Floty White Rapids")
		return
	// Nie blokuje końca rundy: gdy wszystkie inne misje są zamknięte, a kwatera dalej w rękach wroga, misja przepada
	for(var/datum/overmap_objective/O as anything in SSovermap_mode.mode?.objectives)
		if(O != src && O.status == STATUS_INPROGRESS)
			return
	status = STATUS_FAILED

#undef STATUS_INPROGRESS
#undef STATUS_COMPLETED
#undef STATUS_FAILED
#undef HEX_WAR_RETAKE_REWARD
