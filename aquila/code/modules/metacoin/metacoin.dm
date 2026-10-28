/// Konto bankowe z karty postaci, jeśli liczy się ono na koniec rundy: żywy człowiek, który się ewakuował albo ukończył patrol (aquilosy i ranking zarobków)
/client/proc/get_endround_bank_account()
	if(!mob)
		return null
	var/mob/M = mob
	if(!M.mind || isnewplayer(M) || !ishuman(M))
		return null
	if(M.stat == DEAD || isbrain(M))
		return null
	if(!GLOB.crew_transfer_risa) // wygrany patrol NSV liczy się bez ewakuacji
		if(!EMERGENCY_ESCAPED_OR_ENDGAMED)
			return null
		if(!M.onCentCom() && !M.onSyndieBase())
			return null
	var/mob/living/carbon/human/H = M
	return H.get_bank_account()

/client/proc/process_aquila_endround_metacoin()
	if(!CONFIG_GET(flag/allow_endround_bank_balance_metacoin_conversion))
		return
	var/datum/bank_account/banking_details = get_endround_bank_account()
	if(!banking_details)
		return
	var/coeff = CONFIG_GET(number/bank_balance_metacoin_conversion_coefficient)
	if(!coeff)
		coeff = 0
	inc_metabalance(FLOOR(banking_details.account_balance * coeff, 1), reason="Saldo konta bankowego przeliczono na [CONFIG_GET(string/metacurrency_name)].")
	if(banking_details.welfare)
		inc_metabalance(2 * PAYCHECK_WELFARE, reason="Premia socjalna za przeliczenie salda konta bankowego.")

/// Aquilosy za każdy wykonany cel antagonisty, niezależnie od greentextu
#define METACOIN_ANTAG_OBJECTIVE_REWARD 1000

/client/process_endround_metacoin()
	. = ..()
	var/completed = 0
	for(var/datum/antagonist/antag as anything in GLOB.antagonists)
		if(antag.owner?.key != key || antag.type == /datum/antagonist/custom)
			continue
		for(var/datum/objective/objective as anything in antag.objectives)
			if(objective.check_completion())
				completed++
	if(completed)
		inc_metabalance(completed * METACOIN_ANTAG_OBJECTIVE_REWARD, reason="Wykonane cele antagonisty: [completed].")

#undef METACOIN_ANTAG_OBJECTIVE_REWARD
