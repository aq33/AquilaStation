// AQUILA - Pęcherz i mocz, pomysł i grafiki z Monkestation 2.0 (monkestation/code/modules/pissing/).
// U nas pęcherz nie ma własnego licznika jak w Monke: mocz to część naszej potrzeby wypróżnienia (defecation),
// która pochodzi z picia (urination). Logika oddawania jest w urination.dm, cenzura w censor.dm.

/datum/reagent/ammonia/urine
	name = "Mocz"
	description = "Dokładnie to, o czym myślisz. Pewnie się do czegoś przyda."
	color = "#c0d121"
	taste_description = "siki"
	evaporation_rate = 4
	freezing_point = T0C - 1

/// Mała ilość moczu robi plamę zamiast kałuży (Monke: piss_stain)
/datum/reagent/ammonia/urine/reaction_turf(turf/T, reac_volume)
	if(!isopenturf(T) || reac_volume < 3 || !QDELETED(T.liquids))
		return
	if(!(locate(/obj/effect/decal/cleanable/urine) in T))
		new /obj/effect/decal/cleanable/urine(T)

/obj/effect/decal/cleanable/urine
	name = "plama"
	desc = "Lepka, żółtawa plama. Pachnie amoniakiem."
	icon = 'aquila/icons/effects/piss_puddle.dmi'
	icon_state = "piss_puddle"

/obj/effect/decal/cleanable/urine/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, BLOOD_SLIPPERY_KNOCKDOWN, NO_SLIP_WHEN_WALKING)
	add_bodily_censor_appearance()
	QDEL_IN(src, 10 MINUTES)

/obj/item/organ/bladder
	name = "pęcherz"
	desc = "Tu trzyma się siki."
	icon = 'aquila/icons/obj/bladder.dmi'
	icon_state = "bladder"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_BLADDER
	/// Czym sikamy
	var/datum/reagent/pissin_reagent = /datum/reagent/ammonia/urine

/obj/item/organ/bladder/clown
	name = "pęcherz klauna"
	desc = "Jak to w ogóle działa?"
	pissin_reagent = /datum/reagent/lube

// Kto dostaje pęcherz: wszyscy z potrzebą wypróżnienia (tak jak tyłek, aquila/code/modules/butt/butt_organ.dm)

/datum/species
	/// Typ pęcherza, null = brak
	var/obj/item/organ/bladder/mutantbladder = /obj/item/organ/bladder

/datum/species/regenerate_organs(mob/living/carbon/C, datum/species/old_species, replace_current = TRUE)
	. = ..()
	var/obj/item/organ/bladder/bladder = C.getorganslot(ORGAN_SLOT_BLADDER)
	var/wants_bladder = mutantbladder && !(TRAIT_NOSHITTING in inherent_traits)
	if(bladder && !wants_bladder)
		bladder.Remove(C, TRUE)
		qdel(bladder)
	else if(!bladder && wants_bladder)
		bladder = new mutantbladder()
		bladder.Insert(C)

/mob/living/carbon/monkey/create_internal_organs()
	internal_organs += new /obj/item/organ/bladder
	return ..()

/// Klaun dostaje pęcherz z lubrykantem (Monke: bladder/clown)
/datum/job/clown/after_spawn(mob/living/carbon/human/H, mob/M, latejoin = FALSE)
	. = ..()
	if(!istype(H))
		return
	var/obj/item/organ/bladder/old_bladder = H.getorganslot(ORGAN_SLOT_BLADDER)
	if(!old_bladder || istype(old_bladder, /obj/item/organ/bladder/clown))
		return
	old_bladder.Remove(H, TRUE)
	qdel(old_bladder)
	var/obj/item/organ/bladder/clown/clown_bladder = new
	clown_bladder.Insert(H)

/datum/emote/living/carbon/human/piss
	key = "piss"
	key_third_person = "pisses"
	emote_type = EMOTE_VISIBLE

/datum/emote/living/carbon/human/piss/run_emote(mob/user, params, type_override, intentional)
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return FALSE
	if(!CONFIG_GET(flag/shitting_enabled))
		to_chat(user, "<span class='warning'>Wypróżnianie się zostało wyłączone w konfiguracji serwera.</span>")
		return FALSE
	if(!H.getorganslot(ORGAN_SLOT_BLADDER))
		to_chat(user, "<span class='warning'>Nie masz pęcherza!</span>")
		return FALSE
	H.urinate_voluntarily()
	return TRUE
