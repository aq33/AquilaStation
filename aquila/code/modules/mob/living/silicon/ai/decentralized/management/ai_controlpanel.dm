GLOBAL_VAR_INIT(ai_control_code, random_ai_control_code())

/proc/random_ai_control_code()
	return "[rand(100000, 999999)]"

/obj/machinery/computer/ai_control_console
	name = "konsola sterowania SI"
	desc = "Dostęp do centralnego repozytorium SI: wgrywanie SI z intellicardu albo MMI do rdzeni danych i pobieranie SI na intellicard."
	req_one_access = list(ACCESS_RD, ACCESS_CE)
	circuit = /obj/item/circuitboard/computer/ai_upload_download
	icon_keyboard = "tech_key"
	icon_screen = "ai-fixer"
	light_color = LIGHT_COLOR_PINK

	var/one_time_password_used = FALSE //Did we use the one time password to log in? If so disallow logging out.

	var/obj/item/aicard/intellicard

	var/mob/living/silicon/ai/downloading
	var/mob/user_downloading
	var/download_progress = 0
	var/download_warning = FALSE

/obj/machinery/computer/ai_control_console/Destroy()
	stop_download(TRUE)
	if(intellicard)
		intellicard.forceMove(drop_location())
		intellicard = null
	return ..()

/obj/machinery/computer/ai_control_console/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/aicard))
		if(intellicard)
			balloon_alert(user, "intellicard już włożony!")
			return TRUE
		if(user.transferItemToLoc(I, src))
			to_chat(user, span_notice("Wkładasz [I] do [src]."))
			intellicard = I
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 25, FALSE)
			SStgui.update_uis(src)
		return TRUE

	if(istype(I, /obj/item/mmi))
		if(!authenticated)
			balloon_alert(user, "musisz być zalogowany!")
			return TRUE
		upload_mmi(I, user)
		return TRUE

	if(istype(I, /obj/item/surveillance_upgrade) || istype(I, /obj/item/malf_upgrade))
		if(!authenticated)
			balloon_alert(user, "musisz być zalogowany!")
			return TRUE
		var/mob/living/silicon/ai/AI = tgui_input_list(user, "Wybierz SI", "Wybór SI", GLOB.ai_list)
		if(!AI || QDELETED(I) || !user.is_holding(I) || !user.canUseTopic(src, BE_CLOSE))
			return TRUE
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 25, FALSE)
		I.afterattack(AI, user, TRUE)
		return TRUE

	return ..()

/obj/machinery/computer/ai_control_console/proc/upload_mmi(obj/item/mmi/brain, mob/living/user)
	if(!brain.brainmob?.mind)
		balloon_alert(user, "mózg nieaktywny!")
		return
	var/turf/our_turf = get_turf(src)
	if(!LAZYLEN(GLOB.data_cores["[our_turf.z]"]))
		balloon_alert(user, "brak rdzeni danych!")
		return
	SSticker.mode.remove_antag_for_borging(brain.brainmob.mind)

	var/datum/ai_laws/laws = new
	laws.set_laws_config()

	var/mob/living/silicon/ai/A
	if(brain.overrides_aicore_laws)
		A = new /mob/living/silicon/ai(our_turf, brain.laws, brain.brainmob)
	else
		A = new /mob/living/silicon/ai(our_turf, laws, brain.brainmob)
	if(QDELETED(A))
		return
	if(!isaicore(A.loc))
		A.relocate(TRUE)

	SSblackbox.record_feedback("amount", "ais_created", 1)
	deadchat_broadcast("<span class='deadsay'><span class='name'>[A]</span> zostaje wgrana do rdzenia danych w <b>[get_area_name(A, TRUE)]</b></span>.", "<span class='name'>[A]</span>", follow_target = A)
	log_game("[key_name(user)] uploaded [key_name(A)] from an MMI at [AREACOORD(src)].")
	qdel(brain)
	balloon_alert(user, "SI wgrana")
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 25, FALSE)

/obj/machinery/computer/ai_control_console/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	authenticated = TRUE
	obj_flags |= EMAGGED
	if(user)
		balloon_alert(user, "zabezpieczenia obejście")
	return TRUE

/obj/machinery/computer/ai_control_console/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	eject_intellicard(user)

/obj/machinery/computer/ai_control_console/process(delta_time)
	. = ..()
	if(!. || !downloading)
		return

	if(download_progress >= 50 && !download_warning)
		var/turf/T = get_turf(src)
		to_chat(downloading, span_userdanger("Uwaga! Pobieranie ukończone w 50%! Miejsce pobierania: [get_area_name(src, TRUE)] ([T.x], [T.y], [T.z])!"))
		download_warning = TRUE
	if(download_progress >= 100)
		finish_download()
		return

	if(!downloading.can_download && !one_time_password_used)
		stop_download()
		return
	download_progress += AI_DOWNLOAD_PER_PROCESS * (delta_time || 2)

/obj/machinery/computer/ai_control_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiControlPanel", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/ai_control_console/ui_data(mob/user)
	var/list/data = list()
	data["authenticated"] = authenticated

	if(obj_flags & EMAGGED)
		data["username"] = "BŁĄD"
		data["has_access"] = TRUE
	else if(issilicon(user))
		data["username"] = user.name
		data["has_access"] = TRUE
	else if(IsAdminGhost(user))
		data["username"] = user.client.holder.admin_signature || "Centrala"
		data["has_access"] = TRUE
	else if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		data["has_access"] = allowed(user)
		data["username"] = human_user.get_authentification_name("Nieznany")
	else
		data["has_access"] = allowed(user)
		data["username"] = user.name

	data["can_log_out"] = !one_time_password_used

	if(!authenticated)
		return data

	data["intellicard"] = !!intellicard
	if(intellicard?.AI)
		data["intellicard_ai"] = intellicard.AI.real_name
		data["intellicard_ai_health"] = intellicard.AI.health
		data["can_upload"] = !!intellicard.AI.find_valid_ai_core()
	else
		data["intellicard_ai"] = null
		data["intellicard_ai_health"] = 0
		data["can_upload"] = FALSE

	if(downloading)
		data["downloading"] = downloading.real_name
		data["download_progress"] = download_progress
		data["downloading_ref"] = REF(downloading)
	else
		data["downloading"] = null
		data["download_progress"] = 0

	data["ais"] = list()
	data["current_ai_ref"] = isAI(user) ? REF(user) : null

	var/turf/computer_turf = get_turf(src)
	for(var/obj/machinery/ai/data_core/data_core as anything in GLOB.data_cores["[computer_turf.z]"])
		for(var/mob/living/silicon/ai/A in data_core.contents)
			data["ais"] += list(list(
				"name" = A.name,
				"ref" = REF(A),
				"can_download" = one_time_password_used ? TRUE : A.can_download,
				"health" = A.health,
				"active" = !!(A.mind),
				"in_core" = TRUE,
			))

	return data

/obj/machinery/computer/ai_control_console/proc/eject_intellicard(mob/living/user)
	if(!intellicard)
		return FALSE
	if(issilicon(user))
		to_chat(user, span_warning("Nie możesz zdalnie wysunąć [intellicard]!"))
		return FALSE
	stop_download()
	if(!user.put_in_hands(intellicard))
		intellicard.forceMove(drop_location())
	intellicard = null
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 30, FALSE)
	return TRUE

/obj/machinery/computer/ai_control_console/proc/finish_download()
	var/turf/our_turf = get_turf(src)
	if(!downloading || !(downloading.loc in GLOB.data_cores["[our_turf.z]"]))
		stop_download(TRUE)
		return
	if(intellicard && !intellicard.AI)
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 25, FALSE)
		download_to_card(downloading, intellicard)
	stop_download(TRUE)

///Pobiera SI z rdzenia danych na intellicard (odpowiednik /mob/living/silicon/ai/transfer_ai dla AI w data core)
/obj/machinery/computer/ai_control_console/proc/download_to_card(mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(!AI.can_be_carded)
		return FALSE
	AI.disconnect_shell()
	AI.ShutOffDoomsdayDevice()
	var/datum/ai_os/old_os = AI.get_ai_os()
	old_os?.remove_ai(AI)
	AI.ai_restore_power() //So the AI initially has power.
	AI.control_disabled = TRUE //Can't control things remotely if you're stuck in a card!
	AI.radio_enabled = FALSE //No talking on the built-in radio for you either!
	AI.forceMove(card)
	card.AI = AI
	card.update_icon()
	to_chat(AI, "Zostajesz pobrany na przenośne urządzenie. Połączenie ze zdalnymi urządzeniami przerwane.")
	if(user_downloading)
		to_chat(user_downloading, "[span_boldnotice("Pobieranie zakończone")]: [AI.name] ([rand(1000,9999)].exe) zapisano w pamięci intellicardu.")
	log_game("[key_name(user_downloading)] downloaded [key_name(AI)] to an intellicard at [AREACOORD(src)].")
	return TRUE

/obj/machinery/computer/ai_control_console/proc/stop_download(silent = FALSE)
	if(!downloading)
		return
	if(!silent)
		to_chat(downloading, span_userdanger("Pobieranie przerwane."))
	downloading = null
	user_downloading = null
	download_progress = 0
	download_warning = FALSE

/obj/machinery/computer/ai_control_console/proc/upload_ai()
	var/mob/living/silicon/ai/AI = intellicard.AI
	var/obj/machinery/ai/data_core/core = AI.find_valid_ai_core()
	if(!core)
		return FALSE
	playsound(src, 'sound/machines/terminal_processing.ogg', 25, FALSE)
	to_chat(AI, span_notice("Trwa wgrywanie. Proszę czekać..."))
	AI.radio_enabled = TRUE
	AI.control_disabled = FALSE
	intellicard.AI = null
	core.transfer_AI(AI)
	intellicard.update_icon()
	log_game("[key_name(usr)] uploaded [key_name(AI)] from an intellicard at [AREACOORD(src)].")
	return TRUE

/obj/machinery/computer/ai_control_console/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	var/mob/user = usr

	if(!authenticated)
		if(action == "log_in")
			if(allowed(user) || (obj_flags & EMAGGED))
				playsound(src, "terminal_type", 50, FALSE)
				authenticated = TRUE
				return TRUE
			return
		if(action == "log_in_control_code")
			var/code = "[params["control_code"]]"
			if(length(code) != 6)
				to_chat(user, span_warning("Błędny kod. Kod ma 6 cyfr."))
				return
			if(!GLOB.ai_control_code)
				return
			if(code == GLOB.ai_control_code)
				authenticated = TRUE
				one_time_password_used = TRUE
				var/msg = "Wykryto użycie kodu kontrolnego SI do odblokowania konsoli w [get_area_name(src, TRUE)] przez [user.name]. Sprawdźcie, czy to zgodne z procedurami. Obecny kod został unieważniony. Nowy można wydrukować na konsoli komunikacyjnej."
				priority_announce(msg, "Centralne Bezpieczeństwo Cybernetyczne")
				GLOB.ai_control_code = null
				return TRUE
			to_chat(user, span_warning("Błędny kod. Upewnij się, że masz najnowszy."))
		return

	switch(action)
		if("log_out")
			if(one_time_password_used)
				return
			playsound(src, "terminal_type", 50, FALSE)
			authenticated = FALSE
			. = TRUE
		if("upload_intellicard")
			if(!intellicard?.AI || downloading)
				return
			. = upload_ai()

		if("eject_intellicard")
			return eject_intellicard(user)

		if("stop_download")
			if(isAI(user) && one_time_password_used)
				to_chat(user, span_warning("Do przerwania pobierania potrzebny jest fizyczny dostęp!"))
				return
			stop_download()
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 25, FALSE)
			. = TRUE

		if("start_download")
			if(!intellicard || intellicard.AI || downloading)
				return
			var/mob/living/silicon/ai/target = locate(params["download_target"]) in GLOB.ai_list
			if(!istype(target) || !isaicore(target.loc))
				return
			if(!target.can_download && !one_time_password_used)
				return
			var/turf/our_turf = get_turf(src)
			if(!(target.loc in GLOB.data_cores["[our_turf.z]"]))
				to_chat(user, span_warning("Brak połączenia. Spróbuj później."))
				return
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 25, FALSE)
			downloading = target
			to_chat(downloading, span_userdanger("Uwaga! Ktoś próbuje cię pobrać w [get_area_name(src, TRUE)]! (<a href='byond://?src=[REF(downloading)];instant_download=1;console=[REF(src)]'>Kliknij, by od razu zakończyć pobieranie</a>)"))
			user_downloading = user
			download_progress = 0
			. = TRUE
		if("skip_download")
			if(downloading && user == downloading)
				finish_download()
				. = TRUE

/obj/item/paper/ai_control_code
	name = "kartka - „Kod kontrolny SI”"

/obj/item/paper/ai_control_code/Initialize(mapload)
	. = ..()
	add_raw_text("<center><h2>Dzienny reset klucza kontrolnego SI</h2></center><br>Nowy klucz uwierzytelniający to: <b>[GLOB.ai_control_code]</b>.<br>\
		Trzymaj go w tajemnicy, z dala od klauna.<br>Kod może zostać unieważniony, jeśli ktoś zamówi nowy.")
	update_icon()
