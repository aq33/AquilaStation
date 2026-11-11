// Strój chroniący przed promieniowaniem z BeeStation/BeeStation-Hornet#13442 (port tg).
/// Oznacza przedmiot jako chroniący przed promieniowaniem: cecha TRAIT_RADIATION_PROTECTED_CLOTHING i dopisek w opisie.
/// Chroni tylko komplet: każda część ciała musi być zakryta takim ubraniem.
/datum/element/radiation_protected_clothing
	element_flags = ELEMENT_DETACH

/datum/element/radiation_protected_clothing/Attach(datum/target)
	. = ..()

	if (!isclothing(target))
		return ELEMENT_INCOMPATIBLE

	ADD_TRAIT(target, TRAIT_RADIATION_PROTECTED_CLOTHING, REF(src))
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/element/radiation_protected_clothing/Detach(datum/source, ...)
	REMOVE_TRAIT(source, TRAIT_RADIATION_PROTECTED_CLOTHING, REF(src))
	UnregisterSignal(source, COMSIG_PARENT_EXAMINE)
	return ..()

/datum/element/radiation_protected_clothing/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	examine_text += span_notice("Naszywka ze znakiem zagrożenia na boku sugeruje, że <b>chroni przed promieniowaniem</b>.")

/// Aquila (decyzja: kombinezon i każdy strój z pancerzem `rad` >= 100): ubranie z pełną osłoną przed promieniowaniem
/// w pancerzu dostaje ten element samo. Chroni dopiero komplet na każdej części ciała.
/obj/item/clothing/Initialize(mapload)
	. = ..()
	if (armor?.rad >= 100)
		AddElement(/datum/element/radiation_protected_clothing)
