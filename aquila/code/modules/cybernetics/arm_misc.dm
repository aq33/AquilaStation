// Port cybernetyki z Monkestation: pozostałe implanty rąk (drut tnący, Strong-Arm, chłodzenie i grzanie podskórne)

// Drut tnący. Bez smyczy (component/leash) z Monke: zostaje bicz o zasięgu 2 kratek.

/obj/item/organ/cyberimp/arm/razorwire
	name = "implant ze szpulą drutu tnącego"
	desc = "Wbudowana szpula drutu tnącego, którym można smagać przeciwników jak biczem. \
		Siedzi w grzbiecie dłoni, staraj się go nie splątać."
	icon = 'aquila/icons/obj/cybernetics/implants.dmi'
	icon_state = "razorwire"
	syndicate_implant = TRUE
	items_to_create = list(/obj/item/melee/razorwire)

/obj/item/organ/cyberimp/arm/razorwire/l
	zone = BODY_ZONE_L_ARM

/obj/item/melee/razorwire
	name = "wszczepiony drut tnący"
	desc = "Długie włókno monomolekularne wbudowane w grzbiet dłoni. Nieprawdopodobnie cienkie i idealnie ostre, \
		bez trudu tnie tkanki organiczne nawet z kilku kroków. Na czymś twardszym wyniki bywają różne."
	icon = 'aquila/icons/obj/cybernetics/implants.dmi'
	icon_state = "razorwire_weapon"
	item_state = "razorwire"
	lefthand_file = 'aquila/icons/obj/cybernetics/implants_lefthand.dmi'
	righthand_file = 'aquila/icons/obj/cybernetics/implants_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	sharpness = IS_SHARP
	force = 15
	bleed_force = BLEED_CUT
	reach = 2
	hitsound = 'sound/weapons/whip.ogg'
	attack_verb = list("ciacha", "smaga", "chlasta", "rozcina")

// Strong-Arm

/obj/item/organ/cyberimp/arm/strongarm
	name = "implant wzmocnienia mięśni Strong-Arm"
	desc = "Ten implant wzmacnia mięśnie ręki, by każdy ruch miał więcej siły. Ciosy w combat mode odrzucają przeciwnika. \
		Z implantem w obu rękach podważysz drzwi gołymi rękami (pusta ręka, combat mode)."
	icon = 'aquila/icons/obj/cybernetics/implants.dmi'
	icon_state = "muscle_implant"
	actions_types = list()
	/// Obrażenia dokładane do ciosu
	var/punch_damage = 5
	/// Dodatkowe obrażenia dla bestii i megafauny
	var/biotype_bonus_damage = 20
	/// Na ile kratek odrzuca cel
	var/attack_throw_range = 1
	/// Jak długo po EMP mięśnie wariują
	var/emp_base_duration = 9 SECONDS
	/// Odnowienie mocnego ciosu (implanty zwykle są w parze)
	var/slam_cooldown_duration = 5 SECONDS
	COOLDOWN_DECLARE(slam_cooldown)

/obj/item/organ/cyberimp/arm/strongarm/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/strongarm/SetSlotFromZone()
	switch(zone)
		if(BODY_ZONE_L_ARM)
			slot = ORGAN_SLOT_LEFT_ARM_MUSCLE
		if(BODY_ZONE_R_ARM)
			slot = ORGAN_SLOT_RIGHT_ARM_MUSCLE
		else
			CRASH("Invalid zone for [type]")

/obj/item/organ/cyberimp/arm/strongarm/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(owner == M && ishuman(M))
		RegisterSignal(M, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, PROC_REF(on_attack_hand))

/obj/item/organ/cyberimp/arm/strongarm/Remove(mob/living/carbon/M, special = 0)
	if(M)
		UnregisterSignal(M, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)
	return ..()

// Nie ma czego wysuwać, więc klik pustą dłonią nie otwiera menu implantu
/obj/item/organ/cyberimp/arm/strongarm/on_item_attack_self()
	return

/obj/item/organ/cyberimp/arm/strongarm/ui_action_click()
	return

/obj/item/organ/cyberimp/arm/strongarm/emp_act(severity)
	. = ..()
	if(!owner || (organ_flags & ORGAN_FAILING) || (. & EMP_PROTECT_SELF))
		return
	owner.balloon_alert(owner, "ręka wpada w skurcze!")
	organ_flags |= ORGAN_FAILING
	addtimer(CALLBACK(src, PROC_REF(reboot)), emp_base_duration / severity)

/obj/item/organ/cyberimp/arm/strongarm/proc/reboot()
	organ_flags &= ~ORGAN_FAILING
	owner?.balloon_alert(owner, "skurcze ręki mijają")

/// Oba Strong-Army sprawne - liczone ręcznie zamiast organ_set_bonus z tg
/obj/item/organ/cyberimp/arm/strongarm/proc/has_working_pair(mob/living/carbon/user)
	var/obj/item/organ/cyberimp/arm/strongarm/left = user.getorganslot(ORGAN_SLOT_LEFT_ARM_MUSCLE)
	var/obj/item/organ/cyberimp/arm/strongarm/right = user.getorganslot(ORGAN_SLOT_RIGHT_ARM_MUSCLE)
	if(!istype(left) || !istype(right))
		return FALSE
	return !((left.organ_flags | right.organ_flags) & ORGAN_FAILING)

/obj/item/organ/cyberimp/arm/strongarm/proc/on_attack_hand(mob/living/carbon/human/source, atom/target, proximity, list/modifiers)
	SIGNAL_HANDLER

	if(!proximity || source.get_active_hand() != source.get_bodypart(zone))
		return NONE
	if(!source.combat_mode || LAZYACCESS(modifiers, RIGHT_CLICK))
		return NONE

	// Para implantów podważa drzwi (tg: element door_pryer z organ_set_bonus)
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/airlock = target
		if(!airlock.density || airlock.charge || !has_working_pair(source))
			return NONE
		INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door/airlock, try_to_crowbar), null, source, TRUE)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(!isliving(target) || target == source)
		return NONE
	if(source.dna?.check_mutation(HULK))
		return NONE
	if(!COOLDOWN_FINISHED(src, slam_cooldown))
		return NONE

	var/mob/living/living_target = target
	source.changeNext_move(CLICK_CD_MELEE)
	var/list/hit_verbs = pick(list("uderza", "uderzasz"), list("grzmoci", "grzmocisz"), list("wali", "walisz"), list("tłucze", "tłuczesz"), list("rąbie", "rąbiesz"))

	if(organ_flags & ORGAN_FAILING)
		if(!source.resting && prob(50))
			to_chat(source, span_danger("Próbujesz zaatakować [living_target], ale tracisz równowagę i się przewracasz!"))
			source.Knockdown(3 SECONDS)
			source.forceMove(get_turf(living_target))
		else
			to_chat(source, span_danger("Twoje mięśnie łapie skurcz!"))
			source.Paralyze(1 SECONDS)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(ishuman(living_target))
		var/mob/living/carbon/human/human_target = living_target
		if(human_target.check_shields(source, punch_damage, "cios [source]", UNARMED_ATTACK))
			source.do_attack_animation(living_target)
			playsound(living_target.loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
			log_combat(source, living_target, "attempted to slam", "muscle implant")
			return COMPONENT_CANCEL_ATTACK_CHAIN

	var/damage = punch_damage + rand(1, source.dna?.species?.punchdamage || 7)
	if((MOB_BEAST in living_target.mob_biotypes) || (MOB_EPIC in living_target.mob_biotypes))
		damage += biotype_bonus_damage

	source.do_attack_animation(living_target, ATTACK_EFFECT_SMASH)
	playsound(living_target.loc, 'sound/weapons/punch1.ogg', 25, TRUE, -1)

	var/target_zone = ran_zone(source.zone_selected)
	var/armor_block = living_target.run_armor_check(target_zone, "melee")
	living_target.apply_damage(damage, BRUTE, target_zone, armor_block)
	living_target.apply_damage(damage, STAMINA, target_zone, armor_block)

	if(!source.resting) // stojąc odrzucamy cel
		var/atom/throw_target = get_edge_target_turf(living_target, source.dir)
		living_target.throw_at(throw_target, attack_throw_range, rand(1, 4), source, force = MOVE_FORCE_WEAK)

	living_target.visible_message(span_danger("[source] [hit_verbs[1]] [living_target] wzmocnioną pięścią!"), \
		span_userdanger("[source] [hit_verbs[1]] cię wzmocnioną pięścią!"), \
		span_hear("Słyszysz obrzydliwy odgłos uderzenia w ciało!"), COMBAT_MESSAGE_RANGE, list(source))
	to_chat(source, span_danger("[capitalize(hit_verbs[2])] [living_target] wzmocnioną pięścią!"))
	log_combat(source, living_target, "slammed", "muscle implant")
	COOLDOWN_START(src, slam_cooldown, slam_cooldown_duration)
	return COMPONENT_CANCEL_ATTACK_CHAIN

// Podskórne chłodzenie i grzanie. Monke używa homeostazy z tg, u nas to zwykłe przesunięcie temperatury ciała.

/obj/item/organ/cyberimp/arm/cooler
	name = "podskórny implant chłodzący"
	desc = "Implant w dłoni, który schładza cię, gdy się przegrzewasz."
	icon = 'aquila/icons/obj/cybernetics/implants.dmi'
	icon_state = "hand_implant"
	implant_overlay = "hand_implant_overlay"
	implant_color = "#00e1ff"
	actions_types = list()
	/// O ile kelwinów na tick organu zbliża temperaturę do normy
	var/temperature_step = 2
	/// Chłodzi (TRUE) albo grzeje (FALSE)
	var/cooling = TRUE

/obj/item/organ/cyberimp/arm/cooler/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/cooler/on_item_attack_self()
	return

/obj/item/organ/cyberimp/arm/cooler/ui_action_click()
	return

/obj/item/organ/cyberimp/arm/cooler/on_life()
	. = ..()
	if(!owner || (organ_flags & ORGAN_FAILING))
		return
	if(cooling && owner.bodytemperature > BODYTEMP_NORMAL + 2)
		owner.adjust_bodytemperature(-temperature_step, min_temp = BODYTEMP_NORMAL)
	else if(!cooling && owner.bodytemperature < BODYTEMP_NORMAL - 2)
		owner.adjust_bodytemperature(temperature_step, max_temp = BODYTEMP_NORMAL)

/obj/item/organ/cyberimp/arm/cooler/heater
	name = "podskórny implant grzewczy"
	desc = "Implant w dłoni, który ogrzewa cię, gdy marzniesz."
	implant_color = "#ff9100"
	cooling = FALSE

/obj/item/organ/cyberimp/arm/cooler/heater/l
	zone = BODY_ZONE_L_ARM
