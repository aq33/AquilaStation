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
	// Magazyn energii jest tylko w sklepie, a płaci się za zebraną energię, więc idzie przed zasadą „rzeczy ze sklepu za 5”
	if(istype(I, /obj/item/powersink/salvager))
		var/obj/item/powersink/salvager/sink = I
		return round(sink.power_drained / sink.max_power * 15000)
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
	// Sprzedaż jest w oknie terminalu: pokazuje przedmiot z ręki i jego cenę
	if(get_salvager_datum(user))
		ui_interact(user)
	return TRUE

/obj/machinery/salvager_trader/ui_interact(mob/user, datum/tgui/ui)
	if(!get_salvager_datum(user))
		say("Nie można przetworzyć żądania.")
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SalvagerTrader", "S.R.O.K.A.")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/salvager_trader/ui_static_data(mob/user)
	var/list/data = list()
	var/list/shop = salvager_shop_items()
	var/list/categories = list()
	var/list/items = list()
	for(var/path in shop)
		var/obj/item/item_type = path
		var/category = salvager_shop_category(path)
		categories |= category
		items += list(list(
			"path" = "[path]",
			"name" = initial(item_type.name),
			"desc" = initial(item_type.desc),
			"price" = shop[path],
			"category" = category,
			"icon" = salvager_type_icon(path),
		))
	data["categories"] = categories
	data["shop"] = items
	return data

/obj/machinery/salvager_trader/ui_data(mob/user)
	var/list/data = list()
	var/datum/antagonist/pirate/salvager/S = get_salvager_datum(user)
	data["points"] = S?.salvager_points || 0
	data["earned"] = S?.salvager_points_earned || 0
	var/datum/team/pirate/salvager/crew = S?.crew
	var/datum/objective/salvage_points/goal = istype(crew) ? (locate() in crew.objectives) : null
	data["crew_points"] = istype(crew) ? crew.total_points() : 0
	data["goal"] = goal?.target_amount || 0
	var/obj/item/held = user.get_active_held_item()
	if(held)
		data["held"] = list(
			"name" = held.name,
			"value" = salvager_appraise(held),
			"icon" = salvager_type_icon(held.type),
		)
	return data

/obj/machinery/salvager_trader/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/mob/living/user = usr
	if(!istype(user) || !user.Adjacent(src) || user.incapacitated())
		return
	var/datum/antagonist/pirate/salvager/S = get_salvager_datum(user)
	if(!S)
		return
	switch(action)
		if("sell")
			var/obj/item/I = user.get_active_held_item()
			var/value = salvager_appraise(I)
			if(!value)
				say("Obecna wartość rynkowa wynosi 0.")
				return TRUE
			if(!user.temporarilyRemoveItemFromInventory(I))
				return TRUE
			qdel(I)
			S.add_salvage_points(value)
			say(pick("Dziękuję za interes, organiczny.", "Dopisuję cię do bazy dobrych klientów."))
			playsound(src, 'sound/machines/ping.ogg', 40, TRUE)
			return TRUE
		if("buy")
			var/path = text2path(params["path"])
			var/price = salvager_shop_items()[path]
			if(!price)
				return
			if(S.salvager_points < price)
				say("Przykro mi, nie masz wystarczających środków.")
				return TRUE
			S.salvager_points -= price
			var/obj/item/bought = new path(get_turf(src))
			bought.salvager_part = TRUE
			if(istype(bought, /obj/item/stack/barbed_wire))
				var/obj/item/stack/barbed_wire/wire = bought
				wire.amount = 3
				wire.update_icon()
			user.put_in_hands(bought)
			say(pick("Dziękuję za zakupy.", "Czekam na kolejne transakcje."))
			playsound(src, 'sound/machines/ping.ogg', 40, TRUE)
			return TRUE

/// Dział sklepu S.R.O.K.A. dla przedmiotu
/proc/salvager_shop_category(path)
	if(ispath(path, /obj/item/gun) || ispath(path, /obj/item/ammo_box) || ispath(path, /obj/item/storage/box/lethalshot) || ispath(path, /obj/item/fireaxe) || ispath(path, /obj/item/melee) || ispath(path, /obj/item/grenade))
		return "Broń"
	if(ispath(path, /obj/item/clothing/head/helmet) || ispath(path, /obj/item/clothing/suit/armor) || ispath(path, /obj/item/shield) || ispath(path, /obj/item/stack/barbed_wire) || ispath(path, /obj/item/jammer))
		return "Ochrona"
	if(ispath(path, /obj/item/storage/box) || ispath(path, /obj/item/storage/pill_bottle))
		return "Zaopatrzenie"
	return "Narzędzia"

/// Ikona typu przedmiotu dla okien TGUI (raz na typ)
/proc/salvager_type_icon(path)
	var/static/list/cache = list()
	if(!cache[path])
		cache[path] = aq_item_type_icon(path)
	return cache[path]

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
	/// Pierwszy etap startu w oknie konsoli (Goon pytał dwa razy)
	var/armed = FALSE
	var/announced_once = FALSE

/obj/machinery/computer/salvager_pod_launcher/ui_interact(mob/user, datum/tgui/ui)
	if(!get_salvager_datum(user))
		to_chat(user, "<span class='warning'>Ta konsola nie ma dla ciebie sensu.</span>")
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SalvagerPodLauncher", name)
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/salvager_pod_launcher/ui_static_data(mob/user)
	var/list/names = list()
	for(var/area_name in landing_areas())
		names += area_name
	return list("areas" = names)

/obj/machinery/computer/salvager_pod_launcher/ui_data(mob/user)
	var/list/data = list()
	data["area"] = landing_area?.name
	var/list/crew = list()
	for(var/mob/living/carbon/C as anything in launch_crew())
		crew += "[C]"
	data["crew"] = crew
	data["reload"] = max(0, round((next_launch - world.time) / 10))
	data["launching"] = launching
	data["armed"] = armed
	return data

/obj/machinery/computer/salvager_pod_launcher/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!get_salvager_datum(usr) || launching)
		return
	switch(action)
		if("set_area")
			var/list/areas = landing_areas()
			var/area/picked = areas[params["area"]]
			if(picked)
				landing_area = picked
				armed = FALSE
			return TRUE
		if("arm")
			armed = !armed && landing_area && world.time >= next_launch
			return TRUE
		if("launch")
			if(!armed || !landing_area || world.time < next_launch)
				return TRUE
			armed = FALSE
			INVOKE_ASYNC(src, PROC_REF(launch), usr)
			return TRUE

/// Obszary okrętu, na które da się lądować: nazwa -> obszar
/obj/machinery/computer/salvager_pod_launcher/proc/landing_areas()
	. = list()
	for(var/area/A as anything in GLOB.sortedAreas)
		if(!(A.area_flags & VALID_TERRITORY) || !is_station_level(A.z) || .[A.name])
			continue
		.[A.name] = A

/obj/machinery/computer/salvager_pod_launcher/proc/launch_crew()
	. = list()
	for(var/mob/living/carbon/C in range(2, src))
		. += C

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
