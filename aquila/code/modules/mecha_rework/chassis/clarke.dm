// AQUILA - Clarke: górniczy mech na gąsienicach (port z Yogstation code/game/mecha/working/clarke.dm, ten sam /obj/mecha;
// oryginał tg/Bee). Szybki, ognio- i lawoodporny, słabo opancerzony, z wbudowaną ładownią rud. Gąsienice: przy strafe
// nie jedzie po skosie. Różnice: rudę z pola pod mechem zbiera sam do ładowni (jak torba na rudę), bez akcji szukania ruin z tg.

/obj/mecha/working/aq_clarke
	name = "\improper Clarke"
	desc = "Człowiek i maszyna w jednym, dla lepszego, silniejszego górnika. Wytrzyma nawet lawę. Przez gąsienice nie jedzie bokiem."
	icon = 'aquila/icons/mecha/aq_mecha.dmi'
	icon_state = "clarke"
	max_temperature = 65000
	max_integrity = 250
	step_in = 2
	step_energy_drain = 12
	normal_step_energy_drain = 12
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	lights_power = 7
	deflect_chance = 10
	armor = list("melee" = 25, "bullet" = 10, "laser" = 20, "energy" = 0, "bomb" = 60, "bio" = 0, "rad" = 100, "fire" = 100, "acid" = 100, "stamina" = 0)
	facing_modifiers = list(1.2, 1, 0.8)
	enter_delay = 40
	wreckage = /obj/structure/mecha_wreckage/aq_clarke
	internals_req_access = list(ACCESS_MECH_ENGINE, ACCESS_MECH_SCIENCE, ACCESS_MECH_MINING)
	aq_max_equip_by_category = list(AQ_MECHA_L_ARM = 1, AQ_MECHA_R_ARM = 1, AQ_MECHA_UTILITY = 6, AQ_MECHA_POWER = 1, AQ_MECHA_ARMOR = 1)
	/// Wbudowana ładownia rud
	var/obj/structure/ore_box/box

/obj/mecha/working/aq_clarke/Initialize(mapload)
	. = ..()
	box = new(src)
	var/obj/item/mecha_parts/mecha_equipment/aq_orebox_manager/ME = new(src)
	ME.attach(src)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(collect_ore))

/obj/mecha/working/aq_clarke/Destroy()
	if(box)
		box.dump_box_contents()
		QDEL_NULL(box)
	return ..()

/obj/mecha/working/aq_clarke/Exited(atom/movable/M, atom/newloc)
	if(M == box)
		box = null
	return ..()

/obj/mecha/working/aq_clarke/aq_get_ore_box()
	return box

/obj/mecha/working/aq_clarke/proc/collect_ore()
	SIGNAL_HANDLER
	if(!box || !isturf(loc))
		return
	for(var/obj/item/stack/ore/O in loc)
		O.forceMove(box)

/obj/mecha/working/aq_clarke/domove(direction)
	if(ISDIAGONALDIR(direction) && strafe)
		if(EWCOMPONENT(dir))
			direction &= ~(NORTH|SOUTH)
		else if(NSCOMPONENT(dir))
			direction &= ~(EAST|WEST)
	return ..(direction)

/// Ładownia rud Clarke'a (Yogstation, tg): wbudowana, nie do zdjęcia
/obj/item/mecha_parts/mecha_equipment/aq_orebox_manager
	name = "moduł ładowni rud"
	desc = "Zautomatyzowana ładownia rud Clarke'a."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "mecha_bin"
	selectable = FALSE
	salvageable = FALSE
	detachable = FALSE
	aq_slot = AQ_MECHA_SLOT_NONE

/obj/item/mecha_parts/mecha_equipment/aq_orebox_manager/detach(atom/moveto)
	if(chassis && !QDELETED(chassis))
		return
	return ..()

/obj/item/mecha_parts/mecha_equipment/aq_orebox_manager/get_equip_info()
	var/obj/structure/ore_box/B = chassis?.aq_get_ore_box()
	return "[..()] [B ? "\[rudy: [length(B.contents)]\] - <a href='byond://?src=[REF(src)];aq_dump=1'>wyładuj</a>" : ""]"

/obj/item/mecha_parts/mecha_equipment/aq_orebox_manager/Topic(href, href_list)
	..()
	if(href_list["aq_dump"])
		var/obj/structure/ore_box/B = chassis?.aq_get_ore_box()
		B?.dump_box_contents()
		SStgui.update_uis(chassis)

/obj/structure/mecha_wreckage/aq_clarke
	name = "wrak Clarke'a"
	icon = 'aquila/icons/mecha/aq_mecha.dmi'
	icon_state = "clarke-broken"
	welder_salvage = list(/obj/item/stack/sheet/plasteel, /obj/item/stack/sheet/iron, /obj/item/stack/rods)

// ---------------------------------------------------------------- budowa
/obj/item/mecha_parts/chassis/aq/clarke
	name = "rama Clarke'a"
	construct_type = /datum/component/construction/unordered/mecha_chassis/aq/clarke

/obj/item/mecha_parts/part/aq/clarke_torso
	name = "tors Clarke'a"
	desc = "Tors Clarke'a. Mieści zasilanie, rdzeń obliczeniowy i podtrzymywanie życia."
	icon_state = "clarke_harness"

/obj/item/mecha_parts/part/aq/clarke_head
	name = "głowa Clarke'a"
	desc = "Głowa Clarke'a ze zintegrowanym skanerem diagnostycznym."
	icon_state = "clarke_head"

/obj/item/mecha_parts/part/aq/clarke_left_arm
	name = "lewe ramię Clarke'a"
	desc = "Lewe ramię Clarke'a. Gniazda danych i zasilania pasują do większości narzędzi egzoszkieletów."
	icon_state = "clarke_l_arm"

/obj/item/mecha_parts/part/aq/clarke_right_arm
	name = "prawe ramię Clarke'a"
	desc = "Prawe ramię Clarke'a. Gniazda danych i zasilania pasują do większości narzędzi egzoszkieletów."
	icon_state = "clarke_r_arm"

/obj/item/mecha_parts/part/aq/clarke_treads
	name = "gąsienice Clarke'a"
	desc = "Gąsienice Clarke'a. Szybkie na każdym gruncie, odporne na lawę."
	icon_state = "clarke_treads"

/obj/item/circuitboard/mecha/aq_clarke/peripherals
	name = "moduł sterowania peryferiami Clarke (płytka egzoszkieletu)"
	icon_state = "mcontroller"

/obj/item/circuitboard/mecha/aq_clarke/main
	name = "centralny moduł sterowania Clarke (płytka egzoszkieletu)"
	icon_state = "mainboard"

/datum/component/construction/unordered/mecha_chassis/aq/clarke
	result = /datum/component/construction/mecha/aq/clarke
	steps = list(
		/obj/item/mecha_parts/part/aq/clarke_torso,
		/obj/item/mecha_parts/part/aq/clarke_left_arm,
		/obj/item/mecha_parts/part/aq/clarke_right_arm,
		/obj/item/mecha_parts/part/aq/clarke_treads,
		/obj/item/mecha_parts/part/aq/clarke_head,
	)

/datum/component/construction/mecha/aq/clarke
	result = /obj/mecha/working/aq_clarke
	base_icon = "clarke"
	circuit_control = /obj/item/circuitboard/mecha/aq_clarke/main
	circuit_periph = /obj/item/circuitboard/mecha/aq_clarke/peripherals
	inner_plating = /obj/item/stack/sheet/plasteel
	inner_plating_amount = 5
	outer_plating = /obj/item/stack/sheet/mineral/gold
	outer_plating_amount = 5
