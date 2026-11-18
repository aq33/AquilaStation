// AQUILA - NIFSoft „Automatyczna wycena”: przy oględzinach pokazuje wartość eksportową przedmiotu.
// Port z Monkestation (nifsofts/money_sense.dm).

/obj/item/disk/nifsoft_uploader/money_sense
	loaded_nifsoft = /datum/nifsoft/money_sense

/datum/nifsoft/money_sense
	name = "Automatyczna wycena"
	program_desc = "Łączy mózg nosiciela z bazą aktualnych cen większości przedmiotów, dzięki czemu na bieżąco zna ich wartość."
	active_mode = TRUE
	active_cost = 0.5
	compatible_nifs = list(/obj/item/organ/cyberimp/nif/standard)
	buying_category = NIFSOFT_CATEGORY_UTILITY
	ui_icon = "coins"

/datum/nifsoft/money_sense/activate()
	. = ..()
	if(!.)
		return
	if(active)
		linked_mob.AddComponent(/datum/component/money_sense)
		return

	var/datum/component/money_sense/found_component = linked_mob?.GetComponent(/datum/component/money_sense)
	if(found_component)
		qdel(found_component)

/// Dodawany, gdy działa NIFSoft „Automatyczna wycena”
/datum/component/money_sense

/datum/component/money_sense/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_MOB_EXAMINATE, PROC_REF(add_examine))

/datum/component/money_sense/Destroy(force, silent)
	UnregisterSignal(parent, COMSIG_MOB_EXAMINATE)
	return ..()

/// Wycenia oglądany przedmiot jak skaner eksportu, ale bez skanowania
/datum/component/money_sense/proc/add_examine(mob/user, atom/target)
	SIGNAL_HANDLER

	if(!isobj(target))
		return FALSE

	var/datum/export_report/export = export_item_and_contents(target, dry_run = TRUE)
	var/price = 0
	for(var/x in export.total_amount)
		price += export.total_value[x]

	if(price)
		to_chat(parent, span_noticealien("Wartość eksportowa tego przedmiotu: <b>[price] kr.</b>"))
	else
		to_chat(parent, span_warning("Ten przedmiot nie ma wartości eksportowej."))
