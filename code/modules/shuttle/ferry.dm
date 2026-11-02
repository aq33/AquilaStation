/obj/machinery/computer/shuttle_flight/ferry
	name = "konsola promu transportowego"
	desc = "Konsola sterująca promem transportowym."
	circuit = /obj/item/circuitboard/computer/ferry
	shuttleId = "ferry"
	possible_destinations = "ferry_home;ferry_away"
	req_access = list(ACCESS_CENT_GENERAL)

	var/allow_silicons = FALSE
	var/allow_emag = FALSE

/obj/machinery/computer/shuttle_flight/ferry/emag_act(mob/user)
	if(!allow_emag)
		to_chat(user, "<span class='warning'>Zapora bezpieczeństwa [src] jest zbyt potężna, byś mógł ją obejść.</span>")
		return FALSE
	return ..()

/obj/machinery/computer/shuttle_flight/ferry/attack_ai()
	return allow_silicons ? ..() : FALSE

/obj/machinery/computer/shuttle_flight/ferry/attack_robot()
	return allow_silicons ? ..() : FALSE

/obj/machinery/computer/shuttle_flight/ferry/request
	name = "konsola promu"
	circuit = /obj/item/circuitboard/computer/ferry/request
	var/last_request //prevents spamming admins
	var/cooldown = 600
	possible_destinations = "ferry_home;ferry_away"
	req_access = list(ACCESS_CENT_GENERAL)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/machinery/computer/shuttle_flight/ferry/request/Topic(href, href_list)
	..()
	if(href_list["request"])
		if(last_request && (last_request + cooldown > world.time))
			return
		last_request = world.time
		to_chat(usr, "<span class='notice'>Twoja prośba została odebrana przez Centralę.</span>")
		to_chat(GLOB.admins, "<b>PROM: <font color='#3d5bc3'>[ADMIN_LOOKUPFLW(usr)] (<A HREF='byond://?_src_=holder;[HrefToken()];secrets=moveferry'>Przenieś prom</a>)</b> prosi o przeniesienie promu transportowego do Centrali.</font>")
