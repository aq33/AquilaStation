// AQUILA - odpowiednik "eksperymentalnej wymiany organów" abduktorów (code/modules/antagonists/abductor/equipment/abduction_surgery.dm).
// W tg abduktorzy robią to zwykłymi operacjami w wersjach /abductor (przez ubranie, serce bez piłowania kości), które
// są w operation_generic.dm i operation_organ_manip.dm. Odblokowuje je gatunek albo implant abduktora (GLOB.abductor_operations
// w surgery_unlocks.dm); antagoniści abduktorów mają też TRAIT_SURGEON, który odblokowuje wszystko.
// Tu tylko gruczoł wkładany tą operacją dostaje Insert(special = 2), czyli nie startuje od razu (jak stary krok gland_insert).

/datum/surgery_operation/limb/organ_manipulation/internal/abductor/get_insert_special(obj/item/organ/organ)
	if(istype(organ, /obj/item/organ/heart/gland))
		return 2 // "special 2 means abductor surgery" (gland.dm)
	return ..()
