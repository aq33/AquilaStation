/*
	Porous
	The artifact replaces one random gas with another
*/
/datum/xenoartifact_trait/major/gas
	label_name = "Porous"
	label_desc = "Porous: artefakt wydaje się zawierać elementy porowate. Ich aktywacja sprawi, że artefakt zamieni jeden gaz w inny."
	cooldown = XENOA_TRAIT_COOLDOWN_SAFE
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 15
	register_targets = FALSE
	///Possible target gasses
	var/list/target_gasses = list(
		GAS_O2 = 6,
		GAS_N2 = 3,
		GAS_PLASMA = 1,
		GAS_CO2 = 1,
		GAS_H2O = 3
	)
	///Possible exchange gasses
	var/list/exchange_gasses = list(
		GAS_BZ = 3,
		GAS_HYPERNOB = 1,
		GAS_PLASMA = 3,
		GAS_TRITIUM = 2,
		GAS_NITRYL = 1
	)
	///Choosen target gas (id auxmos)
	var/choosen_target
	///Choosen exchange gas (id auxmos)
	var/choosen_exchange
	///Max amount of moles we exchange at once
	var/max_moles = 10

/datum/xenoartifact_trait/major/gas/New(atom/_parent)
	. = ..()
	choosen_target = pickweight(target_gasses)
	choosen_exchange = pickweight(exchange_gasses)

/datum/xenoartifact_trait/major/gas/register_parent(datum/source)
	. = ..()
	if(!component_parent?.parent)
		return
	setup_generic_item_hint()

/datum/xenoartifact_trait/major/gas/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	var/turf/open/T = get_turf(component_parent.parent)
	if(!istype(T))
		return
	var/datum/gas_mixture/air = T.air
	if(!air)
		return
	var/moles = min(air.get_moles(choosen_target), max_moles)
	if(!moles)
		return

	air.adjust_moles(choosen_target, -moles)
	air.adjust_moles(choosen_exchange, moles)
	T.air_update_turf()

/datum/xenoartifact_trait/major/gas/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_RANDOMISED, XENOA_TRAIT_HINT_DETECT("analizator gazów, który pokaże też, jakie gazy artefakt wymienia"))

/datum/xenoartifact_trait/major/gas/do_hint(mob/user, atom/item)
	if(istype(item, /obj/item/analyzer))
		to_chat(user, span_warning("[item] wykrywa zamianę gazu [GLOB.gas_data.names[choosen_target]] w [GLOB.gas_data.names[choosen_exchange]] w tempie [max_moles] moli!"))
		return ..()
