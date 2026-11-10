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

/// Osobiste konta żywych członków działów (praca z paycheck_department), bez powtórzeń: account_id => lista kont.
/// Jedna pętla po umysłach graczy na wypłatę, niezależnie od liczby działów z premią.
/proc/department_commission_members()
	. = list()
	for(var/datum/mind/member_mind as anything in SSticker.minds)
		var/mob/living/carbon/human/member = member_mind.current
		if(!member_mind.key || !member_mind.assigned_role || !ishuman(member) || member.stat == DEAD)
			continue
		var/datum/job/job = SSjob.GetJob(member_mind.assigned_role)
		if(!job?.paycheck_department)
			continue
		var/datum/bank_account/account = member.get_personal_bank_account()
		if(!account)
			continue
		var/list/accounts = .[job.paycheck_department] || list()
		accounts |= account
		.[job.paycheck_department] = accounts

/// Osobiste konta żywych członków jednego działu
/proc/department_commission_accounts(account_id)
	var/list/members = department_commission_members()
	return members[account_id] || list()

/// Wypłaca zebrane premie i zeruje licznik. Premia działu bez żywych członków przepada.
/proc/pay_department_commissions()
	if(!length(GLOB.department_commission_pending))
		return
	var/list/members = department_commission_members()
	for(var/account_id in GLOB.department_commission_pending)
		var/pool = round(GLOB.department_commission_pending[account_id] * DEPARTMENT_COMMISSION_RATE)
		var/list/accounts = members[account_id] || list()
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

/// Dane wybuchu sprzedane przez doppler: liczy się przyrost budżetu nauki
/obj/machinery/doppler_array/research/sense_explosion(datum/source, turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
	var/datum/bank_account/science = SSeconomy.get_dep_account(ACCOUNT_SCI)
	var/before = science?.account_balance
	. = ..()
	if(science)
		add_department_commission(ACCOUNT_SCI, science.account_balance - before)

/// Spłacone grzywny idą na konto ochrony: liczy się przyrost budżetu (bez pasującej grzywny nic nie wpływa)
/datum/datacore/payCitation(id, cDataId, amount)
	var/datum/bank_account/security = SSeconomy.get_dep_account(ACCOUNT_SEC)
	var/before = security?.account_balance
	. = ..()
	if(security)
		add_department_commission(ACCOUNT_SEC, security.account_balance - before)

#undef DEPARTMENT_COMMISSION_RATE
