/datum/plant_trait/roots/no_weeds
	name = "Allelopatia"
	desc = "Ten gen sprawia, że korzenie wydzielają związki hamujące wzrost, które nie pozwalają rosnąć chwastom."
	genetic_cost = 1
	scales = "Tempo usuwania chwastów rośnie z mocą cech."
	/// Amount of weeds we remove per cycle
	var/weed_remove = 0.3

/datum/plant_trait/roots/no_weeds/setup_component_parent(datum/source)
	. = ..()
	if(!parent || !parent.parent)
		return
	START_PROCESSING(SSobj, src)

/datum/plant_trait/roots/no_weeds/process(delta_time)
	var/datum/component/planter/plant_tray = parent.parent.plant_item.loc.GetComponent(/datum/component/planter)
	if(!plant_tray)
		return
	plant_tray.weed_level -= (weed_remove * parent.trait_power) * delta_time;
	plant_tray.weed_level = max(0, plant_tray.weed_level)
