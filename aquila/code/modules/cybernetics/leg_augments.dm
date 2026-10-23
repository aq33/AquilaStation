// Port cybernetyki z Monkestation: implanty nóg.
// Nowe sloty ORGAN_SLOT_LEFT/RIGHT_LEG_AUG, strona zmieniana śrubokrętem jak przy implantach rąk.
// Implanty z double_legged_type działają dopiero w komplecie (oba w nogach), liczone ręcznie przez sloty.

/obj/item/organ/cyberimp/leg
	name = "implant nogi"
	desc = "Tego nie powinno tu być! Zgłoś to adminom."
	zone = BODY_ZONE_R_LEG
	icon_state = "implant-toolkit"
	w_class = WEIGHT_CLASS_SMALL
	/// Typ bazowy, którego para musi siedzieć w obu nogach; null = implant działa sam
	var/double_legged_type
	/// Premia za komplet jest włączona (ustawiane na obu implantach pary)
	var/pair_active = FALSE

/obj/item/organ/cyberimp/leg/Initialize(mapload)
	. = ..()
	update_icon()
	SetSlotFromZone()

/obj/item/organ/cyberimp/leg/proc/SetSlotFromZone()
	switch(zone)
		if(BODY_ZONE_L_LEG)
			slot = ORGAN_SLOT_LEFT_LEG_AUG
		if(BODY_ZONE_R_LEG)
			slot = ORGAN_SLOT_RIGHT_LEG_AUG
		else
			CRASH("Invalid zone for [type]")

/obj/item/organ/cyberimp/leg/update_icon()
	. = ..()
	transform = zone == BODY_ZONE_R_LEG ? null : matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/cyberimp/leg/examine(mob/user)
	. = ..()
	. += span_info("[src] jest zmontowany w konfiguracji na [zone == BODY_ZONE_R_LEG ? "prawą" : "lewą"] nogę. Możesz go przemontować śrubokrętem.")
	if(double_legged_type)
		. += span_info("Działa dopiero z drugim takim implantem w drugiej nodze.")

/obj/item/organ/cyberimp/leg/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return TRUE
	I.play_tool_sound(src)
	zone = zone == BODY_ZONE_R_LEG ? BODY_ZONE_L_LEG : BODY_ZONE_R_LEG
	SetSlotFromZone()
	to_chat(user, span_notice("Przerabiasz [src] do instalacji w [zone == BODY_ZONE_R_LEG ? "prawej" : "lewej"] nodze."))
	update_icon()
	return TRUE

/// Implant tej samej rodziny w drugiej nodze
/obj/item/organ/cyberimp/leg/proc/get_partner(mob/living/carbon/user)
	if(!double_legged_type || !user)
		return null
	var/obj/item/organ/cyberimp/leg/other = user.getorganslot(slot == ORGAN_SLOT_LEFT_LEG_AUG ? ORGAN_SLOT_RIGHT_LEG_AUG : ORGAN_SLOT_LEFT_LEG_AUG)
	if(istype(other, double_legged_type))
		return other
	return null

/obj/item/organ/cyberimp/leg/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(owner != M)
		return
	if(!double_legged_type)
		on_full_insert(M)
		return
	var/obj/item/organ/cyberimp/leg/partner = get_partner(M)
	if(!partner || partner.pair_active)
		return
	pair_active = TRUE
	partner.pair_active = TRUE
	on_full_insert(M)

/obj/item/organ/cyberimp/leg/Remove(mob/living/carbon/M, special = FALSE)
	if(M && (pair_active || !double_legged_type))
		var/obj/item/organ/cyberimp/leg/partner = get_partner(M)
		if(partner)
			partner.pair_active = FALSE
		pair_active = FALSE
		on_full_remove(M)
	return ..()

/// Implant (albo komplet) zaczyna działać
/obj/item/organ/cyberimp/leg/proc/on_full_insert(mob/living/carbon/user)
	return

/// Implant (albo komplet) przestaje działać
/obj/item/organ/cyberimp/leg/proc/on_full_remove(mob/living/carbon/user)
	return

/obj/item/organ/cyberimp/leg/emp_act(severity)
	. = ..()
	if(!owner || (. & EMP_PROTECT_SELF))
		return
	owner.apply_damage(10, BURN, zone)

/// Implanty, które w komplecie dają traity
/obj/item/organ/cyberimp/leg/trait
	/// Traity nadawane przez komplet
	var/list/pair_traits = list()

/obj/item/organ/cyberimp/leg/trait/on_full_insert(mob/living/carbon/user)
	for(var/trait in pair_traits)
		ADD_TRAIT(user, trait, LEG_IMPLANT_TRAIT)

/obj/item/organ/cyberimp/leg/trait/on_full_remove(mob/living/carbon/user)
	for(var/trait in pair_traits)
		REMOVE_TRAIT(user, trait, LEG_IMPLANT_TRAIT)

/obj/item/organ/cyberimp/leg/trait/table_glider
	name = "implant ślizgu po stołach"
	desc = "Implant, dzięki któremu błyskawicznie przeskakujesz przez stoły. Trzeba go wszczepić w obie nogi."
	double_legged_type = /obj/item/organ/cyberimp/leg/trait/table_glider
	pair_traits = list(TRAIT_FAST_CLIMBER)

/obj/item/organ/cyberimp/leg/trait/table_glider/l
	zone = BODY_ZONE_L_LEG

/obj/item/organ/cyberimp/leg/trait/shove_resist
	name = "implant oporowy BU-TAM"
	desc = "Implant, dzięki któremu popchnięcia cię nie przewracają, tylko męczą. Trzeba go wszczepić w obie nogi."
	double_legged_type = /obj/item/organ/cyberimp/leg/trait/shove_resist
	pair_traits = list(TRAIT_SHOVE_RESIST)

/obj/item/organ/cyberimp/leg/trait/shove_resist/l
	zone = BODY_ZONE_L_LEG

/obj/item/organ/cyberimp/leg/trait/sprinter
	name = "system wiązadeł wakuolowych"
	desc = "Mechaniczne serwa w nogach, które wydłużają naturalny krok. Popularne wśród miłośników parkouru. Trzeba go wszczepić w obie nogi."
	double_legged_type = /obj/item/organ/cyberimp/leg/trait/sprinter
	pair_traits = list(TRAIT_FREERUNNING, TRAIT_LIGHT_STEP)

/obj/item/organ/cyberimp/leg/trait/sprinter/l
	zone = BODY_ZONE_L_LEG

/// Popchnięcie przy komplecie BU-TAM: zamiast przewrócenia trochę zmęczenia (hook w /datum/species/proc/disarm)
/mob/living/carbon/human/proc/resist_shove(mob/living/carbon/user)
	user.do_attack_animation(src, ATTACK_EFFECT_DISARM)
	playsound(src, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
	adjustStaminaLoss(3.5)
	visible_message(span_danger("[user] próbuje popchnąć [src], ale ten ani drgnie!"), \
		span_userdanger("[user] prawie cię przewraca!"), span_hear("Słyszysz agresywne szuranie!"), COMBAT_MESSAGE_RANGE, list(user))
	to_chat(user, span_warning("Popychasz [src], ale stoi jak wryty!"))
	log_combat(user, src, "shoved", "resisted (shove resist implant)")
	return FALSE

// P.R.Y.Z.H.O.K. - uproszczony tackler: w trybie rzutu klik pustą ręką rzuca cię na cel.

/obj/item/organ/cyberimp/leg/accelerator
	name = "system przyspieszenia P.R.Y.Z.H.O.K."
	desc = "Rosyjski implant do powalania ludzi szarżą. Włącz tryb rzutu i kliknij cel pustą ręką. Trzeba go wszczepić w obie nogi."
	double_legged_type = /obj/item/organ/cyberimp/leg/accelerator
	/// Zasięg szarży
	var/tackle_range = 5
	/// Prędkość lotu
	var/tackle_speed = 2
	/// Koszt wytrzymałości
	var/tackle_stamina_cost = 12
	/// Jak długo leży trafiony cel
	var/tackle_knockdown = 3 SECONDS
	/// Leci właśnie szarżą
	var/tackling = FALSE
	COOLDOWN_DECLARE(tackle_cooldown)

/obj/item/organ/cyberimp/leg/accelerator/l
	zone = BODY_ZONE_L_LEG

/obj/item/organ/cyberimp/leg/accelerator/on_full_insert(mob/living/carbon/user)
	RegisterSignal(user, COMSIG_MOB_CLICKON, PROC_REF(on_click))

/obj/item/organ/cyberimp/leg/accelerator/on_full_remove(mob/living/carbon/user)
	UnregisterSignal(user, list(COMSIG_MOB_CLICKON, COMSIG_MOVABLE_IMPACT))
	tackling = FALSE
	// Sygnał mógł zarejestrować implant z drugiej nogi (ten, który domknął parę)
	var/obj/item/organ/cyberimp/leg/accelerator/partner = get_partner(user)
	if(partner)
		partner.UnregisterSignal(user, list(COMSIG_MOB_CLICKON, COMSIG_MOVABLE_IMPACT))
		partner.tackling = FALSE

/obj/item/organ/cyberimp/leg/accelerator/proc/on_click(mob/living/carbon/source, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(source.throw_mode == THROW_MODE_DISABLED || source.get_active_held_item())
		return NONE
	if(LAZYACCESS(modifiers, SHIFT_CLICK) || LAZYACCESS(modifiers, CTRL_CLICK) || LAZYACCESS(modifiers, ALT_CLICK) || LAZYACCESS(modifiers, MIDDLE_CLICK))
		return NONE
	if(!isturf(source.loc) || source.buckled || source.incapacitated() || source.resting || tackling)
		return NONE
	if(!COOLDOWN_FINISHED(src, tackle_cooldown) || get_turf(target) == get_turf(source))
		return NONE
	if((organ_flags & ORGAN_FAILING) || source.getStaminaLoss() >= 80)
		source.balloon_alert(source, "nogi odmawiają!")
		return COMSIG_MOB_CANCEL_CLICKON

	source.throw_mode_off(THROW_MODE_TOGGLE)
	COOLDOWN_START(src, tackle_cooldown, 2 SECONDS)
	tackling = TRUE
	source.adjustStaminaLoss(tackle_stamina_cost)
	source.visible_message(span_warning("[source] rzuca się szarżą!"), span_danger("Rzucasz się szarżą!"))
	RegisterSignal(source, COMSIG_MOVABLE_IMPACT, PROC_REF(on_impact))
	INVOKE_ASYNC(source, TYPE_PROC_REF(/atom/movable, throw_at), target, tackle_range, tackle_speed, source, FALSE, FALSE, CALLBACK(src, PROC_REF(tackle_end), source), MOVE_FORCE_WEAK)
	return COMSIG_MOB_CANCEL_CLICKON

/obj/item/organ/cyberimp/leg/accelerator/proc/tackle_end(mob/living/carbon/source)
	tackling = FALSE
	if(source)
		UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)

/obj/item/organ/cyberimp/leg/accelerator/proc/on_impact(mob/living/carbon/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_MOVABLE_IMPACT)
	tackling = FALSE
	if(isliving(hit_atom))
		var/mob/living/victim = hit_atom
		victim.Knockdown(tackle_knockdown)
		source.Knockdown(1 SECONDS)
		source.visible_message(span_danger("[source] powala [victim] szarżą!"), span_userdanger("Powalasz [victim] szarżą!"), ignored_mobs = list(victim))
		to_chat(victim, span_userdanger("[source] powala cię szarżą!"))
		log_combat(source, victim, "tackled", "leg accelerator implant")
	else if(hit_atom.density)
		source.Knockdown(2 SECONDS)
		source.visible_message(span_danger("[source] wbija się w [hit_atom]!"), span_userdanger("Wbijasz się w [hit_atom]!"))

// Organy w nogach wkłada się tą samą operacją co w rękach
/datum/surgery/organ_manipulation/soft/New(atom/surgery_target, surgery_location, surgery_bodypart)
	. = ..()
	possible_locs |= list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

/datum/surgery/organ_manipulation/mechanic/soft/New(atom/surgery_target, surgery_location, surgery_bodypart)
	. = ..()
	possible_locs |= list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
