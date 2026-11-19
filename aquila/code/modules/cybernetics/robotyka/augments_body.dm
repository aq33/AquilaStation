// AQUILA - augmenty tułowia, kręgosłupa, rąk i nóg. Wdrożenie robotyki, część IMPLANTY.
// Źródła: Aurora (platelet_factories, health_scanner, cyborg_analyzer), Baystation12 (internal_air_system),
// Nova Sector (opticalcamo), SS220 (exoframe), TGMC/MonkeStation/Nova (sandevistan), YogStation (spinalspeed, magboot),
// /tg/station (cyberimp/chest/spine, climbing_hook), Sojourn (organ_module/active/simple/custom),
// MonkeStation (doorjack), Paradise (shell_launcher, v1_arm).

#define AQ_ROBOTYKA_ICON 'aquila/icons/obj/cybernetics/robotyka_implanty.dmi'

// ===========================================================================
// TUŁÓW

// Fabryki płytek (Aurora /obj/item/organ/internal/augment/bioaug/platelet_factories)
/obj/item/organ/cyberimp/chest/aq_platelets
	name = "fabryki płytek krwi"
	desc = "Militarny bioaugment, który mocno zwiększa krzepliwość: krwawienia prawie znikają, ale rośnie ryzyko zawału i udaru."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "platelet_factories"
	implant_overlay = null
	slot = ORGAN_SLOT_AQ_BLOOD_AUG
	aq_cyberpsychosis_cost = 2
	/// Mnożnik krwawienia
	var/bleed_multiplier = 0.2
	/// Szansa na zakrzep w każdym cyklu życia (co 2 s), w promilach
	var/clot_chance_permille = 1

/obj/item/organ/cyberimp/chest/aq_platelets/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(owner == M && ishuman(M))
		var/mob/living/carbon/human/human_owner = M
		human_owner.physiology.bleed_mod *= bleed_multiplier

/obj/item/organ/cyberimp/chest/aq_platelets/Remove(mob/living/carbon/M, special = FALSE)
	if(ishuman(M))
		var/mob/living/carbon/human/human_owner = M
		if(human_owner.physiology) // w Destroy() ciała fizjologii już nie ma
			human_owner.physiology.bleed_mod /= bleed_multiplier
	return ..()

/obj/item/organ/cyberimp/chest/aq_platelets/on_life()
	. = ..()
	if(!owner || owner.stat == DEAD || rand(1, 1000) > clot_chance_permille)
		return
	clot()

/// Zakrzep: zawał albo udar
/obj/item/organ/cyberimp/chest/aq_platelets/proc/clot()
	if(prob(50))
		to_chat(owner, span_userdanger("Czujesz ostry, miażdżący ból w klatce piersiowej!"))
		owner.ForceContractDisease(new /datum/disease/heart_failure(), FALSE, TRUE)
	else
		to_chat(owner, span_userdanger("Połowa świata nagle drętwieje!"))
		owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20)
		owner.gain_trauma_type(BRAIN_TRAUMA_MILD, TRAUMA_RESILIENCE_BASIC)

// ---------------------------------------------------------------------------
// Wewnętrzny system powietrza (Baystation12 /obj/item/organ/internal/augment/active/internal_air_system)

/obj/item/organ/cyberimp/chest/aq_air_sac
	name = "wewnętrzny system powietrza"
	desc = "Elastyczny worek powietrza przy płucach. Daje zapas oddechu bez butli i sam uzupełnia się z otoczenia, gdy nie oddychasz z niego. Potrzebuje szczelnej maski albo hełmu."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "internal_air_system"
	implant_overlay = null
	slot = ORGAN_SLOT_AQ_AIR_SAC
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	aq_cyberpsychosis_cost = 1
	/// Worek z powietrzem
	var/obj/item/tank/internals/aq_air_sac/sac

/obj/item/organ/cyberimp/chest/aq_air_sac/Initialize(mapload)
	. = ..()
	sac = new(src)

/obj/item/organ/cyberimp/chest/aq_air_sac/Destroy()
	QDEL_NULL(sac)
	return ..()

/obj/item/organ/cyberimp/chest/aq_air_sac/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(owner == M && sac)
		sac.forceMove(M) // oddychanie z butli wymaga, żeby leżała w ciele (get_breath_from_internal)

/obj/item/organ/cyberimp/chest/aq_air_sac/Remove(mob/living/carbon/M, special = FALSE)
	if(M && sac)
		if(M.internal == sac)
			M.internal = null
			M.update_internals_hud_icon(0)
		sac.forceMove(src)
	return ..()

/obj/item/organ/cyberimp/chest/aq_air_sac/ui_action_click()
	if(!aq_augment_usable() || !sac)
		return
	if(owner.internal == sac)
		owner.internal = null
		owner.update_internals_hud_icon(0)
		to_chat(owner, span_notice("Przestajesz oddychać z worka powietrza."))
		return
	if(!owner.can_breathe_internals())
		to_chat(owner, span_warning("Potrzebujesz szczelnej maski albo hełmu."))
		return
	owner.internal = sac
	owner.update_internals_hud_icon(1)
	to_chat(owner, span_notice("Oddychasz z worka powietrza."))

/obj/item/organ/cyberimp/chest/aq_air_sac/on_life()
	. = ..()
	if(!owner || !sac || owner.internal == sac)
		return
	refill()

/// Uzupełnia worek oddychalnym powietrzem z otoczenia
/obj/item/organ/cyberimp/chest/aq_air_sac/proc/refill()
	var/datum/gas_mixture/inside = sac.return_air()
	if(!inside || inside.return_pressure() >= ONE_ATMOSPHERE * 10)
		return
	var/turf/open/here = get_turf(owner)
	if(!istype(here))
		return
	var/datum/gas_mixture/environment = here.return_air()
	if(!environment)
		return
	var/env_moles = environment.total_moles()
	if(env_moles <= 0)
		return
	var/env_pressure = environment.return_pressure()
	var/oxygen_pressure = env_pressure * environment.get_moles(GAS_O2) / env_moles
	var/toxic_pressure = env_pressure * (environment.get_moles(GAS_PLASMA) + environment.get_moles(GAS_CO2)) / env_moles
	if(oxygen_pressure < 16 || toxic_pressure > 0.5)
		return
	inside.merge(environment.remove_ratio(0.002))
	here.air_update_turf()

/obj/item/tank/internals/aq_air_sac
	name = "worek powietrza"
	desc = "Elastyczny worek na powietrze z wewnętrznego systemu powietrza."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "air_sac"
	item_flags = ABSTRACT
	slot_flags = null
	volume = 6
	distribute_pressure = TANK_DEFAULT_RELEASE_PRESSURE

/obj/item/tank/internals/aq_air_sac/populate_gas()
	air_contents.set_moles(GAS_O2, (3 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C) * O2STANDARD)
	air_contents.set_moles(GAS_N2, (3 * ONE_ATMOSPHERE) * volume / (R_IDEAL_GAS_EQUATION * T20C) * N2STANDARD)

// ---------------------------------------------------------------------------
// Kamuflaż optyczny (Nova Sector /obj/item/organ/cyberimp/chest/opticalcamo)

/obj/item/organ/cyberimp/chest/aq_optical_camo
	name = "implant kamuflażu optycznego"
	desc = "Zagina światło wokół ciała: po włączeniu nosiciel staje się prawie niewidzialny. Zużywa dużo energii z jedzenia, EMP go wyłącza."
	icon_state = "chest_implant"
	implant_overlay = "chest_implant_overlay"
	implant_color = "#2F3B47"
	slot = ORGAN_SLOT_AQ_CAMO
	syndicate_implant = TRUE
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	aq_cyberpsychosis_cost = 3
	/// Czy kamuflaż działa
	var/active = FALSE
	/// Przezroczystość nosiciela
	var/camo_alpha = 15
	/// Głód na cykl życia
	var/nutrition_drain = 2
	/// Do kiedy EMP blokuje kamuflaż
	var/emp_until = 0

/obj/item/organ/cyberimp/chest/aq_optical_camo/ui_action_click()
	if(!active && (!aq_augment_usable() || world.time < emp_until))
		if(world.time < emp_until)
			to_chat(owner, span_warning("Kamuflaż jeszcze się restartuje."))
		return
	set_active(!active)

/obj/item/organ/cyberimp/chest/aq_optical_camo/proc/set_active(new_state)
	if(!owner || active == new_state)
		return
	active = new_state
	animate(owner, alpha = active ? camo_alpha : 255, time = 0.5 SECONDS)
	to_chat(owner, span_notice((active ? "Światło zagina się wokół ciebie." : "Kamuflaż optyczny gaśnie.")))

/obj/item/organ/cyberimp/chest/aq_optical_camo/on_life()
	. = ..()
	if(!active || !owner)
		return
	if(owner.nutrition <= NUTRITION_LEVEL_STARVING || !aq_augment_usable(TRUE))
		set_active(FALSE)
		return
	owner.adjust_nutrition(-nutrition_drain)

/obj/item/organ/cyberimp/chest/aq_optical_camo/Remove(mob/living/carbon/M, special = FALSE)
	set_active(FALSE)
	return ..()

/obj/item/organ/cyberimp/chest/aq_optical_camo/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	set_active(FALSE)
	emp_until = world.time + 30 SECONDS / severity
	do_sparks(3, FALSE, owner)

// ===========================================================================
// KRĘGOSŁUP (slot ORGAN_SLOT_SPINAL, jeden implant naraz)

// Egzoszkielet nośny (SS220 /obj/item/organ/internal/cyberimp/chest/exoframe)
/obj/item/organ/cyberimp/chest/spinal/aq_exoframe
	name = "egzoszkielet nośny"
	desc = "Szkielet nośny jak u humanoidalnego robota: więcej wytrzymałości, mniej obrażeń od uderzeń i mocniejsze ciosy."
	icon_state = "chest_implant"
	implant_overlay = "chest_implant_overlay"
	implant_color = "#9AA3AD"
	aq_cyberpsychosis_cost = 2
	/// Premia do maksymalnego zdrowia
	var/health_bonus = 20
	/// Mnożnik obrażeń od uderzeń
	var/brute_multiplier = 0.9
	/// Premia do ciosów
	var/punch_bonus = 2

/obj/item/organ/cyberimp/chest/spinal/aq_exoframe/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(owner != M)
		return
	M.maxHealth += health_bonus
	M.updatehealth()
	if(ishuman(M))
		var/mob/living/carbon/human/human_owner = M
		human_owner.physiology.brute_mod *= brute_multiplier
		human_owner.unarmed_damage_bonus += punch_bonus

/obj/item/organ/cyberimp/chest/spinal/aq_exoframe/Remove(mob/living/carbon/M, special = FALSE)
	if(M)
		M.maxHealth -= health_bonus
		M.updatehealth()
		if(ishuman(M))
			var/mob/living/carbon/human/human_owner = M
			if(human_owner.physiology)
				human_owner.physiology.brute_mod /= brute_multiplier
			human_owner.unarmed_damage_bonus -= punch_bonus
	return ..()

/obj/item/organ/cyberimp/chest/spinal/aq_exoframe/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	owner.apply_damage(10 / severity, BRUTE, BODY_ZONE_CHEST)
	owner.Knockdown(2 SECONDS / severity)

// ---------------------------------------------------------------------------
// Sandevistan (TGMC /obj/item/implant/sandevistan, MonkeStation, Nova Sector): przyspieszenie z kosztem dla serca

/obj/item/organ/cyberimp/chest/spinal/aq_sandevistan
	name = "implant kręgosłupa Sandevistan"
	desc = "Na żądanie przyspiesza ruchy i reakcje nosiciela tak, że świat wokół zwalnia. Każde użycie obciąża serce i układ nerwowy."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "imp_spinal"
	implant_overlay = null
	syndicate_implant = TRUE
	actions_types = list(/datum/action/item_action/organ_action/use)
	aq_cyberpsychosis_cost = 3
	/// Czy działa
	var/active = FALSE
	/// Ile trwa przyspieszenie
	var/duration = 15 SECONDS
	/// Odnowienie po zakończeniu
	var/cooldown_time = 45 SECONDS
	/// Spowolnienie innych w zasięgu
	var/field_slowdown = 1.5
	/// Zasięg spowolnienia innych
	var/field_range = 3
	/// Kiedy się skończy
	var/end_time = 0
	COOLDOWN_DECLARE(sandy_cooldown)

/obj/item/organ/cyberimp/chest/spinal/aq_sandevistan/ui_action_click()
	if(active)
		deactivate()
		return
	if(!aq_augment_usable())
		return
	if(!COOLDOWN_FINISHED(src, sandy_cooldown))
		to_chat(owner, span_warning("Sandevistan jeszcze się chłodzi ([round(COOLDOWN_TIMELEFT(src, sandy_cooldown) / 10)] s)."))
		return
	activate()

/obj/item/organ/cyberimp/chest/spinal/aq_sandevistan/proc/activate()
	active = TRUE
	icon_state = "imp_spinal_on"
	end_time = world.time + duration
	owner.add_movespeed_modifier("aq_sandevistan", update = TRUE, priority = 100, multiplicative_slowdown = -1)
	owner.next_move_modifier *= 0.7
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(after_image))
	START_PROCESSING(SSfastprocess, src)
	to_chat(owner, span_notice("Świat wokół zwalnia."))
	playsound(owner, 'sound/magic/timeparadox2.ogg', 40, TRUE)

/obj/item/organ/cyberimp/chest/spinal/aq_sandevistan/proc/deactivate(silent = FALSE)
	if(!active)
		return
	active = FALSE
	icon_state = "imp_spinal"
	STOP_PROCESSING(SSfastprocess, src)
	COOLDOWN_START(src, sandy_cooldown, cooldown_time)
	if(!owner)
		return
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	owner.remove_movespeed_modifier("aq_sandevistan")
	owner.next_move_modifier /= 0.7
	if(silent)
		return
	// koszt przeciążenia
	owner.adjustOrganLoss(ORGAN_SLOT_HEART, 10)
	owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 5)
	owner.adjustStaminaLoss(30)
	to_chat(owner, span_warning("Czas wraca do normy, a serce wali jak oszalałe."))

/obj/item/organ/cyberimp/chest/spinal/aq_sandevistan/process(delta_time)
	if(!active)
		return PROCESS_KILL
	if(!owner || owner.stat || world.time >= end_time || !aq_augment_usable(TRUE))
		deactivate()
		return
	for(var/mob/living/other in range(field_range, owner))
		if(other == owner || other.stat == DEAD)
			continue
		other.add_movespeed_modifier("aq_sandevistan_field", update = TRUE, priority = 100, multiplicative_slowdown = field_slowdown)
		addtimer(CALLBACK(other, TYPE_PROC_REF(/mob, remove_movespeed_modifier), "aq_sandevistan_field"), 1 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/item/organ/cyberimp/chest/spinal/aq_sandevistan/proc/after_image(atom/movable/source, atom/old_loc)
	SIGNAL_HANDLER
	if(isturf(old_loc))
		new /obj/effect/temp_visual/decoy/fading(old_loc, source)

/obj/item/organ/cyberimp/chest/spinal/aq_sandevistan/Remove(mob/living/carbon/M, special = FALSE)
	deactivate(silent = TRUE)
	return ..()

/obj/item/organ/cyberimp/chest/spinal/aq_sandevistan/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

// ---------------------------------------------------------------------------
// Neuronowy podkręcacz (YogStation /obj/item/organ/cyberimp/chest/spinalspeed): szybkość za cenę przegrzania

/obj/item/organ/cyberimp/chest/spinal/aq_overclocker
	name = "neuronowy podkręcacz"
	desc = "Pobudza układ nerwowy: po włączeniu szybszy ruch i reakcje z poświatą powidoków. Długie użycie przegrzewa ciało i mózg."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "imp_spinal"
	implant_overlay = null
	syndicate_implant = TRUE
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	aq_cyberpsychosis_cost = 3
	/// Czy działa
	var/active = FALSE
	/// Licznik przegrzania: +1 na cykl włączony, -2 wyłączony
	var/overheat = 0
	/// Zabawkowa wersja tylko świeci
	var/toy = FALSE

/obj/item/organ/cyberimp/chest/spinal/aq_overclocker/ui_action_click()
	if(!active && !aq_augment_usable())
		return
	set_active(!active)

/obj/item/organ/cyberimp/chest/spinal/aq_overclocker/proc/set_active(new_state)
	if(!owner || active == new_state)
		return
	active = new_state
	icon_state = active ? "imp_spinal_on" : "imp_spinal"
	if(active)
		RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(after_image))
		if(!toy)
			owner.add_movespeed_modifier("aq_overclocker", update = TRUE, priority = 100, multiplicative_slowdown = -1)
			owner.next_move_modifier *= 0.7
		to_chat(owner, span_notice("Twoje nerwy płoną. Wszystko dzieje się szybciej."))
	else
		UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
		if(!toy)
			owner.remove_movespeed_modifier("aq_overclocker")
			owner.next_move_modifier /= 0.7
		to_chat(owner, span_notice("Podkręcacz zwalnia."))

/obj/item/organ/cyberimp/chest/spinal/aq_overclocker/proc/after_image(atom/movable/source, atom/old_loc)
	SIGNAL_HANDLER
	if(isturf(old_loc))
		new /obj/effect/temp_visual/decoy/fading(old_loc, source)

/obj/item/organ/cyberimp/chest/spinal/aq_overclocker/on_life()
	. = ..()
	if(!owner)
		return
	if(!active)
		overheat = max(overheat - 2, 0)
		return
	if(owner.stat != CONSCIOUS || !aq_augment_usable(TRUE))
		set_active(FALSE)
		return
	if(toy)
		return
	overheat++
	switch(overheat)
		if(20 to 49)
			owner.adjust_hallucinations_up_to(4 SECONDS, 30 SECONDS)
			owner.adjustFireLoss(1)
		if(50 to 99)
			owner.adjust_hallucinations_up_to(4 SECONDS, 60 SECONDS)
			owner.set_drugginess(10)
			owner.adjustFireLoss(5)
		if(100 to INFINITY)
			// u Yoga przegrzanie rozrywa ciało; u nas wyłącza implant i mocno uszkadza mózg
			to_chat(owner, span_userdanger("Podkręcacz przegrzewa się i wyłącza! Twój mózg się gotuje!"))
			set_active(FALSE)
			overheat = 0
			owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 40)
			owner.adjustFireLoss(20)
			owner.Paralyze(5 SECONDS)

/obj/item/organ/cyberimp/chest/spinal/aq_overclocker/Remove(mob/living/carbon/M, special = FALSE)
	set_active(FALSE)
	return ..()

/obj/item/organ/cyberimp/chest/spinal/aq_overclocker/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF || toy)
		return
	owner.set_drugginess(8 / severity)
	owner.adjust_hallucinations_up_to(50 SECONDS / severity, 100 SECONDS)
	owner.blur_eyes(5)
	owner.Dizzy(5)
	owner.adjustFireLoss(2 / severity)
	overheat += 2 / severity

/obj/item/organ/cyberimp/chest/spinal/aq_overclocker/toy
	name = "zabawkowy neuronowy podkręcacz"
	desc = "Tania podróbka neuronowego podkręcacza. Zostawia ładną poświatę powidoków i nic poza tym."
	syndicate_implant = FALSE
	toy = TRUE
	aq_cyberpsychosis_cost = 1

// ---------------------------------------------------------------------------
// Grawitonowy implant kręgosłupa Herculean (/tg/station /obj/item/organ/cyberimp/chest/spine)

/obj/item/organ/cyberimp/chest/spinal/aq_herculean
	name = "grawitonowy implant kręgosłupa Herculean"
	desc = "Grawitonowe wzmocnienie kręgosłupa: szybsza wspinaczka, dalsze i szybsze rzuty, mocniejsze ciosy."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "herculean_implant"
	implant_overlay = null
	aq_cyberpsychosis_cost = 2
	/// Premia do ciosów
	var/punch_bonus = 4
	/// Premia do zasięgu rzutu
	var/throw_range_bonus = 4
	/// Premia do szybkości rzutu
	var/throw_speed_bonus = 1
	/// Mnożnik czasu wspinaczki (hak wspinaczkowy)
	var/climb_multiplier = 0.8

/obj/item/organ/cyberimp/chest/spinal/aq_herculean/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(owner != M)
		return
	ADD_TRAIT(M, TRAIT_FREERUNNING, REF(src))
	if(ishuman(M))
		var/mob/living/carbon/human/human_owner = M
		human_owner.unarmed_damage_bonus += punch_bonus

/obj/item/organ/cyberimp/chest/spinal/aq_herculean/Remove(mob/living/carbon/M, special = FALSE)
	if(M)
		REMOVE_TRAIT(M, TRAIT_FREERUNNING, REF(src))
		if(ishuman(M))
			var/mob/living/carbon/human/human_owner = M
			human_owner.unarmed_damage_bonus -= punch_bonus
	return ..()

/obj/item/organ/cyberimp/chest/spinal/aq_herculean/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	owner.apply_damage(20 / severity, BRUTE, BODY_ZONE_CHEST)
	to_chat(owner, span_warning("Kręgosłup przeszywa ból, gdy grawitony tracą stabilność!"))

// ===========================================================================
// RĘCE

// Zintegrowany skaner zdrowia (Aurora /obj/item/organ/internal/augment/health_scanner)
/obj/item/organ/cyberimp/arm/aq_health_scanner
	name = "zintegrowany skaner zdrowia"
	desc = "Wysuwany z dłoni analizator zdrowia, który bada pacjenta dotykiem."
	items_to_create = list(/obj/item/healthanalyzer)
	aq_cyberpsychosis_cost = 1

/obj/item/organ/cyberimp/arm/aq_health_scanner/l
	zone = BODY_ZONE_L_ARM

// Analizator cyborgów w palcu (Aurora /obj/item/organ/internal/augment/tool/cyborg_analyzer)
/obj/item/organ/cyberimp/arm/aq_cyborg_analyzer
	name = "wysuwany analizator cyborgów"
	desc = "Analizator cyborgów i protez wysuwany z palca, do diagnozy na miejscu."
	items_to_create = list(/obj/item/aq_robot_analyzer)
	aq_cyberpsychosis_cost = 1

/obj/item/organ/cyberimp/arm/aq_cyborg_analyzer/l
	zone = BODY_ZONE_L_ARM

/obj/item/aq_robot_analyzer
	name = "analizator cyborgów"
	desc = "Ręczny skaner stanu cyborgów, protez i robotycznych narządów."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "robotanalyzer"
	item_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL

/obj/item/aq_robot_analyzer/attack(mob/living/M, mob/living/user)
	if(user.combat_mode)
		return ..()
	scan(M, user)

/// Raport o stanie robotycznych części celu
/obj/item/aq_robot_analyzer/proc/scan(mob/living/target, mob/living/user)
	var/list/lines = list("<b>Analiza: [target]</b>")
	if(iscyborg(target))
		var/mob/living/silicon/robot/borg = target
		lines += "Stan: [borg.stat == DEAD ? "zniszczony" : "[round(borg.health / borg.maxHealth * 100)]%"]"
		lines += "Uszkodzenia konstrukcji: [round(borg.getBruteLoss())], elektroniki: [round(borg.getFireLoss())]"
		lines += borg.cell ? "Ogniwo: [round(borg.cell.percent())]%" : "Brak ogniwa"
	else if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		var/found = FALSE
		for(var/obj/item/bodypart/part as anything in carbon_target.bodyparts)
			if(IS_ORGANIC_LIMB(part))
				continue
			found = TRUE
			lines += "Proteza [part.name]: obrażenia [round(part.brute_dam)] / poparzenia [round(part.burn_dam)]"
		for(var/obj/item/organ/organ as anything in carbon_target.internal_organs)
			if(organ.status != ORGAN_ROBOTIC)
				continue
			found = TRUE
			lines += "[capitalize(organ.name)]: uszkodzenia [round(organ.damage)][organ.organ_flags & ORGAN_FAILING ? " (NIEWYDOLNY)" : ""]"
		if(!found)
			lines += "Brak robotycznych części."
	else
		lines += "Nie rozpoznano konstrukcji."
	user.visible_message(span_notice("[user] skanuje [target] analizatorem cyborgów."))
	to_chat(user, span_notice(jointext(lines, "<br>")))

// Wbudowany przedmiot (Sojourn /obj/item/organ_module/active/simple/custom): dowolny przedmiot wysuwany z ręki
/obj/item/organ/cyberimp/arm/aq_embedded
	name = "moduł wbudowanego przedmiotu"
	desc = "Uniwersalny moduł w ręce: włóż do niego przedmiot nie większy niż zwykły, a będzie się błyskawicznie wysuwać z dłoni. Nożyce do drutu wyjmują przedmiot z modułu."
	aq_cyberpsychosis_cost = 2

/obj/item/organ/cyberimp/arm/aq_embedded/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/aq_embedded/examine(mob/user)
	. = ..()
	var/obj/item/stored = get_stored()
	. += span_info((stored ? "W module siedzi [stored]." : "Moduł jest pusty."))

/// Przedmiot w module
/obj/item/organ/cyberimp/arm/aq_embedded/proc/get_stored()
	for(var/datum/weakref/ref in items_list)
		var/obj/item/stored = ref.resolve()
		if(stored)
			return stored
	return null

/obj/item/organ/cyberimp/arm/aq_embedded/attackby(obj/item/I, mob/user, params)
	if(owner || I.tool_behaviour == TOOL_SCREWDRIVER || istype(I, /obj/item/organ) || istype(I, /obj/item/implanter))
		return ..()
	if(get_stored())
		to_chat(user, span_warning("W module już coś jest."))
		return
	if(I.w_class > WEIGHT_CLASS_NORMAL || HAS_TRAIT(I, TRAIT_NODROP) || (I.item_flags & ABSTRACT))
		to_chat(user, span_warning("[I] nie zmieści się w module."))
		return
	if(!user.transferItemToLoc(I, src))
		return
	items_list += WEAKREF(I)
	to_chat(user, span_notice("Montujesz [I] w module."))

/obj/item/organ/cyberimp/arm/aq_embedded/wirecutter_act(mob/living/user, obj/item/tool)
	if(owner)
		return FALSE
	var/obj/item/stored = get_stored()
	if(!stored)
		to_chat(user, span_warning("Moduł jest pusty."))
		return TRUE
	items_list.Cut()
	REMOVE_TRAIT(stored, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	stored.forceMove(drop_location())
	user.put_in_hands(stored)
	to_chat(user, span_notice("Wyjmujesz [stored] z modułu."))
	return TRUE

// Wbudowany doorjack (MonkeStation /obj/item/organ/internal/cyberimp/arm/item_set/doorjack)
/obj/item/organ/cyberimp/arm/aq_doorjack
	name = "implant doorjacka"
	desc = "Wbudowany w rękę doorjack, którym można sforsować zamek drzwi."
	syndicate_implant = TRUE
	items_to_create = list(/obj/item/aq_doorjack)
	aq_cyberpsychosis_cost = 2

/obj/item/organ/cyberimp/arm/aq_doorjack/l
	zone = BODY_ZONE_L_ARM

/obj/item/aq_doorjack
	name = "doorjack"
	desc = "Wysuwany z ręki łamacz zamków. Przyłożony do drzwi po chwili przepala ich elektronikę."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "doorjack"
	item_state = "card-id"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	/// Ile trwa forsowanie
	var/jack_time = 3 SECONDS

/obj/item/aq_doorjack/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !(istype(target, /obj/machinery/door/airlock) || istype(target, /obj/machinery/door/window)))
		return
	var/obj/machinery/door/door = target
	if(door.obj_flags & EMAGGED)
		to_chat(user, span_warning("Zamek [door] jest już przepalony."))
		return
	user.visible_message(span_warning("[user] przykłada coś do zamka [door]."), span_notice("Doorjack zaczyna łamać zamek [door]..."))
	if(!do_after(user, jack_time, target = door))
		return
	log_combat(user, door, "sforsował doorjackiem")
	door.emag_act(user)

// Hak wspinaczkowy w ręce (Bubberstation /obj/item/organ/cyberimp/arm/toolkit/rope, hak z /tg/station)
/obj/item/organ/cyberimp/arm/aq_climbing_hook
	name = "implant haka wspinaczkowego"
	desc = "Wszczepiony hak z liną do wspinania się na wyższe piętro przez dziurę w suficie."
	items_to_create = list(/obj/item/aq_climbing_hook)
	aq_cyberpsychosis_cost = 1

/obj/item/organ/cyberimp/arm/aq_climbing_hook/l
	zone = BODY_ZONE_L_ARM

/obj/item/aq_climbing_hook
	name = "hak wspinaczkowy"
	desc = "Hak z liną. Stań pod dziurą w suficie i kliknij podłogę obok niej (patrząc w górę albo na swoim piętrze), żeby się wspiąć."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "climbingrope"
	item_state = "crowbar_brass"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	force = 5
	/// Czas wspinaczki
	var/climb_time = 2.5 SECONDS

/obj/item/aq_climbing_hook/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	. = ..()
	var/turf/clicked = get_turf(target)
	var/turf/user_turf = get_turf(user)
	if(!clicked || !user_turf || !isturf(user.loc))
		return
	var/turf/hole = GET_TURF_ABOVE(user_turf)
	var/turf/destination
	if(clicked.z > user_turf.z)
		destination = clicked
	else if(clicked.z == user_turf.z && get_dist(user_turf, clicked) <= 1)
		destination = GET_TURF_ABOVE(clicked)
	else
		return
	if(!hole || !istype(hole, /turf/open/openspace) || !destination || destination.z != hole.z || get_dist(hole, destination) > 1)
		to_chat(user, span_warning("Nad tobą musi być dziura, a cel tuż obok niej."))
		return
	if(destination.density || istype(destination, /turf/open/openspace) || is_blocked_turf(destination, TRUE))
		to_chat(user, span_warning("Nie da się tam wspiąć."))
		return
	var/time = climb_time
	var/obj/item/organ/cyberimp/chest/spinal/aq_herculean/spine = user.getorganslot(ORGAN_SLOT_SPINAL)
	if(istype(spine))
		time *= spine.climb_multiplier
	user.visible_message(span_notice("[user] zaczyna wspinać się po linie w górę."), span_notice("Zaczepiasz hak i wspinasz się w górę."))
	playsound(user_turf, 'sound/effects/picaxe1.ogg', 50)
	if(do_after(user, time, target = user))
		user.forceMove(destination)

// Działko w ramieniu (Paradise /obj/item/organ/internal/cyberimp/arm/shell_launcher)
/obj/item/organ/cyberimp/arm/aq_shell_launcher
	name = "implant wyrzutni nabojów"
	desc = "Jednostrzałowe działko w ramieniu, ładowane nabojami do strzelby. Po strzale trzeba je przeładować. EMP może odpalić nabój w ramieniu."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "shell_cannon"
	syndicate_implant = TRUE
	items_to_create = list(/obj/item/gun/ballistic/shotgun/doublebarrel/aq_shell_launcher)
	aq_cyberpsychosis_cost = 3

/obj/item/organ/cyberimp/arm/aq_shell_launcher/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/aq_shell_launcher/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF || !prob(30 / severity))
		return
	var/obj/item/gun/ballistic/shotgun/doublebarrel/aq_shell_launcher/launcher
	for(var/datum/weakref/ref in items_list)
		launcher = ref.resolve()
		if(istype(launcher))
			break
	Retract()
	if(!istype(launcher) || !launcher.chambered?.BB)
		return
	// nabój odpala w ramieniu
	QDEL_NULL(launcher.chambered.BB)
	launcher.chambered.update_icon()
	owner.apply_damage(30, BRUTE, zone)
	owner.visible_message(span_danger("W ramieniu [owner] coś głośno wybucha!"), span_userdanger("Nabój odpala w twoim ramieniu!"))
	playsound(owner, 'sound/weapons/gunshot.ogg', 60, TRUE)

/obj/item/gun/ballistic/shotgun/doublebarrel/aq_shell_launcher
	name = "wyrzutnia nabojów"
	desc = "Jednostrzałowe działko wysuwane z ramienia. Ładuje się nabojami do strzelby."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "shell_cannon_gun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_LIGHT
	slot_flags = null
	mag_type = /obj/item/ammo_box/magazine/internal/shot/aq_shell_launcher
	unique_reskin = null
	sawn_desc = null

/obj/item/gun/ballistic/shotgun/doublebarrel/aq_shell_launcher/sawoff(mob/user)
	to_chat(user, span_warning("Wyrzutni nie da się skrócić."))
	return FALSE

/obj/item/gun/ballistic/shotgun/doublebarrel/aq_shell_launcher/AltClick(mob/user)
	return

/obj/item/ammo_box/magazine/internal/shot/aq_shell_launcher
	name = "komora wyrzutni nabojów"
	ammo_type = /obj/item/ammo_casing/shotgun/rubbershot
	max_ammo = 1

// Ramię ze sprzężeniem wirowym (Paradise /obj/item/organ/internal/cyberimp/arm/v1_arm)
/obj/item/organ/cyberimp/arm/aq_v1_arm
	name = "ramię ze sprzężeniem wirowym"
	desc = "Obwody z rdzeniem anomalii wiru opancerzają ramię. Wysunięty pancerz odbija nadlatujące pociski energetyczne."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "v1_arm"
	zone = BODY_ZONE_L_ARM
	items_to_create = list(/obj/item/aq_v1_arm)
	aq_cyberpsychosis_cost = 3

/obj/item/organ/cyberimp/arm/aq_v1_arm/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	for(var/datum/weakref/ref in items_list)
		var/obj/item/aq_v1_arm/arm = ref.resolve()
		if(istype(arm))
			arm.disable(10 SECONDS)
	Retract()

/obj/item/aq_v1_arm
	name = "pancerz sprzężenia wirowego"
	desc = "Opancerzone ramię z rdzeniem anomalii wiru. Odbija część nadlatujących pocisków energetycznych."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "v1_arm"
	item_state = "nothing"
	w_class = WEIGHT_CLASS_HUGE
	force = 20
	attack_verb = list("uderza", "miażdży")
	hitsound = 'sound/weapons/smash.ogg'
	/// Szansa na odbicie pocisku
	var/reflect_chance = 50
	/// Do kiedy EMP wyłącza ramię
	var/disabled_until = 0

/obj/item/aq_v1_arm/proc/disable(time)
	disabled_until = world.time + time

/obj/item/aq_v1_arm/IsReflect(def_zone)
	if(world.time < disabled_until || !prob(reflect_chance))
		return FALSE
	if(isliving(loc))
		var/mob/living/holder = loc
		holder.adjustStaminaLoss(5)
		playsound(holder, 'sound/weapons/parry.ogg', 50, TRUE)
	return TRUE

/// Obudowa ramienia: dopiero z rdzeniem anomalii wiru staje się implantem
/obj/item/aq_v1_arm_shell
	name = "obudowa ramienia ze sprzężeniem wirowym"
	desc = "Niedokończony implant ramienia. Brakuje mu rdzenia anomalii wiru."
	icon = AQ_ROBOTYKA_ICON
	icon_state = "v1_arm"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/aq_v1_arm_shell/Initialize(mapload)
	. = ..()
	color = "#888888"

/obj/item/aq_v1_arm_shell/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/assembly/signaler/anomaly/vortex))
		return ..()
	to_chat(user, span_notice("Wkładasz [I] do obudowy. Obwody ożywają."))
	qdel(I)
	var/obj/item/organ/cyberimp/arm/aq_v1_arm/arm = new(drop_location())
	user.put_in_hands(arm)
	qdel(src)

// ===========================================================================
// NOGI

// Magnetyczne stopy (YogStation /obj/item/organ/cyberimp/leg/magboot): potrzebują pary w obu nogach
/obj/item/organ/cyberimp/leg/aq_magboot
	name = "implant magnetycznych stóp"
	desc = "Magnes w stopie działa jak magbuty. Potrzebuje drugiego takiego implantu w drugiej nodze."
	double_legged_type = /obj/item/organ/cyberimp/leg/aq_magboot
	aq_cyberpsychosis_cost = 1
	/// Akcja przełączania (tylko na jednym z pary)
	var/datum/action/innate/aq_maglock/maglock

/obj/item/organ/cyberimp/leg/aq_magboot/l
	zone = BODY_ZONE_L_LEG

/obj/item/organ/cyberimp/leg/aq_magboot/Destroy()
	QDEL_NULL(maglock)
	return ..()

/obj/item/organ/cyberimp/leg/aq_magboot/on_full_insert(mob/living/carbon/user)
	if(!maglock)
		maglock = new(src)
	maglock.Grant(user)

/obj/item/organ/cyberimp/leg/aq_magboot/on_full_remove(mob/living/carbon/user)
	maglock?.set_locked(FALSE)
	maglock?.Remove(user)
	var/obj/item/organ/cyberimp/leg/aq_magboot/partner = get_partner(user)
	if(partner?.maglock)
		partner.maglock.set_locked(FALSE)
		partner.maglock.Remove(user)

/obj/item/organ/cyberimp/leg/aq_magboot/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	maglock?.set_locked(FALSE)

/datum/action/innate/aq_maglock
	name = "Magnetyczne stopy"
	desc = "Włącza i wyłącza magnesy w stopach."
	icon_icon = 'icons/obj/clothing/shoes.dmi'
	button_icon_state = "magboots0"
	/// Czy magnesy są włączone
	var/locked = FALSE

/datum/action/innate/aq_maglock/Trigger()
	var/obj/item/organ/cyberimp/leg/aq_magboot/implant = target
	if(!istype(implant) || !implant.owner)
		return
	if(!locked && !implant.aq_augment_usable())
		return
	set_locked(!locked)

/datum/action/innate/aq_maglock/proc/set_locked(new_state)
	if(locked == new_state || !owner)
		locked = new_state
		return
	locked = new_state
	var/mob/living/carbon/user = owner
	if(locked)
		ADD_TRAIT(user, TRAIT_NEGATES_GRAVITY, REF(src))
		ADD_TRAIT(user, TRAIT_NOSLIPWATER, REF(src))
		user.add_movespeed_modifier("aq_maglock", update = TRUE, priority = 100, multiplicative_slowdown = 1)
	else
		REMOVE_TRAIT(user, TRAIT_NEGATES_GRAVITY, REF(src))
		REMOVE_TRAIT(user, TRAIT_NOSLIPWATER, REF(src))
		user.remove_movespeed_modifier("aq_maglock")
	button_icon_state = locked ? "magboots1" : "magboots0"
	UpdateButtonIcon()
	to_chat(user, span_notice((locked ? "Magnesy w stopach przywierają do podłogi." : "Magnesy w stopach puszczają.")))

#undef AQ_ROBOTYKA_ICON
