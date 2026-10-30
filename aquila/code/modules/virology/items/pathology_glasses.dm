// Okulary patologa — port z Monkestation2.0 (items/pathology_glasses.dm + datums/components/pathology_glasses.dm).
// U nas okulary nie mają komponentu z tg (brak add_item_action/color_cutoffs), więc przełącznik
// siedzi wprost na przedmiocie i działa przez nasz /datum/action/item_action/toggle.

/obj/item/clothing/glasses/pathology
	name = "gogle analityczne patologa"
	desc = "Gogle z analizatorem cząstek wirusowych i odczynników. Mają przełącznik, żeby nie zalewało wzroku."
	icon = 'icons/obj/clothing/glasses.dmi'
	icon_state = "pathology_on"
	item_state = "glasses"
	actions_types = list(/datum/action/item_action/toggle)
	/// Czy podgląd patogenów jest włączony.
	var/pathology_enabled = TRUE
	var/icon_state_on = "pathology_on"
	var/icon_state_off = "pathology_off"

/obj/item/clothing/glasses/pathology/Initialize(mapload)
	. = ..()
	update_icon_state()

/obj/item/clothing/glasses/pathology/update_icon_state()
	icon_state = pathology_enabled ? icon_state_on : icon_state_off
	return ..()

/obj/item/clothing/glasses/pathology/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Podgląd patogenów jest <b>[pathology_enabled ? "włączony" : "wyłączony"]</b>. Użyj przycisku akcji, żeby przełączyć.</span>"

/obj/item/clothing/glasses/pathology/equipped(mob/living/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_EYES && pathology_enabled)
		add_virus_view(user)

/obj/item/clothing/glasses/pathology/dropped(mob/living/user)
	. = ..()
	remove_virus_view(user)

/obj/item/clothing/glasses/pathology/proc/add_virus_view(mob/living/user)
	if(!istype(user))
		return
	ADD_TRAIT(user, TRAIT_VIRUS_SCANNER, "[REF(src)]")
	user.AddElement(/datum/element/virus_viewer)

/obj/item/clothing/glasses/pathology/proc/remove_virus_view(mob/living/user)
	if(!istype(user))
		return
	REMOVE_TRAIT(user, TRAIT_VIRUS_SCANNER, "[REF(src)]")
	if(!HAS_TRAIT(user, TRAIT_VIRUS_SCANNER))
		user.RemoveElement(/datum/element/virus_viewer)

/obj/item/clothing/glasses/pathology/ui_action_click(mob/user, datum/actiontype)
	pathology_enabled = !pathology_enabled
	if(pathology_enabled)
		add_virus_view(user)
	else
		remove_virus_view(user)
	update_icon_state()
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		human_user.update_inv_glasses()
	to_chat(user, "<span class='notice'>[pathology_enabled ? "Włączasz" : "Wyłączasz"] podgląd patogenów.</span>")

/obj/item/clothing/glasses/pathology/sunglasses
	name = "okulary analityczne patologa"
	desc = "Przeciwsłoneczne okulary z analizatorem cząstek wirusowych i odczynników."
	icon_state = "sunhudpatho_on"
	icon_state_on = "sunhudpatho_on"
	icon_state_off = "sunhudpatho_off"
	flash_protect = 1
	tint = 1

/obj/item/clothing/glasses/pathology/night
	name = "noktowizyjne gogle patologa"
	desc = "Noktowizor z analizatorem cząstek wirusowych i odczynników."
	icon_state = "pathohudnight_on"
	icon_state_on = "pathohudnight_on"
	icon_state_off = "pathohudnight_off"
	darkness_view = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	flash_protect = -1
