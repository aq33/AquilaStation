// AQUILA - tg code/modules/surgery/operations/operation_healing.dm
// Opatrywanie ran (stara wersja: code/modules/surgery/healing.dm). Liczby jak u nas: 5 punktów plus 1/15, 1/10 albo 1/5
// brakującego zdrowia (tg: 0.07, 0.1, 0.2), u martwego pięć razy mniej, przez ubranie 55%. Mieszane: 3 + 1/15, 1/10,
// a eksperymentalne 1 + 1/2,5. Wersje zaawansowane odblokowują te same dyski i badania co stare (legacy_unlocked_by).
// Pominięte z tg: monitor funkcji życiowych i modsuit przy pokazywaniu liczb (zostaje analizator w ręce), nastrój TRAIT_MORBID.

/// Leczenie urazów
#define BRUTE_SURGERY (1<<0)
/// Leczenie oparzeń
#define BURN_SURGERY (1<<1)
/// Leczenie jednego i drugiego naraz
#define COMBO_SURGERY (1<<2)

/datum/surgery_operation/basic/tend_wounds
	name = "opatrzenie ran"
	rnd_name = "Opatrywanie ran"
	desc = "Opatruje powierzchowne urazy i oparzenia pacjenta."
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_SCREWDRIVER = 1.5,
		TOOL_WIRECUTTER = 1.67,
		/obj/item/pen = 1.8,
	)
	time = 2.5 SECONDS
	operation_flags = OPERATION_LOOPING | OPERATION_IGNORE_CLOTHES
	preop_sound = 'sound/surgery/scalpel1.ogg'
	success_sound = 'sound/surgery/retractor2.ogg'
	failure_sound = 'sound/surgery/organ1.ogg'
	required_bodytype = NONE
	any_surgery_states_required = ALL_SURGERY_SKIN_STATES
	replaced_by = /datum/surgery_operation/basic/tend_wounds/upgraded
	/// Opcje menu radialnego
	VAR_PRIVATE/list/cached_healing_options
	/// Co ta operacja leczy (BRUTE_SURGERY, BURN_SURGERY, COMBO_SURGERY)
	var/can_heal = BRUTE_SURGERY | BURN_SURGERY
	/// Stała ilość leczenia na krok
	var/healing_amount = 5
	/// Do tego część brakującego zdrowia
	var/healing_multiplier = 1 / 15

/datum/surgery_operation/basic/tend_wounds/all_required_strings()
	return ..() + list("pacjent musi mieć urazy albo oparzenia")

/datum/surgery_operation/basic/tend_wounds/state_check(mob/living/patient)
	return patient.getBruteLoss() > 0 || patient.getFireLoss() > 0

/datum/surgery_operation/basic/tend_wounds/get_default_radial_image()
	return get_item_radial_image(/obj/item/storage/firstaid/regular)

/datum/surgery_operation/basic/tend_wounds/get_radial_options(mob/living/patient, obj/item/tool, operating_zone)
	var/list/options = list()

	if(can_heal & COMBO_SURGERY)
		var/datum/radial_menu_choice/all_healing = LAZYACCESS(cached_healing_options, "[COMBO_SURGERY]")
		if(!all_healing)
			all_healing = new()
			all_healing.image = get_item_radial_image(/obj/item/storage/firstaid/advanced)
			all_healing.name = "opatrzenie urazów i oparzeń[rnd_suffix()]"
			all_healing.info = "Leczy powierzchowne siniaki, rozcięcia i oparzenia pacjenta."
			LAZYSET(cached_healing_options, "[COMBO_SURGERY]", all_healing)

		options[all_healing] = list(
			"[OPERATION_ACTION]" = "heal",
			"[OPERATION_BRUTE_HEAL]" = healing_amount,
			"[OPERATION_BURN_HEAL]" = healing_amount,
			"[OPERATION_BRUTE_MULTIPLIER]" = healing_multiplier,
			"[OPERATION_BURN_MULTIPLIER]" = healing_multiplier,
		)

	if((can_heal & BRUTE_SURGERY) && patient.getBruteLoss() > 0)
		var/datum/radial_menu_choice/brute_healing = LAZYACCESS(cached_healing_options, "[BRUTE_SURGERY]")
		if(!brute_healing)
			brute_healing = new()
			brute_healing.image = get_item_radial_image(/obj/item/storage/firstaid/brute)
			brute_healing.name = "opatrzenie urazów[rnd_suffix()]"
			brute_healing.info = "Leczy powierzchowne siniaki i rozcięcia pacjenta."
			LAZYSET(cached_healing_options, "[BRUTE_SURGERY]", brute_healing)

		options[brute_healing] = list(
			"[OPERATION_ACTION]" = "heal",
			"[OPERATION_BRUTE_HEAL]" = healing_amount,
			"[OPERATION_BRUTE_MULTIPLIER]" = healing_multiplier,
		)

	if((can_heal & BURN_SURGERY) && patient.getFireLoss() > 0)
		var/datum/radial_menu_choice/burn_healing = LAZYACCESS(cached_healing_options, "[BURN_SURGERY]")
		if(!burn_healing)
			burn_healing = new()
			burn_healing.image = get_item_radial_image(/obj/item/storage/firstaid/fire)
			burn_healing.name = "opatrzenie oparzeń[rnd_suffix()]"
			burn_healing.info = "Leczy powierzchowne oparzenia pacjenta."
			LAZYSET(cached_healing_options, "[BURN_SURGERY]", burn_healing)

		options[burn_healing] = list(
			"[OPERATION_ACTION]" = "heal",
			"[OPERATION_BURN_HEAL]" = healing_amount,
			"[OPERATION_BURN_MULTIPLIER]" = healing_multiplier,
		)

	return options

/// AQUILA - dopisek do nazwy w menu, żeby było widać poziom operacji
/datum/surgery_operation/basic/tend_wounds/proc/rnd_suffix()
	return ""

/datum/surgery_operation/basic/tend_wounds/can_loop(mob/living/patient, mob/living/operating_on, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	if(!.)
		return FALSE
	var/brute_heal = operation_args[OPERATION_BRUTE_HEAL] > 0
	var/burn_heal = operation_args[OPERATION_BURN_HEAL] > 0
	if(brute_heal && burn_heal)
		return patient.getBruteLoss() > 0 || patient.getFireLoss() > 0
	else if(brute_heal)
		return patient.getBruteLoss() > 0
	else if(burn_heal)
		return patient.getFireLoss() > 0
	return FALSE

/datum/surgery_operation/basic/tend_wounds/on_preop(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	var/woundtype
	var/brute_heal = operation_args[OPERATION_BRUTE_HEAL] > 0
	var/burn_heal = operation_args[OPERATION_BURN_HEAL] > 0
	if(brute_heal && burn_heal)
		woundtype = "rany"
	else if(brute_heal)
		woundtype = "urazy"
	else
		woundtype = "oparzenia"
	display_results(
		surgeon,
		patient,
		span_notice("Próbujesz opatrzyć część obrażeń [patient] ([woundtype])."),
		span_notice("[surgeon] próbuje opatrzyć część obrażeń [patient] ([woundtype])."),
		span_notice("[surgeon] próbuje opatrzyć część obrażeń [patient] ([woundtype])."),
	)
	display_pain(patient, "Rany ([woundtype]) pieką jak diabli!")

#define CONDITIONAL_DAMAGE_MESSAGE(brute, burn, combo_msg, brute_msg, burn_msg) "[(brute > 0 && burn > 0) ? combo_msg : (brute > 0 ? brute_msg : burn_msg)]"

/// Ile mniej więcej zostało do końca (teksty ze starej wersji)
/datum/surgery_operation/basic/tend_wounds/proc/get_progress(mob/living/surgeon, mob/living/patient, brute_healed, burn_healed)
	var/estimated_remaining_steps = 0
	if(brute_healed > 0)
		estimated_remaining_steps = max(0, (patient.getBruteLoss() / brute_healed))
	if(burn_healed > 0)
		estimated_remaining_steps = max(estimated_remaining_steps, (patient.getFireLoss() / burn_healed))

	var/progress_text = ""

	if(surgeon.is_holding_item_of_type(/obj/item/healthanalyzer))
		if(brute_healed > 0 && patient.getBruteLoss() > 0)
			progress_text += ". Pozostałe urazy: <font color='#ff3333'>[patient.getBruteLoss()]</font>"
		if(burn_healed > 0 && patient.getFireLoss() > 0)
			progress_text += ". Pozostałe oparzenia: <font color='#ff9933'>[patient.getFireLoss()]</font>"
		return progress_text

	switch(estimated_remaining_steps)
		if(-INFINITY to 1)
			return
		if(1 to 3)
			progress_text += ", kończąc ostatnie [CONDITIONAL_DAMAGE_MESSAGE(brute_healed, burn_healed, "ślady obrażeń", "zadrapania", "ślady przypaleń")]"
		if(3 to 6)
			progress_text += ", odliczając ostatnie [CONDITIONAL_DAMAGE_MESSAGE(brute_healed, burn_healed, "miejsca urazów", "siniaki", "pęcherze")] do opatrzenia"
		if(6 to 9)
			progress_text += ", dalej zmagając się z [CONDITIONAL_DAMAGE_MESSAGE(brute_healed, burn_healed, "rozległymi obrażeniami", "rozległymi rozerwaniami", "dokładnym przypieczeniem")]"
		if(9 to 12)
			progress_text += ", szykując się na długą operację"
		if(12 to 15)
			progress_text += ", choć pacjent wciąż bardziej przypomina [CONDITIONAL_DAMAGE_MESSAGE(brute_healed, burn_healed, "rozgniecioną papkę dla niemowląt", "mielone", "przypalony stek")] niż człowieka"
		if(15 to INFINITY)
			progress_text += ", choć masz wrażenie, że ledwo zaczynasz leczyć to [CONDITIONAL_DAMAGE_MESSAGE(brute_healed, burn_healed, "połamane", "zmasakrowane", "zwęglone")] ciało"

	return progress_text

#undef CONDITIONAL_DAMAGE_MESSAGE

/datum/surgery_operation/basic/tend_wounds/on_success(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	var/user_msg = "Udaje ci się opatrzyć część ran [patient]"
	var/target_msg = "[surgeon] opatruje część ran [patient]"

	var/brute_healed = operation_args[OPERATION_BRUTE_HEAL]
	var/burn_healed = operation_args[OPERATION_BURN_HEAL]

	var/dead_multiplier = patient.stat == DEAD ? 0.2 : 1.0
	var/accessibility_modifier = 1.0
	if(!get_location_accessible(patient, BODY_ZONE_CHEST))
		accessibility_modifier = 0.55
		user_msg += " najlepiej, jak potrafisz, gdy pacjent ma na sobie ubranie"
		target_msg += " najlepiej, jak potrafi, gdy pacjent ma na sobie ubranie"

	var/brute_multiplier = operation_args[OPERATION_BRUTE_MULTIPLIER] * dead_multiplier
	var/burn_multiplier = operation_args[OPERATION_BURN_MULTIPLIER] * dead_multiplier

	brute_healed += round(patient.getBruteLoss() * brute_multiplier, 0.1)
	burn_healed += round(patient.getFireLoss() * burn_multiplier, 0.1)
	brute_healed *= accessibility_modifier
	burn_healed *= accessibility_modifier

	patient.heal_bodypart_damage(brute_healed, burn_healed)

	user_msg += get_progress(surgeon, patient, brute_healed, burn_healed)

	display_results(
		surgeon,
		patient,
		span_notice("[user_msg]."),
		span_notice("[target_msg]."),
		span_notice("[target_msg]."),
	)

/datum/surgery_operation/basic/tend_wounds/on_failure(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_warning("Partaczysz!"),
		span_warning("[surgeon] partaczy!"),
		span_notice("[surgeon] opatruje część ran [patient]."),
		target_detailed = TRUE,
	)
	var/brute_dealt = operation_args[OPERATION_BRUTE_HEAL] * 0.8
	var/burn_dealt = operation_args[OPERATION_BURN_HEAL] * 0.8
	var/brute_multiplier = operation_args[OPERATION_BRUTE_MULTIPLIER] * 0.5
	var/burn_multiplier = operation_args[OPERATION_BURN_MULTIPLIER] * 0.5

	brute_dealt += round(patient.getBruteLoss() * brute_multiplier, 0.1)
	burn_dealt += round(patient.getFireLoss() * burn_multiplier, 0.1)

	patient.take_bodypart_damage(brute_dealt, burn_dealt)

/datum/surgery_operation/basic/tend_wounds/upgraded
	rnd_name = "Opatrywanie ran (zaawansowane)"
	operation_flags = OPERATION_LOOPING | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED
	replaced_by = /datum/surgery_operation/basic/tend_wounds/upgraded/master
	healing_multiplier = 0.1
	legacy_unlocked_by = list(/datum/surgery/healing/brute/upgraded, /datum/surgery/healing/burn/upgraded)

/datum/surgery_operation/basic/tend_wounds/upgraded/rnd_suffix()
	return " (zaaw.)"

/datum/surgery_operation/basic/tend_wounds/upgraded/master
	rnd_name = "Opatrywanie ran (eksperymentalne)"
	replaced_by = /datum/surgery_operation/basic/tend_wounds/combo/upgraded/master
	healing_multiplier = 0.2
	legacy_unlocked_by = list(/datum/surgery/healing/brute/upgraded/femto, /datum/surgery/healing/burn/upgraded/femto)

/datum/surgery_operation/basic/tend_wounds/upgraded/master/rnd_suffix()
	return " (eksp.)"

/datum/surgery_operation/basic/tend_wounds/combo
	rnd_name = "Opatrywanie ran mieszanych"
	operation_flags = OPERATION_LOOPING | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED
	replaced_by = /datum/surgery_operation/basic/tend_wounds/combo/upgraded
	can_heal = COMBO_SURGERY
	healing_amount = 3
	time = 1 SECONDS
	legacy_unlocked_by = list(/datum/surgery/healing/combo)

/datum/surgery_operation/basic/tend_wounds/combo/upgraded
	rnd_name = "Opatrywanie ran mieszanych (zaawansowane)"
	replaced_by = /datum/surgery_operation/basic/tend_wounds/combo/upgraded/master
	healing_multiplier = 0.1
	legacy_unlocked_by = list(/datum/surgery/healing/combo/upgraded)

/datum/surgery_operation/basic/tend_wounds/combo/upgraded/rnd_suffix()
	return " (zaaw.)"

/datum/surgery_operation/basic/tend_wounds/combo/upgraded/master
	rnd_name = "Opatrywanie ran mieszanych (eksperymentalne)"
	replaced_by = null
	healing_amount = 1
	healing_multiplier = 0.4
	legacy_unlocked_by = list(/datum/surgery/healing/combo/upgraded/femto)

/datum/surgery_operation/basic/tend_wounds/combo/upgraded/master/rnd_suffix()
	return " (eksp.)"

#undef BRUTE_SURGERY
#undef BURN_SURGERY
#undef COMBO_SURGERY
