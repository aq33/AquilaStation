// AQUILA - SOP alarmów: krótka ściąga, co robić przy którym stanie okrętu.
// Po każdej zmianie stanu załoga dostaje w czacie listę zasad pod ogłoszeniem, a w PDA jest program „SOP” z całą ściągą
// i zaznaczonym obecnym stanem. Treść jest w jednym miejscu (alert_sop_catalog), więc czat i PDA mówią to samo.

/// Ściąga SOP: jedna pozycja na stan okrętu, od najspokojniejszego
/proc/alert_sop_catalog()
	var/static/list/catalog
	if(catalog)
		return catalog
	catalog = list(
		list(
			"level" = SEC_LEVEL_GREEN,
			"name" = "Stan 3: tryb swobodny",
			"colour" = "green",
			"rules" = list(
				"Poza wachtą wolno opuścić stanowisko i odpocząć.",
				"Broń schowana, żandarmeria nie przeszukuje bez powodu.",
				"Dostępy działów jak zwykle, gości wpuszcza się za zgodą.",
			),
		),
		list(
			"level" = SEC_LEVEL_BLUE,
			"name" = "Stan 2: standardowe procedury",
			"colour" = "blue",
			"rules" = list(
				"Cała załoga na swoich stanowiskach.",
				"Żandarmeria może legitymować i przeszukiwać podejrzanych.",
				"Czujniki kombinezonu ustaw na pełne śledzenie.",
			),
		),
		list(
			"level" = SEC_LEVEL_RED,
			"name" = "Alarm bojowy",
			"colour" = "red",
			"rules" = list(
				"Natychmiast na stanowisko bojowe: amunicja, maszynownia, piloci, medycy.",
				"Bez przydziału bojowego zejdź z korytarzy i zostań w swoim dziale.",
				"Skafander próżniowy i butla pod ręką, czujniki na pełne śledzenie.",
				"Żandarmeria zatrzymuje osoby kręcące się bez powodu.",
			),
		),
		list(
			"level" = SEC_LEVEL_ZEBRA,
			"name" = "Stan obronny „Zebra”",
			"colour" = "orange",
			"rules" = list(
				"Blokady przedziałów są zamknięte. Nie otwieraj grodzi bez rozkazu.",
				"Kontrola uszkodzeń w gotowości, reszta zostaje w swoim przedziale.",
				"Spodziewaj się ostrzału i dekompresji: hełm i butla gotowe.",
			),
		),
		list(
			"level" = SEC_LEVEL_DELTA,
			"name" = "Stan Delta: autodestrukcja",
			"colour" = "purple",
			"rules" = list(
				"Natychmiast do kapsuł ratunkowych albo promów.",
				"Zabierz rannych po drodze, nie wracaj po rzeczy.",
			),
		),
	)
	return catalog

/proc/alert_sop_entry(level)
	for(var/list/entry as anything in alert_sop_catalog())
		if(entry["level"] == level)
			return entry

/// Blok SOP pod ogłoszeniem zmiany stanu
/proc/alert_sop_chat_text(level)
	var/list/entry = alert_sop_entry(level)
	if(!entry)
		return
	. = "<span class='notice'><b>SOP — [entry["name"]]:</b>"
	for(var/rule in entry["rules"])
		. += "<br>• [rule]"
	. += "<br><i>Cała ściąga: program „SOP” w PDA.</i></span>"

SUBSYSTEM_DEF(alert_sop)
	name = "SOP alarmów"
	flags = SS_NO_FIRE

/datum/controller/subsystem/alert_sop/Initialize(start_timeofday)
	RegisterSignal(SSdcs, COMSIG_GLOB_SECURITY_ALERT_CHANGE, PROC_REF(on_alert_change))
	return ..()

/datum/controller/subsystem/alert_sop/proc/on_alert_change(datum/source, level)
	SIGNAL_HANDLER
	var/text = alert_sop_chat_text(level)
	if(!text)
		return
	for(var/mob/living/crew in GLOB.player_list)
		if(crew.stat == DEAD || !crew.mind?.assigned_role || !is_station_level(crew.z))
			continue
		to_chat(crew, text)

/datum/computer_file/program/alert_sop
	filename = "sop"
	filedesc = "SOP"
	category = PROGRAM_CATEGORY_CREW
	program_icon_state = "generic"
	extended_desc = "Ściąga standardowych procedur: co robić przy którym stanie okrętu."
	size = 1
	tgui_id = "NtosAlertSop"
	program_icon = "clipboard-list"
	usage_flags = PROGRAM_ALL
	available_on_ntnet = TRUE

/datum/computer_file/program/alert_sop/ui_static_data(mob/user)
	. = ..()
	.["levels"] = alert_sop_catalog()

/datum/computer_file/program/alert_sop/ui_data(mob/user)
	. = ..()
	.["current"] = GLOB.security_level

/// SOP jest na każdym nowym PDA
/obj/item/computer_hardware/hard_drive/small/pda/install_default_programs()
	. = ..()
	store_file(new /datum/computer_file/program/alert_sop(src))
