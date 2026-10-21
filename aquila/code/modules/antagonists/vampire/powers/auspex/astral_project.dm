/datum/action/vampire/astral_projection
	name = "Projekcja astralna"
	desc = "Moc twojej krwi wzmacnia Postrzeganie. Możesz wysłać świadomość poza własne ciało."
	power_explanation = "Po aktywacji stajesz się duchem.\n\
		Odwiedzaj, co chcesz, obserwuj, kogo chcesz.\n\
		Rozmawiaj z duchami i poznaj wszystko."
	background_icon_state_on = "tremere_power_gold_on"
	background_icon_state_off = "tremere_power_gold_off"
	button_icon_state = "power_astral_projection"
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 400
	cooldown_time = 60 SECONDS

/datum/action/vampire/astral_projection/activate_power()
	. = ..()
	var/mob/dead/observer/ghost = owner.ghostize(can_reenter_corpse = TRUE)
	// cool name + color to make it obvious you're astral projecting
	var/ghost_name = "Astralny cień – [ghost.name]"
	ghost.name = ghost_name
	ghost.deadchat_name = ghost_name
	ghost.add_filter("astral_projection", 1, outline_filter(size = 1, color = BLOOD_COLOR_RED))
	deactivate_power()
