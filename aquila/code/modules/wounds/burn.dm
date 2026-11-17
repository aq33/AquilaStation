// AQUILA - burn wounds: dead skin gets infected unless the burn is dressed with mesh.
// Since AquilaMed 5 the infection is the germs of the limb (medical/germs.dm): an undressed burn lets them in (germ_rate),
// a third degree burn the fastest, and the fever and sepsis come from the germs.

/datum/wound/burn
	wound_type = WOUND_BURN

/// The moment the burn starts to fester
/datum/wound/burn/wound_effects(delta_time)
	if(!treated && limb.aq_germs >= 30 && limb.aq_germs - germ_rate * delta_time < 30)
		to_chat(victim, "<span class='userdanger'>Oparzenie ([limb.name]) ropieje i cuchnie, czujesz gorączkę!</span>")

/datum/wound/burn/can_treat_with(obj/item/item)
	return !treated && istype(item, /obj/item/stack/medical/mesh)

/datum/wound/burn/treat(obj/item/stack/medical/dressing, mob/user)
	var/self = user == victim
	user.visible_message("<span class='notice'>[user] zaczyna opatrywać oparzenie ([limb.name]) [victim].</span>", "<span class='notice'>Zaczynasz opatrywać oparzenie ([limb.name])[self ? "" : " [victim]"].</span>")
	if(!do_mob(user, victim, self ? 5 SECONDS : 2 SECONDS))
		return FALSE
	if(QDELETED(src) || treated || !dressing.use(1))
		return FALSE
	treated = TRUE
	victim.aq_medical_overlays_changed() // dressing (medical_overlays.dm)
	if(istype(dressing, /obj/item/stack/medical/mesh/advanced))
		heal_time = max(heal_time, 2 MINUTES)
	user.visible_message("<span class='green'>[user] opatruje oparzenie ([limb.name]) [victim].</span>", "<span class='green'>Opatrujesz oparzenie ([limb.name]).</span>")
	return TRUE

/datum/wound/burn/second_degree
	name = "Oparzenie drugiego stopnia"
	desc = "Skóra pokrywa ci się pęcherzami"
	examine_desc = "poparzoną skórę w pęcherzach"
	treat_text = "Opatrz siatką, spaceacillin hamuje zakażenie."
	severity = WOUND_SEVERITY_SEVERE
	threshold = 80
	heal_time = 2 MINUTES

/datum/wound/burn/third_degree
	name = "Oparzenie trzeciego stopnia"
	desc = "Skóra zwęgla ci się do mięsa"
	examine_desc = "zwęgloną skórę"
	treat_text = "Opatrz siatką, by zatrzymać zakażenie, potem operacja usunięcia martwej tkanki. Zaawansowana siatka goi samodzielnie."
	severity = WOUND_SEVERITY_CRITICAL
	threshold = 140

