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

// --- Hooki w core, które pytały o stare operacje (AQ EDIT, LEGACY_OVERRIDES.md) ---

/// Zarodek obcego (alien_embryo.dm): klatka otwarta nową chirurgią to operacja w toku, larwa wychodzi bez zabijania (tg: skóra + kość)
/mob/living/proc/is_chest_open_for_surgery()
	return LIMB_HAS_SURGERY_STATE(get_bodypart(BODY_ZONE_CHEST), SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED)

/// Moduł MOD wystrzeliwujący organy (modules_medical.dm): organ wchodzi do kończyny otwartej nową chirurgią (tg: skóra, organy, kość)
/mob/living/proc/can_receive_shot_organ(obj/item/organ/organ)
	return LIMB_HAS_SURGERY_STATE(get_bodypart(check_zone(organ.zone)), SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|SURGERY_BONE_SAWED)
