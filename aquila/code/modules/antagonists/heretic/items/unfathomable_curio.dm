//Item for knock/moon heretic sidepath, it can block 5 hits of damage, acts as storage and if the heretic is examined the examiner suffers brain damage and blindness

/obj/item/storage/belt/unfathomable_curio
	name = "Unfathomable Curio"
	desc = "To. Patrzy z powrotem. Patrzy obok. Patrzy w głąb. Widzi. Ukrywa. Otwiera."
	icon_state = "unfathomable_curio"
	item_state = "unfathomable_curio"
	worn_icon_state = "unfathomable_curio"
	worn_icon = 'aquila/icons/mob/clothing/belt_curio.dmi'
	content_overlays = FALSE

	//Vars used for the shield component
	var/heretic_shield_icon = "unfathomable_shield"
	var/max_charges = 1
	var/recharge_start_delay = 30 SECONDS
	var/charge_increment_delay = 30 SECONDS

/obj/item/storage/belt/unfathomable_curio/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 7
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 21
	STR.can_hold = typecacheof(list(
		/obj/item/ammo_box/strilka310/lionhunter,
		/obj/item/heretic_labyrinth_handbook,
		/obj/item/bodypart, // Bodyparts are often used in rituals.
		/obj/item/clothing/neck/eldritch_amulet,
		/obj/item/clothing/neck/heretic_focus,
		/obj/item/codex_cicatrix,
		/obj/item/eldritch_potion,
		/obj/item/food/grown/poppy, // Used to regain a Living Heart.
		/obj/item/food/grown/harebell, // Used to reroll targets
		/obj/item/melee/rune_carver,
		/obj/item/melee/sickly_blade,
		/obj/item/organ, // Organs are also often used in rituals.
		/obj/item/reagent_containers/glass/beaker/eldritch,
		/obj/item/stack/sheet/glass, // Glass is often used by moon heretics
	))

/obj/item/storage/belt/unfathomable_curio/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shielded, max_charges, recharge_start_delay, charge_increment_delay, 'aquila/icons/effects/heretic_side.dmi', heretic_shield_icon, FALSE, CALLBACK(src, PROC_REF(shield_damaged)))

/obj/item/storage/belt/unfathomable_curio/equipped(mob/user, slot, initial)
	. = ..()
	if(!(slot & slot_flags))
		return

	RegisterSignal(user, COMSIG_HUMAN_CHECK_SHIELDS, PROC_REF(shield_reaction), TRUE)

	if(!IS_HERETIC(user))
		to_chat(user, span_warning("Osobliwość owija się wokół ciebie, a ty czujesz bicie czegoś mrocznego w jej wnętrzu..."))

/obj/item/storage/belt/unfathomable_curio/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_HUMAN_CHECK_SHIELDS)

// Here we make sure our curio is only able to block while worn on the belt slot
// AQUILA - nasze check_shields nie sprawdza pasa, więc blokujemy przez sygnał COMSIG_HUMAN_CHECK_SHIELDS
/obj/item/storage/belt/unfathomable_curio/proc/shield_reaction(mob/living/carbon/human/owner, atom/movable/hitby, damage = 0, attack_text = "atak", attack_type = MELEE_ATTACK, armour_penetration = 0)
	SIGNAL_HANDLER

	if(owner.belt != src)
		return NONE
	if(SEND_SIGNAL(src, COMSIG_ITEM_HIT_REACT, owner, hitby, attack_text, damage, attack_type) & COMPONENT_HIT_REACTION_BLOCK)
		return SHIELD_BLOCK
	return NONE

// Our on hit effect
/obj/item/storage/belt/unfathomable_curio/proc/shield_damaged(mob/living/carbon/wearer, attack_text, new_current_charges)
	var/list/brain_traumas = list(
		/datum/brain_trauma/severe/mute,
		/datum/brain_trauma/severe/paralysis,
		/datum/brain_trauma/severe/monophobia
	)
	wearer.visible_message(span_danger("Zasłona [wearer] sprawia, że [attack_text] chybia, ale siła ciosu ją rozprasza!"))
	if(IS_HERETIC(wearer))
		return

	to_chat(wearer, span_warning("W twojej głowie rozbrzmiewa śmiech...."))
	wearer.adjustOrganLoss(ORGAN_SLOT_BRAIN, 40)
	wearer.dropItemToGround(src, TRUE)
	wearer.gain_trauma(pick(brain_traumas), TRAUMA_RESILIENCE_MAGIC)

/obj/item/storage/belt/unfathomable_curio/examine(mob/living/carbon/user)
	. = ..()
	if(IS_HERETIC(user) || !isliving(user))
		return

	user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10, 160)
	user.adjust_temp_blindness(5 SECONDS)
	. += span_notice("To. To spojrzało. TO SIĘ WOKÓŁ MNIE OWIJA.")
