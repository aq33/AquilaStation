/datum/action/vampire/bloodshield
	name = "Taumaturgia: Tarcza krwi"
	desc = "Stwórz tarczę krwi, która ochroni cię przed obrażeniami."
	button_icon_state = "power_bloodshield"
	background_icon_state_on = "tremere_power_gold_on"
	background_icon_state_off = "tremere_power_gold_off"
	power_explanation = "Aktywacja tej mocy daje ci tymczasowo tarczę krwi.\n\
		Tarcza krwi bardzo dobrze blokuje, ale każde przyjęte uderzenie kosztuje 15 krwi."

	power_flags = BP_AM_TOGGLE | BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS

	vitaecost = 25
	cooldown_time = 10 SECONDS
	constant_vitaecost = 3

	/// Blood shield given while this Power is active.
	var/datum/weakref/blood_shield

/datum/action/vampire/bloodshield/activate_power()
	. = ..()
	var/obj/item/shield/vampire/new_shield = new
	blood_shield = WEAKREF(new_shield)
	if(!owner.put_in_inactive_hand(new_shield))
		owner.balloon_alert(owner, "druga ręka jest zajęta!")
		to_chat(owner, span_notice("Nie da się przywołać tarczy krwi, bo druga ręka jest zajęta."))
		deactivate_power()
		return FALSE
	owner.visible_message(
		span_warning("[owner] zaczyna krwawić z dłoni, a krew formuje się w tarczę!"),
		span_warning("Przywołujesz tarczę krwi!"),
		span_hear("Słyszysz, jak coś płynnego zlewa się w całość."))

/datum/action/vampire/bloodshield/deactivate_power()
	. = ..()
	var/obj/item/shield/vampire/shield = blood_shield?.resolve()
	if(shield)
		qdel(shield)
	blood_shield = null

/**
 *	# Blood Shield
 *	Copied mostly from '/obj/item/shield/changeling'
 */
/obj/item/shield/vampire
	name = "tarcza krwi"
	desc = "Tarcza z krwi. Każde przyjęte uderzenie kosztuje krew."
	item_flags = ABSTRACT | DROPDEL
	icon = 'aquila/icons/vampires/vamp_obj.dmi'
	icon_state = "blood_shield"
	lefthand_file = 'aquila/icons/vampires/bs_leftinhand.dmi'
	righthand_file = 'aquila/icons/vampires/bs_rightinhand.dmi'
	block_power = 100

/obj/item/shield/vampire/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, TRAIT_VAMPIRE)

/obj/item/shield/vampire/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	var/datum/antagonist/vampire/vampire = IS_VAMPIRE(owner)
	vampire?.adjust_vitae(-15)
	return ..()
