/*
	ABSTRACT
	Item key
	This trait activates when an item key is used on it
*/
/datum/xenoartifact_trait/activator/item_key
	flags = XENOA_HIDE_TRAIT
	///What item type activates us?
	var/obj/item/key_item
	///Is the key item a strict type?
	var/is_strict = FALSE

/datum/xenoartifact_trait/activator/item_key/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	RegisterSignal(component_parent?.parent, COMSIG_PARENT_ATTACKBY, TYPE_PROC_REF(/datum/xenoartifact_trait/activator, translation_type_b))

/datum/xenoartifact_trait/activator/item_key/remove_parent(datum/source, pensive)
	if(!component_parent?.parent)
		return ..()
	UnregisterSignal(component_parent?.parent, COMSIG_PARENT_ATTACKBY)
	return ..()

/datum/xenoartifact_trait/activator/item_key/translation_type_b(datum/source, atom/item, atom/target)
	if(is_strict)
		. = item?.type == key_item.type
	else
		. = istype(item, key_item)
	return (. && !component_parent.use_cooldown_timer)

/*
	Cell
	This trait activates the artifact when a battery is used
*/
/datum/xenoartifact_trait/activator/item_key/cell
	label_name = "Cell"
	label_desc = "Cell: artefakt wygląda na wykonany z materiału pojemnościowego. Materiał ten zdaje się aktywować pod wpływem prądu, na przykład z ogniw."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	conductivity = 32
	key_item = /obj/item/stock_parts/cell

/datum/xenoartifact_trait/activator/item_key/cell/translation_type_b(datum/source, atom/item, atom/target)
	. = ..()
	do_hint(target, item)
	if(!.)
		return
	var/obj/item/stock_parts/cell/C = item
	if(C.charge-(C.maxcharge*0.25) >= 0 && !check_item_safety(item))
		C.use(C.maxcharge*0.25)
		trigger_artifact(target, XENOA_ACTIVATION_TOUCH)

/datum/xenoartifact_trait/activator/item_key/cell/do_hint(mob/user, atom/item)
	if(istype(item, /obj/item/multitool))
		to_chat(user, "<span class='warning'>[item] wykrywa pobór pojemnościowy na poziomie 25%!</span>")
		return ..()

/datum/xenoartifact_trait/activator/item_key/cell/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TRIGGER("naładowane ogniwo"), XENOA_TRAIT_HINT_DETECT("multitool"))

/*
	Greedy
	This trait activates the artifact when a coin is used
*/
/datum/xenoartifact_trait/activator/item_key/greedy
	material_desc = "szczelinowy"
	label_name = "Greedy"
	label_desc = "Greedy: artefakt wygląda na wykonany z kolekcjonerskiego materiału. Materiał ten zdaje się aktywować po wrzuceniu monet."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 32
	key_item = /obj/item/coin

/datum/xenoartifact_trait/activator/item_key/greedy/translation_type_b(datum/source, atom/item, atom/target)
	. = ..()
	if(!.)
		return
	handle_input(item, target)

/datum/xenoartifact_trait/activator/item_key/greedy/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TRIGGER("moneta"), XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("przyjmować monety jako aktywator"))

/datum/xenoartifact_trait/activator/item_key/greedy/proc/handle_input(atom/item, atom/target)
	var/atom/movable/movable = item
	movable.forceMove(component_parent.parent)
	playsound(component_parent.parent, 'sound/items/coinflip.ogg', 50, TRUE)
	trigger_artifact(target, XENOA_ACTIVATION_TOUCH)

//Credit variant
/datum/xenoartifact_trait/activator/item_key/greedy/credit
	label_name = "Greedy Δ"
	label_desc = "Greedy Δ: artefakt wygląda na wykonany z kolekcjonerskiego materiału. Materiał ten zdaje się aktywować po włożeniu holochipów kredytowych."
	key_item = /obj/item/holochip
	conductivity = 8
	///How many credits we need to activate
	var/credit_requirement = 1

/datum/xenoartifact_trait/activator/item_key/greedy/credit/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TRIGGER("holochip kredytowy"), XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("przyjmować holochipy kredytowe jako aktywator"))

/datum/xenoartifact_trait/activator/item_key/greedy/credit/handle_input(atom/item, atom/target)
	var/obj/item/holochip/C = item
	if(C.credits < credit_requirement)
		to_chat(target, "<span class='warning'>[component_parent.parent] żąda czegoś więcej niż twoja nędzna ofiara!</span>")
		playsound(component_parent.parent, 'sound/machines/buzz-sigh.ogg', 50, TRUE)
		return
	C.forceMove(component_parent.parent)
	playsound(component_parent.parent, 'sound/machines/terminal_insert_disc.ogg', 50, TRUE)
	trigger_artifact(target, XENOA_ACTIVATION_TOUCH)
	credit_requirement += 1
