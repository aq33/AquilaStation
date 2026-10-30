
/datum/design/implant_security_down
	name = "Security Officer Down Implant Case"
	desc = "A glass case containing an implant."
	id = "implant_security_down"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 500, /datum/material/glass = 500)
	build_path = /obj/item/implantcase/security_down
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY  // available only in the seclathe to stop medbay jokers from implanting non-secs

/datum/design/bluebutt
	name = "Butt of Holding"
	desc = "Syntetyczny pośladek z kieszenią bluespace. Pozwala też wypróżnić się na zawołanie prosto w bluespace."
	id = "bluebutt"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/silver = 1000, /datum/material/diamond = 500, /datum/material/bluespace = 1000)
	build_path = /obj/item/organ/butt/bluebutt
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

// AQUILA - projekty operacji odblokowują operacje nowego szkieletu (tgstation#93697, aquila/code/modules/surgery_tg/surgery_unlocks.dm).
// surgery to typ /datum/surgery_operation albo lista typów (ożywienie ma osobną wersję mechaniczną).
/datum/design/surgery/experimental_dissection
	surgery = /datum/surgery_operation/basic/dissection

/datum/design/surgery/lobotomy
	surgery = /datum/surgery_operation/organ/lobotomy

/datum/design/surgery/pacify
	surgery = /datum/surgery_operation/organ/pacify

/datum/design/surgery/viral_bonding
	surgery = /datum/surgery_operation/basic/viral_bonding

/datum/design/surgery/healing/brute_upgrade
	surgery = /datum/surgery_operation/basic/tend_wounds/upgraded

/datum/design/surgery/healing/brute_upgrade_2
	surgery = /datum/surgery_operation/basic/tend_wounds/upgraded/master

/datum/design/surgery/healing/burn_upgrade
	surgery = /datum/surgery_operation/basic/tend_wounds/upgraded

/datum/design/surgery/healing/burn_upgrade_2
	surgery = /datum/surgery_operation/basic/tend_wounds/upgraded/master

/datum/design/surgery/healing/combo
	surgery = /datum/surgery_operation/basic/tend_wounds/combo

/datum/design/surgery/healing/combo_upgrade
	surgery = /datum/surgery_operation/basic/tend_wounds/combo/upgraded

/datum/design/surgery/healing/combo_upgrade_2
	surgery = /datum/surgery_operation/basic/tend_wounds/combo/upgraded/master

/datum/design/surgery/revival
	surgery = list(/datum/surgery_operation/basic/revival, /datum/surgery_operation/basic/revival/mechanic)

/datum/design/surgery/brainwashing
	surgery = /datum/surgery_operation/organ/brainwash

/datum/design/surgery/nerve_splicing
	surgery = /datum/surgery_operation/limb/bioware/nerve_splicing

/datum/design/surgery/nerve_grounding
	surgery = /datum/surgery_operation/limb/bioware/nerve_grounding

/datum/design/surgery/vein_threading
	surgery = /datum/surgery_operation/limb/bioware/vein_threading

/datum/design/surgery/muscled_veins
	surgery = /datum/surgery_operation/limb/bioware/muscled_veins

/datum/design/surgery/ligament_hook
	surgery = /datum/surgery_operation/limb/bioware/ligament_hook

/datum/design/surgery/ligament_reinforcement
	surgery = /datum/surgery_operation/limb/bioware/ligament_reinforcement

/datum/design/surgery/cortex_imprint
	surgery = /datum/surgery_operation/limb/bioware/cortex_imprint

/datum/design/surgery/cortex_folding
	surgery = /datum/surgery_operation/limb/bioware/cortex_folding

/datum/design/surgery/necrotic_revival
	surgery = /datum/surgery_operation/limb/bionecrosis
