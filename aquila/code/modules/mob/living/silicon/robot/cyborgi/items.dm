// AQUILA - narzędzia nowych modułów i ulepszeń cyborgów.
// Mechanika wzorowana na oryginałach (tg, Monkestation, Yogstation, Paradise, Goonstation, /vg/, Baystation12, Nova Sector),
// kod napisany pod nasze typy. Źródło każdej pozycji w komentarzu nad nią.

// ================================================================ Chwytaki (Nova Sector/Yog grippers, na wzór naszego aparatu amunicji)

/obj/item/borg/apparatus/aquila
	name = "chwytak cyborga"
	desc = "Chwytak, który trzyma tylko określone przedmioty."
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_clamp"

/obj/item/borg/apparatus/aquila/update_icon()
	cut_overlays()
	if(stored)
		COMPILE_OVERLAYS(stored)
		stored.pixel_x = 0
		stored.pixel_y = 0
		var/image/held = image("icon" = stored, "layer" = FLOAT_LAYER)
		held.plane = FLOAT_PLANE
		held.transform = matrix() * 0.8
		add_overlay(held)
	return ..()

/obj/item/borg/apparatus/aquila/examine(mob/user)
	. = ..()
	if(stored)
		. += "Chwytak trzyma: [stored]."
		. += "<span class='notice'><i>Alt-kliknięcie</i> odkłada [stored].</span>"

/// Chwytak chemiczny (Nova Sector „chemistry gripper”)
/obj/item/borg/apparatus/aquila/chemistry
	name = "chwytak chemiczny"
	desc = "Chwytak do zlewek, butelek, pojemników na tabletki, worków chemicznych i wkładów do dozowników."
	storable = list(
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/chem_bag,
		/obj/item/storage/pill_bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
	)

/// Chwytak medyczny (Yogstation „medigripper”)
/obj/item/borg/apparatus/aquila/medical
	name = "chwytak medyczny"
	desc = "Chwytak do tabletek, plastrów, butelek, strzykawek, worków z krwią i opatrunków."
	storable = list(
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/blood,
		/obj/item/reagent_containers/medspray,
		/obj/item/reagent_containers/chem_bag,
		/obj/item/stack/medical,
		/obj/item/storage/pill_bottle,
	)

/// Chwytak ksenobiologa (Monkestation „science_xenobiology”: zamiast odkurzacza śluzów, którego nie mamy)
/obj/item/borg/apparatus/aquila/xenobio
	name = "chwytak ksenobiologiczny"
	desc = "Chwytak do ekstraktów śluzów, mikstur śluzowych i małpich kostek."
	storable = list(
		/obj/item/slime_extract,
		/obj/item/slimepotion,
		/obj/item/food/monkeycube,
		/obj/item/storage/box/monkeycubes,
	)

/// Chwytak biurowy (Bay „gripper/clerical”)
/obj/item/borg/apparatus/aquila/paperwork
	name = "chwytak biurowy"
	desc = "Chwytak do papieru, teczek, zdjęć i podkładek."
	storable = list(
		/obj/item/paper,
		/obj/item/folder,
		/obj/item/photo,
		/obj/item/clipboard,
		/obj/item/paper_bin,
		/obj/item/card/id,
	)

/// Aparat do płytek rozszerzony o układy scalone (Monkestation „science_apparatus_improvement/circuits”)
/obj/item/borg/apparatus/circuit/aquila_science
	name = "aparat do płytek i układów"
	desc = "Aparat do płytek drukowanych, elektroniki, części maszyn i komponentów układów scalonych."
	storable = list(
		/obj/item/circuitboard,
		/obj/item/electronics,
		/obj/item/stock_parts,
		/obj/item/circuit_component,
		/obj/item/integrated_circuit,
		/obj/item/shell,
		/obj/item/usb_cable,
		/obj/item/assembly,
	)

/// Aparat ze zlewką bluespace (SS220: cyborgowa zlewka 300 j.)
/obj/item/borg/apparatus/beaker/bluespace
	name = "aparat ze zlewką bluespace"
	desc = "Aparat do zlewek, który zaczyna ze zlewką bluespace."

/obj/item/borg/apparatus/beaker/bluespace/Initialize(mapload)
	. = ..()
	if(stored)
		UnregisterSignal(stored, COMSIG_ATOM_UPDATE_ICON)
		QDEL_NULL(stored)
	stored = new /obj/item/reagent_containers/glass/beaker/bluespace(src)
	RegisterSignal(stored, COMSIG_ATOM_UPDATE_ICON, TYPE_PROC_REF(/atom, update_icon))
	update_icon()

// ================================================================ Chemia

/// Mini-CheMaster (Goonstation „robot_chemaster”): robi tabletki, plastry i butelki z zawartości pojemnika
/obj/item/borg/chem_master
	name = "mini-CheMaster"
	desc = "Wbudowany mały CheMaster. Kliknij nim pojemnik z odczynnikami, żeby zrobić z jego zawartości tabletki, plastry albo butelkę."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0"
	/// Koszt energii jednej sztuki
	var/charge_cost = 100
	/// Ile jednostek najwyżej w jednej sztuce
	var/max_unit_volume = 50
	var/busy = FALSE

/obj/item/borg/chem_master/afterattack(atom/target, mob/living/silicon/robot/user, proximity_flag)
	. = ..()
	if(!proximity_flag || !iscyborg(user) || busy)
		return
	if(!istype(target, /obj/item/reagent_containers) || !target.reagents?.total_volume)
		return
	busy = TRUE
	var/kind = tgui_input_list(user, "Co zrobić z zawartości [target]?", name, list("Tabletki", "Plastry", "Butelka"))
	if(!kind || QDELETED(target) || !user.Adjacent(target) || !target.reagents.total_volume)
		busy = FALSE
		return
	var/per_item = kind == "Butelka" ? 30 : tgui_input_number(user, "Ile jednostek w jednej sztuce?", name, 10, max_unit_volume, 1)
	if(!per_item || QDELETED(target) || !target.reagents.total_volume)
		busy = FALSE
		return
	per_item = clamp(round(per_item), 1, max_unit_volume)
	var/count = kind == "Butelka" ? 1 : min(10, CEILING(target.reagents.total_volume / per_item, 1))
	var/made = aq_make_items(user, target, kind, per_item, count)
	busy = FALSE
	if(made)
		balloon_alert(user, "gotowe: [made] szt.")
		playsound(src, 'sound/machines/click.ogg', 40, TRUE)

/// Robi count sztuk po per_item jednostek z target, zwraca liczbę zrobionych
/obj/item/borg/chem_master/proc/aq_make_items(mob/living/silicon/robot/user, atom/target, kind, per_item, count)
	. = 0
	var/turf/drop = get_turf(user)
	for(var/i in 1 to count)
		if(!target.reagents.total_volume || !user.aq_use_charge(charge_cost))
			return
		var/obj/item/reagent_containers/product
		switch(kind)
			if("Tabletki")
				product = new /obj/item/reagent_containers/pill(drop)
				product.name = "tabletka ([target.reagents.get_master_reagent_name()])"
			if("Plastry")
				product = new /obj/item/reagent_containers/pill/patch(drop)
				product.name = "plaster ([target.reagents.get_master_reagent_name()])"
			else
				product = new /obj/item/reagent_containers/glass/bottle(drop)
				product.name = "butelka ([target.reagents.get_master_reagent_name()])"
		target.reagents.trans_to(product, per_item, transfered_by = user)
		.++

/// Mały dozownik reagentów (Goon/Nova: dozownik chemika-cyborga). Nalewa podstawowe pierwiastki do pojemników, nie wstrzykuje
/obj/item/reagent_containers/borghypo/chem_dispenser
	name = "mały dozownik odczynników"
	desc = "Syntezator podstawowych odczynników chemicznych zasilany z ogniwa. Nalewa do pojemników, nie wstrzykuje."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dispenser"
	possible_transfer_amounts = list(5, 10, 20)
	charge_cost = 20
	recharge_time = 3
	default_reagent_types = list(
		/datum/reagent/aluminium,
		/datum/reagent/bromine,
		/datum/reagent/carbon,
		/datum/reagent/chlorine,
		/datum/reagent/copper,
		/datum/reagent/consumable/ethanol,
		/datum/reagent/fluorine,
		/datum/reagent/hydrogen,
		/datum/reagent/iodine,
		/datum/reagent/iron,
		/datum/reagent/lithium,
		/datum/reagent/mercury,
		/datum/reagent/nitrogen,
		/datum/reagent/oxygen,
		/datum/reagent/phosphorus,
		/datum/reagent/potassium,
		/datum/reagent/silicon,
		/datum/reagent/sodium,
		/datum/reagent/stable_plasma,
		/datum/reagent/consumable/sugar,
		/datum/reagent/sulfur,
		/datum/reagent/water,
	)

/obj/item/reagent_containers/borghypo/chem_dispenser/attack(mob/M, mob/user)
	return // dozownik nie wstrzykuje

/obj/item/reagent_containers/borghypo/chem_dispenser/afterattack(obj/target, mob/user, proximity)
	. = ..()
	if(!proximity || !istype(target) || !target.is_refillable())
		return
	if(!selected_reagent)
		balloon_alert(user, "nie wybrano odczynnika!")
		return
	if(!stored_reagents.has_reagent(selected_reagent.type, amount_per_transfer_from_this))
		balloon_alert(user, "za mało: [selected_reagent.name]!")
		return
	if(target.reagents.total_volume >= target.reagents.maximum_volume)
		balloon_alert(user, "[target] jest pełny!")
		return
	var/datum/reagents/pour = new()
	stored_reagents.remove_reagent(selected_reagent.type, amount_per_transfer_from_this)
	pour.add_reagent(selected_reagent.type, amount_per_transfer_from_this, no_react = TRUE)
	pour.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
	qdel(pour)
	balloon_alert(user, "wlano: [amount_per_transfer_from_this] j.")

/// Skaner widmowy (Goonstation „spectroscopic scanner”): skład odczynników w ludziach, jedzeniu i pojemnikach
/obj/item/borg/spectro_scanner
	name = "skaner widmowy"
	desc = "Skaner spektroskopowy: pokazuje skład odczynników w organizmie, jedzeniu i pojemnikach."
	icon = 'icons/obj/device.dmi'
	icon_state = "spectrometer"
	item_flags = NOBLUDGEON

/obj/item/borg/spectro_scanner/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(!proximity_flag)
		return
	if(isliving(target))
		user.visible_message("<span class='notice'>[user] skanuje [target] skanerem widmowym.</span>")
		chemscan(user, target)
		return
	if(!target.reagents)
		return
	if(!target.reagents.total_volume)
		to_chat(user, "<span class='notice'>[target] nie zawiera odczynników.</span>")
		return
	var/list/lines = list("<span class='notice'>Skład [target]:</span>")
	for(var/datum/reagent/reagent as anything in target.reagents.reagent_list)
		lines += "<span class='notice'>- [reagent.name]: [round(reagent.volume, 0.1)] j.</span>"
	to_chat(user, examine_block(jointext(lines, "\n")))

// ================================================================ Wzrok

/// Noktowizja cyborga (Chaotic Onyx „night vision”)
/obj/item/borg/sight/aquila_nightvision
	name = "\proper noktowizja"
	icon_state = "meson"
	color = "#7CFC00"
	sight_mode = BORG_AQ_NIGHTVISION

/// Noktowizyjne mezony (Yogstation „night vision mesons”)
/obj/item/borg/sight/meson/aquila_nightvision
	name = "\proper noktowizyjne widzenie mezonowe"
	color = "#7CFC00"
	sight_mode = BORGMESON | BORG_AQ_NIGHTVISION

/// Nakładka wzroku podświetlająca wybrane rzeczy w zasięgu (wspólna dla wzroku anomalii i N.O.I.R.)
/obj/item/borg/sight/aquila_scanner
	name = "nakładka wzroku"
	icon_state = "meson"
	/// Promień szukania
	var/scan_range = 7
	/// Kolor podświetlenia
	var/highlight_color = "#FF00FF"
	/// Cyborg, któremu pokazujemy obrazki
	var/mob/living/silicon/robot/viewer
	/// Pokazane obrazki
	var/list/image/shown_images = list()

/obj/item/borg/sight/aquila_scanner/equipped(mob/user, slot)
	. = ..()
	if(!iscyborg(user))
		return
	viewer = user
	START_PROCESSING(SSobj, src)
	process()

/obj/item/borg/sight/aquila_scanner/cyborg_unequip(mob/user)
	. = ..()
	aq_stop()

/obj/item/borg/sight/aquila_scanner/Destroy()
	aq_stop()
	return ..()

/obj/item/borg/sight/aquila_scanner/proc/aq_stop()
	STOP_PROCESSING(SSobj, src)
	aq_clear_images()
	viewer = null

/obj/item/borg/sight/aquila_scanner/proc/aq_clear_images()
	if(viewer?.client)
		viewer.client.images -= shown_images
	shown_images.Cut()

/obj/item/borg/sight/aquila_scanner/process()
	if(QDELETED(viewer) || viewer.stat == DEAD || !(src in viewer.held_items))
		aq_stop()
		return PROCESS_KILL
	aq_clear_images()
	if(!viewer.client)
		return
	for(var/atom/movable/target as anything in aq_scan(get_turf(viewer)))
		var/turf/target_turf = get_turf(target)
		if(!target_turf)
			continue
		// Obrazek na kafelku, a nie na przedmiocie, żeby było go widać przez ściany razem z kafelkiem (widzenie mezonowe)
		var/image/marker = image(target.icon, target_turf, target.icon_state, ABOVE_ALL_MOB_LAYER, target.dir)
		marker.plane = ABOVE_LIGHTING_PLANE
		marker.color = highlight_color
		marker.alpha = 200
		marker.pixel_x = target.pixel_x
		marker.pixel_y = target.pixel_y
		shown_images += marker
	viewer.client.images |= shown_images

/// Co podświetlić wokół center
/obj/item/borg/sight/aquila_scanner/proc/aq_scan(turf/center)
	return list()

/// Wzrok anomalii (CHOMPStation „anomalous vision”): anomalie, ich rdzenie, artefakty i źródła promieniowania przez ściany
/obj/item/borg/sight/aquila_scanner/anomaly
	name = "\proper wzrok anomalii"
	desc = "Nakładka wzroku pokazująca anomalie, rdzenie anomalii, artefakty i źródła promieniowania, także przez ściany."
	color = "#B266FF"
	highlight_color = "#CC66FF"
	sight_mode = BORGMESON

/obj/item/borg/sight/aquila_scanner/anomaly/aq_scan(turf/center)
	. = list()
	if(!center)
		return
	for(var/atom/movable/thing in range(scan_range, center))
		if(istype(thing, /obj/effect/anomaly) || istype(thing, /obj/item/assembly/signaler/anomaly) || istype(thing, /obj/item/xenoartifact))
			. += thing
	for(var/datum/element/radioactive/radiation in SSdcs.processing)
		for(var/atom/movable/source as anything in radiation.radioactive_objects)
			if(!QDELETED(source) && get_dist(source, center) <= scan_range && source.z == center.z)
				. |= source

/// N.O.I.R. (/vg/station): krew, ślady i porzucone dowody wyróżnione kolorem w czarno-białym obrazie
/obj/item/borg/sight/aquila_scanner/noir
	name = "\proper wzrok N.O.I.R."
	desc = "Czarno-biały tryb wzroku, w którym krew, łuski, odłamki pocisków i przedmioty ze śladami są wyróżnione na czerwono."
	icon_state = "securityhud"
	color = "#999999"
	highlight_color = "#FF2020"
	scan_range = 6

/obj/item/borg/sight/aquila_scanner/noir/equipped(mob/user, slot)
	. = ..()
	if(iscyborg(user))
		user.add_client_colour(/datum/client_colour/monochrome)

/obj/item/borg/sight/aquila_scanner/noir/aq_stop()
	viewer?.remove_client_colour(/datum/client_colour/monochrome)
	return ..()

/obj/item/borg/sight/aquila_scanner/noir/aq_scan(turf/center)
	. = list()
	if(!center || !viewer)
		return
	for(var/atom/movable/thing in view(scan_range, viewer))
		if(istype(thing, /obj/effect/decal/cleanable/blood) || istype(thing, /obj/effect/decal/cleanable/blood/trail_holder) || istype(thing, /obj/item/ammo_casing) || istype(thing, /obj/item/bullet_fragment))
			. += thing
		else if(isitem(thing) && thing.GetComponent(/datum/component/forensics))
			. += thing

// ================================================================ Medycyna

/// Syntezator krwi (Chaotic Onyx): napełnia worek krwią 0 Rh- z ogniwa, powoli
/obj/item/borg/blood_synthesizer
	name = "syntezator krwi"
	desc = "Syntezuje krew grupy 0 Rh- z ogniwa cyborga. Kliknij nim worek na krew, żeby go napełniać."
	icon = 'icons/obj/bloodpack.dmi'
	icon_state = "bloodpack"
	color = "#FFB0B0"
	/// Ile krwi na jeden cykl
	var/amount_per_cycle = 20
	/// Koszt energii cyklu
	var/charge_cost = 400
	var/busy = FALSE

/obj/item/borg/blood_synthesizer/afterattack(atom/target, mob/living/silicon/robot/user, proximity_flag)
	. = ..()
	if(!proximity_flag || !iscyborg(user) || busy || !istype(target, /obj/item/reagent_containers/blood))
		return
	var/obj/item/reagent_containers/blood/bag = target
	if(bag.reagents.total_volume >= bag.reagents.maximum_volume)
		balloon_alert(user, "worek jest pełny!")
		return
	busy = TRUE
	to_chat(user, "<span class='notice'>Zaczynasz syntezować krew do [bag].</span>")
	while(bag.reagents.total_volume < bag.reagents.maximum_volume)
		if(!do_after(user, 2 SECONDS, target = bag) || !aq_fill(user, bag))
			break
	busy = FALSE

/// Jeden cykl: zwraca TRUE, jeśli dolano krew
/obj/item/borg/blood_synthesizer/proc/aq_fill(mob/living/silicon/robot/user, obj/item/reagent_containers/blood/bag)
	if(!user.aq_use_charge(charge_cost))
		balloon_alert(user, "za mało energii!")
		return FALSE
	bag.reagents.add_reagent(/datum/reagent/blood, amount_per_cycle, list("viruses" = null, "blood_DNA" = null, "blood_type" = "O-", "resistances" = null, "trace_chem" = null))
	if(!bag.blood_type)
		bag.blood_type = "O-"
	bag.update_icon()
	return TRUE

/// Worek oddechowy (Monkestation „Ambu bag”): wentyluje nieoddychającego, także w masce gazowej
/obj/item/borg/breathing_bag
	name = "worek oddechowy"
	desc = "Worek samorozprężalny z maską. Przyłóż do twarzy pacjenta, żeby go wentylować: każdy cykl usuwa niedotlenienie lepiej niż resuscytacja."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "lungs-c"
	item_flags = NOBLUDGEON
	var/busy = FALSE

/obj/item/borg/breathing_bag/attack(mob/living/carbon/patient, mob/living/user)
	if(!istype(patient) || busy)
		return ..()
	if(patient.stat == DEAD)
		balloon_alert(user, "pacjent nie żyje!")
		return
	if(HAS_TRAIT(patient, TRAIT_NOBREATH) || !patient.getorganslot(ORGAN_SLOT_LUNGS))
		balloon_alert(user, "nie ma czym oddychać!")
		return
	busy = TRUE
	user.visible_message("<span class='notice'>[user] przykłada worek oddechowy do twarzy [patient].</span>", "<span class='notice'>Przykładasz worek oddechowy do twarzy [patient].</span>")
	if(do_after(user, 3 SECONDS, target = patient))
		for(var/i in 1 to 15)
			if(!patient.getOxyLoss() || !do_after(user, 1 SECONDS, target = patient))
				break
			patient.adjustOxyLoss(-10)
			patient.updatehealth()
		to_chat(user, "<span class='notice'>Kończysz wentylować [patient].</span>")
	busy = FALSE

/// Syntezator organów (Chaotic Onyx): proste narządy syntetyczne z energii, powoli
/obj/item/borg/organ_synthesizer
	name = "syntezator organów"
	desc = "Syntezuje proste narządy syntetyczne: serce, płuca, wątrobę i żołądek. Użyj w ręce, żeby wybrać narząd."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "heart-c"
	/// Koszt energii jednego narządu
	var/charge_cost = 5000
	/// Czas syntezy
	var/build_time = 15 SECONDS
	var/busy = FALSE
	var/static/list/organs = list(
		"Serce" = /obj/item/organ/heart/cybernetic,
		"Płuca" = /obj/item/organ/lungs/cybernetic,
		"Wątroba" = /obj/item/organ/liver/cybernetic,
		"Żołądek" = /obj/item/organ/stomach/cybernetic,
	)

/obj/item/borg/organ_synthesizer/attack_self(mob/living/silicon/robot/user)
	if(!iscyborg(user) || busy)
		return
	var/choice = tgui_input_list(user, "Który narząd zsyntezować?", name, organs)
	if(!choice || busy)
		return
	if(user.cell?.charge < charge_cost + AQ_BORG_MIN_CHARGE)
		balloon_alert(user, "za mało energii!")
		return
	busy = TRUE
	balloon_alert(user, "syntetyzuję...")
	if(do_after(user, build_time, target = user) && user.aq_use_charge(charge_cost))
		var/organ_type = organs[choice]
		new organ_type(get_turf(user))
		playsound(src, 'sound/machines/ding.ogg', 40, TRUE)
	busy = FALSE

/// Złącze zasilania z APC i sieci (Monkestation „power connector”): rozszerza nasze złącze o APC i węzły kabli
/obj/item/borg/charger/aquila_connector
	name = "kabel zasilania"
	desc = "Złącze zasilania z kablem: pobiera energię także z APC i węzłów sieci (kabel z terminalem albo węzeł na podłodze)."
	icon = 'icons/obj/module.dmi'
	icon_state = "charger_wire"
	/// Ile energii na jeden cykl (1,5 s)
	var/draw_per_cycle = 1000
	/// APC nie zejdzie poniżej tylu procent
	var/apc_min_percent = 25

/obj/item/borg/charger/aquila_connector/update_icon()
	icon_state = "charger_wire"
	return

/obj/item/borg/charger/aquila_connector/afterattack(atom/target, mob/living/silicon/robot/user, proximity_flag)
	if(!proximity_flag || !iscyborg(user) || mode != "draw" || !(istype(target, /obj/machinery/power/apc) || istype(target, /obj/structure/cable)))
		return ..()
	if(active)
		to_chat(user, "<span class='warning'>Już pobierasz energię z czegoś!</span>")
		return
	active = TRUE
	to_chat(user, "<span class='notice'>Podłączasz kabel do [target]...</span>")
	while(user.cell && user.cell.charge < user.cell.maxcharge)
		if(!do_after(user, 15, target = target) || !aq_draw(user, target))
			break
	active = FALSE
	to_chat(user, "<span class='notice'>Odłączasz kabel od [target].</span>")

/// Jeden cykl pobierania; zwraca ilość pobranej energii
/obj/item/borg/charger/aquila_connector/proc/aq_draw(mob/living/silicon/robot/user, atom/target)
	var/wanted = min(draw_per_cycle, user.cell.maxcharge - user.cell.charge)
	if(wanted <= 0)
		return 0
	var/got = 0
	if(istype(target, /obj/machinery/power/apc))
		var/obj/machinery/power/apc/apc = target
		if(!apc.cell || apc.cell.percent() <= apc_min_percent)
			balloon_alert(user, "APC ma za mało energii!")
			return 0
		got = apc.cell.use(min(wanted, apc.cell.charge - apc.cell.maxcharge * apc_min_percent / 100)) ? min(wanted, apc.cell.charge) : 0
		apc.update_icon()
	else
		var/obj/structure/cable/cable = target
		var/datum/powernet/net = cable.powernet
		if(!net || net.avail <= 0)
			balloon_alert(user, "w kablu nie ma prądu!")
			return 0
		var/surplus = max(0, net.avail - net.load)
		got = min(wanted, surplus * GLOB.CELLRATE)
		if(got <= 0)
			balloon_alert(user, "w sieci brakuje mocy!")
			return 0
		net.load += got / GLOB.CELLRATE
	if(got > 0)
		user.cell.give(got)
		do_sparks(1, FALSE, target)
	return got

/// Induktor cyborga (tg „modular inducer”): ładuje APC, ogniwa urządzeń i mechy z ogniwa cyborga
/obj/item/inducer/cyborg
	name = "induktor cyborga"
	desc = "Wbudowany induktor: ładuje APC, ogniwa urządzeń i egzoszkielety prosto z ogniwa cyborga. Nie zejdzie poniżej rezerwy cyborga."
	cell_type = null
	powertransfer = 1000

/obj/item/inducer/cyborg/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)

/obj/item/inducer/cyborg/cantbeused(mob/user)
	var/mob/living/silicon/robot/cyborg = user
	if(!iscyborg(cyborg) || !cyborg.cell)
		to_chat(user, "<span class='warning'>Induktor działa tylko podłączony do ogniwa cyborga!</span>")
		return TRUE
	cell = cyborg.cell
	if(cell.charge <= AQ_BORG_MIN_CHARGE)
		to_chat(user, "<span class='warning'>Masz za mało energii!</span>")
		return TRUE
	return FALSE

/obj/item/inducer/cyborg/induce(obj/item/stock_parts/cell/target, coefficient)
	if(!cell || cell.charge <= AQ_BORG_MIN_CHARGE || target == cell)
		return
	var/totransfer = min(cell.charge - AQ_BORG_MIN_CHARGE, powertransfer * coefficient)
	var/transferred = target.give(totransfer)
	cell.use(transferred)
	target.update_icon()

/obj/item/inducer/cyborg/recharge(atom/movable/A, mob/user)
	if(A == user || iscyborg(A))
		to_chat(user, "<span class='warning'>Induktor cyborga nie ładuje cyborgów.</span>")
		return TRUE
	return ..()

/obj/item/inducer/cyborg/attack_self(mob/user)
	return

/obj/item/inducer/cyborg/attackby(obj/item/W, mob/user)
	if(W.tool_behaviour == TOOL_SCREWDRIVER || istype(W, /obj/item/stock_parts/cell))
		return
	return ..()

/obj/item/inducer/cyborg/cyborg_unequip(mob/user)
	. = ..()
	cell = null

/obj/item/inducer/cyborg/Destroy()
	cell = null
	return ..()

// ================================================================ Inżynieria i budowa

/// RLD cyborga (Nova Sector „cyborg RLD”): lampy z energii ogniwa
/obj/item/construction/rld/cyborg
	name = "RLD cyborga"
	desc = "Szybki oświetlacz zasilany z ogniwa cyborga: stawia lampy, oprawy i świetliki."
	no_ammo_message = "<span class='warning'>Za mało ładunku.</span>"
	/// Ile energii za jednostkę materii
	var/energyfactor = 50

/obj/item/construction/rld/cyborg/useResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		to_chat(user, no_ammo_message)
		return 0
	. = borgy.cell.use(amount * energyfactor)
	if(!.)
		to_chat(user, no_ammo_message)

/obj/item/construction/rld/cyborg/checkResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		to_chat(user, no_ammo_message)
		return 0
	. = borgy.cell.charge >= (amount * energyfactor)
	if(!.)
		to_chat(user, no_ammo_message)

/// RPED bluespace cyborga (tg/Monkestation „BRPED”)
/obj/item/storage/part_replacer/bluespace/cyborg
	name = "RPED bluespace cyborga"
	desc = "Wbudowany RPED bluespace: wymienia części maszyn z odległości i mieści dużo więcej części."

/// Narzędzie do łatania podłóg (tg „plating repair tool”): kładzie poszycie na dziurze, naprawia i kafelkuje
/obj/item/borg/plating_repair
	name = "narzędzie do łatania podłóg"
	desc = "Kliknij nim dziurę w podłodze, żeby położyć poszycie, uszkodzone poszycie, żeby je naprawić, a gołe poszycie, żeby je wyłożyć płytkami. Zasilane z ogniwa."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	color = "#C0C0FF"
	item_flags = NOBLUDGEON
	/// Koszt energii jednej operacji
	var/charge_cost = 250

/obj/item/borg/plating_repair/afterattack(atom/target, mob/living/silicon/robot/user, proximity_flag)
	. = ..()
	if(!proximity_flag || !iscyborg(user))
		return
	var/turf/target_turf = get_turf(target)
	if(!target_turf || !isturf(target))
		return
	if(!user.aq_use_charge(charge_cost))
		balloon_alert(user, "za mało energii!")
		return
	if(isspaceturf(target_turf) || istype(target_turf, /turf/open/openspace))
		target_turf.PlaceOnTop(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		balloon_alert(user, "poszycie położone")
	else if(istype(target_turf, /turf/open/floor/plating))
		var/turf/open/floor/plating/plating = target_turf
		if(plating.broken || plating.burnt)
			plating.broken = FALSE
			plating.burnt = FALSE
			plating.icon_state = plating.icon_plating
			plating.update_icon()
			balloon_alert(user, "poszycie naprawione")
		else
			plating.PlaceOnTop(/turf/open/floor/plasteel, flags = CHANGETURF_INHERIT_AIR)
			balloon_alert(user, "płytki położone")
	else if(istype(target_turf, /turf/open/floor))
		var/turf/open/floor/floor = target_turf
		if(!floor.broken && !floor.burnt)
			balloon_alert(user, "podłoga jest cała")
			return
		floor.broken = FALSE
		floor.burnt = FALSE
		floor.update_icon()
		balloon_alert(user, "podłoga naprawiona")
	else
		return
	playsound(target_turf, 'sound/items/deconstruct.ogg', 40, TRUE)

/// Wspólny omni-tool cyborga (tg „cyborg omnitool”): jedno narzędzie z wyborem trybu w ręce
/obj/item/borg/aquila_omnitool
	name = "omni-tool cyborga"
	desc = "Narzędzie wielofunkcyjne. Użyj w ręce, żeby zmienić tryb."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "multitool_cyborg"
	toolspeed = 0.3
	usesound = 'sound/items/drill_use.ogg'
	/// nazwa trybu => list(zachowanie narzędzia, plik ikony, stan ikony)
	var/list/modes = list()

/obj/item/borg/aquila_omnitool/Initialize(mapload)
	. = ..()
	if(length(modes))
		aq_set_mode(modes[1])

/obj/item/borg/aquila_omnitool/attack_self(mob/user)
	var/list/choices = list()
	for(var/mode in modes)
		var/list/details = modes[mode]
		choices[mode] = image(icon = details[2], icon_state = details[3])
	var/choice = show_radial_menu(user, user, choices, require_near = TRUE, tooltips = TRUE)
	if(!choice || QDELETED(src))
		return
	aq_set_mode(choice)
	balloon_alert(user, "tryb: [choice]")
	playsound(src, 'sound/items/change_jaws.ogg', 40, TRUE)

/obj/item/borg/aquila_omnitool/proc/aq_set_mode(mode)
	var/list/details = modes[mode]
	if(!details)
		return
	tool_behaviour = details[1]
	icon = details[2]
	icon_state = details[3]
	name = "[initial(name)] ([mode])"
	update_icon()

/obj/item/borg/aquila_omnitool/engineering
	name = "omni-tool inżynieryjny"
	desc = "Śrubokręt, klucz, łom i przecinak w jednym, szybszy od zwykłych narzędzi cyborga. Użyj w ręce, żeby zmienić tryb. Multitool zostaje osobno (bufor urządzeń)."
	modes = list(
		"śrubokręt" = list(TOOL_SCREWDRIVER, 'icons/obj/items_cyborg.dmi', "screwdriver_cyborg"),
		"klucz" = list(TOOL_WRENCH, 'icons/obj/items_cyborg.dmi', "wrench_cyborg"),
		"łom" = list(TOOL_CROWBAR, 'icons/obj/items_cyborg.dmi', "crowbar_cyborg"),
		"przecinak" = list(TOOL_WIRECUTTER, 'icons/obj/items_cyborg.dmi', "wirecutters_cyborg"),
	)

/obj/item/borg/aquila_omnitool/surgical
	name = "omni-tool chirurgiczny"
	desc = "Skalpel, hemostat, retraktor, kauter, piła i wiertło w jednym, szybsze od zwykłych narzędzi. Użyj w ręce, żeby zmienić tryb."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "scalpel"
	sharpness = IS_SHARP
	modes = list(
		"skalpel" = list(TOOL_SCALPEL, 'icons/obj/surgery.dmi', "scalpel"),
		"hemostat" = list(TOOL_HEMOSTAT, 'icons/obj/surgery.dmi', "hemostat"),
		"retraktor" = list(TOOL_RETRACTOR, 'icons/obj/surgery.dmi', "retractor"),
		"kauter" = list(TOOL_CAUTERY, 'icons/obj/surgery.dmi', "cautery"),
		"piła" = list(TOOL_SAW, 'icons/obj/surgery.dmi', "saw"),
		"wiertło" = list(TOOL_DRILL, 'icons/obj/surgery.dmi', "drill"),
	)

// ================================================================ Porządki

/// Miotła cyborga (tg „experimental push broom”): zgarnia do 20 przedmiotów z kafelka przed sobą, także w ruchu
/obj/item/borg/push_broom
	name = "eksperymentalna miotła cyborga"
	desc = "Kliknij kafelek, żeby zgarnąć z niego śmieci o kafelek dalej (prosto do kosza, jeśli tam stoi). Użyj w ręce, żeby zamiatać przy każdym kroku."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "broom1"
	/// Czy zamiata w ruchu
	var/sweeping = FALSE
	var/mob/living/sweeper

/obj/item/borg/push_broom/attack_self(mob/user)
	if(sweeping)
		aq_stop_sweeping()
		balloon_alert(user, "przestajesz zamiatać")
		return
	sweeping = TRUE
	sweeper = user
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(aq_on_move))
	balloon_alert(user, "zamiatasz w ruchu")

/obj/item/borg/push_broom/cyborg_unequip(mob/user)
	. = ..()
	aq_stop_sweeping()

/obj/item/borg/push_broom/Destroy()
	aq_stop_sweeping()
	return ..()

/obj/item/borg/push_broom/proc/aq_stop_sweeping()
	if(sweeper)
		UnregisterSignal(sweeper, COMSIG_MOVABLE_MOVED)
	sweeper = null
	sweeping = FALSE

/obj/item/borg/push_broom/proc/aq_on_move(mob/living/source)
	SIGNAL_HANDLER
	aq_sweep(source, get_turf(source))

/obj/item/borg/push_broom/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(proximity_flag)
		aq_sweep(user, get_turf(target))

/// Zgarnia śmieci z kafelka target o kafelek w stronę, w którą patrzy user; zwraca liczbę przesuniętych
/obj/item/borg/push_broom/proc/aq_sweep(mob/user, turf/target)
	. = 0
	if(!target || locate(/obj/structure/table) in target)
		return
	var/movedir = user.dir & ~(UP|DOWN)
	var/turf/next_turf = get_step(target, movedir)
	if(!next_turf)
		return
	var/obj/machinery/disposal/bin/bin = locate(/obj/machinery/disposal/bin) in next_turf
	for(var/obj/item/garbage in target)
		if(garbage.anchored || garbage == src || HAS_TRAIT(garbage, TRAIT_NODROP))
			continue
		if(bin)
			garbage.forceMove(bin)
		else
			garbage.Move(next_turf, movedir)
		.++
		if(. >= 20)
			break
	if(.)
		playsound(user, 'sound/weapons/thudswoosh.ogg', 20, TRUE)

// ================================================================ Ratownictwo

/// Dopalacze ratownika (Aurora „rescue mobility”): szybszy ruch kosztem energii
/obj/item/borg/rescue_boosters
	name = "dopalacze ratownicze"
	desc = "Silniczki w podwoziu cyborga ratowniczego: użyj w ręce, żeby przyspieszyć. Zużywają energię, dopóki są włączone i trzymane."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade2"
	/// Koszt energii co sekundę
	var/charge_per_second = 20
	var/mob/living/silicon/robot/owner

/obj/item/borg/rescue_boosters/attack_self(mob/living/silicon/robot/user)
	if(owner)
		aq_disable()
		balloon_alert(user, "dopalacze wyłączone")
		return
	if(!iscyborg(user) || user.cell?.charge < AQ_BORG_MIN_CHARGE)
		balloon_alert(user, "za mało energii!")
		return
	owner = user
	user.add_movespeed_modifier(MOVESPEED_ID_AQ_RESCUE_BOOSTERS, update = TRUE, priority = 100, multiplicative_slowdown = -1)
	START_PROCESSING(SSobj, src)
	balloon_alert(user, "dopalacze włączone")

/obj/item/borg/rescue_boosters/process(delta_time)
	if(QDELETED(owner) || !(src in owner.held_items) || !owner.aq_use_charge(charge_per_second * delta_time))
		aq_disable()
		return PROCESS_KILL

/obj/item/borg/rescue_boosters/cyborg_unequip(mob/user)
	. = ..()
	aq_disable()

/obj/item/borg/rescue_boosters/Destroy()
	aq_disable()
	return ..()

/obj/item/borg/rescue_boosters/proc/aq_disable()
	STOP_PROCESSING(SSobj, src)
	owner?.remove_movespeed_modifier(MOVESPEED_ID_AQ_RESCUE_BOOSTERS)
	owner = null

/// Rozwieracz drzwi ratownika (Aurora/Eris: łom ratowniczy): podważa śluzy także pod prądem
/obj/item/crowbar/cyborg/aquila_rescue
	name = "hydrauliczny rozwieracz drzwi"
	desc = "Wbudowany rozwieracz hydrauliczny: podważa śluzy, także zasilane (bez zamkniętych rygli i zaspawanych)."
	icon = 'icons/obj/tools.dmi'
	icon_state = "jaws_pry"
	toolspeed = 0.5

/obj/item/crowbar/cyborg/aquila_rescue/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_DOOR_PRYER, REF(src))

/// Holograficzne nosze (Paradise „holo stretcher rack”): rozkłada łóżko z twardego światła
/obj/item/roller/robo/holo
	name = "dok holograficznych noszy"
	desc = "Projektor noszy z twardego światła. Rozłóż je, przypnij rannego i ciągnij; złożone wracają do doku."
	color = "#80D0FF"

/obj/item/roller/robo/holo/Initialize(mapload)
	. = ..()
	if(loaded)
		QDEL_NULL(loaded)
	loaded = new /obj/structure/bed/roller/holo(src)

/obj/structure/bed/roller/holo
	name = "holograficzne nosze"
	desc = "Nosze z twardego światła. Nie da się ich rozebrać, za to szybko się je przenosi."
	color = "#80D0FF"
	alpha = 200
	buildstackamount = 0
	foldabletype = /obj/item/roller/robo/holo

/obj/structure/bed/roller/holo/deconstruct(disassembled)
	qdel(src)

// ================================================================ Ochrona

/// Czy zabójczy tryb broni cyborga jest dozwolony: czerwony alarm lub wyżej, pokład obcego okrętu albo żywi abordażyści na tym samym pokładzie
/proc/aquila_cyborg_lethal_allowed(mob/living/user)
	if(GLOB.security_level >= SEC_LEVEL_RED)
		return TRUE
	if(!user)
		return FALSE
	var/obj/structure/overmap/ship = user.get_overmap()
	if(ship && ship.role != MAIN_OVERMAP && ship.role != MAIN_MINING_SHIP)
		return TRUE // abordaż wrogiego okrętu
	var/turf/here = get_turf(user)
	if(!here)
		return FALSE
	for(var/datum/component/knpc/boarder as anything in GLOB.knpcs)
		var/mob/living/boarder_mob = boarder.parent
		if(istype(boarder_mob) && boarder_mob.stat != DEAD && boarder_mob.z == here.z)
			return TRUE // abordażyści na naszym pokładzie
	return FALSE

/// Broń cyborga z odblokowanym trybem zabójczym (Tegustation „lethal mode unlock”)
/obj/item/gun/energy/e_gun/aquila_cyborg_lethal
	name = "broń energetyczna cyborga"
	desc = "Wbudowana broń energetyczna zasilana z ogniwa cyborga. Tryb zabójczy działa tylko przy czerwonym alarmie albo w trakcie abordażu."
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)
	can_flashlight = FALSE
	can_charge = FALSE
	use_cyborg_cell = TRUE
	requires_wielding = FALSE

/obj/item/gun/energy/e_gun/aquila_cyborg_lethal/proc/aq_lethal_selected()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	return ispath(shot.projectile_type, /obj/item/projectile/beam/laser)

/obj/item/gun/energy/e_gun/aquila_cyborg_lethal/select_fire(mob/living/user)
	. = ..()
	if(aq_lethal_selected() && !aquila_cyborg_lethal_allowed(user))
		..() // z powrotem na obezwładnianie
		to_chat(user, "<span class='warning'>Tryb zabójczy jest zablokowany: potrzebny czerwony alarm albo abordaż.</span>")

/obj/item/gun/energy/e_gun/aquila_cyborg_lethal/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(aq_lethal_selected() && !aquila_cyborg_lethal_allowed(user))
		select_fire(user)
		to_chat(user, "<span class='warning'>Alarm odwołany: broń wraca do trybu obezwładniającego.</span>")
		return FALSE
	return ..()

/// Glock-13BR cyborga ochrony (NSV): ostra amunicja tylko wtedy, gdy wolno broni z trybem zabójczym (czerwony alarm albo abordaż).
/// Zhakowany cyborg strzela ostrą bez ograniczeń.
/obj/item/gun/energy/printer/glock
	desc = "Wbudowany pistolet 9 mm dla cyborgów ochrony Nanotrasen. Ostra amunicja działa tylko przy czerwonym alarmie albo w trakcie abordażu, poza tym strzela gumowymi kulami."

/obj/item/gun/energy/printer/glock/proc/aq_lethal_selected()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	return !ispath(shot.projectile_type, /obj/item/projectile/bullet/c9mm/rubber)

/obj/item/gun/energy/printer/glock/proc/aq_lethal_blocked(mob/living/user)
	if(!aq_lethal_selected())
		return FALSE
	if(iscyborg(user))
		var/mob/living/silicon/robot/cyborg = user
		if(cyborg.emagged)
			return FALSE
	return !aquila_cyborg_lethal_allowed(user)

/obj/item/gun/energy/printer/glock/select_fire(mob/living/user)
	. = ..()
	if(aq_lethal_blocked(user))
		..() // z powrotem na gumowe kule
		to_chat(user, "<span class='warning'>Ostra amunicja jest zablokowana: potrzebny czerwony alarm albo abordaż.</span>")

/obj/item/gun/energy/printer/glock/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0, aimed = FALSE)
	if(aq_lethal_blocked(user))
		select_fire(user)
		to_chat(user, "<span class='warning'>Alarm odwołany: pistolet wraca do gumowych kul.</span>")
		return FALSE
	return ..()

/// Pocisk wyrzutni bol (Tegustation „energy bola launcher”), na naszej boli energetycznej cyborga
/obj/item/ammo_casing/energy/aquila_bola
	projectile_type = /obj/item/projectile/energy/trap/cyborg
	select_name = "bola"
	e_cost = 300
	harmful = FALSE
	fire_sound = 'sound/weapons/taser.ogg'

/obj/item/gun/energy/aquila_bola_launcher
	name = "wyrzutnia bol energetycznych"
	desc = "Wbudowana wyrzutnia bol z twardego światła: spowalnia i oplątuje uciekającego. Zasilana z ogniwa cyborga."
	icon_state = "dragnet"
	item_state = "dragnet"
	ammo_type = list(/obj/item/ammo_casing/energy/aquila_bola)
	can_flashlight = FALSE
	can_charge = FALSE
	use_cyborg_cell = TRUE
	requires_wielding = FALSE
	fire_delay = 10

/// Skaner akt (Goonstation Brobocop „prisoner scanner”): status z akt ochrony, wyroki i mandaty
/obj/item/borg/record_scanner
	name = "skaner akt"
	desc = "Kliknij nim osobę, żeby sprawdzić jej status w aktach ochrony, zarzuty i mandaty."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-blue"
	item_flags = NOBLUDGEON

/obj/item/borg/record_scanner/attack(mob/living/carbon/human/target, mob/living/user)
	if(!istype(target))
		return ..()
	aq_scan(user, target)

/obj/item/borg/record_scanner/proc/aq_scan(mob/living/user, mob/living/carbon/human/target)
	var/name_on_id = target.get_face_name(target.get_id_name(""))
	if(!name_on_id || name_on_id == "Unknown" || name_on_id == "Nieznany")
		to_chat(user, "<span class='warning'>Nie da się ustalić tożsamości [target].</span>")
		return
	var/datum/data/record/record = find_record("name", name_on_id, GLOB.data_core.security)
	user.visible_message("<span class='notice'>[user] skanuje [target].</span>")
	if(!record)
		to_chat(user, "<span class='notice'>[name_on_id]: brak akt ochrony.</span>")
		return
	var/list/lines = list("<b>[name_on_id]</b>: status <b>[record.fields["criminal"]]</b>")
	for(var/datum/data/crime/crime in record.fields["crim"])
		lines += "Zarzut: [crime.crimeName] ([crime.crimeDetails])"
	for(var/datum/data/crime/citation in record.fields["citation"])
		lines += "Mandat: [citation.crimeName], [citation.fine] kr"
	to_chat(user, examine_block(jointext(lines, "\n")))
	return record

/// Citationinator cyborga: dostęp ma z modułu, mandat drukuje pod sobą
/obj/item/citationinator/cyborg
	access_check_skipped = TRUE

/obj/item/citationinator/cyborg/emag_act(mob/user)
	return

// ================================================================ Biuro, kuchnia, śledztwo

/// Drukarka papieru (Bay „form printer”): papier z tonera cyborga
/obj/item/borg/paper_dispenser
	name = "drukarka papieru"
	desc = "Drukuje czysty arkusz papieru z tonera cyborga. Użyj w ręce."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin1"
	/// Ile tonera kosztuje arkusz
	var/toner_cost = 1

/obj/item/borg/paper_dispenser/attack_self(mob/living/silicon/robot/user)
	if(!iscyborg(user))
		return
	if(user.toner < toner_cost)
		balloon_alert(user, "brak tonera!")
		return
	user.toner -= toner_cost
	new /obj/item/paper(get_turf(user))
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)

/// Książka kucharska cyborga (tg „Codex Cibus Mechanicus”): otwiera nasz katalog przepisów z tabletu cyborga
/obj/item/borg/cookbook
	name = "Codex Cibus Mechanicus"
	desc = "Wbudowana książka kucharska. Użyj w ręce, żeby otworzyć katalog przepisów."
	icon = 'icons/obj/library.dmi'
	icon_state = "cooked_book"

/obj/item/borg/cookbook/attack_self(mob/living/silicon/robot/user)
	if(!iscyborg(user) || !user.modularInterface)
		return
	var/obj/item/computer_hardware/hard_drive/drive = user.modularInterface.all_components[MC_HDD]
	var/datum/computer_file/program/cookbook/program = drive?.find_file_by_name("kucharz")
	if(!program)
		to_chat(user, "<span class='warning'>Na tablecie brakuje programu „Książka kucharska”.</span>")
		return
	user.modularInterface.open_program(user, program)
	user.modularInterface.interact(user)

/// Spray z luminolem cyborga (nasz luminol z aquila/code/modules/detectivework/luminol.dm)
/obj/item/reagent_containers/spray/cyborg/luminol
	name = "spray z luminolem"
	desc = "Spray z luminolem do szukania zmytej krwi; uzupełnia się z ogniwa cyborga."
	color = "#B0E0FF"
	set_reagent = /datum/reagent/luminol

// ================================================================ Logistyka i górnictwo

/// Teleporter ładunku (Skyrat „cargo teleporter”): wysyła skrzynię albo szafkę na postawiony wcześniej znacznik
/obj/item/borg/cargo_teleporter
	name = "teleporter ładunku"
	desc = "Użyj w ręce, żeby ustawić cel w miejscu, gdzie stoisz. Kliknij skrzynię albo szafkę obok siebie, żeby wysłać ją do celu."
	icon = 'icons/obj/device.dmi'
	icon_state = "hand_tele"
	item_flags = NOBLUDGEON
	/// Kafelek celu
	var/datum/weakref/destination
	/// Koszt energii wysyłki
	var/charge_cost = 2000
	COOLDOWN_DECLARE(teleport_cooldown)

/obj/item/borg/cargo_teleporter/attack_self(mob/user)
	var/turf/here = get_turf(user)
	if(!here)
		return
	destination = WEAKREF(here)
	balloon_alert(user, "cel ustawiony")
	to_chat(user, "<span class='notice'>Cel teleportera: [get_area_name(here, TRUE)].</span>")

/obj/item/borg/cargo_teleporter/afterattack(atom/target, mob/living/silicon/robot/user, proximity_flag)
	. = ..()
	if(!proximity_flag || !iscyborg(user) || !istype(target, /obj/structure/closet))
		return
	aq_send(user, target)

/// Wysyła szafkę; zwraca TRUE przy powodzeniu
/obj/item/borg/cargo_teleporter/proc/aq_send(mob/living/silicon/robot/user, obj/structure/closet/crate)
	var/turf/target_turf = destination?.resolve()
	if(!target_turf)
		balloon_alert(user, "najpierw ustaw cel!")
		return FALSE
	if(!COOLDOWN_FINISHED(src, teleport_cooldown))
		balloon_alert(user, "ładowanie: [DisplayTimeText(COOLDOWN_TIMELEFT(src, teleport_cooldown))]")
		return FALSE
	if(crate.anchored)
		balloon_alert(user, "przykręcone!")
		return FALSE
	for(var/mob/living/stowaway in crate.GetAllContents())
		balloon_alert(user, "w środku ktoś jest!")
		return FALSE
	if(!user.aq_use_charge(charge_cost))
		balloon_alert(user, "za mało energii!")
		return FALSE
	do_sparks(3, TRUE, crate)
	crate.forceMove(target_turf)
	do_sparks(3, TRUE, crate)
	COOLDOWN_START(src, teleport_cooldown, 60 SECONDS)
	playsound(target_turf, 'sound/weapons/emitter2.ogg', 40, TRUE)
	return TRUE

/// Przenośna huta (/vg/station „portable ore processor”): przetapia rudę z torby cyborga w sztabki
/obj/item/borg/ore_processor
	name = "przenośna huta"
	desc = "Użyj w ręce, żeby przetopić rudę z torby na rudę w sztabki, wolniej niż huta i kosztem energii."
	icon = 'icons/obj/mining.dmi'
	icon_state = "crusher_lit"
	/// Koszt energii jednej rudy
	var/charge_per_ore = 50
	/// Ile rudy najwyżej naraz
	var/max_per_use = 50
	var/busy = FALSE

/obj/item/borg/ore_processor/attack_self(mob/living/silicon/robot/user)
	if(!iscyborg(user) || busy)
		return
	busy = TRUE
	var/smelted = aq_smelt(user)
	busy = FALSE
	if(smelted)
		balloon_alert(user, "przetopiono: [smelted]")
	else
		balloon_alert(user, "brak rudy do przetopienia")

/// Przetapia rudę z torby, zwraca liczbę przetopionych sztuk
/obj/item/borg/ore_processor/proc/aq_smelt(mob/living/silicon/robot/user)
	. = 0
	var/obj/item/storage/bag/ore/bag = user.aq_find_module_item(/obj/item/storage/bag/ore)
	if(!bag)
		return
	var/turf/drop = get_turf(user)
	for(var/obj/item/stack/ore/ore in bag.contents)
		if(!ore.refined_type)
			continue
		var/amount = min(ore.amount, max_per_use - .)
		if(amount <= 0)
			break
		var/affordable = round(max(0, user.cell.charge - AQ_BORG_MIN_CHARGE) / charge_per_ore)
		amount = min(amount, affordable)
		if(amount <= 0)
			break
		user.cell.use(amount * charge_per_ore)
		new ore.refined_type(drop, amount)
		ore.use(amount)
		. += amount
	if(.)
		playsound(src, 'sound/machines/ding.ogg', 30, TRUE)

/// Plazmowy przecinak zaawansowany cyborga (Citadel/Yog „advanced plasma cutter”)
/obj/item/gun/energy/plasmacutter/adv/cyborg
	name = "zaawansowany przecinak plazmowy cyborga"
	desc = "Wbudowany zaawansowany przecinak plazmowy: większy zasięg i obrażenia dla fauny."
	dead_cell = FALSE
	can_charge = FALSE
	use_cyborg_cell = TRUE
	tool_behaviour = null
	requires_wielding = FALSE
