// AQ - porządki w UI: zakładka "Squad" (oddział) połączona z "Faction" (frakcja).
// Panel pokazuje "Faction" jako "Oddział i frakcja"; u człowieka na górze jest
// jego oddział, pod kreską stan frakcji.

/mob/living/carbon/human/get_stat_tabs()
	var/list/tabs = ..()
	tabs -= "Squad"
	return tabs

/mob/living/carbon/human/get_stat(selected_tab)
	if(selected_tab != "Faction")
		return ..()
	var/list/tab_data = get_stat_tab_squad()
	tab_data["squad_faction_divider"] = list(type = STAT_DIVIDER)
	tab_data += ..()
	client.stat_update_mode = STAT_SLOW_UPDATE
	return tab_data
