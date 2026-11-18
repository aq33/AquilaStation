// AQUILA - śledziona, jelita i uszkodzenia pęcherza (AquilaMed 5, etap 6). Sprite'y śledziony i jelit z Goonstation
// (icons/obj/items/organs/spleen.dmi, intestines.dmi, CC BY-NC-SA 3.0).
// - Śledziona: przy utracie krwi raz na 5 minut wyrzuca zapas (10% krwi). Mocny cios tępy w brzuch może ją rozerwać:
//   krwotok wewnętrzny, którego nie zatrzyma bandaż. Kończy go wycięcie śledziony albo operacja zszycia.
// - Jelita: wchłaniają jedzenie. Uszkodzone wchłaniają gorzej i dają biegunkę (skala bristolska, bladder/bristol.dm).
//   Rana kłuta albo postrzał brzucha może je przebić: zakażenie (medical/germs.dm), ból, operacja zszycia.
// - Pęcherz (bladder/bladder.dm) może pęknąć od ciosu w brzuch: mocz zatruwa organizm. Cewnik opróżnia pęcherz
//   i na 10 minut zatrzymuje zatrucie, naprawia operacja zszycia pęcherza.

/// Brute damage to the belly at or above this can rupture the spleen or the bladder
#define AQ_RUPTURE_MIN_DAMAGE 15
#define AQ_SPLEEN_RELEASE_COOLDOWN (5 MINUTES)

/// The zone of COMSIG_MOB_APPLY_DAMGE: fists, kicks, animals and aliens pass the bodypart itself, weapons a zone string
/proc/aq_damage_zone(def_zone)
	if(isbodypart(def_zone))
		var/obj/item/bodypart/part = def_zone
		return part.body_zone
	return def_zone

/// COMSIG_MOB_APPLY_DAMGE carries the damage before armor: what is left of it after the armor on that zone
/mob/living/carbon/proc/aq_damage_after_armor(damage, def_zone)
	var/zone = aq_damage_zone(def_zone)
	var/armor = zone ? getarmor(zone, MELEE) : 0
	return damage * max(0, 100 - armor) / 100

/// A belly hit: brute on the chest or the groin
/proc/aq_is_belly_hit(damagetype, def_zone)
	var/zone = aq_damage_zone(def_zone)
	return damagetype == BRUTE && (!zone || zone == BODY_ZONE_CHEST || zone == BODY_ZONE_PRECISE_GROIN)

/// Organ lines for the health analyzer (wounds/_wounds.dm get_wound_scan_lines)
/mob/living/carbon/proc/aq_organ_scan_lines()
	. = list()
	for(var/obj/item/organ/organ as anything in internal_organs)
		var/line = organ.aq_scan_line()
		if(line)
			. += "<span class='alert'>[line]</span>"
	. += aq_missing_organ_scan_lines()

/// AquilaMed 5 and 6 organs this body should have but lacks: the line names what goes wrong without it
/mob/living/carbon/proc/aq_missing_organ_scan_lines()
	. = list()
	var/mob/living/carbon/human/H = src
	if(!istype(H) || !H.dna?.species?.aq_has_med5_organs())
		return
	var/datum/species/S = H.dna.species
	var/static/list/effects = list(
		ORGAN_SLOT_KIDNEYS = list("nerek", "toksyny we krwi rosną; dializa w sleeperze albo przeszczep"),
		ORGAN_SLOT_SPLEEN = list("śledziony", "brak zapasu krwi"),
		ORGAN_SLOT_INTESTINES = list("jelit", "jedzenie się nie wchłania"),
		ORGAN_SLOT_ADRENALS = list("nadnerczy", "brak adrenaliny przy bólu"),
		ORGAN_SLOT_LARYNX = list("krtani", "pacjent nie mówi"),
		ORGAN_SLOT_PANCREAS = list("trzustki", "cukier spala się wolno, grozi hiperglikemia; insulina doraźnie"),
		ORGAN_SLOT_ESOPHAGUS = list("przełyku", "pacjent nie może jeść ani pić"),
		ORGAN_SLOT_AQ_SPINE = list("kręgosłupa", "ręce i nogi bezwładne; po wszczepieniu połącz pień mózgu"),
	)
	var/list/species_type = list(
		ORGAN_SLOT_KIDNEYS = S.mutantkidneys, ORGAN_SLOT_SPLEEN = S.mutantspleen, ORGAN_SLOT_INTESTINES = S.mutantintestines,
		ORGAN_SLOT_ADRENALS = S.mutantadrenals, ORGAN_SLOT_LARYNX = S.aq_larynx_type(), ORGAN_SLOT_PANCREAS = S.mutantpancreas,
		ORGAN_SLOT_ESOPHAGUS = S.mutantesophagus, ORGAN_SLOT_AQ_SPINE = S.mutantspine,
	)
	for(var/slot in effects)
		if(!species_type[slot] || getorganslot(slot))
			continue
		var/list/info = effects[slot]
		. += "<span class='alert'><b>Brak [info[1]]:</b> [info[2]]. Przeszczep albo narząd cybernetyczny.</span>"
	// Hyperglycemia without a working pancreas (the pancreas line covers a damaged one still inside)
	var/sugar = reagents?.get_reagent_amount(/datum/reagent/consumable/sugar)
	if(!getorganslot(ORGAN_SLOT_PANCREAS) && S.mutantpancreas && sugar > AQ_HYPERGLYCEMIA_SUGAR)
		. += "<span class='alert'><b>Hiperglikemia:</b> [round(sugar, 1)] j. cukru we krwi. Podaj insulinę.</span>"

/obj/item/organ/proc/aq_scan_line()
	return null

// --- Śledziona ---

/obj/item/organ/spleen
	name = "śledziona"
	desc = "Magazyn krwi. Przy dużej utracie krwi wyrzuca zapas do krążenia."
	icon = 'aquila/icons/obj/medical/organs_med5.dmi'
	icon_state = "spleen"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_SPLEEN
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY
	low_threshold_passed = "<span class='info'>Coś kłuje cię w lewym boku.</span>"
	high_threshold_passed = "<span class='warning'>Lewy bok boli coraz mocniej.</span>"
	/// Torn: bleeds inside until removed or stitched
	var/ruptured = FALSE
	var/next_release = 0

/obj/item/organ/spleen/cybernetic
	name = "śledziona cybernetyczna"
	desc = "Mechaniczny zbiornik krwi. Nie pęka od ciosów, ale impuls EMP potrafi go uszkodzić."
	icon_state = "spleen-cyber"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC

/obj/item/organ/spleen/cybernetic/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_SELF))
		applyOrganDamage(25 / severity)

/obj/item/organ/spleen/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	RegisterSignal(M, COMSIG_MOB_APPLY_DAMGE, PROC_REF(on_owner_damaged), override = TRUE)

/obj/item/organ/spleen/Remove(mob/living/carbon/M, special = 0)
	UnregisterSignal(M, COMSIG_MOB_APPLY_DAMGE)
	ruptured = FALSE
	return ..()

/obj/item/organ/spleen/proc/on_owner_damaged(datum/source, damage, damagetype, def_zone)
	SIGNAL_HANDLER
	if(ruptured || (organ_flags & ORGAN_SYNTHETIC) || !owner || !aq_is_belly_hit(damagetype, def_zone) || owner.aq_damage_after_armor(damage, def_zone) < AQ_RUPTURE_MIN_DAMAGE || !prob(10))
		return
	rupture()

/obj/item/organ/spleen/proc/rupture()
	ruptured = TRUE
	setOrganDamage(max(damage, high_threshold))
	to_chat(owner, "<span class='userdanger'>Coś w lewym boku pęka, a brzuch zalewa gorąco!</span>")

/obj/item/organ/spleen/on_life()
	. = ..()
	if(!owner || owner.stat == DEAD)
		return
	if(ruptured)
		owner.blood_volume = max(0, owner.blood_volume - 1.5)
		return
	if(organ_flags & ORGAN_FAILING || owner.blood_volume >= BLOOD_VOLUME_OKAY || world.time < next_release)
		return
	next_release = world.time + AQ_SPLEEN_RELEASE_COOLDOWN
	owner.blood_volume = min(BLOOD_VOLUME_NORMAL, owner.blood_volume + BLOOD_VOLUME_NORMAL * 0.1)
	to_chat(owner, "<span class='notice'>Czujesz ukłucie w lewym boku, a w głowie trochę się rozjaśnia.</span>")

/obj/item/organ/spleen/aq_scan_line()
	if(ruptured)
		return "<b>Krwotok wewnętrzny: pęknięta śledziona.</b> Wytnij śledzionę albo ją zszyj."

// --- Jelita ---

/obj/item/organ/intestines
	name = "jelita"
	desc = "Kilka metrów jelit. Wchłaniają to, co zjesz."
	icon = 'aquila/icons/obj/medical/organs_med5.dmi'
	icon_state = "intestines"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_INTESTINES
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY
	low_threshold_passed = "<span class='info'>Brzuch burczy i skręca cię w nim.</span>"
	high_threshold_passed = "<span class='warning'>Kurcze brzucha nie dają spokoju.</span>"
	/// Punctured: lets germs into the belly until stitched
	var/perforated = FALSE

/obj/item/organ/intestines/cybernetic
	name = "jelita cybernetyczne"
	desc = "Mechaniczny układ trawienny. Nie da się go przebić, ale impuls EMP potrafi go uszkodzić."
	icon_state = "intestines-cyber"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC

/obj/item/organ/intestines/cybernetic/emp_act(severity)
	. = ..()
	if(!(. & EMP_PROTECT_SELF))
		applyOrganDamage(25 / severity)

/obj/item/organ/intestines/Remove(mob/living/carbon/M, special = 0)
	perforated = FALSE
	return ..()

/// How much of the food reaches the body, 0-1
/obj/item/organ/intestines/proc/aq_absorption()
	if(organ_flags & ORGAN_FAILING)
		return 0.3
	. = 1 - 0.5 * damage / maxHealth
	if(perforated)
		. *= 0.7

/obj/item/organ/intestines/proc/perforate()
	if(perforated || (organ_flags & ORGAN_SYNTHETIC))
		return
	perforated = TRUE
	setOrganDamage(max(damage, low_threshold + 5))
	to_chat(owner, "<span class='userdanger'>Coś rozrywa ci się w brzuchu, czujesz ostry, rozlewający się ból!</span>")

/obj/item/organ/intestines/on_life()
	. = ..()
	if(!owner || owner.stat == DEAD || !perforated)
		return
	var/obj/item/bodypart/chest = owner.get_bodypart(BODY_ZONE_CHEST)
	chest?.aq_add_germs(0.1)

/obj/item/organ/intestines/aq_scan_line()
	if(perforated)
		return "<b>Przebite jelita.</b> Grozi zakażeniem: zszyj jelita operacją."

/// Sick or missing intestines absorb less of the food passing from the stomach; the rest is lost. Only food that went
/// through the stomach: photosynthesis, an IV drip or an injection are not touched.
/obj/item/organ/stomach/digest()
	var/mob/living/carbon/human/H = owner
	if(!istype(H) || !H.reagents || !H.dna?.species?.aq_has_med5_organs())
		return ..()
	var/obj/item/organ/intestines/intestines = H.getorganslot(ORGAN_SLOT_INTESTINES)
	var/absorption = intestines ? intestines.aq_absorption() : 0.2
	if(absorption >= 1)
		return ..()
	var/list/before = list()
	for(var/datum/reagent/consumable/food in H.reagents.reagent_list)
		before[food.type] = food.volume
	. = ..()
	for(var/datum/reagent/consumable/food in H.reagents.reagent_list.Copy())
		var/gained = food.volume - (before[food.type] || 0)
		if(gained > 0)
			H.reagents.remove_reagent(food.type, gained * (1 - absorption))

/// A full heal (admin, changeling revive, healing magic) closes ruptures and perforations too
/mob/living/carbon/fully_heal(admin_revive = FALSE)
	. = ..()
	var/obj/item/organ/spleen/spleen = getorganslot(ORGAN_SLOT_SPLEEN)
	if(spleen)
		spleen.ruptured = FALSE
	var/obj/item/organ/intestines/intestines = getorganslot(ORGAN_SLOT_INTESTINES)
	if(intestines)
		intestines.perforated = FALSE
	var/obj/item/organ/bladder/bladder = getorganslot(ORGAN_SLOT_BLADDER)
	if(bladder)
		bladder.ruptured = FALSE

/mob/living/carbon/human/stool_type(list/reasons)
	. = ..()
	var/obj/item/organ/intestines/intestines = getorganslot(ORGAN_SLOT_INTESTINES)
	if(intestines && (intestines.perforated || intestines.damage >= intestines.low_threshold))
		reasons?.Add("chore jelita")
		. = max(., 6)

/// A stab or a gunshot in the belly can puncture the intestines
/datum/wound/pierce/on_apply()
	. = ..()
	if(aq_from_treatment || limb?.body_zone != BODY_ZONE_CHEST || !prob(15 * severity))
		return
	var/obj/item/organ/intestines/intestines = victim.getorganslot(ORGAN_SLOT_INTESTINES)
	intestines?.perforate()

// --- Pęcherz ---

/obj/item/organ/bladder
	/// Torn: urine leaks inside and poisons until stitched (a catheter holds it off)
	var/ruptured = FALSE

/obj/item/organ/bladder/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	RegisterSignal(M, COMSIG_MOB_APPLY_DAMGE, PROC_REF(on_owner_damaged), override = TRUE)

/obj/item/organ/bladder/Remove(mob/living/carbon/M, special = 0)
	UnregisterSignal(M, COMSIG_MOB_APPLY_DAMGE)
	ruptured = FALSE
	return ..()

/obj/item/organ/bladder/proc/on_owner_damaged(datum/source, incoming_damage, damagetype, def_zone)
	SIGNAL_HANDLER
	if(ruptured || !owner || !aq_is_belly_hit(damagetype, def_zone) || owner.aq_damage_after_armor(incoming_damage, def_zone) < AQ_RUPTURE_MIN_DAMAGE || !prob(6))
		return
	ruptured = TRUE
	setOrganDamage(max(damage, high_threshold))
	to_chat(owner, "<span class='userdanger'>Coś pęka ci w podbrzuszu, a ból rozlewa się na cały brzuch!</span>")

/obj/item/organ/bladder/on_life()
	. = ..()
	if(!owner || owner.stat == DEAD || !ruptured)
		return
	var/mob/living/carbon/human/H = owner
	if(istype(H) && world.time < H.aq_catheter_until)
		return
	if(owner.getToxLoss() < 60)
		owner.adjustToxLoss(0.2)

/obj/item/organ/bladder/aq_scan_line()
	if(ruptured)
		return "<b>Pęknięty pęcherz:</b> mocz zatruwa organizm. Cewnik pomaga na chwilę, naprawia operacja."

/mob/living/carbon/human
	/// A catheter keeps the urine out of a ruptured bladder until this time
	var/aq_catheter_until = 0

/obj/item/catheter
	name = "cewnik"
	desc = "Jednorazowy cewnik z workiem. Opróżnia pęcherz pacjenta, a przy pękniętym pęcherzu na 10 minut zatrzymuje zatrucie moczem."
	icon = 'aquila/icons/obj/medical/medycyna5.dmi' // sprite z Paradise (icons/obj/surgery.dmi, tube), CC-BY-SA 3.0
	icon_state = "catheter"
	w_class = WEIGHT_CLASS_SMALL
	custom_materials = list(/datum/material/plastic = 300)

/obj/item/catheter/attack(mob/living/M, mob/living/user)
	if(!ishuman(M) || user.combat_mode)
		return ..()
	var/mob/living/carbon/human/patient = M
	if(!patient.getorganslot(ORGAN_SLOT_BLADDER))
		to_chat(user, "<span class='warning'>[patient] nie ma pęcherza.</span>")
		return
	user.visible_message("<span class='notice'>[user] zakłada cewnik [patient].</span>", "<span class='notice'>Zakładasz cewnik [patient]...</span>")
	if(!do_mob(user, patient, (patient == user ? 6 SECONDS : 4 SECONDS) * toolspeed))
		return
	var/drained = patient.urination
	patient.urination = 0
	patient.adjust_defecation(-drained)
	patient.aq_catheter_until = world.time + 10 MINUTES
	user.visible_message("<span class='notice'>[user] opróżnia pęcherz [patient] przez cewnik.</span>", "<span class='notice'>Opróżniasz pęcherz [patient] przez cewnik.</span>")
	qdel(src)

// --- Operacje zszycia ---

// Organs in the groin have no zone picture (get_generic_limb_radial_image), so these show the organ itself
/datum/surgery_operation/organ/repair/spleen/get_default_radial_image()
	return get_item_radial_image(target_type)

/datum/surgery_operation/organ/repair/intestines/get_default_radial_image()
	return get_item_radial_image(target_type)

/datum/surgery_operation/organ/repair/bladder/get_default_radial_image()
	return get_item_radial_image(target_type)

/datum/surgery_operation/organ/repair/spleen
	name = "zszycie śledziony"
	rnd_name = "Splenorafia (operacja śledziony)"
	desc = "Zszywa pękniętą albo uszkodzoną śledzionę i zatrzymuje krwotok wewnętrzny."
	implements = list(TOOL_HEMOSTAT = 1, /obj/item/stack/medical/suture = 1.2, TOOL_WIRECUTTER = 2.85)
	time = 5 SECONDS
	target_type = /obj/item/organ/spleen
	heal_to_percent = 0.1
	required_damage_percent = 0.1
	repeatable = TRUE
	preop_sound = 'sound/surgery/hemostat1.ogg'
	success_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_operation/organ/repair/spleen/state_check(obj/item/organ/spleen/organ)
	return organ.ruptured || ..()

/datum/surgery_operation/organ/repair/spleen/on_success(obj/item/organ/spleen/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	organ.ruptured = FALSE
	display_results(surgeon, organ.owner, span_notice("Zszywasz śledzionę [FORMAT_ORGAN_OWNER(organ)]."), span_notice("[surgeon] zszywa śledzionę [FORMAT_ORGAN_OWNER(organ)]."), span_notice("[surgeon] kończy operację [FORMAT_ORGAN_OWNER(organ)]."))

/datum/surgery_operation/organ/repair/intestines
	name = "zszycie jelit"
	rnd_name = "Zszycie jelit"
	desc = "Zszywa przebite albo uszkodzone jelita."
	implements = list(TOOL_HEMOSTAT = 1, /obj/item/stack/medical/suture = 1.2, TOOL_WIRECUTTER = 2.85)
	time = 5 SECONDS
	target_type = /obj/item/organ/intestines
	heal_to_percent = 0.1
	required_damage_percent = 0.1
	repeatable = TRUE
	preop_sound = 'sound/surgery/hemostat1.ogg'
	success_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_operation/organ/repair/intestines/state_check(obj/item/organ/intestines/organ)
	return organ.perforated || ..()

/datum/surgery_operation/organ/repair/intestines/on_success(obj/item/organ/intestines/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	organ.perforated = FALSE
	display_results(surgeon, organ.owner, span_notice("Zszywasz jelita [FORMAT_ORGAN_OWNER(organ)]."), span_notice("[surgeon] zszywa jelita [FORMAT_ORGAN_OWNER(organ)]."), span_notice("[surgeon] kończy operację [FORMAT_ORGAN_OWNER(organ)]."))

/datum/surgery_operation/organ/repair/bladder
	name = "zszycie pęcherza"
	rnd_name = "Zszycie pęcherza"
	desc = "Zszywa pęknięty albo uszkodzony pęcherz."
	implements = list(TOOL_HEMOSTAT = 1, /obj/item/stack/medical/suture = 1.2, TOOL_WIRECUTTER = 2.85)
	time = 5 SECONDS
	target_type = /obj/item/organ/bladder
	heal_to_percent = 0.1
	required_damage_percent = 0.1
	repeatable = TRUE
	preop_sound = 'sound/surgery/hemostat1.ogg'
	success_sound = 'sound/surgery/organ1.ogg'

/datum/surgery_operation/organ/repair/bladder/state_check(obj/item/organ/bladder/organ)
	return organ.ruptured || ..()

/datum/surgery_operation/organ/repair/bladder/on_success(obj/item/organ/bladder/organ, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	organ.ruptured = FALSE
	display_results(surgeon, organ.owner, span_notice("Zszywasz pęcherz [FORMAT_ORGAN_OWNER(organ)]."), span_notice("[surgeon] zszywa pęcherz [FORMAT_ORGAN_OWNER(organ)]."), span_notice("[surgeon] kończy operację [FORMAT_ORGAN_OWNER(organ)]."))

/datum/design/cybernetic_spleen
	name = "Śledziona cybernetyczna"
	desc = "Mechaniczny zbiornik krwi zamiast śledziony."
	id = "aq_cybernetic_spleen"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/glass = 300)
	build_path = /obj/item/organ/spleen/cybernetic
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/cybernetic_intestines
	name = "Jelita cybernetyczne"
	desc = "Mechaniczny układ trawienny zamiast jelit."
	id = "aq_cybernetic_intestines"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 600, /datum/material/glass = 300)
	build_path = /obj/item/organ/intestines/cybernetic
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/catheter
	name = "Cewnik"
	desc = "Jednorazowy cewnik z workiem."
	id = "aq_catheter"
	build_type = PROTOLATHE | AUTOLATHE
	materials = list(/datum/material/plastic = 300)
	build_path = /obj/item/catheter
	category = list("initial", "Medical", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

#undef AQ_RUPTURE_MIN_DAMAGE
#undef AQ_SPLEEN_RELEASE_COOLDOWN
