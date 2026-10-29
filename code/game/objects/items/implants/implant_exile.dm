// AQ EDIT - Exile implants mark the wearer for digital exile: put them into a netpod and they are sent to the Loop forever.
// (aquila/code/modules/bitrunning/exile). Gateways are gone from our maps.

/obj/item/implant/exile
	name = "implant wygnania"
	desc = "Oznacza nosiciela do cyfrowego wygnania. Gdy trafi do netpoda, zostanie na zawsze przeniesiony do Pętli."
	activated = 0

/obj/item/implant/exile/get_data()
	var/dat = {"<b>Specyfikacja implantu:</b><BR><b>Nazwa:</b> Implant wygnania pracownika Nanotrasen<BR><b>Szczegóły implantu:</b> netpod, który wykryje ten implant, rozpoczyna procedurę cyfrowego wygnania: świadomość nosiciela zostaje na zawsze przeniesiona do Pętli, cyfrowego więzienia, z którego nie ma powrotu.<BR>"}
	return dat

/obj/item/implanter/exile
	name = "implanter (wygnanie)"
	imp_type = /obj/item/implant/exile

/obj/item/implantcase/exile
	name = "etui na implant – „Wygnanie”"
	desc = "Szklane etui z implantem wygnania."
	imp_type = /obj/item/implant/exile


//For hotel staff, prevents them entering the station Z-level, dusts you if you remove it

/obj/item/implant/exile/hotel
	name = "superimplant wygnania"
	desc = "niezła próba, obsługo hotelu"

/obj/item/implant/exile/hotel/on_implanted(mob/user)
	user.AddComponent(/datum/component/stationloving/hotelloving)

/obj/item/implant/exile/hotel/removed(mob/unimplanted) // Incase they try self surgery
	visible_message("<span class='danger'>Aktywują się mechanizmy implantu zapobiegające usunięciu!</span>")
	unimplanted.dust()
	message_admins("[ADMIN_LOOKUPFLW(unimplanted)] próbuje usunąć implant obsługi hotelu, żeby wejść na stację, i obraca się w pył.")
	if(!QDELETED(src)) //If you try to qdel when the implant is removed without an implant case it causes a loop of qdels and gibbing
		qdel(src)

/datum/component/stationloving/hotelloving/in_bounds()
	if(SSticker.current_state <= GAME_STATE_PREGAME)
		return TRUE
	var/turf/T = get_turf(parent)
	if(!T)
		return FALSE
	if(is_station_level(T.z)) // Are they on the station Z-level? If so trigger relocate()
		return FALSE
	return TRUE

//Override to plop the disk back to a syndie crew spawn rather than somewhere on the station.

/datum/component/stationloving/hotelloving/relocate()
	var/mob/hotelstaff = parent
	if(ismob(hotelstaff))
		if(!QDELETED(src)) // if you don't do this the body gets continuously dusted forever. While this is funny, an infinitely large pile of remains that crashes clients on right click isn't.
			qdel(src)
		to_chat(hotelstaff,"<span class='danger'>Aktywują się mechanizmy implantu zapobiegające ucieczce!</span>")
		hotelstaff.dust() // Nice try hotel staff
		message_admins("[ADMIN_LOOKUPFLW(hotelstaff)] próbuje wejść na stację jako obsługa hotelu i obraca się w pył.")
	else
		qdel(src) // This should only ever be applied to mobs
