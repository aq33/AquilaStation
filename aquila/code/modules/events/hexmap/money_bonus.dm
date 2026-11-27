// AQUILA - Premia z Centrali: przelew na budżet okrętu z ogłoszeniem (port z HaloSpaceStation13 code/modules/halo/events/ueg_money_bonus.dm)
// Halo pays a UEG faction account by event severity: a clerical error refund (100-500), a funding grant (500-1500) or a
// priority defence allocation (1500-5000). We have no event severities and no factions on board, so the tier is rolled
// (60/30/10%): the refund and the allocation go to the cargo budget, which buys for the whole ship, and the grant to the
// budget of one random department. The UEG Financial Committee became the Nanotrasen Central Command finance department.

/datum/round_event_control/aquila_hex_money_bonus
	name = "Premia z Centrali"
	typepath = /datum/round_event/aquila_hex_money_bonus
	weight = 10
	max_occurrences = 2
	earliest_start = 15 MINUTES

/datum/round_event/aquila_hex_money_bonus
	fakeable = FALSE
	startWhen = 1
	announceWhen = 1
	/// "refund", "grant" or "priority"
	var/tier
	/// Credits paid
	var/amount = 0
	/// Department account id (ACCOUNT_*) that gets the money
	var/account_id = ACCOUNT_CAR
	/// The money was paid
	var/paid = FALSE

/datum/round_event/aquila_hex_money_bonus/setup()
	roll_bonus(pick(60; "refund", 30; "grant", 10; "priority"))

/// Sets the tier, the amount and the account of the bonus
/datum/round_event/aquila_hex_money_bonus/proc/roll_bonus(new_tier)
	tier = new_tier
	account_id = ACCOUNT_CAR
	switch(tier)
		if("refund")
			amount = rand(1, 5) * 100
		if("grant")
			amount = rand(1, 3) * 500
			account_id = pick(ACCOUNT_ENG, ACCOUNT_MED, ACCOUNT_SCI, ACCOUNT_SRV, ACCOUNT_SEC, ACCOUNT_MUN)
		if("priority")
			amount = rand(3, 10) * 500

/datum/round_event/aquila_hex_money_bonus/start()
	var/datum/bank_account/department/account = SSeconomy.get_dep_account(account_id)
	if(!account)
		log_game("Money Bonus: no [account_id] account, cancelling the event.")
		return kill()
	account.adjust_money(amount)
	paid = TRUE
	log_game("Money Bonus: [amount] cr ([tier]) paid to [account.account_holder].")

/// Polish name of the account that gets the money
/datum/round_event/aquila_hex_money_bonus/proc/budget_name()
	switch(account_id)
		if(ACCOUNT_CAR)
			return "budżet zaopatrzenia"
		if(ACCOUNT_ENG)
			return "budżet inżynierii"
		if(ACCOUNT_MED)
			return "budżet medyczny"
		if(ACCOUNT_SCI)
			return "budżet działu badań"
		if(ACCOUNT_SRV)
			return "budżet usług"
		if(ACCOUNT_SEC)
			return "budżet ochrony"
		if(ACCOUNT_MUN)
			return "budżet amunicji"
	return "budżet okrętu"

/datum/round_event/aquila_hex_money_bonus/announce(fake)
	if(!paid && !fake)
		return
	var/budget = budget_name()
	switch(tier)
		if("refund")
			priority_announce("Wykryliśmy błąd księgowy na niekorzyść okrętu i zwróciliśmy [amount] kr na konto: [budget]. Przepraszamy za utrudnienia i prosimy nie pytać, jak do niego doszło.", "Dział Finansów Centrali")
		if("grant")
			priority_announce("Zatwierdzono dodatkowe finansowanie działań okrętu: [amount] kr wpłynęło na konto: [budget]. Prosimy wydać je rozsądnie, czyli nie na automat z kawą.", "Dział Finansów Centrali")
		if("priority")
			priority_announce("Dowództwo uznało obronę tego sektora za priorytetową i zwiększyło budżet okrętu o [amount] kr (konto: [budget]). Oczekujemy wyników.", "Dział Finansów Centrali")
