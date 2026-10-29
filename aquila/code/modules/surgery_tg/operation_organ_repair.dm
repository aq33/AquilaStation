// AQUILA - tg code/modules/surgery/operations/operation_organ_repair.dm
// Naprawa organów. Stare wersje: coronary_bypass.dm, lobectomy.dm, hepatectomy.dm, gastrectomy.dm, eye_surgery.dm,
// brain_recalibration.dm i ear_surgery.dm Aquili. Zostają nasze progi i efekty: serce i płuca od 60 uszkodzeń i tylko raz
// (zmienna operated), wątroba i żołądek od 50 uszkodzeń, nie gdy już padły, i bez limitu; oczy leczą też ślepotę
// i krótkowzroczność od uszkodzeń, uszy dają chwilową głuchotę, mózg leczy 60 punktów na raz.
// Pominięte z tg: ORGAN_EMP (nie mamy).

/// Naprawa konkretnego organu
/datum/surgery_operation/organ/repair
	abstract_type = /datum/surgery_operation/organ/repair
	name = "naprawa organu"
	desc = "Naprawia uszkodzony organ pacjenta."
	required_organ_flag = ORGAN_ORGANIC
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE | OPERATION_NO_PATIENT_REQUIRED
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|SURGERY_BONE_SAWED
	/// Do ilu % uszkodzeń leczy organ (0% uszkodzeń = pełne zdrowie)
	var/heal_to_percent = 0.6
	/// AQUILA - od ilu % uszkodzeń operacja jest dostępna (null = heal_to_percent, jak w tg)
	var/required_damage_percent
	/// AQUILA - nie da się naprawić organu, który już padł (stara hepatektomia i gastrektomia)
	var/blocked_if_failing = FALSE
	/// Ile % uszkodzeń dodaje porażka
	var/failure_damage_percent = 0.2
	/// TRUE - organ można naprawiać wiele razy
	var/repeatable = FALSE

/datum/surgery_operation/organ/repair/New()
	. = ..()
	if(operation_flags & OPERATION_LOOPING)
		repeatable = TRUE
	if(isnull(required_damage_percent))
		required_damage_percent = heal_to_percent
	if(!repeatable)
		desc += " Można ją zrobić tylko raz na organie."

/datum/surgery_operation/organ/repair/state_check(obj/item/organ/organ)
	if(organ.damage <= (organ.maxHealth * required_damage_percent))
		return FALSE
	if(blocked_if_failing && (organ.organ_flags & ORGAN_FAILING))
		return FALSE
	if(!repeatable && was_operated(organ))
		return FALSE
	return TRUE

/// Czy organ był już naprawiany (nowy szkielet albo stara operacja serca/płuc)
/datum/surgery_operation/organ/repair/proc/was_operated(obj/item/organ/organ)
	if(HAS_TRAIT(organ, TRAIT_ORGAN_OPERATED_ON))
		return TRUE
	if(istype(organ, /obj/item/organ/heart))
		var/obj/item/organ/heart/heart = organ
		return heart.operated
	if(istype(organ, /obj/item/organ/lungs))
		var/obj/item/organ/lungs/lungs = organ
		return lungs.operated
	return FALSE

/datum/surgery_operation/organ/repair/all_required_strings()
	. = ..()
	. += "organ musi być wyraźnie uszkodzony"
	if(blocked_if_failing)
		. += "organ nie może jeszcze całkiem paść"

/datum/surgery_operation/organ/repair/all_blocked_strings()
	. = ..()
	if(!repeatable)
		. += "organ nie mógł być wcześniej naprawiany chirurgicznie"

/datum/surgery_operation/organ/repair/on_success(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	organ.setOrganDamage(organ.maxHealth * heal_to_percent)
	ADD_TRAIT(organ, TRAIT_ORGAN_OPERATED_ON, TRAIT_GENERIC)
	// zgodność ze starymi operacjami serca i płuc
	if(istype(organ, /obj/item/organ/heart))
		var/obj/item/organ/heart/heart = organ
		heart.operated = TRUE
	else if(istype(organ, /obj/item/organ/lungs))
		var/obj/item/organ/lungs/lungs = organ
		lungs.operated = TRUE

/datum/surgery_operation/organ/repair/on_failure(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	organ.applyOrganDamage(organ.maxHealth * failure_damage_percent)

// --- Płuca ---

/datum/surgery_operation/organ/repair/lobectomy
	name = "wycięcie uszkodzonego płata płuca"
	rnd_name = "Lobektomia (operacja płuc)"
	desc = "Naprawia uszkodzone płuca, wycinając najbardziej uszkodzony płat."
	implements = list(
		TOOL_SCALPEL = 1.05,
		/obj/item/melee/transforming/energy/sword = 1.5,
		/obj/item/kitchen/knife = 2.25,
		/obj/item/shard = 2.85,
	)
	time = 4.2 SECONDS
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/organ1.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'
	target_type = /obj/item/organ/lungs
	failure_damage_percent = 0.1

/datum/surgery_operation/organ/repair/lobectomy/on_preop(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Zaczynasz nacinać płuca [FORMAT_ORGAN_OWNER(organ)]..."),
		span_notice("[surgeon] zaczyna nacinać [FORMAT_ORGAN_OWNER(organ)]."),
		span_notice("[surgeon] zaczyna nacinać [FORMAT_ORGAN_OWNER(organ)]."),
	)
	display_pain(organ.owner, "Czujesz kłujący ból w klatce piersiowej!")

/datum/surgery_operation/organ/repair/lobectomy/on_success(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		organ.owner,
		span_notice("Pomyślnie wycinasz najbardziej uszkodzony płat płuca [FORMAT_ORGAN_OWNER(organ)]."),
		span_notice("[surgeon] pomyślnie usuwa fragment płuc [FORMAT_ORGAN_OWNER(organ)]."),
		span_notice("[surgeon] pomyślnie usuwa fragment płuc [FORMAT_ORGAN_OWNER(organ)]."),
	)

/datum/surgery_operation/organ/repair/lobectomy/on_failure(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	organ.owner?.losebreath += 4
	display_results(
		surgeon,
		organ.owner,
		span_warning("Partaczysz i nie udaje ci się wyciąć uszkodzonego płata płuca [FORMAT_ORGAN_OWNER(organ)]!"),
		span_warning("[surgeon] partaczy!"),
		span_warning("[surgeon] partaczy!"),
	)
	display_pain(organ.owner, "Czujesz ostre dźgnięcie w klatce, brakuje ci tchu i boli przy każdym oddechu!")

/datum/surgery_operation/organ/repair/lobectomy/mechanic
	name = "konserwacja filtrów powietrza"
	rnd_name = "Diagnostyka filtrów powietrza (operacja płuc)"
	implements = list(
		TOOL_WRENCH = 1.05,
		TOOL_SCALPEL = 1.05,
		/obj/item/melee/transforming/energy/sword = 1.5,
		/obj/item/kitchen/knife = 2.25,
		/obj/item/shard = 2.85,
	)
	preop_sound = 'sound/items/ratchet.ogg'
	success_sound = 'sound/machines/doorclick.ogg'
	required_organ_flag = ORGAN_ROBOTIC
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE | OPERATION_NO_PATIENT_REQUIRED | OPERATION_MECHANIC

// --- Wątroba ---

/datum/surgery_operation/organ/repair/hepatectomy
	name = "wycięcie uszkodzonego fragmentu wątroby"
	rnd_name = "Hepatektomia (operacja wątroby)"
	desc = "Naprawia uszkodzoną wątrobę, wycinając najbardziej uszkodzony fragment."
	implements = list(
		TOOL_SCALPEL = 1.05,
		/obj/item/melee/transforming/energy/sword = 1.5,
		/obj/item/kitchen/knife = 2.25,
		/obj/item/shard = 2.85,
	)
	time = 5.2 SECONDS
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/organ1.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'
	target_type = /obj/item/organ/liver
	heal_to_percent = 0.1
	required_damage_percent = 0.5
	blocked_if_failing = TRUE
	repeatable = TRUE
	failure_damage_percent = 0.15

/datum/surgery_operation/organ/repair/hepatectomy/on_preop(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Zaczynasz wycinać uszkodzony fragment wątroby [FORMAT_ORGAN_OWNER(organ)]..."),
		span_notice("[surgeon] zaczyna nacinać [FORMAT_ORGAN_OWNER(organ)]."),
		span_notice("[surgeon] zaczyna nacinać [FORMAT_ORGAN_OWNER(organ)]."),
	)
	display_pain(organ.owner, "Brzuch pali cię straszliwym, kłującym bólem!")

/datum/surgery_operation/organ/repair/hepatectomy/on_success(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		organ.owner,
		span_notice("Pomyślnie usuwasz uszkodzony fragment wątroby [FORMAT_ORGAN_OWNER(organ)]."),
		span_notice("[surgeon] pomyślnie usuwa uszkodzony fragment wątroby [FORMAT_ORGAN_OWNER(organ)]."),
		span_notice("[surgeon] pomyślnie usuwa uszkodzony fragment wątroby [FORMAT_ORGAN_OWNER(organ)]."),
	)
	display_pain(organ.owner, "Ból trochę słabnie!")

/datum/surgery_operation/organ/repair/hepatectomy/on_failure(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		organ.owner,
		span_warning("Wycinasz nie ten fragment wątroby [FORMAT_ORGAN_OWNER(organ)]!"),
		span_warning("[surgeon] wycina nie ten fragment wątroby [FORMAT_ORGAN_OWNER(organ)]!"),
		span_warning("[surgeon] wycina nie ten fragment wątroby [FORMAT_ORGAN_OWNER(organ)]!"),
	)
	display_pain(organ.owner, "Ból brzucha się nasila!")

/datum/surgery_operation/organ/repair/hepatectomy/mechanic
	name = "konserwacja układu oczyszczania"
	rnd_name = "Diagnostyka układu oczyszczania (operacja wątroby)"
	implements = list(
		TOOL_WRENCH = 1.05,
		TOOL_SCALPEL = 1.05,
		/obj/item/melee/transforming/energy/sword = 1.5,
		/obj/item/kitchen/knife = 2.25,
		/obj/item/shard = 2.85,
	)
	preop_sound = 'sound/items/ratchet.ogg'
	success_sound = 'sound/machines/doorclick.ogg'
	required_organ_flag = ORGAN_ROBOTIC
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE | OPERATION_NO_PATIENT_REQUIRED | OPERATION_MECHANIC

// --- Serce ---

/datum/surgery_operation/organ/repair/coronary_bypass
	name = "wszczepienie bajpasu"
	rnd_name = "Pomostowanie aortalno-wieńcowe (operacja serca)"
	desc = "Wszczepia bajpas do uszkodzonego serca, przywracając przepływ krwi."
	implements = list(
		TOOL_HEMOSTAT = 1.05,
		TOOL_WIRECUTTER = 2.85,
		/obj/item/stack/package_wrap = 6.67,
		/obj/item/stack/cable_coil = 2,
	)
	time = 9 SECONDS
	preop_sound = 'sound/surgery/hemostat1.ogg'
	success_sound = 'sound/surgery/hemostat1.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'
	target_type = /obj/item/organ/heart

/datum/surgery_operation/organ/repair/coronary_bypass/on_preop(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Zaczynasz wszczepiać bajpas do serca [FORMAT_ORGAN_OWNER(organ)]..."),
		span_notice("[surgeon] zaczyna wszczepiać coś do serca [FORMAT_ORGAN_OWNER(organ)]!"),
		span_notice("[surgeon] zaczyna wszczepiać coś do serca [FORMAT_ORGAN_OWNER(organ)]!"),
	)
	display_pain(organ.owner, "Ból w klatce piersiowej jest nie do zniesienia!")

/datum/surgery_operation/organ/repair/coronary_bypass/on_success(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		organ.owner,
		span_notice("Pomyślnie wszczepiasz bajpas do serca [FORMAT_ORGAN_OWNER(organ)]."),
		span_notice("[surgeon] kończy wszczepiać coś do serca [FORMAT_ORGAN_OWNER(organ)]."),
		span_notice("[surgeon] kończy wszczepiać coś do serca [FORMAT_ORGAN_OWNER(organ)]."),
	)
	display_pain(organ.owner, "Klatka piersiowa pulsuje bólem, ale serce bije lepiej niż kiedykolwiek!")

/datum/surgery_operation/organ/repair/coronary_bypass/on_failure(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	// AQUILA - tg: adjustBleedStacks(30), u nas krwawienie Bee jak w starym kroku
	organ.owner?.add_bleeding(BLEED_CRITICAL)
	display_results(
		surgeon,
		organ.owner,
		span_warning("Partaczysz przy mocowaniu przeszczepu, a ten się odrywa, rozrywając część serca!"),
		span_warning("[surgeon] partaczy, przez co z klatki piersiowej [FORMAT_ORGAN_OWNER(organ)] obficie tryska krew!"),
		span_warning("[surgeon] partaczy, przez co z klatki piersiowej [FORMAT_ORGAN_OWNER(organ)] obficie tryska krew!"),
	)
	display_pain(organ.owner, "Klatka piersiowa płonie, odchodzisz od zmysłów!")

/datum/surgery_operation/organ/repair/coronary_bypass/mechanic
	name = "dostęp do wnętrza silnika"
	rnd_name = "Diagnostyka silnika (operacja serca)"
	implements = list(
		TOOL_CROWBAR = 1.05,
		TOOL_SCALPEL = 1.05,
		/obj/item/melee/transforming/energy/sword = 1.5,
		/obj/item/kitchen/knife = 2.25,
		/obj/item/shard = 2.85,
	)
	preop_sound = 'sound/items/ratchet.ogg'
	success_sound = 'sound/machines/doorclick.ogg'
	required_organ_flag = ORGAN_ROBOTIC
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE | OPERATION_NO_PATIENT_REQUIRED | OPERATION_MECHANIC

// --- Żołądek ---

/datum/surgery_operation/organ/repair/gastrectomy
	name = "wycięcie uszkodzonego fragmentu żołądka"
	rnd_name = "Gastrektomia (operacja żołądka)"
	desc = "Naprawia żołądek, wycinając uszkodzony fragment."
	implements = list(
		TOOL_SCALPEL = 1.05,
		/obj/item/melee/transforming/energy/sword = 1.5,
		/obj/item/kitchen/knife = 2.25,
		/obj/item/shard = 2.85,
		/obj/item = 4,
	)
	time = 5.2 SECONDS
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/organ1.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'
	target_type = /obj/item/organ/stomach
	heal_to_percent = 0.2
	required_damage_percent = 0.5
	blocked_if_failing = TRUE
	repeatable = TRUE
	failure_damage_percent = 0.15

/datum/surgery_operation/organ/repair/gastrectomy/get_any_tool()
	return "Dowolny ostry przedmiot"

/datum/surgery_operation/organ/repair/gastrectomy/tool_check(obj/item/tool)
	// ostrze albo pasujące narzędzie
	return (tool.sharpness == IS_SHARP || tool.sharpness == IS_SHARP_ACCURATE || (tool.tool_behaviour && implements[tool.tool_behaviour]))

/datum/surgery_operation/organ/repair/gastrectomy/on_preop(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Zaczynasz wycinać uszkodzony fragment żołądka [FORMAT_ORGAN_OWNER(organ)]..."),
		span_notice("[surgeon] zaczyna nacinać [FORMAT_ORGAN_OWNER(organ)]."),
		span_notice("[surgeon] zaczyna nacinać [FORMAT_ORGAN_OWNER(organ)]."),
	)
	display_pain(organ.owner, "Czujesz straszne dźgnięcie w brzuchu!")

/datum/surgery_operation/organ/repair/gastrectomy/on_success(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		organ.owner,
		span_notice("Pomyślnie usuwasz uszkodzony fragment żołądka [FORMAT_ORGAN_OWNER(organ)]."),
		span_notice("[surgeon] pomyślnie usuwa uszkodzony fragment żołądka [FORMAT_ORGAN_OWNER(organ)]."),
		span_notice("[surgeon] pomyślnie usuwa uszkodzony fragment żołądka [FORMAT_ORGAN_OWNER(organ)]."),
	)
	display_pain(organ.owner, "Ból brzucha trochę słabnie!")

/datum/surgery_operation/organ/repair/gastrectomy/on_failure(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		organ.owner,
		span_warning("Wycinasz nie ten fragment żołądka [FORMAT_ORGAN_OWNER(organ)]!"),
		span_warning("[surgeon] wycina nie ten fragment żołądka [FORMAT_ORGAN_OWNER(organ)]!"),
		span_warning("[surgeon] wycina nie ten fragment żołądka [FORMAT_ORGAN_OWNER(organ)]!"),
	)
	display_pain(organ.owner, "Ból brzucha się nasila!")

/datum/surgery_operation/organ/repair/gastrectomy/mechanic
	name = "konserwacja przetwornika składników"
	rnd_name = "Diagnostyka przetwornika składników (operacja żołądka)"
	implements = list(
		TOOL_WRENCH = 1.05,
		TOOL_SCALPEL = 1.05,
		/obj/item/melee/transforming/energy/sword = 1.5,
		/obj/item/kitchen/knife = 2.25,
		/obj/item/shard = 2.85,
		/obj/item = 4,
	)
	preop_sound = 'sound/items/ratchet.ogg'
	success_sound = 'sound/machines/doorclick.ogg'
	required_organ_flag = ORGAN_ROBOTIC
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE | OPERATION_NO_PATIENT_REQUIRED | OPERATION_MECHANIC

// --- Uszy ---

/datum/surgery_operation/organ/repair/ears
	name = "operacja uszu"
	rnd_name = "Otochirurgia (operacja uszu)"
	desc = "Naprawia uszkodzone uszy pacjenta, przywracając słuch."
	operation_flags = OPERATION_NOTABLE | OPERATION_NO_PATIENT_REQUIRED
	implements = list(
		TOOL_HEMOSTAT = 1.05,
		TOOL_SCREWDRIVER = 2.25,
		/obj/item/pen = 4,
	)
	target_type = /obj/item/organ/ears
	time = 6.4 SECONDS
	heal_to_percent = 0
	repeatable = TRUE
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/organ/repair/ears/all_blocked_strings()
	return ..() + list("kości (jeśli są) muszą być całe")

/datum/surgery_operation/organ/repair/ears/state_check(obj/item/organ/ears/organ)
	var/obj/item/bodypart/organ_limb = organ.get_bodypart_owner()
	if(LIMB_HAS_ANY_SURGERY_STATE(organ_limb, SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED) && LIMB_HAS_BONES(organ_limb))
		return FALSE
	return TRUE // zawsze dostępna, żeby dało się ją celowo spartaczyć

/datum/surgery_operation/organ/repair/ears/on_preop(obj/item/organ/ears/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Zaczynasz naprawiać uszy [FORMAT_ORGAN_OWNER(organ)]..."),
		span_notice("[surgeon] zaczyna naprawiać uszy [FORMAT_ORGAN_OWNER(organ)]."),
		span_notice("[surgeon] zaczyna operację uszu [FORMAT_ORGAN_OWNER(organ)]."),
	)
	display_pain(organ.owner, "Czujesz zawrotny ból głowy!")

/datum/surgery_operation/organ/repair/ears/on_success(obj/item/organ/ears/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	organ.setOrganDamage(0)
	organ.deaf = 20 // AQUILA - jak stara operacja: głuchota mija po ok. 30-40 s
	display_results(
		surgeon,
		organ.owner,
		span_notice("Udaje ci się naprawić uszy [FORMAT_ORGAN_OWNER(organ)]."),
		span_notice("[surgeon] naprawia uszy [FORMAT_ORGAN_OWNER(organ)]!"),
		span_notice("[surgeon] kończy operację uszu [FORMAT_ORGAN_OWNER(organ)]."),
	)
	display_pain(organ.owner, "Kręci ci się w głowie, ale chyba czujesz, że słuch wraca!")

/datum/surgery_operation/organ/repair/ears/on_failure(obj/item/organ/ears/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	stab_brain(organ, surgeon)

/// Porażka przy oczach albo uszach: dźgnięcie w mózg
/datum/surgery_operation/organ/repair/proc/stab_brain(obj/item/organ/organ, mob/living/surgeon)
	var/obj/item/organ/brain/brain = organ.owner?.getorganslot(ORGAN_SLOT_BRAIN)
	if(isnull(brain))
		display_results(
			surgeon,
			organ.owner,
			span_warning("Przypadkiem dźgasz [FORMAT_ORGAN_OWNER(organ)] prosto w mózg! A raczej dźgnąłbyś, gdyby był tam mózg."),
			span_warning("[surgeon] przypadkiem dźga [FORMAT_ORGAN_OWNER(organ)] prosto w mózg! A raczej dźgnąłby, gdyby był tam mózg."),
			span_warning("[surgeon] przypadkiem dźga [FORMAT_ORGAN_OWNER(organ)] prosto w mózg!"),
		)
		return

	display_results(
		surgeon,
		organ.owner,
		span_warning("Przypadkiem dźgasz [FORMAT_ORGAN_OWNER(organ)] prosto w mózg!"),
		span_warning("[surgeon] przypadkiem dźga [FORMAT_ORGAN_OWNER(organ)] prosto w mózg!"),
		span_warning("[surgeon] przypadkiem dźga [FORMAT_ORGAN_OWNER(organ)] prosto w mózg!"),
	)
	display_pain(organ.owner, "Czujesz przeszywający ból głowy, prosto w mózg!")
	brain.applyOrganDamage(70)

// --- Oczy ---

/datum/surgery_operation/organ/repair/eyes
	name = "operacja oczu"
	rnd_name = "Witrektomia (operacja oczu)"
	desc = "Naprawia uszkodzone oczy pacjenta, przywracając wzrok."
	operation_flags = OPERATION_NOTABLE | OPERATION_NO_PATIENT_REQUIRED
	implements = list(
		TOOL_HEMOSTAT = 1.05,
		TOOL_SCREWDRIVER = 2.25,
		/obj/item/pen = 4,
	)
	time = 6.4 SECONDS
	target_type = /obj/item/organ/eyes
	heal_to_percent = 0
	repeatable = TRUE
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/organ/repair/eyes/all_blocked_strings()
	return ..() + list("kości (jeśli są) muszą być całe")

/datum/surgery_operation/organ/repair/eyes/state_check(obj/item/organ/organ)
	var/obj/item/bodypart/organ_limb = organ.get_bodypart_owner()
	if(LIMB_HAS_ANY_SURGERY_STATE(organ_limb, SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED) && LIMB_HAS_BONES(organ_limb))
		return FALSE
	return TRUE // zawsze dostępna, żeby dało się ją celowo spartaczyć

/datum/surgery_operation/organ/repair/eyes/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "surgery_eyes")

/datum/surgery_operation/organ/repair/eyes/on_preop(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Zaczynasz naprawiać oczy [FORMAT_ORGAN_OWNER(organ)]..."),
		span_notice("[surgeon] zaczyna naprawiać oczy [FORMAT_ORGAN_OWNER(organ)]."),
		span_notice("[surgeon] zaczyna operację oczu [FORMAT_ORGAN_OWNER(organ)]."),
	)
	display_pain(organ.owner, "Czujesz kłujący ból w oczach!")

/datum/surgery_operation/organ/repair/eyes/on_success(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	organ.setOrganDamage(0)
	// AQUILA - jak stara operacja oczu: znika ślepota i krótkowzroczność od uszkodzeń, wzrok się rozmywa
	var/mob/living/carbon/patient = organ.owner
	if(patient)
		patient.cure_blind(list(EYE_DAMAGE))
		patient.set_blindness(0)
		patient.cure_nearsighted(list(EYE_DAMAGE))
		patient.blur_eyes(35)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Udaje ci się naprawić oczy [FORMAT_ORGAN_OWNER(organ)]."),
		span_notice("[surgeon] naprawia oczy [FORMAT_ORGAN_OWNER(organ)]!"),
		span_notice("[surgeon] kończy operację oczu [FORMAT_ORGAN_OWNER(organ)]."),
	)
	display_pain(organ.owner, "Obraz się rozmywa, ale chyba widzisz trochę lepiej!")

/datum/surgery_operation/organ/repair/eyes/on_failure(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	stab_brain(organ, surgeon)

// --- Mózg ---

/datum/surgery_operation/organ/repair/brain
	name = "operacja mózgu"
	rnd_name = "Neurochirurgia (operacja mózgu)"
	desc = "Naprawia uszkodzoną tkankę mózgu, przywracając sprawność umysłu."
	implements = list(
		TOOL_HEMOSTAT = 1.05,
		TOOL_SCREWDRIVER = 2.85,
		/obj/item/pen = 6.67,
	)
	time = 10 SECONDS
	preop_sound = 'sound/surgery/hemostat1.ogg'
	success_sound = 'sound/surgery/hemostat1.ogg'
	failure_sound = 'sound/surgery/organ2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE | OPERATION_NO_PATIENT_REQUIRED | OPERATION_LOOPING
	target_type = /obj/item/organ/brain
	// AQUILA - jak stara kalibracja mózgu: 60 punktów (30% z 200) na raz, porażka +60 i ciężka trauma
	heal_to_percent = 0.3
	failure_damage_percent = 0.3
	repeatable = TRUE
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/organ/repair/brain/state_check(obj/item/organ/brain/organ)
	return TRUE // zawsze dostępna, żeby dało się ją celowo spartaczyć

/datum/surgery_operation/organ/repair/brain/can_loop(mob/living/patient, obj/item/organ/brain/organ, mob/living/surgeon, tool, list/operation_args)
	return ..() && organ.damage > 0

/datum/surgery_operation/organ/repair/brain/on_preop(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		organ.owner,
		span_notice("Zaczynasz naprawiać mózg [FORMAT_ORGAN_OWNER(organ)]..."),
		span_notice("[surgeon] zaczyna naprawiać mózg [FORMAT_ORGAN_OWNER(organ)]."),
		span_notice("[surgeon] zaczyna operację mózgu [FORMAT_ORGAN_OWNER(organ)]."),
	)
	display_pain(organ.owner, "Głowa pęka ci z niewyobrażalnego bólu!")

/datum/surgery_operation/organ/repair/brain/on_success(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	// bez wywołania rodzica, mózg leczy się o stałą część
	organ.setOrganDamage(max(organ.damage - organ.maxHealth * heal_to_percent, 0))
	display_results(
		surgeon,
		organ.owner,
		span_notice("Udaje ci się naprawić mózg [FORMAT_ORGAN_OWNER(organ)]."),
		span_notice("[surgeon] naprawia mózg [FORMAT_ORGAN_OWNER(organ)]!"),
		span_notice("[surgeon] kończy operację mózgu [FORMAT_ORGAN_OWNER(organ)]."),
	)
	display_pain(organ.owner, "Ból głowy słabnie, myśli się trochę łatwiej!")
	if(organ.owner)
		organ.owner.mind?.remove_antag_datum(/datum/antagonist/brainwashed)
	else if(organ.brainmob)
		organ.brainmob.mind?.remove_antag_datum(/datum/antagonist/brainwashed)
	organ.cure_all_traumas(TRAUMA_RESILIENCE_SURGERY)
	if(organ.damage > organ.maxHealth * 0.1)
		to_chat(surgeon, span_notice("Mózg [FORMAT_ORGAN_OWNER(organ)] da się jeszcze podleczyć."))

/datum/surgery_operation/organ/repair/brain/on_failure(obj/item/organ/brain/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		organ.owner,
		span_warning("Partaczysz, powodując dodatkowe obrażenia!"),
		span_warning("[surgeon] partaczy, uszkadzając mózg!"),
		span_notice("[surgeon] kończy operację mózgu [FORMAT_ORGAN_OWNER(organ)]."),
	)
	display_pain(organ.owner, "Głowa pulsuje straszliwym bólem, myślenie boli!")
	organ.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)

/datum/surgery_operation/organ/repair/brain/mechanic
	name = "debugowanie sieci neuronowej"
	rnd_name = "Diagnostyka systemu (operacja mózgu)"
	implements = list(
		TOOL_MULTITOOL = 1.15,
		TOOL_HEMOSTAT = 1.05,
		TOOL_SCREWDRIVER = 2.85,
		/obj/item/pen = 6.67,
	)
	preop_sound = 'sound/items/ratchet.ogg'
	success_sound = 'sound/machines/doorclick.ogg'
	required_organ_flag = ORGAN_ROBOTIC
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE | OPERATION_NO_PATIENT_REQUIRED | OPERATION_LOOPING | OPERATION_MECHANIC
