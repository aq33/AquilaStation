// AQUILA - wrzody żołądka. Śmieciowe jedzenie (JUNKFOOD, FRIED, smażone w głębokim tłuszczu, wszystko z automatu) i słodkie
// napoje gazowane podnoszą kwas w żołądku. Zdrowe jedzenie i mleko go zbijają. Długo wysoki kwas robi wrzód: nadżerki, wrzód,
// krwawiący wrzód. Stres przyspiesza narastanie. Same wrzody nie zabijają: uszkodzenie żołądka ma sufit niżej niż niewydolność.
// Goją się same bez śmieciowego jedzenia, szybciej z mlekiem, szybko z Omeprazolem. Krwawiący wrzód wycina gastrektomia.

/// Kwas za jednostkę zjedzonego śmieciowego jedzenia (paczka chipsów to 5 j.)
#define AQ_ACID_PER_JUNK_UNIT 4
/// O ile jednostka warzyw, owoców albo nabiału zbija kwas
#define AQ_ACID_PER_HEALTHY_UNIT 2
/// Ile kwasu znika na tick (2 s)
#define AQ_ACID_DECAY 0.02
/// Od jakiego kwasu rośnie wrzód
#define AQ_ACID_ULCER_START 50
/// Poniżej jakiego kwasu wrzód się goi
#define AQ_ACID_HEAL_BELOW 20
/// Ile wrzodu goi się samo na tick
#define AQ_ULCER_NATURAL_HEAL 0.02
/// Ile wrzodu goi Omeprazol na tick
#define AQ_ULCER_DRUG_HEAL 0.5
/// Co ile najwyżej pali po podrażnieniu
#define AQ_ULCER_IRRITATION_COOLDOWN (30 SECONDS)

/obj/item/organ/stomach
	/// Kwas i podrażnienie śluzówki od śmieciowego jedzenia, 0-100
	var/aq_acid = 0
	/// Wrzody, 0-100 (progi AQ_ULCER_STAGE_*)
	var/aq_ulcer = 0
	/// Do kiedy mleko osłania żołądek
	var/aq_soothed_until = 0
	/// Do kiedy żołądek pali po podrażnieniu (dodatkowy ból)
	var/aq_irritated_until = 0
	var/aq_next_ulcer_message = 0

/// Czy ten żołądek może mieć wrzody: tylko organiczny, nie bateria
/obj/item/organ/stomach/proc/aq_can_ulcer()
	return status == ORGAN_ORGANIC && !(organ_flags & ORGAN_SYNTHETIC) && !istype(src, /obj/item/organ/stomach/battery)

/// Stadium wrzodów: 0 brak, 1 nadżerki, 2 wrzód, 3 krwawiący wrzód
/obj/item/organ/stomach/proc/aq_ulcer_stage()
	if(aq_ulcer >= AQ_ULCER_STAGE_3)
		return 3
	if(aq_ulcer >= AQ_ULCER_STAGE_2)
		return 2
	if(aq_ulcer >= AQ_ULCER_STAGE_1)
		return 1
	return 0

/// Ból od wrzodów, dokładany do bólu z ciała
/obj/item/organ/stomach/proc/aq_ulcer_pain()
	switch(aq_ulcer_stage())
		if(1)
			. = 5
		if(2)
			. = 12
		if(3)
			. = 20
	if(. && world.time < aq_irritated_until)
		. += 10

/// Podrażnienie wrzodu (śmieciowe jedzenie, ostre, alkohol): pieczenie, przy wrzodzie czasem wymioty
/obj/item/organ/stomach/proc/aq_irritate(mob/living/carbon/human/H)
	var/stage = aq_ulcer_stage()
	if(!stage || world.time < aq_irritated_until)
		return
	aq_irritated_until = world.time + AQ_ULCER_IRRITATION_COOLDOWN
	to_chat(H, "<span class='warning'>Pali cię w żołądku.</span>")
	if(stage >= 2 && prob(25))
		H.vomit(10, FALSE, FALSE)

/// Kwas i gojenie co tick
/obj/item/organ/stomach/proc/aq_ulcer_tick(mob/living/carbon/human/H)
	var/drug = H.reagents?.has_reagent(/datum/reagent/medicine/aq_omeprazole)
	var/soothed = world.time < aq_soothed_until
	var/acid_decay = AQ_ACID_DECAY
	if(drug)
		acid_decay = 5
	else if(soothed)
		acid_decay *= 3
	aq_acid = max(aq_acid - acid_decay, 0)
	if(aq_acid > AQ_ACID_ULCER_START)
		var/growth = (aq_acid - AQ_ACID_ULCER_START) / 400
		var/datum/component/mood/mood = H.GetComponent(/datum/component/mood)
		if(mood && mood.sanity <= SANITY_DISTURBED)
			growth *= 1.5 // stres
		aq_ulcer = min(aq_ulcer + growth, 100)
	else if(aq_ulcer > 0 && aq_acid < AQ_ACID_HEAL_BELOW)
		var/heal = AQ_ULCER_NATURAL_HEAL
		if(drug)
			heal = AQ_ULCER_DRUG_HEAL
		else if(soothed)
			heal *= 3
		aq_ulcer = max(aq_ulcer - heal, 0)
	var/stage = aq_ulcer_stage()
	if(!stage)
		return
	// Uszkodzenie żołądka rośnie do sufitu stadium. Przy krwawiącym wrzodzie sufit jest nad dolnym progiem,
	// więc żołądek nie utrzymuje dużo jedzenia (stomach.dm), ale daleko do niewydolności.
	var/cap = 0
	if(stage >= 3)
		cap = low_threshold + 5
	else if(stage == 2)
		cap = low_threshold - 1
	if(damage < cap)
		applyOrganDamage(min(0.3, cap - damage))
	if(stage >= 3)
		if(H.blood_volume > BLOOD_VOLUME_SAFE && !(NOBLOOD in H.dna.species.species_traits) && !HAS_TRAIT(H, TRAIT_NO_BLOOD))
			H.blood_volume -= 0.1
		if(prob(1))
			H.vomit(10, TRUE, FALSE)
	if(world.time >= aq_next_ulcer_message && prob(10))
		aq_next_ulcer_message = world.time + 2 MINUTES
		switch(stage)
			if(1)
				to_chat(H, "<span class='notice'>Czujesz lekkie pieczenie w nadbrzuszu.</span>")
			if(2)
				to_chat(H, "<span class='warning'>Tępy ból w nadbrzuszu nie odpuszcza.</span>")
			if(3)
				to_chat(H, "<span class='danger'>Żołądek boli cię przenikliwie, a w ustach czujesz posmak krwi.</span>")

/mob/living/carbon/human/proc/aq_get_ulcer_stomach()
	var/obj/item/organ/stomach/belly = getorganslot(ORGAN_SLOT_STOMACH)
	if(belly?.aq_can_ulcer())
		return belly

/// Co tick z aq_handle_needs()
/mob/living/carbon/human/proc/aq_handle_ulcer()
	var/obj/item/organ/stomach/belly = aq_get_ulcer_stomach()
	belly?.aq_ulcer_tick(src)

/// Kęs jedzenia (amount jednostek): śmieciowe podnosi kwas i drażni wrzód, zdrowe zbija kwas
/mob/living/carbon/human/proc/aq_stomach_bite(junk, types, amount)
	var/obj/item/organ/stomach/belly = aq_get_ulcer_stomach()
	if(!belly)
		return
	if(junk)
		belly.aq_acid = min(belly.aq_acid + AQ_ACID_PER_JUNK_UNIT * amount, 100)
		belly.aq_irritate(src)
	else if(types & (VEGETABLES|FRUIT|DAIRY))
		belly.aq_acid = max(belly.aq_acid - AQ_ACID_PER_HEALTHY_UNIT * amount, 0)

/// Wchłonięty reagent: kwas (napoje gazowane), osłona (mleko), podrażnienie (ostre, alkohol)
/mob/living/carbon/human/proc/aq_stomach_reagent(datum/reagent/consumable/bit)
	var/obj/item/organ/stomach/belly = aq_get_ulcer_stomach()
	if(!belly)
		return
	if(bit.aq_stomach_acid)
		belly.aq_acid = clamp(belly.aq_acid + bit.aq_stomach_acid * bit.metabolization_rate, 0, 100)
		if(bit.aq_stomach_acid < 0)
			belly.aq_soothed_until = world.time + 20 SECONDS
	if(bit.aq_ulcer_irritant)
		belly.aq_irritate(src)

/mob/living/carbon/human/aq_compute_pain()
	. = ..()
	if(stat == DEAD || HAS_TRAIT(src, TRAIT_ANALGESIA) || (status_flags & GODMODE))
		return
	var/obj/item/organ/stomach/belly = aq_get_ulcer_stomach()
	if(belly)
		. += belly.aq_ulcer_pain()

/mob/living/carbon/human/get_wound_scan_lines()
	. = ..()
	var/obj/item/organ/stomach/belly = aq_get_ulcer_stomach()
	if(!belly)
		return
	switch(belly.aq_ulcer_stage())
		if(1)
			. += "<span class='alert'>Wrzody żołądka: stadium 1 (nadżerki). Leczenie: Omeprazol albo dieta bez śmieciowego jedzenia, mleko.</span>"
		if(2)
			. += "<span class='alert'>Wrzody żołądka: stadium 2 (wrzód). Leczenie: Omeprazol, mleko, dieta bez śmieciowego jedzenia.</span>"
		if(3)
			. += "<span class='alert'>Wrzody żołądka: stadium 3 (krwawiący wrzód). Leczenie: Omeprazol albo gastrektomia.</span>"
		else
			if(belly.aq_acid >= AQ_ACID_ULCER_START)
				. += "<span class='notice'>Podrażniona śluzówka żołądka (dużo śmieciowego jedzenia).</span>"

/mob/living/carbon/human/fully_heal(admin_revive = FALSE)
	var/obj/item/organ/stomach/belly = getorganslot(ORGAN_SLOT_STOMACH)
	if(belly)
		belly.aq_acid = 0
		belly.aq_ulcer = 0
	return ..()

// --- Gastrektomia wycina krwawiący wrzód, nawet gdy żołądek nie jest jeszcze mocno uszkodzony ---

/datum/surgery_operation/organ/repair/gastrectomy/state_check(obj/item/organ/organ)
	var/obj/item/organ/stomach/belly = organ
	if(istype(belly) && belly.aq_ulcer_stage() >= 3 && !(organ.organ_flags & ORGAN_FAILING))
		return TRUE
	return ..()

/datum/surgery_operation/organ/repair/gastrectomy/on_success(obj/item/organ/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/obj/item/organ/stomach/belly = organ
	var/old_damage = organ.damage
	var/ulcer = istype(belly) && belly.aq_ulcer_stage() >= 3
	. = ..()
	if(ulcer)
		belly.aq_ulcer = 0
		belly.aq_acid = 0
		// Naprawa ustawia uszkodzenie na 20%: przy samym wrzodzie nie może go podnieść
		organ.setOrganDamage(min(organ.damage, old_damage))

// --- Omeprazol ---

/datum/reagent/medicine/aq_omeprazole
	name = "Omeprazol"
	description = "Lek osłaniający żołądek. Hamuje wydzielanie kwasu i szybko goi wrzody żołądka."
	reagent_state = SOLID
	color = "#E6DDF0"
	chem_flags = CHEMICAL_RNG_GENERAL
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	taste_description = "kreda"

/datum/chemical_reaction/aq_omeprazole
	name = "Omeprazol"
	id = /datum/reagent/medicine/aq_omeprazole
	results = list(/datum/reagent/medicine/aq_omeprazole = 4)
	required_reagents = list(/datum/reagent/sulfur = 1, /datum/reagent/sodium = 1, /datum/reagent/carbon = 1, /datum/reagent/nitrogen = 1)
	optimal_ph_min = 5
	optimal_ph_max = 9
	purity_min = 0.1
	reaction_tags = REACTION_TAG_EASY | REACTION_TAG_HEALING | REACTION_TAG_ORGAN

#undef AQ_ACID_PER_JUNK_UNIT
#undef AQ_ACID_PER_HEALTHY_UNIT
#undef AQ_ACID_DECAY
#undef AQ_ACID_ULCER_START
#undef AQ_ACID_HEAL_BELOW
#undef AQ_ULCER_NATURAL_HEAL
#undef AQ_ULCER_DRUG_HEAL
#undef AQ_ULCER_IRRITATION_COOLDOWN
