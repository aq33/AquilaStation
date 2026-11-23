// AQUILA - wspólne elementy implantów i augmentów z wdrożenia robotyki (część IMPLANTY).
// Koszt cyberpsychozy, zakłócanie augmentów, kanał binarny, swój-obcy, zdalne sterowanie maszynami (implant przejęcia).

/// Koszt cyberpsychozy augmentu (0-3 pkt). Mechanikę liczy część ROBOTYKA, tu tylko wartość.
/// Zmienna jest na każdym narządzie, bo augmentem bywa też narząd (cyberoko, mózg z łączem SI), nie tylko /obj/item/organ/cyberimp.
/obj/item/organ/var/aq_cyberpsychosis_cost = 0

/// Czy augmenty moba są zakłócone (implant zakłócający augmenty)
/mob/living/proc/aq_augments_disrupted()
	return HAS_TRAIT(src, TRAIT_AQ_AUGMENTS_DISRUPTED)

/// Czy augment może teraz działać: wszczepiony, sprawny i niezakłócony. Z komunikatem dla nosiciela.
/obj/item/organ/proc/aq_augment_usable(silent = FALSE)
	if(!owner)
		return FALSE
	if(organ_flags & ORGAN_FAILING)
		if(!silent)
			to_chat(owner, span_warning("[capitalize(name)] nie reaguje. Wygląda na zepsuty..."))
		return FALSE
	if(owner.aq_augments_disrupted())
		if(!silent)
			to_chat(owner, span_warning("[capitalize(name)] nie odpowiada: coś zagłusza sygnał augmentów."))
		return FALSE
	return TRUE

// Zakłócone augmenty: przyciski akcji implantów cybernetycznych nic nie robią
/datum/action/item_action/Trigger()
	if(owner && istype(target, /obj/item/organ/cyberimp) && isliving(owner))
		var/mob/living/living_owner = owner
		if(living_owner.aq_augments_disrupted())
			to_chat(owner, span_warning("[capitalize(target.name)] nie odpowiada: coś zagłusza sygnał augmentów."))
			return FALSE
	return ..()

// Zakłócone augmenty: narzędzia nie wysuwają się z rąk
/obj/item/organ/cyberimp/arm/Extend(obj/item/item)
	if(owner?.aq_augments_disrupted())
		to_chat(owner, span_warning("[capitalize(name)] nie odpowiada: coś zagłusza sygnał augmentów."))
		return
	return ..()

// Kanał binarny bez słuchawek: powłoka SI (mózg z łączem SI)
/mob/living/carbon/human/binarycheck()
	. = ..()
	if(!. && stat < SOFT_CRIT && HAS_TRAIT(src, TRAIT_AQ_BINARY_SPEAKER))
		return TRUE

/// Frakcja implantu swój-obcy albo null
/mob/living/proc/aq_iff_faction()
	for(var/obj/item/implant/aq_iff/iff in implants)
		return iff.iff_faction
	return null

// Swój-obcy: pocisk strzelca z implantem przelatuje przez nosiciela implantu tej samej frakcji,
// chyba że strzelec celuje prosto w niego (jak IFF smyczy drużyny w gunplay/iff_smart.dm)
/obj/item/projectile/can_hit_target(atom/target, direct_target = FALSE, ignore_loc = FALSE, cross_failed = FALSE)
	if(!direct_target && target != original && isliving(target) && isliving(firer) && target != firer)
		var/mob/living/living_target = target
		var/mob/living/shooter = firer
		var/target_faction = living_target.aq_iff_faction()
		if(target_faction && target_faction == shooter.aq_iff_faction())
			return FALSE
	return ..()

// Implant przejęcia: maszyny w przejętym obszarze jak dla SI (/obj/machinery/can_interact).
// Tylko maszyny, które SI może obsłużyć: pozostałe nosiciel obsługuje rękami jak zwykle.
/mob/living/carbon/human/has_remote_machine_access(atom/target)
	. = ..()
	if(. || stat || incapacitated() || !istype(target))
		return
	if(ismachinery(target))
		var/obj/machinery/machine = target
		if(!(machine.interaction_flags_machine & INTERACT_MACHINE_ALLOW_SILICON))
			return FALSE
	for(var/obj/item/implant/aq_hijack/hijack in implants)
		if(hijack.toggled && hijack.hijacked_area && get_area(target) == hijack.hijacked_area)
			return TRUE

// Zdalne sterowanie śluzą (panel SI) dla tego, kto ma zdalny dostęp do maszyn w jej obszarze (implant przejęcia).
// Bez tego user_allowed() wpuszcza tylko silikony, więc panel śluzy się otwierał, ale żaden przycisk nie działał.
/obj/machinery/door/airlock/user_allowed(mob/user)
	. = ..()
	if(. || !user?.has_remote_machine_access(src))
		return
	if((obj_flags & EMAGGED) || detonated)
		return FALSE
	return canAIControl(user)

/mob/living/carbon/human/default_can_use_topic(src_object)
	if(isatom(src_object) && has_remote_machine_access(src_object))
		return shared_ui_interaction(src_object)
	return ..()

// Ośrodek smaku: po skosztowaniu podaje skład
/mob/living/carbon/taste(datum/reagents/from)
	var/tasted_before = last_taste_time
	. = ..()
	if(last_taste_time == tasted_before || !from)
		return
	var/obj/item/organ/cyberimp/aq_gustatorial/analyzer = getorganslot(ORGAN_SLOT_AQ_GUSTATORIAL)
	if(istype(analyzer) && analyzer.aq_augment_usable(TRUE))
		analyzer.report_reagents(from)
