// AQUILA - tkanki w kończynach (AquilaMed 6, etap 7). Na wzór CEV-Eris (code/modules/organs/internal/bones.dm,
// muscles.dm, blood_vessels.dm), sprite'y z icons/obj/surgery.dmi Erisa (CC BY-SA 3.0).
// Każda ręka i noga ma trzy narządy: kość, mięśnie i naczynia krwionośne.
// - Rany je uszkadzają: złamania kość, rany cięte naczynia, kłute mięśnie, ciężkie oparzenia mięśnie.
// - Zniszczona albo wyjęta kość lub mięśnie: kończyna bezwładna. Uszkodzone mięśnie nóg spowalniają.
// - Zniszczone albo wyjęte naczynia: kończyna bez krwi powoli obumiera (obrażenia fizyczne).
// - Wymiana przez operację narządów kończyny: kość z tej samej strony i tej samej kończyny, mięśnie i naczynia
//   pasują do każdej kończyny. Wersje syntetyczne z protolathe'a prawie nie łapią obrażeń od ran.
// Różnice względem Erisa: u nas rany i złamania robi system ran z Bee, a tkanki tylko dokładają skutki. Brak tkanki
// liczy się dopiero wtedy, gdy ktoś ją wyjmie, więc doczepione i robotyczne kończyny nic nie tracą.

#define AQ_TISSUE_TRAIT "aq_tissue"
GLOBAL_LIST_INIT(aq_tissue_limb_zones, list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))

/obj/item/bodypart
	/// AquilaMed 6: tissues a surgeon took out of this limb (until a new one goes in)
	var/aq_tissue_removed = NONE

/obj/item/organ/aq_tissue
	icon = 'aquila/icons/obj/medical/organs_med6.dmi'
	zone = BODY_ZONE_L_ARM
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = 0 // tkanki nie gniją w zwłokach: po wskrzeszeniu kończyny działają
	maxHealth = STANDARD_ORGAN_THRESHOLD * 0.6
	low_threshold = STANDARD_ORGAN_THRESHOLD * 0.6 * 0.3
	high_threshold = STANDARD_ORGAN_THRESHOLD * 0.6 * 0.6
	/// AQ_TISSUE_* flag
	var/kind
	/// Fits any limb (muscles, vessels); a bone keeps its own limb
	var/any_limb = TRUE
	/// Multiplier of damage from wounds
	var/wound_damage_mult = 1
	var/was_failing = FALSE

/obj/item/organ/aq_tissue/Initialize(mapload, limb_zone)
	if(limb_zone)
		zone = limb_zone
	. = ..()
	aq_set_zone(zone)

/// Moves the organ to another limb: its slot follows
/obj/item/organ/aq_tissue/proc/aq_set_zone(new_zone)
	zone = new_zone
	slot = "aq_tissue_[kind]_[zone]"
	aq_update_tissue_name()

/obj/item/organ/aq_tissue/proc/aq_update_tissue_name()
	return

/obj/item/organ/aq_tissue/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE)
	. = ..()
	var/obj/item/bodypart/limb = M?.get_bodypart(zone)
	if(limb)
		limb.aq_tissue_removed &= ~kind
	M?.aq_update_tissues()

/obj/item/organ/aq_tissue/Remove(mob/living/carbon/M, special = 0)
	var/obj/item/bodypart/limb = M?.get_bodypart(zone)
	. = ..()
	if(!special && limb && limb.owner == M)
		limb.aq_tissue_removed |= kind
	if(M && !QDELETED(M) && M.loc)
		M.aq_update_tissues()

/obj/item/organ/aq_tissue/on_life()
	. = ..()
	var/failing = !!(organ_flags & ORGAN_FAILING)
	if(failing != was_failing)
		was_failing = failing
		owner?.aq_update_tissues()

/obj/item/organ/aq_tissue/applyOrganDamage(d, maximum = maxHealth)
	. = ..()
	if(owner && kind == AQ_TISSUE_MUSCLE && (zone == BODY_ZONE_L_LEG || zone == BODY_ZONE_R_LEG))
		owner.aq_update_tissues() // spowolnienie zależy od uszkodzenia

/obj/item/organ/aq_tissue/proc/aq_wound_damage(amount)
	applyOrganDamage(amount * wound_damage_mult)

// --- Rodzaje ---

/obj/item/organ/aq_tissue/bone
	name = "kość"
	desc = "Kość kończyny. Bez niej ręka albo noga jest bezwładna."
	icon_state = "bone-l_arm"
	kind = AQ_TISSUE_BONE
	any_limb = FALSE
	maxHealth = STANDARD_ORGAN_THRESHOLD
	low_threshold = STANDARD_ORGAN_THRESHOLD * 0.3
	high_threshold = STANDARD_ORGAN_THRESHOLD * 0.6
	healing_factor = STANDARD_ORGAN_HEALING * 0.5
	w_class = WEIGHT_CLASS_NORMAL
	low_threshold_passed = "<span class='info'>Kość w kończynie tępo boli.</span>"
	high_threshold_passed = "<span class='warning'>Kość w kończynie trzeszczy przy każdym ruchu.</span>"
	now_failing = "<span class='danger'>Kość w kończynie rozsypuje się na kawałki!</span>"

/obj/item/organ/aq_tissue/bone/aq_update_tissue_name()
	var/limb = ""
	switch(zone)
		if(BODY_ZONE_L_ARM)
			limb = "lewej ręki"
		if(BODY_ZONE_R_ARM)
			limb = "prawej ręki"
		if(BODY_ZONE_L_LEG)
			limb = "lewej nogi"
		if(BODY_ZONE_R_LEG)
			limb = "prawej nogi"
	name = "[(organ_flags & ORGAN_SYNTHETIC) ? "pręt tytanowy" : "kość"] [limb]"
	icon_state = "bone-[zone][(organ_flags & ORGAN_SYNTHETIC) ? "-cyber" : ""]"

/obj/item/organ/aq_tissue/muscle
	name = "mięśnie"
	desc = "Mięśnie kończyny. Bez nich ręka albo noga nie ma siły, uszkodzone w nogach spowalniają."
	icon_state = "muscle"
	kind = AQ_TISSUE_MUSCLE
	low_threshold_passed = "<span class='info'>Mięśnie kończyny pieką ze zmęczenia.</span>"
	high_threshold_passed = "<span class='warning'>Mięśnie kończyny drżą i odmawiają posłuszeństwa.</span>"
	now_failing = "<span class='danger'>Mięśnie w kończynie są rozerwane!</span>"

/obj/item/organ/aq_tissue/vessels
	name = "naczynia krwionośne"
	desc = "Tętnice i żyły kończyny. Bez nich kończyna nie dostaje krwi i obumiera."
	icon_state = "vessels"
	kind = AQ_TISSUE_VESSELS
	low_threshold_passed = "<span class='info'>Kończyna jest chłodna i mrowi.</span>"
	high_threshold_passed = "<span class='warning'>Kończyna blednie i drętwieje.</span>"
	now_failing = "<span class='danger'>Kończyna robi się zimna i sina!</span>"

// --- Syntetyczne ---

/obj/item/organ/aq_tissue/bone/cybernetic
	desc = "Tytanowy pręt z przegubami w miejsce kości. Prawie się nie łamie, ale impuls EMP potrafi go uszkodzić."
	icon_state = "bone-l_arm-cyber"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC
	wound_damage_mult = 0.25

/obj/item/organ/aq_tissue/muscle/cybernetic
	name = "mięśnie hydrauliczne"
	desc = "Siłowniki zamiast mięśni. Znoszą rany lepiej niż żywe, ale impuls EMP potrafi je uszkodzić."
	icon_state = "muscle-cyber"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC
	wound_damage_mult = 0.4

/obj/item/organ/aq_tissue/vessels/cybernetic
	name = "naczynia syntetyczne"
	desc = "Sieć elastycznych rurek zamiast tętnic i żył. Znosi rany lepiej niż żywa, ale impuls EMP potrafi ją uszkodzić."
	icon_state = "vessels-cyber"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC
	wound_damage_mult = 0.4

/obj/item/organ/aq_tissue/emp_act(severity)
	. = ..()
	if((. & EMP_PROTECT_SELF) || !(organ_flags & ORGAN_SYNTHETIC))
		return
	applyOrganDamage(20 / severity)

// --- Skutki ---

/mob/living/carbon
	/// Limbs without blood (missing or dead vessels), refreshed by aq_update_tissues()
	var/list/aq_ischemic_limbs

/// Does this body use limb tissues
/mob/living/carbon/proc/aq_uses_tissues()
	var/mob/living/carbon/human/H = src
	return istype(H) && H.dna?.species?.aq_has_med5_organs() && H.dna.species.aq_limb_tissues

/// Is this tissue missing or dead in that limb
/mob/living/carbon/proc/aq_tissue_lacking(obj/item/bodypart/limb, kind)
	var/obj/item/organ/aq_tissue/tissue = getorganslot("aq_tissue_[kind]_[limb.body_zone]")
	if(tissue)
		return !!(tissue.organ_flags & ORGAN_FAILING)
	return !!(limb.aq_tissue_removed & kind)

/// Paralysis, slowdown and missing blood from the tissues of all limbs
/mob/living/carbon/proc/aq_update_tissues()
	var/uses = aq_uses_tissues()
	var/slowdown = 0
	var/list/ischemic
	var/list/paralysed = list()
	if(uses)
		for(var/obj/item/bodypart/limb as anything in bodyparts)
			if(!(limb.body_zone in GLOB.aq_tissue_limb_zones) || !IS_ORGANIC_LIMB(limb))
				continue
			if(aq_tissue_lacking(limb, AQ_TISSUE_BONE) || aq_tissue_lacking(limb, AQ_TISSUE_MUSCLE))
				paralysed += limb.body_zone
			if(aq_tissue_lacking(limb, AQ_TISSUE_VESSELS))
				LAZYADD(ischemic, limb.body_zone)
			if(limb.body_zone == BODY_ZONE_L_LEG || limb.body_zone == BODY_ZONE_R_LEG)
				var/obj/item/organ/aq_tissue/muscle = getorganslot("aq_tissue_[AQ_TISSUE_MUSCLE]_[limb.body_zone]")
				if(muscle && !(muscle.organ_flags & ORGAN_FAILING))
					slowdown += 0.4 * muscle.damage / muscle.maxHealth
	aq_ischemic_limbs = ischemic
	if(slowdown > 0.05)
		add_movespeed_modifier("aq_tissue_muscles", update = TRUE, priority = 100, override = TRUE, multiplicative_slowdown = slowdown)
	else
		remove_movespeed_modifier("aq_tissue_muscles")
	var/changed = FALSE
	var/static/list/zone_traits = list(BODY_ZONE_L_ARM = TRAIT_PARALYSIS_L_ARM, BODY_ZONE_R_ARM = TRAIT_PARALYSIS_R_ARM, BODY_ZONE_L_LEG = TRAIT_PARALYSIS_L_LEG, BODY_ZONE_R_LEG = TRAIT_PARALYSIS_R_LEG)
	for(var/zone in zone_traits)
		var/trait = zone_traits[zone]
		var/has = HAS_TRAIT_FROM(src, trait, AQ_TISSUE_TRAIT)
		if((zone in paralysed) && !has)
			ADD_TRAIT(src, trait, AQ_TISSUE_TRAIT)
			changed = TRUE
		else if(!(zone in paralysed) && has)
			REMOVE_TRAIT(src, trait, AQ_TISSUE_TRAIT)
			changed = TRUE
	if(!changed)
		return
	// Bee keeps the old disabled state of a limb, so the paralysis is cleared by hand (as in wounds/spinal.dm)
	for(var/obj/item/bodypart/part as anything in bodyparts)
		if(part.disabled == BODYPART_DISABLED_PARALYSIS && !HAS_TRAIT(part, TRAIT_PARALYSIS))
			part.set_disabled(BODYPART_NOT_DISABLED)
	update_disabled_bodyparts()

/// A limb without blood slowly dies
/mob/living/carbon/human/Life()
	. = ..()
	if(!LAZYLEN(aq_ischemic_limbs) || QDELETED(src) || stat == DEAD || IsInStasis())
		return
	for(var/zone in aq_ischemic_limbs)
		var/obj/item/bodypart/limb = get_bodypart(zone)
		if(!limb || !IS_ORGANIC_LIMB(limb) || limb.brute_dam >= limb.max_damage * 0.5)
			continue
		limb.receive_damage(brute = 0.3)
		if(prob(3))
			to_chat(src, "<span class='warning'>[capitalize(strefa_pl(zone))] jest zimna i sina, nie czujesz w niej krwi.</span>")

/// Every organic limb of this body gets the tissues it lacks (a fresh body, a new limb); tissues a surgeon took out stay out
/mob/living/carbon/proc/aq_ensure_tissues()
	if(!aq_uses_tissues())
		return
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		if(!(limb.body_zone in GLOB.aq_tissue_limb_zones) || !IS_ORGANIC_LIMB(limb))
			continue
		for(var/tissue_type in list(/obj/item/organ/aq_tissue/bone, /obj/item/organ/aq_tissue/muscle, /obj/item/organ/aq_tissue/vessels))
			var/obj/item/organ/aq_tissue/prototype = tissue_type
			var/kind = initial(prototype.kind)
			if((limb.aq_tissue_removed & kind) || getorganslot("aq_tissue_[kind]_[limb.body_zone]"))
				continue
			var/obj/item/organ/aq_tissue/tissue = new tissue_type(null, limb.body_zone)
			tissue.Insert(src, TRUE)

/datum/species
	/// AquilaMed 6: bones, muscles and vessels in the limbs
	var/aq_limb_tissues = TRUE

/datum/species/regenerate_organs(mob/living/carbon/C, datum/species/old_species, replace_current = TRUE)
	. = ..()
	if(!C.aq_uses_tissues())
		for(var/obj/item/organ/aq_tissue/tissue in C.internal_organs)
			tissue.Remove(C, TRUE)
			qdel(tissue)
		C.aq_update_tissues()
		return
	C.aq_ensure_tissues()

/obj/item/bodypart/attach_limb(mob/living/carbon/C, special, is_creating = FALSE)
	. = ..()
	if(!is_creating && owner == C && !QDELETED(C))
		C.aq_ensure_tissues()
		C.aq_update_tissues()

/obj/item/bodypart/drop_limb(special)
	var/mob/living/carbon/old_owner = owner
	. = ..()
	if(old_owner && !QDELETED(old_owner) && old_owner.loc)
		old_owner.aq_update_tissues()

/// Wounds hurt the tissue under them
/datum/wound/proc/aq_hurt_tissue(kind, amount)
	if(aq_from_treatment || !victim || !limb || !(limb.body_zone in GLOB.aq_tissue_limb_zones))
		return
	var/obj/item/organ/aq_tissue/tissue = victim.getorganslot("aq_tissue_[kind]_[limb.body_zone]")
	tissue?.aq_wound_damage(amount)

/datum/wound/blunt/on_apply()
	. = ..()
	aq_hurt_tissue(AQ_TISSUE_BONE, severity >= WOUND_SEVERITY_CRITICAL ? 35 : 12 * severity)

/datum/wound/slash/on_apply()
	. = ..()
	aq_hurt_tissue(AQ_TISSUE_VESSELS, severity >= WOUND_SEVERITY_CRITICAL ? 30 : 8 * severity)

/datum/wound/pierce/on_apply()
	. = ..()
	aq_hurt_tissue(AQ_TISSUE_MUSCLE, 10 * severity)

/datum/wound/burn/on_apply()
	. = ..()
	if(severity >= WOUND_SEVERITY_CRITICAL)
		aq_hurt_tissue(AQ_TISSUE_MUSCLE, 25)

/// A loose muscle or vessel fits the limb it goes into
/datum/surgery_operation/limb/organ_manipulation/is_insert_available(obj/item/bodypart/limb, obj/item/tool, operated_zone)
	var/obj/item/organ/aq_tissue/tissue = get_inserted_organ(tool)
	if(istype(tissue) && tissue.any_limb && (operated_zone in GLOB.aq_tissue_limb_zones))
		tissue.aq_set_zone(operated_zone)
	return ..()

/mob/living/carbon/human/get_wound_scan_lines()
	. = ..()
	if(!aq_uses_tissues())
		return
	for(var/obj/item/bodypart/limb as anything in bodyparts)
		if(!limb.aq_tissue_removed)
			continue
		var/list/missing = list()
		if(limb.aq_tissue_removed & AQ_TISSUE_BONE)
			missing += "kości"
		if(limb.aq_tissue_removed & AQ_TISSUE_MUSCLE)
			missing += "mięśni"
		if(limb.aq_tissue_removed & AQ_TISSUE_VESSELS)
			missing += "naczyń"
		. += "<span class='alert'>[capitalize(strefa_pl(limb.body_zone))]: brak [jointext(missing, ", ")]. Wszczep nowe operacją narządów kończyny.</span>"

/datum/design/aq_titanium_bone
	name = "Pręt tytanowy (kość kończyny)"
	desc = "Tytanowy pręt z przegubami w miejsce kości ręki albo nogi. Po wydruku wybiera się kończynę."
	id = "aq_titanium_bone"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 500, /datum/material/titanium = 500)
	build_path = /obj/item/aq_bone_kit
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/aq_hydraulic_muscle
	name = "Mięśnie hydrauliczne"
	desc = "Siłowniki zamiast mięśni ręki albo nogi."
	id = "aq_hydraulic_muscle"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/iron = 600, /datum/material/glass = 200, /datum/material/silver = 100)
	build_path = /obj/item/organ/aq_tissue/muscle/cybernetic
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/aq_synthetic_vessels
	name = "Naczynia syntetyczne"
	desc = "Elastyczne rurki zamiast tętnic i żył ręki albo nogi."
	id = "aq_synthetic_vessels"
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(/datum/material/plastic = 500, /datum/material/glass = 200)
	build_path = /obj/item/organ/aq_tissue/vessels/cybernetic
	category = list("Cybernetics", "Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/// A printed titanium bone: pick which limb it is for
/obj/item/aq_bone_kit
	name = "pręt tytanowy w paczce"
	desc = "Tytanowy pręt z przegubami. Użyj w ręce, żeby dopasować go do kończyny."
	icon = 'aquila/icons/obj/medical/organs_med6.dmi'
	icon_state = "bone-l_arm-cyber"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/aq_bone_kit/attack_self(mob/user)
	var/static/list/choices = list("lewa ręka" = BODY_ZONE_L_ARM, "prawa ręka" = BODY_ZONE_R_ARM, "lewa noga" = BODY_ZONE_L_LEG, "prawa noga" = BODY_ZONE_R_LEG)
	var/choice = tgui_input_list(user, "Do której kończyny?", "Pręt tytanowy", choices)
	if(!choice || QDELETED(src) || !user.is_holding(src))
		return
	var/obj/item/organ/aq_tissue/bone/cybernetic/bone = new(get_turf(user), choices[choice])
	qdel(src)
	user.put_in_hands(bone)

#undef AQ_TISSUE_TRAIT
