// AQUILA - Złośliwy narząd: u losowej osoby z załogi wyrasta guz złośliwy, który w ciągu kilkunastu minut daje coraz cięższe objawy, dopóki lekarz go nie znajdzie i nie wytnie (port z CHOMPStation2/CHOMPStation2 modular_chomp/code/modules/event/spontaneous_malignant_organ.dm i modular_chomp/code/modules/organs/internal/malignant/malignant.dm)
// CHOMP grows a random malignant organ (one of several tumours, parasites or engineered organs, each with its own way of
// killing) in any organic limb of a random crew member who is not an antagonist. AquilaMed has no tumours (the only
// "tumours" in our code are the darkspawn thrall's and the living teratoma ghost role), so ours is one simple internal
// organ in its own slot: a malignant tumour in the chest, the groin or the head. It goes through four stages of about
// five minutes each (pain, nausea and toxins, weakness, then falls), shows on the health analyzer from stage two with
// the treatment, and is removed like any organ by organ manipulation of its zone (a removed tumour is dead: it no longer
// grows or does anything, even transplanted); no drug cures it. Only crew members
// with a client, an organic body and no antagonist role can get it; no announcement, as in CHOMP.

/// Szczelina narządu guza (jeden guz na osobę)
#define ORGAN_SLOT_AQUILA_TUMOR "aquila_tumor"

/datum/round_event_control/aquila_hex_spontaneous_malignant_organ
	name = "Złośliwy narząd"
	typepath = /datum/round_event/aquila_hex_spontaneous_malignant_organ
	weight = 8
	min_players = 10
	max_occurrences = 2
	earliest_start = 20 MINUTES

/datum/round_event/aquila_hex_spontaneous_malignant_organ
	fakeable = FALSE
	startWhen = 1

/datum/round_event/aquila_hex_spontaneous_malignant_organ/start()
	var/list/candidates = list()
	for(var/mob/living/carbon/human/person in GLOB.player_list)
		if(can_grow_in(person))
			candidates += person
	if(!length(candidates))
		log_game("Spontaneous Malignant Organ: no crew member can get a tumour, cancelling the event.")
		return kill()
	var/mob/living/carbon/human/patient = pick(candidates)
	var/obj/item/organ/aquila_hex_tumor/tumor = grow_tumor(patient)
	if(!tumor)
		return kill()
	message_admins("Złośliwy narząd: [ADMIN_LOOKUPFLW(patient)] ma guza ([strefa_pl(tumor.zone)]).")
	log_game("Spontaneous Malignant Organ: [key_name(patient)] got a malignant tumour in the [tumor.zone].")

/// Czy w tej osobie może wyrosnąć guz: żywa osoba z załogi z klientem, organicznym ciałem, bez roli antagonisty i bez guza
/datum/round_event/aquila_hex_spontaneous_malignant_organ/proc/can_grow_in(mob/living/carbon/human/person)
	if(!istype(person) || person.stat == DEAD || !person.client || !person.mind || is_special_character(person))
		return FALSE
	if(!(MOB_ORGANIC in person.mob_biotypes) || person.getorganslot(ORGAN_SLOT_AQUILA_TUMOR))
		return FALSE
	var/turf/person_turf = get_turf(person)
	return person_turf && is_station_level(person_turf.z)

/// Wszczepia guza w losową organiczną strefę (klatka, krocze, głowa); zwraca guza albo null
/datum/round_event/aquila_hex_spontaneous_malignant_organ/proc/grow_tumor(mob/living/carbon/human/patient)
	if(QDELETED(patient) || patient.getorganslot(ORGAN_SLOT_AQUILA_TUMOR))
		return null
	var/list/zones = list()
	for(var/zone in list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_HEAD))
		var/obj/item/bodypart/limb = patient.get_bodypart(check_zone(zone))
		if(limb && IS_ORGANIC_LIMB(limb))
			zones += zone
	if(!length(zones))
		return null
	var/obj/item/organ/aquila_hex_tumor/tumor = new
	tumor.zone = pick(zones)
	tumor.Insert(patient)
	return tumor

/**
 * Guz złośliwy: rośnie w czterech stadiach i daje coraz cięższe objawy. Wycina go operacja na organach jego strefy.
 */
/obj/item/organ/aquila_hex_tumor
	name = "guz złośliwy"
	desc = "Twarda, nieregularna narośl, która wyrosła z czyichś tkanek. Lepiej, że jest już na zewnątrz."
	icon_state = "innards"
	color = "#c99a8a"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_AQUILA_TUMOR
	organ_flags = NONE
	/// Stadium (1-4)
	var/stage = 1
	/// Postęp do następnego stadium (co Life() żywiciela, ok. 2 s)
	var/progress = 0
	/// Ile razy guz rośnie w jednym stadium (150 to ok. 5 minut)
	var/stage_length = 150
	/// Guz wycięty z ciała: już nie rośnie i nie daje objawów, także po przeszczepie
	var/dead = FALSE

/obj/item/organ/aquila_hex_tumor/Remove(mob/living/carbon/M, special = 0)
	if(!special)
		dead = TRUE
	return ..()

/obj/item/organ/aquila_hex_tumor/on_life()
	. = ..()
	if(dead || !owner || owner.stat == DEAD)
		return
	if(stage < 4 && ++progress >= stage_length)
		progress = 0
		stage++
		to_chat(owner, "<span class='warning'>Coś jest z tobą bardzo nie tak ([strefa_pl(zone)]).</span>")
	symptoms()

/// Objawy stadium guza
/obj/item/organ/aquila_hex_tumor/proc/symptoms()
	switch(stage)
		if(1)
			if(prob(2))
				to_chat(owner, "<span class='warning'>Czujesz tępy ból ([strefa_pl(zone)]).</span>")
		if(2)
			if(prob(3))
				to_chat(owner, "<span class='warning'>Robi ci się niedobrze.</span>")
				owner.adjustToxLoss(1)
		if(3)
			if(prob(4))
				owner.adjustToxLoss(1)
			if(prob(2))
				to_chat(owner, "<span class='danger'>Ogarnia cię nagła słabość.</span>")
				owner.adjustStaminaLoss(20)
		if(4)
			if(prob(5))
				owner.adjustToxLoss(2)
			if(prob(2))
				to_chat(owner, "<span class='userdanger'>Przeszywający ból ([strefa_pl(zone)]) zwala cię z nóg!</span>")
				owner.Knockdown(2 SECONDS)

/obj/item/organ/aquila_hex_tumor/aq_scan_line()
	if(dead || stage < 2)
		return null
	return "<b>Guz złośliwy ([strefa_pl(zone)]):</b> stadium [stage]/4. Usunąć operacją na organach ([strefa_pl(zone)])."

/obj/item/organ/aquila_hex_tumor/on_find(mob/living/finder)
	. = ..()
	to_chat(finder, "<span class='warning'>Znajdujesz twardą, nieregularną narośl ([strefa_pl(zone)]).</span>")

#undef ORGAN_SLOT_AQUILA_TUMOR
