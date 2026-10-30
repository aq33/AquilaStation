/obj/item/firing_pin/off_station
	name = "iglica pozastacyjna"
	desc = "Pozwala strzelać z broni, gdy nie jesteś na stacji."
	fail_message = "<span class='warning'>BLOKADA BEZPIECZEŃSTWA STACJI WŁĄCZONA.</span>"
	pin_removeable = TRUE

/obj/item/firing_pin/off_station/pin_auth(mob/living/user)
	if(!istype(user))
		return FALSE
	var/turf/T = get_turf(user)
	if(!T)
		return FALSE
	if(is_station_level(T.z))
		return FALSE
	return TRUE
