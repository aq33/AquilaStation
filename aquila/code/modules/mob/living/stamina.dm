// Port BeeStation/BeeStation-Hornet#14750: stamina jako jedna pula na mobie zamiast staminy per kończyna.
// Różnice względem Bee:
// - zostaje warstwa zgodności: getStaminaLoss/adjustStaminaLoss/setStaminaLoss działają dalej i idą do puli
//   (Bee je usuwa i przepisuje ~200 wywołań), a stamina przekazana do heal/take i kończyn trafia do puli (AQ EDIT w core)
// - stamcrit to status z Bee, ale zamiast cech mobilności ustawia nasze stam_paralyzed (IsParalyzed, update_mobility)
// - wyczerpanie robi to samo co w Bee: bez sprintu, tylko szept, spowolnienie

/mob/living/Initialize(mapload)
	// Przed ..(), bo inicjalizacja moba potrafi już zadawać albo leczyć staminę
	stamina = new(src)
	return ..()

/mob/living/Destroy()
	QDEL_NULL(stamina)
	return ..()

/mob/living/revive(full_heal = FALSE, admin_revive = FALSE)
	. = ..()
	stamina?.resume()

/mob/living/death(gibbed)
	. = ..()
	stamina?.update()

///Ostatnia zmiana przed odjęciem/dodaniem staminy. Zwraca zmianę po modyfikacjach (0 = odporny).
/mob/living/proc/pre_stamina_change(diff, forced)
	if(!forced && (status_flags & GODMODE))
		return 0
	return diff

/mob/living/carbon/alien/pre_stamina_change(diff, forced)
	return 0

/mob/living/silicon/pre_stamina_change(diff, forced)
	return 0

/mob/living/simple_animal/pre_stamina_change(diff, forced)
	. = ..()
	if(!forced && diff < 0)
		. *= damage_coeff?[STAMINA] || 0

///Czy mob może w ogóle stracić staminę
/mob/living/proc/takes_stamina_damage()
	return pre_stamina_change(-1) != 0

///Czy mob jest w stamcricie
/mob/living/proc/is_stamcrit()
	return FALSE

/mob/living/carbon/is_stamcrit()
	return stam_paralyzed

/mob/living/proc/on_stamina_update()
	return

/mob/living/proc/on_stamina_loss()
	return

/mob/living/proc/stamina_stun()
	return

///Atakujący płaci za zamach, ale tylko dopóki po nim zostaje ponad STAMINA_MAXIMUM_TO_SWING (niżej zamachy są darmowe)
/mob/living/proc/stamina_swing(cost)
	if(!stamina || !cost)
		return
	if((stamina.current - cost) > STAMINA_MAXIMUM_TO_SWING)
		stamina.adjust(-cost, TRUE)

// ---------------------------------------------------------------------------
// Warstwa zgodności ze starym API (getStaminaLoss = brakująca stamina)

/mob/living/proc/stamina_loss_compat()
	return stamina ? stamina.loss : 0

/mob/living/proc/adjust_stamina_loss_compat(amount, forced)
	if(!stamina || !amount)
		return 0
	return -stamina.adjust(-amount, forced)

/mob/living/proc/set_stamina_loss_compat(amount, forced)
	if(!stamina)
		return
	if(amount <= 0)
		stamina.refill()
		remove_status_effect(STATUS_EFFECT_STAMCRIT)
		return
	stamina.adjust((stamina.maximum - amount) - stamina.current, forced)

/mob/living/getStaminaLoss()
	return stamina_loss_compat()

/mob/living/adjustStaminaLoss(amount, updating_health = TRUE, forced = FALSE)
	return adjust_stamina_loss_compat(amount, forced)

/mob/living/setStaminaLoss(amount, updating_health = TRUE, forced = FALSE)
	return set_stamina_loss_compat(amount, forced)

// Pełne nadpisania wersji z code/modules/mob/living/carbon/damage_procs.dm (tam stamina była sumą kończyn)
/mob/living/carbon/getStaminaLoss()
	return stamina_loss_compat()

/mob/living/carbon/adjustStaminaLoss(amount, updating_health = TRUE, forced = FALSE)
	return adjust_stamina_loss_compat(amount, forced)

/mob/living/carbon/setStaminaLoss(amount, updating_health = TRUE, forced = FALSE)
	return set_stamina_loss_compat(amount, forced)

// Stary stamcrit (carbon.dm) liczył próg od staminy kończyn; teraz decyduje stamina_stun()
/mob/living/carbon/update_stamina(extend_stam_crit = FALSE)
	update_stamina_hud()

// ---------------------------------------------------------------------------
// Wyczerpanie i stamcrit

/mob/living/carbon/on_stamina_update()
	var/fraction = stamina.get_fraction()
	var/exhausted = HAS_TRAIT_FROM(src, TRAIT_EXHAUSTED, STAMINA_TRAIT)
	var/no_stamcrit = HAS_TRAIT(src, TRAIT_NOSTAMCRIT)
	if(!exhausted && !no_stamcrit && stat != DEAD && fraction < STAMINA_EXHAUSTION_THRESHOLD_MODIFIER)
		ADD_TRAIT(src, TRAIT_EXHAUSTED, STAMINA_TRAIT)
		ADD_TRAIT(src, TRAIT_WHISPER_ONLY, STAMINA_TRAIT)
		add_movespeed_modifier(MOVESPEED_ID_SPRINT_EXHAUSTION, TRUE, 0, override = TRUE, multiplicative_slowdown = STAMINA_EXHAUSTION_MOVESPEED_SLOWDOWN)
		to_chat(src, "<span class='danger'>Jesteś wyczerpany. Nie możesz sprintować i możesz tylko szeptać, dopóki nie złapiesz oddechu.</span>")
	else if(exhausted && (no_stamcrit || stat == DEAD || fraction > STAMINA_EXHAUSTION_RECOVERY_THRESHOLD_MODIFIER))
		REMOVE_TRAIT(src, TRAIT_EXHAUSTED, STAMINA_TRAIT)
		REMOVE_TRAIT(src, TRAIT_WHISPER_ONLY, STAMINA_TRAIT)
		remove_movespeed_modifier(MOVESPEED_ID_SPRINT_EXHAUSTION)
		if(stat != DEAD)
			to_chat(src, "<span class='notice'>Łapiesz oddech.</span>")
	update_stamina_hud()

/mob/living/carbon/on_stamina_loss()
	if((stamina.current < stamina.maximum * STAMINA_STUN_THRESHOLD_MODIFIER) && stat <= SOFT_CRIT)
		stamina_stun()

/mob/living/carbon/stamina_stun()
	var/threshold = stamina.maximum * STAMINA_STUN_THRESHOLD_MODIFIER
	var/chance = STAMINA_SCALING_STUN_BASE + STAMINA_SCALING_STUN_SCALER * (1 - stamina.current / threshold)
	if(prob(chance))
		apply_status_effect(STATUS_EFFECT_STAMCRIT)

// Softcrit zmniejsza pulę i regenerację (w Bee przez cechę TRAIT_SOFT_CRITICAL_CONDITION)
/mob/living/carbon/updatehealth()
	. = ..()
	if(!stamina)
		return
	if(stat == SOFT_CRIT)
		stamina.add_max_modifier("softcrit", STAMINA_SOFTCRIT_MAX_MODIFIER)
		stamina.add_regen_modifier("softcrit", STAMINA_SOFTCRIT_REGEN_MODIFIER)
	else
		stamina.remove_max_modifier("softcrit")
		stamina.remove_regen_modifier("softcrit")

/// Stamina stun (port code/datums/status_effects/debuffs/stamcrit.dm)
/datum/status_effect/incapacitating/stamcrit
	id = "stamcrit"
	status_type = STATUS_EFFECT_UNIQUE
	duration = STAMINA_STUN_TIME

/datum/status_effect/incapacitating/stamcrit/on_apply()
	if(!iscarbon(owner) || owner.stat == DEAD)
		return FALSE
	if(!(owner.status_flags & CANKNOCKDOWN) || HAS_TRAIT(owner, TRAIT_STUNIMMUNE) || HAS_TRAIT(owner, TRAIT_NOSTAMCRIT))
		return FALSE
	if(owner.absorb_stun(0))
		return FALSE
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/C = owner
	C.stam_paralyzed = TRUE
	owner.visible_message("<span class='danger'>[owner] osuwa się, zbyt słaby, żeby dalej walczyć...</span>", \
		"<span class='userdanger'>Jesteś zbyt wyczerpany, żeby dalej walczyć...</span>", \
		"<span class='hear'>Słyszysz, jak coś upada na podłogę.</span>")
	owner.add_filter("stamcrit", 1, drop_shadow_filter(x = 0, y = 0, size = -3, color = "#04080F"))
	owner.log_message("was stamina stunned", LOG_ATTACK)
	owner.update_mobility()
	owner.update_stamina_hud()

/datum/status_effect/incapacitating/stamcrit/on_remove()
	var/mob/living/carbon/C = owner
	if(istype(C))
		C.stam_paralyzed = FALSE
	owner.remove_filter("stamcrit")
	owner.update_stamina_hud()
	return ..()

// ---------------------------------------------------------------------------
// Kończyny nie wyłączają się już od staminy. Mechaniki, które tego używały (dźwignia MAA z NSV13),
// unieruchamiają kończynę na chwilę wprost.

///Unieruchamia kończynę w danej strefie na podany czas
/mob/living/carbon/proc/disable_limb_temporarily(zone, duration, source = "temporary_disable")
	var/obj/item/bodypart/limb = get_bodypart(check_zone(zone))
	if(!limb)
		return FALSE
	ADD_TRAIT(limb, TRAIT_PARALYSIS, source)
	limb.update_disabled()
	addtimer(CALLBACK(src, PROC_REF(enable_limb), limb, source), duration, TIMER_UNIQUE | TIMER_OVERRIDE)
	return TRUE

/mob/living/carbon/proc/enable_limb(obj/item/bodypart/limb, source)
	if(QDELETED(limb))
		return
	REMOVE_TRAIT(limb, TRAIT_PARALYSIS, source)
	limb.update_disabled()
