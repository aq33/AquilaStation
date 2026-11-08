/// Konta już przypisane na koniec rundy: numer konta => ckey gracza, któremu się liczy
GLOBAL_LIST_EMPTY(endround_claimed_bank_accounts)

/// Osobiste konto postaci (z przydziału pracy), nigdy budżet działu. Karta trzymana w ręce nie ma znaczenia,
/// bo karta działu albo karta podpięta pod cudze konto dawała w aquilosach i rankingu cudze pieniądze.
/mob/living/carbon/human/proc/get_personal_bank_account()
	RETURN_TYPE(/datum/bank_account)
	var/datum/bank_account/account = find_bank_account_by_id(account_id)
	if(istype(account, /datum/bank_account/department))
		return null
	return account

/// Rezerwuje konto dla gracza na koniec rundy. Każde konto liczy się tylko jednemu graczowi (np. klon z tym samym kontem).
/// Zwraca konto albo null, gdy należy już do kogoś innego. reserve = FALSE tylko sprawdza, nie rezerwując.
/proc/claim_endround_bank_account(datum/bank_account/account, claimer_ckey, reserve = TRUE)
	if(!account || !claimer_ckey)
		return null
	var/owner = GLOB.endround_claimed_bank_accounts["[account.account_id]"]
	if(owner && owner != claimer_ckey)
		return null
	if(reserve)
		GLOB.endround_claimed_bank_accounts["[account.account_id]"] = claimer_ckey
	return account

/// Osobiste konto postaci, jeśli liczy się ono na koniec rundy: żywy człowiek, który się ewakuował albo ukończył patrol (aquilosy i ranking zarobków)
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
	return claim_endround_bank_account(H.get_personal_bank_account(), ckey)

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
#define METACOIN_ANTAG_OBJECTIVE_REWARD 500

/client/process_endround_metacoin()
	. = ..()
	/// Cele zawsze zaliczone (fabularne, bez warunku) - nie dają aquilosów
	var/static/list/always_completed_objectives = typecacheof(list(
		/datum/objective/gimmick,
		/datum/objective/lunatic,
		/datum/objective/revenantFluff,
		/datum/objective/chaos
	))
	var/completed = 0
	for(var/datum/antagonist/antag as anything in GLOB.antagonists)
		if(antag.owner?.key != key || antag.type == /datum/antagonist/custom)
			continue
		if(istype(antag, /datum/antagonist/ert)) // ERT wysyła admin, a cel misji jest zaliczony z góry: bez aquilosów za tę rolę
			continue
		for(var/datum/objective/objective as anything in antag.objectives)
			if(objective.optional || is_type_in_typecache(objective, always_completed_objectives))
				continue
			if(objective.check_completion())
				completed++
	if(completed)
		inc_metabalance(completed * METACOIN_ANTAG_OBJECTIVE_REWARD, reason="Wykonane cele antagonisty: [completed].")

#undef METACOIN_ANTAG_OBJECTIVE_REWARD
