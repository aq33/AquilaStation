/datum/action/cooldown/spell/pointed/burglar_finesse
	name = "Burglar's Finesse"
	desc = "Kradnie losowy przedmiot z plecaka ofiary."
	background_icon_state = "bg_ecult"
	overlay_icon_state = "bg_ecult"
	icon_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "burglarsfinesse"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 40 SECONDS

	invocation = "Y'O'K!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 6

/datum/action/cooldown/spell/pointed/burglar_finesse/is_valid_target(mob/living/carbon/human/cast_on)
	if(!istype(cast_on))
		return FALSE
	// AQUILA - u nas schowek to komponent storage
	var/obj/item/back_item = cast_on.get_item_by_slot(ITEM_SLOT_BACK)
	return ..() && back_item?.GetComponent(/datum/component/storage)

/datum/action/cooldown/spell/pointed/burglar_finesse/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_danger("Czujesz lekkie szarpnięcie, ale nic ci nie jest - chroniła cię świętość!"))
		to_chat(owner, span_danger("[cast_on] jest chroniony przez święte moce!"))
		return FALSE

	var/obj/storage_item = cast_on.get_item_by_slot(ITEM_SLOT_BACK)

	if(isnull(storage_item))
		return FALSE

	var/list/stored_items = list()
	SEND_SIGNAL(storage_item, COMSIG_TRY_STORAGE_RETURN_INVENTORY, stored_items, FALSE)
	if(!length(stored_items))
		return FALSE
	var/obj/item/item = pick(stored_items)
	if(!SEND_SIGNAL(storage_item, COMSIG_TRY_STORAGE_TAKE, item, owner.drop_location(), TRUE))
		return FALSE

	to_chat(cast_on, span_warning("Twój [storage_item.name] wydaje się lżejszy..."))
	to_chat(owner, span_notice("W mgnieniu oka wyciągasz [item.name] z [storage_item.name] [cast_on]."))
	var/mob/living/living_owner = owner
	if(istype(living_owner))
		living_owner.put_in_active_hand(item)
