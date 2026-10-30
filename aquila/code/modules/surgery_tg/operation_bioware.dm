// AQUILA - tg code/modules/surgery/operations/operation_bioware.dm
// Bioware: trwałe modyfikacje ciała (stare wersje: code/modules/surgery/advanced/bioware/*.dm).
// Zostaje nasz system /datum/bioware (lista human.bioware, jedna modyfikacja na mod_type) zamiast statusów z tg.
// Zaawansowane operacje z dysku albo badań: OPERATION_LOCKED, odblokowują je dyski i projekty /datum/design/surgery (surgery_unlocks.dm).
// Zostają nasze wymagania: klatka bez piłowania kości (nacięta skóra, zaciśnięte naczynia, nacięte organy), głowa
// z przepiłowaną czaszką; przeplatanie żył można zrobić na sobie; nieudane fałdowanie i odciskanie kory: 60 uszkodzeń
// mózgu i ciężka trauma. Pominięte z tg: wersje dla protez (stare operacje były tylko dla organicznych kończyn).

/datum/surgery_operation/limb/bioware
	abstract_type = /datum/surgery_operation/limb/bioware
	implements = list(
		IMPLEMENT_HAND = 1,
	)
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE | OPERATION_MORBID | OPERATION_LOCKED
	required_bodytype = BODYTYPE_ORGANIC
	time = 12.5 SECONDS
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED
	/// Modyfikacja dodawana po sukcesie
	var/datum/bioware/bioware_type = /datum/bioware
	/// Strefa operacji
	var/required_zone = BODY_ZONE_CHEST

/datum/surgery_operation/limb/bioware/get_default_radial_image()
	return get_generic_limb_radial_image(required_zone)

/datum/surgery_operation/limb/bioware/all_required_strings()
	return list("operacja na: [strefa_pl(required_zone)]") + ..()

/datum/surgery_operation/limb/bioware/all_blocked_strings()
	var/list/incompatible_surgeries = list()
	for(var/datum/surgery_operation/limb/bioware/other_bioware as anything in subtypesof(/datum/surgery_operation/limb/bioware))
		var/datum/bioware/other_type = initial(other_bioware.bioware_type)
		if(initial(other_type.mod_type) != initial(bioware_type.mod_type))
			continue
		incompatible_surgeries += (initial(other_bioware.rnd_name) || initial(other_bioware.name))
	return ..() + list("pacjent nie może mieć już za sobą: [english_list(incompatible_surgeries, and_text = " ANI ")]")

/datum/surgery_operation/limb/bioware/state_check(obj/item/bodypart/limb)
	if(limb.body_zone != required_zone)
		return FALSE
	if(!ishuman(limb.owner))
		return FALSE
	var/mob/living/carbon/human/patient = limb.owner
	for(var/datum/bioware/existing as anything in patient.bioware)
		if(existing.mod_type == initial(bioware_type.mod_type))
			return FALSE
	return TRUE

/datum/surgery_operation/limb/bioware/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	new bioware_type(limb.owner)
	if(limb.owner.ckey)
		SSblackbox.record_feedback("tally", "bioware", 1, bioware_type)

// --- Układ krwionośny ---

/datum/surgery_operation/limb/bioware/vein_threading
	name = "przeplatanie żył"
	rnd_name = "Symwaskulodeza (przeplatanie żył)"
	desc = "Przeplata naczynia krwionośne pacjenta w wytrzymałą siatkę, mocno ograniczając utratę krwi z ran."
	// AQUILA - jak stara operacja: można ją zrobić na sobie
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_NOTABLE | OPERATION_MORBID | OPERATION_LOCKED | OPERATION_SELF_OPERABLE
	bioware_type = /datum/bioware/threaded_veins

/datum/surgery_operation/limb/bioware/vein_threading/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz przeplatać układ krwionośny [limb.owner]."),
		span_notice("[surgeon] zaczyna przeplatać układ krwionośny [limb.owner]."),
		span_notice("[surgeon] zaczyna manipulować układem krwionośnym [limb.owner]."),
	)
	display_pain(limb.owner, "Całe ciało płonie z bólu!")

/datum/surgery_operation/limb/bioware/vein_threading/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Przeplatasz układ krwionośny [limb.owner] w odporną siatkę!"),
		span_notice("[surgeon] przeplata układ krwionośny [limb.owner] w odporną siatkę!"),
		span_notice("[surgeon] kończy manipulować układem krwionośnym [limb.owner]."),
	)
	display_pain(limb.owner, "Czujesz, jak krew płynie przez wzmocnione żyły!")

/datum/surgery_operation/limb/bioware/muscled_veins
	name = "umięśnienie żył"
	rnd_name = "Miowaskuloplastyka (umięśnione żyły)"
	desc = "Dodaje do naczyń krwionośnych pacjenta umięśnioną błonę, dzięki której pompują krew nawet bez serca."
	bioware_type = /datum/bioware/muscled_veins

/datum/surgery_operation/limb/bioware/muscled_veins/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz owijać mięśnie wokół układu krwionośnego [limb.owner]."),
		span_notice("[surgeon] zaczyna owijać mięśnie wokół układu krwionośnego [limb.owner]."),
		span_notice("[surgeon] zaczyna manipulować układem krwionośnym [limb.owner]."),
	)
	display_pain(limb.owner, "Całe ciało płonie z bólu!")

/datum/surgery_operation/limb/bioware/muscled_veins/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Przekształcasz układ krwionośny [limb.owner], dodając umięśnioną błonę!"),
		span_notice("[surgeon] przekształca układ krwionośny [limb.owner], dodając umięśnioną błonę!"),
		span_notice("[surgeon] kończy manipulować układem krwionośnym [limb.owner]."),
	)
	display_pain(limb.owner, "Czujesz, jak potężne uderzenia serca rozchodzą się po całym ciele!")

// --- Nerwy ---

/datum/surgery_operation/limb/bioware/nerve_splicing
	name = "splatanie nerwów"
	rnd_name = "Symneurodeza (splecione nerwy)"
	desc = "Splata nerwy pacjenta, przez co ogłuszenia działają na niego słabiej."
	time = 15.5 SECONDS
	bioware_type = /datum/bioware/spliced_nerves

/datum/surgery_operation/limb/bioware/nerve_splicing/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz łączyć nerwy [limb.owner]."),
		span_notice("[surgeon] zaczyna łączyć nerwy [limb.owner]."),
		span_notice("[surgeon] zaczyna manipulować układem nerwowym [limb.owner]."),
	)
	display_pain(limb.owner, "Całe ciało drętwieje!")

/datum/surgery_operation/limb/bioware/nerve_splicing/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Pomyślnie łączysz układ nerwowy [limb.owner]!"),
		span_notice("[surgeon] pomyślnie łączy układ nerwowy [limb.owner]!"),
		span_notice("[surgeon] kończy manipulować układem nerwowym [limb.owner]."),
	)
	display_pain(limb.owner, "Czucie wraca, a wszystko wokół jakby zwolniło!")

/datum/surgery_operation/limb/bioware/nerve_grounding
	name = "uziemienie nerwów"
	rnd_name = "Ksantoneuroplastyka (uziemione nerwy)"
	desc = "Przekierowuje nerwy pacjenta tak, że działają jak uziemienie i chronią przed porażeniem prądem."
	time = 15.5 SECONDS
	bioware_type = /datum/bioware/grounded_nerves

/datum/surgery_operation/limb/bioware/nerve_grounding/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz przekierowywać nerwy [limb.owner]."),
		span_notice("[surgeon] zaczyna przekierowywać nerwy [limb.owner]."),
		span_notice("[surgeon] zaczyna manipulować układem nerwowym [limb.owner]."),
	)
	display_pain(limb.owner, "Całe ciało drętwieje!")

/datum/surgery_operation/limb/bioware/nerve_grounding/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Pomyślnie przekierowujesz układ nerwowy [limb.owner]!"),
		span_notice("[surgeon] pomyślnie przekierowuje układ nerwowy [limb.owner]!"),
		span_notice("[surgeon] kończy manipulować układem nerwowym [limb.owner]."),
	)
	display_pain(limb.owner, "Czucie wraca, czujesz przypływ energii!")

// --- Więzadła ---

/datum/surgery_operation/limb/bioware/ligament_hook
	name = "przekształcenie więzadeł"
	rnd_name = "Artroplastyka (haki więzadłowe)"
	desc = "Przekształca więzadła pacjenta tak, że odcięte kończyny da się przyczepić ręcznie, ale łatwiej je też oderwać."
	bioware_type = /datum/bioware/hooked_ligaments

/datum/surgery_operation/limb/bioware/ligament_hook/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz przekształcać więzadła [limb.owner] w kształt haka."),
		span_notice("[surgeon] zaczyna przekształcać więzadła [limb.owner] w kształt haka."),
		span_notice("[surgeon] zaczyna manipulować więzadłami [limb.owner]."),
	)
	display_pain(limb.owner, "Kończyny płoną potwornym bólem!")

/datum/surgery_operation/limb/bioware/ligament_hook/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Przekształcasz więzadła [limb.owner] w łączący hak!"),
		span_notice("[surgeon] przekształca więzadła [limb.owner] w łączący hak!"),
		span_notice("[surgeon] kończy manipulować więzadłami [limb.owner]."),
	)
	display_pain(limb.owner, "Kończyny są jakieś... dziwnie luźne.")

/datum/surgery_operation/limb/bioware/ligament_reinforcement
	name = "wzmocnienie więzadeł"
	rnd_name = "Artrorafia (wzmocnione więzadła)"
	desc = "Wzmacnia więzadła pacjenta, przez co kończyny trudno oderwać, ale łatwiej je unieruchomić obrażeniami."
	bioware_type = /datum/bioware/reinforced_ligaments

/datum/surgery_operation/limb/bioware/ligament_reinforcement/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz wzmacniać więzadła [limb.owner]."),
		span_notice("[surgeon] zaczyna wzmacniać więzadła [limb.owner]."),
		span_notice("[surgeon] zaczyna manipulować więzadłami [limb.owner]."),
	)
	display_pain(limb.owner, "Kończyny płoną potwornym bólem!")

/datum/surgery_operation/limb/bioware/ligament_reinforcement/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Wzmacniasz więzadła [limb.owner]!"),
		span_notice("[surgeon] wzmacnia więzadła [limb.owner]!"),
		span_notice("[surgeon] kończy manipulować więzadłami [limb.owner]."),
	)
	display_pain(limb.owner, "Kończyny trzymają się pewniej, ale są jakby bardziej kruche.")

// --- Kora mózgowa ---

/datum/surgery_operation/limb/bioware/cortex_folding
	name = "fałdowanie kory"
	rnd_name = "Encefalofraktoplastyka (fałdowanie kory)"
	desc = "Składa korę mózgową pacjenta we wzór fraktalny, robiąc miejsce na niestandardowe wzorce neuronowe."
	bioware_type = /datum/bioware/cortex_fold
	required_zone = BODY_ZONE_HEAD
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED

/datum/surgery_operation/limb/bioware/cortex_folding/state_check(obj/item/bodypart/limb)
	return ..() && limb.owner.getorganslot(ORGAN_SLOT_BRAIN)

/datum/surgery_operation/limb/bioware/cortex_folding/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz składać zewnętrzną korę mózgową [limb.owner] we wzór fraktalny."),
		span_notice("[surgeon] zaczyna składać zewnętrzną korę mózgową [limb.owner] we wzór fraktalny."),
		span_notice("[surgeon] zaczyna operację mózgu [limb.owner]."),
	)
	display_pain(limb.owner, "Głowa pulsuje okropnym bólem, ledwo da się to znieść!")

/datum/surgery_operation/limb/bioware/cortex_folding/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Składasz zewnętrzną korę mózgową [limb.owner] we wzór fraktalny!"),
		span_notice("[surgeon] składa zewnętrzną korę mózgową [limb.owner] we wzór fraktalny!"),
		span_notice("[surgeon] kończy operację mózgu [limb.owner]."),
	)
	display_pain(limb.owner, "Mózg jest silniejszy... i bardziej elastyczny!")

/datum/surgery_operation/limb/bioware/cortex_folding/on_failure(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	cortex_failure(limb, surgeon)

/datum/surgery_operation/limb/bioware/cortex_imprint
	name = "odciskanie kory"
	rnd_name = "Encefalopremoplastyka (odciśnięcie kory)"
	desc = "Rzeźbi korę mózgową pacjenta w samoodciskający się wzór, dzięki któremu mózg omija skutki lekkich urazów."
	bioware_type = /datum/bioware/cortex_imprint
	required_zone = BODY_ZONE_HEAD
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED

/datum/surgery_operation/limb/bioware/cortex_imprint/state_check(obj/item/bodypart/limb)
	return ..() && limb.owner.getorganslot(ORGAN_SLOT_BRAIN)

/datum/surgery_operation/limb/bioware/cortex_imprint/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("Zaczynasz rzeźbić zewnętrzną korę mózgową [limb.owner] w samoodciskający się wzór."),
		span_notice("[surgeon] zaczyna rzeźbić zewnętrzną korę mózgową [limb.owner] w samoodciskający się wzór."),
		span_notice("[surgeon] zaczyna operację mózgu [limb.owner]."),
	)
	display_pain(limb.owner, "Głowa pulsuje okropnym bólem, ledwo da się to znieść!")

/datum/surgery_operation/limb/bioware/cortex_imprint/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	display_results(
		surgeon,
		limb.owner,
		span_notice("Przekształcasz zewnętrzną korę mózgową [limb.owner] w samoodciskający się wzór!"),
		span_notice("[surgeon] przekształca zewnętrzną korę mózgową [limb.owner] w samoodciskający się wzór!"),
		span_notice("[surgeon] kończy operację mózgu [limb.owner]."),
	)
	display_pain(limb.owner, "Mózg jest silniejszy... i bardziej odporny!")

/datum/surgery_operation/limb/bioware/cortex_imprint/on_failure(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	cortex_failure(limb, surgeon)

/// Nieudana operacja kory: 60 uszkodzeń mózgu i ciężka trauma (jak stare fold_cortex/imprint_cortex)
/datum/surgery_operation/limb/bioware/proc/cortex_failure(obj/item/bodypart/limb, mob/living/surgeon)
	var/mob/living/carbon/patient = limb.owner
	if(!patient.getorganslot(ORGAN_SLOT_BRAIN))
		surgeon.visible_message(
			span_warning("[surgeon] nagle zauważa, że mózgu, nad którym pracował, już tam nie ma."),
			span_warning("Nagle zauważasz, że mózgu, nad którym pracowałeś, już tam nie ma."),
		)
		return
	display_results(
		surgeon,
		patient,
		span_warning("Partaczysz, uszkadzając mózg!"),
		span_warning("[surgeon] partaczy, uszkadzając mózg!"),
		span_notice("[surgeon] kończy operację mózgu [patient]."),
	)
	display_pain(patient, "Głowa pulsuje straszliwym bólem, myślenie boli!")
	patient.adjustOrganLoss(ORGAN_SLOT_BRAIN, 60)
	patient.gain_trauma_type(BRAIN_TRAUMA_SEVERE, TRAUMA_RESILIENCE_LOBOTOMY)
