//Programs that heal the host in some way.

/datum/nanite_program/regenerative
	name = "Przyspieszona regeneracja"
	desc = "Nanity wzmacniają naturalną regenerację nosiciela, przyspieszając gojenie. Nie zużywa nanitów, gdy nosiciel nie jest ranny."
	use_rate = 0.5
	rogue_types = list(/datum/nanite_program/necrotic)

/datum/nanite_program/regenerative/check_conditions()
	if(!host_mob.getBruteLoss() && !host_mob.getFireLoss())
		return FALSE
	if(iscarbon(host_mob))
		var/mob/living/carbon/C = host_mob
		var/list/parts = C.get_damaged_bodyparts(TRUE,TRUE, status = BODYTYPE_ORGANIC)
		if(!parts.len)
			return FALSE
	return ..()

/datum/nanite_program/regenerative/active_effect()
	if(iscarbon(host_mob))
		var/mob/living/carbon/C = host_mob
		var/list/parts = C.get_damaged_bodyparts(TRUE,TRUE, status = BODYTYPE_ORGANIC)
		if(!parts.len)
			return
		for(var/obj/item/bodypart/L in parts)
			if(L.heal_damage(0.5/parts.len, 0.5/parts.len, null, BODYTYPE_ORGANIC))
				host_mob.update_damage_overlays()
	else
		host_mob.adjustBruteLoss(-0.5, TRUE)
		host_mob.adjustFireLoss(-0.5, TRUE)

/datum/nanite_program/temperature
	name = "Regulacja temperatury"
	desc = "Nanity ustawiają temperaturę wewnętrzną nosiciela na idealnym poziomie."
	use_rate = 3.5
	rogue_types = list(/datum/nanite_program/skin_decay)

/datum/nanite_program/temperature/check_conditions()
	if(host_mob.bodytemperature > (BODYTEMP_NORMAL - 30) && host_mob.bodytemperature < (BODYTEMP_NORMAL + 30))
		return FALSE
	return ..()

/datum/nanite_program/temperature/active_effect()
	if(host_mob.bodytemperature > BODYTEMP_NORMAL)
		host_mob.adjust_bodytemperature(-40 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	else if(host_mob.bodytemperature < (BODYTEMP_NORMAL + 1))
		host_mob.adjust_bodytemperature(40 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)

/datum/nanite_program/purging
	name = "Oczyszczanie krwi"
	desc = "Nanity usuwają toksyny i chemikalia z krwiobiegu nosiciela."
	use_rate = 1
	rogue_types = list(/datum/nanite_program/suffocating, /datum/nanite_program/necrotic)

/datum/nanite_program/purging/check_conditions()
	var/foreign_reagent = length(host_mob.reagents?.reagent_list)
	if(!host_mob.getToxLoss() && !foreign_reagent)
		return FALSE
	return ..()

/datum/nanite_program/purging/active_effect()
	host_mob.adjustToxLoss(-1)
	for(var/datum/reagent/R in host_mob.reagents.reagent_list)
		host_mob.reagents.remove_reagent(R.type,1)

/datum/nanite_program/brain_heal
	name = "Regeneracja neuronów"
	desc = "Nanity naprawiają połączenia nerwowe w mózgu nosiciela, cofając uszkodzenia mózgu i drobne urazy."
	use_rate = 1.5
	rogue_types = list(/datum/nanite_program/brain_decay)

/datum/nanite_program/brain_heal/check_conditions()
	var/problems = FALSE
	if(iscarbon(host_mob))
		var/mob/living/carbon/C = host_mob
		if(length(C.get_traumas()))
			problems = TRUE
	if(host_mob.getOrganLoss(ORGAN_SLOT_BRAIN) > 0)
		problems = TRUE
	return problems ? ..() : FALSE

/datum/nanite_program/brain_heal/active_effect()
	host_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1)
	if(iscarbon(host_mob) && prob(10))
		var/mob/living/carbon/C = host_mob
		C.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC)

/datum/nanite_program/blood_restoring
	name = "Regeneracja krwi"
	desc = "Nanity pobudzają i wzmacniają wytwarzanie krwinek u nosiciela."
	use_rate = 1
	rogue_types = list(/datum/nanite_program/suffocating)

/datum/nanite_program/blood_restoring/check_conditions()
	if(iscarbon(host_mob))
		var/mob/living/carbon/C = host_mob
		if(C.blood_volume >= BLOOD_VOLUME_SAFE)
			return FALSE
	else
		return FALSE
	return ..()

/datum/nanite_program/blood_restoring/active_effect()
	if(iscarbon(host_mob))
		var/mob/living/carbon/C = host_mob
		C.blood_volume += 2

/datum/nanite_program/repairing
	name = "Naprawa mechaniczna"
	desc = "Nanity naprawiają uszkodzenia mechanicznych kończyn nosiciela."
	use_rate = 0.5
	rogue_types = list(/datum/nanite_program/necrotic)

/datum/nanite_program/repairing/check_conditions()
	if(!host_mob.getBruteLoss() && !host_mob.getFireLoss())
		return FALSE

	if(iscarbon(host_mob))
		var/mob/living/carbon/C = host_mob
		var/list/parts = C.get_damaged_bodyparts(TRUE, TRUE, status = BODYTYPE_ROBOTIC)
		if(!parts.len)
			return FALSE
	else
		if(!(host_mob.mob_biotypes & MOB_ROBOTIC))
			return FALSE
	return ..()

/datum/nanite_program/repairing/active_effect(mob/living/M)
	if(iscarbon(host_mob))
		var/mob/living/carbon/C = host_mob
		var/list/parts = C.get_damaged_bodyparts(TRUE, TRUE, status = BODYTYPE_ROBOTIC)
		if(!parts.len)
			return
		var/update = FALSE
		for(var/obj/item/bodypart/L in parts)
			if(L.heal_damage(1.5/parts.len, 1.5/parts.len, null, BODYTYPE_ROBOTIC)) //much faster than organic healing
				update = TRUE
		if(update)
			host_mob.update_damage_overlays()
	else
		host_mob.adjustBruteLoss(-1.5, TRUE)
		host_mob.adjustFireLoss(-1.5, TRUE)

/datum/nanite_program/purging_advanced
	name = "Wybiórcze oczyszczanie krwi"
	desc = "Nanity usuwają toksyny i niebezpieczne chemikalia z krwiobiegu nosiciela, pomijając te korzystne. \
			Dodatkowa moc obliczeniowa potrzebna do analizy chemikaliów znacznie zwiększa zużycie nanitów."
	use_rate = 2
	rogue_types = list(/datum/nanite_program/suffocating, /datum/nanite_program/necrotic)

/datum/nanite_program/purging_advanced/check_conditions()
	var/foreign_reagent = FALSE
	for(var/datum/reagent/toxin/R in host_mob.reagents.reagent_list)
		foreign_reagent = TRUE
		break
	if(!host_mob.getToxLoss() && !foreign_reagent)
		return FALSE
	return ..()

/datum/nanite_program/purging_advanced/active_effect()
	host_mob.adjustToxLoss(-1)
	for(var/datum/reagent/toxin/R in host_mob.reagents.reagent_list)
		host_mob.reagents.remove_reagent(R.type,1)

/datum/nanite_program/regenerative_advanced
	name = "Biorekonstrukcja"
	desc = "Nanity ręcznie naprawiają i wymieniają komórki organiczne, działając znacznie szybciej niż zwykła regeneracja. \
			Program nie odróżnia jednak tkanek uszkodzonych od zdrowych, więc zużywa nanity nawet wtedy, gdy nic nie daje."
	use_rate = 5.5
	rogue_types = list(/datum/nanite_program/suffocating, /datum/nanite_program/necrotic)

/datum/nanite_program/regenerative_advanced/active_effect()
	if(iscarbon(host_mob))
		var/mob/living/carbon/C = host_mob
		var/list/parts = C.get_damaged_bodyparts(TRUE,TRUE, status = BODYTYPE_ORGANIC)
		if(!parts.len)
			return
		var/update = FALSE
		for(var/obj/item/bodypart/L in parts)
			if(L.heal_damage(3/parts.len, 3/parts.len, null, BODYTYPE_ORGANIC))
				update = TRUE
		if(update)
			host_mob.update_damage_overlays()
	else
		host_mob.adjustBruteLoss(-3, TRUE)
		host_mob.adjustFireLoss(-3, TRUE)

/datum/nanite_program/brain_heal_advanced
	name = "Odtwarzanie połączeń nerwowych"
	desc = "Nanity potrafią zapisać kopię połączeń nerwowych nosiciela i je odtworzyć, zastępując nawet całe fragmenty brakującej lub uszkodzonej tkanki mózgowej."
	use_rate = 3
	rogue_types = list(/datum/nanite_program/brain_decay, /datum/nanite_program/brain_misfire)

/datum/nanite_program/brain_heal_advanced/check_conditions()
	var/problems = FALSE
	if(iscarbon(host_mob))
		var/mob/living/carbon/C = host_mob
		if(length(C.get_traumas()))
			problems = TRUE
	if(host_mob.getOrganLoss(ORGAN_SLOT_BRAIN) > 0)
		problems = TRUE
	return problems ? ..() : FALSE

/datum/nanite_program/brain_heal_advanced/active_effect()
	host_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -2)
	if(iscarbon(host_mob) && prob(10))
		var/mob/living/carbon/C = host_mob
		C.cure_trauma_type(resilience = TRAUMA_RESILIENCE_LOBOTOMY)

/datum/nanite_program/defib
	name = "Defibrylacja"
	desc = "Po aktywacji nanity porażają serce nosiciela, przywracając go do życia, jeśli ciało jest w stanie to znieść."
	can_trigger = TRUE
	trigger_cost = 25
	trigger_cooldown = 120
	rogue_types = list(/datum/nanite_program/shocking)

/datum/nanite_program/defib/on_trigger(comm_message)
	host_mob.notify_ghost_cloning("Twoje serce jest defibrylowane przez nanity. Wróć do swojego ciała, jeśli chcesz zostać wskrzeszony!")
	addtimer(CALLBACK(src, PROC_REF(zap)), 50)

/datum/nanite_program/defib/proc/check_revivable()
	if(!iscarbon(host_mob)) //nonstandard biology
		return FALSE
	var/mob/living/carbon/C = host_mob
	if(C.suiciding || C.ishellbound() || HAS_TRAIT(C, TRAIT_HUSK)) //can't revive
		return FALSE
	if((world.time - C.timeofdeath) > 1800) //too late
		return FALSE
	if((C.getBruteLoss() >= MAX_REVIVE_BRUTE_DAMAGE) || (C.getFireLoss() >= MAX_REVIVE_FIRE_DAMAGE) || !C.can_be_revived()) //too damaged
		return FALSE
	if(!C.getorgan(/obj/item/organ/heart)) //what are we even shocking
		return FALSE
	var/obj/item/organ/brain/BR = C.getorgan(/obj/item/organ/brain)
	if(QDELETED(BR) || BR.brain_death || (BR.organ_flags & ORGAN_FAILING) || BR.suicided)
		return FALSE
	if(C.get_ghost())
		return FALSE
	return TRUE

/datum/nanite_program/defib/proc/zap()
	var/mob/living/carbon/C = host_mob
	playsound(C, 'sound/machines/defib_charge.ogg', 50, FALSE)
	sleep(30)
	playsound(C, 'sound/machines/defib_zap.ogg', 50, FALSE)
	if(check_revivable())
		playsound(C, 'sound/machines/defib_success.ogg', 50, FALSE)
		C.set_heartattack(FALSE)
		C.revive(full_heal = FALSE, admin_revive = FALSE)
		C.emote("gasp")
		C.Jitter(100)
		SEND_SIGNAL(C, COMSIG_LIVING_MINOR_SHOCK)
		log_game("[C] has been successfully defibrillated by nanites.")
	else
		playsound(C, 'sound/machines/defib_failed.ogg', 50, FALSE)

