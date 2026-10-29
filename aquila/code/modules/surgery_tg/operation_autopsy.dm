// AQUILA - tg code/modules/surgery/operations/operation_autopsy.dm
// Autopsja skanerem (stara wersja: aquila/code/modules/surgery/autopsy.dm). Zostaje z naszej: cecha "autopsied"
// (zdejmowana po ożywieniu, osobna od TRAIT_DISSECTED, żeby eksperymentalna sekcja dalej działała), raport skanera
// i 5 obrażeń przy porażce. Pominięte z tg: TRAIT_SURGICALLY_ANALYZED, sygnał komputera operacyjnego, nastrój TRAIT_MORBID.

// te same wartości co w autopsy.dm (tam są #undef na końcu pliku)
#define TRAIT_AUTOPSIED "autopsied"
#define AUTOPSY_TRAIT "autopsy"

/datum/surgery_operation/limb/autopsy
	name = "autopsja"
	rnd_name = "Androtomia (sekcja i autopsja)"
	desc = "Dokładnie bada zwłoki pacjenta skanerem autopsyjnym i drukuje raport."
	implements = list(/obj/item/autopsy_scanner = 1)
	time = 10 SECONDS
	success_sound = 'sound/machines/ping.ogg'
	required_bodytype = ~BODYTYPE_ROBOTIC
	operation_flags = OPERATION_MORBID | OPERATION_IGNORE_CLOTHES
	all_surgery_states_required = SURGERY_SKIN_OPEN

/datum/surgery_operation/limb/autopsy/get_default_radial_image()
	return get_item_radial_image(/obj/item/autopsy_scanner)

/datum/surgery_operation/limb/autopsy/all_required_strings()
	. = list()
	. += "operacja na klatce piersiowej"
	. += ..()
	. += "pacjent musi być martwy"
	. += "na ciele nie mogło być wcześniej autopsji"

/datum/surgery_operation/limb/autopsy/state_check(obj/item/bodypart/limb)
	if(limb.body_zone != BODY_ZONE_CHEST)
		return FALSE
	if(limb.owner.stat != DEAD)
		return FALSE
	if(HAS_TRAIT(limb.owner, TRAIT_AUTOPSIED))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/autopsy/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/autopsy_scanner/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz autopsję [limb.owner]..."),
		span_notice("[surgeon] przeprowadza autopsję [limb.owner] za pomocą [tool]."),
		span_notice("[surgeon] używa [tool] na klatce piersiowej [limb.owner]."),
	)

/datum/surgery_operation/limb/autopsy/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/autopsy_scanner/tool, list/operation_args)
	ADD_TRAIT(limb.owner, TRAIT_AUTOPSIED, AUTOPSY_TRAIT)
	tool.scan_cadaver(surgeon, limb.owner)
	return ..()

/datum/surgery_operation/limb/autopsy/on_failure(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_warning("Partaczysz i obijasz klatkę piersiową [limb.owner]!"),
		span_warning("[surgeon] partaczy i obija klatkę piersiową [limb.owner]!"),
		span_warning("[surgeon] partaczy!"),
	)
	limb.owner.adjustBruteLoss(5)

/// Analiza awarii systemu (IPC, protezy)
/datum/surgery_operation/limb/autopsy/mechanic
	name = "analiza awarii systemu"
	rnd_name = "Analiza awarii systemu (sekcja i autopsja)"
	desc = "Dokładnie bada wyłączone systemy robotycznego pacjenta skanerem autopsyjnym."
	required_bodytype = BODYTYPE_ROBOTIC
	operation_flags = OPERATION_MORBID | OPERATION_IGNORE_CLOTHES | OPERATION_MECHANIC

#undef TRAIT_AUTOPSIED
#undef AUTOPSY_TRAIT
