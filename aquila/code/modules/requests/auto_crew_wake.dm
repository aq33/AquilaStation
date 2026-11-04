// Automatyczne wybudzenie załogi: gdy nie żyje co najmniej połowa graczy, którzy weszli do rundy, Centrala sama
// budzi ochotników z kriostazy, tak jak po prośbie z konsoli komunikacyjnej (wake_crew_from_cryostasis() w request.dm).
// Admini mają chwilę na anulowanie. Raz na rundę; gdy nikt się nie zgłosi, kolejna próba najwcześniej po AUTO_CREW_WAKE_RETRY.

/// Udział martwych graczy, od którego Centrala budzi załogę
#define AUTO_CREW_WAKE_DEAD_RATIO 0.5
/// Mniej graczy w rundzie i automat nie działa (przy dwóch graczach jeden trup to już połowa)
#define AUTO_CREW_WAKE_MIN_CREW 4
/// Czas na anulowanie przez admina
#define AUTO_CREW_WAKE_ADMIN_TIME (20 SECONDS)
/// Po nieudanej próbie (nikt się nie zgłosił) automat może spróbować ponownie dopiero po tym czasie
#define AUTO_CREW_WAKE_RETRY (10 MINUTES)

GLOBAL_DATUM_INIT(auto_crew_wake, /datum/auto_crew_wake, new)

/datum/auto_crew_wake
	/// Wybudzenie się udało, w tej rundzie już nic
	var/done = FALSE
	/// Trwa odliczanie albo ankieta
	var/in_progress = FALSE
	/// Trwa odliczanie, w którym admin może anulować (ankieta już tego nie pozwala)
	var/waiting_for_admin = FALSE
	/// Admin anulował trwające odliczanie
	var/cancelled = FALSE
	/// Ckey graczy, których postać z załogi zginęła w tej rundzie
	var/list/died_ckeys = list()
	COOLDOWN_DECLARE(retry_cooldown)

/// Gracze załogi i ilu z nich nie żyje: list(wszyscy, martwi). Liczy się każdy ckey raz i tylko postacie na stanowiskach
/// statku (bez ról duchów i ERT). Kto wyszedł przez kriopod i nie zginął, w ogóle się nie liczy.
/datum/auto_crew_wake/proc/count_crew()
	var/list/crew_ckeys = list()
	var/list/alive_ckeys = list()
	for(var/datum/mind/mind as anything in SSticker.minds)
		if(!mind.key || !SSjob.GetJob(mind.assigned_role))
			continue
		var/player_ckey = ckey(mind.key)
		if(!(player_ckey in GLOB.joined_player_list))
			continue
		crew_ckeys[player_ckey] = TRUE
		if(isliving(mind.current) && mind.current.stat != DEAD)
			alive_ckeys[player_ckey] = TRUE
	var/total = 0
	var/dead = 0
	for(var/player_ckey in crew_ckeys)
		if(alive_ckeys[player_ckey])
			total++
		else if(died_ckeys[player_ckey])
			total++
			dead++
	return list(total, dead)

/// Zapamiętuje śmierć postaci z załogi, żeby trup liczył się także po gibie albo zniknięciu ciała
/datum/auto_crew_wake/proc/crew_died(datum/mind/mind)
	if(mind?.key && SSjob.GetJob(mind.assigned_role))
		died_ckeys[ckey(mind.key)] = TRUE
	check()

/// Czy przy takiej liczbie graczy i trupów Centrala budzi załogę
/datum/auto_crew_wake/proc/should_wake(total, dead)
	return total >= AUTO_CREW_WAKE_MIN_CREW && dead >= total * AUTO_CREW_WAKE_DEAD_RATIO

/// Wołane po śmierci gracza
/datum/auto_crew_wake/proc/check()
	if(done || in_progress || !COOLDOWN_FINISHED(src, retry_cooldown))
		return
	if(!SSticker.IsRoundInProgress())
		return
	var/list/counts = count_crew()
	var/total = counts[1]
	var/dead = counts[2]
	if(!should_wake(total, dead))
		return
	in_progress = TRUE
	waiting_for_admin = TRUE
	cancelled = FALSE
	message_admins("Nie żyje [dead] z [total] graczy rundy. Za [DisplayTimeText(AUTO_CREW_WAKE_ADMIN_TIME)] Centrala automatycznie wybudzi załogę z kriostazy. (<a href='byond://?src=[REF(src)];cancel_auto_wake=1'>ANULUJ</a>)")
	log_game("Automatic crew wake started: [dead] of [total] round players are dead.")
	addtimer(CALLBACK(src, PROC_REF(wake)), AUTO_CREW_WAKE_ADMIN_TIME)

/datum/auto_crew_wake/proc/wake()
	waiting_for_admin = FALSE // Too late to cancel from now on
	if(cancelled)
		in_progress = FALSE
		done = TRUE // An admin decided against it, do not start again this round
		return
	// The counts may have changed during the wait (revivals)
	var/list/counts = count_crew()
	if(!should_wake(counts[1], counts[2]))
		in_progress = FALSE
		message_admins("Automatyczne wybudzenie odwołane: w czasie oczekiwania część załogi wróciła do życia.")
		return
	priority_announce("Czujniki biometryczne wykazały śmierć co najmniej połowy załogi. Rozpoczynamy awaryjne wybudzanie ochotników z kriostazy.", "Automatyczny System Awaryjny Centrali")
	var/woken = wake_crew_from_cryostasis("Procedurę awaryjnego wybudzenia uruchomiła Centrala po śmierci połowy załogi.")
	in_progress = FALSE
	if(woken)
		done = TRUE
		message_admins("Automatyczne wybudzenie: z kriostazy obudziło się [woken] graczy.")
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(priority_announce), "Z kriostazy wybudzono członków załogi: [woken].", "Automatyczny System Awaryjny Centrali"), 2 SECONDS)
		return
	COOLDOWN_START(src, retry_cooldown, AUTO_CREW_WAKE_RETRY)
	// Nobody has to die again for the next try: check once the cooldown ends
	addtimer(CALLBACK(src, PROC_REF(check)), AUTO_CREW_WAKE_RETRY + 1 SECONDS)
	message_admins("Automatyczne wybudzenie nikogo nie obudziło: [(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE) ? "żaden duch się nie zgłosił" : "role duchów są wyłączone w Ghost Pool Protection"]. Kolejna próba najwcześniej za [DisplayTimeText(AUTO_CREW_WAKE_RETRY)].")
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(priority_announce), "Procedura wybudzenia zakończona. Żaden członek załogi w kriostazie nie nadawał się do wybudzenia.", "Automatyczny System Awaryjny Centrali"), 2 SECONDS)

/datum/auto_crew_wake/Topic(href, href_list)
	. = ..()
	if(!href_list["cancel_auto_wake"] || !check_rights(R_ADMIN))
		return
	if(!waiting_for_admin || cancelled)
		to_chat(usr, "<span class='admin'>Za późno, by to anulować!</span>")
		return
	cancelled = TRUE
	message_admins("[key_name_admin(usr)] anuluje automatyczne wybudzenie załogi.")
	log_admin("[key_name(usr)] cancelled the automatic crew wake.")

#undef AUTO_CREW_WAKE_DEAD_RATIO
#undef AUTO_CREW_WAKE_MIN_CREW
#undef AUTO_CREW_WAKE_ADMIN_TIME
#undef AUTO_CREW_WAKE_RETRY
