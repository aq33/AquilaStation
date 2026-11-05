/**
 * Purifying a reagent in the ChemMaster buffer, for chemists who do not want to play with purity and pH.
 * The impure part is thrown away: 100u at 30% purity becomes 30u at 100% purity.
 * Called from the "purify" action in /obj/machinery/chem_master/ui_act (core hook).
 */
/obj/machinery/chem_master/proc/purify_buffer_reagent(reagent_type, mob/user)
	if(condi || !reagent_type)
		return FALSE
	var/datum/reagent/reagent
	for(var/datum/reagent/candidate as anything in reagents.reagent_list)
		if(candidate.type == reagent_type)
			reagent = candidate
			break
	if(!reagent || reagent.purity >= 1)
		return FALSE

	var/old_volume = reagent.volume
	var/pure_volume = round(old_volume * reagent.purity, CHEMICAL_VOLUME_ROUNDING)
	var/reagent_name = reagent.name
	if(old_volume > pure_volume)
		reagents.remove_reagent(reagent_type, old_volume - pure_volume)
	if(!QDELETED(reagent) && (reagent in reagents.reagent_list))
		reagent.purity = 1
		reagent.creation_purity = 1
	reagents.update_total()

	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	if(user)
		to_chat(user, "<span class='notice'>[src] oczyszcza [reagent_name]: zostaje [pure_volume]u czystego odczynnika, [round(old_volume - pure_volume, CHEMICAL_VOLUME_ROUNDING)]u zanieczyszczeń idzie do utylizacji.</span>")
	return TRUE
