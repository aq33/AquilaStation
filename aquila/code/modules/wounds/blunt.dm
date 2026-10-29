// AQUILA - blunt wounds: dislocation, fracture, compound fracture

/datum/wound/blunt
	wound_type = WOUND_BLUNT
	/// Per second chance to drop what the hand holds, untreated and treated
	var/drop_chance = 0
	var/treated_drop_chance = 0
	/// Bone gel and surgical tape (tgstation bones.dm): how long the taped bone takes to knit, 0 if they do not work here
	var/regen_time = 0
	var/regen_progress = 0
	/// Coated with bone gel, waits for the tape
	var/gelled = FALSE
	/// Taped over the gel, the bone knits by itself
	var/taped = FALSE

/datum/wound/blunt/on_apply()
	if(severity >= WOUND_SEVERITY_SEVERE)
		victim.play_bone_break()

/datum/wound/blunt/wound_effects(delta_time)
	var/drop = treated ? treated_drop_chance : drop_chance
	if(drop && (limb.body_zone == BODY_ZONE_L_ARM || limb.body_zone == BODY_ZONE_R_ARM) && DT_PROB(drop, delta_time))
		var/obj/item/held = victim.get_item_for_held_index(limb.held_index)
		if(held && victim.dropItemToGround(held))
			to_chat(victim, "<span class='danger'>Ból w [limb.name] sprawia, że upuszczasz [held]!</span>")
	if(treated)
		return
	switch(limb.body_zone)
		if(BODY_ZONE_CHEST)
			if(DT_PROB(severity, delta_time))
				to_chat(victim, "<span class='danger'>Połamane żebra kłują cię przy każdym oddechu!</span>")
				victim.adjustStaminaLoss(5 * severity)
		if(BODY_ZONE_HEAD)
			if(DT_PROB(severity, delta_time))
				to_chat(victim, "<span class='danger'>Kręci ci się w głowie z bólu!</span>")
				victim.Dizzy(4 * severity)

/// Gauze works as a splint on fractures, bone gel and then surgical tape make the bone knit by itself
/datum/wound/blunt/can_treat_with(obj/item/item)
	if(severity < WOUND_SEVERITY_SEVERE)
		return FALSE
	if(istype(item, /obj/item/stack/medical/bone_gel) || istype(item, /obj/item/stack/sticky_tape/surgical))
		return regen_time && !taped && !limb_in_surgery()
	return !treated && istype(item, /obj/item/stack/medical/gauze)

/datum/wound/blunt/treat(obj/item/item, mob/user)
	if(istype(item, /obj/item/stack/medical/bone_gel))
		return apply_gel(item, user)
	if(istype(item, /obj/item/stack/sticky_tape/surgical))
		return apply_tape(item, user)
	var/obj/item/stack/medical/gauze/gauze = item
	var/self = user == victim
	user.visible_message("<span class='notice'>[user] zaczyna unieruchamiać [limb.name] [victim] opatrunkiem.</span>", "<span class='notice'>Zaczynasz unieruchamiać [limb.name] [self ? "" : "[victim] "]opatrunkiem.</span>")
	if(!do_mob(user, victim, self ? 6 SECONDS : 3 SECONDS))
		return FALSE
	if(QDELETED(src) || treated || !gauze.use(1))
		return FALSE
	treated = TRUE
	victim.update_wound_slowdown()
	user.visible_message("<span class='green'>[user] unieruchamia [limb.name] [victim].</span>", "<span class='green'>Unieruchamiasz [limb.name] [self ? "" : "[victim]"].</span>")
	return TRUE

/// An open surgery on this limb wants the real bone setting, not the emergency gel
/datum/wound/blunt/proc/limb_in_surgery()
	for(var/datum/surgery/surgery as anything in victim.surgeries)
		if(surgery.location == limb.body_zone)
			return TRUE
	// nowy szkielet chirurgii: kończyna otwarta, kość składa operacja
	if(LIMB_HAS_ANY_SURGERY_STATE(limb, ALL_SURGERY_SKIN_STATES))
		return TRUE
	return FALSE

/// tgstation bones.dm gel(): painful, and applied to yourself it can knock you out before you finish
/datum/wound/blunt/proc/apply_gel(obj/item/stack/medical/bone_gel/gel, mob/user)
	var/self = user == victim
	if(gelled)
		to_chat(user, "<span class='warning'>[capitalize(limb.name)] [self ? "" : "[victim] "]jest już pokryta żelem kostnym!</span>")
		return FALSE
	user.visible_message("<span class='danger'>[user] w pośpiechu nakłada [gel] na [limb.name] [victim]...</span>", "<span class='warning'>W pośpiechu nakładasz [gel] na [limb.name][self ? "" : " [victim]"], ignorując ostrzeżenie na etykiecie...</span>")
	if(!do_mob(user, victim, self ? 11 SECONDS : 7.5 SECONDS))
		return FALSE
	if(QDELETED(src) || gelled || !gel.use(1))
		return FALSE
	victim.emote("scream")
	if(!self)
		user.visible_message("<span class='notice'>[user] kończy nakładać [gel] na [limb.name] [victim], słychać syczenie!</span>", "<span class='notice'>Kończysz nakładać [gel] na [limb.name] [victim]!</span>", ignored_mobs = victim)
		to_chat(victim, "<span class='userdanger'>[user] kończy nakładać [gel] na [limb.name], a kości eksplodują bólem, topiąc się i zrastając na nowo!</span>")
	else
		// 25% on a fracture, 45% on a compound fracture, less when drunk, none on morphine
		if(!victim.reagents?.has_reagent(/datum/reagent/medicine/morphine) && prob(25 + 20 * (severity - WOUND_SEVERITY_SEVERE) - min(victim.drunkenness, 10)))
			victim.visible_message("<span class='danger'>[victim] nie daje rady dokończyć nakładania [gel] na [limb.name] i mdleje z bólu!</span>", "<span class='userdanger'>Mdlejesz z bólu, zanim kończysz nakładać [gel] na [limb.name]!</span>")
			victim.AdjustUnconscious(5 SECONDS)
			return TRUE
		victim.visible_message("<span class='notice'>[victim] kończy nakładać [gel] na [limb.name], krzywiąc się z bólu!</span>", "<span class='userdanger'>Kończysz nakładać [gel] na [limb.name], a kości eksplodują bólem!</span>")
	set_gelled()
	return TRUE

/// The gel is on: it burns the limb and drains stamina, the tape comes next
/datum/wound/blunt/proc/set_gelled()
	limb.receive_damage(25)
	victim.adjustStaminaLoss(100)
	gelled = TRUE
	update_bone_treat_text()

/// tgstation bones.dm tape(): the gel needs tape over it to start knitting the bone
/datum/wound/blunt/proc/apply_tape(obj/item/stack/sticky_tape/surgical/tape, mob/user)
	var/self = user == victim
	if(!gelled)
		to_chat(user, "<span class='warning'>[capitalize(limb.name)] [self ? "" : "[victim] "]musi być najpierw pokryta żelem kostnym!</span>")
		return FALSE
	user.visible_message("<span class='danger'>[user] zaczyna owijać [limb.name] [victim] taśmą chirurgiczną...</span>", "<span class='warning'>Zaczynasz owijać [limb.name][self ? "" : " [victim]"] taśmą chirurgiczną...</span>")
	if(!do_mob(user, victim, self ? 7.5 SECONDS : 5 SECONDS))
		return FALSE
	if(QDELETED(src) || taped || !tape.use(1))
		return FALSE
	start_knitting(self)
	if(!self)
		user.visible_message("<span class='notice'>[user] owija [limb.name] [victim] taśmą chirurgiczną.</span>", "<span class='notice'>Owijasz [limb.name] [victim] taśmą chirurgiczną.</span>", ignored_mobs = victim)
		to_chat(victim, "<span class='green'>[user] owija ci [limb.name] taśmą chirurgiczną, od razu czujesz, jak kości zaczynają się zrastać!</span>")
	else
		victim.visible_message("<span class='notice'>[victim] owija sobie [limb.name] taśmą chirurgiczną.</span>", "<span class='green'>Owijasz [limb.name] taśmą chirurgiczną i od razu czujesz, jak kości zaczynają się zrastać!</span>")
	return TRUE

/// Gel and tape are on, the bone knits by itself. Done on yourself it takes half as long again.
/datum/wound/blunt/proc/start_knitting(self = FALSE)
	if(self)
		regen_time *= 1.5
	taped = TRUE
	update_bone_treat_text()

/// The analyzer reads treat_text, so it follows the gel and the tape
/datum/wound/blunt/proc/update_bone_treat_text()
	if(taped)
		treat_text = "Żel kostny i taśma chirurgiczna: kość się zrasta ([round(100 * regen_progress / regen_time)]%). Leżenie i sen przyspieszają."
	else if(gelled)
		treat_text = "Pokryta żelem kostnym: owiń taśmą chirurgiczną, żeby kość zaczęła się zrastać."

/datum/wound/blunt/process(delta_time)
	. = ..()
	if(QDELETED(src) || !taped || victim.stat == DEAD)
		return
	regen_progress += delta_time SECONDS
	if(!(victim.mobility_flags & MOBILITY_STAND))
		if(DT_PROB(30, delta_time))
			regen_progress += 2 SECONDS
		if(victim.IsSleeping() && DT_PROB(30, delta_time))
			regen_progress += 2 SECONDS
	if(DT_PROB(severity * 1.5, delta_time))
		limb.receive_damage(rand(1, severity * 2))
		victim.adjustStaminaLoss(rand(2, severity * 2.5))
		if(prob(33))
			to_chat(victim, "<span class='danger'>Czujesz ostry ból, gdy kości ci się zrastają!</span>")
	if(regen_progress >= regen_time)
		to_chat(victim, "<span class='green'>[capitalize(limb.name)]: [name] się zrosło.</span>")
		qdel(src)
		return
	update_bone_treat_text()

/datum/wound/blunt/dislocation
	name = "Zwichnięcie"
	desc = "Coś przeskakuje ci w stawie"
	examine_desc = "wykręconą kończynę"
	treat_text = "Nastaw ją: pomoc z pustą ręką, celując w kończynę."
	severity = WOUND_SEVERITY_MODERATE
	threshold = 35
	allowed_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	drop_chance = 1
	limp_slowdown = 0.3

/datum/wound/blunt/dislocation/can_treat_with(obj/item/item)
	return FALSE

/// Help intent with an empty hand on the limb puts it back in place
/datum/wound/blunt/dislocation/proc/try_reset(mob/living/carbon/user)
	var/self = user == victim
	user.visible_message("<span class='notice'>[user] chwyta [limb.name] [victim] i próbuje ją nastawić.</span>", "<span class='notice'>Próbujesz nastawić [limb.name] [self ? "" : "[victim]"].</span>")
	if(!do_mob(user, victim, self ? 6 SECONDS : 3 SECONDS))
		return
	if(QDELETED(src))
		return
	if(prob(self ? 50 : 80))
		victim.visible_message("<span class='danger'>[user] z trzaskiem nastawia [limb.name] [victim]!</span>", "<span class='userdanger'>[limb.name] wskakuje z trzaskiem na miejsce!</span>")
		victim.emote("scream")
		limb.receive_damage(5)
		qdel(src)
	else
		victim.visible_message("<span class='danger'>[user] szarpie [limb.name] [victim], ale nic z tego!</span>", "<span class='userdanger'>Ból przeszywa [limb.name]!</span>")
		limb.receive_damage(5)

/datum/wound/blunt/fracture
	name = "Pęknięcie kości"
	desc = "Słyszysz chrupnięcie kości"
	examine_desc = "spuchniętą, posiniaczoną kończynę"
	treat_text = "Unieruchom gazą, zrośnie się po kilku minutach. Albo żel kostny i taśma chirurgiczna (bolesne, ok. 4 minuty), albo operacja nastawienia kości."
	severity = WOUND_SEVERITY_SEVERE
	threshold = 60
	heal_time = 3 MINUTES
	regen_time = 4 MINUTES
	drop_chance = 3
	limp_slowdown = 0.8
	treated_limp_slowdown = 0.3

/datum/wound/blunt/compound
	name = "Złamanie otwarte"
	desc = "Kość przebija ci skórę"
	examine_desc = "kość sterczącą z rany"
	treat_text = "Operacja nastawienia kości. W nagłym wypadku żel kostny, potem taśma chirurgiczna (bardzo bolesne, ok. 8 minut). Gaza tylko unieruchamia."
	severity = WOUND_SEVERITY_CRITICAL
	threshold = 115
	regen_time = 8 MINUTES
	drop_chance = 10
	treated_drop_chance = 2
	limp_slowdown = 1.5
	treated_limp_slowdown = 0.6

/datum/wound/blunt/compound/on_apply()
	. = ..()
	victim.add_bleeding(BLEED_SURFACE)

/mob/living/carbon/help_shake_act(mob/living/carbon/M)
	var/obj/item/bodypart/limb = get_bodypart(check_zone(M.zone_selected))
	var/datum/wound/blunt/dislocation/dislocation = locate() in limb?.wounds
	if(dislocation && !M.get_active_held_item())
		if(src in M.do_afters) // one reset attempt at a time
			return
		INVOKE_ASYNC(dislocation, TYPE_PROC_REF(/datum/wound/blunt/dislocation, try_reset), M)
		return
	return ..()
