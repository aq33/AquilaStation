// AQUILA - odblokowywanie zablokowanych operacji (OPERATION_LOCKED), tg code/modules/surgery/surgery_disks.dm i
// code/game/machinery/computer/operating_computer.dm (tgstation#93697).
// Dyski (/obj/item/disk/surgery), zbadane projekty (/datum/design/surgery) i listy advanced_surgeries (komputer operacyjny,
// procesor chirurgiczny borga, implant linkedsurgery) trzymają typy operacji (/datum/surgery_operation/...).
// W tg dopisują je sygnały COMSIG_LIVING_OPERATING_ON / COMSIG_ATOM_BEING_OPERATED_ON (stół, procesor, implant, abduktor).
// U nas stół i łóżko stazy nie śledzą pacjenta sygnałami, więc źródła zbiera jedna procka, jak dawne /datum/surgery/proc/can_start.
// Sygnały zostają: dopisane przez nie typy też działają.

/// Wersje operacji dla abduktorów (przez ubranie, serce bez piłowania kości). Odpowiednik starej "eksperymentalnej wymiany organów".
GLOBAL_LIST_INIT(abductor_operations, list(
	/datum/surgery_operation/limb/incise_skin/abductor,
	/datum/surgery_operation/limb/retract_skin/abductor,
	/datum/surgery_operation/limb/close_skin/abductor,
	/datum/surgery_operation/limb/clamp_bleeders/abductor,
	/datum/surgery_operation/limb/unclamp_bleeders/abductor,
	/datum/surgery_operation/limb/incise_organs/abductor,
	/datum/surgery_operation/limb/organ_manipulation/internal/abductor,
))

/**
 * Zablokowane operacje, które chirurg może teraz zrobić na tym pacjencie
 *
 * Źródła: TRAIT_SURGEON (abduktorzy, wszystko), gatunek albo implant abduktora, procesor chirurgiczny borga,
 * implant linkedsurgery, komputer operacyjny podpięty do stołu albo łóżka stazy, na którym leży pacjent.
 */
/mob/living/proc/get_unlocked_operations(atom/movable/operating_on)
	if(HAS_TRAIT(src, TRAIT_SURGEON) || (mind && HAS_TRAIT(mind, TRAIT_SURGEON)))
		return GLOB.operations.locked.Copy()

	var/list/unlocked = list()
	if(can_abductor_organ_extraction())
		unlocked |= GLOB.abductor_operations
	if(iscyborg(src))
		var/mob/living/silicon/robot/robot = src
		var/obj/item/surgical_processor/processor = locate() in robot.module?.modules
		if(processor)
			unlocked |= processor.advanced_surgeries
	if(iscarbon(src))
		var/mob/living/carbon/carbon_self = src
		var/obj/item/organ/cyberimp/brain/linkedsurgery/implant = carbon_self.getorganslot(ORGAN_SLOT_BRAIN_SURGICAL_IMPLANT)
		if(istype(implant))
			unlocked |= implant.advanced_surgeries
	var/turf/patient_turf = get_turf(operating_on)
	if(patient_turf)
		var/obj/structure/table/optable/table = locate() in patient_turf
		if(table?.computer && !(table.computer.machine_stat & (NOPOWER|BROKEN)))
			unlocked |= table.computer.advanced_surgeries
		var/obj/machinery/stasis/stasis_bed = locate() in patient_turf
		if(stasis_bed?.op_computer && !(stasis_bed.op_computer.machine_stat & (NOPOWER|BROKEN)))
			unlocked |= stasis_bed.op_computer.advanced_surgeries
	return unlocked & GLOB.operations.locked

/// Czy chirurg może robić operacje abduktorów (te same warunki co stare /datum/surgery/organ_extraction/can_start)
/mob/living/proc/can_abductor_organ_extraction()
	if(!ishuman(src))
		return FALSE
	var/mob/living/carbon/human/human_self = src
	if(isabductor(human_self))
		return TRUE
	return !!(locate(/obj/item/implant/abductor) in human_self.implants)

// --- Dyski ---
// Bazowy dysk i dysk debugowy przeniesione z code/modules/surgery/surgery.dm razem ze starym szkieletem.

/obj/item/disk/surgery
	name = "Surgery Procedure Disk"
	desc = "A disk that contains advanced surgery procedures, must be loaded into an Operating Console."
	icon_state = "datadisk1"
	materials = list(/datum/material/iron=300, /datum/material/glass=100)
	/// Typy operacji (/datum/surgery_operation/...) odblokowywane przez dysk
	var/list/surgeries

/obj/item/disk/surgery/debug
	name = "Debug Surgery Disk"
	desc = "A disk that contains all existing surgery procedures."

/obj/item/disk/surgery/debug/Initialize(mapload)
	. = ..()
	surgeries = GLOB.operations.locked.Copy() // tg: wszystkie operacje, odblokowane i tak są dostępne

/obj/item/disk/surgery/brainwashing
	name = "Brainwashing Surgery Disk"
	desc = "The disk provides instructions on how to impress an order on a brain, making it the primary objective of the patient."
	surgeries = list(/datum/surgery_operation/organ/brainwash)

/obj/item/disk/surgery/examine(mob/user)
	. = ..()
	var/list/names = list()
	for(var/datum/surgery_operation/operation as anything in GLOB.operations.get_instances_from(surgeries, filter_replaced = FALSE))
		names += capitalize(operation.rnd_name || operation.name)
	if(length(names))
		. += span_info("Odblokowuje operacje: [english_list(names)].")
