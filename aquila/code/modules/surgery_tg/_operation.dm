// AQUILA - szkielet chirurgii z tgstation#93697 ("Spooky Scary Supreme Surgery"), tg code/modules/surgery/operations/_operation.dm.
// Zamiast /datum/surgery z listą kroków są pojedyncze operacje (/datum/surgery_operation). Kończyna pamięta stan
// we flagach surgery_state, a narzędzie w ręce pokazuje w menu radialnym operacje pasujące do narzędzia i do stanu.
// Przepisane na nasze API (attackby/do_after, check_zone, get_location_accessible, mobility_flags, nastroje Bee).
// Stary szkielet (/datum/surgery) działa obok, mostek jest w surgery_bridge.dm.

/**
 * Próbuje wykonać operację narzędziem
 *
 * * src - chirurg
 * * operating_on - to, na czym operujemy, zwykle mob (odcięta kończyna u nas nie ma jeszcze punktu wejścia)
 * * potential_tool - narzędzie (albo IMPLEMENT_HAND)
 * * intentionally_fail - TRUE wymusza porażkę (prawy klik)
 *
 * Zwraca flagę ITEM_INTERACT_*
 */
/mob/living/proc/perform_surgery(atom/movable/operating_on, potential_tool = IMPLEMENT_HAND, intentionally_fail = FALSE, operating_zone = zone_selected)
	if(operating_on in do_afters)
		operating_on.balloon_alert(src, "już operujesz!")
		return ITEM_INTERACT_BLOCKING

	// cyborgi operują "rękami" przez przytulacz
	if(istype(potential_tool, /obj/item/borg/cyborghug))
		potential_tool = IMPLEMENT_HAND

	var/list/operations = get_available_operations(operating_on, potential_tool, operating_zone)

	// nic się nie da zrobić?
	if(!length(operations))
		if(!isitem(potential_tool))
			return NONE
		var/obj/item/realtool = potential_tool
		// zamknięcie rany na sobie, jeśli się da
		if(src == operating_on)
			var/manual_cauterization = try_manual_cauterize(realtool)
			if(manual_cauterization & (ITEM_INTERACT_SUCCESS|ITEM_INTERACT_BLOCKING))
				return manual_cauterization
		// tylko narzędzia chirurgiczne blokują atak
		if(!realtool.is_surgical_tool())
			return NONE
		// kończyna nieprzygotowana do operacji, więc może to jednak atak
		var/obj/item/bodypart/operating = null
		if(isbodypart(operating_on))
			operating = operating_on
		else if(isliving(operating_on))
			var/mob/living/patient = operating_on
			operating = patient.get_bodypart(check_zone(operating_zone))
		if(operating && !HAS_TRAIT(operating, TRAIT_READY_TO_OPERATE))
			return NONE
		// tu już raczej pomyłka, więc podpowiedź...
		if(isliving(operating_on))
			var/mob/living/patient = operating_on
			if(!get_location_accessible(patient, operating_zone))
				patient.balloon_alert(src, "miejsce zasłonięte ubraniem!")
			else if(!IS_LYING_OR_CANNOT_LIE(patient))
				patient.balloon_alert(src, "pacjent nie leży!")
			else
				patient.balloon_alert(src, "nic do zrobienia: [realtool.name]!")
		else
			operating?.balloon_alert(src, "nic do zrobienia: [realtool.name]!")
		// ...i bez ataku, żeby chirurg nie dźgnął pacjenta przez pomyłkę
		return ITEM_INTERACT_BLOCKING

	// nazwa w menu -> wpis z listy operations
	var/list/radial_operations = list()
	var/list/entry_by_name = list()
	for(var/datum/radial_menu_choice/radial_slice as anything in operations)
		radial_operations[radial_slice.name] = radial_slice
		entry_by_name[radial_slice.name] = operations[radial_slice]
	radial_operations = sortList(radial_operations)

	var/picked
	if(length(radial_operations) == 1)
		picked = radial_operations[1] // tg: autopick_single_option
	else
		picked = show_radial_menu(
			user = src,
			anchor = operating_on,
			choices = radial_operations,
			radius = 56,
			custom_check = CALLBACK(src, PROC_REF(surgery_check), potential_tool, operating_on),
			require_near = TRUE,
			tooltips = TRUE,
		)
	if(isnull(picked) || isnull(entry_by_name[picked]))
		return ITEM_INTERACT_BLOCKING

	var/list/picked_entry = entry_by_name[picked]
	var/datum/surgery_operation/picked_op = picked_entry[1]
	var/atom/movable/operating = picked_entry[2]
	var/list/op_info = picked_entry[3]
	op_info = op_info.Copy()
	op_info[OPERATION_TARGET_ZONE] = operating_zone
	op_info[OPERATION_FORCE_FAIL] = intentionally_fail

	return picked_op.try_perform(operating, src, potential_tool, op_info)

/**
 * Wszystkie operacje, które chirurg może teraz zrobić tym narzędziem
 *
 * Zwraca listę: klucz to /datum/radial_menu_choice, wartość to list(operacja, cel operacji, op_info)
 */
/mob/living/proc/get_available_operations(atom/movable/operating_on, potential_tool = IMPLEMENT_HAND, operating_zone = zone_selected)
	// typy operacji, które w ogóle wchodzą w grę
	var/list/possible_operations = GLOB.operations.unlocked.Copy()
	// sygnały mogą dopisać zablokowane operacje
	SEND_SIGNAL(src, COMSIG_LIVING_OPERATING_ON, operating_on, possible_operations)
	SEND_SIGNAL(operating_on, COMSIG_ATOM_BEING_OPERATED_ON, src, possible_operations)

	var/list/operations = list()
	for(var/datum/surgery_operation/operation as anything in GLOB.operations.get_instances_from(possible_operations))
		var/atom/movable/operate_on = operation.get_operation_target(operating_on, operating_zone)
		if(!operation.check_availability(isliving(operating_on) ? operating_on : null, operate_on, src, potential_tool, operating_zone))
			continue
		var/potential_options = operation.get_radial_options(operate_on, potential_tool, operating_zone)
		if(!islist(potential_options))
			potential_options = list(potential_options)
		for(var/datum/radial_menu_choice/radial_slice as anything in potential_options)
			if(operations[radial_slice])
				stack_trace("Duplicate radial surgery option '[radial_slice.name]' detected for operation '[operation.type]'.")
				continue
			var/option_specific_info = potential_options[radial_slice] || list("[OPERATION_ACTION]" = "default")
			operations[radial_slice] = list(operation, operate_on, option_specific_info)

	return operations

/// Czy menu radialne może zostać otwarte (chirurg trzyma to samo narzędzie)
/mob/living/proc/surgery_check(obj/item/tool, atom/movable/operating_on)
	var/obj/item/holding = get_active_held_item()

	if(tool == IMPLEMENT_HAND)
		return isnull(holding) || istype(holding, /obj/item/borg/cyborghug)

	if(QDELETED(holding))
		return FALSE

	return tool == holding

/// Zamknięcie rany na sobie: ręczna wersja "zamknięcia nacięcia", czyści stan chirurgiczny kończyny
/mob/living/proc/try_manual_cauterize(obj/item/tool)
	var/cauterize_zone = check_zone(zone_selected)
	var/obj/item/bodypart/limb = get_bodypart(cauterize_zone)
	if(!manual_cauterize_check(tool, limb))
		return NONE
	if(src in do_afters)
		return ITEM_INTERACT_BLOCKING

	var/is_suture = istype(tool, /obj/item/stack/medical/suture)
	visible_message(
		span_notice("[src] próbuje zamknąć sobie [strefa_pl(limb.body_zone, TRUE)] za pomocą [tool]..."),
		span_notice("Próbujesz zamknąć sobie [strefa_pl(limb.body_zone, TRUE)] za pomocą [tool]..."),
		vision_distance = 5,
	)
	playsound(src, is_suture ? 'sound/surgery/hemostat1.ogg' : 'sound/surgery/cautery1.ogg', 50, TRUE)
	if(!do_after(src, /datum/surgery_operation/limb/close_skin::time * 2 * tool.toolspeed, target = src, extra_checks = CALLBACK(src, PROC_REF(manual_cauterize_check), tool, limb)))
		return ITEM_INTERACT_BLOCKING

	visible_message(
		span_notice("[src] zamyka sobie [strefa_pl(limb.body_zone, TRUE)] za pomocą [tool]."),
		span_notice("Zamykasz sobie [strefa_pl(limb.body_zone, TRUE)] za pomocą [tool]."),
		vision_distance = 5,
	)
	playsound(src, is_suture ? 'sound/surgery/hemostat1.ogg' : 'sound/surgery/cautery2.ogg', 50, TRUE)
	limb.remove_surgical_state(ALL_SURGERY_STATES_UNSET_ON_CLOSE)
	if(iscarbon(src))
		var/mob/living/carbon/carbon_self = src
		carbon_self.cauterise_wounds()
	if(is_suture)
		var/obj/item/stack/medical/suture/suture_tool = tool
		suture_tool.use(1)
	else
		limb.receive_damage(burn = 5)
	return ITEM_INTERACT_SUCCESS

/// Czy ręczne zamykanie rany może trwać dalej
/mob/living/proc/manual_cauterize_check(obj/item/tool, obj/item/bodypart/limb)
	PRIVATE_PROC(TRUE)

	if(QDELETED(limb) || limb.owner != src)
		return FALSE

	if(QDELETED(tool))
		return FALSE
	else if(istype(tool, /obj/item/stack/medical/suture))
		var/obj/item/stack/medical/suture/suture_tool = tool
		if(suture_tool.amount <= 0)
			return FALSE
	else if(tool.tool_behaviour != TOOL_CAUTERY)
		if(tool.is_hot() <= FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
			return FALSE

	// musi być co zamykać
	var/states_to_check = ALL_SURGERY_STATES_UNSET_ON_CLOSE
	if(!LIMB_HAS_BONES(limb))
		states_to_check &= ~BONELESS_SURGERY_STATES
	if(!LIMB_HAS_VESSELS(limb))
		states_to_check &= ~VESSELLESS_SURGERY_STATES
	if(!LIMB_HAS_SKIN(limb))
		states_to_check &= ~SKINLESS_SURGERY_STATES
	if(!states_to_check || !LIMB_HAS_ANY_SURGERY_STATE(limb, states_to_check))
		return FALSE

	// skóra musi być nacięta albo otwarta
	if(!LIMB_HAS_ANY_SURGERY_STATE(limb, ALL_SURGERY_SKIN_STATES))
		return FALSE

	return TRUE

/// Stan chirurgiczny strefy po ludzku, np. list("Skóra nacięta", "Kość przepiłowana")
/mob/living/proc/get_surgery_state_as_list(target_zone)
	var/list/state = list()
	if(has_limbs)
		var/obj/item/bodypart/part = get_bodypart(check_zone(target_zone))
		if(isnull(part))
			return list("Brak kończyny")

		if(HAS_TRAIT(part, TRAIT_READY_TO_OPERATE))
			state += "Przygotowane do operacji"
		if(!get_location_accessible(src, target_zone))
			state += "Zasłonięte ubraniem"

		var/part_state = part.surgery_state
		if(!LIMB_HAS_BONES(part))
			part_state &= ~BONELESS_SURGERY_STATES
		if(!LIMB_HAS_VESSELS(part))
			part_state &= ~VESSELLESS_SURGERY_STATES
		if(!LIMB_HAS_SKIN(part))
			part_state &= ~SKINLESS_SURGERY_STATES

		state += bitfield_to_list(part_state, SURGERY_STATE_READABLE)

	else
		if(HAS_TRAIT(src, TRAIT_READY_TO_OPERATE))
			state += "Przygotowane do operacji"

		var/datum/status_effect/basic_surgery_state/state_holder = has_status_effect(/datum/status_effect/basic_surgery_state) || null // u nas FALSE, gdy brak statusu
		state += bitfield_to_list(state_holder?.surgery_state, SURGERY_STATE_READABLE)

	return state

/mob/living
	/// Modyfikatory szybkości operacji na tym mobie jako pacjencie, id -> mnożnik (lazy)
	var/list/mob_surgery_speed_mods

/**
 * Dodaje modyfikator szybkości operacji na tym mobie
 *
 * * id - tekstowe id
 * * amount - mnożnik czasu (mnoży się z innymi)
 * * duration - czas trwania w decysekundach, null = na stałe
 */
/mob/living/proc/add_surgery_speed_mod(id, amount, duration)
	if(!(!isnull(id)))
		CRASH("Surgery speed mod ID cannot be null")
	if(!(isnum(amount)))
		CRASH("Surgery speed mod amount must be a number")
	if(!(isnum(duration) || isnull(duration)))
		CRASH("Surgery speed mod duration must be a number or null")

	var/existing = LAZYACCESS(mob_surgery_speed_mods, id)
	if(existing == amount)
		return

	if(isnum(existing))
		if(amount > 1 && existing > 1)
			LAZYSET(mob_surgery_speed_mods, id, max(amount, existing))
		else if(amount < 1 && existing < 1)
			LAZYSET(mob_surgery_speed_mods, id, min(amount, existing))
		else
			LAZYSET(mob_surgery_speed_mods, id, amount * existing)
	else
		LAZYSET(mob_surgery_speed_mods, id, amount)

	if(isnum(duration))
		addtimer(CALLBACK(src, PROC_REF(remove_surgery_speed_mod), id), duration, TIMER_UNIQUE|TIMER_OVERRIDE)

/// Usuwa modyfikator szybkości operacji
/mob/living/proc/remove_surgery_speed_mod(id)
	LAZYREMOVE(mob_surgery_speed_mods, id)

/// Pijaństwo chirurga i pacjenta (u nas tylko węglowe moby mają drunkenness)
/mob/living/proc/get_drunk_amount()
	return 0

/mob/living/carbon/get_drunk_amount()
	return drunkenness

/// Narzędzie chirurgiczne (tg: item_flags & SURGICAL_TOOL). Takie narzędzie na przygotowanym pacjencie nie atakuje, nawet gdy nie ma operacji.
/obj/item/proc/is_surgical_tool()
	var/static/list/surgical_behaviours = list(TOOL_SCALPEL, TOOL_HEMOSTAT, TOOL_RETRACTOR, TOOL_CAUTERY, TOOL_SAW, TOOL_DRILL, TOOL_BONESET, TOOL_BLOODFILTER)
	return (tool_behaviour in surgical_behaviours)

/// tg: nazwa opcji w menu radialnym (u nas datum miał tylko obrazek i opis)
/datum/radial_menu_choice
	var/name

/// tg: zamienia pole bitowe na listę nazw z listy nazwa = flaga
/proc/bitfield_to_list(bitfield = 0, list/wordlist)
	var/list/return_list = list()
	if(!bitfield || !length(wordlist))
		return return_list
	for(var/word in wordlist)
		if(bitfield & wordlist[word])
			return_list += word
	return return_list

GLOBAL_DATUM_INIT(operations, /datum/operation_holder, new)

/// Singleton ze wszystkimi operacjami
/datum/operation_holder
	/// Wszystkie operacje, typ -> singleton. Lepiej używać get_instances_from().
	var/list/operations_by_typepath
	/// Typy operacji dostępnych od ręki
	var/list/unlocked
	/// Typy operacji, które trzeba odblokować
	var/list/locked

/datum/operation_holder/New()
	. = ..()
	operations_by_typepath = list()
	unlocked = list()
	locked = list()

	for(var/datum/surgery_operation/operation_type as anything in subtypesof(/datum/surgery_operation))
		if(initial(operation_type.abstract_type) == operation_type)
			continue
		var/datum/surgery_operation/operation = new operation_type()
		if(isnull(operation.name))
			stack_trace("Surgery operation '[operation_type]' is missing a name!")

		operations_by_typepath[operation_type] = operation
		if(operation.operation_flags & OPERATION_LOCKED)
			locked += operation_type
		else
			unlocked += operation_type

/// Singletony dla listy typów. Domyślnie pomija operacje zastąpione przez inne z tej samej listy.
/datum/operation_holder/proc/get_instances_from(list/typepaths, filter_replaced = TRUE)
	var/list/result = list()
	for(var/datum/surgery_operation/operation_type as anything in typepaths)
		var/datum/surgery_operation/operation = operations_by_typepath[operation_type]
		if(isnull(operation))
			continue
		if(filter_replaced && is_replaced(operation, typepaths))
			continue
		result += operation
	return result

/// Czy operację zastępuje inna z puli
/datum/operation_holder/proc/is_replaced(datum/surgery_operation/operation, list/operation_pool)
	if(isnull(operation.replaced_by) || !length(operation_pool))
		return FALSE
	if(operation.replaced_by == operation.type)
		return FALSE
	if(operation.replaced_by in operation_pool)
		return TRUE
	var/datum/surgery_operation/next_highest_operation = operations_by_typepath[operation.replaced_by]
	if(isnull(next_highest_operation))
		return FALSE
	return is_replaced(next_highest_operation, operation_pool)

/**
 * ## Operacja chirurgiczna
 *
 * Singleton: jedna operacja, którą można zrobić na mobie (przejście między stanami albo coś większego).
 *
 * Minimum: [name], [desc], [implements] i [on_success()].
 * Warto też: [operation_flags], [all_surgery_states_required], [any_surgery_states_blocked], [state_check()], [get_default_radial_image()].
 *
 * Najlepiej dziedziczyć z [/datum/surgery_operation/limb] albo [/datum/surgery_operation/organ].
 * [/datum/surgery_operation/basic] działa też na mobach bez kończyn.
 */
/datum/surgery_operation
	/// Typ abstrakcyjny, nie tworzy singletonu
	var/abstract_type = /datum/surgery_operation
	/// Wymagane - nazwa w menu, krótko i jak czynność: "nacięcie skóry". Z małej litery.
	var/name
	/// Wymagane - opis, krótko: "Nacina skórę pacjenta."
	var/desc

	/// Opcjonalnie - nazwa w konsoli R&D i na komputerze operacyjnym
	var/rnd_name
	/// Opcjonalnie - opis w konsoli R&D i na komputerze operacyjnym
	var/rnd_desc

	/**
	 * Narzędzia: typ przedmiotu, TOOL_X albo IMPLEMENT_HAND -> mnożnik czasu.
	 * list(TOOL_SCALPEL = 2, TOOL_SAW = 0.5): skalpel dwa razy wolniej, piła dwa razy szybciej. Brak na liście = nie da się.
	 * Kolejność ma znaczenie: pierwszy pasujący wpis wygrywa.
	 */
	var/list/implements
	/// Czas bazowy
	var/time = 1 SECONDS

	/// Flagi OPERATION_*
	var/operation_flags = NONE

	/// Cel musi mieć WSZYSTKIE te stany
	var/all_surgery_states_required = NONE
	/// Cel musi mieć KTÓRYKOLWIEK z tych stanów
	var/any_surgery_states_required = NONE
	/// Cel nie może mieć ŻADNEGO z tych stanów
	var/any_surgery_states_blocked = NONE

	/// Typ operacji, która zastępuje tę, gdy obie są dostępne
	var/datum/surgery_operation/replaced_by

	/// Dźwięk przed do_after. Ścieżka albo lista typ przedmiotu/TOOL_X -> ścieżka.
	var/preop_sound
	/// Dźwięk po sukcesie
	var/success_sound
	/// Dźwięk po porażce
	var/failure_sound

	/// Domyślna opcja w menu radialnym, tworzona przy pierwszym użyciu
	VAR_PRIVATE/datum/radial_menu_choice/main_option

	/// Nastrój przytomnego pacjenta na początku operacji
	var/datum/mood_event/surgery/surgery_started_mood_event = /datum/mood_event/surgery
	/// Nastrój po sukcesie
	var/datum/mood_event/surgery/surgery_success_mood_event = /datum/mood_event/surgery/success
	/// Nastrój po porażce
	var/datum/mood_event/surgery/surgery_failure_mood_event = /datum/mood_event/surgery/failure

/**
 * Czy operację da się teraz zrobić. Główne wejście sprawdzania dostępności.
 */
/datum/surgery_operation/proc/check_availability(mob/living/patient, atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	SHOULD_NOT_OVERRIDE(TRUE)
	SHOULD_NOT_SLEEP(TRUE)

	if(isnull(operating_on))
		return FALSE

	if(get_tool_quality(tool) <= 0)
		return FALSE

	if(!is_available(operating_on, operated_zone))
		return FALSE

	if(isnull(patient))
		if(operation_flags & OPERATION_NO_PATIENT_REQUIRED)
			return snowflake_check_availability(operating_on, surgeon, tool, operated_zone)
		return FALSE

	if(!(operation_flags & OPERATION_STANDING_ALLOWED) && !IS_LYING_OR_CANNOT_LIE(patient))
		return FALSE

	if(!(operation_flags & OPERATION_SELF_OPERABLE) && patient == surgeon && !HAS_TRAIT(surgeon, TRAIT_SELF_SURGERY))
		return FALSE

	return snowflake_check_availability(operating_on, surgeon, tool, operated_zone)

/// Dodatkowe warunki operacji, które zależą od kilku rzeczy naraz
/datum/surgery_operation/proc/snowflake_check_availability(atom/movable/operating_on, mob/living/surgeon, tool, operated_zone)
	PROTECTED_PROC(TRUE)
	return TRUE

/**
 * Jakość narzędzia dla tej operacji (mnożnik czasu). 0 = nie da się.
 */
/datum/surgery_operation/proc/get_tool_quality(tool = IMPLEMENT_HAND)
	PROTECTED_PROC(TRUE)
	if(!length(implements))
		return 1
	if(!isitem(tool))
		return implements[tool]
	if(!tool_check(tool))
		return 0

	var/obj/item/realtool = tool
	if(realtool.tool_behaviour && implements[realtool.tool_behaviour])
		return realtool.toolspeed * implements[realtool.tool_behaviour]
	for(var/implement in implements)
		if(ispath(implement) && istype(realtool, implement))
			return realtool.toolspeed * implements[implement]
	return 0

/**
 * Opcja w menu radialnym, lista opcji albo lista opcja -> op_info.
 * Nadpisz, żeby dać kilka opcji (np. wybór organu).
 */
/datum/surgery_operation/proc/get_radial_options(atom/movable/operating_on, obj/item/tool, operating_zone)
	if(!main_option)
		main_option = new()
		main_option.image = get_default_radial_image()
		main_option.name = name
		main_option.info = desc

	return main_option

/**
 * Czy operacja pasuje do celu (stany, ubranie, state_check)
 */
/datum/surgery_operation/proc/is_available(atom/movable/operating_on, operated_zone)
	PROTECTED_PROC(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	if(all_surgery_states_required && !has_surgery_state(operating_on, all_surgery_states_required))
		return FALSE

	if(any_surgery_states_required && !has_any_surgery_state(operating_on, any_surgery_states_required))
		return FALSE

	if(any_surgery_states_blocked && has_any_surgery_state(operating_on, any_surgery_states_blocked))
		return FALSE

	var/mob/living/patient = get_patient(operating_on)
	if(isnull(patient))
		if(!(operation_flags & OPERATION_NO_PATIENT_REQUIRED))
			return FALSE
		return state_check(operating_on)

	if(!state_check(operating_on))
		return FALSE

	if(!(operation_flags & OPERATION_IGNORE_CLOTHES) && !get_location_accessible(patient, operated_zone))
		return FALSE

	return TRUE

/// Cel ma wszystkie podane stany
/datum/surgery_operation/proc/has_surgery_state(atom/movable/operating_on, state)
	PROTECTED_PROC(TRUE)
	return FALSE

/// Cel ma którykolwiek z podanych stanów
/datum/surgery_operation/proc/has_any_surgery_state(atom/movable/operating_on, state)
	PROTECTED_PROC(TRUE)
	return FALSE

/**
 * Dodatkowe warunki celu (cechy, rodzaj kończyny...)
 */
/datum/surgery_operation/proc/state_check(atom/movable/operating_on)
	PROTECTED_PROC(TRUE)
	return TRUE

/**
 * Dodatkowe warunki narzędzia (ostrość, temperatura...)
 */
/datum/surgery_operation/proc/tool_check(obj/item/tool)
	PROTECTED_PROC(TRUE)
	return TRUE

/**
 * Nazwa zalecanego narzędzia, np. "hemostat"
 */
/datum/surgery_operation/proc/get_recommended_tool()
	if(!length(implements))
		return null
	var/recommendation = implements[1]
	if(istext(recommendation))
		return recommendation
	if(recommendation == /obj/item)
		return get_any_tool()
	if(ispath(recommendation, /obj/item))
		var/obj/item/tool = recommendation
		return initial(tool.name)
	return null

/**
 * Dla operacji, które przyjmują dowolny przedmiot: jaki przedmiot się nada
 */
/datum/surgery_operation/proc/get_any_tool()
	return "Dowolny przedmiot"

/**
 * Wymagania operacji jako lista list tekstów
 */
/datum/surgery_operation/proc/get_requirements()
	SHOULD_NOT_OVERRIDE(TRUE)
	return list(
		all_required_strings(),
		any_required_strings(),
		any_optional_strings(),
		all_blocked_strings(),
	)

/// "Wszystkie poniższe muszą być spełnione:"
/datum/surgery_operation/proc/all_required_strings()
	SHOULD_CALL_PARENT(TRUE)
	. = bitfield_to_list(all_surgery_states_required, SURGERY_STATE_GUIDES("must"))
	if(!(operation_flags & OPERATION_STANDING_ALLOWED))
		. += "pacjent musi leżeć"

/// "Przynajmniej jedno z poniższych:"
/datum/surgery_operation/proc/any_required_strings()
	SHOULD_CALL_PARENT(TRUE)
	. = list()
	var/parsed_any_flags = any_surgery_states_required
	if((parsed_any_flags & ALL_SURGERY_BONE_STATES) == ALL_SURGERY_BONE_STATES)
		parsed_any_flags &= ~ALL_SURGERY_BONE_STATES
		. += "kość musi być przepiłowana albo nawiercona"
	if((parsed_any_flags & ALL_SURGERY_SKIN_STATES) == ALL_SURGERY_SKIN_STATES)
		parsed_any_flags &= ~ALL_SURGERY_SKIN_STATES
		. += "skóra musi być nacięta albo odciągnięta"
	if((parsed_any_flags & ALL_SURGERY_VESSEL_STATES) == ALL_SURGERY_VESSEL_STATES)
		parsed_any_flags &= ~ALL_SURGERY_VESSEL_STATES
		. += "naczynia muszą być odsłonięte"

	. += bitfield_to_list(parsed_any_flags, SURGERY_STATE_GUIDES("must"))

/// "Dodatkowo może być:"
/datum/surgery_operation/proc/any_optional_strings()
	SHOULD_CALL_PARENT(TRUE)
	. = list()
	if(operation_flags & OPERATION_SELF_OPERABLE)
		. += "chirurg może to zrobić na sobie"

/// "Żadne z poniższych:"
/datum/surgery_operation/proc/all_blocked_strings()
	SHOULD_CALL_PARENT(TRUE)
	. = list()
	var/parsed_blocked_flags = any_surgery_states_blocked
	if((parsed_blocked_flags & ALL_SURGERY_BONE_STATES) == ALL_SURGERY_BONE_STATES)
		parsed_blocked_flags &= ~ALL_SURGERY_BONE_STATES
		. += "kość musi być cała"
	if((parsed_blocked_flags & ALL_SURGERY_SKIN_STATES) == ALL_SURGERY_SKIN_STATES)
		parsed_blocked_flags &= ~ALL_SURGERY_SKIN_STATES
		. += "skóra musi być cała"
	if((parsed_blocked_flags & ALL_SURGERY_VESSEL_STATES) == ALL_SURGERY_VESSEL_STATES)
		parsed_blocked_flags &= ~ALL_SURGERY_VESSEL_STATES
		. += "naczynia muszą być nienaruszone"

	. += bitfield_to_list(parsed_blocked_flags, SURGERY_STATE_GUIDES("must not"))
	if(!(operation_flags & OPERATION_IGNORE_CLOTHES))
		. += "miejsce operacji nie może być zasłonięte ubraniem"

/**
 * Obrazek operacji w menu radialnym, gdy nie daje własnych opcji
 */
/datum/surgery_operation/proc/get_default_radial_image()
	return image(icon = 'icons/obj/surgery.dmi', icon_state = "surgery_any")

/// Obrazek strefy ciała (surgery_head, surgery_arms...)
/datum/surgery_operation/proc/get_generic_limb_radial_image(body_zone)
	SHOULD_NOT_OVERRIDE(TRUE)
	PROTECTED_PROC(TRUE)

	if(body_zone == BODY_ZONE_HEAD || body_zone == BODY_ZONE_CHEST || body_zone == BODY_ZONE_PRECISE_EYES || body_zone == BODY_ZONE_PRECISE_MOUTH)
		return image(icon = 'icons/obj/surgery.dmi', icon_state = "surgery_[body_zone]")
	if(body_zone == BODY_ZONE_L_ARM || body_zone == BODY_ZONE_R_ARM)
		return image(icon = 'icons/obj/surgery.dmi', icon_state = "surgery_arms")
	if(body_zone == BODY_ZONE_L_LEG || body_zone == BODY_ZONE_R_LEG)
		return image(icon = 'icons/obj/surgery.dmi', icon_state = "surgery_legs")
	return get_default_radial_image()

/// AQUILA - obrazek przedmiotu z typu (zamiast ikon z tg icons/hud/surgery_radial.dmi, których nie mamy)
/datum/surgery_operation/proc/get_item_radial_image(obj/item/item_type)
	SHOULD_NOT_OVERRIDE(TRUE)
	PROTECTED_PROC(TRUE)
	return image(icon = initial(item_type.icon), icon_state = initial(item_type.icon_state))

/**
 * Nakładki na obrazek w menu radialnym. Wejście: typ atomu, atom albo obrazek. Zwraca listę obrazków.
 */
/datum/surgery_operation/proc/add_radial_overlays(list/overlay_icons)
	SHOULD_NOT_OVERRIDE(TRUE)
	PROTECTED_PROC(TRUE)

	if(!islist(overlay_icons))
		overlay_icons = list(overlay_icons)

	var/list/created_list = list()
	for(var/input in overlay_icons)
		var/image/created = isimage(input) ? input : image(input)
		created.layer = FLOAT_LAYER
		created.plane = FLOAT_PLANE
		created.pixel_x = 0
		created.pixel_y = 0
		created_list += created

	return created_list

/**
 * Łączny modyfikator czasu operacji
 */
/datum/surgery_operation/proc/get_time_modifiers(atom/movable/operating_on, mob/living/surgeon, tool)
	PROTECTED_PROC(TRUE)
	var/total_mod = 1.0
	total_mod *= get_tool_quality(tool) || 1.0
	// bez kar, ale i bez premii
	if(!HAS_TRAIT(surgeon, TRAIT_IGNORE_SURGERY_MODIFIERS))
		var/mob/living/patient = get_patient(operating_on)
		total_mod *= get_surgeon_surgery_speed_mod(patient, surgeon, tool)
		if(!isnull(patient))
			total_mod *= get_location_modifier(get_turf(patient), patient, surgeon, tool)
			total_mod *= get_mob_surgery_speed_mod(patient, surgeon, tool)
		// TRAIT_SELF_SURGERY przy operacji, której normalnie nie da się zrobić na sobie, spowalnia
		if(patient == surgeon && HAS_TRAIT(surgeon, TRAIT_SELF_SURGERY) && !(operation_flags & OPERATION_SELF_OPERABLE))
			total_mod *= 1.5
	return round(total_mod, 0.01)

/// Modyfikator od stanu pacjenta
/datum/surgery_operation/proc/get_mob_surgery_speed_mod(mob/living/patient, mob/living/surgeon, tool)
	PROTECTED_PROC(TRUE)
	var/basemod = 1.0
	for(var/mod_id in patient.mob_surgery_speed_mods)
		basemod *= patient.mob_surgery_speed_mods[mod_id]
	if(HAS_TRAIT(patient, TRAIT_ANALGESIA))
		basemod *= 0.8
	return basemod

/// Modyfikator od stanu chirurga
/datum/surgery_operation/proc/get_surgeon_surgery_speed_mod(mob/living/patient, mob/living/surgeon, tool)
	PROTECTED_PROC(TRUE)
	var/basemod = 1.0
	var/drunkness = surgeon.get_drunk_amount()
	// pijany chirurg jest wolniejszy, chyba że trafi w ballmer peak
	if(drunkness >= BALLMER_PEAK_LOW_END && drunkness <= BALLMER_PEAK_HIGH_END)
		basemod *= 0.8
	else
		basemod *= 1 + round((drunkness ** 1.5) / 90, 0.1)

	return basemod

/// Modyfikator od tego, na czym leży pacjent (stół operacyjny, łóżko stazy, zwykły stół, łóżko...)
/datum/surgery_operation/proc/get_location_modifier(turf/operation_turf, mob/living/patient, mob/living/surgeon, tool)
	PROTECTED_PROC(TRUE)
	// kolejność ma znaczenie: pierwszy pasujący typ (od najbardziej szczegółowego)
	var/static/list/modifiers = list(
		/obj/structure/table/optable/abductor = 0.85,
		/obj/structure/table/optable = 1.0,
		/obj/machinery/stasis = 1.15,
		/obj/structure/table = 1.25,
		/obj/structure/bed = 1.5,
		/obj/structure/kitchenspike = 1.5,
	)
	var/mod = 2.0
	for(var/obj/thingy in operation_turf)
		for(var/modifier_type in modifiers)
			if(istype(thingy, modifier_type))
				mod = min(mod, modifiers[modifier_type])
				break
	return mod

/**
 * Co dokładnie jest celem operacji (to trafia do try_perform()). null = nie da się.
 *
 * * operating_on - mob albo odcięta kończyna
 * * body_zone - wybrana strefa ciała
 */
/datum/surgery_operation/proc/get_operation_target(atom/movable/operating_on, body_zone)
	return operating_on

/**
 * Dla komputera operacyjnego: czy to może być następny krok
 */
/datum/surgery_operation/proc/show_as_next_step(atom/movable/potential_target, operated_zone)
	var/atom/movable/operate_on = get_operation_target(potential_target, operated_zone)
	return !isnull(operate_on) && is_available(operate_on, operated_zone)

/**
 * Cała operacja: sprawdzenie, do_after, sukces albo porażka
 *
 * * operating_on - cel, zwykle kończyna albo mob
 * * surgeon - chirurg
 * * tool - narzędzie. MOŻE BYĆ TEKSTEM (IMPLEMENT_HAND), uwaga.
 * * operation_args - op_info, patrz OPERATION_*
 *
 * Zwraca flagę ITEM_INTERACT_*
 */
/datum/surgery_operation/proc/try_perform(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args = list())
	SHOULD_NOT_OVERRIDE(TRUE)
	var/mob/living/patient = get_patient(operating_on)

	if(!check_availability(patient, operating_on, surgeon, tool, operation_args[OPERATION_TARGET_ZONE]))
		return ITEM_INTERACT_BLOCKING

	if(isitem(tool))
		var/obj/item/realtool = tool
		var/tool_return = SEND_SIGNAL(realtool, COMSIG_ITEM_USED_IN_SURGERY, src, operating_on, surgeon)
		if(tool_return & (ITEM_INTERACT_SUCCESS|ITEM_INTERACT_BLOCKING))
			return tool_return

	if(!start_operation(operating_on, surgeon, tool, operation_args))
		return ITEM_INTERACT_BLOCKING

	var/result = NONE

	if(patient)
		update_surgery_mood(patient, SURGERY_STATE_STARTED)
		SEND_SIGNAL(patient, COMSIG_ATOM_SURGERY_STARTED, src, operating_on, tool)

	do
		operation_args[OPERATION_SPEED] = get_time_modifiers(operating_on, surgeon, tool)

		// czas jest ucięty na progu, nadwyżka idzie w szansę porażki
		if(!do_after(surgeon, time * min(operation_args[OPERATION_SPEED], SURGERY_MODIFIER_FAILURE_THRESHOLD), target = patient || operating_on, extra_checks = CALLBACK(src, PROC_REF(operate_check), patient, operating_on, surgeon, tool, operation_args)))
			result |= ITEM_INTERACT_BLOCKING
			if(patient)
				update_surgery_mood(patient, SURGERY_STATE_FAILURE)
			break

		// TRAIT_SELF_SURGERY przy operacji, której normalnie nie da się zrobić na sobie: dodatkowa kara do szansy porażki
		if(patient == surgeon && HAS_TRAIT(surgeon, TRAIT_SELF_SURGERY) && !(operation_flags & OPERATION_SELF_OPERABLE))
			operation_args[OPERATION_SPEED] += 1.5

		// TRAIT_IGNORE_SURGERY_MODIFIERS: bez porażek, chyba że operacja zawsze może się nie udać
		if(HAS_TRAIT(surgeon, TRAIT_IGNORE_SURGERY_MODIFIERS) && !(operation_flags & OPERATION_ALWAYS_FAILABLE))
			operation_args[OPERATION_SPEED] = 0

		if(operation_args[OPERATION_FORCE_FAIL] || prob(clamp(GET_FAILURE_CHANCE(time, operation_args[OPERATION_SPEED]), 0, 99)))
			failure(operating_on, surgeon, tool, operation_args)
			result |= ITEM_INTERACT_BLOCKING
			if(patient)
				update_surgery_mood(patient, SURGERY_STATE_FAILURE)
		else
			success(operating_on, surgeon, tool, operation_args)
			result |= ITEM_INTERACT_SUCCESS
			if(patient)
				update_surgery_mood(patient, SURGERY_STATE_SUCCESS)

		if(isstack(tool))
			var/obj/item/stack/tool_stack = tool
			tool_stack.use(1)

	while((operation_flags & OPERATION_LOOPING) && can_loop(patient, operating_on, surgeon, tool, operation_args))

	if(patient)
		SEND_SIGNAL(patient, COMSIG_ATOM_SURGERY_FINISHED, src, operating_on, tool)

	return result

/// Po operacji: czy można ją powtórzyć (OPERATION_LOOPING)
/datum/surgery_operation/proc/can_loop(mob/living/patient, atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	PROTECTED_PROC(TRUE)
	return operate_check(patient, operating_on, surgeon, tool, operation_args)

/// W trakcie do_after: czy operacja może trwać
/datum/surgery_operation/proc/operate_check(mob/living/patient, atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	PROTECTED_PROC(TRUE)

	if(isstack(tool))
		var/obj/item/stack/tool_stack = tool
		if(tool_stack.amount <= 0)
			return FALSE

	if(!surgeon.surgery_check(tool, (operation_flags & OPERATION_NO_PATIENT_REQUIRED) ? patient : (patient || operating_on)))
		return FALSE

	if(!check_availability(patient, operating_on, surgeon, tool, operation_args[OPERATION_TARGET_ZONE]))
		return FALSE

	return TRUE

/**
 * Przygotowanie przed startem, tu można pytać chirurga o coś (może spać).
 * FALSE przerywa operację.
 */
/datum/surgery_operation/proc/pre_preop(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	PROTECTED_PROC(TRUE)
	return TRUE

/// Komunikaty dla chirurga, widzów i pacjenta (widzą tylko ci tuż obok)
/datum/surgery_operation/proc/display_results(mob/living/surgeon, mob/living/target, self_message, detailed_message, vague_message, target_detailed = FALSE)
	SHOULD_NOT_OVERRIDE(TRUE)
	PROTECTED_PROC(TRUE)

	if(!(istext(self_message)))
		CRASH("[type] operation display_results must have a self_message!")
	if(!(istext(detailed_message)))
		CRASH("[type] operation display_results must have a detailed_message!")
	if(!(istext(vague_message) || target_detailed))
		CRASH("[type] operation display_results must have either a vague_message or target_detailed = TRUE!")

	surgeon.visible_message(detailed_message, self_message, vision_distance = 1, ignored_mobs = target_detailed ? null : target)

	if(target_detailed)
		return

	if(!target)
		if(operation_flags & OPERATION_NO_PATIENT_REQUIRED)
			return
		CRASH("[type] operation attempted to call display_results without a patient, despite requiring one!")

	var/you_feel = pick("krótki ból", "jak ciało ci się napina", "coś niepokojącego")
	target.show_message(vague_message || detailed_message || span_notice("Czujesz [you_feel], gdy ktoś cię operuje."), MSG_VISUAL, span_notice("Czujesz [you_feel], gdy ktoś cię operuje."))

/// Ból pacjenta. Nieprzytomny, na morfinie, bez czucia albo pijany nie czuje.
/datum/surgery_operation/proc/display_pain(mob/living/target, pain_message, mechanical_surgery = FALSE)
	SHOULD_NOT_OVERRIDE(TRUE)
	PROTECTED_PROC(TRUE)

	if(!pain_message)
		return

	if(!target)
		if(operation_flags & OPERATION_NO_PATIENT_REQUIRED)
			return
		CRASH("[type] operation attempted to call display_pain without a patient, despite requiring one!")

	var/drunken_patient = target.get_drunk_amount()
	var/drunken_ignorance_probability = clamp(drunken_patient, 0, 90)

	if(IS_UNCONSCIOUS(target) || HAS_TRAIT(target, TRAIT_FAKEDEATH))
		return
	if(HAS_TRAIT(target, TRAIT_ANALGESIA) || target.reagents?.has_reagent(/datum/reagent/medicine/morphine) || (drunken_patient && prob(drunken_ignorance_probability)))
		to_chat(target, span_notice("Czujesz tępe odrętwienie, gdy ktoś cię operuje."))
		return
	to_chat(target, span_userdanger(pain_message))
	if(prob(30) && !mechanical_surgery)
		target.emote("scream")

/// Dźwięk operacji zależnie od narzędzia
/datum/surgery_operation/proc/play_operation_sound(atom/movable/operating_on, mob/living/surgeon, tool, sound_or_sound_list)
	PROTECTED_PROC(TRUE)

	if(isitem(tool) && (operation_flags & OPERATION_MECHANIC))
		var/obj/item/realtool = tool
		if(realtool.usesound)
			realtool.play_tool_sound(operating_on)
			return

	var/sound_to_play
	if(islist(sound_or_sound_list))
		var/list/sounds = sound_or_sound_list
		if(isitem(tool))
			var/obj/item/realtool = tool
			sound_to_play = (realtool.tool_behaviour && sounds[realtool.tool_behaviour])
			if(!sound_to_play)
				for(var/sound_key in sounds)
					if(ispath(sound_key) && istype(realtool, sound_key))
						sound_to_play = sounds[sound_key]
						break
		else
			sound_to_play = sounds[tool]
	else
		sound_to_play = sound_or_sound_list

	if(sound_to_play)
		playsound(surgeon, sound_to_play, 50, TRUE)

/// Mob, którego ostatecznie operujemy (dla kończyny: jej właściciel)
/datum/surgery_operation/proc/get_patient(atom/movable/operating_on)
	return operating_on

/// Komputer operacyjny podpięty do stołu, na którym leży pacjent
/datum/surgery_operation/proc/locate_operating_computer(atom/movable/operating_on)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/turf/operating_turf = get_turf(operating_on)
	if(isnull(operating_turf))
		return null

	var/obj/structure/table/optable/operating_table = locate() in operating_turf
	var/obj/machinery/computer/operating/operating_computer = operating_table?.computer

	if(isnull(operating_computer) || (operating_computer.machine_stat & (NOPOWER|BROKEN)))
		return null

	return operating_computer

/// Nastrój pacjenta zależnie od etapu operacji (system nastrojów Bee: sygnały COMSIG_ADD/CLEAR_MOOD_EVENT)
/datum/surgery_operation/proc/update_surgery_mood(mob/living/patient, surgery_state)
	PROTECTED_PROC(TRUE)
	if(!(operation_flags & OPERATION_AFFECTS_MOOD))
		return

	var/drunk_ignore_prob = clamp(patient.get_drunk_amount(), 0, 90)

	if(HAS_TRAIT(patient, TRAIT_ANALGESIA) || patient.reagents?.has_reagent(/datum/reagent/medicine/morphine) || prob(drunk_ignore_prob))
		SEND_SIGNAL(patient, COMSIG_CLEAR_MOOD_EVENT, SURGERY_MOOD_CATEGORY)
		return
	if(IS_UNCONSCIOUS(patient))
		// śpiący nie dostaje traumy, ale jak zasnął w trakcie, niech obudzi się z lepszym wspomnieniem
		var/datum/component/mood/mood = patient.GetComponent(/datum/component/mood)
		var/datum/mood_event/surgery/target_mood_event = mood?.mood_events[SURGERY_MOOD_CATEGORY]
		if(!istype(target_mood_event) || target_mood_event.surgery_completed)
			return
	switch(surgery_state)
		if(SURGERY_STATE_STARTED)
			SEND_SIGNAL(patient, COMSIG_ADD_MOOD_EVENT, SURGERY_MOOD_CATEGORY, surgery_started_mood_event)
		if(SURGERY_STATE_SUCCESS)
			SEND_SIGNAL(patient, COMSIG_ADD_MOOD_EVENT, SURGERY_MOOD_CATEGORY, surgery_success_mood_event)
		if(SURGERY_STATE_FAILURE)
			SEND_SIGNAL(patient, COMSIG_ADD_MOOD_EVENT, SURGERY_MOOD_CATEGORY, surgery_failure_mood_event)
		else
			CRASH("passed invalid surgery_state, \"[surgery_state]\".")

/**
 * Start operacji. Nie ruszaj, nadpisuj on_preop().
 */
/datum/surgery_operation/proc/start_operation(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	SHOULD_NOT_OVERRIDE(TRUE)
	PRIVATE_PROC(TRUE)

	var/preop_time = world.time
	var/mob/living/patient = get_patient(operating_on)
	if(!pre_preop(operating_on, surgeon, tool, operation_args))
		return FALSE
	// pre_preop mogło spać, więc sprawdzamy jeszcze raz
	if(preop_time != world.time)
		if(patient != get_patient(operating_on))
			return FALSE
		if(!in_range(patient || operating_on, surgeon))
			return FALSE
		if(!operate_check(patient, operating_on, surgeon, tool, operation_args))
			return FALSE

	play_operation_sound(operating_on, surgeon, tool, preop_sound)
	on_preop(operating_on, surgeon, tool, operation_args)
	return TRUE

/**
 * Co się dzieje na początku operacji (komunikaty, ból)
 */
/datum/surgery_operation/proc/on_preop(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	PROTECTED_PROC(TRUE)
	var/mob/living/patient = get_patient(operating_on)
	var/atom/movable/display_target = patient || operating_on
	display_results(
		surgeon,
		patient,
		span_notice("Zaczynasz operować [display_target]..."),
		span_notice("[surgeon] zaczyna operować [display_target]."),
		span_notice("[surgeon] zaczyna operować [display_target]."),
	)

/**
 * Sukces. Nie ruszaj, nadpisuj on_success().
 */
/datum/surgery_operation/proc/success(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	SHOULD_NOT_OVERRIDE(TRUE)
	PRIVATE_PROC(TRUE)
	SHOULD_NOT_SLEEP(TRUE)

	if(operation_flags & OPERATION_NOTABLE)
		SSblackbox.record_feedback("tally", "surgeries_completed", 1, type)

	SEND_SIGNAL(surgeon, COMSIG_ATOM_SURGERY_SUCCESS, src, operating_on, tool)
	play_operation_sound(operating_on, surgeon, tool, success_sound)
	on_success(operating_on, surgeon, tool, operation_args)

/**
 * Efekt udanej operacji
 */
/datum/surgery_operation/proc/on_success(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	PROTECTED_PROC(TRUE)
	var/mob/living/patient = get_patient(operating_on)

	display_results(
		surgeon,
		patient,
		span_notice("Udaje ci się."),
		span_notice("[surgeon] kończy z powodzeniem!"),
		span_notice("[surgeon] kończy."),
	)

/**
 * Porażka. Nie ruszaj, nadpisuj on_failure().
 */
/datum/surgery_operation/proc/failure(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	SHOULD_NOT_OVERRIDE(TRUE)
	PRIVATE_PROC(TRUE)
	SHOULD_NOT_SLEEP(TRUE)

	if(operation_flags & OPERATION_NOTABLE)
		SSblackbox.record_feedback("tally", "surgeries_failed", 1, type)

	SEND_SIGNAL(surgeon, COMSIG_ATOM_SURGERY_FAILED, src, operating_on, tool)
	play_operation_sound(operating_on, surgeon, tool, failure_sound)
	on_failure(operating_on, surgeon, tool, operation_args)

/**
 * Efekt nieudanej operacji. operation_args[OPERATION_SPEED] mówi, jak bardzo źle poszło (od 2,5 w górę).
 */
/datum/surgery_operation/proc/on_failure(atom/movable/operating_on, mob/living/surgeon, tool, list/operation_args)
	PROTECTED_PROC(TRUE)
	var/mob/living/patient = get_patient(operating_on)

	var/screwedmessage = ""
	switch(operation_args[OPERATION_SPEED])
		if(2.5 to 3)
			screwedmessage = " Ale było blisko."
		if(4 to 5)
			screwedmessage = " W tych warunkach trudno to zrobić dobrze..."
		if(5 to INFINITY)
			screwedmessage = " W tych warunkach to praktycznie niemożliwe..."
	if(operation_args[OPERATION_FORCE_FAIL])
		screwedmessage = " Celowo."

	display_results(
		surgeon,
		patient,
		span_warning("Partaczysz![screwedmessage]"),
		span_warning("[surgeon] partaczy!"),
		span_notice("[surgeon] kończy."),
		TRUE, // pacjent zauważy, że coś poszło nie tak
	)

/**
 * Operacje "basic": działają na każdym mobie.
 * Na mobie z kończynami sprawdzają stan kończyny target_zone, na mobie bez kończyn stan z /datum/status_effect/basic_surgery_state.
 * Celem (operating_on) jest sam mob.
 */
/datum/surgery_operation/basic
	abstract_type = /datum/surgery_operation/basic
	/// AQUILA - u nas mob_biotypes to lista tekstów, a nie pole bitowe. Pacjent musi mieć ten biotyp (null = dowolny).
	var/required_biotype
	/// AQUILA - pacjent nie może mieć tego biotypu (tg: required_biotype = ~MOB_ROBOTIC)
	var/blocked_biotype = MOB_ROBOTIC
	/// Strefa, na której operujemy, także na mobie bez kończyn. null = dowolna.
	var/target_zone = BODY_ZONE_CHEST
	/// Na mobach z kończynami: jaki rodzaj kończyny (pole bitowe bodytype)
	var/required_bodytype = ~BODYTYPE_ROBOTIC

/datum/surgery_operation/basic/all_required_strings()
	. = list()
	if(target_zone)
		. += "operacja na: [strefa_pl(target_zone)]"
	else if(required_biotype || blocked_biotype)
		. += "operacja na pacjencie"
	. += ..()

/datum/surgery_operation/basic/all_blocked_strings()
	. = ..()
	if(required_biotype == MOB_ROBOTIC)
		. += "pacjent nie może być organiczny"
	else if(blocked_biotype == MOB_ROBOTIC)
		. += "pacjent nie może być robotem"

/datum/surgery_operation/basic/is_available(mob/living/patient, operated_zone)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(target_zone && target_zone != operated_zone)
		return FALSE
	if(!HAS_TRAIT(patient, TRAIT_READY_TO_OPERATE))
		return FALSE
	if(required_biotype && !(required_biotype in patient.mob_biotypes))
		return FALSE
	if(blocked_biotype && (blocked_biotype in patient.mob_biotypes))
		return FALSE
	if(!patient.has_limbs || !target_zone)
		return ..()

	var/obj/item/bodypart/carbon_part = patient.get_bodypart(target_zone)
	if(isnull(carbon_part))
		return FALSE
	if(!HAS_TRAIT(carbon_part, TRAIT_READY_TO_OPERATE))
		return FALSE
	if(required_bodytype && !(carbon_part.bodytype & required_bodytype))
		return FALSE
	return ..()

/datum/surgery_operation/basic/has_surgery_state(mob/living/patient, state)
	var/obj/item/bodypart/carbon_part = patient.get_bodypart(target_zone)
	if(isnull(carbon_part)) // bez kończyn
		var/datum/status_effect/basic_surgery_state/state_holder = patient.has_status_effect(/datum/status_effect/basic_surgery_state) || null // u nas FALSE, gdy brak statusu
		return HAS_SURGERY_STATE(state_holder?.surgery_state, state & (SURGERY_BONE_SAWED|SURGERY_SKIN_OPEN)) // tylko te stany mają moby bez kończyn

	return LIMB_HAS_SURGERY_STATE(carbon_part, state)

/datum/surgery_operation/basic/has_any_surgery_state(mob/living/patient, state)
	var/obj/item/bodypart/carbon_part = patient.get_bodypart(target_zone)
	if(isnull(carbon_part)) // bez kończyn
		var/datum/status_effect/basic_surgery_state/state_holder = patient.has_status_effect(/datum/status_effect/basic_surgery_state) || null // u nas FALSE, gdy brak statusu
		return HAS_ANY_SURGERY_STATE(state_holder?.surgery_state, state)

	return LIMB_HAS_ANY_SURGERY_STATE(carbon_part, state)

/**
 * Operacje na kończynie wybranej przez chirurga. Celem (operating_on) jest kończyna.
 */
/datum/surgery_operation/limb
	abstract_type = /datum/surgery_operation/limb
	/// Wymagany rodzaj kończyny (pole bitowe bodytype)
	var/required_bodytype = NONE
	/// tg: można operować kikut. U nas nie ma kikutów, zostaje dla zgodności.
	var/allow_stumps = FALSE

/datum/surgery_operation/limb/all_blocked_strings()
	. = ..()
	if(required_bodytype & BODYTYPE_ROBOTIC)
		. += "kończyna nie może być organiczna"
	else if(required_bodytype & BODYTYPE_ORGANIC)
		. += "kończyna nie może być robotyczna"

/datum/surgery_operation/limb/get_operation_target(atom/movable/operating_on, body_zone)
	if(isliving(operating_on))
		var/mob/living/patient = operating_on
		return patient.get_bodypart(check_zone(body_zone))
	if(!isbodypart(operating_on))
		return null
	return operating_on

/datum/surgery_operation/limb/is_available(obj/item/bodypart/limb, operated_zone)
	SHOULD_NOT_OVERRIDE(TRUE)

	// pachwina przekierowuje na klatkę piersiową
	if(limb.body_zone != check_zone(operated_zone))
		return FALSE

	if(required_bodytype && !(limb.bodytype & required_bodytype))
		return FALSE

	// AQUILA - w tg tego nie ma (sprawdza tylko moba), u nas kończyna musi być przygotowana, żeby nowe operacje nie zabierały
	// narzędzi staremu szkieletowi na nieprzygotowanych strefach
	if(limb.owner && !HAS_TRAIT(limb, TRAIT_READY_TO_OPERATE))
		return FALSE

	return ..()

/datum/surgery_operation/limb/has_surgery_state(obj/item/bodypart/limb, state)
	return LIMB_HAS_SURGERY_STATE(limb, state)

/datum/surgery_operation/limb/has_any_surgery_state(obj/item/bodypart/limb, state)
	return LIMB_HAS_ANY_SURGERY_STATE(limb, state)

/datum/surgery_operation/limb/get_patient(obj/item/bodypart/limb)
	return limb.owner

/**
 * Operacje na organie danego typu. Celem (operating_on) jest organ.
 */
/datum/surgery_operation/organ
	abstract_type = /datum/surgery_operation/organ
	/// AQUILA - u nas rodzaj organu to organ.status (ORGAN_ORGANIC = 1, ORGAN_ROBOTIC = 2), więc to maska na status
	var/required_organ_flag = ORGAN_ORGANIC
	/// Typ organu
	var/obj/item/organ/target_type

/datum/surgery_operation/organ/all_required_strings()
	return list("operacja na: [initial(target_type.name)] ([strefa_pl(initial(target_type.zone))])") + ..()

/datum/surgery_operation/organ/all_blocked_strings()
	. = ..()
	if(required_organ_flag == ORGAN_ROBOTIC)
		. += "organ nie może być organiczny"
	else if(required_organ_flag == ORGAN_ORGANIC)
		. += "organ nie może być cybernetyczny"

/datum/surgery_operation/organ/get_default_radial_image()
	return get_generic_limb_radial_image(initial(target_type.zone))

/datum/surgery_operation/organ/get_operation_target(atom/movable/operating_on, body_zone)
	if(isliving(operating_on))
		var/mob/living/patient = operating_on
		return patient.getorgan(target_type)

	if(!isbodypart(operating_on))
		return null

	return locate(target_type) in operating_on

/datum/surgery_operation/organ/get_patient(obj/item/organ/organ)
	return organ.owner

/datum/surgery_operation/organ/is_available(obj/item/organ/organ, operated_zone)
	SHOULD_NOT_OVERRIDE(TRUE)

	if(organ.zone != operated_zone) // żeby oczy nie wyskakiwały przy głowie
		return FALSE
	if(required_organ_flag && !(organ.status & required_organ_flag))
		return FALSE
	var/obj/item/bodypart/organ_limb = organ.get_bodypart_owner()
	if(isnull(organ_limb) || !HAS_TRAIT(organ_limb, TRAIT_READY_TO_OPERATE))
		return FALSE

	return ..()

/datum/surgery_operation/organ/has_surgery_state(obj/item/organ/organ, state)
	return LIMB_HAS_SURGERY_STATE(organ.get_bodypart_owner(), state)

/datum/surgery_operation/organ/has_any_surgery_state(obj/item/organ/organ, state)
	return LIMB_HAS_ANY_SURGERY_STATE(organ.get_bodypart_owner(), state)

/// AQUILA - tg: organ.bodypart_owner. U nas organ zna tylko właściciela i strefę.
/obj/item/organ/proc/get_bodypart_owner()
	return owner?.get_bodypart(check_zone(zone))
