// AQUILA - mostek między nowym szkieletem chirurgii (tgstation#93697) a starym (/datum/surgery z krokami).
// Przejściowe: stary szkielet działa dalej, dopóki kolejne etapy nie przeniosą wszystkich operacji.
//
// Kolejność przy kliknięciu narzędziem albo pustą ręką na moba (bez combat mode):
// 1. Mob nieprzygotowany (brak TRAIT_READY_TO_OPERATE) albo w tej strefie trwa stara operacja -> stary łańcuch jak dotąd.
// 2. Mob przygotowany -> perform_surgery(): menu z nowymi operacjami pasującymi do narzędzia i stanu kończyny.
//    Jest operacja -> wykonuje ją i kończy kliknięcie. Nie ma, a to narzędzie chirurgiczne na przygotowanej strefie ->
//    podpowiedź i blokada ataku (jak w tg). Inaczej -> stary łańcuch (atak, leczenie stackami, rany...).
// Serwety i prześcieradło zawsze idą do starego surgery_initiator: w jego menu jest wybór starej operacji
// albo "Przygotuj do operacji narzędziami" (nowy szkielet). Bez dostępnych starych operacji od razu przygotowują strefę.

/**
 * Nowa chirurgia z łańcucha kliknięcia. Hook w /obj/item/proc/melee_attack_chain (przed tool_act, jak item_interaction w tg)
 * i w /mob/living/carbon/attack_hand.
 *
 * * patient - kliknięty atom
 * * tool - przedmiot albo IMPLEMENT_HAND
 * * right_click - prawy klik (operacja celowo się nie uda)
 *
 * Zwraca TRUE, jeśli kliknięcie zostało obsłużone i reszta łańcucha ma się nie wykonać
 */
/mob/living/proc/try_tg_surgery(atom/patient, tool = IMPLEMENT_HAND, right_click = FALSE)
	if(combat_mode || !isliving(patient))
		return FALSE
	var/mob/living/living_patient = patient
	if(isitem(tool))
		var/obj/item/item_tool = tool
		// serwety i prześcieradło: stary initiator, w nim jest przygotowanie do nowej chirurgii
		if(item_tool.GetComponent(/datum/component/surgery_initiator))
			return FALSE

	if(HAS_TRAIT(living_patient, TRAIT_READY_TO_OPERATE) && !living_patient.get_legacy_surgery(zone_selected))
		var/surgery_result = perform_surgery(living_patient, tool, right_click)
		if(surgery_result & (ITEM_INTERACT_SUCCESS|ITEM_INTERACT_BLOCKING))
			return TRUE

	// tg: zamknięcie rany na sobie działa też bez przygotowania
	if(living_patient == src && isitem(tool))
		var/manual_cauterization = try_manual_cauterize(tool)
		if(manual_cauterization & (ITEM_INTERACT_SUCCESS|ITEM_INTERACT_BLOCKING))
			return TRUE

	return FALSE

/// Stara operacja (/datum/surgery) w tej strefie, jeśli jest
/mob/living/proc/get_legacy_surgery(zone)
	for(var/datum/surgery/legacy_surgery as anything in surgeries)
		if(legacy_surgery.location == zone)
			return legacy_surgery
	return null

// Pusta ręka (operacje z IMPLEMENT_HAND, np. otwarcie klapy protezy). Przed starym łańcuchem w carbon_defense.dm.
/mob/living/carbon/attack_hand(mob/living/carbon/human/user, modifiers)
	if(isliving(user))
		var/mob/living/living_user = user
		if(living_user.try_tg_surgery(src, IMPLEMENT_HAND, LAZYACCESS(modifiers, RIGHT_CLICK)))
			return TRUE
	return ..()

// Serwety bez dostępnych starych operacji: od razu przygotowanie strefy (albo jego zdjęcie)
/datum/component/surgery_initiator/do_initiate_surgery_moment(mob/living/target, mob/user)
	if(!isliving(user) || target.get_legacy_surgery(user.zone_selected) || length(get_available_surgeries(user, target)))
		return ..()
	target.toggle_surgery_prep(user, user.zone_selected, get_surgery_aid_name())

/// Nazwa pomocy chirurgicznej do opisu przygotowania
/datum/component/surgery_initiator/proc/get_surgery_aid_name()
	if(istype(parent, /obj/item/bedsheet))
		return "prześcieradło"
	return "serwety"

// --- Odblokowanie zablokowanych operacji (OPERATION_LOCKED) ---
// W tg odblokowują je dyski i badania przez sygnały. U nas to samo źródło co dla starych zaawansowanych operacji:
// advanced_surgeries komputera operacyjnego (stół albo łóżko stazy), procesora chirurgicznego borga i implantu
// linkedsurgery (dyski i zbadane /datum/design/surgery). Nowa operacja wskazuje swoje stare odpowiedniki w legacy_unlocked_by.
// TRAIT_SURGEON (abduktorzy) odblokowuje wszystko, jak w starym can_start().

/datum/surgery_operation
	/// AQUILA - stare operacje (/datum/surgery), których odblokowanie odblokowuje też tę (dla OPERATION_LOCKED)
	var/list/legacy_unlocked_by

/**
 * Zablokowane operacje, które chirurg może teraz zrobić na tym pacjencie (dyski, badania, TRAIT_SURGEON)
 */
/mob/living/proc/get_legacy_unlocked_operations(atom/movable/operating_on)
	var/list/unlocked = list()
	if(HAS_TRAIT(src, TRAIT_SURGEON) || (mind && HAS_TRAIT(mind, TRAIT_SURGEON)))
		unlocked += GLOB.operations.locked
		return unlocked
	var/list/legacy_surgeries = get_legacy_advanced_surgeries(operating_on)
	if(!length(legacy_surgeries))
		return unlocked
	for(var/operation_type in GLOB.operations.locked)
		var/datum/surgery_operation/operation = GLOB.operations.operations_by_typepath[operation_type]
		if(length(operation?.legacy_unlocked_by & legacy_surgeries))
			unlocked += operation_type
	return unlocked

/// Stare zaawansowane operacje dostępne dla chirurga przy tym pacjencie (te same źródła co /datum/surgery/proc/can_start)
/mob/living/proc/get_legacy_advanced_surgeries(atom/movable/operating_on)
	var/list/surgeries = list()
	if(iscyborg(src))
		var/mob/living/silicon/robot/robot = src
		var/obj/item/surgical_processor/processor = locate() in robot.module?.modules
		if(processor)
			surgeries |= processor.advanced_surgeries
	if(iscarbon(src))
		var/mob/living/carbon/carbon_self = src
		var/obj/item/organ/cyberimp/brain/linkedsurgery/implant = carbon_self.getorganslot(ORGAN_SLOT_BRAIN_SURGICAL_IMPLANT)
		if(istype(implant))
			surgeries |= implant.advanced_surgeries
	var/turf/patient_turf = get_turf(operating_on)
	if(isnull(patient_turf))
		return surgeries
	var/obj/structure/table/optable/table = locate() in patient_turf
	if(table?.computer && !(table.computer.machine_stat & (NOPOWER|BROKEN)))
		surgeries |= table.computer.advanced_surgeries
	var/obj/machinery/stasis/stasis_bed = locate() in patient_turf
	if(stasis_bed?.op_computer && !(stasis_bed.op_computer.machine_stat & (NOPOWER|BROKEN)))
		surgeries |= stasis_bed.op_computer.advanced_surgeries
	return surgeries
