// AQUILA - narzędzia mechów (źródła w opisach). Działają na mechach roboczych i bojowych, chyba że opis mówi inaczej.

/obj/item/mecha_parts/mecha_equipment/aq_tool
	name = "narzędzie egzoszkieletu"
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "mecha_equip"
	range = MECHA_MELEE
	aq_slot = AQ_MECHA_SLOT_ARM
	mech_flags = EXOSUIT_MODULE_RIPLEY | EXOSUIT_MODULE_COMBAT | EXOSUIT_MODULE_MEDICAL

// ---------------------------------------------------------------- chwytak Paddy
/obj/item/mecha_parts/mecha_equipment/aq_tool/paddy_claw
	name = "chwytak hydrauliczny Paddy"
	desc = "Chwytak dla ludzi (tg): łapie zatrzymanego, zakłada mu opaski i, jeśli w mechu jest wolna cela, od razu go tam wkłada. Pasuje tylko do Paddy."
	icon_state = "paddy_claw"
	equip_cooldown = 20
	energy_drain = 20
	harmful = FALSE

/obj/item/mecha_parts/mecha_equipment/aq_tool/paddy_claw/can_attach(obj/mecha/M)
	if(!istype(M, /obj/mecha/working/ripley/aq_paddy))
		return FALSE
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_tool/paddy_claw/action(atom/target, params)
	if(!action_checks(target) || !iscarbon(target) || !chassis.Adjacent(target))
		return 0
	var/mob/living/carbon/C = target
	chassis.visible_message("<span class='danger'>[chassis] chwyta [C] hydraulicznym chwytakiem!</span>")
	if(!do_after_mecha(C, 2 SECONDS))
		return 0
	if(!C.handcuffed && C.canBeHandcuffed())
		C.handcuffed = new /obj/item/restraints/handcuffs/cable/zipties/used(C)
		C.update_handcuffed()
		log_combat(chassis.occupant, C, "handcuffed", src)
		playsound(C, 'sound/weapons/cablecuff.ogg', 40, TRUE)
	var/obj/item/mecha_parts/mecha_equipment/aq_utility/carrier/jail_cell/cell = locate() in chassis.equipment
	if(cell?.load(C))
		chassis.visible_message("<span class='danger'>[chassis] wkłada [C] do celi.</span>")
	return 1

// ---------------------------------------------------------------- zestaw narzędzi i palnik
/obj/item/mecha_parts/mecha_equipment/aq_tool/toolset
	name = "zestaw narzędzi inżynieryjnych egzoszkieletu"
	desc = "Łom, śrubokręt, klucz, przecinak i multitool w jednym module (SS220). Mech inżynierski naprawia instalacje bez wysiadania. Narzędzie wybiera się w oknie mecha."
	icon_state = "aq_toolset"
	equip_cooldown = 5
	energy_drain = 5
	var/list/obj/item/tools = list()
	var/obj/item/current

/obj/item/mecha_parts/mecha_equipment/aq_tool/toolset/Initialize(mapload)
	. = ..()
	for(var/path in list(/obj/item/crowbar/cyborg, /obj/item/screwdriver/cyborg, /obj/item/wrench/cyborg, /obj/item/wirecutters/cyborg, /obj/item/multitool))
		tools += new path(src)
	current = tools[1]
	for(var/obj/item/T as anything in tools)
		ADD_TRAIT(T, TRAIT_NODROP, REF(src))

/obj/item/mecha_parts/mecha_equipment/aq_tool/toolset/Destroy()
	for(var/obj/item/T as anything in tools)
		if(T.loc == src)
			qdel(T)
	tools.Cut()
	current = null
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_tool/toolset/get_equip_info()
	return "[..()] - <a href='byond://?src=[REF(src)];aq_next=1'>[current?.name]</a>"

/obj/item/mecha_parts/mecha_equipment/aq_tool/toolset/Topic(href, href_list)
	..()
	if(href_list["aq_next"])
		var/i = tools.Find(current)
		current = tools[(i % length(tools)) + 1]
		occupant_message("Wybrane narzędzie: [current.name].")
		SStgui.update_uis(chassis)

/obj/item/mecha_parts/mecha_equipment/aq_tool/toolset/action(atom/target, params)
	if(!action_checks(target) || !chassis.Adjacent(target) || !current)
		return 0
	var/mob/living/user = chassis.occupant
	if(!(current.tool_behaviour && target.tool_act(user, current, current.tool_behaviour)))
		target.attackby(current, user, params)
	reclaim_tools()
	return 1

/// Narzędzie zostaje w module, nawet jeśli cel próbował je zabrać (stół, szafka, schowek)
/obj/item/mecha_parts/mecha_equipment/aq_tool/toolset/proc/reclaim_tools()
	for(var/obj/item/T as anything in tools.Copy())
		if(QDELETED(T))
			tools -= T
		else if(T.loc != src)
			T.forceMove(src)
	if(!(current in tools))
		current = length(tools) ? tools[1] : null

/obj/item/mecha_parts/mecha_equipment/aq_tool/toolset/torch
	name = "palnik inżynieryjny Atlas"
	desc = "Palnik spawalniczy mecha (Nova Sector) zasilany z ogniwa: spawa i tnie płyty, łata kadłub obok piany kadłubowej."
	icon_state = "aq_torch"
	energy_drain = 15

/obj/item/mecha_parts/mecha_equipment/aq_tool/toolset/torch/Initialize(mapload)
	. = ..()
	QDEL_LIST(tools)
	var/obj/item/weldingtool/experimental/W = new(src)
	W.switched_on()
	ADD_TRAIT(W, TRAIT_NODROP, REF(src))
	tools += W
	current = W

/obj/item/mecha_parts/mecha_equipment/aq_tool/toolset/torch/action(atom/target, params)
	var/obj/item/weldingtool/W = current
	if(istype(W))
		W.reagents?.add_reagent(/datum/reagent/fuel, W.max_fuel)
		if(!W.welding)
			W.switched_on()
	return ..()

// ---------------------------------------------------------------- atmosfera
/obj/item/mecha_parts/mecha_equipment/aq_tool/atmos
	name = "moduł atmosferyczny egzoszkieletu"
	desc = "Analizator gazów i pompa (SS220). Klik w pole bada atmosferę; w trybie pompy uzupełnia pole powietrzem ze zbiornika mecha albo wypompowuje je do zbiornika."
	icon_state = "aq_atmos"
	range = MECHA_MELEE | MECHA_RANGED
	equip_cooldown = 10
	energy_drain = 20
	/// 0 = analiza, 1 = napełnianie, 2 = wypompowywanie
	var/mode = 0

/obj/item/mecha_parts/mecha_equipment/aq_tool/atmos/get_equip_info()
	var/list/names = list("analiza", "napełnianie", "wypompowywanie")
	return "[..()] - <a href='byond://?src=[REF(src)];aq_mode=1'>[names[mode + 1]]</a>"

/obj/item/mecha_parts/mecha_equipment/aq_tool/atmos/Topic(href, href_list)
	..()
	if(href_list["aq_mode"])
		mode = (mode + 1) % 3
		SStgui.update_uis(chassis)

/obj/item/mecha_parts/mecha_equipment/aq_tool/atmos/action(atom/target, params)
	if(!action_checks(target))
		return 0
	var/turf/open/T = get_turf(target)
	if(!istype(T) || get_dist(chassis, T) > 3)
		return 0
	switch(mode)
		if(0)
			atmosanalyzer_scan(chassis.occupant, T)
		if(1)
			var/datum/gas_mixture/tank = chassis.internal_tank?.return_air()
			if(!tank || tank.total_moles() <= 0)
				occupant_message("<span class='warning'>Zbiornik powietrza mecha jest pusty.</span>")
				return 0
			T.assume_air(tank.remove_ratio(0.1))
			T.air_update_turf()
			occupant_message("<span class='notice'>Wypuszczasz powietrze ze zbiornika na pole.</span>")
		if(2)
			var/obj/machinery/portable_atmospherics/canister/C = chassis.internal_tank
			if(!C)
				return 0
			var/datum/gas_mixture/removed = T.remove_air_ratio(0.5)
			var/datum/gas_mixture/tank_air = C.return_air()
			if(removed && tank_air)
				tank_air.merge(removed)
			T.air_update_turf()
			occupant_message("<span class='notice'>Wypompowujesz powietrze z pola do zbiornika.</span>")
	return 1

// ---------------------------------------------------------------- RPD
/obj/item/pipe_dispenser/aq_mech
	name = "zamontowany dyspenser rur"

/obj/item/pipe_dispenser/aq_mech/ui_state(mob/user)
	return GLOB.always_state

/obj/item/mecha_parts/mecha_equipment/aq_tool/rpd
	name = "montowany dyspenser rur egzoszkieletu"
	desc = "Dyspenser rur (Yogstation) zamontowany w ramieniu: szybka naprawa rur atmosfery i kanalizacji. Rodzaj rury wybiera się w oknie dyspensera."
	icon_state = "mecha_pipe_dispenser"
	range = MECHA_MELEE | MECHA_RANGED
	equip_cooldown = 5
	energy_drain = 15
	var/obj/item/pipe_dispenser/aq_mech/rpd

/obj/item/mecha_parts/mecha_equipment/aq_tool/rpd/Initialize(mapload)
	. = ..()
	rpd = new(src)

/obj/item/mecha_parts/mecha_equipment/aq_tool/rpd/Destroy()
	QDEL_NULL(rpd)
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_tool/rpd/get_equip_info()
	return "[..()] - <a href='byond://?src=[REF(src)];aq_menu=1'>ustawienia</a>"

/obj/item/mecha_parts/mecha_equipment/aq_tool/rpd/Topic(href, href_list)
	..()
	if(href_list["aq_menu"] && chassis?.occupant)
		rpd.ui_interact(chassis.occupant)

/obj/item/mecha_parts/mecha_equipment/aq_tool/rpd/action(atom/target, params)
	if(!action_checks(target) || get_dist(chassis, target) > 3)
		return 0
	INVOKE_ASYNC(rpd, TYPE_PROC_REF(/obj/item, pre_attack), target, chassis.occupant)
	return 1

// ---------------------------------------------------------------- szczęki ratownicze, wyłom
/obj/item/mecha_parts/mecha_equipment/aq_tool/rescue_jaw
	name = "szczęki ratownicze egzoszkieletu"
	desc = "Hydrauliczne szczęki (Paradise, Hypatia) rozwierające drzwi bez zasilania. Ratunek po wyłomach i wejście na wraki oraz opuszczone stacje."
	icon_state = "aq_rescue_jaw"
	equip_cooldown = 15
	energy_drain = 40

/obj/item/mecha_parts/mecha_equipment/aq_tool/rescue_jaw/action(atom/target, params)
	if(!action_checks(target) || !chassis.Adjacent(target))
		return 0
	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target
		if(A.locked || A.welded)
			occupant_message("<span class='warning'>[A] jest zaryglowany albo zaspawany.</span>")
			return 0
		if(A.hasPower())
			occupant_message("<span class='warning'>Silniki zasilanej śluzy [A] nie dają się rozewrzeć szczękami.</span>")
			return 0
		playsound(chassis, 'sound/machines/airlock_alien_prying.ogg', 60, TRUE)
		if(!do_after_mecha(A, 3 SECONDS) || A.hasPower() || A.locked || A.welded)
			return 0
		if(A.density)
			INVOKE_ASYNC(A, TYPE_PROC_REF(/obj/machinery/door/airlock, open), 2)
		else
			INVOKE_ASYNC(A, TYPE_PROC_REF(/obj/machinery/door/airlock, close), 2)
		return 1
	if(istype(target, /obj/machinery/door/firedoor))
		var/obj/machinery/door/firedoor/F = target
		if(F.welded)
			occupant_message("<span class='warning'>[F] jest zaspawany.</span>")
			return 0
		if(!do_after_mecha(F, 2 SECONDS) || F.welded || F.operating)
			return 0
		INVOKE_ASYNC(F, F.density ? TYPE_PROC_REF(/obj/machinery/door, open) : TYPE_PROC_REF(/obj/machinery/door, close))
		return 1
	return 0

/obj/item/mecha_parts/mecha_equipment/aq_tool/entry_device
	name = "ładunek wejścia siłowego"
	desc = "Moduł z podów (Goonstation): przykłada ładunek kierunkowy do drzwi albo okna przed mechem i po chwili wysadza je. Trzy ładunki, uzupełniane z ogniwa."
	icon_state = "aq_entry_device"
	equip_cooldown = 60
	energy_drain = 800
	harmful = TRUE
	var/charges = 3

/obj/item/mecha_parts/mecha_equipment/aq_tool/entry_device/get_equip_info()
	return "[..()] \[[charges]\][charges < 3 ? " - <a href='byond://?src=[REF(src)];aq_recharge=1'>naładuj</a>" : ""]"

/obj/item/mecha_parts/mecha_equipment/aq_tool/entry_device/Topic(href, href_list)
	..()
	if(href_list["aq_recharge"] && chassis?.has_charge(energy_drain))
		chassis.use_power(energy_drain)
		charges = min(3, charges + 1)
		SStgui.update_uis(chassis)

/obj/item/mecha_parts/mecha_equipment/aq_tool/entry_device/action(atom/target, params)
	if(!action_checks(target) || !chassis.Adjacent(target) || charges <= 0)
		return 0
	// tylko drzwi i okna (opis modułu): ścian ładunek nie rozbiera
	if(!istype(target, /obj/machinery/door) && !istype(target, /obj/structure/window) && !istype(target, /obj/structure/grille))
		return 0
	charges--
	chassis.visible_message("<span class='danger'>[chassis] przykłada ładunek do [target]!</span>")
	playsound(target, 'sound/weapons/armbomb.ogg', 60, TRUE)
	addtimer(CALLBACK(src, PROC_REF(blow), target), 3 SECONDS)
	log_combat(chassis.occupant, target, "planted a breaching charge on", src)
	return 1

/obj/item/mecha_parts/mecha_equipment/aq_tool/entry_device/proc/blow(atom/target)
	if(QDELETED(target))
		return
	var/turf/T = get_turf(target)
	if(isobj(target))
		var/obj/O = target
		O.take_damage(1000, BRUTE, "bomb", FALSE)
	explosion(T, -1, -1, 1, flash_range = 2)

// ---------------------------------------------------------------- dmuchane ściany i osłony
/obj/item/mecha_parts/mecha_equipment/aq_tool/inflatables
	name = "dozownik dmuchanych przegród egzoszkieletu"
	desc = "Rozkłada dmuchane ściany (Polaris): szybkie zatykanie wyłomów w kadłubie. Zapas uzupełnia się z ogniwa."
	icon_state = "aq_inflatables"
	range = MECHA_MELEE | MECHA_RANGED
	equip_cooldown = 15
	energy_drain = 100
	var/stock = 10

/obj/item/mecha_parts/mecha_equipment/aq_tool/inflatables/get_equip_info()
	return "[..()] \[[stock]\][stock < initial(stock) ? " - <a href='byond://?src=[REF(src)];aq_recharge=1'>uzupełnij z ogniwa</a>" : ""]"

/obj/item/mecha_parts/mecha_equipment/aq_tool/inflatables/Topic(href, href_list)
	..()
	if(href_list["aq_recharge"] && chassis)
		if(stock < initial(stock) && !rearm())
			occupant_message("<span class='warning'>Za mało energii w ogniwie, żeby uzupełnić przegrody.</span>")
		SStgui.update_uis(chassis)

/obj/item/mecha_parts/mecha_equipment/aq_tool/inflatables/action(atom/target, params)
	if(!action_checks(target))
		return 0
	var/turf/open/T = get_turf(target)
	if(!istype(T) || get_dist(chassis, T) > 2 || T.density)
		return 0
	if(locate(/obj/structure/inflatable) in T)
		return 0
	for(var/atom/movable/AM in T)
		if(AM.density)
			return 0
	if(stock <= 0)
		occupant_message("<span class='warning'>Zapas przegród się skończył.</span>")
		return 0
	stock--
	new /obj/structure/inflatable(T)
	playsound(T, 'sound/items/zip.ogg', 50, TRUE)
	return 1

/obj/item/mecha_parts/mecha_equipment/aq_tool/inflatables/rearm()
	if(stock < initial(stock) && chassis?.has_charge(500))
		chassis.use_power(500)
		stock = initial(stock)
		return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/aq_tool/inflatables/needs_rearm()
	return stock <= 0

/obj/item/mecha_parts/mecha_equipment/aq_tool/dropwall
	name = "\improper wyrzutnia osłon DWDL-04"
	desc = "Wystrzeliwuje rozkładaną osłonę (Paradise), która przez dwie minuty zatrzymuje pociski lecące z jednej strony. Osłona dla piechoty przy abordażu."
	icon_state = "aq_dropwall"
	range = MECHA_MELEE | MECHA_RANGED
	equip_cooldown = 100
	energy_drain = 1000

/obj/item/mecha_parts/mecha_equipment/aq_tool/dropwall/action(atom/target, params)
	if(!action_checks(target))
		return 0
	var/turf/T = get_turf(target)
	if(!isopenturf(T) || get_dist(chassis, T) > 4)
		return 0
	var/obj/structure/aq_dropwall/W = new(T)
	W.setDir(chassis.dir)
	playsound(T, 'sound/effects/bamf.ogg', 50, TRUE)
	return 1

/obj/structure/aq_dropwall
	name = "osłona rozkładana"
	desc = "Energetyczna osłona zatrzymująca pociski lecące z przodu. Po dwóch minutach się wyczerpuje."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-old"
	anchored = TRUE
	density = FALSE
	max_integrity = 200
	layer = ABOVE_MOB_LAYER

/obj/structure/aq_dropwall/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 2 MINUTES)

/obj/structure/aq_dropwall/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(istype(mover, /obj/item/projectile))
		// pocisk lecący w stronę, w którą osłona patrzy z przodu (czyli od wroga), zatrzymuje się
		if(get_dir(loc, mover.loc) & dir)
			return FALSE
	return TRUE

// ---------------------------------------------------------------- ładunki
/obj/item/mecha_parts/mecha_equipment/aq_tool/forklift
	name = "widły egzoszkieletu"
	desc = "Widły (CEV Eris) podnoszące skrzynię, maszynę albo kanister, nawet przykręcone. Na raz unosi jeden ładunek; klik w puste pole go odkłada."
	icon_state = "aq_forklift"
	equip_cooldown = 15
	energy_drain = 20
	var/obj/load
	/// Trwa podnoszenie (do_after): drugie kliknięcie nie zaczyna kolejnego
	var/busy = FALSE

/obj/item/mecha_parts/mecha_equipment/aq_tool/forklift/Destroy()
	if(load)
		load.forceMove(get_turf(src))
		load = null
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_tool/forklift/detach(atom/moveto)
	if(load)
		load.forceMove(get_turf(chassis || src))
		load = null
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_tool/forklift/get_equip_info()
	return "[..()] [load ? "\[[load.name]\]" : "\[pusto\]"]"

/obj/item/mecha_parts/mecha_equipment/aq_tool/forklift/action(atom/target, params)
	if(!action_checks(target) || !chassis.Adjacent(target))
		return 0
	if(load)
		var/turf/T = get_turf(target)
		if(!isopenturf(T) || T.density)
			return 0
		for(var/atom/movable/AM in T)
			if(AM.density)
				return 0
		load.forceMove(T)
		occupant_message("<span class='notice'>Odkładasz [load].</span>")
		load = null
		return 1
	if(!(istype(target, /obj/structure/closet) || istype(target, /obj/machinery) || istype(target, /obj/structure/ore_box) || istype(target, /obj/structure/reagent_dispensers)))
		return 0
	var/obj/O = target
	if(istype(O, /obj/machinery/computer) || istype(O, /obj/machinery/door) || O.resistance_flags & INDESTRUCTIBLE)
		return 0
	// maszyny podpięte do instalacji (atmosfera, APC, terminale) zostają na miejscu
	if(O.move_resist > MOVE_FORCE_STRONG || istype(O, /obj/machinery/power/apc) || istype(O, /obj/machinery/power/terminal))
		occupant_message("<span class='warning'>[O] jest na stałe podpięty do instalacji, widły go nie ruszą.</span>")
		return 0
	if(busy)
		return 0
	busy = TRUE
	var/lifted = do_after_mecha(O, 2 SECONDS)
	busy = FALSE
	if(!lifted || load || QDELETED(O) || !chassis.Adjacent(O))
		return 0
	load = O
	O.forceMove(src)
	occupant_message("<span class='notice'>Unosisz [O] na widłach.</span>")
	return 1

/obj/item/mecha_parts/mecha_equipment/aq_towing_hook
	name = "hak holowniczy egzoszkieletu"
	desc = "Hak (CEV Eris) ciągnący za mechem skrzynię, maszynę, wrak albo inny mech. Zaczepia się przyciskiem w oknie mecha o obiekt obok."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "aq_towing"
	selectable = FALSE
	aq_slot = AQ_MECHA_UTILITY
	var/atom/movable/towed

/obj/item/mecha_parts/mecha_equipment/aq_towing_hook/get_equip_info()
	return "[..()] - <a href='byond://?src=[REF(src)];aq_tow=1'>[towed ? "odczep [towed.name]" : "zaczep"]</a>"

/obj/item/mecha_parts/mecha_equipment/aq_towing_hook/Topic(href, href_list)
	..()
	if(!href_list["aq_tow"] || !chassis)
		return
	if(towed)
		release()
	else
		for(var/atom/movable/AM in orange(1, chassis))
			if(AM.anchored || isliving(AM) || isitem(AM) || iseffect(AM))
				continue
			if(!(isstructure(AM) || ismachinery(AM) || ismecha(AM)))
				continue
			towed = AM
			RegisterSignal(chassis, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
			occupant_message("<span class='notice'>Zaczepiasz hak o [AM].</span>")
			break
	SStgui.update_uis(chassis)

/obj/item/mecha_parts/mecha_equipment/aq_towing_hook/proc/release()
	if(chassis)
		UnregisterSignal(chassis, COMSIG_MOVABLE_MOVED)
	towed = null

/obj/item/mecha_parts/mecha_equipment/aq_towing_hook/proc/on_move(obj/mecha/source, atom/oldloc)
	SIGNAL_HANDLER
	if(QDELETED(towed) || towed.anchored || get_dist(towed, oldloc) > 2)
		release()
		return
	towed.Move(oldloc)

/obj/item/mecha_parts/mecha_equipment/aq_towing_hook/detach(atom/moveto)
	release()
	return ..()

// ---------------------------------------------------------------- sprzątanie
/obj/item/mecha_parts/mecha_equipment/aq_tool/super_spray
	name = "\improper spryskiwacz JS-33"
	desc = "Spryskiwacz mecha woźnego (Paradise): zmywa brud na trzech polach przed mechem. Para do mega mopa."
	icon_state = "mecha_washer"
	range = MECHA_MELEE | MECHA_RANGED
	equip_cooldown = 10
	energy_drain = 15

/obj/item/mecha_parts/mecha_equipment/aq_tool/super_spray/action(atom/target, params)
	if(!action_checks(target))
		return 0
	playsound(chassis, 'sound/effects/spray2.ogg', 50, TRUE)
	var/list/turfs = getline(chassis, target)
	var/count = 0
	for(var/turf/T in turfs)
		if(T == get_turf(chassis))
			continue
		if(T.density || count >= 3)
			break
		count++
		SEND_SIGNAL(T, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_STRENGTH_BLOOD)
		for(var/obj/effect/decal/cleanable/C in T)
			qdel(C)
		for(var/mob/living/L in T)
			L.ExtinguishMob()
	return 1

// ---------------------------------------------------------------- górnictwo
/obj/item/mecha_parts/mecha_equipment/aq_ore_summoner
	name = "przywoływacz rudy egzoszkieletu"
	desc = "Magnetyczny przywoływacz (Aurora): co chwilę ściąga rozrzuconą rudę z okolicy do ładowni Clarke'a albo pod mecha."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "aq_ore_summoner"
	selectable = FALSE
	aq_slot = AQ_MECHA_UTILITY
	energy_drain = 20
	mech_flags = EXOSUIT_MODULE_RIPLEY

/obj/item/mecha_parts/mecha_equipment/aq_ore_summoner/attach(obj/mecha/M)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/aq_ore_summoner/detach(atom/moveto)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_ore_summoner/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_ore_summoner/process(delta_time)
	if(!chassis || chassis.equipment_disabled || !chassis.has_charge(energy_drain))
		return
	var/obj/structure/ore_box/box = chassis.aq_get_ore_box()
	var/moved = 0
	for(var/obj/item/stack/ore/O in range(5, chassis))
		if(!isturf(O.loc))
			continue
		if(box)
			O.forceMove(box)
		else
			O.forceMove(get_turf(chassis))
		if(++moved >= 10)
			break
	if(moved)
		chassis.use_power(energy_drain)

/// Ładownia rudy mecha (Clarke), jeśli jest
/obj/mecha/proc/aq_get_ore_box()
	return null

// ---------------------------------------------------------------- FOBricator i promień ściągający
/obj/item/mecha_parts/mecha_equipment/aq_tool/fobricator
	name = "moduł FOBricator"
	desc = "Buduje z żelaza barykady i umocnienia wysuniętej bazy (Nova Sector). Żelazo ładuje się klikiem w stos arkuszy obok mecha; barykada kosztuje 5 arkuszy."
	icon_state = "aq_fobricator"
	range = MECHA_MELEE | MECHA_RANGED
	equip_cooldown = 20
	energy_drain = 50
	var/iron = 0
	var/max_iron = 100
	/// Trwa budowa (do_after): drugie kliknięcie nie zaczyna kolejnej
	var/busy = FALSE

/obj/item/mecha_parts/mecha_equipment/aq_tool/fobricator/get_equip_info()
	return "[..()] \[żelazo: [iron]/[max_iron]\]"

/obj/item/mecha_parts/mecha_equipment/aq_tool/fobricator/action(atom/target, params)
	if(!action_checks(target))
		return 0
	if(istype(target, /obj/item/stack/sheet/iron) && chassis.Adjacent(target))
		var/obj/item/stack/sheet/iron/S = target
		var/n = min(S.amount, max_iron - iron)
		if(n <= 0)
			return 0
		S.use(n)
		iron += n
		occupant_message("<span class='notice'>Ładujesz [n] arkuszy żelaza.</span>")
		return 1
	var/turf/T = get_turf(target)
	if(!isopenturf(T) || get_dist(chassis, T) > 2)
		return 0
	for(var/atom/movable/AM in T)
		if(AM.density)
			return 0
	if(iron < 5)
		occupant_message("<span class='warning'>Za mało żelaza (potrzeba 5).</span>")
		return 0
	if(busy)
		return 0
	busy = TRUE
	var/built = do_after_mecha(T, 2 SECONDS)
	busy = FALSE
	if(!built || iron < 5)
		return 0
	for(var/atom/movable/AM in T)
		if(AM.density)
			return 0
	iron -= 5
	new /obj/structure/barricade/sandbags(T)
	playsound(T, 'sound/items/deconstruct.ogg', 50, TRUE)
	return 1

/obj/item/mecha_parts/mecha_equipment/aq_tool/tractor
	name = "promień ściągający egzoszkieletu"
	desc = "Moduł z podów (Goonstation): przyciąga wskazany przedmiot, skrzynię albo leżącego człowieka do mecha."
	icon_state = "aq_tractor"
	range = MECHA_RANGED
	equip_cooldown = 20
	energy_drain = 60

/obj/item/mecha_parts/mecha_equipment/aq_tool/tractor/action(atom/target, params)
	if(!action_checks(target) || get_dist(chassis, target) > 7)
		return 0
	var/atom/movable/AM = target
	if(!istype(AM) || AM.anchored || ismecha(AM))
		return 0
	if(isliving(AM))
		var/mob/living/L = AM
		if((L.mobility_flags & MOBILITY_STAND) && L.stat == CONSCIOUS)
			occupant_message("<span class='warning'>Promień nie utrzyma stojącego celu.</span>")
			return 0
	AM.throw_at(chassis, get_dist(chassis, AM) - 1, 1, chassis.occupant, FALSE)
	chassis.Beam(AM, icon_state = "nzcrentrs_power", time = 5)
	return 1
