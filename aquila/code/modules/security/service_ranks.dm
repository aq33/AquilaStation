// AQUILA - trwałe stopnie z awansami (pomysł z Persistence SS13: Kadet → Sierżant w ochronie).
// Mechanizm jest wspólny (drabina stopni dla stanowiska), treść na razie tylko dla Żandarma.
// Stopień liczy się przy wejściu do gry: sam staż i aresztowania dają awans do progu, wyżej awansuje Komendant
// albo Kapitan w konsoli rekordów; ta sama konsola degraduje (kary dyscyplinarne z kodeksu).
// Awanse i degradacje są statystykami postaci (character_stats), więc przechodzą między rundami.
// Stopień zmienia tytuł w rozmowie i daje premię do pensji: +10% za każdy stopień ponad najniższy.

/// Stanowisko => drabina: "stat" (klucz statystyk), "ranks" (od najniższego), "auto" (ile stopni da się dostać samemu),
/// "thresholds" (rundy, aresztowania) dla kolejnych automatycznych awansów
GLOBAL_LIST_INIT(aq_rank_ladders, list(
	"Żandarm" = list(
		"stat" = "sec",
		"ranks" = list("mat", "bosm.", "st. bosm."),
		"auto" = 2,
		"thresholds" = list(list(10, 5)),
	),
))

#define RANK_PAY_BONUS_PER_STEP 0.1

/datum/mind
	/// Indeks w drabinie stopni stanowiska (null = stopień ze stanowiska)
	var/aq_rank_index
	/// Drabina, z której pochodzi aq_rank_index
	var/aq_rank_job

/// Stopień z drabiny dla tego umysłu albo null
/datum/mind/proc/aq_personal_rank()
	if(isnull(aq_rank_index) || !aq_rank_job)
		return null
	var/list/ladder = GLOB.aq_rank_ladders[aq_rank_job]
	var/list/ranks = ladder?["ranks"]
	if(!length(ranks))
		return null
	return ranks[clamp(aq_rank_index, 1, length(ranks))]

/// Liczy indeks stopnia ze statystyk postaci: automatyczne awanse według progów, ręczne awanse i degradacje
/proc/aq_rank_index_from_stats(list/ladder, list/stats)
	var/index = 1
	var/list/thresholds = ladder["thresholds"]
	for(var/list/threshold as anything in thresholds)
		if(index >= ladder["auto"])
			break
		if(stats["rounds"] >= threshold[1] && stats["arrests"] >= threshold[2])
			index++
	var/stat = ladder["stat"]
	index += stats["rank_up_[stat]"] - stats["rank_down_[stat]"]
	return clamp(index, 1, length(ladder["ranks"]))

/// Przy wejściu do gry: stopień z drabiny i premia do pensji
/datum/job/after_spawn(mob/living/H, mob/M, latejoin = FALSE)
	. = ..()
	var/list/ladder = GLOB.aq_rank_ladders[title]
	if(!ladder || !H?.mind?.key || !H.real_name)
		return
	var/list/all_characters = character_stats_load(ckey(H.mind.key))
	var/list/stats = all_characters[H.real_name] || list()
	H.mind.aq_rank_job = title
	H.mind.aq_rank_index = aq_rank_index_from_stats(ladder, stats)
	aq_apply_rank_pay(H)

/proc/aq_apply_rank_pay(mob/living/H)
	var/obj/item/card/id/id = H.get_idcard(FALSE)
	var/datum/bank_account/account = id?.registered_account
	if(!account || !H.mind?.aq_rank_index)
		return
	var/datum/job/job = SSjob.GetJob(H.mind.aq_rank_job)
	if(!job)
		return
	account.paycheck_amount = round(job.paycheck * (1 + RANK_PAY_BONUS_PER_STEP * (H.mind.aq_rank_index - 1)))

/// Awans (+1) albo degradacja (-1) z konsoli rekordów. Zwraca nowy stopień albo null
/proc/aq_change_rank(datum/mind/target_mind, delta, author)
	if(!target_mind?.aq_rank_job || !delta)
		return null
	var/list/ladder = GLOB.aq_rank_ladders[target_mind.aq_rank_job]
	var/new_index = clamp(target_mind.aq_rank_index + delta, 1, length(ladder["ranks"]))
	if(new_index == target_mind.aq_rank_index)
		return null
	target_mind.aq_rank_index = new_index
	record_mind_stat(target_mind, delta > 0 ? "rank_up_[ladder["stat"]]" : "rank_down_[ladder["stat"]]")
	if(isliving(target_mind.current))
		aq_apply_rank_pay(target_mind.current)
	var/rank = target_mind.aq_personal_rank()
	aq_security_announce("Kadry: [delta > 0 ? "awans" : "degradacja"] – [target_mind.name], nowy stopień: [rank] ([author]).")
	return rank

/// Umysł postaci z tej rundy po imieniu (rekord kartoteki nie ma ckey)
/proc/aq_mind_by_name(name)
	for(var/datum/mind/mind as anything in SSticker.minds)
		if(mind?.name == name)
			return mind
	return null

// Stopień osobisty zamiast stopnia stanowiska w rozmowie i przez radio (stopień drużyny dalej wygrywa)
/atom/movable/compose_rank(atom/movable/speaker)
	var/atom/movable/real_speaker = speaker
	if(istype(speaker, /atom/movable/virtualspeaker))
		var/atom/movable/virtualspeaker/virtual = speaker
		if(virtual.squad_rank)
			return ..()
		real_speaker = virtual.source
	if(ismob(real_speaker) && CONFIG_GET(flag/show_ranks))
		var/mob/speaker_mob = real_speaker
		var/rank = speaker_mob.mind?.aq_personal_rank()
		if(rank)
			return "[rank] "
	return ..()

#undef RANK_PAY_BONUS_PER_STEP

// --- Konsola rekordów: stopień osoby, awans i degradacja (Komendant, Kapitan) ---

/obj/machinery/computer/secure_data/proc/aq_can_change_rank(mob/user)
	var/list/access = aq_user_access(user)
	return (ACCESS_HOS in access) || (ACCESS_CAPTAIN in access)

/obj/machinery/computer/secure_data/ui_data(mob/user)
	var/list/data = ..()
	if(authenticated && screen == 3 && istype(active1, /datum/data/record))
		var/datum/mind/target_mind = aq_mind_by_name(active1.fields["name"])
		var/rank = target_mind?.aq_personal_rank()
		if(rank)
			data["service_rank"] = list("rank" = rank, "can_change" = aq_can_change_rank(user))
	return data

/obj/machinery/computer/secure_data/ui_act(action, list/params)
	if(action != "rank_up" && action != "rank_down")
		return ..()
	if(!authenticated || !istype(active1, /datum/data/record) || !aq_can_change_rank(usr))
		return FALSE
	var/datum/mind/target_mind = aq_mind_by_name(active1.fields["name"])
	if(!aq_change_rank(target_mind, action == "rank_up" ? 1 : -1, aq_record_author(usr)))
		return FALSE
	investigate_log("[key_name(usr)] changed the service rank of [active1.fields["name"]] ([action])", INVESTIGATE_RECORDS)
	return TRUE
