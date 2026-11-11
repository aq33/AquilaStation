// AQUILA - port of BeeStation/BeeStation-Hornet /datum/keybinding/living/view_pet_data (code/datums/keybinding/mob.dm).
// Held down while hovering a pet that obeys you opens its command menu (/datum/component/obeys_commands).
// Unbound by default: Bee uses Shift, but ours is sprint and the examine cursor, and saved keybinds never got it anyway.
// Alt+click on the pet opens the same menu; the key can be bound in the keybinding preferences.
/datum/keybinding/living/view_pet_commands
	key = "Unbound"
	name = "view_pet_commands"
	full_name = "Polecenia dla zwierząt"
	description = "Przytrzymaj i najedź myszą na oswojone zwierzę, żeby zobaczyć polecenia, które możesz mu wydać."
	keybind_signal = COMSIG_KB_LIVING_VIEW_PET_COMMANDS

/datum/keybinding/living/view_pet_commands/up(client/user)
	. = ..()
	SEND_SIGNAL(user.mob, DEACTIVATE_KEYBIND(COMSIG_KB_LIVING_VIEW_PET_COMMANDS))
