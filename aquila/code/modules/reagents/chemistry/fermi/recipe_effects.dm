// Zachowania przy przegrzaniu (overheated) i zbyt niskiej czystości (overly_impure) z tg
// (tgstation@b3949ec362, recipes/medicine.dm, drugs.dm, others.dm) dla przepisów, które mamy też my.
// Parametry tych przepisów (temperatury, pH itd.) są w wygenerowanym fermi_data.dm.

/datum/chemical_reaction/oculine/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	. = ..()
	explode_flash(holder, equilibrium, round(equilibrium.reacted_vol / 10), 10)

/datum/chemical_reaction/oculine/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	. = ..()
	explode_flash(holder, equilibrium, 3, 30)

/datum/chemical_reaction/inacusiate/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	holder.my_atom.audible_message("<span class='notice'>[holder.my_atom] nagle wydaje głośny huk!</span>")
	explode_deafen(holder, equilibrium, 0.5, 10, 3)

/datum/chemical_reaction/inacusiate/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	var/power = equilibrium.reacted_vol / 10
	holder.my_atom.audible_message("<span class='notice'>[holder.my_atom] nagle wydaje ogłuszająco głośny huk!</span>")
	explode_deafen(holder, equilibrium, power / 2, power * 2, max(power / 2, 3))
	clear_products(holder)

/datum/chemical_reaction/ephedrine/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	reagent_explode(holder, equilibrium.reacted_vol, 0, 25)

/datum/chemical_reaction/ephedrine/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	reagent_explode(holder, equilibrium.reacted_vol, 0, 20)

/datum/chemical_reaction/mannitol/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	if(off_cooldown(holder, equilibrium, 10, "mannitol"))
		explode_attack_chem(holder, equilibrium, /datum/reagent/inverse, 5) // tg: Mannitoil, którego u nas nie ma
		explode_invert_smoke(holder, equilibrium)

/datum/chemical_reaction/mannitol/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	overheated(holder, equilibrium, vol_added)

/datum/chemical_reaction/neurine/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	if(off_cooldown(holder, equilibrium, 10, "neurine"))
		explode_invert_smoke(holder, equilibrium, clear_products = FALSE, clear_reactants = FALSE)
		explode_attack_chem(holder, equilibrium, /datum/reagent/inverse/neurine, 10)
		clear_products(holder, 5)

/datum/chemical_reaction/neurine/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	overheated(holder, equilibrium, vol_added)

/datum/chemical_reaction/antihol/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	explode_smoke(holder, equilibrium)

/datum/chemical_reaction/antihol/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, vol_added)
	explode_smoke(holder, equilibrium)

/datum/chemical_reaction/nitrous_oxide/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, step_volume_added)
	. = ..()
	var/turf/open/exposed_turf = get_turf(holder.my_atom)
	if(!istype(exposed_turf))
		return
	exposed_turf.atmos_spawn_air("n2o=[equilibrium.step_target_vol / 2];TEMP=[holder.chem_temp]")
	clear_products(holder, equilibrium.step_target_vol)

/datum/chemical_reaction/nitrous_oxide/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, step_volume_added)
	return //tg: the n2o explosion reaction happens instead

/datum/chemical_reaction/methamphetamine/reaction_step(datum/reagents/holder, datum/equilibrium/reaction, delta_t, delta_ph, step_reaction_vol)
	var/datum/reagent/meth = holder.get_reagent(/datum/reagent/drug/methamphetamine)
	if(!meth)//First step
		reaction.thermic_mod = (1 - delta_ph) * 5
		return
	reaction.thermic_mod = (1 - meth.purity) * 5

/datum/chemical_reaction/methamphetamine/overheated(datum/reagents/holder, datum/equilibrium/equilibrium, step_volume_added)
	. = ..()
	temp_meth_explosion(holder, equilibrium.reacted_vol)

/datum/chemical_reaction/methamphetamine/overly_impure(datum/reagents/holder, datum/equilibrium/equilibrium, step_volume_added)
	. = ..()
	temp_meth_explosion(holder, equilibrium.reacted_vol)

/datum/chemical_reaction/methamphetamine/reaction_finish(datum/reagents/holder, datum/equilibrium/reaction, react_vol)
	var/datum/reagent/meth = holder.get_reagent(/datum/reagent/drug/methamphetamine)
	if(!meth)//Other procs before this can already blow us up
		return ..()
	if(meth.purity < purity_min)
		temp_meth_explosion(holder, react_vol)
		return
	return ..()

/// Meth reactions blow up when they overheat or get too impure
/datum/chemical_reaction/methamphetamine/proc/temp_meth_explosion(datum/reagents/holder, explode_vol)
	if(ismob(holder.my_atom))
		return
	reagent_explode(holder, explode_vol, 5, 12) //meth strengthdiv is 12
