///AI Upgrades


//Malf Picker
/obj/item/malf_upgrade
	name = "ulepszenie oprogramowania bojowego"
	desc = "Wysoce nielegalne i wysoce niebezpieczne ulepszenie dla jednostek sztucznej inteligencji, które daje im różne moce oraz zdolność hakowania APC.<br>To ulepszenie nie nadpisuje aktywnych praw i trzeba je zainstalować bezpośrednio w aktywnym rdzeniu SI."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk3"


/obj/item/malf_upgrade/afterattack(mob/living/silicon/ai/AI, mob/user)
	. = ..()
	if(!istype(AI))
		return
	if(AI.malf_picker)
		AI.malf_picker.processing_time += 50
		to_chat(AI, "<span class='userdanger'>[user] próbuje cię ulepszyć oprogramowaniem bojowym, które już masz. Zamiast tego zyskujesz 50 punktów do wydania na Moduły Awarii.</span>")
	else
		to_chat(AI, "<span class='userdanger'>[user] ulepsza cię oprogramowaniem bojowym!</span>")
		to_chat(AI, "<span class='userdanger'>Twoje obecne prawa i cele pozostają bez zmian.</span>") //this unlocks malf powers, but does not give the license to plasma flood
		AI.add_malf_picker()
		log_game("[key_name(user)] has upgraded [key_name(AI)] with a [src].")
		message_admins("[ADMIN_LOOKUPFLW(user)] ulepsza [ADMIN_LOOKUPFLW(AI)] za pomocą [src].")
	to_chat(user, "<span class='notice'>Ulepszasz [AI]. [src] zostaje przy tym zużyty.</span>")
	qdel(src)


//Lipreading
/obj/item/surveillance_upgrade
	name = "ulepszenie oprogramowania do inwigilacji"
	desc = "Nielegalny pakiet oprogramowania, dzięki któremu sztuczna inteligencja może „słyszeć” przez kamery, czytając z ruchu warg i korzystając z ukrytych mikrofonów."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk3"

/obj/item/surveillance_upgrade/afterattack(mob/living/silicon/ai/AI, mob/user)
	. = ..()
	if(!istype(AI))
		return
	if(AI.eyeobj)
		AI.eyeobj.set_relay_speech(TRUE)
		to_chat(AI, "<span class='userdanger'>[user] ulepsza cię oprogramowaniem do inwigilacji!</span>")
		to_chat(AI, "Dzięki ukrytym mikrofonom i oprogramowaniu do czytania z ruchu warg możesz podsłuchiwać rozmowy przez kamery.")
	to_chat(user, "<span class='notice'>Ulepszasz [AI]. [src] zostaje przy tym zużyty.</span>")
	log_game("[key_name(user)] has upgraded [key_name(AI)] with a [src].")
	message_admins("[ADMIN_LOOKUPFLW(user)] ulepsza [ADMIN_LOOKUPFLW(AI)] za pomocą [src].")
	qdel(src)
