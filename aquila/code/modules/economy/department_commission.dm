// AQUILA - premia działu: część tego, co dział zarobił pracą (sprzedaż artefaktów, uratowana załoga, energia, eksport,
// nagrody misji, grzywny), trafia przy wypłacie na osobiste konta żywych członków działu. Premia to nowe pieniądze:
// budżet działu dostaje pełną kwotę jak dotąd. Wypłaty pensji i przelewy się nie liczą, liczą się tylko miejsca,
// które wołają add_department_commission().

/// Jaka część zarobku działu idzie na premię dla jego członków
#define DEPARTMENT_COMMISSION_RATE 0.2

/// account_id działu => kredyty zarobione pracą od ostatniej wypłaty
GLOBAL_LIST_EMPTY(department_commission_pending)

/// Dopisuje zarobek działu do premii najbliższej wypłaty
/proc/add_department_commission(account_id, income)
	if(!account_id || !isnum(income) || income <= 0)
		return
	GLOB.department_commission_pending[account_id] += income

/// Odmiana nazwy działu w komunikacie o premii
/proc/department_commission_name(account_id)
	var/static/list/names = list(
		ACCOUNT_CIV = "cywilnego",
		ACCOUNT_ENG = "inżynierii",
		ACCOUNT_SCI = "nauki",
		ACCOUNT_MED = "medycyny",
		ACCOUNT_SRV = "obsługi",
		ACCOUNT_CAR = "zaopatrzenia",
		ACCOUNT_SEC = "ochrony",
		ACCOUNT_MUN = "uzbrojenia",
	)
	return names[account_id] || "działu"

/// Osobiste konta żywych członków działu (praca z paycheck_department tego działu), bez powtórzeń
/proc/department_commission_accounts(account_id)
	. = list()
	for(var/mob/living/carbon/human/member in GLOB.alive_mob_list)
		var/datum/mind/member_mind = member.mind
		if(!member_mind?.key || !member_mind.assigned_role)
			continue
		var/datum/job/job = SSjob.GetJob(member_mind.assigned_role)
		if(job?.paycheck_department != account_id)
			continue
		var/datum/bank_account/account = member.get_personal_bank_account()
		if(account)
			. |= account

/// Wypłaca zebrane premie i zeruje licznik. Premia działu bez żywych członków przepada.
/proc/pay_department_commissions()
	for(var/account_id in GLOB.department_commission_pending)
		var/pool = round(GLOB.department_commission_pending[account_id] * DEPARTMENT_COMMISSION_RATE)
		var/list/accounts = department_commission_accounts(account_id)
		if(pool <= 0 || !length(accounts))
			continue
		var/share = round(pool / length(accounts))
		if(share <= 0)
			continue
		for(var/datum/bank_account/account as anything in accounts)
			account.adjust_money(share)
			account.bank_card_talk("Premia działu [department_commission_name(account_id)] za pracę działu: [share] kr.")
		log_game("Department commission: [share] cr each to [length(accounts)] members of [account_id] (pool [pool] cr)")
	GLOB.department_commission_pending.Cut()

/datum/controller/subsystem/economy/fire(resumed = 0)
	. = ..()
	pay_department_commissions()

// --- Źródła zarobku działów spoza aquila/ ---

/// Eksport promem zaopatrzenia
/obj/docking_port/mobile/supply/sell()
	var/datum/bank_account/cargo = SSeconomy.get_dep_account(ACCOUNT_CAR)
	var/before = cargo?.account_balance
	. = ..()
	if(cargo)
		add_department_commission(ACCOUNT_CAR, cargo.account_balance - before)

/// Nagroda Dowództwa Marynarki za misje i zniszczone okręty, dzielona na zaopatrzenie i uzbrojenie
/datum/controller/subsystem/star_system/bounty_payout()
	var/pool = bounty_pool
	. = ..()
	if(pool && !bounty_pool)
		add_department_commission(ACCOUNT_CAR, pool / 2)
		add_department_commission(ACCOUNT_MUN, pool / 2)

/// Spłacone grzywny idą na konto ochrony
/datum/datacore/payCitation(id, cDataId, amount)
	. = ..()
	add_department_commission(ACCOUNT_SEC, amount)

#undef DEPARTMENT_COMMISSION_RATE
