/datum/plant_trait/fruit/temperature
	name = "Podgrzewana zawartość"
	desc = "Aktywowany owoc gwałtownie podgrzewa swoją zawartość."
	/// How hot or cold are we trying to make our reagents?
	var/target_temperature = 666
	/// How many ticks to reach target
	var/target_coefficient = 0.089
	/// Verb + friends for visible message
	var/temperature_verb = "nagrzewać"

/datum/plant_trait/fruit/temperature/setup_fruit_parent()
	. = ..()
	RegisterSignal(fruit_parent, COMSIG_FRUIT_ACTIVATE_TARGET, TYPE_PROC_REF(/datum/plant_trait/fruit, catch_activate))
	RegisterSignal(fruit_parent, COMSIG_FRUIT_ACTIVATE_NO_CONTEXT, TYPE_PROC_REF(/datum/plant_trait/fruit, catch_activate))

/datum/plant_trait/fruit/temperature/catch_activate(datum/source)
	. = ..()
	if(QDELING(src) || QDELING(fruit_parent))
		return
	fruit_parent?.visible_message("<span class='warning'>[fruit_parent] zaczyna się [temperature_verb]!</span>")
	START_PROCESSING(SSobj, src)

/datum/plant_trait/fruit/temperature/process(delta_time)
	if(!fruit_parent.reagents || !length(fruit_parent.reagents.reagent_list))
		return ..()
	if(QDELING(src) || QDELING(fruit_parent))
		return ..()
	//This is just stolen from the chem heater
	fruit_parent.reagents.adjust_thermal_energy((target_temperature - fruit_parent.reagents.chem_temp) * target_coefficient * delta_time * SPECIFIC_HEAT_DEFAULT * fruit_parent.reagents.total_volume)
	fruit_parent.reagents.handle_reactions()

/*
	Cooling variant
*/
/datum/plant_trait/fruit/temperature/cold
	name = "Chłodzona zawartość"
	desc = "Aktywowany owoc gwałtownie schładza swoją zawartość."
	target_temperature = -666
	temperature_verb = "schładzać"
