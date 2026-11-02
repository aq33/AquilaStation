//Command boards


/obj/item/circuitboard/computer/aiupload
	name = "konsola przesyłania praw SI (płytka komputera)"
	icon_state = "command"
	build_path = /obj/machinery/computer/upload/ai

/obj/item/circuitboard/computer/borgupload
	name = "konsola przesyłania praw cyborgów (płytka komputera)"
	icon_state = "command"
	build_path = /obj/machinery/computer/upload/borg

/obj/item/circuitboard/computer/bsa_control
	name = "sterowanie artylerią bluespace (płytka komputera)"
	icon_state = "command"
	build_path = /obj/machinery/computer/bsa_control

/obj/item/circuitboard/computer/card
	name = "konsola identyfikacyjna (płytka komputera)"
	icon_state = "command"
	build_path = /obj/machinery/computer/card

/obj/item/circuitboard/computer/card/centcom
	name = "konsola identyfikacyjna Centrali (płytka komputera)"
	icon_state = "command"
	build_path = /obj/machinery/computer/card/centcom

/obj/item/circuitboard/computer/card/minor
	name = "konsola zarządzania działem (płytka komputera)"
	icon_state = "command"
	build_path = /obj/machinery/computer/card/minor
	var/target_dept = 1
	var/list/dept_list = list("ogólny","ochrona","medyczny","nauka","inżynieria")

/obj/item/circuitboard/computer/card/minor/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		target_dept = (target_dept == dept_list.len) ? 1 : (target_dept + 1)
		to_chat(user, "<span class='notice'>Ustawiasz płytkę na \"[dept_list[target_dept]]\".</span>")
	else
		return ..()

/obj/item/circuitboard/computer/card/minor/examine(user)
	. = ..()
	. += "Obecnie ustawiona na \"[dept_list[target_dept]]\"."

/obj/item/circuitboard/computer/communications
	name = "konsola komunikacyjna (płytka komputera)"
	icon_state = "command"
	desc = "Można ją zmodyfikować śrubokrętem."
	build_path = /obj/machinery/computer/communications
	var/insecure = FALSE // Forbids shuttles that are set as illegal.

/obj/item/circuitboard/computer/communications/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		insecure = !insecure
		if(insecure)
			desc = "Ktoś przy niej majstrował i usunął część zabezpieczeń. Śrubokręt może to odwrócić."
			to_chat(user, "<span class='notice'>Wyłączasz zabezpieczenia promu na płytce.</span>")
		else
			desc = "Można ją zmodyfikować śrubokrętem."
			to_chat(user, "<span class='notice'>Ponownie włączasz zabezpieczenia promu na płytce.</span>")
	else
		return ..()

//obj/item/circuitboard/computer/shield
//	name = "Shield Control (Computer Board)"
//	build_path = /obj/machinery/computer/stationshield


//Engineering


/obj/item/circuitboard/computer/apc_control
	name = "konsola sterowania przepływem energii (płytka komputera)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/apc_control

/obj/item/circuitboard/computer/atmos_alert
	name = "konsola alarmów atmosferycznych (płytka komputera)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/atmos_alert

/obj/item/circuitboard/computer/atmos_control
	name = "monitoring atmosferyki (płytka komputera)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/atmos_control

/obj/item/circuitboard/computer/atmos_control/tank
	name = "konsola sterowania zbiornikiem (płytka komputera)"
	build_path = /obj/machinery/computer/atmos_control/tank

/obj/item/circuitboard/computer/atmos_control/tank/oxygen_tank
	name = "sterowanie dopływem tlenu (płytka komputera)"
	build_path = /obj/machinery/computer/atmos_control/tank/oxygen_tank

/obj/item/circuitboard/computer/atmos_control/tank/toxin_tank
	name = "sterowanie dopływem plazmy (płytka komputera)"
	build_path = /obj/machinery/computer/atmos_control/tank/toxin_tank

/obj/item/circuitboard/computer/atmos_control/tank/air_tank
	name = "sterowanie dopływem mieszanki powietrza (płytka komputera)"
	build_path = /obj/machinery/computer/atmos_control/tank/air_tank

/obj/item/circuitboard/computer/atmos_control/tank/mix_tank
	name = "sterowanie zbiornikiem mieszanki gazów (płytka komputera)"
	build_path = /obj/machinery/computer/atmos_control/tank/mix_tank

/obj/item/circuitboard/computer/atmos_control/tank/nitrous_tank
	name = "sterowanie dopływem podtlenku azotu (płytka komputera)"
	build_path = /obj/machinery/computer/atmos_control/tank/nitrous_tank

/obj/item/circuitboard/computer/atmos_control/tank/nitrogen_tank
	name = "sterowanie dopływem azotu (płytka komputera)"
	build_path = /obj/machinery/computer/atmos_control/tank/nitrogen_tank

/obj/item/circuitboard/computer/atmos_control/tank/carbon_tank
	name = "sterowanie dopływem dwutlenku węgla (płytka komputera)"
	build_path = /obj/machinery/computer/atmos_control/tank/carbon_tank

/obj/item/circuitboard/computer/atmos_control/tank/incinerator
	name = "sterowanie powietrzem spalarni (płytka komputera)"
	build_path = /obj/machinery/computer/atmos_control/tank/incinerator

/obj/item/circuitboard/computer/auxillary_base
	name = "konsola zarządzania bazą pomocniczą (płytka komputera)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/auxillary_base

/obj/item/circuitboard/computer/base_construction
	name = "konsola budowy pomocniczej bazy górniczej (płytka komputera)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/camera_advanced/base_construction

/obj/item/circuitboard/computer/comm_monitor
	name = "konsola monitorowania telekomunikacji (płytka komputera)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/telecomms/monitor

/obj/item/circuitboard/computer/comm_server
	name = "konsola monitorowania serwerów telekomunikacji (płytka komputera)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/telecomms/server

/obj/item/circuitboard/computer/message_monitor
	name = "konsola monitorowania wiadomości (płytka komputera)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/message_monitor

/obj/item/circuitboard/computer/powermonitor
	name = "konsola monitorowania zasilania (płytka komputera)"  //name fixed 250810
	icon_state = "engineering"
	build_path = /obj/machinery/computer/monitor

/obj/item/circuitboard/computer/powermonitor/secret
	name = "przestarzała konsola monitorowania zasilania (płytka komputera)" //Variant used on ruins to prevent them from showing up on PDA's.
	build_path = /obj/machinery/computer/monitor/secret

/obj/item/circuitboard/computer/sat_control
	name = "sterowanie satelitami (płytka komputera)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/sat_control

/obj/item/circuitboard/computer/solar_control
	name = "konsola paneli słonecznych (płytka komputera)"  //name fixed 250810
	icon_state = "engineering"
	build_path = /obj/machinery/power/solar_control

/obj/item/circuitboard/computer/stationalert
	name = "konsola alarmów stacji (płytka komputera)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/station_alert

/obj/item/circuitboard/computer/teleporter
	name = "konsola sterowania teleporterem (płytka komputera)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/teleporter

/obj/item/circuitboard/computer/turbine_computer
	name = "komputer sterowania turbiną gazową (płytka komputera)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/turbine_computer

/obj/item/circuitboard/computer/turbine_control
	name = "sterowanie turbiną (płytka komputera)"
	icon_state = "engineering"
	build_path = /obj/machinery/computer/turbine_computer


//Generic


/obj/item/circuitboard/computer/advanced_camera
	name = "zaawansowana konsola kamer (płytka komputera)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/camera_advanced/syndie

/obj/item/circuitboard/computer/arcade/amputation
	name = "Amputacyjna przygoda Mediborga (płytka komputera)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/arcade/amputation

/obj/item/circuitboard/computer/arcade/battle
	name = "automat do gier: bitwa (płytka komputera)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/arcade/battle

/obj/item/circuitboard/computer/arcade/orion_trail
	name = "automat do gier: Orion Trail (płytka komputera)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/arcade/orion_trail

/obj/item/circuitboard/computer/holodeck// Not going to let people get this, but it's just here for future
	name = "konsola sterowania holodekiem (płytka komputera)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/holodeck

/obj/item/circuitboard/computer/libraryconsole
	name = "konsola czytelnika biblioteki (płytka komputera)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/libraryconsole

/obj/item/circuitboard/computer/libraryconsole/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(build_path == /obj/machinery/computer/libraryconsole/bookmanagement)
			name = "konsola czytelnika biblioteki (płytka komputera)"
			build_path = /obj/machinery/computer/libraryconsole
			to_chat(user, "<span class='notice'>Przywracanie domyślnych protokołów dostępu.</span>")
		else
			name = "konsola zarządzania księgozbiorem (płytka komputera)"
			build_path = /obj/machinery/computer/libraryconsole/bookmanagement
			to_chat(user, "<span class='notice'>Protokoły dostępu zaktualizowane pomyślnie.</span>")
	else
		return ..()

/obj/item/circuitboard/computer/olddoor
	name = "DoorMex (płytka komputera)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/pod/old

/obj/item/circuitboard/computer/pod
	name = "sterowanie startem wyrzutni masowej (płytka komputera)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/pod

/obj/item/circuitboard/computer/slot_machine
	name = "jednoręki bandyta (płytka komputera)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/slot_machine

/obj/item/circuitboard/computer/swfdoor
	name = "Magix (płytka komputera)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/pod/old/swf

//Not inhereting the hackability from shuttle subtypes
/obj/item/circuitboard/computer/syndicate_shuttle
	name = "terminal promu Syndykatu (płytka komputera)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/shuttle_flight/syndicate
	var/challenge = FALSE
	var/moved = FALSE

/obj/item/circuitboard/computer/syndicate_shuttle/Initialize(mapload)
	. = ..()
	GLOB.syndicate_shuttle_boards += src

/obj/item/circuitboard/computer/syndicate_shuttle/Destroy()
	GLOB.syndicate_shuttle_boards -= src
	return ..()

/obj/item/circuitboard/computer/syndicatedoor
	name = "ProComp Executive (płytka komputera)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/pod/old/syndicate

//Medical

/obj/item/circuitboard/computer/cloning
	name = "konsola klonowania (płytka komputera)"
	icon_state = "medical"
	build_path = /obj/machinery/computer/cloning
	var/list/records = list()

/obj/item/circuitboard/computer/crew
	name = "konsola monitorowania załogi (płytka komputera)"
	icon_state = "medical"
	build_path = /obj/machinery/computer/crew

/obj/item/circuitboard/computer/med_data
	name = "konsola akt medycznych (płytka komputera)"
	icon_state = "medical"
	build_path = /obj/machinery/computer/med_data

/obj/item/circuitboard/computer/operating
	name = "komputer operacyjny (płytka komputera)"
	icon_state = "medical"
	build_path = /obj/machinery/computer/operating

/obj/item/circuitboard/computer/pandemic
	name = "PanD.E.M.I.C. 2200 (płytka komputera)"
	icon_state = "medical"
	build_path = /obj/machinery/computer/pandemic

/obj/item/circuitboard/computer/cloning/prototype
	name = "prototypowa konsola klonowania (płytka komputera)"
	icon_state = "medical"
	build_path = /obj/machinery/computer/cloning/prototype

/obj/item/circuitboard/computer/scan_consolenew
	name = "konsola dostępu do skanera DNA (płytka komputera)"
	icon_state = "medical"
	build_path = /obj/machinery/computer/scan_consolenew


//Science


/obj/item/circuitboard/computer/aifixer
	name = "przywracacz integralności systemu SI (płytka komputera)"
	icon_state = "science"
	build_path = /obj/machinery/computer/aifixer

/obj/item/circuitboard/computer/launchpad_console
	name = "konsola sterowania wyrzutnią (płytka komputera)"
	icon_state = "science"
	build_path = /obj/machinery/computer/launchpad

/obj/item/circuitboard/computer/mech_bay_power_console
	name = "konsola sterowania zasilaniem warsztatu mechów (płytka komputera)"
	icon_state = "science"
	build_path = /obj/machinery/computer/mech_bay_power_console

/obj/item/circuitboard/computer/mecha_control
	name = "konsola sterowania egzoszkieletami (płytka komputera)"
	icon_state = "science"
	build_path = /obj/machinery/computer/mecha

/obj/item/circuitboard/computer/nanite_chamber_control
	name = "konsola sterowania komorą nanitów (płytka komputera)"
	icon_state = "science"
	build_path = /obj/machinery/computer/nanite_chamber_control

/obj/item/circuitboard/computer/nanite_cloud_controller
	name = "kontroler chmury nanitów (płytka komputera)"
	icon_state = "science"
	build_path = /obj/machinery/computer/nanite_cloud_controller

/obj/item/circuitboard/computer/rdconsole
	name = "konsola B+R (płytka komputera)"
	icon_state = "science"
	build_path = /obj/machinery/computer/rdconsole/core

/obj/item/circuitboard/computer/rdconsole/production
	name = "konsola B+R – tylko produkcja (płytka komputera)"
	build_path = /obj/machinery/computer/rdconsole/production

/obj/item/circuitboard/computer/rdconsole/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(build_path == /obj/machinery/computer/rdconsole/core)
			name = "konsola B+R – robotyka (płytka komputera)"
			build_path = /obj/machinery/computer/rdconsole/robotics
			to_chat(user, "<span class='notice'>Protokoły dostępu zaktualizowane pomyślnie.</span>")
		else
			name = "konsola B+R (płytka komputera)"
			build_path = /obj/machinery/computer/rdconsole/core
			to_chat(user, "<span class='notice'>Przywracanie domyślnych protokołów dostępu.</span>")
	else
		return ..()

/obj/item/circuitboard/computer/rdservercontrol
	name = "kontroler serwerów B+R (płytka komputera)"
	icon_state = "science"
	build_path = /obj/machinery/computer/rdservercontrol

/obj/item/circuitboard/computer/research
	name = "konsola kamer działu naukowego (płytka komputera)"
	icon_state = "science"
	build_path = /obj/machinery/computer/security/research

/obj/item/circuitboard/computer/robotics
	name = "konsola sterowania robotyką (płytka komputera)"
	icon_state = "science"
	build_path = /obj/machinery/computer/robotics

/obj/item/circuitboard/computer/xenobiology
	name = "konsola zarządzania szlamami (płytka komputera)"
	icon_state = "science"
	build_path = /obj/machinery/computer/camera_advanced/xenobio


//Security

/obj/item/circuitboard/computer/gulag_teleporter_console
	name = "konsola teleportu do obozu pracy (płytka komputera)"
	icon_state = "security"
	build_path = /obj/machinery/computer/prisoner/gulag_teleporter_computer

/obj/item/circuitboard/computer/prisoner/management //NSV13 modified - fix
	name = "konsola zarządzania więźniami (płytka komputera)"
	icon_state = "security"
	build_path = /obj/machinery/computer/prisoner/management

/obj/item/circuitboard/computer/secure_data
	name = "konsola akt ochrony (płytka komputera)"
	icon_state = "security"
	build_path = /obj/machinery/computer/secure_data

/obj/item/circuitboard/computer/security
	name = "konsola kamer ochrony (płytka komputera)"
	icon_state = "security"
	build_path = /obj/machinery/computer/security

/obj/item/circuitboard/computer/warrant
	name = "konsola nakazów ochrony (płytka komputera)"
	icon_state = "security"
	build_path = /obj/machinery/computer/warrant

//Service


//Supply

/obj/item/circuitboard/computer/objective
	name = "konsola celów stacji (płytka komputera)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/objective

/obj/item/circuitboard/computer/bounty
	name = "konsola zleceń Nanotrasen (płytka komputera)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/bounty

/obj/item/circuitboard/computer/cargo
	name = "konsola zaopatrzenia (płytka komputera)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/cargo
	var/contraband = FALSE

/obj/item/circuitboard/computer/cargo/multitool_act(mob/living/user)
	if(!(obj_flags & EMAGGED))
		contraband = !contraband
		to_chat(user, "<span class='notice'>Spektrum odbiornika ustawione na: [contraband ? "szerokie" : "standardowe"].</span>")
	else
		to_chat(user, "<span class='notice'>Chip spektrum nie reaguje.</span>")

/obj/item/circuitboard/computer/cargo/emag_act(mob/living/user)
	if(!(obj_flags & EMAGGED))
		contraband = TRUE
		obj_flags |= EMAGGED
		to_chat(user, "<span class='notice'>Zmieniasz trasowanie i spektrum odbiornika [src], odblokowując specjalne dostawy i kontrabandę.</span>")

/obj/item/circuitboard/computer/cargo/express
	name = "ekspresowa konsola zaopatrzenia (płytka komputera)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/cargo/express

/obj/item/circuitboard/computer/cargo/express/multitool_act(mob/living/user)
	if (!(obj_flags & EMAGGED))
		to_chat(user, "<span class='notice'>Protokoły trasowania są już ustawione na: \"ustawienia fabryczne\".</span>")
	else
		to_chat(user, "<span class='notice'>Przywracasz protokoły trasowania do: \"ustawienia fabryczne\".</span>")
		obj_flags &= ~EMAGGED

/obj/item/circuitboard/computer/cargo/express/emag_act(mob/living/user)
		to_chat(user, "<span class='notice'>Zmieniasz protokoły trasowania, pozwalając kapsule zrzutowej lądować w dowolnym miejscu stacji.</span>")
		obj_flags |= EMAGGED

/obj/item/circuitboard/computer/cargo/request
	name = "konsola zgłoszeń zaopatrzenia (płytka komputera)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/cargo/request

/obj/item/circuitboard/computer/mining
	name = "konsola kamer placówki (płytka komputera)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/security/mining

//Shuttles

/obj/item/circuitboard/computer/shuttle
	var/hacked = FALSE

/obj/item/circuitboard/computer/shuttle/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_MULTITOOL)
		hacked = !hacked
		if(hacked)
			to_chat(user, "<span class='notice'>Wyłączasz protokoły skanowania ID płytki.</span>")
		else
			to_chat(user, "<span class='notice'>Przywracasz protokoły skanowania ID płytki.</span>")
		return
	. = ..()

/obj/item/circuitboard/computer/shuttle/white_ship
	name = "konsola Białego Statku (płytka komputera)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/shuttle_flight/white_ship

/obj/item/circuitboard/computer/shuttle/white_ship/pod
	name = "konsola kapsuły ratowniczej (płytka komputera)"
	build_path = /obj/machinery/computer/shuttle_flight/white_ship/pod

/obj/item/circuitboard/computer/shuttle/white_ship/pod/recall
	name = "konsola przywołania kapsuły ratowniczej (płytka komputera)"
	build_path = /obj/machinery/computer/shuttle_flight/white_ship/pod/recall

/obj/item/circuitboard/computer/shuttle/flight_control
	name = "sterownik lotu promu (płytka komputera)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/shuttle_flight/custom_shuttle

/obj/item/circuitboard/computer/shuttle/labor_shuttle
	name = "konsola promu obozu pracy (płytka komputera)"
	icon_state = "security"
	build_path = /obj/machinery/computer/shuttle_flight/labor

/obj/item/circuitboard/computer/shuttle/labor_shuttle/one_way
	name = "konsola promu więziennego (płytka komputera)"
	build_path = /obj/machinery/computer/shuttle_flight/labor/one_way

/obj/item/circuitboard/computer/ferry
	name = "konsola promu transportowego (płytka komputera)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/shuttle_flight/ferry

/obj/item/circuitboard/computer/ferry/request
	name = "konsola promu (płytka komputera)"
	build_path = /obj/machinery/computer/shuttle_flight/ferry/request

/obj/item/circuitboard/computer/shuttle/mining_shuttle
	name = "konsola promu górniczego (płytka komputera)"
	icon_state = "supply"
	build_path = /obj/machinery/computer/shuttle_flight/mining

/obj/item/circuitboard/computer/shuttle/science_shuttle
	name = "konsola promu placówki naukowej (płytka komputera)"
	build_path = /obj/machinery/computer/shuttle_flight/science

/obj/item/circuitboard/computer/shuttle/exploration_shuttle
	name = "konsola promu badawczego (płytka komputera)"
	build_path = /obj/machinery/computer/shuttle_flight/custom_shuttle/exploration

/obj/item/circuitboard/computer/shuttle/monastery_shuttle
	name = "konsola promu klasztoru (płytka komputera)"
	icon_state = "generic"
	build_path = /obj/machinery/computer/shuttle_flight/monastery_shuttle
