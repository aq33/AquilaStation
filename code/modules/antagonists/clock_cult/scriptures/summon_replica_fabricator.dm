//==================================//
// !       Replica Fab       ! //
//==================================//

/datum/clockcult/scripture/replica_fabricator
	name = "Fabrykator replik"
	desc = "Przywołuje fabrykator replik, który wytwarza mosiądz do budowy umocnień."
	tip = "Wytwarza mosiądz i naprawia struktury"
	button_icon_state = "Replica Fabricator"
	power_cost = 400
	cogs_required = 2
	invokation_time = 50
	invokation_text = list("Ich technologia nie ma szans z mocą Eng'ine'a.")
	category = SPELLTYPE_STRUCTURES

/datum/clockcult/scripture/replica_fabricator/invoke_success()
	var/obj/item/clockwork/replica_fabricator/RF = new(get_turf(invoker))
	invoker.put_in_inactive_hand(RF)
