// AQUILA - implant tłumacza (AquilaMed 5, etap 12). Alternatywa dla czipu w słuchawkach (translator_chip.dm): wszczepiony
// w głowę tłumaczy zawsze, bez słuchawek na uszach. Obcokrajowiec, który zaczyna rundę bez słuchawek, dostaje go od razu
// zamiast tłumacza kieszonkowego (foreigner.dm). Drukuje go protolathe medyczny, wszczepia operacja na narządach głowy.
// EMP wyłącza go na minutę, jak tłumacz kieszonkowy.

/obj/item/organ/cyberimp/brain/aq_translator
	name = "implant tłumacza"
	desc = "Implant w płacie skroniowym. Przekłada mowę między angielskim i polskim bez słuchawek na uszach."
	icon = 'aquila/icons/obj/translator_chip.dmi'
	icon_state = "translator_chip"
	slot = ORGAN_SLOT_AQ_TRANSLATOR
	implant_color = "#4FA3D1"
	/// Off for a minute after an EMP
	var/rebooting = FALSE

/obj/item/organ/cyberimp/brain/aq_translator/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	if(!rebooting)
		M.aq_translator_on(REF(src))

/obj/item/organ/cyberimp/brain/aq_translator/Remove(mob/living/carbon/M, special = 0)
	M?.aq_translator_off(REF(src))
	return ..()

/obj/item/organ/cyberimp/brain/aq_translator/emp_act(severity)
	. = ..()
	if((. & EMP_PROTECT_SELF) || rebooting || !owner)
		return
	rebooting = TRUE
	owner.aq_translator_off(REF(src))
	to_chat(owner, "<span class='warning'>Implant tłumacza piszczy w głowie i milknie.</span>")
	addtimer(CALLBACK(src, PROC_REF(aq_reboot_done)), 1 MINUTES)

/obj/item/organ/cyberimp/brain/aq_translator/proc/aq_reboot_done()
	rebooting = FALSE
	if(owner)
		owner.aq_translator_on(REF(src))
		to_chat(owner, "<span class='notice'>Implant tłumacza znowu działa.</span>")

/datum/design/aq_translator_implant
	name = "Implant tłumacza"
	desc = "Wszczepiany tłumacz angielskiego, działa bez słuchawek."
	id = "aq_translator_implant"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 300, /datum/material/glass = 300, /datum/material/gold = 100)
	build_path = /obj/item/organ/cyberimp/brain/aq_translator
	category = list("Medical Designs", "Cybernetics")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/techweb_node/cyber_organs/New()
	. = ..()
	design_ids += list("aq_translator_implant")
