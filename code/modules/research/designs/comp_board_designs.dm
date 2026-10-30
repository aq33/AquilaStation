///////////////////Computer Boards///////////////////////////////////

/datum/design/board
	name = "Projekt komputera ( PUSTY WPIS )"
	desc = "Przysięgam, że to nie daje ci gadżetów Syndykatu!"
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 1000, /datum/material/copper = 300)

/datum/design/board/arcade_battle
	name = "Projekt komputera (automat do gier: bitwa)"
	desc = "Pozwala zbudować płytkę drukowaną: automat do gier: bitwa."
	id = "arcade_battle"
	build_path = /obj/item/circuitboard/computer/arcade/battle
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/board/orion_trail
	name = "Projekt komputera (automat do gier: Orion Trail)"
	desc = "Pozwala zbudować płytkę drukowaną: automat Orion Trail."
	id = "arcade_orion"
	build_path = /obj/item/circuitboard/computer/arcade/orion_trail
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/board/amputation_adventure
	name = "Projekt komputera (Amputacyjna przygoda Mediborga)"
	desc = "Pozwala zbudować płytkę drukowaną: automat „Amputacyjna przygoda Mediborga”."
	id = "arcade_amputation"
	build_path = /obj/item/circuitboard/computer/arcade/amputation
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/board/amputation_adventure
	name = "Projekt komputera (Amputacyjna przygoda Mediborga)"
	desc = "Pozwala zbudować płytkę drukowaną: automat „Amputacyjna przygoda Mediborga”."
	id = "arcade_amputation"
	build_path = /obj/item/circuitboard/computer/arcade/amputation
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/board/seccamera
	name = "Projekt komputera (konsola kamer ochrony)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola kamer ochrony."
	id = "seccamera"
	build_path = /obj/item/circuitboard/computer/security
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/board/rdcamera
	name = "Projekt komputera (konsola kamer działu naukowego)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola kamer działu naukowego."
	id = "rdcamera"
	build_path = /obj/item/circuitboard/computer/research
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/xenobiocamera
	name = "Projekt komputera (konsola zarządzania szlamami)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola zarządzania szlamami."
	id = "xenobioconsole"
	build_path = /obj/item/circuitboard/computer/xenobiology
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/aiupload
	name = "Projekt komputera (konsola przesyłania praw SI)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola przesyłania praw SI."
	id = "aiupload"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 2000, /datum/material/copper = 300)
	build_path = /obj/item/circuitboard/computer/aiupload
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/borgupload
	name = "Projekt komputera (konsola przesyłania praw cyborgów)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola przesyłania praw cyborgów."
	id = "borgupload"
	materials = list(/datum/material/glass = 1000, /datum/material/gold = 2000, /datum/material/copper = 300)
	build_path = /obj/item/circuitboard/computer/borgupload
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/med_data
	name = "Projekt komputera (konsola akt medycznych)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola akt medycznych."
	id = "med_data"
	build_path = /obj/item/circuitboard/computer/med_data
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/board/operating
	name = "Projekt komputera (komputer operacyjny)"
	desc = "Pozwala zbudować płytkę drukowaną: komputer operacyjny."
	id = "operating"
	build_path = /obj/item/circuitboard/computer/operating
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/pandemic
	name = "Projekt komputera (PanD.E.M.I.C. 2200)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola PanD.E.M.I.C. 2200."
	id = "pandemic"
	build_path = /obj/item/circuitboard/computer/pandemic
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/datum/design/board/scan_console
	name = "Projekt komputera (konsola dostępu do skanera DNA)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola skanera DNA."
	id = "scan_console"
	build_path = /obj/item/circuitboard/computer/scan_consolenew
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/comconsole
	name = "Projekt komputera (konsola komunikacyjna)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola komunikacyjna."
	id = "comconsole"
	build_path = /obj/item/circuitboard/computer/communications
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SECURITY				//Honestly should have a bridge techfab for this sometime.

/datum/design/board/idcardconsole
	name = "Projekt komputera (konsola identyfikacyjna)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola identyfikacyjna."
	id = "idcardconsole"
	build_path = /obj/item/circuitboard/computer/card
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING | DEPARTMENTAL_FLAG_SECURITY				//Honestly should have a bridge techfab for this sometime.

/datum/design/board/crewconsole
	name = "Projekt komputera (konsola monitorowania załogi)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola monitorowania załogi."
	id = "crewconsole"
	build_path = /obj/item/circuitboard/computer/crew
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY | DEPARTMENTAL_FLAG_MEDICAL

/datum/design/board/secdata
	name = "Projekt komputera (konsola akt ochrony)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola akt ochrony."
	id = "secdata"
	build_path = /obj/item/circuitboard/computer/secure_data
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/board/atmosalerts
	name = "Projekt komputera (konsola alarmów atmosferycznych)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola alarmów atmosferycznych."
	id = "atmosalerts"
	build_path = /obj/item/circuitboard/computer/atmos_alert
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/atmos_control
	name = "Projekt komputera (monitoring atmosferyki)"
	desc = "Pozwala zbudować płytkę drukowaną: monitoring atmosferyki."
	id = "atmos_control"
	build_path = /obj/item/circuitboard/computer/atmos_control
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/robocontrol
	name = "Projekt komputera (konsola sterowania robotyką)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola sterowania robotyką."
	id = "robocontrol"
	build_path = /obj/item/circuitboard/computer/robotics
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/slot_machine
	name = "Projekt komputera (jednoręki bandyta)"
	desc = "Pozwala zbudować płytkę drukowaną: jednoręki bandyta."
	id = "slotmachine"
	build_path = /obj/item/circuitboard/computer/slot_machine
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/board/powermonitor
	name = "Projekt komputera (konsola monitorowania zasilania)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola monitorowania zasilania."
	id = "powermonitor"
	build_path = /obj/item/circuitboard/computer/powermonitor
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/solarcontrol
	name = "Projekt komputera (konsola paneli słonecznych)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola sterowania panelami słonecznymi."
	id = "solarcontrol"
	build_path = /obj/item/circuitboard/computer/solar_control
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/prisonmanage // NSV13 modified - fix
	name = "Projekt komputera (konsola zarządzania więźniami)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola zarządzania więźniami."
	id = "prisonmanage"
	build_path = /obj/item/circuitboard/computer/prisoner/management
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/board/mechacontrol
	name = "Projekt komputera (konsola sterowania egzoszkieletami)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola sterowania egzoszkieletami."
	id = "mechacontrol"
	build_path = /obj/item/circuitboard/computer/mecha_control
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/mechapower
	name = "Projekt komputera (konsola sterowania zasilaniem warsztatu mechów)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola sterowania zasilaniem warsztatu mechów."
	id = "mechapower"
	build_path = /obj/item/circuitboard/computer/mech_bay_power_console
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/rdconsole
	name = "Projekt komputera (konsola B+R)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola B+R."
	id = "rdconsole"
	build_path = /obj/item/circuitboard/computer/rdconsole
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/cargo
	name = "Projekt komputera (konsola zaopatrzenia)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola zaopatrzenia."
	id = "cargo"
	build_path = /obj/item/circuitboard/computer/cargo
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/board/objective
	name = "Projekt komputera (konsola celów stacji)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola celów stacji."
	id = "objective"
	build_path = /obj/item/circuitboard/computer/objective
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/cargorequest
	name = "Projekt komputera (konsola zgłoszeń zaopatrzenia)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola zgłoszeń zaopatrzenia."
	id = "cargorequest"
	build_path = /obj/item/circuitboard/computer/cargo/request
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/board/bounty
	name = "Projekt komputera (konsola zleceń Nanotrasen)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola zleceń Nanotrasen."
	id = "bounty"
	build_path = /obj/item/circuitboard/computer/bounty
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/board/mining
	name = "Projekt komputera (konsola kamer placówki)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola wyświetlacza stanu placówki."
	id = "mining"
	build_path = /obj/item/circuitboard/computer/mining
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO | DEPARTMENTAL_FLAG_SECURITY

/datum/design/board/comm_monitor
	name = "Projekt komputera (konsola monitorowania telekomunikacji)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola monitorowania telekomunikacji."
	id = "comm_monitor"
	build_path = /obj/item/circuitboard/computer/comm_monitor
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/comm_server
	name = "Projekt komputera (konsola monitorowania serwerów telekomunikacji)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola przeglądania i monitorowania serwerów telekomunikacji."
	id = "comm_server"
	build_path = /obj/item/circuitboard/computer/comm_server
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/message_monitor
	name = "Projekt komputera (konsola monitorowania wiadomości)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola monitorowania wiadomości."
	id = "message_monitor"
	build_path = /obj/item/circuitboard/computer/message_monitor
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/aifixer
	name = "Projekt komputera (przywracacz integralności systemu SI)"
	desc = "Pozwala zbudować płytkę drukowaną: przywracacz integralności systemu SI."
	id = "aifixer"
	build_path = /obj/item/circuitboard/computer/aifixer
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/libraryconsole
	name = "Projekt komputera (konsola czytelnika biblioteki)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola czytelni."
	id = "libraryconsole"
	build_path = /obj/item/circuitboard/computer/libraryconsole
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ALL

/datum/design/board/apc_control
	name = "Projekt komputera (konsola sterowania przepływem energii)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola sterowania APC."
	id = "apc_control"
	build_path = /obj/item/circuitboard/computer/apc_control
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_ENGINEERING

/datum/design/board/nanite_chamber_control
	name = "Projekt komputera (konsola sterowania komorą nanitów)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola sterowania komorą nanitów."
	id = "nanite_chamber_control"
	build_path = /obj/item/circuitboard/computer/nanite_chamber_control
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/nanite_cloud_control
	name = "Projekt komputera (kontroler chmury nanitów)"
	desc = "Pozwala zbudować płytkę drukowaną: kontroler chmury nanitów."
	id = "nanite_cloud_control"
	build_path = /obj/item/circuitboard/computer/nanite_cloud_controller
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE

/datum/design/board/advanced_camera
	name = "Projekt komputera (zaawansowana konsola kamer)"
	desc = "Pozwala zbudować płytkę drukowaną: zaawansowana konsola kamer."
	id = "advanced_camera"
	build_path = /obj/item/circuitboard/computer/advanced_camera
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/design/board/shuttle/flight_control
	name = "Projekt komputera (sterownik lotu promu)"
	desc = "Pozwala zbudować płytkę drukowaną: konsola sterowania lotem promu."
	id = "shuttle_control"
	build_path = /obj/item/circuitboard/computer/shuttle/flight_control
	category = list("Computer Boards", "Shuttle Machinery")
	departmental_flags = DEPARTMENTAL_FLAG_SCIENCE | DEPARTMENTAL_FLAG_ENGINEERING
