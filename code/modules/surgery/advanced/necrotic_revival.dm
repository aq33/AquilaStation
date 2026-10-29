/datum/surgery/advanced/necrotic_revival
	name = "Ożywienie nekrotyczne"
	desc = "Eksperymentalny zabieg chirurgiczny, który pobudza wzrost guza romerolowego w mózgu pacjenta. Wymaga Proszku zombie albo Rezadonu."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/saw,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/bionecrosis,
				/datum/surgery_step/close)

	possible_locs = list(BODY_ZONE_HEAD)

/datum/surgery/advanced/necrotic_revival/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	var/obj/item/organ/zombie_infection/ZI = target.getorganslot(ORGAN_SLOT_ZOMBIE)
	if(ZI)
		return FALSE

/datum/surgery_step/bionecrosis
	name = "rozpocznij bionekrozę"
	implements = list(/obj/item/reagent_containers/syringe = 100, /obj/item/pen = 30)
	time = 50
	chems_needed = list(/datum/reagent/toxin/zombiepowder, /datum/reagent/medicine/rezadone)
	require_all_chems = FALSE

/datum/surgery_step/bionecrosis/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Zaczynasz hodować guz romerolowy na mózgu [target]...</span>",
		"[user] zaczyna majstrować przy mózgu [target]...",
		"[user] zaczyna operację mózgu [target].")

/datum/surgery_step/bionecrosis/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>Udaje ci się wyhodować guz romerolowy na mózgu [target].</span>",
		"[user] pomyślnie hoduje guz romerolowy na mózgu [target]!",
		"[user] kończy operację mózgu [target].")
	if(!target.getorganslot(ORGAN_SLOT_ZOMBIE))
		var/obj/item/organ/zombie_infection/ZI = new()
		ZI.Insert(target)
	return TRUE
