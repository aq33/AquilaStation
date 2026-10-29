// AQUILA - modyfikacje ciała z operacji bioware (/datum/bioware), przeniesione z code/modules/surgery/advanced/bioware/
// razem ze starym szkieletem chirurgii. Operacje, które je nakładają, są w operation_bioware.dm.
// Destroy(): on_lose() tylko przy żywym właścicielu, owner zerowany po on_lose() (wcześniej AQ EDIT w core, runtime null.physiology).

/datum/bioware
	var/name = "Generic Bioware"
	var/mob/living/carbon/human/owner
	var/desc = "If you see this something's wrong, warn a coder."
	var/active = FALSE
	var/can_process = FALSE
	var/mod_type = BIOWARE_GENERIC

/datum/bioware/New(mob/living/carbon/human/_owner)
	owner = _owner
	for(var/datum/bioware/bioware as anything in owner.bioware)
		if(bioware.mod_type == mod_type)
			qdel(src)
			return
	owner.bioware += src
	on_gain()

/datum/bioware/Destroy()
	if(active && !QDELETED(owner))
		on_lose()
	owner = null
	return ..()

/datum/bioware/proc/on_gain()
	active = TRUE
	if(can_process)
		START_PROCESSING(SSobj, src)

/datum/bioware/proc/on_lose()
	STOP_PROCESSING(SSobj, src)
	return

/datum/bioware/threaded_veins
	name = "Threaded Veins"
	desc = "The circulatory system is woven into a mesh, severely reducing the amount of blood lost from wounds."
	mod_type = BIOWARE_CIRCULATION

/datum/bioware/threaded_veins/on_gain()
	..()
	owner.physiology.bleed_mod *= 0.25

/datum/bioware/threaded_veins/on_lose()
	..()
	owner.physiology.bleed_mod *= 4

/datum/bioware/muscled_veins
	name = "Threaded Veins"
	desc = "The circulatory system is woven into a mesh, severely reducing the amount of blood lost from wounds."
	mod_type = BIOWARE_CIRCULATION

/datum/bioware/muscled_veins/on_gain()
	..()
	ADD_TRAIT(owner, TRAIT_STABLEHEART, "muscled_veins")

/datum/bioware/muscled_veins/on_lose()
	..()
	REMOVE_TRAIT(owner, TRAIT_STABLEHEART, "muscled_veins")

/datum/bioware/spliced_nerves
	name = "Spliced Nerves"
	desc = "Nerves are connected to each other multiple times, greatly reducing the impact of stunning effects."
	mod_type = BIOWARE_NERVES

/datum/bioware/spliced_nerves/on_gain()
	..()
	owner.physiology.stun_mod *= 0.5

/datum/bioware/spliced_nerves/on_lose()
	..()
	owner.physiology.stun_mod *= 2

/datum/bioware/grounded_nerves
	name = "Grounded Nerves"
	desc = "Nerves form a safe path for electricity to traverse, protecting the body from electric shocks."
	mod_type = BIOWARE_NERVES

/datum/bioware/grounded_nerves/on_gain()
	..()
	ADD_TRAIT(owner, TRAIT_SHOCKIMMUNE, "grounded_nerves")

/datum/bioware/grounded_nerves/on_lose()
	..()
	REMOVE_TRAIT(owner, TRAIT_SHOCKIMMUNE, "grounded_nerves")

/datum/bioware/hooked_ligaments
	name = "Hooked Ligaments"
	desc = "The ligaments and nerve endings that connect the torso to the limbs are formed into a hook-like shape, so limbs can be attached without requiring surgery, but are easier to sever."
	mod_type = BIOWARE_LIGAMENTS

/datum/bioware/hooked_ligaments/on_gain()
	..()
	ADD_TRAIT(owner, TRAIT_LIMBATTACHMENT, "ligament_hook")
	ADD_TRAIT(owner, TRAIT_EASYDISMEMBER, "ligament_hook")

/datum/bioware/hooked_ligaments/on_lose()
	..()
	REMOVE_TRAIT(owner, TRAIT_LIMBATTACHMENT, "ligament_hook")
	REMOVE_TRAIT(owner, TRAIT_EASYDISMEMBER, "ligament_hook")

/datum/bioware/reinforced_ligaments
	name = "Reinforced Ligaments"
	desc = "The ligaments and nerve endings that connect the torso to the limbs are protected by a mix of bone and tissues, and are much harder to separate from the body, but are also easier to disable."
	mod_type = BIOWARE_LIGAMENTS

/datum/bioware/reinforced_ligaments/on_gain()
	..()
	ADD_TRAIT(owner, TRAIT_NODISMEMBER, "reinforced_ligaments")
	ADD_TRAIT(owner, TRAIT_EASYLIMBDISABLE, "reinforced_ligaments")

/datum/bioware/reinforced_ligaments/on_lose()
	..()
	REMOVE_TRAIT(owner, TRAIT_NODISMEMBER, "reinforced_ligaments")
	REMOVE_TRAIT(owner, TRAIT_EASYLIMBDISABLE, "reinforced_ligaments")

/datum/bioware/cortex_fold
	name = "Cortex Fold"
	desc = "The cerebral cortex has been folded into a complex fractal pattern, and can support non-standard neural patterns."
	mod_type = BIOWARE_CORTEX

/datum/bioware/cortex_fold/on_gain()
	. = ..()
	ADD_TRAIT(owner, TRAIT_SPECIAL_TRAUMA_BOOST, EXPERIMENTAL_SURGERY_TRAIT)

/datum/bioware/cortex_fold/on_lose()
	REMOVE_TRAIT(owner, TRAIT_SPECIAL_TRAUMA_BOOST, EXPERIMENTAL_SURGERY_TRAIT)
	return ..()

/datum/bioware/cortex_imprint
	name = "Cortex Imprint"
	desc = "The cerebral cortex has been reshaped into a redundant neural pattern, making the brain able to bypass impediments caused by minor brain traumas."
	mod_type = BIOWARE_CORTEX
	can_process = TRUE

/datum/bioware/cortex_imprint/process()
	owner.cure_trauma_type(resilience = TRAUMA_RESILIENCE_BASIC)
