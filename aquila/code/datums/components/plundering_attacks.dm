// AQUILA: port of tgstation code/datums/components/plundering_attacks.dm (tg 926bf40c5a) for the pirates.
// COMSIG_HOSTILE_POST_ATTACKINGTARGET comes from /mob/living/basic/proc/melee_attack() (aquila/code/modules/mob/living/basic/basic.dm).
/**
 * Component that makes basic mobs' melee attacks steal money from the target's ID card.
 * Plundered money is stored and dropped on death or removal of the component.
 */
/datum/component/plundering_attacks
	/// How many credits do we steal per attack?
	var/plunder_amount = 25
	/// How much plunder do we have stored?
	var/plunder_stored = 0

/datum/component/plundering_attacks/Initialize(plunder_amount = 25)
	. = ..()
	if(!isbasicmob(parent))
		return COMPONENT_INCOMPATIBLE

	src.plunder_amount = plunder_amount

/datum/component/plundering_attacks/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_HOSTILE_POST_ATTACKINGTARGET, PROC_REF(attempt_plunder))
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(drop_plunder))

/datum/component/plundering_attacks/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_HOSTILE_POST_ATTACKINGTARGET, COMSIG_LIVING_DEATH))
	drop_plunder()

/datum/component/plundering_attacks/proc/attempt_plunder(mob/living/attacker, mob/living/carbon/human/target, success)
	SIGNAL_HANDLER
	if(!istype(target) || !success)
		return
	var/obj/item/card/id/id_card = target.wear_id?.GetID()
	if(isnull(id_card))
		return
	var/datum/bank_account/account_to_rob = id_card.registered_account
	if(isnull(account_to_rob) || account_to_rob.account_balance <= 0)
		return

	var/amount_to_steal = min(plunder_amount, account_to_rob.account_balance) //If there isn't enough, just take what's left
	plunder_stored += amount_to_steal
	account_to_rob.adjust_money(-amount_to_steal)
	account_to_rob.bank_card_talk("Transakcja potwierdzona! Przelano [amount_to_steal] kr na nieznane konto!")

/datum/component/plundering_attacks/proc/drop_plunder()
	SIGNAL_HANDLER
	if(plunder_stored <= 0)
		return
	var/turf/drop_turf = get_turf(parent)
	if(drop_turf)
		new /obj/item/holochip(drop_turf, plunder_stored)
	plunder_stored = 0
