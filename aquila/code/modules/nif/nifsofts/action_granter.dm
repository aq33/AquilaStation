// AQUILA - NIFSoft dający akcję, gdy jest włączony. Port z Monkestation (nifsofts/action_granter.dm).

/datum/nifsoft/action_granter
	active_mode = TRUE
	activation_cost = 10
	active_cost = 1
	/// Typ dawanej akcji
	var/action_to_grant = /datum/action/innate
	/// Dana akcja
	var/datum/action/innate/granted_action

/datum/nifsoft/action_granter/activate()
	. = ..()
	if(!.)
		return
	if(active)
		granted_action = new action_to_grant(linked_mob)
		granted_action.Grant(linked_mob)
		return

	QDEL_NULL(granted_action)

/datum/nifsoft/action_granter/Destroy()
	QDEL_NULL(granted_action)
	return ..()
