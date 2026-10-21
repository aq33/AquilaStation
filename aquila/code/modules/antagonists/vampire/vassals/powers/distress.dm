/datum/action/vampire/distress
	name = "Wezwanie pomocy"
	desc = "Zrań się, aby rozpaczliwie wezwać na pomoc swojego pana."
	button_icon_state = "power_distress"
	power_explanation = "Użyj tej mocy gdziekolwiek, a twój pan natychmiast dowie się, gdzie jesteś."
	power_flags = NONE
	check_flags = NONE
	special_flags = NONE
	vitaecost = 10
	cooldown_time = 10 SECONDS

/datum/action/vampire/distress/activate_power()
	. = ..()
	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(owner)

	owner.balloon_alert(owner, "wzywasz swojego pana!")
	to_chat(vassaldatum.master.owner, span_userdanger("[owner.name], twój wierny wasal, rozpaczliwie wzywa pomocy! Miejsce: [get_area(owner)]!"))

	var/mob/living/living_owner = owner
	living_owner.adjustBruteLoss(10)
	deactivate_power()
