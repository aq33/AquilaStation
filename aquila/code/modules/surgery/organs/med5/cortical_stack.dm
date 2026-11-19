// AQUILA - stos korowy (AquilaMed 5, etap 11). Pomysł i sprite z Baystation12 (icons/obj/organs.dmi "cortical-stack",
// CC BY-SA 3.0). Stos u podstawy czaszki zapisuje umysł nosiciela, a konsola klonowania odczytuje umysł tylko ze stosu:
// bez niego sklonować da się wyłącznie samo ciało (skan ciała, β). Ma go każdy z ras z krwią od startu, cecha
// „Bez stosu korowego” w preferencjach go zabiera. Medyk drukuje nowy stos w protolathe i wszczepia go operacją
// na narządach głowy. Konsola eksperymentalna (bez warunków umysłu) dalej działa po swojemu.

/obj/item/organ/cortical_stack
	name = "stos korowy"
	desc = "Mały implant u podstawy czaszki. Na bieżąco zapisuje umysł nosiciela, a bez niego klonowanie nie ma z czego odtworzyć osobowości."
	icon = 'aquila/icons/obj/medical/cortical_stack.dmi'
	icon_state = "cortical-stack"
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_CORTICAL_STACK
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC
	w_class = WEIGHT_CLASS_TINY
	/// Whose mind it holds, set when it leaves a body
	var/recorded_name

/obj/item/organ/cortical_stack/Remove(mob/living/carbon/M, special = 0)
	if(M?.real_name)
		recorded_name = M.real_name
	return ..()

/obj/item/organ/cortical_stack/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	recorded_name = null
	return ..()

/obj/item/organ/cortical_stack/examine(mob/user)
	. = ..()
	if(recorded_name)
		. += "<span class='notice'>Ostatni zapisany umysł: [recorded_name].</span>"

/obj/item/organ/cortical_stack/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_SELF))
		applyOrganDamage(20 / severity)

/datum/species
	var/obj/item/organ/cortical_stack/mutantcorticalstack = /obj/item/organ/cortical_stack

/// The cloning console reads the mind only from a stack
/obj/machinery/computer/cloning/can_scan(datum/dna/dna, mob/living/mob_occupant, datum/bank_account/account, body_only)
	. = ..()
	if(!. || body_only || experimental || !ishuman(mob_occupant))
		return
	var/mob/living/carbon/human/H = mob_occupant
	if(!H.dna?.species?.aq_has_med5_organs() || H.getorganslot(ORGAN_SLOT_CORTICAL_STACK))
		return
	scantemp = "Brak stosu korowego: nie ma z czego odczytać umysłu. Da się zeskanować tylko samo ciało."
	playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
	return FALSE

/datum/quirk/no_cortical_stack
	name = "Bez stosu korowego"
	desc = "Nie masz stosu korowego. Po śmierci da się cię ożywić, ale nie sklonować, chyba że medyk wszczepi ci nowy stos."
	value = 0
	gain_text = "<span class='notice'>Nie masz stosu korowego. Jeśli zginiesz, klonowanie cię nie wskrzesi.</span>"
	lose_text = "<span class='notice'>Myśl o stosie korowym przestaje cię niepokoić.</span>"
	medical_record_text = "Pacjent nie ma stosu korowego: nie da się go sklonować."
	icon = "ban"

/datum/quirk/no_cortical_stack/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/cortical_stack/stack = H.getorganslot(ORGAN_SLOT_CORTICAL_STACK)
	if(stack)
		stack.Remove(H, TRUE)
		qdel(stack)

/datum/design/aq_cortical_stack
	name = "Stos korowy"
	desc = "Pusty stos korowy do wszczepienia u podstawy czaszki. Bez niego nie da się kogoś sklonować."
	id = "aq_cortical_stack"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(/datum/material/iron = 300, /datum/material/glass = 300, /datum/material/silver = 200, /datum/material/gold = 100)
	build_path = /obj/item/organ/cortical_stack
	category = list("Medical Designs", "Cybernetics")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/techweb_node/biotech/New()
	. = ..()
	design_ids += list("aq_cortical_stack", "aq_prosthetic_teeth", "aq_gold_teeth")
