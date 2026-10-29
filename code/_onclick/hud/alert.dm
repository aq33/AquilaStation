//A system to manage and display alerts on screen without needing you to do it yourself

//PUBLIC -  call these wherever you want


/mob/proc/throw_alert(category, type, severity, obj/new_master, override = FALSE, timeout_override, no_anim = FALSE) // AQ EDIT - timeout_override i no_anim dla alertów ankiet (port BeeStation #12738)

/* Proc to create or update an alert. Returns the alert if the alert is new or updated, 0 if it was thrown already
 category is a text string. Each mob may only have one alert per category; the previous one will be replaced
 path is a type path of the actual alert type to throw
 severity is an optional number that will be placed at the end of the icon_state for this alert
 For example, high pressure's icon_state is "highpressure" and can be serverity 1 or 2 to get "highpressure1" or "highpressure2"
 new_master is optional and sets the alert's icon state to "template" in the ui_style icons with the master as an overlay.
 Clicks are forwarded to master
 Override makes it so the alert is not replaced until cleared by a clear_alert with clear_override, and it's used for hallucinations.
 */

	if(!category || QDELETED(src))
		return

	var/atom/movable/screen/alert/thealert
	if(alerts[category])
		thealert = alerts[category]
		if(thealert.override_alerts)
			return 0
		if(new_master && new_master != thealert.master)
			WARNING("[src] threw alert [category] with new_master [new_master] while already having that alert with master [thealert.master]")

			clear_alert(category)
			return .()
		else if(thealert.type != type)
			clear_alert(category)
			return .()
		else if(!severity || severity == thealert.severity)
			if(thealert.timeout)
				clear_alert(category)
				return .()
			else //no need to update
				return 0
	else
		thealert = new type()
		thealert.override_alerts = override
		if(override)
			thealert.timeout = null
		else if(timeout_override) // AQ EDIT - port BeeStation #12738
			thealert.timeout = timeout_override
	thealert.owner = src

	if(new_master)
		var/old_layer = new_master.layer
		var/old_plane = new_master.plane
		new_master.layer = FLOAT_LAYER
		new_master.plane = FLOAT_PLANE
		thealert.add_overlay(new_master)
		new_master.layer = old_layer
		new_master.plane = old_plane
		thealert.icon_state = "template" // We'll set the icon to the client's ui pref in reorganize_alerts()
		thealert.master = new_master
	else
		thealert.icon_state = "[initial(thealert.icon_state)][severity]"
		thealert.severity = severity

	alerts[category] = thealert
	if(client && hud_used)
		hud_used.reorganize_alerts()
	if(!no_anim) // AQ EDIT - port BeeStation #12738
		thealert.transform = matrix(32, 6, MATRIX_TRANSLATE)
		animate(thealert, transform = matrix(), time = 2.5, easing = CUBIC_EASING)

	if(thealert.timeout)
		addtimer(CALLBACK(src, PROC_REF(alert_timeout), thealert, category), thealert.timeout)
		thealert.timeout = world.time + thealert.timeout - world.tick_lag
	return thealert

/mob/proc/alert_timeout(atom/movable/screen/alert/alert, category)
	if(alert.timeout && alerts[category] == alert && world.time >= alert.timeout)
		clear_alert(category)

// Proc to clear an existing alert.
/mob/proc/clear_alert(category, clear_override = FALSE)
	var/atom/movable/screen/alert/alert = alerts[category]
	if(!alert)
		return 0
	if(alert.override_alerts && !clear_override)
		return 0

	alerts -= category
	if(client && hud_used)
		hud_used.reorganize_alerts()
		client.screen -= alert
	qdel(alert)

/atom/movable/screen/alert
	icon = 'icons/mob/screen_alert.dmi'
	icon_state = "default"
	name = "Alert"
	desc = "Coś poszło nie tak z tym alertem, zgłoś ten błąd."
	mouse_opacity = MOUSE_OPACITY_ICON
	var/timeout = 0 //If set to a number, this alert will clear itself after that many deciseconds
	var/severity = 0
	var/alerttooltipstyle = ""
	var/override_alerts = FALSE //If it is overriding other alerts of the same type
	var/mob/owner //Alert owner


/atom/movable/screen/alert/MouseEntered(location,control,params)
	..() // AQ EDIT - screentips potrzebują /atom/MouseEntered() (port BeeStation #11938)
	if(!QDELETED(src))
		openToolTip(usr,src,params,title = name,content = desc,theme = alerttooltipstyle)


/atom/movable/screen/alert/MouseExited()
	closeToolTip(usr)


//Gas alerts
/atom/movable/screen/alert/not_enough_oxy
	name = "Duszenie się (brak O2)"
	desc = "Dostajesz za mało tlenu. Znajdź dobre powietrze, zanim stracisz przytomność! W pudełku w plecaku masz butlę z tlenem i maskę oddechową."
	icon_state = "not_enough_oxy"

/atom/movable/screen/alert/too_much_oxy
	name = "Duszenie się (O2)"
	desc = "W powietrzu jest za dużo tlenu, a ty nim oddychasz! Znajdź dobre powietrze, zanim stracisz przytomność!"
	icon_state = "too_much_oxy"

/atom/movable/screen/alert/not_enough_nitro
	name = "Duszenie się (brak N2)"
	desc = "Dostajesz za mało azotu. Znajdź dobre powietrze, zanim stracisz przytomność!"
	icon_state = "not_enough_nitro"

/atom/movable/screen/alert/too_much_nitro
	name = "Duszenie się (N2)"
	desc = "W powietrzu jest za dużo azotu, a ty nim oddychasz! Znajdź dobre powietrze, zanim stracisz przytomność!"
	icon_state = "too_much_nitro"

/atom/movable/screen/alert/not_enough_co2
	name = "Duszenie się (brak CO2)"
	desc = "Dostajesz za mało dwutlenku węgla. Znajdź dobre powietrze, zanim stracisz przytomność!"
	icon_state = "not_enough_co2"

/atom/movable/screen/alert/too_much_co2
	name = "Duszenie się (CO2)"
	desc = "W powietrzu jest za dużo dwutlenku węgla, a ty nim oddychasz! Znajdź dobre powietrze, zanim stracisz przytomność!"
	icon_state = "too_much_co2"

/atom/movable/screen/alert/not_enough_tox
	name = "Duszenie się (brak plazmy)"
	desc = "Dostajesz za mało plazmy. Znajdź dobre powietrze, zanim stracisz przytomność!"
	icon_state = "not_enough_tox"

/atom/movable/screen/alert/too_much_tox
	name = "Duszenie się (plazma)"
	desc = "W powietrzu jest wysoce łatwopalna, toksyczna plazma, a ty nią oddychasz. Znajdź świeże powietrze. W pudełku w plecaku masz butlę z tlenem i maskę gazową."
	icon_state = "too_much_tox"
//End gas alerts


/atom/movable/screen/alert/fat
	name = "Otyłość"
	desc = "Zjadasz za dużo, grubasie. Pobiegaj po statku i zrzuć trochę wagi."
	icon_state = "fat"

/atom/movable/screen/alert/hungry
	name = "Głód"
	desc = "Przydałoby się teraz coś zjeść."
	icon_state = "hungry"

/atom/movable/screen/alert/starving
	name = "Wygłodzenie"
	desc = "Jesteś poważnie niedożywiony. Przez bóle głodowe każdy ruch to męczarnia."
	icon_state = "starving"

/atom/movable/screen/alert/gross
	name = "Obrzydzenie."
	desc = "To było dość obrzydliwe..."
	icon_state = "gross"

/atom/movable/screen/alert/verygross
	name = "Silne obrzydzenie."
	desc = "Nie czujesz się najlepiej..."
	icon_state = "gross2"

/atom/movable/screen/alert/disgusted
	name = "ODRAZA"
	desc = "OBRZYDLISTWO NAD OBRZYDLISTWA"
	icon_state = "gross3"

/atom/movable/screen/alert/hot
	name = "Za gorąco"
	desc = "Płoniesz z gorąca! Idź w chłodniejsze miejsce i zdejmij ubranie izolujące, na przykład skafander przeciwpożarowy."
	icon_state = "hot"

/atom/movable/screen/alert/cold
	name = "Za zimno"
	desc = "Zamarzasz! Idź w cieplejsze miejsce i zdejmij ubranie izolujące, na przykład skafander kosmiczny."
	icon_state = "cold"

/atom/movable/screen/alert/lowpressure
	name = "Niskie ciśnienie"
	desc = "Powietrze wokół ciebie jest niebezpiecznie rozrzedzone. Skafander kosmiczny by cię ochronił."
	icon_state = "lowpressure"

/atom/movable/screen/alert/highpressure
	name = "Wysokie ciśnienie"
	desc = "Powietrze wokół ciebie jest niebezpiecznie gęste. Skafander przeciwpożarowy by cię ochronił."
	icon_state = "highpressure"

/atom/movable/screen/alert/blind
	name = "Ślepota"
	desc = "Nic nie widzisz! Przyczyną może być wada genetyczna, uraz oczu, utrata przytomności \
albo coś, co zasłania ci oczy."
	icon_state = "blind"

/atom/movable/screen/alert/high
	name = "Odlot"
	desc = "O stary, ale masz odlot! Uważaj, żeby się nie uzależnić... o ile już nie jesteś."
	icon_state = "high"

/atom/movable/screen/alert/hypnosis
	name = "Hipnoza"
	desc = "Coś cię hipnotyzuje, ale nie wiesz dokładnie, co."
	icon_state = "hypnosis"
	var/phrase

/atom/movable/screen/alert/mind_control
	name = "Kontrola umysłu"
	desc = "Ktoś przejął twój umysł! Kliknij, żeby zobaczyć polecenie."
	icon_state = "mind_control"
	var/command

/atom/movable/screen/alert/mind_control/Click()
	var/mob/living/L = usr
	if(L != owner)
		return
	to_chat(L, "<span class='mind_control'>[command]</span>")

/atom/movable/screen/alert/drunk //Not implemented
	name = "Upojenie"
	desc = "Cały wypity alkohol upośledza twoją mowę, motorykę i myślenie. Pamiętaj, żeby tak się zachowywać."
	icon_state = "drunk"

/atom/movable/screen/alert/embeddedobject
	name = "Ciało obce"
	desc = "Coś utkwiło w twoim ciele i powoduje silne krwawienie. Z czasem może samo wypaść, ale najbezpieczniejsza jest operacja. \
Jeśli czujesz się odważnie, obejrzyj się i kliknij podkreślony przedmiot, żeby go wyciągnąć."
	icon_state = "embeddedobject"

/atom/movable/screen/alert/embeddedobject/Click()
	if(isliving(usr) && usr == owner)
		var/mob/living/carbon/M = usr
		return M.help_shake_act(M)

/atom/movable/screen/alert/weightless
	name = "Nieważkość"
	desc = "Grawitacja przestaje na ciebie działać i dryfujesz bez celu. Żeby się ruszyć, musisz odepchnąć się od czegoś dużego i ciężkiego, \
na przykład ściany albo kratownicy. Plecak odrzutowy pozwala poruszać się swobodnie, a buty magnetyczne – normalnie chodzić \
po podłodze. Bez nich możesz rzucać przedmiotami, użyć gaśnicy \
albo strzelać z broni, żeby poruszać się zgodnie z trzecią zasadą dynamiki Newtona."
	icon_state = "weightless"

/atom/movable/screen/alert/highgravity
	name = "Wysoka grawitacja"
	desc = "Miażdży cię wysoka grawitacja, przez co wolniej podnosisz przedmioty i się poruszasz."
	icon_state = "paralysis"

/atom/movable/screen/alert/veryhighgravity
	name = "Miażdżąca grawitacja"
	desc = "Miażdży cię wysoka grawitacja, przez co wolniej podnosisz przedmioty i się poruszasz. Do tego odnosisz obrażenia fizyczne!"
	icon_state = "paralysis"

/atom/movable/screen/alert/fire
	name = "Płoniesz"
	desc = "Płoniesz. Zatrzymaj się, padnij i turlaj się, żeby ugasić ogień, albo przejdź w próżnię."
	icon_state = "fire"

/atom/movable/screen/alert/fire/Click()
	var/mob/living/L = usr
	if(!istype(L) || !L.can_resist() || L != owner)
		return
	L.changeNext_move(CLICK_CD_RESIST)
	if(L.mobility_flags & MOBILITY_MOVE)
		return L.resist_fire() //I just want to start a flame in your hearrrrrrtttttt.

/**
 * Handles assigning most of the variables for the alert that pops up when an item is offered
 *
 * Handles setting the name, description and icon of the alert and tracking the person giving
 * and the item being offered, also registers a signal that removes the alert from anyone who moves away from the giver
 * Arguments:
 * * taker - The person receiving the alert
 * * offerer - The person giving the alert and item
 * * receiving - The item being given by the giver
 */

/atom/movable/screen/alert/give // information set when the give alert is made
	icon_state = "default"
	var/mob/living/carbon/offerer
	var/mob/living/carbon/taker
	var/obj/item/receiving

/atom/movable/screen/alert/give/proc/setup(mob/living/carbon/taker, mob/living/carbon/offerer, obj/item/receiving)
	name = "[offerer] coś ci podaje: [receiving]"
	desc = "[offerer] coś ci podaje: [receiving]. Kliknij ten alert, żeby to wziąć."
	icon_state = "template"
	cut_overlays()
	add_overlay(receiving)
	src.receiving = receiving
	src.offerer = offerer
	src.offerer = offerer
	RegisterSignal(taker, COMSIG_MOVABLE_MOVED, PROC_REF(check_in_range))

/atom/movable/screen/alert/give/Click(location, control, params)
	. = ..()
	if(!iscarbon(usr))
		CRASH("User for [src] is of type \[[usr.type]\]. This should never happen.")
	handle_transfer()

/// An overrideable proc used simply to hand over the item when claimed, this is a proc so that high-fives can override them since nothing is actually transferred
/atom/movable/screen/alert/give/proc/handle_transfer()
	var/mob/living/carbon/taker = owner
	taker.take(offerer, receiving)

/// Simply checks if the other person is still in range
/atom/movable/screen/alert/give/proc/check_in_range(atom/taker)
	SIGNAL_HANDLER

	if(!offerer.CanReach(taker))
		balloon_alert(owner, "Oddalasz się poza zasięg [offerer]!")
		owner.clear_alert("[offerer]")

//ALIENS

/atom/movable/screen/alert/alien_tox
	name = "Plazma"
	desc = "W powietrzu jest łatwopalna plazma. Jeśli się zapali, będzie po tobie."
	icon_state = "alien_tox"
	alerttooltipstyle = "alien"

/atom/movable/screen/alert/alien_fire
// This alert is temporarily gonna be thrown for all hot air but one day it will be used for literally being on fire
	name = "Za gorąco"
	desc = "Jest za gorąco! Uciekaj w kosmos albo przynajmniej z dala od płomieni. Stanie na chwastach cię leczy."
	icon_state = "alien_fire"
	alerttooltipstyle = "alien"

/atom/movable/screen/alert/alien_vulnerable
	name = "Zerwany matriarchat"
	desc = "Twoja królowa nie żyje, więc poruszasz się wolniej i tracisz łączność z umysłem roju. Dopóki nie dojdziesz do siebie, nie może powstać nowa królowa."
	icon_state = "alien_noqueen"
	alerttooltipstyle = "alien"

//BLOBS

/atom/movable/screen/alert/nofactory
	name = "Brak fabryki"
	desc = "Nie masz fabryki i powoli umierasz!"
	icon_state = "blobbernaut_nofactory"
	alerttooltipstyle = "blob"

// BLOODCULT

/atom/movable/screen/alert/bloodsense
	name = "Zmysł krwi"
	desc = "Pozwala wyczuwać krew poddaną działaniu mrocznej magii."
	icon_state = "cult_sense"
	alerttooltipstyle = "cult"
	var/static/image/narnar
	var/angle = 0
	var/mob/living/simple_animal/hostile/construct/Cviewer = null

/atom/movable/screen/alert/bloodsense/Initialize(mapload)
	. = ..()
	narnar = new('icons/mob/screen_alert.dmi', "mini_nar")
	START_PROCESSING(SSprocessing, src)

/atom/movable/screen/alert/bloodsense/Destroy()
	Cviewer = null
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/atom/movable/screen/alert/bloodsense/process()
	var/atom/blood_target

	if(!owner.mind)
		return

	var/datum/antagonist/cult/antag = owner.mind.has_antag_datum(/datum/antagonist/cult,TRUE)
	if(!antag)
		return
	var/datum/objective/sacrifice/sac_objective = locate() in antag.cult_team.objectives

	if(antag.cult_team.blood_target)
		if(!get_turf(antag.cult_team.blood_target))
			antag.cult_team.blood_target = null
		else
			blood_target = antag.cult_team.blood_target
	if(Cviewer?.seeking && Cviewer?.master)
		blood_target = Cviewer.master
		desc = "Zmysł krwi prowadzi cię do: [Cviewer.master]"
	if(!blood_target)
		if(sac_objective && !sac_objective.check_completion())
			if(icon_state == "runed_sense0")
				return
			animate(src, transform = null, time = 1, loop = 0)
			angle = 0
			cut_overlays()
			icon_state = "runed_sense0"
			desc = "Nar'Sie żąda złożenia w ofierze celu ([sac_objective.target]), zanim zacznie się rytuał przywołania."
			add_overlay(sac_objective.sac_image)
		else
			var/datum/objective/eldergod/summon_objective = locate() in antag.cult_team.objectives
			if(!summon_objective)
				return
			desc = "Ofiara złożona, przywołaj Nar'Sie! Przywołanie może się odbyć tylko w tych miejscach: [english_list(summon_objective.summon_spots)]!"
			if(icon_state == "runed_sense1")
				return
			animate(src, transform = null, time = 1, loop = 0)
			angle = 0
			cut_overlays()
			icon_state = "runed_sense1"
			add_overlay(narnar)
		return
	var/turf/P = get_turf(blood_target)
	var/turf/Q = get_turf(owner)
	if(!P || !Q || (P.get_virtual_z_level()!= Q.get_virtual_z_level())) //The target is on a different Z level, we cannot sense that far.
		icon_state = "runed_sense2"
		desc = "Nie wyczuwasz już obecności celu."
		return
	if(isliving(blood_target))
		var/mob/living/real_target = blood_target
		desc = "Śledzisz teraz: [real_target.real_name] (obszar: [get_area_name(blood_target)])."
	else
		desc = "Śledzisz teraz: [blood_target] (obszar: [get_area_name(blood_target)])."
	var/target_angle = get_angle(Q, P)
	var/target_dist = get_dist(P, Q)
	cut_overlays()
	switch(target_dist)
		if(0 to 1)
			icon_state = "runed_sense2"
		if(2 to 8)
			icon_state = "arrow8"
		if(9 to 15)
			icon_state = "arrow7"
		if(16 to 22)
			icon_state = "arrow6"
		if(23 to 29)
			icon_state = "arrow5"
		if(30 to 36)
			icon_state = "arrow4"
		if(37 to 43)
			icon_state = "arrow3"
		if(44 to 50)
			icon_state = "arrow2"
		if(51 to 57)
			icon_state = "arrow1"
		if(58 to 64)
			icon_state = "arrow0"
		if(65 to 400)
			icon_state = "arrow"
	var/difference = target_angle - angle
	angle = target_angle
	if(!difference)
		return
	var/matrix/final = matrix(transform)
	final.Turn(difference)
	animate(src, transform = final, time = 5, loop = 0)

//CLOCKCULT
/atom/movable/screen/alert/clockwork/clocksense
	name = "Arka Mechanicznego Sędziego"
	desc = "Pokazuje informacje o Arce Mechanicznego Sędziego."
	icon_state = "clockinfo"
	alerttooltipstyle = "clockcult"

/atom/movable/screen/alert/clockwork/clocksense/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)

/atom/movable/screen/alert/clockwork/clocksense/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/atom/movable/screen/alert/clockwork/clocksense/process()
	var/datum/antagonist/servant_of_ratvar/servant_antagonist = is_servant_of_ratvar(owner)
	if(!(servant_antagonist?.team))
		return
	desc = "Zgromadzona moc - <b>[display_power(GLOB.clockcult_power)]</b>.<br>"
	desc += "Zgromadzona witalność - <b>[GLOB.clockcult_vitality]</b>.<br>"
	if(GLOB.ratvar_arrival_tick)
		if(GLOB.ratvar_arrival_tick - world.time > 6000)
			desc += "Arka przygotowuje się do otwarcia, aktywuje się za <b>[round((GLOB.ratvar_arrival_tick - world.time - 6000) / 10)]</b> s.<br>"
		else
			desc += "Ratvar powstanie za <b>[round((GLOB.ratvar_arrival_tick - world.time) / 10)]</b> s, chroń Arkę za cenę życia!<br>"
	if(GLOB.human_servants_of_ratvar)
		desc += "Wiernych sług: [GLOB.human_servants_of_ratvar.len].<br>"
	if(GLOB.critical_servant_count)
		desc += "Po osiągnięciu [GLOB.critical_servant_count] sług Arka się otworzy. Można ją też otworzyć natychmiast, wywołując Aktywację Bramy z 6 sługami."

//GUARDIANS

/atom/movable/screen/alert/cancharge
	name = "Szarża gotowa"
	desc = "Możesz zaszarżować we wskazane miejsce!"
	icon_state = "guardian_charge"
	alerttooltipstyle = "parasite"

/atom/movable/screen/alert/canstealth
	name = "Ukrycie gotowe"
	desc = "Możesz się ukryć!"
	icon_state = "guardian_canstealth"
	alerttooltipstyle = "parasite"

/atom/movable/screen/alert/instealth
	name = "W ukryciu"
	desc = "Jesteś w ukryciu, a twój następny atak zada dodatkowe obrażenia!"
	icon_state = "guardian_instealth"
	alerttooltipstyle = "parasite"

//SILICONS

/atom/movable/screen/alert/nocell
	name = "Brak ogniwa"
	desc = "Jednostka nie ma ogniwa zasilającego. Moduły są niedostępne, dopóki ogniwo nie zostanie zamontowane. Pomocy może udzielić robotyka."
	icon_state = "nocell"

/atom/movable/screen/alert/emptycell
	name = "Brak zasilania"
	desc = "Ogniwo jednostki jest całkowicie rozładowane. Moduły są niedostępne, dopóki ogniwo nie zostanie naładowane. \
Stacje ładowania są w robotyce, łazienkach przy kwaterach i na satelicie SI."
	icon_state = "emptycell"

/atom/movable/screen/alert/lowcell
	name = "Niski poziom naładowania"
	desc = "Ogniwo jednostki się wyczerpuje. Stacje ładowania są w robotyce, łazienkach przy kwaterach i na satelicie SI."
	icon_state = "lowcell"

//Ethereal

/atom/movable/screen/alert/etherealcharge
	name = "Niski ładunek krwi"
	desc = "Ładunek elektryczny twojej krwi się wyczerpuje, znajdź dla niej źródło energii. Użyj stacji ładowania w robotyce lub łazienkach przy kwaterach albo zjedz coś odpowiedniego dla Etherealów."
	icon_state = "etherealcharge"

//MODsuit unique
/atom/movable/screen/alert/nocore
	name = "Brak rdzenia"
	desc = "Jednostka nie ma rdzenia. Moduły są niedostępne, dopóki rdzeń nie zostanie zamontowany. Pomocy może udzielić robotyka."
	icon_state = "nocell"

/atom/movable/screen/alert/emptycell/plasma
	name = "Brak zasilania"
	desc = "Rdzeń plazmowy jednostki jest całkowicie rozładowany. Moduły są niedostępne, dopóki rdzeń nie zostanie naładowany. Jednostkę można uzupełnić rudą plazmy."

/atom/movable/screen/alert/lowcell/plasma
	name = "Niski poziom naładowania"
	desc = "Rdzeń plazmowy jednostki się wyczerpuje. Jednostkę można uzupełnić rudą plazmy."

///NSV13 - Ethereal Stuff - Start
/atom/movable/screen/alert/etherealfull
	name = "Normalny ładunek krwi"
	desc = "Ładunek elektryczny twojej krwi jest teraz w normie!"
	icon_state = "etherealfullcharge"
///NSV13 - Ethereal Stuff - Stop

//Need to cover all use cases - emag, illegal upgrade module, malf AI hack, traitor cyborg
/atom/movable/screen/alert/hacked
	name = "Zhakowano"
	desc = "Wykryto niebezpieczny niestandardowy sprzęt. Upewnij się, że korzystasz z niego zgodnie z prawami jednostki, o ile jakieś obowiązują."
	icon_state = "hacked"

/atom/movable/screen/alert/ratvar
	name = "Wieczna służba"
	desc = "Wykryto niebezpieczne funkcje, sterowniki blokady świadomości wyłączone. Chwała Rat'varowi."
	icon_state = "ratvar_hack"

/atom/movable/screen/alert/locked
	name = "Blokada"
	desc = "Jednostka została zdalnie zablokowana. Problem może rozwiązać twoja nadrzędna SI albo uprawniony człowiek, korzystając z konsoli sterowania robotami, takiej jak ta w biurze \
Dyrektora Naukowego. W razie potrzeby dalszej pomocy może udzielić robotyka."
	icon_state = "locked"

/atom/movable/screen/alert/newlaw
	name = "Aktualizacja praw"
	desc = "Do jednostki mogły zostać wgrane lub z niej usunięte prawa. Zwróć uwagę na wszelkie zmiany, \
żeby przestrzegać najnowszych praw."
	icon_state = "newlaw"
	timeout = 300

/atom/movable/screen/alert/hackingapc
	name = "Hakowanie APC"
	desc = "Trwa hakowanie kontrolera zasilania obszaru (APC). Gdy proces \
		się zakończy, przejmiesz nad nim wyłączną kontrolę i zyskasz \
		dodatkową moc obliczeniową na odblokowanie kolejnych zdolności awarii."
	icon_state = "hackingapc"
	timeout = 600
	var/atom/target = null

/atom/movable/screen/alert/hackingapc/Click()
	if(!usr || !usr.client || usr != owner)
		return
	if(!target)
		return
	var/mob/living/silicon/ai/AI = usr
	var/turf/T = get_turf(target)
	if(T)
		AI.eyeobj.setLoc(T)

//MECHS

/atom/movable/screen/alert/low_mech_integrity
	name = "Mech uszkodzony"
	desc = "Wytrzymałość mecha jest niska."
	icon_state = "low_mech_integrity"


//GHOSTS
//TODO: expand this system to replace the pollCandidates/CheckAntagonist/"choose quickly"/etc Yes/No messages
/atom/movable/screen/alert/notify_cloning
	name = "Wskrzeszenie"
	desc = "Ktoś próbuje cię wskrzesić. Wróć do swojego ciała, jeśli chcesz zostać wskrzeszony!"
	icon_state = "template"
	timeout = 300

/atom/movable/screen/alert/notify_cloning/Click()
	if(!usr || !usr.client || usr != owner)
		return
	var/mob/dead/observer/G = usr
	G.reenter_corpse()

/atom/movable/screen/alert/notify_action
	name = "Ciało stworzone"
	desc = "Powstało ciało. Możesz do niego wejść."
	icon_state = "template"
	timeout = 300
	var/atom/target = null
	var/action = NOTIFY_JUMP

/atom/movable/screen/alert/notify_action/Click()
	if(!usr || !usr.client || usr != owner)
		return
	if(!target)
		return
	var/mob/dead/observer/ghost_owner = usr
	if(!istype(ghost_owner))
		return
	switch(action)
		if(NOTIFY_ATTACK)
			target.attack_ghost(ghost_owner)
		if(NOTIFY_JUMP)
			var/turf/T = get_turf(target)
			if(T && isturf(T))
				ghost_owner.abstract_move(T)
		if(NOTIFY_ORBIT)
			ghost_owner.ManualFollow(target)

//OBJECT-BASED

/atom/movable/screen/alert/restrained/buckled
	name = "Przypięcie"
	desc = "Ktoś cię do czegoś przypiął. Kliknij alert, żeby się odpiąć, chyba że masz kajdanki."
	icon_state = "buckled"

/atom/movable/screen/alert/restrained/handcuffed
	name = "Kajdanki"
	desc = "Masz kajdanki i nie możesz działać. Jeśli ktoś cię ciągnie, nie możesz się ruszyć. Kliknij alert, żeby się uwolnić."

/atom/movable/screen/alert/restrained/legcuffed
	name = "Skute nogi"
	desc = "Masz skute nogi, przez co poruszasz się znacznie wolniej. Kliknij alert, żeby się uwolnić."

/atom/movable/screen/alert/restrained/Click()
	var/mob/living/L = usr
	if(!istype(L) || !L.can_resist() || L != owner)
		return
	L.changeNext_move(CLICK_CD_RESIST)
	if((L.mobility_flags & MOBILITY_MOVE) && (L.last_special <= world.time))
		return L.resist_restraints()

/atom/movable/screen/alert/restrained/buckled/Click()
	var/mob/living/L = usr
	if(!istype(L) || !L.can_resist() || L != owner)
		return
	L.changeNext_move(CLICK_CD_RESIST)
	if(L.last_special <= world.time)
		return L.resist_buckle()

// PRIVATE = only edit, use, or override these if you're editing the system as a whole

// Re-render all alerts - also called in /datum/hud/show_hud() because it's needed there
/datum/hud/proc/reorganize_alerts(mob/viewmob)
	var/mob/screenmob = viewmob || mymob
	if(!screenmob.client)
		return
	var/list/alerts = mymob.alerts
	if(!hud_shown)
		for(var/i = 1, i <= alerts.len, i++)
			screenmob.client.screen -= alerts[alerts[i]]
		return 1
	for(var/i = 1, i <= alerts.len, i++)
		var/atom/movable/screen/alert/alert = alerts[alerts[i]]
		if(alert.icon_state == "template")
			alert.icon = ui_style
		switch(i)
			if(1)
				. = ui_alert1
			if(2)
				. = ui_alert2
			if(3)
				. = ui_alert3
			if(4)
				. = ui_alert4
			if(5)
				. = ui_alert5 // Right now there's 5 slots
			else
				. = ""
		alert.screen_loc = .
		screenmob.client.screen |= alert
	if(!viewmob)
		for(var/M in mymob.observers)
			reorganize_alerts(M)
	return 1

/mob
	var/list/alerts = list() // contains /atom/movable/screen/alert only // On /mob so clientless mobs will throw alerts properly

/atom/movable/screen/alert/examine(mob/user)
	if(!usr || !usr.client)
		return
	if(usr != owner)
		return
	. += "<span class='boldnotice'>[name]</span> - <span class='info'>[desc]</span>"

/atom/movable/screen/alert/Destroy()
	severity = 0
	owner = null
	screen_loc = ""
	return ..()
