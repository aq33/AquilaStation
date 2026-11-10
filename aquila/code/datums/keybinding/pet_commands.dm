// AQUILA - port of BeeStation/BeeStation-Hornet /datum/keybinding/living/view_pet_data (code/datums/keybinding/mob.dm).
// Held down while hovering a pet that obeys you opens its command menu (/datum/component/obeys_commands).
// Shift is shared with sprint and the examine cursor, as in Bee. Alt+click on the pet opens the same menu.
/datum/keybinding/living/view_pet_commands
	key = "Shift"
	name = "view_pet_commands"
	full_name = "Polecenia dla zwierząt"
	description = "Przytrzymaj i najedź myszą na oswojone zwierzę, żeby zobaczyć polecenia, które możesz mu wydać."
	keybind_signal = COMSIG_KB_LIVING_VIEW_PET_COMMANDS

/datum/keybinding/living/view_pet_commands/up(client/user)
	. = ..()
	SEND_SIGNAL(user.mob, DEACTIVATE_KEYBIND(COMSIG_KB_LIVING_VIEW_PET_COMMANDS))
