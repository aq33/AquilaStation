/*
	Observational
	This trait activates the artifact when it's examined
*/
/datum/xenoartifact_trait/activator/examine
	label_name = "Observational"
	label_desc = "Observational: artefakt wygląda na wykonany z materiału światłoczułego. Materiał ten zdaje się aktywować, gdy ktoś mu się przygląda."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 16

/datum/xenoartifact_trait/activator/examine/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	//Register all the relevant signals we trigger from
	RegisterSignal(component_parent?.parent, COMSIG_PARENT_EXAMINE, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_a))

/datum/xenoartifact_trait/activator/examine/remove_parent(datum/source, pensive)
	if(!component_parent?.parent)
		return ..()
	UnregisterSignal(component_parent?.parent, COMSIG_PARENT_EXAMINE)
	return ..()

/datum/xenoartifact_trait/activator/examine/translation_type_a(datum/source, atom/target)
	if(isliving(target))
		trigger_artifact(target, XENOA_ACTIVATION_SPECIAL)
		return
