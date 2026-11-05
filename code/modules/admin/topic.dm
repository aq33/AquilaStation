/datum/admins/proc/CheckAdminHref(href, href_list)
	var/auth = href_list["admin_token"]
	. = auth && (auth == href_token || auth == GLOB.href_token)
	if(.)
		return
	var/msg = !auth ? "no" : "a bad"
	message_admins("[key_name_admin(usr)] klika href z [auth ? "błędnym" : "brakującym"] kluczem autoryzacji!")
	if(CONFIG_GET(flag/debug_admin_hrefs))
		message_admins("Tryb debugowania włączony, wywołanie nie zostało zablokowane. Poproś koderów o przejrzenie logów tej rundy.")
		log_world("UAH: [href]")
		return TRUE
	log_admin_private("[key_name(usr)] clicked an href with [msg] authorization key! [href]")

/// AQUILA - okna TGUI admina wywołują istniejące gałęzie Topic() tak, jak kliknięcie linku z tokenem.
/// Każda gałąź Topic() sama sprawdza uprawnienia, więc nic tu nie omijamy.
/datum/admins/proc/ui_topic(list/href_list)
	if(!islist(href_list) || !usr?.client || usr.client != owner)
		return
	href_list["admin_token"] = href_token
	Topic(null, href_list)

/// AQUILA - wspólne akcje okien TGUI admina na mobie/umyśle (dawne linki PP, VV, TP, PM, SM, FLW, LOGS, N)
/// Zwraca TRUE, jeśli okno ma się odświeżyć.
/datum/admins/proc/ui_common_action(action, list/params)
	var/ref = params["ref"]
	switch(action)
		if("pp")
			ui_topic(list("adminplayeropts" = ref))
		if("vv")
			var/datum/target = locate(ref)
			if(target)
				usr.client.debug_variables(target)
		if("tp")
			ui_topic(list("traitor" = ref))
		if("bp")
			ui_topic(list("borgpanel" = ref))
		if("pm")
			if(params["ckey"])
				usr.client.cmd_admin_pm(params["ckey"], null)
		if("sm")
			ui_topic(list("subtlemessage" = ref))
		if("flw")
			ui_topic(list("adminplayerobservefollow" = ref))
		if("logs")
			var/list/href_list = list("individuallog" = ref)
			if(params["log_src"])
				href_list["log_src"] = params["log_src"]
			ui_topic(href_list)
		if("notes")
			if(params["ckey"])
				ui_topic(list("showmessageckey" = params["ckey"]))
		if("jumpto")
			ui_topic(list("jumpto" = ref))
		else
			return FALSE
	return TRUE

/datum/admins/Topic(href, href_list)
	..()

	if(usr.client != src.owner || !check_rights(0))
		message_admins("[usr.key] próbuje obejść panel admina!")
		log_admin("[key_name(usr)] tried to use the admin panel without authorization.")
		return

	if(!CheckAdminHref(href, href_list))
		return

	if(href_list["ahelp"])
		if(!check_rights(R_ADMIN, TRUE))
			return

		var/ahelp_ref = href_list["ahelp"]
		var/datum/admin_help/AH = locate(ahelp_ref)
		if(AH)
			AH.Action(href_list["ahelp_action"])
		else
			to_chat(usr, "Zgłoszenie [ahelp_ref] zostało usunięte!")

	else if(href_list["ahelp_tickets"])
		GLOB.ahelp_tickets.BrowseTickets(usr)

	else if(href_list["stickyban"])
		stickyban(href_list["stickyban"],href_list)

	else if(href_list["getplaytimewindow"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/M = locate(href_list["getplaytimewindow"]) in GLOB.mob_list
		if(!M)
			to_chat(usr, "<span class='danger'>BŁĄD: nie znaleziono moba.</span>")
			return
		cmd_show_exp_panel(M.client)

	else if(href_list["toggleexempt"])
		if(!check_rights(R_ADMIN))
			return
		var/client/C = locate(href_list["toggleexempt"]) in GLOB.clients
		if(!C)
			to_chat(usr, "<span class='danger'>BŁĄD: nie znaleziono klienta.</span>")
			return
		toggle_exempt_status(C)

	else if(href_list["makeAntag"])
		if(!check_rights(R_ADMIN))
			return
		if (!SSticker.mode)
			to_chat(usr, "<span class='danger'>Nie przed startem rundy!</span>")
			return
		switch(href_list["makeAntag"])
			if("traitors")
				var/maxCount = input("Ustaw liczbę zdrajców","Liczba zdrajców (maks.)",1) as num|null
				if (!maxCount)
					return
				if(src.makeTraitors(maxCount))
					message_admins("[key_name_admin(usr)] tworzy zdrajców: [maxCount].")
					log_admin("[key_name(usr)] created [maxCount] traitor(s).")
				else
					message_admins("[key_name_admin(usr)] próbuje stworzyć zdrajców ([maxCount]). Niestety nie było chętnych.")
					log_admin("[key_name(usr)] failed to create [maxCount] traitor(s).")
			if("changelings")
				var/maxCount = input("Ustaw liczbę zmiennokształtnych","Liczba zmiennokształtnych (maks.)",1) as num|null
				if (!maxCount)
					return
				if(src.makeChangelings(maxCount))
					message_admins("[key_name(usr)] tworzy changelingi: [maxCount].")
					log_admin("[key_name(usr)] created [maxCount] changelings.")
				else
					message_admins("[key_name_admin(usr)] próbuje stworzyć zmiennokształtnych ([maxCount]). Niestety nie było chętnych.")
					log_admin("[key_name(usr)] failed to create [maxCount] changelings.")
			if("revs")
				var/maxCount = input("Ustaw liczbę rewolucjonistów","Liczba rewolucjonistów (maks.)",1) as num|null
				if (!maxCount)
					return
				if(src.makeRevs(maxCount))
					message_admins("[key_name(usr)] wszczyna rewolucję, bojowników o wolność: [maxCount].")
					log_admin("[key_name(usr)] started a [maxCount] freedom fighters.")
				else
					message_admins("[key_name_admin(usr)] próbuje wszcząć rewolucję ([maxCount] bojowników o wolność). Niestety nie było chętnych.")
					log_admin("[key_name(usr)] failed to start a revolution with [maxCount] freedom fighters.")
			if("cult")
				var/maxCount = input("Ustaw liczbę kultystów","Liczba kultystów (maks.)",1) as num|null
				if (!maxCount)
					return
				if(src.makeCult(maxCount))
					message_admins("[key_name(usr)] zakłada kult, kultystów: [maxCount].")
					log_admin("[key_name(usr)] started a cult with [maxCount] cultists.")
				else
					message_admins("[key_name_admin(usr)] próbuje założyć kult ([maxCount] kultystów). Niestety nie było chętnych.")
					log_admin("[key_name(usr)] failed to start a cult with [maxCount] cultists.")
			if("wizard")
				message_admins("[key_name(usr)] tworzy czarodzieja...")
				if(src.makeWizard())
					message_admins("[key_name(usr)] tworzy czarodzieja.")
					log_admin("[key_name(usr)] created a wizard.")
				else
					message_admins("[key_name_admin(usr)] próbuje stworzyć czarodzieja. Niestety nie było chętnych.")
					log_admin("[key_name(usr)] failed to create a wizard.")
			if("nukeops")
				message_admins("[key_name(usr)] tworzy drużynę nuklearną...")
				var/maxCount = input("Ustaw liczbę operatorów nuklearnych","Liczba operatorów (maks.)",5) as num|null
				if (!maxCount)
					message_admins("[key_name_admin(usr)] anuluje tworzenie drużyny nuklearnej.")
					return
				if(src.makeNukeTeam(maxCount))
					message_admins("[key_name(usr)] tworzy drużynę nuklearną, agentów: [maxCount]")
					log_admin("[key_name(usr)] created a nuke team with [maxCount] operatives")
				else
					message_admins("[key_name_admin(usr)] próbuje stworzyć drużynę nuklearną ([maxCount] agentów). Niestety było za mało chętnych.")
					log_admin("[key_name(usr)] failed to create a nuke team with [maxCount] operatives.")
			if("ninja")
				message_admins("[key_name(usr)] tworzy ninję.")
				log_admin("[key_name(usr)] spawned a ninja.")
				src.makeSpaceNinja()
			if("aliens")
				message_admins("[key_name(usr)] wywołuje inwazję obcych.")
				log_admin("[key_name(usr)] started an alien infestation.")
				src.makeAliens()
			if("deathsquad")
				message_admins("[key_name(usr)] tworzy szwadron śmierci...")
				if(src.makeDeathsquad())
					message_admins("[key_name(usr)] tworzy szwadron śmierci.")
					log_admin("[key_name(usr)] created a death squad.")
				else
					message_admins("[key_name_admin(usr)] próbuje stworzyć szwadron śmierci. Niestety było za mało chętnych.")
					log_admin("[key_name(usr)] failed to create a death squad.")
			if("blob")
				var/strength = input("Ustaw tempo zdobywania zasobów grzyba","Tempo zasobów",1) as num|null
				if(!strength)
					return
				message_admins("[key_name(usr)] tworzy grzyba z bazowym przyrostem zasobów [strength].")
				log_admin("[key_name(usr)] spawned a blob with base resource gain [strength].")
				new/datum/round_event/ghost_role/blob(TRUE, strength)
			if("centcom")
				message_admins("[key_name(usr)] tworzy zespół reagowania Centrali...")
				if(src.makeEmergencyresponseteam())
					message_admins("[key_name(usr)] tworzy zespół reagowania Centrali.")
					log_admin("[key_name(usr)] created a CentCom response team.")
				else
					message_admins("[key_name_admin(usr)] próbuje stworzyć zespół reagowania Centrali. Niestety było za mało chętnych.")
					log_admin("[key_name(usr)] failed to create a CentCom response team.")
			if("abductors")
				message_admins("[key_name(usr)] tworzy drużynę porywaczy...")
				if(src.makeAbductorTeam())
					message_admins("[key_name(usr)] tworzy drużynę porywaczy.")
					log_admin("[key_name(usr)] created an abductor team.")
				else
					message_admins("[key_name_admin(usr)] próbuje stworzyć drużynę porywaczy. Niestety było za mało chętnych.")
					log_admin("[key_name(usr)] failed to create an abductor team.")
			if("revenant")
				if(src.makeRevenant())
					message_admins("[key_name(usr)] tworzy upiora.")
					log_admin("[key_name(usr)] created a revenant.")
				else
					message_admins("[key_name_admin(usr)] próbuje stworzyć upiora. Niestety nie było chętnych.")
					log_admin("[key_name(usr)] failed to create a revenant.")

	else if(href_list["forceevent"])
		if(!check_rights(R_FUN))
			return
		var/datum/round_event_control/E = locate(href_list["forceevent"]) in SSevents.control
		if(E)
			E.admin_setup(usr)
			var/datum/round_event/event = E.runEvent()
			if(event.announceWhen>0)
				event.processing = FALSE
				var/prompt = alert(usr, "Czy chcesz powiadomić załogę?", "Alert", "Tak", "Nie", "Anuluj")
				switch(prompt)
					if("Tak")
						event.announceChance = 100
					if("Anuluj")
						event.kill()
						return
					if("Nie")
						event.announceChance = 0
				event.on_admin_trigger()
				event.processing = TRUE
			message_admins("[key_name_admin(usr)] wywołuje zdarzenie. ([E.name])")
			log_admin("[key_name(usr)] has triggered an event. ([E.name])")
		return

	else if(href_list["editrightsbrowser"])
		edit_admin_permissions(0)

	else if(href_list["editrightsbrowserlog"])
		edit_admin_permissions(1, href_list["editrightstarget"], href_list["editrightsoperation"], href_list["editrightspage"])

	if(href_list["editrightsbrowsermanage"])
		if(href_list["editrightschange"])
			change_admin_rank(ckey(href_list["editrightschange"]), href_list["editrightschange"], TRUE)
		else if(href_list["editrightsremove"])
			remove_admin(ckey(href_list["editrightsremove"]), href_list["editrightsremove"], TRUE)
		else if(href_list["editrightsremoverank"])
			remove_rank(href_list["editrightsremoverank"])
		edit_admin_permissions(2)

	else if(href_list["editrights"])
		edit_rights_topic(href_list)

	else if(href_list["gamemode_panel"])
		if(!check_rights(R_ADMIN))
			return
		SSticker.mode.admin_panel()

	else if(href_list["f_dynamic_roundstart"])
		if(!check_rights(R_ADMIN))
			return
		if(SSticker && SSticker.mode)
			return alert(usr, "Gra już się zaczęła.", null, null, null, null)
		if(!SSticker.is_mode("dynamic"))
			return alert(usr, "Tryb gry musi być trybem dynamic.", null, null, null, null)
		var/roundstart_rules = list()
		for (var/rule in subtypesof(/datum/dynamic_ruleset/roundstart))
			var/datum/dynamic_ruleset/roundstart/newrule = new rule()
			roundstart_rules[newrule.name] = newrule
		var/added_rule = input(usr,"Który zestaw reguł chcesz wymusić? To pominie ograniczenia poziomu zagrożenia i liczby graczy.", "Ustawianie startu rundy", null) as null|anything in roundstart_rules
		if (added_rule)
			GLOB.dynamic_forced_roundstart_ruleset += roundstart_rules[added_rule]
			log_admin("[key_name(usr)] set [added_rule] to be a forced roundstart ruleset.")
			message_admins("[key_name(usr)] wymusza zestaw reguł na start rundy: [added_rule].", 1)
			Game()

	else if(href_list["f_dynamic_roundstart_clear"])
		if(!check_rights(R_ADMIN))
			return
		GLOB.dynamic_forced_roundstart_ruleset = list()
		Game()
		log_admin("[key_name(usr)] cleared the rigged roundstart rulesets. The mode will pick them as normal.")
		message_admins("[key_name(usr)] czyści wymuszone zestawy reguł na start rundy. Tryb wybierze je normalnie.", 1)

	else if(href_list["f_dynamic_roundstart_remove"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/dynamic_ruleset/roundstart/rule = locate(href_list["f_dynamic_roundstart_remove"])
		GLOB.dynamic_forced_roundstart_ruleset -= rule
		Game()
		log_admin("[key_name(usr)] removed [rule] from the forced roundstart rulesets.")
		message_admins("[key_name(usr)] usuwa [rule] z wymuszonych zestawów reguł na start rundy.", 1)

	else if(href_list["f_dynamic_latejoin"])
		if(!check_rights(R_ADMIN))
			return
		if(!SSticker || !SSticker.mode)
			return alert(usr, "Najpierw gra musi się zacząć.", null, null, null, null)
		if(!SSticker.is_mode("dynamic"))
			return alert(usr, "Tryb gry musi być trybem dynamic!", null, null, null, null)
		var/latejoin_rules = list()
		var/datum/game_mode/dynamic/mode = SSticker.mode
		for (var/rule in subtypesof(/datum/dynamic_ruleset/latejoin))
			var/datum/dynamic_ruleset/latejoin/newrule = new rule()
			mode.configure_ruleset(newrule)
			latejoin_rules[newrule.name] = newrule
		var/added_rule = input(usr,"Który zestaw reguł chcesz wymusić na następnym spóźnialskim? To pominie ograniczenia poziomu zagrożenia i liczby graczy.", "Ustawianie późnego dołączenia", null) as null|anything in latejoin_rules
		if (added_rule)
			mode.forced_latejoin_rule = latejoin_rules[added_rule]
			log_admin("[key_name(usr)] set [added_rule] to proc on the next latejoin.")
			message_admins("[key_name(usr)] ustawia [added_rule] na następne późne dołączenie.", 1)
			Game()

	else if(href_list["f_dynamic_latejoin_clear"])
		if(!check_rights(R_ADMIN))
			return
		if (SSticker && SSticker.mode && istype(SSticker.mode,/datum/game_mode/dynamic))
			var/datum/game_mode/dynamic/mode = SSticker.mode
			mode.forced_latejoin_rule = null
			Game()
			log_admin("[key_name(usr)] cleared the forced latejoin ruleset.")
			message_admins("[key_name(usr)] czyści wymuszony zestaw reguł dla późnego dołączenia.", 1)

	else if(href_list["f_dynamic_midround"])
		if(!check_rights(R_ADMIN))
			return
		if(!SSticker || !SSticker.mode)
			return alert(usr, "Najpierw gra musi się zacząć.", null, null, null, null)
		if(!SSticker.is_mode("dynamic"))
			return alert(usr, "Tryb gry musi być trybem dynamic!", null, null, null, null)
		var/midround_rules = list()
		var/datum/game_mode/dynamic/mode = SSticker.mode
		for (var/rule in subtypesof(/datum/dynamic_ruleset/midround))
			var/datum/dynamic_ruleset/midround/newrule = new rule()
			mode.configure_ruleset(newrule)
			midround_rules[newrule.name] = rule
		var/added_rule = input(usr,"Który zestaw reguł chcesz wymusić teraz? To pominie ograniczenia poziomu zagrożenia i liczby graczy.", "Wykonaj zestaw reguł", null) as null|anything in midround_rules
		if (added_rule)
			log_admin("[key_name(usr)] executed the [added_rule] ruleset.")
			message_admins("[key_name(usr)] wykonuje zestaw reguł: [added_rule].", 1)
			mode.picking_specific_rule(midround_rules[added_rule],1)

	else if (href_list["f_dynamic_options"])
		if(!check_rights(R_ADMIN))
			return

		if(SSticker && SSticker.mode)
			return alert(usr, "Gra już się zaczęła.", null, null, null, null)
		if(!SSticker.is_mode("dynamic"))
			return alert(usr, "Tryb gry musi być trybem dynamic!", null, null, null, null)

		dynamic_mode_options(usr)

	else if(href_list["f_dynamic_force_extended"])
		if(!check_rights(R_ADMIN))
			return

		if(!SSticker.is_mode("dynamic"))
			return alert(usr, "Tryb gry musi być trybem dynamic!", null, null, null, null)

		GLOB.dynamic_forced_extended = !GLOB.dynamic_forced_extended
		log_admin("[key_name(usr)] set 'forced_extended' to [GLOB.dynamic_forced_extended].")
		message_admins("[key_name(usr)] ustawia 'forced_extended' na [GLOB.dynamic_forced_extended].")
		dynamic_mode_options(usr)

	else if(href_list["f_dynamic_no_stacking"])
		if(!check_rights(R_ADMIN))
			return

		if(!SSticker.is_mode("dynamic"))
			return alert(usr, "Tryb gry musi być trybem dynamic!", null, null, null, null)

		GLOB.dynamic_no_stacking = !GLOB.dynamic_no_stacking
		log_admin("[key_name(usr)] set 'no_stacking' to [GLOB.dynamic_no_stacking].")
		message_admins("[key_name(usr)] ustawia 'no_stacking' na [GLOB.dynamic_no_stacking].")
		dynamic_mode_options(usr)

	else if(href_list["f_dynamic_stacking_limit"])
		if(!check_rights(R_ADMIN))
			return

		if(!SSticker.is_mode("dynamic"))
			return alert(usr, "Tryb gry musi być trybem dynamic!", null, null, null, null)

		GLOB.dynamic_stacking_limit = input(usr,"Zmień próg zagrożenia, od którego zestawy reguł kończące rundę zaczną się kumulować.", "Limit kumulacji", null) as num
		log_admin("[key_name(usr)] set 'stacking_limit' to [GLOB.dynamic_stacking_limit].")
		message_admins("[key_name(usr)] ustawia 'stacking_limit' na [GLOB.dynamic_stacking_limit].")
		dynamic_mode_options(usr)

	else if(href_list["f_dynamic_forced_threat"])
		if(!check_rights(R_ADMIN))
			return

		if(SSticker && SSticker.mode)
			return alert(usr, "Gra już się zaczęła.", null, null, null, null)

		if(!SSticker.is_mode("dynamic"))
			return alert(usr, "Tryb gry musi być trybem dynamic!", null, null, null, null)

		var/new_value = input(usr, "Podaj wymuszony poziom zagrożenia dla trybu dynamic.", "Wymuszony poziom zagrożenia") as num
		if (new_value > 100)
			return alert(usr, "Wartość musi być mniejsza niż 100.", null, null, null, null)
		GLOB.dynamic_forced_threat_level = new_value

		log_admin("[key_name(usr)] set 'forced_threat_level' to [GLOB.dynamic_forced_threat_level].")
		message_admins("[key_name(usr)] ustawia 'forced_threat_level' na [GLOB.dynamic_forced_threat_level].")
		dynamic_mode_options(usr)

	else if(href_list["call_shuttle"])
		if(!check_rights(R_ADMIN))
			return


		switch(href_list["call_shuttle"])
			if("1")
				if(EMERGENCY_AT_LEAST_DOCKED)
					return
				SSshuttle.emergency.request()
				log_admin("[key_name(usr)] called the Emergency Shuttle.")
				message_admins("<span class='adminnotice'>[key_name_admin(usr)] wzywa prom ewakuacyjny na stację.</span>")

			if("2")
				if(EMERGENCY_AT_LEAST_DOCKED)
					return
				switch(SSshuttle.emergency.mode)
					if(SHUTTLE_CALL)
						SSshuttle.emergency.cancel()
						log_admin("[key_name(usr)] sent the Emergency Shuttle back.")
						message_admins("<span class='adminnotice'>[key_name_admin(usr)] odsyła prom ewakuacyjny.</span>")
					else
						SSshuttle.emergency.cancel()
						log_admin("[key_name(usr)] called the Emergency Shuttle.")
						message_admins("<span class='adminnotice'>[key_name_admin(usr)] wzywa prom ewakuacyjny na stację.</span>")



	else if(href_list["edit_shuttle_time"])
		if(!check_rights(R_SERVER))
			return

		var/timer = input("Podaj nowy czas promu (w sekundach):","Czas promu", SSshuttle.emergency.timeLeft() ) as num|null
		if(!timer)
			return
		SSshuttle.emergency.setTimer(timer*10)
		log_admin("[key_name(usr)] edited the Emergency Shuttle's timeleft to [timer] seconds.")
		minor_announce("Prom ewakuacyjny dotrze do celu za [round(SSshuttle.emergency.timeLeft(600))] min.")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] ustawia czas promu ewakuacyjnego na [timer] s.</span>")
	else if(href_list["trigger_centcom_recall"])
		if(!check_rights(R_ADMIN))
			return

		usr.client.trigger_centcom_recall()

	else if(href_list["toggle_continuous"])
		if(!check_rights(R_ADMIN))
			return
		var/list/continuous = CONFIG_GET(keyed_list/continuous)
		if(!continuous[SSticker.mode.config_tag])
			continuous[SSticker.mode.config_tag] = TRUE
		else
			continuous[SSticker.mode.config_tag] = FALSE

		message_admins("<span class='adminnotice'>[key_name_admin(usr)] ustawia rundę tak, by [continuous[SSticker.mode.config_tag] ? "trwała dalej po śmierci wszystkich antagonistów" : "kończyła się razem z antagonistami"].</span>")
		check_antagonists()

	else if(href_list["toggle_midround_antag"])
		if(!check_rights(R_ADMIN))
			return

		var/list/midround_antag = CONFIG_GET(keyed_list/midround_antag)
		if(!midround_antag[SSticker.mode.config_tag])
			midround_antag[SSticker.mode.config_tag] = TRUE
		else
			midround_antag[SSticker.mode.config_tag] = FALSE

		message_admins("<span class='adminnotice'>[key_name_admin(usr)] [midround_antag[SSticker.mode.config_tag] ? "włącza" : "wyłącza"] w tej rundzie system antagonistów w trakcie rundy.</span>")
		check_antagonists()

	else if(href_list["alter_midround_time_limit"])
		if(!check_rights(R_ADMIN))
			return

		var/timer = input("Podaj nowy maksymalny czas",, CONFIG_GET(number/midround_antag_time_check)) as num|null
		if(!timer)
			return
		CONFIG_SET(number/midround_antag_time_check, timer)
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] ustawia maksymalny czas antagonistów w trakcie rundy na [timer] min.</span>")
		check_antagonists()

	else if(href_list["alter_midround_life_limit"])
		if(!check_rights(R_ADMIN))
			return

		var/ratio = input("Podaj nowy odsetek żywych",, CONFIG_GET(number/midround_antag_life_check) * 100) as num
		if(!ratio)
			return
		CONFIG_SET(number/midround_antag_life_check, ratio / 100)

		message_admins("<span class='adminnotice'>[key_name_admin(usr)] ustawia próg żywej załogi dla antagonistów w trakcie rundy na [ratio]%.</span>")
		check_antagonists()

	else if(href_list["toggle_noncontinuous_behavior"])
		if(!check_rights(R_ADMIN))
			return

		if(!SSticker.mode.round_ends_with_antag_death)
			SSticker.mode.round_ends_with_antag_death = 1
		else
			SSticker.mode.round_ends_with_antag_death = 0

		message_admins("<span class='adminnotice'>[key_name_admin(usr)] ustawia, że po porażce systemu antagonistów w trakcie rundy [SSticker.mode.round_ends_with_antag_death ? "runda się kończy" : "gra toczy się dalej jak extended"].</span>")
		check_antagonists()

	else if(href_list["delay_round_end"])
		if(!check_rights(R_ADMIN))
			return
		delay_round_end()

	else if(href_list["end_round"])
		if(!check_rights(R_ADMIN))
			return

		message_admins("<span class='adminnotice'>[key_name_admin(usr)] rozważa zakończenie rundy.</span>")
		if(alert(usr, "To zakończy rundę, czy na PEWNO chcesz to zrobić?", "Potwierdzenie", "Tak", "Nie") == "Tak")
			if(alert(usr, "Ostateczne potwierdzenie: zakończyć rundę TERAZ?", "Potwierdzenie", "Tak", "Nie") == "Tak")
				message_admins("<span class='adminnotice'>[key_name_admin(usr)] kończy rundę.</span>")
				SSticker.force_ending = 1 //Yeah there we go APC destroyed mission accomplished
				return
			else
				message_admins("<span class='adminnotice'>[key_name_admin(usr)] rezygnuje z zakończenia rundy.</span>")
		else
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] rezygnuje z zakończenia rundy.</span>")

	else if(href_list["simplemake"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/M = locate(href_list["mob"])
		if(!ismob(M))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob.")
			return

		var/delmob = FALSE
		switch(alert("Usunąć starego moba?","Wiadomość","Tak","Nie","Anuluj"))
			if("Anuluj")
				return
			if("Tak")
				delmob = TRUE

		log_admin("[key_name(usr)] has used rudimentary transformation on [key_name(M)]. Transforming to [href_list["simplemake"]].; deletemob=[delmob]")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] używa prostej przemiany na [key_name_admin(M)]. Przemiana w: [href_list["simplemake"]].; deletemob=[delmob]</span>")
		switch(href_list["simplemake"])
			if("observer")
				M.change_mob_type( /mob/dead/observer , null, null, delmob )
			if("drone")
				M.change_mob_type( /mob/living/carbon/alien/humanoid/drone , null, null, delmob )
			if("hunter")
				M.change_mob_type( /mob/living/carbon/alien/humanoid/hunter , null, null, delmob )
			if("queen")
				M.change_mob_type( /mob/living/carbon/alien/humanoid/royal/queen , null, null, delmob )
			if("praetorian")
				M.change_mob_type( /mob/living/carbon/alien/humanoid/royal/praetorian , null, null, delmob )
			if("sentinel")
				M.change_mob_type( /mob/living/carbon/alien/humanoid/sentinel , null, null, delmob )
			if("larva")
				M.change_mob_type( /mob/living/carbon/alien/larva , null, null, delmob )
			if("human")
				var/posttransformoutfit = usr.client.robust_dress_shop()
				if (!posttransformoutfit)
					return
				var/mob/living/carbon/human/newmob = M.change_mob_type( /mob/living/carbon/human , null, null, delmob )
				if(posttransformoutfit && istype(newmob))
					newmob.equipOutfit(posttransformoutfit)
			if("slime")
				M.change_mob_type( /mob/living/simple_animal/slime , null, null, delmob )
			if("monkey")
				M.change_mob_type( /mob/living/carbon/monkey , null, null, delmob )
			if("robot")
				M.change_mob_type( /mob/living/silicon/robot , null, null, delmob )
			if("cat")
				M.change_mob_type( /mob/living/simple_animal/pet/cat , null, null, delmob )
			if("runtime")
				M.change_mob_type( /mob/living/simple_animal/pet/cat/Runtime , null, null, delmob )
			if("corgi")
				M.change_mob_type( /mob/living/simple_animal/pet/dog/corgi , null, null, delmob )
			if("ian")
				M.change_mob_type( /mob/living/simple_animal/pet/dog/corgi/Ian , null, null, delmob )
			if("pug")
				M.change_mob_type( /mob/living/simple_animal/pet/dog/pug , null, null, delmob )
			if("crab")
				M.change_mob_type( /mob/living/simple_animal/crab , null, null, delmob )
			if("coffee")
				M.change_mob_type( /mob/living/simple_animal/crab/Coffee , null, null, delmob )
			if("parrot")
				M.change_mob_type( /mob/living/simple_animal/parrot , null, null, delmob )
			if("polyparrot")
				M.change_mob_type( /mob/living/simple_animal/parrot/Poly , null, null, delmob )
			if("constructarmored")
				M.change_mob_type( /mob/living/simple_animal/hostile/construct/armored , null, null, delmob )
			if("constructbuilder")
				M.change_mob_type( /mob/living/simple_animal/hostile/construct/builder , null, null, delmob )
			if("constructwraith")
				M.change_mob_type( /mob/living/simple_animal/hostile/construct/wraith , null, null, delmob )
			if("shade")
				M.change_mob_type( /mob/living/simple_animal/shade , null, null, delmob )

	else if(href_list["boot2"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/M = locate(href_list["boot2"])
		if(ismob(M))
			if(!check_if_greater_rights_than(M.client))
				to_chat(usr, "<span class='danger'>Błąd: ma większe uprawnienia niż ty.</span>")
				return
			if(alert(usr, "Wyrzucić [key_name(M)]?", "Potwierdź", "Tak", "Nie") != "Tak")
				return
			if(!M)
				to_chat(usr, "<span class='danger'>Błąd: [M] już nie istnieje!</span>")
				return
			if(!M.client)
				to_chat(usr, "<span class='danger'>Błąd: [M] nie ma już klienta!</span>")
				return
			to_chat(M, "<span class='danger'>Zostałeś wyrzucony z serwera przez [usr.client.holder.fakekey ? "Administratora" : "[usr.client.key]"].</span>")
			log_admin("[key_name(usr)] kicked [key_name(M)].")
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] wyrzuca [key_name_admin(M)].</span>")
			qdel(M.client)

	else if(href_list["addmessage"])
		if(!check_rights(R_ADMIN))
			return
		var/target_key = href_list["addmessage"]
		create_message("message", target_key, secret = 0)

	else if(href_list["addnote"])
		if(!check_rights(R_ADMIN))
			return
		var/target_key = href_list["addnote"]
		create_message("note", target_key)

	else if(href_list["addwatch"])
		if(!check_rights(R_ADMIN))
			return
		var/target_key = href_list["addwatch"]
		create_message("watchlist entry", target_key, secret = 1)

	else if(href_list["addmemo"])
		if(!check_rights(R_ADMIN))
			return
		create_message("memo", secret = 0, browse = 1)

	else if(href_list["addmessageempty"])
		if(!check_rights(R_ADMIN))
			return
		create_message("message", secret = 0)

	else if(href_list["addnoteempty"])
		if(!check_rights(R_ADMIN))
			return
		create_message("note")

	else if(href_list["addwatchempty"])
		if(!check_rights(R_ADMIN))
			return
		create_message("watchlist entry", secret = 1)

	else if(href_list["deletemessage"])
		if(!check_rights(R_ADMIN))
			return
		var/safety = alert("Usunąć wiadomość/notkę?",,"Tak","Nie");
		if (safety == "Tak")
			var/message_id = href_list["deletemessage"]
			delete_message(message_id)

	else if(href_list["deletemessageempty"])
		if(!check_rights(R_ADMIN))
			return
		var/safety = alert("Usunąć wiadomość/notkę?",,"Tak","Nie");
		if (safety == "Tak")
			var/message_id = href_list["deletemessageempty"]
			delete_message(message_id, browse = TRUE)

	else if(href_list["editmessage"])
		if(!check_rights(R_ADMIN))
			return
		var/message_id = href_list["editmessage"]
		edit_message(message_id)

	else if(href_list["editmessageempty"])
		if(!check_rights(R_ADMIN))
			return
		var/message_id = href_list["editmessageempty"]
		edit_message(message_id, browse = 1)

	else if(href_list["editmessageexpiry"])
		if(!check_rights(R_ADMIN))
			return
		var/message_id = href_list["editmessageexpiry"]
		edit_message_expiry(message_id)

	else if(href_list["editmessageexpiryempty"])
		if(!check_rights(R_ADMIN))
			return
		var/message_id = href_list["editmessageexpiryempty"]
		edit_message_expiry(message_id, browse = 1)

	else if(href_list["editmessageseverity"])
		if(!check_rights(R_ADMIN))
			return
		var/message_id = href_list["editmessageseverity"]
		edit_message_severity(message_id)

	else if(href_list["secretmessage"])
		if(!check_rights(R_ADMIN))
			return
		var/message_id = href_list["secretmessage"]
		toggle_message_secrecy(message_id)

	else if(href_list["searchmessages"])
		if(!check_rights(R_ADMIN))
			return
		var/target = href_list["searchmessages"]
		browse_messages(index = target)

	else if(href_list["nonalpha"])
		if(!check_rights(R_ADMIN))
			return
		var/target = href_list["nonalpha"]
		target = text2num(target)
		browse_messages(index = target)

	else if(href_list["showmessages"])
		if(!check_rights(R_ADMIN))
			return
		var/target = href_list["showmessages"]
		browse_messages(index = target)

	else if(href_list["showmemo"])
		if(!check_rights(R_ADMIN))
			return
		browse_messages("memo")

	else if(href_list["showwatch"])
		if(!check_rights(R_ADMIN))
			return
		browse_messages("watchlist entry")

	else if(href_list["showwatchfilter"])
		if(!check_rights(R_ADMIN))
			return
		browse_messages("watchlist entry", filter = 1)

	else if(href_list["showmessageckey"])
		if(!check_rights(R_ADMIN))
			return
		var/target = href_list["showmessageckey"]
		var/agegate = TRUE
		if (href_list["showall"])
			agegate = FALSE
		browse_messages(target_ckey = target, agegate = agegate)

	else if(href_list["showmessageckeylinkless"])
		var/target = href_list["showmessageckeylinkless"]
		browse_messages(target_ckey = target, linkless = 1)

	else if(href_list["messageedits"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/DBQuery/query_get_message_edits = SSdbcore.NewQuery(
			"SELECT edits FROM [format_table_name("messages")] WHERE id = :message_id",
			list("message_id" = href_list["messageedits"])
		)
		if(!query_get_message_edits.warn_execute())
			qdel(query_get_message_edits)
			return
		if(query_get_message_edits.NextRow())
			var/edit_log = query_get_message_edits.item[1]
			if(!QDELETED(usr))
				var/datum/browser/browser = new(usr, "Note edits", "Historia zmian notki")
				browser.set_content(jointext(edit_log, ""))
				browser.open()
		qdel(query_get_message_edits)

	else if(href_list["mute"])
		if(!check_rights(R_ADMIN))
			return
		cmd_admin_mute(href_list["mute"], text2num(href_list["mute_type"]))

	else if(href_list["c_mode"])
		return HandleCMode()

	else if(href_list["f_secret"])
		return HandleFSecret()

	else if(href_list["c_mode2"])
		if(!check_rights(R_ADMIN|R_SERVER))
			return

		if (SSticker.HasRoundStarted())
			alert("Runda już się zaczęła.")
			HandleCMode()
			return
		if(SSticker.gamemode_hotswap_disabled)
			alert("Tryb gry już wczytał mapy i nie można go zmienić!")
			HandleCMode()
			return
		GLOB.master_mode = href_list["c_mode2"]
		//Disable presetup so their gamemode gets loaded.
		SSticker.pre_setup_completed = FALSE
		log_admin("[key_name(usr)] set the mode as [GLOB.master_mode].")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] ustawia tryb na [GLOB.master_mode].</span>")
		to_chat(world, "<span class='adminnotice'><b>Tryb to teraz: [GLOB.master_mode]</b></span>")
		Game() // updates the main game menu
		HandleCMode()

	else if(href_list["f_secret2"])
		if(!check_rights(R_ADMIN|R_SERVER))
			return

		if(SSticker.HasRoundStarted())
			return alert(usr, "Gra już się zaczęła.", null, null, null, null)
		if(GLOB.master_mode != "secret")
			return alert(usr, "Tryb gry musi być trybem secret!", null, null, null, null)
		GLOB.secret_force_mode = href_list["f_secret2"]
		log_admin("[key_name(usr)] set the forced secret mode as [GLOB.secret_force_mode].")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] ustawia wymuszony tryb secret na [GLOB.secret_force_mode].</span>")
		Game() // updates the main game menu
		HandleFSecret()

	else if(href_list["monkeyone"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["monkeyone"])
		if(!istype(H))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob/living/carbon/human.")
			return

		log_admin("[key_name(usr)] attempting to monkeyize [key_name(H)].")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] próbuje zmienić w małpę: [key_name_admin(H)].</span>")
		H.monkeyize()

	else if(href_list["humanone"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/monkey/Mo = locate(href_list["humanone"])
		if(!istype(Mo))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob/living/carbon/monkey.")
			return

		log_admin("[key_name(usr)] attempting to humanize [key_name(Mo)].")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] próbuje zmienić w człowieka: [key_name_admin(Mo)].</span>")
		Mo.humanize()

	else if(href_list["corgione"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/C = locate(href_list["corgione"])
		if(!istype(C))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob/living/carbon.")
			return

		log_admin("[key_name(usr)] attempting to corgize [key_name(C)].")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] próbuje zmienić w corgi: [key_name_admin(C)].</span>")
		C.corgize()


	else if(href_list["forcespeech"])
		if(!check_rights(R_FUN))
			return

		var/mob/M = locate(href_list["forcespeech"])
		if(!ismob(M))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob.")

		var/speech = input("Co ma powiedzieć [key_name(M)]?", "Wymuszona mowa", "")// Don't need to sanitize, since it does that in say(), we also trust our admins.
		if(!speech)
			return
		M.say(speech, forced = "admin speech")
		speech = sanitize(speech) // Nah, we don't trust them
		log_admin("[key_name(usr)] forced [key_name(M)] to say: [speech]")
		message_admins("<span class='adminnotice'>[key_name_admin(usr)] zmusza [key_name_admin(M)] do powiedzenia: [speech]</span>")

	else if(href_list["sendtoprison"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["sendtoprison"])
		if(!ismob(M))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob.")
			return
		if(isAI(M))
			to_chat(usr, "Nie można tego użyć na instancjach typu /mob/living/silicon/ai.")
			return

		if(alert(usr, "Wysłać [key_name(M)] do więzienia?", "Wiadomość", "Tak", "Nie") != "Tak")
			return

		M.forceMove(pick(GLOB.prisonwarp))
		to_chat(M, "<span class='adminnotice'>Zostałeś wysłany do więzienia!</span>")

		log_admin("[key_name(usr)] has sent [key_name(M)] to Prison!")
		message_admins("[key_name_admin(usr)] wysyła [key_name_admin(M)] do więzienia!")

	else if(href_list["sendbacktolobby"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["sendbacktolobby"])

		if(!isobserver(M))
			to_chat(usr, "<span class='notice'>Do lobby możesz odesłać tylko graczy-duchy.</span>")
			return

		if(!M.client)
			to_chat(usr, "<span class='warning'>Wygląda na to, że [M] nie ma aktywnego klienta.</span>")
			return

		if(alert(usr, "Odesłać [key_name(M)] do lobby?", "Wiadomość", "Tak", "Nie") != "Tak")
			return

		log_admin("[key_name(usr)] has sent [key_name(M)] back to the Lobby.")
		message_admins("[key_name(usr)] odsyła [key_name(M)] do lobby.")

		var/mob/dead/new_player/NP = new()
		NP.ckey = M.ckey
		qdel(M)

	else if(href_list["tdome1"])
		if(!check_rights(R_FUN))
			return

		if(alert(usr, "Potwierdzasz?", "Wiadomość", "Tak", "Nie") != "Tak")
			return

		var/mob/M = locate(href_list["tdome1"])
		if(!isliving(M))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob/living.")
			return
		if(isAI(M))
			to_chat(usr, "Nie można tego użyć na instancjach typu /mob/living/silicon/ai.")
			return
		var/mob/living/L = M

		for(var/obj/item/I in L)
			L.dropItemToGround(I, TRUE)

		L.Unconscious(100)
		sleep(5)
		L.forceMove(pick(GLOB.tdome1))
		spawn(50)
			to_chat(L, "<span class='adminnotice'>Zostałeś wysłany do Thunderdome.</span>")
		log_admin("[key_name(usr)] has sent [key_name(L)] to the thunderdome. (Team 1)")
		message_admins("[key_name_admin(usr)] wysyła [key_name_admin(L)] na Thunderdome. (drużyna 1)")

	else if(href_list["tdome2"])
		if(!check_rights(R_FUN))
			return

		if(alert(usr, "Potwierdzasz?", "Wiadomość", "Tak", "Nie") != "Tak")
			return

		var/mob/M = locate(href_list["tdome2"])
		if(!isliving(M))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob/living.")
			return
		if(isAI(M))
			to_chat(usr, "Nie można tego użyć na instancjach typu /mob/living/silicon/ai.")
			return
		var/mob/living/L = M

		for(var/obj/item/I in L)
			L.dropItemToGround(I, TRUE)

		L.Unconscious(100)
		sleep(5)
		L.forceMove(pick(GLOB.tdome2))
		spawn(50)
			to_chat(L, "<span class='adminnotice'>Zostałeś wysłany do Thunderdome.</span>")
		log_admin("[key_name(usr)] has sent [key_name(L)] to the thunderdome. (Team 2)")
		message_admins("[key_name_admin(usr)] wysyła [key_name_admin(L)] na Thunderdome. (drużyna 2)")

	else if(href_list["tdomeadmin"])
		if(!check_rights(R_FUN))
			return

		if(alert(usr, "Potwierdzasz?", "Wiadomość", "Tak", "Nie") != "Tak")
			return

		var/mob/M = locate(href_list["tdomeadmin"])
		if(!isliving(M))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob/living.")
			return
		if(isAI(M))
			to_chat(usr, "Nie można tego użyć na instancjach typu /mob/living/silicon/ai.")
			return
		var/mob/living/L = M

		L.Unconscious(100)
		sleep(5)
		L.forceMove(pick(GLOB.tdomeadmin))
		spawn(50)
			to_chat(L, "<span class='adminnotice'>Zostałeś wysłany do Thunderdome.</span>")
		log_admin("[key_name(usr)] has sent [key_name(L)] to the thunderdome. (Admin.)")
		message_admins("[key_name_admin(usr)] wysyła [key_name_admin(L)] na Thunderdome. (admin)")

	else if(href_list["tdomeobserve"])
		if(!check_rights(R_FUN))
			return

		if(alert(usr, "Potwierdzasz?", "Wiadomość", "Tak", "Nie") != "Tak")
			return

		var/mob/M = locate(href_list["tdomeobserve"])
		if(!isliving(M))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob/living.")
			return
		if(isAI(M))
			to_chat(usr, "Nie można tego użyć na instancjach typu /mob/living/silicon/ai.")
			return
		var/mob/living/L = M

		for(var/obj/item/I in L)
			L.dropItemToGround(I, TRUE)

		if(ishuman(L))
			var/mob/living/carbon/human/observer = L
			observer.equip_to_slot_or_del(new /obj/item/clothing/under/suit/black(observer), ITEM_SLOT_ICLOTHING)
			observer.equip_to_slot_or_del(new /obj/item/clothing/shoes/sneakers/black(observer), ITEM_SLOT_FEET)
		L.Unconscious(100)
		sleep(5)
		L.forceMove(pick(GLOB.tdomeobserve))
		spawn(50)
			to_chat(L, "<span class='adminnotice'>Zostałeś wysłany do Thunderdome.</span>")
		log_admin("[key_name(usr)] has sent [key_name(L)] to the thunderdome. (Observer.)")
		message_admins("[key_name_admin(usr)] wysyła [key_name_admin(L)] na Thunderdome. (obserwator)")

	else if(href_list["revive"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/living/L = locate(href_list["revive"])
		if(!istype(L))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob/living.")
			return

		L.revive(full_heal = 1, admin_revive = 1)
		message_admins("<span class='danger'>Admin [key_name_admin(usr)] leczy / ożywia [key_name_admin(L)]!</span>")
		log_admin("[key_name(usr)] healed / Revived [key_name(L)].")

	else if(href_list["makeai"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makeai"])
		if(!istype(H))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob/living/carbon/human.")
			return

		message_admins("<span class='danger'>Admin [key_name_admin(usr)] zmienia w SI: [key_name_admin(H)]!</span>")
		log_admin("[key_name(usr)] AIized [key_name(H)].")
		H.AIize(TRUE, H.client)

	else if(href_list["makepai"])
		if(!check_rights(R_SPAWN))
			return
		var/mob/H = locate(href_list["makepai"])
		if(!istype(H))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob.")
			return
		message_admins("<span class='danger'>Admin [key_name_admin(usr)] zmienia w pAI: [key_name_admin(H)]!</span>")
		log_admin("[key_name(usr)] PAI'd [key_name(H)].")
		H.makePAI(TRUE)

	else if(href_list["makealien"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makealien"])
		if(!istype(H))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob/living/carbon/human.")
			return

		usr.client.cmd_admin_alienize(H)

	else if(href_list["makeslime"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makeslime"])
		if(!istype(H))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob/living/carbon/human.")
			return

		usr.client.cmd_admin_slimeize(H)

	else if(href_list["makeblob"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makeblob"])
		if(!istype(H))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob/living/carbon/human.")
			return

		usr.client.cmd_admin_blobize(H)

	else if(href_list["makecluwne"])
		if(!check_rights(R_SPAWN))
			return
		var/mob/living/carbon/human/H = locate(href_list["makecluwne"])
		if(!istype(H))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob/living/carbon/human.")
			return
		message_admins("[key_name(usr)] cluwned [key_name(H)]")
		log_admin("[key_name(usr)] cluwned [key_name(H)]")
		H.cluwne()

	else if(href_list["makerobot"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/living/carbon/human/H = locate(href_list["makerobot"])
		if(!istype(H))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob/living/carbon/human.")
			return

		usr.client.cmd_admin_robotize(H)

	else if(href_list["makeanimal"])
		if(!check_rights(R_SPAWN))
			return

		var/mob/M = locate(href_list["makeanimal"])
		if(isnewplayer(M))
			to_chat(usr, "Nie można tego użyć na instancjach typu /mob/dead/new_player.")
			return

		usr.client.cmd_admin_animalize(M)

	else if(href_list["adminplayeropts"])
		var/mob/M = locate(href_list["adminplayeropts"])
		show_player_panel(M)

	else if(href_list["adminplayerobservefollow"])
		admin_follow(locate(href_list["adminplayerobservefollow"]))

	else if(href_list["admingetmovable"])
		if(!check_rights(R_ADMIN))
			return

		var/atom/movable/AM = locate(href_list["admingetmovable"])
		if(QDELETED(AM))
			return
		AM.forceMove(get_turf(usr))

	else if(href_list["adminplayerobservecoodjump"])
		if(!isobserver(usr) && !check_rights(R_ADMIN))
			return

		var/x = text2num(href_list["X"])
		var/y = text2num(href_list["Y"])
		var/z = text2num(href_list["Z"])

		var/client/C = usr.client
		if(!isobserver(usr))
			C.admin_ghost()
		sleep(2)
		C.jumptocoord(x,y,z)

	else if(href_list["adminchecklaws"])
		if(!check_rights(R_ADMIN))
			return
		output_ai_laws()

	else if(href_list["admincheckdevilinfo"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/M = locate(href_list["admincheckdevilinfo"])
		output_devil_info(M)

	else if(href_list["adminmoreinfo"])
		admin_more_info(locate(href_list["adminmoreinfo"]) in GLOB.mob_list)

	else if(href_list["addjobslot"])
		if(!check_rights(R_ADMIN))
			return

		var/Add = href_list["addjobslot"]

		for(var/datum/job/job in SSjob.occupations)
			if(job.title == Add)
				job.total_positions += 1
				break

		src.manage_free_slots()


	else if(href_list["customjobslot"])
		if(!check_rights(R_ADMIN))
			return

		var/Add = href_list["customjobslot"]

		for(var/datum/job/job in SSjob.occupations)
			if(job.title == Add)
				var/newtime = null
				newtime = input(usr, "Ile chcesz etatów?", "Dodaj ogłoszenia o pracę", "[newtime]") as num|null
				if(!newtime)
					to_chat(src.owner, "Ustawiam na liczbę zajętych stanowisk w tym zawodzie")
					job.total_positions = job.current_positions
					break
				job.total_positions = newtime

		src.manage_free_slots()

	else if(href_list["removejobslot"])
		if(!check_rights(R_ADMIN))
			return

		var/Remove = href_list["removejobslot"]

		for(var/datum/job/job in SSjob.occupations)
			if(job.title == Remove && job.total_positions - job.current_positions > 0)
				job.total_positions -= 1
				break

		src.manage_free_slots()

	else if(href_list["unlimitjobslot"])
		if(!check_rights(R_ADMIN))
			return

		var/Unlimit = href_list["unlimitjobslot"]

		for(var/datum/job/job in SSjob.occupations)
			if(job.title == Unlimit)
				job.total_positions = -1
				break

		src.manage_free_slots()

	else if(href_list["limitjobslot"])
		if(!check_rights(R_ADMIN))
			return

		var/Limit = href_list["limitjobslot"]

		for(var/datum/job/job in SSjob.occupations)
			if(job.title == Limit)
				job.total_positions = job.current_positions
				break

		src.manage_free_slots()


	else if(href_list["adminspawncookie"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/living/carbon/human/H = locate(href_list["adminspawncookie"])
		if(!ishuman(H))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob/living/carbon/human.")
			return

		var/obj/item/food/cookie/cookie = new(H)
		if(H.put_in_hands(cookie))
			H.update_inv_hands()
		else
			qdel(cookie)
			log_admin("[key_name(H)] has their hands full, so they did not receive their cookie, spawned by [key_name(src.owner)].")
			message_admins("[key_name(H)] ma pełne ręce, więc nie dostaje ciasteczka od [key_name(src.owner)].")
			return

		log_admin("[key_name(H)] got their cookie, spawned by [key_name(src.owner)].")
		message_admins("[key_name(H)] dostaje ciasteczko od [key_name(src.owner)].")
		SSblackbox.record_feedback("amount", "admin_cookies_spawned", 1)
		to_chat(H, "<span class='adminnotice'>Twoje modlitwy zostały wysłuchane!! Otrzymujesz <b>najlepsze ciasteczko</b>!</span>")
		SEND_SOUND(H, sound('sound/effects/pray_chaplain.ogg'))

	else if(href_list["adminsmite"])
		if(!check_rights(R_ADMIN|R_FUN))
			return

		var/mob/living/carbon/human/H = locate(href_list["adminsmite"]) in GLOB.mob_list
		if(!H || !istype(H))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob/living/carbon/human")
			return

		usr.client.smite(H)

	else if(href_list["CentComReply"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["CentComReply"])
		usr.client.admin_headset_message(M, RADIO_CHANNEL_CENTCOM)

	else if(href_list["SyndicateReply"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["SyndicateReply"])
		usr.client.admin_headset_message(M, RADIO_CHANNEL_SYNDICATE)

	else if(href_list["HeadsetMessage"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["HeadsetMessage"])
		usr.client.admin_headset_message(M)

	else if(href_list["reject_custom_name"])
		if(!check_rights(R_ADMIN))
			return
		var/obj/item/station_charter/charter = locate(href_list["reject_custom_name"])
		if(istype(charter))
			charter.reject_proposed(usr)
	else if(href_list["jumpto"])
		if(!isobserver(usr) && !check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["jumpto"])
		usr.client.jumptomob(M)

	else if(href_list["getmob"])
		if(!check_rights(R_ADMIN))
			return

		if(alert(usr, "Potwierdzasz?", "Wiadomość", "Tak", "Nie") != "Tak")
			return
		var/mob/M = locate(href_list["getmob"])
		usr.client.Getmob(M)

	else if(href_list["sendmob"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["sendmob"])
		usr.client.sendmob(M)

	else if(href_list["narrateto"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["narrateto"])
		usr.client.cmd_admin_direct_narrate(M)

	else if(href_list["subtlemessage"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["subtlemessage"])
		usr.client.cmd_admin_subtle_message(M)

	else if(href_list["individuallog"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["individuallog"]) in GLOB.mob_list
		if(!ismob(M))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob.")
			return

		show_individual_logging_panel(M, href_list["log_src"], href_list["log_type"])
	else if(href_list["languagemenu"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["languagemenu"]) in GLOB.mob_list
		if(!ismob(M))
			to_chat(usr, "Można tego użyć tylko na instancjach typu /mob.")
			return
		var/datum/language_holder/H = M.get_language_holder()
		H.open_language_menu(usr)

	else if(href_list["traitor"])
		if(!check_rights(R_ADMIN))
			return

		if(!SSticker.HasRoundStarted())
			alert("Gra jeszcze się nie zaczęła!")
			return

		var/mob/M = locate(href_list["traitor"])
		if(!ismob(M))
			var/datum/mind/D = M
			if(!istype(D))
				to_chat(usr, "Można tego użyć tylko na instancjach typu /mob i /mind")
				return
			else
				D.traitor_panel()
		else
			show_traitor_panel(M)

	else if(href_list["borgpanel"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["borgpanel"])
		if(!iscyborg(M))
			to_chat(usr, "Można tego użyć tylko na cyborgach")
		else
			open_borgopanel(M)

	else if(href_list["initmind"])
		if(!check_rights(R_ADMIN))
			return
		var/mob/M = locate(href_list["initmind"])
		if(!ismob(M) || M.mind)
			to_chat(usr, "Można tego użyć tylko na mobach bez umysłu")
			return
		M.mind_initialize()

	else if(href_list["create_object"])
		if(!check_rights(R_SPAWN))
			return
		return create_object(usr)

	else if(href_list["quick_create_object"])
		if(!check_rights(R_SPAWN))
			return
		return quick_create_object(usr)

	else if(href_list["create_turf"])
		if(!check_rights(R_SPAWN))
			return
		return create_turf(usr)

	else if(href_list["create_mob"])
		if(!check_rights(R_SPAWN))
			return
		return create_mob(usr)

	else if(href_list["dupe_marked_datum"])
		if(!check_rights(R_SPAWN))
			return
		return DuplicateObject(marked_datum, perfectcopy=1, newloc=get_turf(usr))

	else if(href_list["object_list"])			//this is the laggiest thing ever
		if(!check_rights(R_SPAWN))
			return

		var/atom/loc = usr.loc

		var/dirty_paths
		if (istext(href_list["object_list"]))
			dirty_paths = list(href_list["object_list"])
		else if (istype(href_list["object_list"], /list))
			dirty_paths = href_list["object_list"]

		var/paths = list()

		for(var/dirty_path in dirty_paths)
			var/path = text2path(dirty_path)
			if(!path)
				continue
			else if(!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob))
				continue
			paths += path

		if(!paths)
			alert("Wysłana lista ścieżek jest pusta.")
			return
		if(length(paths) > 5)
			alert("Wybierz mniej typów obiektów (maks. 5).")
			return

		var/list/offset = splittext(href_list["offset"],",")
		var/number = CLAMP(text2num(href_list["object_count"]), 1, 100)
		var/X = offset.len > 0 ? text2num(offset[1]) : 0
		var/Y = offset.len > 1 ? text2num(offset[2]) : 0
		var/Z = offset.len > 2 ? text2num(offset[3]) : 0
		var/obj_dir = text2num(href_list["object_dir"])
		if(obj_dir && !(obj_dir in list(1,2,4,8,5,6,9,10)))
			obj_dir = null
		var/obj_name = sanitize(href_list["object_name"])


		var/atom/target //Where the object will be spawned
		var/where = href_list["object_where"]
		if (!( where in list("onfloor","frompod","inhand","inmarked") ))
			where = "onfloor"


		switch(where)
			if("inhand")
				if (!iscarbon(usr) && !iscyborg(usr))
					to_chat(usr, "Do ręki możesz tworzyć tylko jako mob węglowy albo cyborg.")
					where = "onfloor"
				target = usr

			if("onfloor", "frompod")
				switch(href_list["offset_type"])
					if ("absolute")
						target = locate(0 + X,0 + Y,0 + Z)
					if ("relative")
						target = locate(loc.x + X,loc.y + Y,loc.z + Z)
			if("inmarked")
				if(!marked_datum)
					to_chat(usr, "Nie masz oznaczonego obiektu. Przerywam tworzenie.")
					return
				else if(!istype(marked_datum, /atom))
					to_chat(usr, "Oznaczonego obiektu nie można użyć jako celu. Cel musi być typu /atom. Przerywam tworzenie.")
					return
				else
					target = marked_datum

		var/obj/structure/closet/supplypod/centcompod/pod

		if(target)
			if(where == "frompod")
				pod = new()

			for (var/path in paths)
				for (var/i = 0; i < number; i++)
					if(path in typesof(/turf))
						var/turf/O = target
						var/turf/N = O.ChangeTurf(path)
						if(N && obj_name)
							N.name = obj_name
					else
						var/atom/O
						if(where == "frompod")
							O = new path(pod)
						else
							O = new path(target)

						if(!QDELETED(O))
							O.flags_1 |= ADMIN_SPAWNED_1
							if(obj_dir)
								O.setDir(obj_dir)
							if(obj_name)
								O.name = obj_name
								if(ismob(O))
									var/mob/M = O
									M.real_name = obj_name
							if(where == "inhand" && isliving(usr) && isitem(O))
								var/mob/living/L = usr
								var/obj/item/I = O
								L.put_in_hands(I)
								if(iscyborg(L))
									var/mob/living/silicon/robot/R = L
									if(R.module)
										R.module.add_module(I, TRUE, TRUE)
										R.activate_module(I)

		if(pod)
			new /obj/effect/pod_landingzone(target, pod)

		var/turf/T = get_turf(usr.loc) // get admin's LOC as a turf

		if (number == 1)
			log_admin("[key_name(usr)] created a [english_list(paths)] at [AREACOORD(T)]")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[key_name_admin(usr)] tworzy: [english_list(paths)]")
					break
		else
			log_admin("[key_name(usr)] created [number]ea [english_list(paths)] at [AREACOORD(T)]")
			for(var/path in paths)
				if(ispath(path, /mob))
					message_admins("[key_name_admin(usr)] tworzy [number] szt.: [english_list(paths)]")
					break
		return

	else if(href_list["check_antagonist"])
		if(!check_rights(R_ADMIN))
			return
		usr.client.check_antagonists()

	else if(href_list["kick_all_from_lobby"])
		if(!check_rights(R_ADMIN))
			return
		if(SSticker.IsRoundInProgress())
			var/afkonly = text2num(href_list["afkonly"])
			if(alert("Czy na pewno chcesz wyrzucić z lobby wszystkich [afkonly ? "AFK" : ""] klientów??","Wiadomość","Tak","Anuluj") != "Tak")
				to_chat(usr, "Przerwano wyrzucanie klientów z lobby")
				return
			var/list/listkicked = kick_clients_in_lobby("<span class='danger'>Zostałeś wyrzucony z lobby przez [usr.client.holder.fakekey ? "Administratora" : "[usr.client.key]"].</span>", afkonly)

			var/strkicked = ""
			for(var/name in listkicked)
				strkicked += "[name], "
			message_admins("[key_name_admin(usr)] wyrzuca z lobby [afkonly ? "wszystkich klientów AFK" : "wszystkich klientów"]. Wyrzuceni ([length(listkicked)]): [strkicked ? strkicked : "--"]")
			log_admin("[key_name(usr)] has kicked [afkonly ? "all AFK" : "all"] clients from the lobby. [length(listkicked)] clients kicked: [strkicked ? strkicked : "--"]")
		else
			to_chat(usr, "Możesz tego użyć tylko w trakcie gry.")

	else if(href_list["set_selfdestruct_code"])
		if(!check_rights(R_ADMIN))
			return
		var/code = random_code(5)
		for(var/obj/machinery/nuclearbomb/selfdestruct/SD in GLOB.nuke_list)
			SD.r_code = code
		message_admins("[key_name_admin(usr)] ustawia kod \
			samozniszczenia na „[code]”.")

	else if(href_list["add_station_goal"])
		if(!check_rights(R_ADMIN))
			return
		var/list/type_choices = typesof(/datum/station_goal)
		var/picked = input("Wybierz typ celu") in type_choices|null
		if(!picked)
			return
		var/datum/station_goal/G = new picked()
		if(picked == /datum/station_goal)
			var/newname = capped_input(usr, "Podaj nazwę celu:")
			if(!newname)
				return
			G.name = newname
			var/description = capped_multiline_input(usr, "Podaj treść wiadomości od Centrali:")
			if(!description)
				return
			G.report_message = description
		message_admins("[key_name(usr)] tworzy cel stacji „[G.name]”.")
		SSticker.mode.station_goals += G
		modify_goals()

	else if(href_list["viewruntime"])
		var/datum/error_viewer/error_viewer = locate(href_list["viewruntime"])
		if(!istype(error_viewer))
			to_chat(usr, "<span class='warning'>Ten podgląd runtime'u już nie istnieje.</span>")
			return

		if(href_list["viewruntime_backto"])
			error_viewer.show_to(owner, locate(href_list["viewruntime_backto"]), href_list["viewruntime_linear"])
		else
			error_viewer.show_to(owner, null, href_list["viewruntime_linear"])

	else if(href_list["showrelatedacc"])
		if(!check_rights(R_ADMIN))
			return
		var/client/C = locate(href_list["client"]) in GLOB.clients
		var/thing_to_check
		if(href_list["showrelatedacc"] == "cid")
			thing_to_check = C.related_accounts_cid
		else
			thing_to_check = C.related_accounts_ip
		thing_to_check = splittext(thing_to_check, ", ")


		var/list/dat = list("Powiązane konta wg [uppertext(href_list["showrelatedacc"])]:")
		dat += thing_to_check

		var/datum/browser/browser = new(usr, "related_[C]", "Powiązane konta: [C.ckey]", 420, 300)
		browser.set_content(dat.Join("<br>"))
		browser.open()

	else if(href_list["centcomlookup"])
		if(!check_rights(R_ADMIN))
			return

		if(!CONFIG_GET(string/centcom_ban_db))
			to_chat(usr, "<span class='warning'>Galaktyczna baza banów Centrali jest wyłączona!</span>")
			return

		var/ckey = href_list["centcomlookup"]

		// Make the request
		var/datum/http_request/request = new()
		request.prepare(RUSTG_HTTP_METHOD_GET, "[CONFIG_GET(string/centcom_ban_db)]/[ckey]", "", "")
		request.begin_async()
		UNTIL(request.is_complete() || !usr)
		if (!usr)
			return
		var/datum/http_response/response = request.into_response()

		var/list/bans

		var/list/dat = list()

		if(response.errored)
			dat += "<br>Nie udało się połączyć z Centralą."
		else if(response.status_code != 200)
			dat += "<br>Nie udało się połączyć z Centralą. Kod statusu: [response.status_code]"
		else
			if(response.body == "[]")
				dat += "<center><b>Wykryte bany dla [ckey]: 0</b></center>"
			else
				bans = json_decode(response.body) // AQ EDIT - response to datum, nie lista (runtime przy każdym graczu z banami)
				dat += "<center><b>Wykryte bany dla [ckey]: [bans.len]</b></center>"
				for(var/list/ban in bans)
					dat += "<b>Serwer: </b> [sanitize(ban["sourceName"])]<br>"
					dat += "<b>Poziom RP: </b> [sanitize(ban["sourceRoleplayLevel"])]<br>"
					dat += "<b>Typ: </b> [sanitize(ban["type"])]<br>"
					dat += "<b>Zbanował: </b> [sanitize(ban["bannedBy"])]<br>"
					dat += "<b>Powód: </b> [sanitize(ban["reason"])]<br>"
					dat += "<b>Data i godzina: </b> [sanitize(ban["bannedOn"])]<br>"
					var/expiration = ban["expires"]
					dat += "<b>Wygasa: </b> [expiration ? "[sanitize(expiration)]" : "permanentny"]<br>"
					if(ban["type"] == "job")
						dat += "<b>Zawody: </b> "
						var/list/jobs = ban["jobs"]
						dat += sanitize(jobs.Join(", "))
						dat += "<br>"
					dat += "<hr>"

		var/datum/browser/popup = new(usr, "centcomlookup-[ckey]", "<div align='center'>Galaktyczna baza banów Centrali</div>", 700, 600)
		popup.set_content(dat.Join())
		popup.open(FALSE)

	else if(href_list["modantagrep"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["mob"]) in GLOB.mob_list
		var/client/C = M.client
		usr.client.cmd_admin_mod_antag_rep(C, href_list["modantagrep"])
		show_player_panel(M)

	else if(href_list["slowquery"])
		if(!check_rights(R_ADMIN))
			return
		var/answer = href_list["slowquery"]
		if(answer == "yes")
			log_query_debug("[usr.key] | Reported a server hang")
			if(alert(usr, "Czy właśnie naciskałeś jakieś przyciski admina?", "Zgłoszenie zawieszenia serwera", "Tak", "Nie") == "Tak")
				var/response = input(usr,"Co właśnie robiłeś?","Zgłoszenie zawieszenia serwera") as null|text
				if(response)
					log_query_debug("[usr.key] | [response]")
		else if(answer == "no")
			log_query_debug("[usr.key] | Reported no server hang")

	else if(href_list["ctf_toggle"])
		if(!check_rights(R_ADMIN))
			return
		toggle_all_ctf(usr)

	else if(href_list["rebootworld"])
		if(!check_rights(R_ADMIN))
			return
		var/confirm = alert("Czy na pewno chcesz zrestartować serwer?", "Potwierdź restart", "Tak", "Nie")
		if(confirm != "Tak")
			return
		restart()

	else if(href_list["check_teams"])
		if(!check_rights(R_ADMIN))
			return
		check_teams()

	else if(href_list["team_command"])
		if(!check_rights(R_ADMIN))
			return
		switch(href_list["team_command"])
			if("create_team")
				admin_create_team(usr)
			if("rename_team")
				var/datum/team/T = locate(href_list["team"]) in GLOB.antagonist_teams
				if(T)
					T.admin_rename(usr)
			if("communicate")
				var/datum/team/T = locate(href_list["team"]) in GLOB.antagonist_teams
				if(T)
					T.admin_communicate(usr)
			if("delete_team")
				var/datum/team/T = locate(href_list["team"]) in GLOB.antagonist_teams
				if(T)
					T.admin_delete(usr)
			if("add_objective")
				var/datum/team/T = locate(href_list["team"]) in GLOB.antagonist_teams
				if(T)
					T.admin_add_objective(usr)
			if("edit_objective")
				var/datum/team/T = locate(href_list["team"]) in GLOB.antagonist_teams
				if(!T)
					return
				var/datum/objective/O = locate(href_list["tobjective"]) in T.objectives
				if(O)
					T.admin_edit_objective(usr,O)
			if("remove_objective")
				var/datum/team/T = locate(href_list["team"]) in GLOB.antagonist_teams
				if(!T)
					return
				var/datum/objective/O = locate(href_list["tobjective"]) in T.objectives
				if(O)
					T.admin_remove_objective(usr,O)
			if("add_member")
				var/datum/team/T = locate(href_list["team"]) in GLOB.antagonist_teams
				if(T)
					T.admin_add_member(usr)
			if("remove_member")
				var/datum/team/T = locate(href_list["team"]) in GLOB.antagonist_teams
				if(!T)
					return
				var/datum/mind/M = locate(href_list["tmember"]) in T.members
				if(M)
					T.admin_remove_member(usr,M)
		check_teams()

	else if(href_list["newbankey"])
		var/player_key = href_list["newbankey"]
		var/player_ip = href_list["newbanip"]
		var/player_cid = href_list["newbancid"]
		ban_panel(player_key, player_ip, player_cid)

	else if(href_list["intervaltype"]) //check for ban panel, intervaltype is used as it's the only value which will always be present
		if(href_list["roleban_delimiter"])
			ban_parse_href(href_list)
		else
			ban_parse_href(href_list, TRUE)

	else if(href_list["searchunbankey"] || href_list["searchunbanadminkey"] || href_list["searchunbanip"] || href_list["searchunbancid"])
		var/player_key = href_list["searchunbankey"]
		var/admin_key = href_list["searchunbanadminkey"]
		var/player_ip = href_list["searchunbanip"]
		var/player_cid = href_list["searchunbancid"]
		unban_panel(player_key, admin_key, player_ip, player_cid)

	else if(href_list["unbanpagecount"])
		var/page = href_list["unbanpagecount"]
		var/player_key = href_list["unbankey"]
		var/admin_key = href_list["unbanadminkey"]
		var/player_ip = href_list["unbanip"]
		var/player_cid = href_list["unbancid"]
		unban_panel(player_key, admin_key, player_ip, player_cid, page)

	else if(href_list["editbanid"])
		var/edit_id = href_list["editbanid"]
		var/player_key = href_list["editbankey"]
		var/player_ip = href_list["editbanip"]
		var/player_cid = href_list["editbancid"]
		var/role = href_list["editbanrole"]
		var/duration = href_list["editbanduration"]
		var/applies_to_admins = text2num(href_list["editbanadmins"])
		var/reason = rustg_url_decode(href_list["editbanreason"])
		var/page = href_list["editbanpage"]
		var/admin_key = href_list["editbanadminkey"]
		ban_panel(player_key, player_ip, player_cid, role, duration, applies_to_admins, reason, edit_id, page, admin_key)

	else if(href_list["unbanid"])
		var/ban_id = href_list["unbanid"]
		var/player_key = href_list["unbankey"]
		var/player_ip = href_list["unbanip"]
		var/player_cid = href_list["unbancid"]
		var/role = href_list["unbanrole"]
		var/page = href_list["unbanpage"]
		var/admin_key = href_list["unbanadminkey"]
		unban(ban_id, player_key, player_ip, player_cid, role, page, admin_key)

	else if(href_list["unbanlog"])
		var/ban_id = href_list["unbanlog"]
		ban_log(ban_id)

	else if(href_list["modantagtokens"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["mob"]) in GLOB.mob_list
		var/client/C = M.client
		usr.client.cmd_admin_mod_antag_tokens(C, href_list["modantagtokens"])
		show_player_panel(M)

//AQ EDIT
	else if(href_list["modmetacoins"])
		if(!check_rights(R_ADMIN))
			return

		var/mob/M = locate(href_list["mob"]) in GLOB.mob_list
		var/client/C = M.client
		usr.client.cmd_admin_mod_metacoins(C, href_list["modmetacoins"])
		show_player_panel(M)
//AQ EDIT

	else if(href_list["retrieveboh"])
		var/obj/boh_tear/tear = locate(href_list["retrieveboh"])
		if(!tear)
			to_chat(usr, "Przedmioty zostały już odzyskane albo minęło 10 minut i zostały usunięte.")
			return
		var/confirm = alert("To przeniesie wszystkie przedmioty pochłonięte przez rozdarcie BoH z powrotem w pierwotne miejsce rozdarcia i usunie BoH, jeśli wciąż istnieje. Na pewno?", "Potwierdź ograniczanie szkód", "Tak", "Nie")
		if(confirm != "Tak")
			return
		var/turf/T = get_turf(tear.old_loc)
		message_admins("[key_name_admin(usr)] odzyskuje przedmioty pochłonięte przez rozdarcie BoH w [ADMIN_VERBOSEJMP(T)].")
		tear.investigate_log("Items consumed at [AREACOORD(T)] retrieved by [key_name(usr)].", INVESTIGATE_ENGINES)
		tear.retrieve_consumed_items()

	else if(href_list["reloadpolls"])
		GLOB.polls.Cut()
		GLOB.poll_options.Cut()
		load_poll_data()
		poll_list_panel()

	else if(href_list["newpoll"])
		poll_management_panel()

	else if(href_list["editpoll"])
		var/datum/poll_question/poll = locate(href_list["editpoll"]) in GLOB.polls
		poll_management_panel(poll)

	else if(href_list["deletepoll"])
		var/datum/poll_question/poll = locate(href_list["deletepoll"]) in GLOB.polls
		poll.delete_poll()
		poll_list_panel()

	else if(href_list["initializepoll"])
		poll_parse_href(href_list)

	else if(href_list["submitpoll"])
		var/datum/poll_question/poll = locate(href_list["submitpoll"]) in GLOB.polls
		poll_parse_href(href_list, poll)

	else if(href_list["clearpollvotes"])
		var/datum/poll_question/poll = locate(href_list["clearpollvotes"]) in GLOB.polls
		poll.clear_poll_votes()
		poll_management_panel(poll)

	else if(href_list["addpolloption"])
		var/datum/poll_question/poll = locate(href_list["addpolloption"]) in GLOB.polls
		poll_option_panel(poll)

	else if(href_list["editpolloption"])
		var/datum/poll_option/option = locate(href_list["editpolloption"]) in GLOB.poll_options
		var/datum/poll_question/poll = locate(href_list["parentpoll"]) in GLOB.polls
		poll_option_panel(poll, option)

	else if(href_list["deletepolloption"])
		var/datum/poll_option/option = locate(href_list["deletepolloption"]) in GLOB.poll_options
		var/datum/poll_question/poll = option.delete_option()
		poll_management_panel(poll)

	else if(href_list["submitoption"])
		var/datum/poll_option/option = locate(href_list["submitoption"]) in GLOB.poll_options
		var/datum/poll_question/poll = locate(href_list["submitoptionpoll"]) in GLOB.polls
		poll_option_parse_href(href_list, poll, option)

	else if (href_list["interview"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/interview/I = locate(href_list["interview"])
		if (I)
			I.ui_interact(usr)

	else if (href_list["interview_man"])
		if(!check_rights(R_ADMIN))
			return
		GLOB.interviews.ui_interact(usr)

	else if(href_list["tag_datum"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/datum_to_tag = locate(href_list["tag_datum"])
		if(!datum_to_tag)
			return
		return add_tagged_datum(datum_to_tag)

	else if(href_list["del_tag"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/datum_to_remove = locate(href_list["del_tag"])
		if(!datum_to_remove)
			return
		return remove_tagged_datum(datum_to_remove)

	else if(href_list["show_tags"])
		if(!check_rights(R_ADMIN))
			return
		return display_tags()

	else if(href_list["mark_datum"])
		if(!check_rights(R_ADMIN))
			return
		var/datum/datum_to_mark = locate(href_list["mark_datum"])
		if(!datum_to_mark)
			return
		return usr.client?.mark_datum(datum_to_mark)
		
// AQUILA EDIT - wybór trybu i wymuszenie trybu w secret są teraz sekcjami Game Panelu (TGUI)
/datum/admins/proc/HandleCMode()
	if(!check_rights(R_ADMIN))
		return
	Game()

/datum/admins/proc/HandleFSecret()
	if(!check_rights(R_ADMIN))
		return

	if(SSticker.HasRoundStarted())
		return alert(usr, "Gra już się zaczęła.", null, null, null, null)
	if(GLOB.master_mode != "secret")
		return alert(usr, "Tryb gry musi być trybem secret!", null, null, null, null)
	Game()
