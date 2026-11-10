// AQUILA - Ciecze: zbieranie kałuż (Monke: liquid_interaction.dm, mop.dm, reagent_containers.dm, _cup.dm).
// U nas zamiast komponentu liquids_interaction (sygnał item_interaction z nowego tg) nadpisania afterattack.

/// Sygnały z /obj/item/afterattack(), gdy nadpisanie kończy się bez ..() (peleryna wampira, heretyk i inni słuchacze)
/obj/item/proc/send_afterattack_signals(atom/target, mob/user, proximity)
	SEND_SIGNAL(src, COMSIG_ITEM_AFTERATTACK, target, user, proximity)
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_AFTERATTACK, target, src, proximity)
	SEND_SIGNAL(target, COMSIG_ATOM_AFTER_ATTACKEDBY, src, user, proximity)

/// Mop wsiąka ciecz z kałuży (5 j. na ruch, coraz szybciej), a pełny wyciska się do wiadra prawym przyciskiem.
/// Zamarzniętej kałuży nie wsiąka, więc wtedy myje podłogę jak zwykle (plamy pod lodem).
/obj/item/mop/afterattack(atom/A, mob/user, proximity)
	var/turf/T = get_turf(A)
	if(proximity && T && !QDELETED(T.liquids) && !T.liquids.liquid_group?.frozen && !istype(A, /obj/item/reagent_containers/glass/bucket) && !istype(A, /obj/structure/janitorialcart))
		send_afterattack_signals(A, user, proximity)
		INVOKE_ASYNC(src, PROC_REF(soak_liquids), T, user)
		return
	return ..()

/obj/item/mop/proc/soak_liquids(turf/target, mob/user)
	if(mopping)
		return
	var/speed_mult = 1
	var/datum/liquid_group/targeted_group = target?.liquids?.liquid_group
	mopping = TRUE
	while(!QDELETED(targeted_group))
		if(targeted_group.frozen)
			to_chat(user, "<span class='warning'>Lodu nie da się zebrać mopem!</span>")
			break
		if(speed_mult >= 0.2)
			speed_mult -= 0.05
		if(reagents.total_volume >= reagents.maximum_volume)
			to_chat(user, "<span class='warning'>[src] nie wchłonie już więcej. Wyciśnij go do wiadra ([user.secondary_click_text()]).</span>")
			break
		if(!do_after(user, mopspeed * speed_mult, target = target))
			break
		if(targeted_group?.reagents_per_turf)
			targeted_group.trans_to_seperate_group(reagents, min(targeted_group.reagents_per_turf, 5, reagents.maximum_volume - reagents.total_volume), target.liquids)
			to_chat(user, "<span class='notice'>Wchłaniasz trochę cieczy [src].</span>")
		if(QDELETED(targeted_group) && !QDELETED(target?.liquids?.liquid_group))
			targeted_group = target.liquids.liquid_group
	mopping = FALSE
	user.changeNext_move(CLICK_CD_MELEE)

/// Wyciskanie mopa do wiadra (Monke: bucket/attackby_secondary): ćwierć pojemności trafia do wiadra, reszta wsiąka w szmatę
/obj/item/reagent_containers/glass/bucket/attackby_secondary(obj/item/weapon, mob/user, params)
	if(!istype(weapon, /obj/item/mop))
		return ..()
	var/obj/item/mop/attacked_mop = weapon
	if(reagents.holder_full())
		to_chat(user, "<span class='warning'>[src] jest pełne.</span>")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(attacked_mop.reagents.total_volume < 0.1)
		to_chat(user, "<span class='warning'>[attacked_mop] jest już suchy!</span>")
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	to_chat(user, "<span class='notice'>Wyciskasz [attacked_mop] do [src].</span>")
	playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)
	attacked_mop.reagents.trans_to(src, attacked_mop.reagents.maximum_volume * 0.25, transfered_by = user)
	attacked_mop.reagents.clear_reagents()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// Zlewki, wiadra i inne naczynia nabierają ciecz z kałuży (poza combat mode; w combat mode chlustają jak dotąd)
/obj/item/reagent_containers/glass/afterattack(obj/target, mob/user, proximity)
	if(proximity && spillable && isturf(target) && !user.combat_mode)
		var/turf/T = target
		if(!QDELETED(T.liquids))
			send_afterattack_signals(target, user, proximity)
			scoop_liquids(T, user)
			return
	return ..()

/obj/item/reagent_containers/glass/proc/scoop_liquids(turf/T, mob/living/user)
	var/datum/liquid_group/group = T.liquids?.liquid_group
	if(QDELETED(group))
		return
	if(group.frozen)
		to_chat(user, "<span class='warning'>Ciecz zamarzła, nie da się jej nabrać.</span>")
		return
	if(group.group_overlay_state <= LIQUID_STATE_PUDDLE && group.reagents_per_turf < 1)
		to_chat(user, "<span class='warning'>Tu jest za płytko, żeby cokolwiek nabrać.</span>")
		return
	var/free_space = reagents.maximum_volume - reagents.total_volume
	if(free_space <= 0)
		to_chat(user, "<span class='warning'>[src] jest pełny.</span>")
		return
	var/desired_transfer = min(amount_per_transfer_from_this, free_space, group.reagents_per_turf)
	group.trans_to_seperate_group(reagents, desired_transfer, T.liquids)
	reagents.handle_reactions() // przelanie z kałuży idzie z no_react, a zawartość naczynia ma zareagować z nabraną cieczą
	to_chat(user, "<span class='notice'>Nabierasz około [round(desired_transfer)] j. cieczy do [src].</span>")
	playsound(src, 'sound/effects/slosh.ogg', 15, TRUE)
