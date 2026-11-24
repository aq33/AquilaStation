// HUD diagnostyczny basic botów (jak /mob/living/simple_animal/bot w code/game/data_huds.dm)

/mob/living/basic/bot/proc/diag_hud_set_bothealth()
	var/image/holder = hud_list?[DIAG_HUD]
	if(!holder)
		return
	holder.pixel_y = get_cached_height() - world.icon_size
	holder.icon_state = "huddiag[RoundDiagBar(health/maxHealth)]"

/mob/living/basic/bot/proc/diag_hud_set_botstat()
	var/image/holder = hud_list?[DIAG_STAT_HUD]
	if(!holder)
		return
	holder.pixel_y = get_cached_height() - world.icon_size
	if(bot_mode_flags & BOT_MODE_ON)
		holder.icon_state = "hudstat"
	else if(stat)
		holder.icon_state = "hudoffline"
	else
		holder.icon_state = "huddead2"

/mob/living/basic/bot/proc/diag_hud_set_botmode()
	var/image/holder = hud_list?[DIAG_BOT_HUD]
	if(!holder)
		return
	holder.pixel_y = get_cached_height() - world.icon_size
	if(client)
		holder.icon_state = "hudsentient"
		return
	switch(mode)
		if(BBOT_SUMMON)
			holder.icon_state = "hudcalled"
		if(BBOT_CLEANING, BBOT_REPAIRING, BBOT_HEALING, BBOT_WORKING)
			holder.icon_state = "hudworking"
		if(BBOT_PATROL)
			holder.icon_state = "hudpatrol"
		if(BBOT_ARREST, BBOT_HUNT)
			holder.icon_state = "hudalert"
		if(BBOT_MOVING, BBOT_DELIVER, BBOT_GO_HOME)
			holder.icon_state = "hudmove"
		else
			holder.icon_state = ""
