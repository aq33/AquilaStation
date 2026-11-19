// AQUILA - przycisk akcji otwierający okno NIF. Port z Monkestation (nif_actions.dm).

/datum/action/item_action/nif
	button_icon = 'aquila/icons/monke/nif/nif_action_backgrounds.dmi'
	background_icon_state = "android"
	icon_icon = 'aquila/icons/monke/nif/nif_actions.dmi'
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/nif/open_menu
	name = "Otwórz menu NIF"
	desc = "Pokazuje stan NIF-u i zainstalowane NIFSofty."
	button_icon_state = "user"

// Przycisk akcji woła ui_action_click() implantu (item_action/Trigger)
/obj/item/organ/cyberimp/nif/ui_action_click(mob/user, datum/actiontype)
	if(!istype(actiontype, /datum/action/item_action/nif/open_menu))
		return ..()

	if(calibrating)
		send_message("NIF wciąż się kalibruje, poczekaj!", alert = TRUE)
		return FALSE

	if(durability < 1)
		send_message("Za niska wytrzymałość!", alert = TRUE)
		return FALSE

	if(broken)
		send_message("NIF jest teraz niedostępny!", alert = TRUE)
		return FALSE

	ui_interact(user)
	return TRUE
