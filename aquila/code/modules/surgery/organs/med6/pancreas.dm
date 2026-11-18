// AQUILA - trzustka (AquilaMed 6, etap 1). Port z Goonstation (code/obj/item/organs/pancreas.dm), sprite'y
// z icons/obj/items/organs/pancreas.dmi (CC BY-NC-SA 3.0).
// - Zdrowa trzustka wydziela insulinę: cukier we krwi schodzi szybko. Duży nadmiar cukru ją przeciąża i uszkadza.
// - Bez trzustki albo z niewydolną cukier schodzi cztery razy wolniej: po słodyczach rośnie hiperglikemia (senność,
//   mdłości, rozmazany wzrok), a powyżej progu przedawkowania cukru wstrząs hiperglikemiczny. Ratuje insulina albo
//   przeszczep. Niewydolna trzustka trawi też samą siebie (powolne obrażenia toksyczne).
// - Cybernetyczna działa jak zdrowa. Po emagu przestaje wydzielać insulinę i dosypuje do krwi efedrynę i epinefrynę.
// Różnica względem Goona: tam trzustka dodaje insulinę dopiero przy przedawkowaniu cukru, a jej brak niczego nie
// zmienia. U nas cukier i tak metabolizuje się sam, więc trzustka steruje tempem jego spalania.

/obj/item/organ/pancreas
	name = "trzustka"
	desc = "Gruczoł pod żołądkiem. Wydziela insulinę, dzięki której organizm spala cukier."
	icon = 'aquila/icons/obj/medical/organs_med6.dmi'
	icon_state = "pancreas"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_PANCREAS
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY
	low_threshold_passed = "<span class='info'>Coś ćmi cię pod żebrami, ból promieniuje do pleców.</span>"
	high_threshold_passed = "<span class='warning'>Ból pod żebrami jest coraz ostrzejszy, robi ci się niedobrze.</span>"
	now_failing = "<span class='danger'>Pod żebrami pali cię żywym ogniem. Trzustka przestaje pracować.</span>"
	now_fixed = "<span class='info'>Ból pod żebrami mija.</span>"
	/// Multiplier of sugar burning when healthy
	var/sugar_clearance = 1

/obj/item/organ/pancreas/cybernetic
	name = "trzustka cybernetyczna"
	desc = "Mechaniczny dozownik insuliny. Działa jak zdrowa trzustka i nie przeciąża się od cukru, ale impuls EMP potrafi go uszkodzić."
	icon_state = "pancreas-cyber"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC
	maxHealth = STANDARD_ORGAN_THRESHOLD * 1.5

/obj/item/organ/pancreas/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	applyOrganDamage(25 / severity)

/obj/item/organ/pancreas/cybernetic/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user, "<span class='warning'>Zdejmujesz ograniczniki z [src].</span>")

/// How fast sugar burns, 1 = healthy; no or failed pancreas burns it at a quarter
/obj/item/organ/pancreas/proc/aq_sugar_clearance()
	if((organ_flags & ORGAN_FAILING) || (obj_flags & EMAGGED))
		return 0.25
	return max(0.25, sugar_clearance * (1 - 0.75 * damage / maxHealth))

/obj/item/organ/pancreas/on_life()
	. = ..()
	if(!owner || owner.stat == DEAD || !owner.reagents)
		return
	var/sugar = owner.reagents.get_reagent_amount(/datum/reagent/consumable/sugar)
	if(obj_flags & EMAGGED)
		for(var/stim in list(/datum/reagent/medicine/ephedrine, /datum/reagent/medicine/epinephrine))
			if(owner.reagents.get_reagent_amount(stim) < 10)
				owner.reagents.add_reagent(stim, 1)
	// Duży nadmiar cukru przeciąża żywą trzustkę
	else if(sugar > 80 && !(organ_flags & ORGAN_SYNTHETIC))
		applyOrganDamage(sugar > 160 ? 1 : 0.3)
	if(organ_flags & ORGAN_FAILING)
		if(owner.getToxLoss() < 50)
			owner.adjustToxLoss(0.2)

/obj/item/organ/pancreas/aq_scan_line()
	var/sugar = owner?.reagents?.get_reagent_amount(/datum/reagent/consumable/sugar)
	if(sugar > AQ_HYPERGLYCEMIA_SUGAR && aq_sugar_clearance() < 0.6)
		return "<b>Hiperglikemia:</b> [round(sugar, 1)] j. cukru we krwi, trzustka nie nadąża. Podaj insulinę."

/// Sugar burning speed of this body (1 = healthy pancreas)
/mob/living/carbon/proc/aq_sugar_clearance()
	var/mob/living/carbon/human/H = src
	if(!istype(H) || !H.dna?.species?.mutantpancreas || !H.dna.species.aq_has_med5_organs())
		return 1
	var/obj/item/organ/pancreas/pancreas = getorganslot(ORGAN_SLOT_PANCREAS)
	return pancreas ? pancreas.aq_sugar_clearance() : 0.25

/datum/reagent/consumable/sugar/on_mob_life(mob/living/carbon/M)
	var/clearance = M.aq_sugar_clearance()
	metabolization_rate = initial(metabolization_rate) * clearance
	if(clearance < 0.6 && volume > AQ_HYPERGLYCEMIA_SUGAR)
		M.drowsyness = max(M.drowsyness, 3)
		M.blur_eyes(2)
		if(prob(5))
			to_chat(M, "<span class='warning'>[pick("Strasznie chce ci się pić.", "Robi ci się niedobrze od słodkości.", "Oczy same ci się zamykają.")]</span>")
	return ..()

/datum/design/cybernetic_pancreas
	name = "Trzustka cybernetyczna"
	desc = "Mechaniczny dozownik insuliny zamiast trzustki."
	id = "aq_cybernetic_pancreas"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 400, /datum/material/glass = 400, /datum/material/silver = 100)
	build_path = /obj/item/organ/pancreas/cybernetic
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL
