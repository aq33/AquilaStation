// AQUILA - port z tgstation: brakujące definicje i helpery dla DNA infusera
// (code/__DEFINES/dna_infuser_defines.dm, organ_flags, sygnały organów, replace_into, can_mutate)

//-- Tiery (code/__DEFINES/dna_infuser_defines.dm) --//
/// wpis bez progu (żartobliwe zestawy tieru 0)
#define DNA_INFUSION_NO_THRESHOLD ""
/// nie pojawia się w książce, nie da się go wszczepić
#define DNA_MUTANT_UNOBTAINABLE -1
/// tier 0: kosmetyka, rasy startowe, mucha
#define DNA_MUTANT_TIER_ZERO 0
/// tier 1: łatwe zestawy z bonusem
#define DNA_MUTANT_TIER_ONE 1
/// tier 2: trudniejsze zestawy (gondola)
#define DNA_MUTANT_TIER_TWO 2
/// infuser nie podnosi tieru powyżej tego
#define DNA_INFUSER_MAX_TIER 2

//-- Flagi / sygnały / cechy z tg, których u nas nie ma --//
#ifndef ORGAN_MUTANT
/// organ zmutowany w DNA infuserze
#define ORGAN_MUTANT (1<<7)
#endif

#ifndef COMSIG_ORGAN_IMPLANTED
/// od /obj/item/organ/Insert() po udanym wszczepieniu: (mob/living/carbon/receiver)
#define COMSIG_ORGAN_IMPLANTED "organ_implanted"
#endif
#ifndef COMSIG_ORGAN_REMOVED
/// od /obj/item/organ/Remove(): (mob/living/carbon/old_owner)
#define COMSIG_ORGAN_REMOVED "organ_removed"
#endif

#ifndef TRAIT_VALID_DNA_INFUSION
/// przedmiot (nie mob) nadaje się na próbkę do DNA infusera
#define TRAIT_VALID_DNA_INFUSION "valid_dna_infusion"
#endif
#ifndef TRAIT_SPACEWALK
/// można się poruszać w próżni bez odpychania się i plecaka odrzutowego
#define TRAIT_SPACEWALK "spacewalk"
#endif
#ifndef TRAIT_NUKEIMMUNE
/// głowica atomowa nie rozrywa moba
#define TRAIT_NUKEIMMUNE "nuke_immunity"
#endif
#ifndef TRAIT_VIRUS_RESISTANCE
/// duża szansa na odparcie zarażenia wirusem
#define TRAIT_VIRUS_RESISTANCE "virus_resistance"
#endif

/// źródło cech nadawanych przez infuser
#define INFUSER_TRAIT "dna_infuser"

//-- organ_traits jak w tg: cechy nadawane właścicielowi przez organ --//
/obj/item/organ/var/list/organ_traits
/// odpowiednik tg ORGAN_EXTERNAL dla infusera: organ może "wyrosnąć", nawet jeśli slot jest pusty
/obj/item/organ/var/infuser_external = FALSE

/obj/item/organ/tail
	infuser_external = TRUE

/obj/item/organ/wings
	infuser_external = TRUE

/obj/item/organ/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	var/already_owned = (M && owner == M)
	. = ..()
	if(already_owned || !M || owner != M)
		return
	if(length(organ_traits))
		M.add_traits(organ_traits, REF(src))
	SEND_SIGNAL(src, COMSIG_ORGAN_IMPLANTED, M)

/obj/item/organ/Remove(mob/living/carbon/M, special = FALSE)
	. = ..()
	if(!M)
		return
	if(length(organ_traits))
		M.remove_traits(organ_traits, REF(src))
	SEND_SIGNAL(src, COMSIG_ORGAN_REMOVED, M)

/// tg: wstawia organ w miejsce istniejącego w tym samym slocie, stary organ jest usuwany
/obj/item/organ/proc/replace_into(mob/living/carbon/new_owner)
	var/obj/item/organ/old_organ = new_owner.getorganslot(slot)
	if(old_organ)
		if(istype(old_organ, /obj/item/organ/brain))
			// bez przenoszenia tożsamości - umysł zostaje w ciele
			var/obj/item/organ/brain/old_brain = old_organ
			old_brain.Remove(new_owner, TRUE, TRUE)
		else
			old_organ.Remove(new_owner, TRUE)
		qdel(old_organ)
	Insert(new_owner, TRUE, TRUE)

/// tg: czy DNA tego moba da się modyfikować
/mob/living/carbon/proc/can_mutate()
	if(!has_dna())
		return FALSE
	if(!(MOB_ORGANIC in mob_biotypes))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_BADDNA) || HAS_TRAIT(src, TRAIT_GENELESS))
		return FALSE
	return TRUE

/// tg: losowa nazwa dla organów muchy, których nikt nie umie nazwać
/proc/odd_organ_name()
	return "[pick("zdeformowany", "pulsujący", "dziwny", "obślizgły", "pomarszczony", "odrażający", "ohydny", "lepki", "napuchnięty")] [pick("narząd", "organ", "gruczoł", "worek", "guz", "węzeł", "płat", "zwój")]"

//-- TRAIT_SPACEWALK: ruch w próżni jak karp --//
/mob/living/carbon/human/Process_Spacemove(movement_dir = 0)
	if(movement_dir && HAS_TRAIT(src, TRAIT_SPACEWALK) && isturf(loc))
		return TRUE
	return ..()

//-- TRAIT_NUKEIMMUNE: KillEveryoneOnZLevel() rozrywa każdego żywego moba --//
/mob/living/carbon/human/gib(no_brain, no_organs, no_bodyparts)
	if(HAS_TRAIT(src, TRAIT_NUKEIMMUNE) && SSticker.mode?.station_was_nuked)
		to_chat(src, "<span class='userdanger'>Fala uderzeniowa przetacza się przez ciebie... a ty wciąż żyjesz. Jak karaluch.</span>")
		return
	return ..()

//-- TRAIT_VIRUS_RESISTANCE: 75% szans na odparcie choroby zakaźnej --//
/mob/living/carbon/human/CanContractDisease(datum/disease/D)
	. = ..()
	if(. && HAS_TRAIT(src, TRAIT_VIRUS_RESISTANCE) && !D.bypasses_immunity && prob(75))
		return FALSE

//-- tg element noticable_organ: dopisek przy oględzinach właściciela organu --//
/datum/element/noticable_organ
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// tekst dopisywany do oględzin
	var/infused_desc
	/// strefa ciała, której zakrycie ukrywa dopisek (null = zawsze widoczny)
	var/body_zone

/datum/element/noticable_organ/Attach(datum/target, infused_desc, body_zone)
	. = ..()
	if(!isorgan(target))
		return ELEMENT_INCOMPATIBLE
	src.infused_desc = infused_desc
	src.body_zone = body_zone
	RegisterSignal(target, COMSIG_ORGAN_IMPLANTED, PROC_REF(on_implanted))
	RegisterSignal(target, COMSIG_ORGAN_REMOVED, PROC_REF(on_removed))
	var/obj/item/organ/organ = target
	if(organ.owner)
		RegisterSignal(organ.owner, COMSIG_PARENT_EXAMINE, PROC_REF(on_owner_examine), override = TRUE)

/datum/element/noticable_organ/Detach(obj/item/organ/target)
	UnregisterSignal(target, list(COMSIG_ORGAN_IMPLANTED, COMSIG_ORGAN_REMOVED))
	if(target.owner)
		UnregisterSignal(target.owner, COMSIG_PARENT_EXAMINE)
	return ..()

/datum/element/noticable_organ/proc/on_implanted(obj/item/organ/target, mob/living/carbon/receiver)
	SIGNAL_HANDLER
	RegisterSignal(receiver, COMSIG_PARENT_EXAMINE, PROC_REF(on_owner_examine), override = TRUE)

/datum/element/noticable_organ/proc/on_removed(obj/item/organ/target, mob/living/carbon/loser)
	SIGNAL_HANDLER
	UnregisterSignal(loser, COMSIG_PARENT_EXAMINE)

/datum/element/noticable_organ/proc/on_owner_examine(mob/living/carbon/examined, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(body_zone && infuser_zone_covered(examined, body_zone))
		return
	examine_list += "<span class='notice'>[infused_desc]</span>"

/// czy dana strefa ciała jest zasłonięta ubraniem
/proc/infuser_zone_covered(mob/living/carbon/target, zone)
	switch(zone)
		if(BODY_ZONE_PRECISE_MOUTH)
			return target.is_mouth_covered()
		if(BODY_ZONE_PRECISE_EYES)
			return target.is_eyes_covered()
	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/human/human_target = target
	var/flag
	switch(zone)
		if(BODY_ZONE_HEAD)
			flag = HEAD
		if(BODY_ZONE_CHEST)
			flag = CHEST
		if(BODY_ZONE_L_ARM)
			flag = ARM_LEFT
		if(BODY_ZONE_R_ARM)
			flag = ARM_RIGHT
	if(!flag)
		return FALSE
	for(var/obj/item/clothing/worn in list(human_target.w_uniform, human_target.wear_suit, human_target.gloves, human_target.head, human_target.wear_mask))
		if(worn.body_parts_covered & flag)
			return TRUE
	return FALSE
