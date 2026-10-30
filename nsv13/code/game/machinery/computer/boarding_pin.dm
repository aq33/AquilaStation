GLOBAL_VAR_INIT(boarding_guns_z_locked, TRUE)

// Computer controlled
// Can work either on non-player-ship Z levels, or as a regular firing pin
/obj/item/firing_pin/boarding
	name = "iglica abordażowa"
	desc = "Ta zabezpieczająca iglica pozwala strzelać tylko na wrogich statkach, według uznania Komendanta."
	fail_message = "<span class='warning'>UŻYCIE NIEAUTORYZOWANE.</span>"
	pin_removeable = TRUE
	force_replace = TRUE
	req_one_access = list(ACCESS_ARMORY)

/obj/item/firing_pin/boarding/pin_auth(mob/living/user)
	if(!istype(user)) // Not a mob
		return FALSE
	if(allowed(user)) // The person has a weapons permit
		return TRUE
	if(on_friendly_overmap(user)) // On one of the NT ships
		// If they're locked don't fire
		if(GLOB.boarding_guns_z_locked)
			return FALSE
		else // Otherwise check the alert level
			return (GLOB.security_level >= SEC_LEVEL_RED)
	else // We're on a boarding level, fire away
		return TRUE

/obj/item/firing_pin/boarding/proc/on_friendly_overmap(mob/living/user)
	var/obj/structure/overmap/OM = user.get_overmap()
	if(!OM) // No overmap
		return FALSE
	if((OM.role == MAIN_OVERMAP) || (OM.role == MAIN_MINING_SHIP))
		return TRUE
	return FALSE

// A box
/obj/item/storage/box/boardingpins
        name = "pudełko iglic abordażowych"
        desc = "Pudełko pełne iglic abordażowych, żeby krewcy żołnierze nie zdemolowali statku."
        illustration = "id"

/obj/item/storage/box/boardingpins/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/firing_pin/boarding(src)

// The control computer
// This not being buildable is a feature, thank you have a nice day
/obj/machinery/computer/boarding_guns
	name = "konsola kontroli broni abordażowej"
	desc = "Służy do zdalnego blokowania albo autoryzowania broni z zamontowanymi iglicami abordażowymi."
	req_access = list(ACCESS_ARMORY)
	circuit = /obj/item/circuitboard/computer/boarding_guns
	light_color = LIGHT_COLOR_RED
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/circuitboard/computer/boarding_guns
	name = "konsola autoryzacji iglic abordażowych (płytka komputera)"
	build_path = /obj/machinery/computer/boarding_guns

/obj/machinery/computer/boarding_guns/ui_interact(mob/user)
	. = ..()

	var/dat = "[GLOB.boarding_guns_z_locked ? "Broń działa tylko poza okrętem." : "Broń działa podczas alarmu bojowego."]<br>"
	dat += "Obecny poziom alarmu: [get_security_level_pl()]<br>"

	if(!GLOB.boarding_guns_z_locked)
		dat += "<A href='byond://?src=[REF(src)];locked=true'>Zablokuj broń na okręcie.</A><br>"
	else
		dat += "<A href='byond://?src=[REF(src)];locked=false'>Odblokuj broń podczas alarmu bojowego.</A><br>"

	dat += "<a href='byond://?src=[REF(user)];mach_close=computer'>Zamknij</a>"

	var/datum/browser/popup = new(user, "computer", "Zarządzanie bronią abordażową", 300, 150) //width, height
	popup.set_content("<center>[dat]</center>")
	popup.open()


/obj/machinery/computer/boarding_guns/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)
	if(!allowed(usr))
		to_chat(usr, "<span class='danger'>Odmowa dostępu.</span>")
		return

	if(href_list["locked"] == "true")
		GLOB.boarding_guns_z_locked = TRUE
		say("Bolce abordażowe ustawione na: misja.")
	else if(href_list["locked"] == "false")
		GLOB.boarding_guns_z_locked = FALSE
		say("Bolce abordażowe ustawione na: alarm bojowy.")

	updateUsrDialog()
