// Port cybernetyki z Monkestation: implanty kręgosłupa (knockout, R.A.G.E., C.C.M.S.).
// Pominięty Sandevistan: potrzebuje komponentów after_image i slowing_field.

/obj/item/organ/cyberimp/chest/spinal
	name = "implant kręgosłupa"
	desc = "Tego nie powinno tu być!"
	icon_state = "chest_implant"
	implant_overlay = "chest_implant_overlay"
	slot = ORGAN_SLOT_SPINAL

// Knockout

/datum/action/item_action/organ_action/knockout
	name = "Cios nokautujący"

/obj/item/organ/cyberimp/chest/spinal/knockout
	name = "implant nokautujący"
	desc = "Wystrzeliwuje z klatki piersiowej rękawicę bokserską, która zdmuchuje skarpetki z nóg temu, kto stoi przed tobą! Odrzut przewraca na tyłek ciebie."
	actions_types = list(/datum/action/item_action/organ_action/knockout)
	/// Odnowienie strzału
	var/cooldown_time = 60 SECONDS
	/// Co wystrzeliwujemy
	var/projectile = /obj/item/punching_glove
	/// Dźwięk strzału
	var/fire_sound = 'sound/items/bikehorn.ogg'
	/// Czy rękawica zadaje obrażenia
	var/harmful = FALSE
	COOLDOWN_DECLARE(shoot_cooldown)

/obj/item/organ/cyberimp/chest/spinal/knockout/ui_action_click()
	if(organ_flags & ORGAN_FAILING)
		to_chat(owner, span_warning("Implant nie reaguje. Wygląda na zepsuty..."))
		return
	if(!COOLDOWN_FINISHED(src, shoot_cooldown))
		to_chat(owner, span_warning("Implant nie reaguje. Chyba jeszcze się ładuje..."))
		return
	COOLDOWN_START(src, shoot_cooldown, cooldown_time)
	shoot_fist()

/obj/item/organ/cyberimp/chest/spinal/knockout/proc/shoot_fist()
	var/turf/target = get_edge_target_turf(owner, owner.dir)
	var/obj/item/glove = new projectile(owner.loc)
	glove.throwforce = harmful ? 35 : 0
	playsound(owner, fire_sound, 50, TRUE)
	log_combat(owner, target, "launched [glove] from a knockout implant at")
	owner.visible_message(span_warning("[owner] wystrzeliwuje [glove] z klatki piersiowej!"))
	owner.Beam(glove, icon_state = "chain", time = 10 SECONDS, maxdistance = 7)
	glove.throw_at(target, 5, 1.5, owner, FALSE, TRUE)

	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		var/obj/item/suit = human_owner.wear_suit
		if(suit && human_owner.dropItemToGround(suit, TRUE))
			suit.throw_at(target, 5, 1.5, owner, FALSE, TRUE)

	owner.visible_message(span_notice("Odrzut posyła [owner] do tyłu, prosto na tyłek."))
	owner.newtonian_move(turn(owner.dir, 180))
	owner.SetKnockdown(1.5 SECONDS)
	return TRUE

// R.A.G.E.

/obj/item/organ/cyberimp/chest/spinal/chemvat
	name = "system chemiczny R.A.G.E."
	desc = "Skrajnie niebezpieczny system, który co chwilę zalewa nosiciela mieszanką silnych narkotyków. Przyrasta do pleców i twarzy."
	icon = 'aquila/icons/obj/cybernetics/chemvat.dmi'
	icon_state = "chemvat_back_held"
	implant_overlay = null
	syndicate_implant = TRUE
	/// Maska wymuszona na twarzy
	var/obj/item/clothing/mask/chemvat/forced_mask
	/// Zbiornik wymuszony na plecach
	var/obj/item/chemvat_tank/forced_tank
	/// Co ile wstrzykuje
	var/refill_time = 20 SECONDS
	/// Do kiedy się uzupełnia
	var/refill_until = 0
	/// Koktajl (penthrite -> efedryna, brain_healer z Monke -> mannitol)
	var/list/reagent_list = list(
		/datum/reagent/medicine/ephedrine = 5,
		/datum/reagent/drug/bath_salts = 3,
		/datum/reagent/medicine/omnizine = 3,
		/datum/reagent/medicine/mannitol = 5,
	)

/obj/item/organ/cyberimp/chest/spinal/chemvat/on_life()
	. = ..()
	if(!owner || (organ_flags & ORGAN_FAILING))
		return
	if(world.time < refill_until)
		if(owner.nutrition > NUTRITION_LEVEL_STARVING && owner.blood_volume > BLOOD_VOLUME_SURVIVE)
			owner.adjust_nutrition(-5)
			owner.blood_volume--
			owner.Jitter(1)
			owner.Dizzy(1)
		return
	refill_until = world.time + refill_time
	var/obj/effect/temp_visual/chempunk/punk = new(get_turf(owner))
	punk.color = "#77BD5D"
	owner.reagents.add_reagent_list(reagent_list)
	to_chat(owner, span_notice("Czujesz ostre ukłucie, gdy koktajl chemikaliów wpływa ci do krwi!"))

/obj/item/organ/cyberimp/chest/spinal/chemvat/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(owner != M)
		return
	if(!forced_mask)
		forced_mask = new(src)
	if(!forced_tank)
		forced_tank = new(src)
	if(M.wear_mask != forced_mask)
		if(M.wear_mask)
			M.dropItemToGround(M.wear_mask, TRUE)
		M.equip_to_slot_if_possible(forced_mask, ITEM_SLOT_MASK, disable_warning = TRUE)
	if(M.back != forced_tank)
		if(M.back)
			M.dropItemToGround(M.back, TRUE)
		M.equip_to_slot_if_possible(forced_tank, ITEM_SLOT_BACK, disable_warning = TRUE)

/obj/item/organ/cyberimp/chest/spinal/chemvat/Remove(mob/living/carbon/M, special = FALSE)
	QDEL_NULL(forced_mask)
	QDEL_NULL(forced_tank)
	return ..()

/obj/item/organ/cyberimp/chest/spinal/chemvat/Destroy()
	QDEL_NULL(forced_mask)
	QDEL_NULL(forced_tank)
	return ..()

/obj/item/chemvat_tank
	name = "zbiornik R.A.G.E."
	desc = "Zbiornik z chemikaliami przyrośnięty do pleców."
	icon = 'aquila/icons/obj/cybernetics/chemvat.dmi'
	icon_state = "chemvat_back_held"
	worn_icon = 'aquila/icons/obj/cybernetics/chemvat.dmi'
	worn_icon_state = "chemvat_back"
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/chemvat_tank/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/clothing/mask/chemvat
	name = "maska R.A.G.E."
	desc = "Maska przyrośnięta do twarzy, przez którą system R.A.G.E. podaje opary."
	icon = 'aquila/icons/obj/cybernetics/chemvat.dmi'
	icon_state = "chemvat_mask_held"
	worn_icon = 'aquila/icons/obj/cybernetics/chemvat.dmi'
	worn_icon_state = "chemvat_mask"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/clothing/mask/chemvat/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

// C.C.M.S. - walka dwiema rękami

/obj/item/organ/cyberimp/chest/spinal/dualwield
	name = "implant C.C.M.S."
	desc = "Complementary Combat Maneuvering System przetwarza sygnały nerwowe z rdzenia kręgowego i wymusza ruch uzupełniający po drugiej stronie ciała przy każdym ataku. \
		Mówiąc prościej: walczysz dwiema rękami naraz (tylko w combat mode)."
	icon = 'aquila/icons/obj/cybernetics/implants.dmi'
	icon_state = "ccms"
	implant_overlay = null
	syndicate_implant = TRUE
	/// Właśnie wykonujemy cios uzupełniający, żeby nie zapętlić ataków
	var/complementing = FALSE
	/// Kiedy ostatnio zaplanowano cios uzupełniający
	var/last_scheduled = 0

/obj/item/organ/cyberimp/chest/spinal/dualwield/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(owner == M)
		RegisterSignal(M, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_item_attack))

/obj/item/organ/cyberimp/chest/spinal/dualwield/Remove(mob/living/carbon/M, special = FALSE)
	if(M)
		UnregisterSignal(M, COMSIG_MOB_ITEM_ATTACK)
	return ..()

/obj/item/organ/cyberimp/chest/spinal/dualwield/proc/on_item_attack(mob/living/carbon/source, mob/living/target, mob/living/user, params)
	SIGNAL_HANDLER
	if(complementing || !source.combat_mode || (organ_flags & ORGAN_FAILING))
		return
	if(last_scheduled == world.time) // np. ostrza modliszki same dokładają cios drugą ręką
		return
	var/obj/item/offhand = source.get_inactive_held_item()
	if(!offhand)
		return
	last_scheduled = world.time
	// Cios wpada w przerwę między atakami właściciela
	var/attack_time = max((source.next_move - world.time) * 0.5, 1)
	addtimer(CALLBACK(src, PROC_REF(complement_attack), offhand, target), attack_time)

/obj/item/organ/cyberimp/chest/spinal/dualwield/proc/complement_attack(obj/item/item, mob/living/target)
	if(QDELETED(owner) || QDELETED(target) || QDELETED(item))
		return
	if(owner.get_inactive_held_item() != item || !owner.combat_mode || (organ_flags & ORGAN_FAILING))
		return
	if(handle_side_effects(item, target))
		return
	if(owner.CanReach(target, item))
		complementing = TRUE
		item.attack(target, owner)
		complementing = FALSE

/// TRUE = niewypał, ciosu nie będzie
/obj/item/organ/cyberimp/chest/spinal/dualwield/proc/handle_side_effects(obj/item/item, mob/living/target)
	return FALSE

/obj/item/organ/cyberimp/chest/spinal/dualwield/refurbished
	name = "odnowiony implant C.C.M.S."
	desc = "Odnowiony implant do walki dwiema rękami. Wygląda staro, włókna nerwowe są zużyte, ale nadal działa. Czasem nie zadziała albo szarpnie ręką."
	icon_state = "ccms_refurbished"
	syndicate_implant = FALSE

/obj/item/organ/cyberimp/chest/spinal/dualwield/refurbished/handle_side_effects(obj/item/item, mob/living/target)
	if(prob(20))
		owner.visible_message(span_warning("Ręka [owner] drga."), span_danger("Twój C.C.M.S. nie odpala!"))
		return TRUE
	if(prob(30))
		owner.visible_message(span_warning("Ręka [owner] wpada w spazmy!"), span_danger("Twoja ręka wpada w spazmy!"))
		var/obj/item/bodypart/arm = owner.get_bodypart(owner.active_hand_index % 2 ? BODY_ZONE_R_ARM : BODY_ZONE_L_ARM)
		arm?.receive_damage(brute = 10)
	return FALSE
