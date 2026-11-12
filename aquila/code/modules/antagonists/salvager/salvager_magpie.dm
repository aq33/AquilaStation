// S.R.O.K.A. (u Goona M4GP13 „Magpie”): terminal skupu i wymiany na statku złomiarzy.
// Wycenia rzeczy, skupuje złom za osobiste punkty złomiarza i sprzedaje za nie sprzęt (ceny jak w Goonie).
// Konsola kapsuł desantowych wysyła złomiarzy stojących obok na wybrany obszar okrętu (w jedną stronę).

/obj/item
	/// Kupione w terminalu S.R.O.K.A.: odsprzedaż daje tylko 5 punktów (Goon: „SALVAGER PART”)
	var/tmp/salvager_part = FALSE

/// Sprzęt w sklepie S.R.O.K.A.: typ -> cena w punktach
/proc/salvager_shop_items()
	var/static/list/items = list(
		/obj/item/salvager_hand_tele = 400,
		/obj/item/clothing/head/helmet/alt = 250,
		/obj/item/clothing/suit/armor/bulletproof = 500,
		/obj/item/weldingtool/experimental/salvager_arc = 500,
		/obj/item/fireaxe = 400,
		/obj/item/melee/sledgehammer/salvager = 500,
		/obj/item/gun/ballistic/shotgun/salvager = 1200,
		/obj/item/storage/box/lethalshot = 250,
		/obj/item/gun/energy/laser/retro = 650,
		/obj/item/gun/ballistic/automatic/pistol = 1650,
		/obj/item/ammo_box/magazine/m10mm = 399,
		/obj/item/storage/box/teargas = 400,
		/obj/item/storage/box/salvager_distract = 350,
		/obj/item/stack/barbed_wire = 350,
		/obj/item/shield/riot = 700,
		/obj/item/jammer = 2000,
		/obj/item/grenade/plastic/x4 = 500,
		/obj/item/powersink/salvager = 5000,
		/obj/item/storage/pill_bottle/salvager = 50,
		/obj/item/storage/pill_bottle/salvager/meth = 350,
		/obj/item/salvage_reclaimer = 100,
		/obj/item/salvage_dualconstructor = 10,
		/obj/item/storage/belt/utility/full = 100,
		/obj/item/clothing/glasses/salvager = 50,
		/obj/item/stack/telecrystal = 225,
	)
	return items

/// Wartość rzeczy w terminalu S.R.O.K.A. (cennik skupu Goona przełożony na nasze przedmioty)
/proc/salvager_appraise(obj/item/I)
	if(!istype(I))
		return 0
	if(I.salvager_part)
		return 5
	. = 0
	if(istype(I, /obj/item/salvage_frame))
		var/obj/item/salvage_frame/frame = I
		. = 100
		if(frame.had_access)
			. += 75
		if(!frame.from_station)
			. *= 0.8
	else if(istype(I, /obj/item/circuitboard))
		. = 10 // luźna płytka: u Goona część poza ramą jest warta dziesięć razy mniej
	else if(istype(I, /obj/item/stack/scrap))
		var/obj/item/stack/scrap/scrap = I
		. = scrap.scrap_value * scrap.amount
	else if(istype(I, /obj/item/stack/telecrystal))
		var/obj/item/stack/telecrystal/crystal = I
		. = 200 * crystal.amount
	else if(istype(I, /obj/item/stack/sheet/mineral/diamond) || istype(I, /obj/item/stack/ore/bluespace_crystal))
		var/obj/item/stack/gem = I
		. = 150 * gem.amount
	else if(istype(I, /obj/item/stack/sheet/mineral))
		var/obj/item/stack/bar = I
		. = 10 * bar.amount
	else if(istype(I, /obj/item/stack/sheet))
		var/obj/item/stack/sheet = I
		. = sheet.amount
	else if(istype(I, /obj/item/bodypart) && findtext("[I.type]", "/robot"))
		. = 25
	else if(istype(I, /obj/item/powersink/salvager))
		var/obj/item/powersink/salvager/sink = I
		return round(sink.power_drained / sink.max_power * 15000)
	// Nic nie jest warte więcej niż 80% ceny w sklepie
	var/shop_price = salvager_shop_items()[I.type]
	if(shop_price && . > shop_price * 0.8)
		. = shop_price * 0.8
	. = round(.)

/obj/machinery/salvager_trader
	name = "S.R.O.K.A. - System Rozliczeń Odzysku i Kupna Asortymentu"
	desc = "Terminal skupu i zaopatrzenia złomiarzy. Za odzyskane materiały i sprzęt wydaje towar."
	icon = 'aquila/icons/goonstation/salvager.dmi'
	icon_state = "magpie_trader"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE
	var/next_scan = 0

/obj/machinery/salvager_trader/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Uderz terminal przedmiotem, żeby poznać jego cenę i go sprzedać. Kliknij, żeby kupić sprzęt.</span>"

/obj/machinery/salvager_trader/attackby(obj/item/I, mob/living/user, params)
	if(user.combat_mode)
		return ..()
	if(world.time < next_scan)
		return TRUE
	next_scan = world.time + 2.7 SECONDS
	var/value = salvager_appraise(I)
	playsound(src, 'sound/machines/scanbuzz.ogg', 30, TRUE)
	if(!do_after(user, 1.8 SECONDS, target = src))
		return TRUE
	if(!value)
		say(prob(95) ? "Obecna wartość rynkowa wynosi 0." : "Brak w bazie kupca na [I].")
		return TRUE
	say(prob(90) ? "Obecna wartość rynkowa wynosi [value]." : "[value] to najlepsze, co mogę dać.")
	var/datum/antagonist/pirate/salvager/S = get_salvager_datum(user)
	if(!S)
		return TRUE
	if(tgui_alert(user, "Sprzedać [I] za [value] pkt?", "S.R.O.K.A.", list("Sprzedaj", "Zostaw")) != "Sprzedaj")
		return TRUE
	if(QDELETED(I) || !user.Adjacent(src) || salvager_appraise(I) != value || !user.temporarilyRemoveItemFromInventory(I))
		return TRUE
	qdel(I)
	S.add_salvage_points(value)
	say(pick("Dziękuję za interes, organiczny.", "Dopisuję cię do bazy dobrych klientów."))
	playsound(src, 'sound/machines/ping.ogg', 40, TRUE)
	return TRUE

/obj/machinery/salvager_trader/ui_interact(mob/user, datum/tgui/ui)
	var/datum/antagonist/pirate/salvager/S = get_salvager_datum(user)
	if(!S)
		say("Nie można przetworzyć żądania.")
		return
	var/list/dat = list()
	dat += "<b>Witaj w sklepie. Wybierz sprzęt.</b><br>Twoje punkty złomu: <b>[S.salvager_points]</b> (zarobione: [S.salvager_points_earned])<br><hr>"
	var/list/shop = salvager_shop_items()
	for(var/path in shop)
		var/obj/item/item_type = path
		var/price = shop[path]
		var/label = "[initial(item_type.name)] ([price] pkt)"
		if(S.salvager_points >= price)
			label = "<a href='byond://?src=[REF(src)];buy=[path]'>[label]</a>"
		dat += "[label]<br>"
	var/datum/browser/popup = new(user, "salvager_trader", "S.R.O.K.A.", 420, 620)
	popup.set_content(dat.Join())
	popup.open()

/obj/machinery/salvager_trader/Topic(href, href_list)
	. = ..()
	var/mob/living/user = usr
	if(!istype(user) || !user.Adjacent(src) || user.incapacitated())
		return
	var/datum/antagonist/pirate/salvager/S = get_salvager_datum(user)
	if(!S || !href_list["buy"])
		return
	var/path = text2path(href_list["buy"])
	var/price = salvager_shop_items()[path]
	if(!price || S.salvager_points < price)
		say("Przykro mi, nie masz wystarczających środków.")
		return
	S.salvager_points -= price
	var/obj/item/bought = new path(get_turf(src))
	bought.salvager_part = TRUE
	if(istype(bought, /obj/item/stack/barbed_wire))
		var/obj/item/stack/barbed_wire/wire = bought
		wire.amount = 3
		wire.update_icon()
	user.put_in_hands(bought)
	say(pick("Dziękuję za zakupy.", "Czekam na kolejne transakcje."))
	ui_interact(user)

///////////////////
// Konsola kapsuł desantowych
///////////////////

/obj/structure/closet/supplypod/salvager
	name = "kapsuła desantowa złomiarzy"
	style = STYLE_SYNDICATE
	bluespace = TRUE
	explosionSize = list(0, 0, 0, 1)

/obj/machinery/computer/salvager_pod_launcher
	name = "konsola kapsuł desantowych"
	desc = "Wystrzeliwuje złomiarzy stojących obok na wybrany obszar okrętu. W jedną stronę: wraca się teleporterem ręcznym."
	icon_screen = "syndishuttle"
	icon_keyboard = "syndie_key"
	light_color = LIGHT_COLOR_RED
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE
	/// Obszar lądowania
	var/area/landing_area
	/// Do kiedy konsola się przeładowuje
	var/next_launch = 0
	var/launching = FALSE
	var/announced_once = FALSE

/obj/machinery/computer/salvager_pod_launcher/ui_interact(mob/user, datum/tgui/ui)
	if(!get_salvager_datum(user))
		to_chat(user, "<span class='warning'>Ta konsola nie ma dla ciebie sensu.</span>")
		return
	if(launching)
		to_chat(user, "<span class='warning'>Kapsuły już startują!</span>")
		return
	if(!landing_area)
		choose_area(user)
		return
	var/choice = tgui_alert(user, "Obszar lądowania: [landing_area.name]. Co robisz?", name, list("Start", "Zmień obszar", "Anuluj"))
	if(choice == "Zmień obszar")
		choose_area(user)
	else if(choice == "Start")
		try_launch(user)

/obj/machinery/computer/salvager_pod_launcher/proc/choose_area(mob/user)
	var/list/areas = list()
	for(var/area/A as anything in GLOB.sortedAreas)
		if(!(A.area_flags & VALID_TERRITORY) || !is_station_level(A.z) || areas[A.name])
			continue
		areas[A.name] = A
	var/picked = tgui_input_list(user, "Gdzie lądujemy?", name, areas)
	if(picked && areas[picked])
		landing_area = areas[picked]
		to_chat(user, "<span class='notice'>Obszar lądowania: [landing_area.name].</span>")

/obj/machinery/computer/salvager_pod_launcher/proc/launch_crew()
	. = list()
	for(var/mob/living/carbon/C in range(2, src))
		. += C

/obj/machinery/computer/salvager_pod_launcher/proc/try_launch(mob/user)
	if(world.time < next_launch)
		to_chat(user, "<span class='warning'>Kapsuły się przeładowują. Gotowe za [DisplayTimeText(next_launch - world.time)].</span>")
		return
	var/list/crew = launch_crew()
	if(tgui_alert(user, "Na pewno startujecie? [length(crew) <= 1 ? "Jesteś sam!" : "Leci [length(crew)] osób."]", name, list("Tak", "Nie")) != "Tak")
		return
	if(tgui_alert(user, "NAPRAWDĘ na pewno? Nie ma powrotu!", name, list("Tak", "Nie")) != "Tak")
		return
	if(launching || world.time < next_launch || !user.Adjacent(src))
		return
	INVOKE_ASYNC(src, PROC_REF(launch), user)

/obj/machinery/computer/salvager_pod_launcher/proc/launch(mob/user)
	launching = TRUE
	next_launch = world.time + 5 MINUTES
	var/delay = 10 SECONDS + rand(0, 5 SECONDS)
	for(var/mob/living/L in launch_crew())
		shake_camera(L, delay / 10, 2)
		L.Knockdown(2 SECONDS)
	sleep(delay / 2)
	if(!announced_once || prob(80))
		priority_announce("Czujniki wykryły kapsułę zmierzającą w stronę okrętu. Zalecana reakcja.", "Alarm czujników")
		announced_once = TRUE
	sleep(delay / 2)
	var/list/turf/landing = salvager_landing_turfs()
	var/list/launched = launch_crew()
	for(var/mob/living/carbon/C in launched)
		if(!length(landing))
			landing = salvager_landing_turfs()
		if(!length(landing))
			break
		var/turf/T = pick_n_take(landing)
		var/obj/structure/closet/supplypod/salvager/pod = new
		C.forceMove(pod)
		new /obj/effect/pod_landingzone(T, pod)
		log_game("Salvager pod: [key_name(C)] launched to [AREACOORD(T)]")
	if(length(launched))
		priority_announce("[length(launched) > 1 ? "Grupa [length(launched)] kapsuł desantowych" : "Pojedyncza kapsuła desantowa"] leci w stronę okrętu. Przygotujcie się na kontakt.", "Alarm czujników")
	launching = FALSE

/// Bezpieczne kafelki w promieniu 3 od losowego miejsca w wybranym obszarze (kapsuły lądują w grupie, jak w Goonie)
/obj/machinery/computer/salvager_pod_launcher/proc/salvager_landing_turfs()
	. = list()
	if(!landing_area)
		return
	var/list/safe = list()
	for(var/turf/open/T in get_area_turfs(landing_area))
		if(isspaceturf(T) || is_blocked_turf(T, TRUE))
			continue
		safe += T
	if(!length(safe))
		return
	var/turf/center = pick(safe)
	for(var/turf/T as anything in safe)
		if(T.z == center.z && get_dist(T, center) <= 3)
			. += T
