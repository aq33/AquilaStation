/////////////////////////////////////
//////////Limb Grower Designs ///////
/////////////////////////////////////

/datum/design/leftarm
	name = "Lewa ręka"
	id = "leftarm"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 25)
	build_path = /obj/item/bodypart/l_arm
	category = list("initial","human","lizard","moth","apid","plasmaman","ethereal")

/datum/design/rightarm
	name = "Prawa ręka"
	id = "rightarm"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 25)
	build_path = /obj/item/bodypart/r_arm
	category = list("initial","human","lizard","moth","apid","plasmaman","ethereal")

/datum/design/leftleg
	name = "Lewa noga"
	id = "leftleg"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 25)
	build_path = /obj/item/bodypart/l_leg
	category = list("initial","human","lizard","moth","apid","plasmaman","ethereal")

/datum/design/rightleg
	name = "Prawa noga"
	id = "rightleg"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 25)
	build_path = /obj/item/bodypart/r_leg
	category = list("initial","human","lizard","moth","apid","plasmaman","ethereal")

/datum/design/digi_leftleg
	name = "Lewa noga palcochodna"
	id = "digi_leftleg"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 30)
	build_path = /obj/item/bodypart/l_leg/digitigrade
	category = list("lizard")

/datum/design/digi_rightleg
	name = "Prawa noga palcochodna"
	id = "digi_rightleg"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 30)
	build_path = /obj/item/bodypart/r_leg/digitigrade
	category = list("lizard")

//Non-limb limb designs

//Heart
/datum/design/heart
	name = "Serce"
	id = "heart"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 30)
	build_path = /obj/item/organ/heart
	category = list("initial","human")

//Lungs
/datum/design/lungs
	name = "Płuca"
	id = "lungs"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 20)
	build_path = /obj/item/organ/lungs
	category = list("initial","human")

/datum/design/plasmaman_lungs
	name = "Filtr plazmy"
	id = "plasmamanlungs"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10, /datum/reagent/toxin/plasma = 20)
	build_path = /obj/item/organ/lungs/plasmaman
	category = list("plasmaman")

/datum/design/apid_lungs
	name = "Płuca apida"
	id = "apidlungs"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10, /datum/reagent/consumable/honey = 20)
	build_path = /obj/item/organ/lungs/apid
	category = list("apid")

//Liver
/datum/design/liver
	name = "Wątroba"
	id = "liver"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 20)
	build_path = /obj/item/organ/liver
	category = list("initial","human")

/datum/design/plasmaman_liver
	name = "Kryształ przetwarzający reagenty"
	id = "plasmamanliver"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10, /datum/reagent/toxin/plasma = 20)
	build_path = /obj/item/organ/liver/plasmaman
	category = list("plasmaman")

//Stomach
/datum/design/stomach
	name = "Żołądek"
	id = "stomach"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 15)
	build_path = /obj/item/organ/stomach
	category = list("initial","human")

/datum/design/plasmaman_stomach
	name = "Kryształ trawienny"
	id = "plasmamanstomach"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10, /datum/reagent/toxin/plasma = 20)
	build_path = /obj/item/organ/stomach/plasmaman
	category = list("plasmaman")

/datum/design/ethereal_stomach
	name = "Bateria biologiczna"
	id = "etherealstomach"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10, /datum/reagent/consumable/liquidelectricity = 20)
	build_path = /obj/item/organ/stomach/battery/ethereal
	category = list("ethereal")

//Appendix
/datum/design/appendix
	name = "Wyrostek robaczkowy"
	id = "appendix"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 5) //why would you need this
	build_path = /obj/item/organ/appendix
	category = list("initial","human")

//Eyes
/datum/design/eyes
	name = "Oczy"
	id = "eyes"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10)
	build_path = /obj/item/organ/eyes
	category = list("initial","human")

/datum/design/moth_eyes
	name = "Oczy ćmy"
	id = "motheyes"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 25)
	build_path = /obj/item/organ/eyes/moth
	category = list("moth")

/datum/design/apid_eyes
	name = "Oczy apida"
	id = "apideyes"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 25)
	build_path = /obj/item/organ/eyes/apid
	category = list("apid")

//Ears
/datum/design/ears
	name = "Uszy"
	id = "ears"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10)
	build_path = /obj/item/organ/ears
	category = list("initial","human")

/datum/design/cat_ears
	name = "Kocie uszy"
	id = "catears"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10)
	build_path = /obj/item/organ/ears/cat
	category = list("human")

//Tongues
/datum/design/tongue
	name = "Język"
	id = "tongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10)
	build_path = /obj/item/organ/tongue
	category = list("initial","other")

/datum/design/lizard_tongue
	name = "Rozwidlony język"
	id = "liztongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 20)
	build_path = /obj/item/organ/tongue/lizard
	category = list("other")

/datum/design/plasmaman_tongue
	name = "Plazmowy kostny język"
	id = "plasmamantongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10, /datum/reagent/toxin/plasma = 20)
	build_path = /obj/item/organ/tongue/bone/plasmaman
	category = list("other")

/datum/design/ethereal_tongue
	name = "Wyładowywacz elektryczny"
	id = "etherealtongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10, /datum/reagent/consumable/liquidelectricity = 20)
	build_path = /obj/item/organ/tongue/ethereal
	category = list("other")

/datum/design/apid_tongue
	name = "Trąbka"
	id = "apidtongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10, /datum/reagent/consumable/honey = 20)
	build_path = /obj/item/organ/tongue/bee
	category = list("other")

//Tails
/datum/design/lizard_tail
	name = "Jaszczurzy ogon"
	id = "liztail"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 20)
	build_path = /obj/item/organ/tail/lizard/fake
	category = list("lizard")

/datum/design/cat_tail
	name = "Koci ogon"
	id = "cattail"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 20)
	build_path = /obj/item/organ/tail/cat
	category = list("human")

//Wings
/datum/design/moth_wings
	name = "Skrzydła ćmy"
	id = "mothwings"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 25)
	build_path = /obj/item/organ/wings/moth
	category = list("moth")

/datum/design/apid_wings
	name = "Pszczele skrzydła"
	id = "apidwings"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 25)
	build_path = /obj/item/organ/wings/bee
	category = list("apid")


// Intentionally not growable by normal means - for balance conerns.

/datum/design/armblade
	name = "Syntetyczne ostrze ręczne"
	id = "armblade"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 75)
	build_path = /obj/item/melee/synthetic_arm_blade
	category = list("other","emagged")

/// Design disks and designs - for adding limbs and organs to the limbgrower.
/obj/item/disk/design_disk/limbs
	name = "dysk z projektami kończyn"
	desc = "Dysk z projektami kończyn i organów dla hodowli kończyn."
	icon_state = "datadisk1"
	/// List of all limb designs this disk contains.
	var/list/limb_designs = list()

/obj/item/disk/design_disk/limbs/Initialize()
	. = ..()
	max_blueprints = limb_designs.len
	for(var/design in limb_designs)
		var/datum/design/new_design = design
		blueprints += new new_design

/datum/design/limb_disk
	name = "Dysk z projektami kończyn"
	desc = "Zawiera projekty różnych kończyn."
	id = "limbdesign_parent"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100)
	build_path = /obj/item/disk/design_disk/limbs
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/obj/item/disk/design_disk/limbs/debug
	name = "dysk z projektami kończyn (debug)"
	desc = "Nie powinieneś tego mieć, chyba że coś debugujesz albo robisz adminbus."
	limb_designs = list(/datum/design/cat_tail, /datum/design/cat_ears,
		/datum/design/lizard_tail, /datum/design/lizard_tongue, /datum/design/digi_leftleg, /datum/design/digi_rightleg,
		/datum/design/apid_wings, /datum/design/apid_eyes, /datum/design/apid_lungs, /datum/design/apid_tongue,
		/datum/design/moth_wings, /datum/design/moth_eyes,
		/datum/design/plasmaman_stomach, /datum/design/plasmaman_liver, /datum/design/plasmaman_lungs, /datum/design/plasmaman_tongue,
		/datum/design/ethereal_stomach, /datum/design/ethereal_tongue)

/obj/item/disk/design_disk/limbs/felinid
	name = "dysk z projektami kończyn (felinid)"
	limb_designs = list(/datum/design/cat_tail, /datum/design/cat_ears)

/datum/design/limb_disk/felinid
	name = "Dysk z projektami kończyn (felinid)"
	desc = "Zawiera projekty części ciała felinidów dla hodowli kończyn: uszy i ogon."
	id = "limbdesign_felinid"
	build_path = /obj/item/disk/design_disk/limbs/felinid

/obj/item/disk/design_disk/limbs/lizard
	name = "dysk z projektami kończyn (jaszczur)"
	limb_designs = list(/datum/design/lizard_tail, /datum/design/lizard_tongue, /datum/design/digi_leftleg, /datum/design/digi_rightleg)

/datum/design/limb_disk/lizard
	name = "Dysk z projektami kończyn (jaszczur)"
	desc = "Zawiera projekty części ciała jaszczurów dla hodowli kończyn: język, ogon i nogi palcochodne."
	id = "limbdesign_lizard"
	build_path = /obj/item/disk/design_disk/limbs/lizard

/obj/item/disk/design_disk/limbs/apid
	name = "dysk z projektami kończyn (apid)"
	limb_designs = list(/datum/design/apid_wings, /datum/design/apid_eyes, /datum/design/apid_lungs, /datum/design/apid_tongue)

/datum/design/limb_disk/apid
	name = "Dysk z projektami kończyn (apid)"
	desc = "Zawiera projekty organów apidów dla hodowli kończyn: skrzydła, oczy, płuca i język."
	id = "limbdesign_apid"
	build_path = /obj/item/disk/design_disk/limbs/apid

/obj/item/disk/design_disk/limbs/moth
	name = "dysk z projektami kończyn (ćma)"
	limb_designs = list(/datum/design/moth_wings, /datum/design/moth_eyes)

/datum/design/limb_disk/moth
	name = "Dysk z projektami kończyn (ćma)"
	desc = "Zawiera projekty organów ciem dla hodowli kończyn: skrzydła i oczy."
	id = "limbdesign_moth"
	build_path = /obj/item/disk/design_disk/limbs/moth

/obj/item/disk/design_disk/limbs/plasmaman
	name = "dysk z projektami kończyn (plazmaman)"
	limb_designs = list(/datum/design/plasmaman_stomach, /datum/design/plasmaman_liver, /datum/design/plasmaman_lungs, /datum/design/plasmaman_tongue)

/datum/design/limb_disk/plasmaman
	name = "Dysk z projektami kończyn (plazmaman)"
	desc = "Zawiera projekty organów plazmaludzi dla hodowli kończyn: język, wątroba, żołądek i płuca."
	id = "limbdesign_plasmaman"
	build_path = /obj/item/disk/design_disk/limbs/plasmaman

/obj/item/disk/design_disk/limbs/ethereal
	name = "dysk z projektami kończyn (eteryk)"
	limb_designs = list(/datum/design/ethereal_stomach, /datum/design/ethereal_tongue)

/datum/design/limb_disk/ethereal
	name = "Dysk z projektami kończyn (eteryk)"
	desc = "Zawiera projekty organów eteryków dla hodowli kończyn: język i żołądek."
	id = "limbdesign_ethereal"
	build_path = /obj/item/disk/design_disk/limbs/ethereal
