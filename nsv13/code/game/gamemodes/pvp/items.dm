

/datum/outfit/syndicate/no_crystals
	implants = list()
	uplink_type = null //Nope :) Go to the req officer you ungas.

//Syndicate defense budget
/obj/item/card/id/departmental_budget/syndicate
	department_ID = ACCOUNT_SYN
	department_name = ACCOUNT_SYN_NAME
	icon_state = "warden" //placeholder

/obj/machinery/computer/cargo/express/syndicate
	name = "ekspresowa konsola zaopatrzenia Syndykatu"
	req_one_access = list(ACCESS_SYNDICATE_LEADER, ACCESS_SYNDICATE_REQUISITIONS)
	req_access = null
	req_one_access_txt = ""
	account_type = ACCOUNT_SYN
	circuit = /obj/item/circuitboard/computer/cargo/express/syndicate
	cargo_landingzone = /area/quartermaster/pvp //Without this, any crates that are sent to cargo bay LZ will land in NT cargo instead.

/obj/machinery/computer/cargo/express/syndicate/emag_act(mob/living/user)
	to_chat(user, "<span class='warning'>Syndykat pewnie kazałby cię zabić, gdybyś majstrował przy tej konsoli...</span>")
	return FALSE

/obj/item/circuitboard/computer/cargo/express/syndicate
	name = "ekspresowa konsola zaopatrzenia Syndykatu (płytka komputera)"
	icon_state = "security"
	build_path = /obj/machinery/computer/cargo/express/syndicate

/datum/outfit/syndicate/no_crystals/syndi_crew
	name = "Syndicate crewmate"
	head = /obj/item/clothing/head/HoS/beret/syndicate
	suit = /obj/item/clothing/suit/ship/syndicate_crew
	uniform = /obj/item/clothing/under/ship/pilot/syndicate
	shoes = /obj/item/clothing/shoes/jackboots
	gloves = /obj/item/clothing/gloves/color/black

/obj/item/pvp_nuke_spawner
	name = "przywoływacz bomby atomowej"
	desc = "Małe urządzenie, które przywołuje do ciebie głowicę atomową z SSV Nebuchadnezzar. Kliknij je w ręce, żeby go użyć."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-green"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	req_one_access_txt = "150"

/obj/item/pvp_nuke_spawner/attack_self(mob/user)
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Odmowa dostępu</span>")
		return
	if(!is_station_level(user.z))
		to_chat(user, "<span class='notice'>W słuchawce trzeszczy wiadomość: Operatorze. Nie dotarłeś jeszcze na [station_name()] - upewnij się, że jesteś na wrogim statku, zanim przywołasz bombę.</span>")
		return
	if(alert("Na pewno chcesz przywołać bombę atomową do siebie?",name,"Tak","Nie") == "Tak")
		to_chat(user, "<span class='notice'>Naciskasz przycisk na [src] i pojawia się bomba atomowa.</span>")
		var/obj/machinery/nuclearbomb/syndicate/nuke = locate() in GLOB.nuke_list
		nuke.visible_message("<span class='warning'>[src] znika z sykiem!</span>")
		nuke?.forceMove(get_turf(user))
		do_sparks(1, TRUE, src)
		qdel(src)

/datum/antagonist/nukeop/syndi_crew/move_to_spawnpoint()
	owner.current.forceMove(pick(GLOB.syndi_crew_spawns))

/datum/antagonist/nukeop/leader/syndi_crew/move_to_spawnpoint()
	owner.current.forceMove(pick(GLOB.syndi_crew_leader_spawns))

/obj/effect/landmark/start/nukeop/syndi_crew
	name = "Syndicate crew"

/obj/effect/landmark/start/nukeop/syndi_crew/Initialize(mapload)
	..()
	GLOB.syndi_crew_spawns += loc
	return INITIALIZE_HINT_QDEL

/obj/effect/landmark/start/nukeop/syndi_crew_leader
	name = "Syndicate captain"

/obj/effect/landmark/start/nukeop/syndi_crew_leader/Initialize(mapload)
	..()
	GLOB.syndi_crew_leader_spawns += loc
	return INITIALIZE_HINT_QDEL

/obj/machinery/conquest_beacon
	name = "nadajnik latarni"
	desc = "Zaawansowany nadajnik nawigacyjny zdolny tworzyć mosty skokowe, dzięki którym całe floty mogą skoczyć do wskazanego systemu bez korzystania z hiperlinii. Te urządzenia pobierają ogromne ilości energii, a po włączeniu trudno ich nie zauważyć."
	icon = 'nsv13/icons/obj/munitions_large.dmi'
	icon_state = "lighthouse"
	req_one_access = list(ACCESS_SYNDICATE_LEADER)
	idle_power_usage = 1000 //Slight power drain.
	obj_integrity = 1000
	max_integrity = 1000
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	density = TRUE
	anchored = TRUE
	layer = 4
	var/faction_type = FACTION_ID_SYNDICATE
	var/alignment = "syndicate"
	var/points_per_capture = 100 //How many points does capturing one system net you? Since it's 1000 points to win, this will take a bunch of captures to outright win.
	var/time_left = 150 //2.5 min
	var/active = FALSE
	var/next_activation = 0
	var/activation_delay = 7 MINUTES //How long until we can activate it again?
	var/datum/star_system/capturing //System we are currently capturing

/obj/machinery/conquest_beacon/examine(mob/user)
	. = ..()
	. += "<span class='sciradio'>Licznik pokazuje: pozostało [time_left] s.</span>"

/obj/machinery/conquest_beacon/process()
	if(!powered())
		set_active(FALSE)
		return FALSE
	if(active)
		if(capturing != get_overmap().current_system)
			set_active(FALSE)
			return FALSE
		time_left -= 2
		playsound(loc, 'sound/items/timer.ogg', 100, FALSE)
		if(time_left <= 0)
			capture_system()

/obj/machinery/conquest_beacon/proc/capture_system()
	set_active(FALSE, TRUE)
	var/datum/faction/ours = SSstar_system.faction_by_id(faction_type)
	if(!ours)
		message_admins("OSTRZEŻENIE: nadajnik latarni ma ustawioną nieprawidłową frakcję! (brak frakcji o ID: [faction_type])")
		return
	get_overmap().relay_to_nearby('nsv13/sound/effects/ship/FTL.ogg')
	//Annnd send the reinforcements!
	capturing.owner = alignment
	capturing.alignment = alignment
	ours.send_fleet(override=capturing, force=TRUE)
	ours.gain_influence(points_per_capture)

/obj/machinery/conquest_beacon/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/conquest_beacon/LateInitialize()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(add_to_ship)), 5 SECONDS)

/obj/machinery/conquest_beacon/proc/add_to_ship()
	RegisterSignal(get_overmap(), COMSIG_FTL_STATE_CHANGE, PROC_REF(deactivate))

/obj/machinery/conquest_beacon/proc/deactivate()
	set_active(FALSE)

/obj/machinery/conquest_beacon/proc/set_active(state, voluntarily=FALSE, mob/user=usr)
	if(user)
		if(!allowed(user))
			to_chat(user, "<span class='notice'>Odmowa dostępu.</span>")
			return
		if(world.time < next_activation)
			to_chat(user, "<span class='sciradio'>[src] się odnawia.</span>")
			return
		if(!powered())
			return
		if(alert(user, "Zacząć wzywać posiłki przez [src]? To głośny proces, który zdradzi twoją pozycję wrogom!","Potwierdź","Tak","Nie")=="Nie")
			return
		var/datum/star_system/SS = get_overmap().current_system
		if(SS.alignment == alignment) //Todo: add federation check here.
			to_chat(user, "<span class='sciradio'>Nie możesz przejmować systemów, które już należą do twojej frakcji...</span>")
			return
		next_activation = world.time + activation_delay
		capturing = get_overmap().current_system
		priority_announce("NIEBEZPIECZEŃSTWO: [get_overmap()] próbuje zbudować most skokowy w [get_overmap().current_system]. Trwa inwazja", "WhiteRapids EAS", 'nsv13/sound/effects/ship/lighthouse_alarm.ogg')
	if(active && !state && !voluntarily) //Great, they ran away! Good job stopping that capture crew. Now let's alert everyone.
		visible_message("[src] samoistnie się wyłącza!")
		priority_announce("Most skokowy się zapada. Inwazja powstrzymana.", "WhiteRapids EAS", 'nsv13/sound/effects/ship/lighthouse_alarm.ogg')
	active = state
	icon_state = "[initial(icon_state)][active ? "_on" : ""]"
	time_left = initial(time_left)

/obj/machinery/conquest_beacon/attack_ai(mob/user)
	. = ..()
	set_active(TRUE, TRUE, user)

/obj/machinery/conquest_beacon/attack_robot(mob/user)
	. = ..()
	set_active(TRUE, TRUE, user)

/obj/machinery/conquest_beacon/attack_hand(mob/user)
	. = ..()
	set_active(TRUE, TRUE, user)

//NT beacon
/obj/machinery/conquest_beacon/nanotrasen //Pretty much just a glorified space phone.
	name = "\proper urządzenie F.L.A.R.E."
	desc = "Prosty nadajnik, który błyskawicznie przekazuje na ogromne odległości wieść o przejęciu terytorium."
	icon_state = "lighthouse_nt"
	idle_power_usage = 10
	req_one_access = list(ACCESS_CAPTAIN)
	faction_type = FACTION_ID_NT
	alignment = "nanotrasen"
	activation_delay = 3 MINUTES
	time_left = 60 //NT can capture faster because they don't get a fleet to support

/obj/machinery/conquest_beacon/nanotrasen/capture_system()
	set_active(FALSE, TRUE)
	var/datum/faction/ours = SSstar_system.faction_by_id(faction_type)
	priority_announce("\proper [get_overmap()] przejmuje [capturing]!", "WhiteRapids EAS", )
	capturing.owner = alignment
	capturing.alignment = alignment
	ours.gain_influence(points_per_capture)

/obj/machinery/conquest_beacon/nanotrasen/set_active(state, voluntarily=FALSE, mob/user)
	if(user)
		if(!allowed(user))
			to_chat(user, "<span class='notice'>Odmowa dostępu.</span>")
			return
		if(world.time < next_activation)
			to_chat(user, "<span class='sciradio'>[src] się odnawia.</span>")
			return
		if(!powered())
			return
		if(alert(user, "Aktywować [src]? Wysłanie transmisji zajmie dwie minuty i na stałe oznaczy system jako przejęty!","Potwierdź","Tak","Nie")=="Nie")
			return
		capturing = get_overmap().current_system
		if(capturing.alignment == alignment || capturing.alignment == "solgov") //Todo: add federation check here.
			to_chat(user, "<span class='sciradio'>Nie możesz przejmować systemów, które już należą do twojej frakcji...</span>")
			return
		next_activation = world.time + activation_delay
	if(active && !state && !voluntarily)
		visible_message("[src] samoistnie się wyłącza!")
	active = state
	icon_state = "[initial(icon_state)][active ? "_on" : ""]"
	time_left = initial(time_left)

/**
* Lets the captain customize the feel and role of their ship.
*/
/datum/ship_loadout
	var/name = "Równy podział mocy między systemy główne"
	var/desc = "Przekierowuje moc do systemów głównych kosztem wszystkich modułów specjalnych. Daje to spory wzrost wszystkich ogólnych parametrów statku (wytrzymałość, zwrotność)."

/datum/ship_loadout/proc/apply(obj/structure/overmap/OM)
	if(!OM)
		return FALSE
	OM.max_integrity *= 2
	OM.obj_integrity = OM.max_integrity
	OM.forward_maxthrust *= 1.25
	OM.backward_maxthrust *= 1.25
	OM.side_maxthrust *= 1.25
	OM.max_angular_acceleration *= 1.25
	return TRUE

/datum/ship_loadout/stealth
	name = "Napęd maskujący"
	desc = "Skany wykryły na pokładzie nieaktywne urządzenie zakłócające sensory. Włącz je, żeby ukryć sygnaturę statku przed DRADIS-em (z wyjątkiem bliskiego zasięgu), a nadwyżkę nieprzydzielonej mocy przeznaczyć na większą zwrotność w walce i nieco większą wytrzymałość. Ten moduł zmienia statek w wyjątkowo skuteczną platformę do pierwszego uderzenia i pozwala wymknąć się z walki po odniesieniu uszkodzeń. OSTRZEŻENIE: strzelanie podczas maskowania chwilowo zakłóca maskowanie."

/datum/ship_loadout/stealth/apply(obj/structure/overmap/OM)
	if(!OM)
		return FALSE
	OM.max_integrity *= 1.25
	OM.obj_integrity = OM.max_integrity
	OM.cloak_factor = 100
	OM.forward_maxthrust *= 1.15
	OM.backward_maxthrust *= 1.15
	OM.side_maxthrust *= 1.15
	OM.max_angular_acceleration *= 1.15
	OM.handle_cloak(TRUE)
	return TRUE

/datum/ship_loadout/interceptor
	name = "Eksperymentalne modyfikacje silników"
	desc = "Skany wykryły w sieci zasilania eksperymentalny kolektor zwiększający prędkość oraz prototypową modyfikację napędu Thirringa. Włącz je, żeby znacznie zwiększyć zwrotność i prędkość przelotową statku, a komputer FTL będzie sam rozgrzewać napęd między skokami. Ten moduł pozwala dużo szybciej docierać do celów i wyraźnie zwiększa zwrotność i prędkość, ale nie zostaje żadna nadwyżka mocy na wzmocnienie konstrukcji."

/datum/ship_loadout/interceptor/apply(obj/structure/overmap/OM)
	if(!OM)
		return FALSE
	OM.forward_maxthrust *= 1.5
	OM.backward_maxthrust *= 1.5
	OM.side_maxthrust *= 1.5
	OM.speed_limit *= 1.5
	OM.max_angular_acceleration *= 1.5
	OM.ftl_drive.auto_spool_enabled = TRUE //Lazy sods, but yes this is a very valid option if you want to annoy NT.
	return TRUE

/obj/item/ship_loadout_selector
	name = "selektor konfiguracji statku"
	desc = "Urządzenie, które może przekierować moc do wybranych systemów statku, a nawet uruchomić te, które dotąd były nieaktywne! Kliknij je w ręce, żeby wybrać konfigurację statku."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-red"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	req_one_access_txt = "150"
	var/list/loadouts = list()

/obj/item/ship_loadout_selector/Initialize(mapload)
	. = ..()
	for(var/theType in typecacheof(/datum/ship_loadout))
		loadouts += new theType

/obj/item/ship_loadout_selector/attack_self(mob/user)
	if(!allowed(user))
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Odmowa dostępu</span>")
		return
	ui_interact(user)

/obj/item/ship_loadout_selector/ui_state(mob/user)
	return GLOB.always_state

/obj/item/ship_loadout_selector/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ShipLoadout", "Konfiguracja statku")
		ui.open()

/obj/item/ship_loadout_selector/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	var/list/categories = list()
	for(var/datum/ship_loadout/SL in loadouts)
		var/list/info = list()
		info["name"] = SL.name
		info["desc"] = SL.desc
		info["id"] = "\ref[SL]"
		categories[++categories.len] = info
	data["categories"] = categories
	return data

/obj/item/ship_loadout_selector/ui_act(action, params)
	. = ..()
	if(!loc.get_overmap()) //Piss off then.
		return FALSE
	var/datum/ship_loadout/target = locate(params["target_id"])
	if(!target)
		return FALSE
	if(alert("Na pewno chcesz wybrać [target]?",name,"Tak","Nie") == "Tak")
		if(target.apply(loc.get_overmap()))
			qdel(src)

/obj/effect/landmark/trader_drop_point
	name = "Trader sending target"

/obj/effect/landmark/trader_drop_point/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/landmark/trader_drop_point/LateInitialize()
	..()
	// addtimer(CALLBACK(src, PROC_REF(add_to_ship)), 1 MINUTES)
	add_to_ship() // I don't understand why we're delaying this

/obj/effect/landmark/trader_drop_point/proc/add_to_ship()
	LAZYADD(get_overmap()?.trader_beacons, src)

/area/bridge/pvp
	name = "Mostek Syndykatu"

/area/bridge/pvp/secondary
	name = "Mostek Bojowy Syndykatu"

/area/bridge/meeting_room/pvp
	name = "Sala Konferencyjna Syndykatu"

/area/hallway/pvp
	name = "Główny Korytarz Syndykatu"

/area/crew_quarters/bar/pvp
	name = "Bar Syndykatu"

/area/crew_quarters/cafeteria/pvp
	name = "Kafeteria Syndykatu"

/area/hydroponics/pvp
	name = "Hydroponika Syndykatu"

/area/ai_monitored/nuke_storage/pvp
	name = "Skarbiec Syndykatu"

/area/medical/medbay/pvp
	name = "Placówka Medyczna Syndykatu"

/area/nsv/weapons/pvp
	name = "Amunicja Syndykatu"

/area/nsv/hanger/pvp
	name = "Hangar Syndykatu"

/area/nsv/hanger/pvp/marine
	name = "Hangar Piechoty Morskiej Syndykatu"

/area/security/brig/pvp
	name = "Areszt Syndykatu"

/area/engine/engineering/pvp
	name = "Inżynieria Syndykatu"

/area/engine/engine_room/pvp
	name = "Rdzeń Reaktora Syndykatu"

/area/quartermaster/pvp
	name = "Ładownia Zaopatrzenia Syndykatu"

/area/science/pvp
	name = "Skrzydło Naukowe Syndykatu"

/area/science/robotics/pvp
	name = "Robotyka Syndykatu"

/area/crew_quarters/pvp
	name = "Kwatery Syndykatu"

/area/crew_quarters/toilet/pvp
	name = "Toalety Syndykatu"
/area/crew_quarters/heads/hor/pvp
	name = "Biuro Badawcze Syndykatu"

/area/crew_quarters/heads/hos/pvp
	name = "Gabinet Komendanta Syndykatu"

/area/crew_quarters/heads/chief/pvp
	name = "Biuro Głównego Inżyniera Syndykatu"

/area/crew_quarters/heads/captain/pvp
	name = "Biuro Kapitana Syndykatu"

/area/crew_quarters/heads/captain/pvp/admiral
	name = "Biuro Admirała Syndykatu"

/area/maintenance/pvp
	name = "Tunel Konserwacyjny Syndykatu"

/obj/machinery/camera/syndicate
	name = "kamera taktyczna Syndykatu"
	network = list("syndicate")

/obj/machinery/camera/syndicate/autoname
	var/number = 0
/obj/machinery/camera/syndicate/autoname/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/camera/syndicate/autoname/LateInitialize()
	. = ..()
	number = 1
	var/area/A = get_area(src)
	if(A)
		for(var/obj/machinery/camera/syndicate/autoname/C in GLOB.machines)
			if(C == src)
				continue
			var/area/CA = get_area(C)
			if(CA.type == A.type)
				if(C.number)
					number = max(number, C.number+1)
		c_tag = "[A.name] #[number]"

/obj/item/radio/intercom/syndicate //An intercom for syndicate AIs.
	name = "interkom Syndykatu"
	syndie = 1
	freqlock = 1

/obj/item/radio/intercom/syndicate/Initialize(mapload)
	. = ..()
	set_frequency(FREQ_SYNDICATE)

