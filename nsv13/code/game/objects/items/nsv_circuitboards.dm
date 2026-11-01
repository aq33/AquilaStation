////CIC consoles////

/obj/item/circuitboard/computer/ship/helm
	name = "komputer steru (płytka komputera)"
	build_path = /obj/machinery/computer/ship/helm

/obj/item/circuitboard/computer/ship/tactical_computer
	name = "konsola taktyczna (płytka komputera)"
	build_path = /obj/machinery/computer/ship/tactical

//Dradis
/obj/item/circuitboard/computer/ship/dradis
	name = "konsola DRADIS (płytka komputera)"
	build_path = /obj/machinery/computer/ship/dradis

/obj/item/circuitboard/computer/ship/dradis/mining
	name = "górnicza konsola DRADIS (płytka komputera)"
	build_path = /obj/machinery/computer/ship/dradis/mining

/obj/item/circuitboard/computer/ship/dradis/cargo
	name = "komputer DRADIS ładunkowego (płytka komputera)"
	build_path = /obj/machinery/computer/ship/dradis/minor/cargo

//FTL nav
/obj/item/circuitboard/computer/ship/navigation
	name = "konsola nawigacji FTL (płytka komputera)"
	build_path = /obj/machinery/computer/ship/navigation

//Secondary ID console
/obj/item/circuitboard/computer/card/secondary_ship_id_console
	name = "pomocnicza konsola identyfikatorów (płytka komputera)"
	build_path = /obj/machinery/computer/secondary_ship_id_console

/obj/item/circuitboard/computer/card/secondary_ship_id_console/syndicate
	name = "konsola identyfikatorów Syndykatu (płytka komputera)"
	build_path = /obj/machinery/computer/secondary_ship_id_console/syndicate

////Security////

/obj/item/circuitboard/computer/security/syndicate
	name = "konsola kamer Syndykatu (płytka komputera)"
	build_path = /obj/machinery/computer/security/syndicate

////Science////

/obj/item/circuitboard/computer/astrometrics
	name = "komputer astrometryczny (płytka komputera)"
	build_path = /obj/machinery/computer/ship/navigation/astrometrics

////Medical////
/obj/item/circuitboard/machine/autoinject_printer
	name = "drukarka autoinjektorów (płytka maszyny)"
	icon_state = "medical"
	build_path = /obj/machinery/autoinject_printer
	req_components = list(
		/obj/item/reagent_containers/glass/beaker = 2,
		/obj/item/stock_parts/manipulator = 1)

////Munitions consoles////

/obj/item/circuitboard/computer/ship/munitions_computer
	name = "komputer kontroli amunicji (płytka komputera)"
	build_path = /obj/machinery/computer/ship/munitions_computer

/obj/item/circuitboard/computer/ship/ordnance_computer
	name = "konsola monitorowania uzbrojenia (płytka komputera)"
	build_path = /obj/machinery/computer/ship/ordnance

/obj/item/circuitboard/computer/ams
	name = "konsola sterowania AMS (płytka komputera)"
	build_path = /obj/machinery/computer/ams
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/item/circuitboard/computer/ams/Initialize(mapload)
	. = ..()
	GLOB.critical_muni_items += src

/obj/item/circuitboard/computer/ams/Destroy(force=FALSE)
	if(!force)
		return QDEL_HINT_LETMELIVE
	GLOB.critical_muni_items -= src
	return ..()

/obj/item/circuitboard/computer/anti_air
	name = "konsola wieżyczek przeciwlotniczych (płytka komputera)"
	build_path = /obj/machinery/computer/anti_air
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/item/circuitboard/computer/anti_air/Initialize(mapload)
	. = ..()
	GLOB.critical_muni_items += src

/obj/item/circuitboard/computer/anti_air/Destroy(force=FALSE)
	if(!force)
		return QDEL_HINT_LETMELIVE
	GLOB.critical_muni_items -= src
	return ..()

/obj/item/circuitboard/computer/ship/fighter_controller
	name = "komputer kontroli myśliwców (płytka komputera)"
	build_path = /obj/machinery/computer/ship/fighter_controller

//Mag-cat control console
/obj/item/circuitboard/computer/ship/fighter_launcher
	name = "konsola sterowania katapultą elektromagnetyczną (płytka komputera)"
	build_path = /obj/machinery/computer/ship/fighter_launcher

////SHIP GUNS////

//50 Cal. guns, currently not used
/obj/item/circuitboard/machine/anti_air
	name = "wieżyczka przeciwlotnicza (płytka maszyny)"
	req_components = list(
		/obj/item/stack/sheet/mineral/titanium = 20,
		/obj/item/stack/sheet/mineral/copper = 10,
		/obj/item/stack/sheet/iron = 30,
		/obj/item/stack/cable_coil = 5)
	build_path = /obj/machinery/ship_weapon/anti_air
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/item/circuitboard/machine/anti_air/Initialize(mapload)
	. = ..()
	GLOB.critical_muni_items += src

/obj/item/circuitboard/machine/anti_air/Destroy(force=FALSE)
	if(!force)
		return QDEL_HINT_LETMELIVE
	GLOB.critical_muni_items -= src
	return ..()

/obj/item/circuitboard/machine/anti_air/heavy
	name = "ciężka wieżyczka przeciwlotnicza (płytka maszyny)"
	req_components = list(
		/obj/item/stack/sheet/mineral/titanium = 40,
		/obj/item/stack/sheet/mineral/copper = 40,
		/obj/item/stack/sheet/mineral/diamond = 5,
		/obj/item/stack/sheet/iron = 20,
		/obj/item/stack/cable_coil = 5)
	build_path = /obj/machinery/ship_weapon/anti_air/heavy

//PDC and flak boards
#define PATH_PDC /obj/machinery/ship_weapon/pdc_mount
#define PATH_FLAK  /obj/machinery/ship_weapon/pdc_mount/flak

/obj/item/circuitboard/machine/pdc_mount
	name = "stojak ładowania PDC (płytka maszyny)"
	desc = "Śrubokrętem możesz przełączać między PDC a flakiem."
	req_components = list(
		/obj/item/stock_parts/manipulator = 4,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/matter_bin = 3,
	)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	build_path = PATH_PDC

/*  //Not using flak right now
/obj/item/circuitboard/machine/pdc_mount/Initialize(mapload)
	. = ..()
	if(!build_path)
		if(prob(50))
			name = "PDC loading rack (Machine Board)"
			build_path = PATH_PDC
		else
			name = "Flak loading rack (Machine Board)"
			build_path = PATH_FLAK
*/

/obj/item/circuitboard/machine/pdc_mount/Initialize(mapload)
	. = ..()
	GLOB.critical_muni_items += src

/obj/item/circuitboard/machine/pdc_mount/Destroy(force=FALSE)
	if(!force)
		return QDEL_HINT_LETMELIVE
	GLOB.critical_muni_items -= src
	return ..()

/* Flak isn't used right now
/obj/item/circuitboard/machine/pdc_mount/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		var/obj/item/circuitboard/new_type
		var/new_setting
		switch(build_path)
			if(PATH_PDC)
				new_type = /obj/item/circuitboard/machine/pdc_mount/flak
				new_setting = "Flak"
			if(PATH_FLAK)
				new_type = /obj/item/circuitboard/machine/pdc_mount/
				new_setting = "PDC"
		name = initial(new_type.name)
		build_path = initial(new_type.build_path)
		I.play_tool_sound(src)
		to_chat(user, "<span class='notice'>You change the circuitboard setting to \"[new_setting]\".</span>")
		return
*/

/obj/item/circuitboard/machine/pdc_mount/flak
	name = "stojak ładowania flaku (płytka maszyny)"
	build_path = PATH_FLAK

#undef PATH_PDC
#undef PATH_FLAK

//Deck Gun
/obj/item/circuitboard/machine/deck_turret
	name = "wieżyczka działa pokładowego (płytka maszyny)"
	req_components = list()
	build_path = /obj/machinery/ship_weapon/deck_turret
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/item/circuitboard/machine/deck_turret/apply_default_parts()
	//dont

/obj/item/circuitboard/machine/deck_turret/Initialize(mapload)
	. = ..()
	GLOB.critical_muni_items += src

/obj/item/circuitboard/machine/deck_turret/Destroy(force=FALSE)
	if(!force)
		return QDEL_HINT_LETMELIVE
	GLOB.critical_muni_items -= src
	return ..()

/obj/item/circuitboard/computer/deckgun
	name = "konsola sterowania działem pokładowym (płytka komputera)"
	build_path = /obj/machinery/computer/deckgun
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/item/circuitboard/machine/deck_gun
	needs_anchored = FALSE

/obj/item/circuitboard/machine/deck_gun/core
	name = "rdzeń działa pokładowego (płytka maszyny)"
	req_components = list(
		/obj/item/stack/sheet/mineral/titanium = 10,
		/obj/item/stack/cable_coil = 5)
	build_path = /obj/machinery/deck_turret/core
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/item/circuitboard/machine/deck_gun/powder
	name = "bramka prochu działa pokładowego (płytka maszyny)"
	req_components = list(
		/obj/item/stack/sheet/iron = 20,
		/obj/item/stack/sheet/mineral/copper = 20,
		/obj/item/stack/cable_coil = 5)
	build_path = /obj/machinery/deck_turret/powder_gate
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/item/circuitboard/machine/deck_gun/payload
	name = "bramka ładunku działa pokładowego (płytka maszyny)"
	req_components = list(
		/obj/item/stack/sheet/iron = 20,
		/obj/item/stack/sheet/mineral/titanium = 5,
		/obj/item/stack/sheet/mineral/copper = 10,
		/obj/item/ship_weapon/parts/railgun_rail = 1,
		/obj/item/ship_weapon/parts/loading_tray=1,
		/obj/item/stack/cable_coil = 10)
	build_path = /obj/machinery/deck_turret/payload_gate
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

// Inertial dampeners

/obj/item/circuitboard/machine/inertial_dampener
	name = "tłumik bezwładności (płytka maszyny)"
	req_components = list(
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stack/ore/bluespace_crystal = 2,
		/obj/item/stock_parts/manipulator = 6,
		/obj/item/stock_parts/capacitor = 2,
	)
	build_path = /obj/machinery/inertial_dampener

//Upgrades
/obj/item/circuitboard/machine/deck_gun/autoelevator
	name = "automatyczny podnośnik działa pokładowego (płytka maszyny)"
	req_components = list(
		/obj/item/stack/sheet/mineral/titanium = 40,
		/obj/item/stack/sheet/mineral/copper = 20,
		/obj/item/stack/sheet/mineral/diamond = 5,
		/obj/item/stack/cable_coil = 10)
	build_path = /obj/machinery/deck_turret/autoelevator

/obj/item/circuitboard/machine/deck_gun/autorepair
	name = "moduł autonaprawy działa pokładowego (płytka maszyny)"
	req_components = list(
		/obj/item/stack/sheet/mineral/titanium = 40,
		/obj/item/stack/sheet/mineral/copper = 20,
		/obj/item/stack/sheet/mineral/diamond = 2,
		/obj/item/stack/sheet/mineral/uranium = 10,
		/obj/item/stack/cable_coil = 10)
	build_path = /obj/machinery/deck_turret/autorepair

//Missile factory
/obj/item/circuitboard/machine/missile_builder
	name = "automatyczny klucz robotyczny Seegson model „Ford” (płytka maszyny)"
	build_path = /obj/machinery/missile_builder
	req_components = list()
	needs_anchored = FALSE

/obj/item/circuitboard/machine/missile_builder/wirer
	name = "automatyczny okablowywacz robotyczny Seegson model „Ford” (płytka maszyny)"
	build_path = /obj/machinery/missile_builder/wirer

/obj/item/circuitboard/machine/missile_builder/welder
	name = "automatyczna spawarka robotyczna Seegson model „Ford” (płytka maszyny)"
	build_path = /obj/machinery/missile_builder/welder

/obj/item/circuitboard/machine/missile_builder/screwdriver
	name = "robotyczna wkrętarka śrub Seegson model „Ford” (płytka maszyny)"
	build_path = /obj/machinery/missile_builder/screwdriver

/obj/item/circuitboard/machine/missile_builder/assembler
	name = "robotyczne ramię montażu rakiet Seegson model „Ford” (płytka maszyny)"
	build_path = /obj/machinery/missile_builder/assembler

//Missile system
/obj/item/circuitboard/machine/vls
	name = "wyrzutnia pionowa VLS M14 (płytka maszyny)"
	build_path = /obj/machinery/ship_weapon/vls
	req_components = list(
		/obj/item/stack/sheet/mineral/titanium = 20,
		/obj/item/stack/sheet/mineral/copper = 20,
		/obj/item/stack/sheet/iron = 30,
		/obj/item/stack/cable_coil = 10)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/item/circuitboard/machine/vls/Initialize(mapload)
	. = ..()
	GLOB.critical_muni_items += src

/obj/item/circuitboard/machine/vls/Destroy(force=FALSE)
	if(!force)
		return QDEL_HINT_LETMELIVE
	GLOB.critical_muni_items -= src
	return ..()

//Gauss guns
/obj/item/circuitboard/machine/gauss_turret
	name = "wieżyczka Gaussa (płytka maszyny)"
	build_path = /obj/machinery/ship_weapon/gauss_gun
	req_components = list()
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/item/circuitboard/machine/gauss_turret/Initialize(mapload)
	. = ..()
	GLOB.critical_muni_items += src

/obj/item/circuitboard/machine/gauss_turret/Destroy(force=FALSE)
	if(!force)
		return QDEL_HINT_LETMELIVE
	GLOB.critical_muni_items -= src
	return ..()

/obj/item/circuitboard/computer/iff
	name = "konsola IFF (płytka maszyny)"
	build_path = /obj/machinery/computer/iff_console

//Coffee Machine - Navy's Lifeblood
/obj/item/circuitboard/machine/coffeemaker
	name = "ekspres do kawy (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/coffeemaker
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/reagent_containers/glass/beaker = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/micro_laser = 1,
	)

/obj/item/circuitboard/machine/coffeemaker/pendulum
	name = "ekspres do kawy Pendulum (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/coffeemaker/pendulum
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/reagent_containers/glass/beaker = 2,
		/obj/item/stock_parts/capacitor/adv = 1,
		/obj/item/stock_parts/micro_laser/high = 2,
	)


//Plasma Caster and Loader

/obj/item/circuitboard/machine/plasma_loader
	name = "regulator gazowego foronu (płytka maszyny)"
	build_path = /obj/machinery/atmospherics/components/unary/plasma_loader
	var/pipe_layer = PIPING_LAYER_DEFAULT
	req_components = list(
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/item/circuitboard/machine/plasma_loader/Initialize(mapload)
	. = ..()
	GLOB.critical_muni_items += src

/obj/item/circuitboard/machine/plasma_loader/Destroy(forced=FALSE)
	if(!forced)
		return QDEL_HINT_LETMELIVE
	GLOB.critical_muni_items -= src
	return ..()

/obj/item/circuitboard/machine/plasma_loader/multitool_act(mob/living/user, obj/item/multitool/I)
	. = ..()
	if(istype(I))
		pipe_layer = (pipe_layer >= PIPING_LAYER_MAX) ? PIPING_LAYER_MIN : (pipe_layer + 1)
		to_chat(user, "<span class='notice'>Zmieniasz warstwę płytki na [pipe_layer].</span>")

/obj/item/circuitboard/machine/plasma_loader/examine()
	. = ..()
	. += "<span class='notice'>Ustawiona na warstwę [pipe_layer].</span>"

/obj/item/circuitboard/machine/plasma_caster
	name = "miotacz plazmy (płytka maszyny)"
	desc = "Moi wierni... trwajcie niezłomnie!"
	req_components = list(
		/obj/item/stack/sheet/mineral/titanium = 25,
		/obj/item/stack/sheet/iron = 50,
		/obj/item/stack/sheet/mineral/uranium = 10,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/capacitor = 5,
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/assembly/igniter = 1,
		/obj/item/ship_weapon/parts/firing_electronics = 1
	)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	build_path = /obj/machinery/ship_weapon/plasma_caster

/obj/item/circuitboard/machine/plasma_caster/Initialize(mapload)
	. = ..()
	GLOB.critical_muni_items += src

/obj/item/circuitboard/machine/plasma_caster/Destroy(forced=FALSE)
	if(!forced)
		return QDEL_HINT_LETMELIVE
	GLOB.critical_muni_items -= src
	return ..()

// Laser PD console
/obj/item/circuitboard/computer/laser_pd
	name = "konsola laserów obrony punktowej (płytka maszyny)"
	build_path = /obj/machinery/computer/laser_pd
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

/obj/item/circuitboard/computer/laser_pd/Initialize(mapload)
	. = ..()
	GLOB.critical_muni_items += src

/obj/item/circuitboard/computer/laser_pd/Destroy(force=FALSE)
	if(!force)
		return QDEL_HINT_LETMELIVE
	GLOB.critical_muni_items -= src
	return ..()

// Laser PD
/obj/item/circuitboard/machine/laser_pd
	name = "wieżyczka lasera obrony punktowej (płytka maszyny)"
	build_path = /obj/machinery/ship_weapon/energy/laser_pd
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	req_components = list(
		/obj/item/stock_parts/capacitor = 5,
		/obj/item/stock_parts/cell = 5,
		/obj/item/stack/ore/bluespace_crystal = 5)

// Laser AMS
/obj/item/circuitboard/machine/laser_ams
	name = "laserowy AMS (płytka)"
	build_path = /obj/machinery/ship_weapon/energy/ams
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	req_components = list(
		/obj/item/stack/sheet/glass = 5,
		/obj/item/stock_parts/micro_laser = 5,
		/obj/item/stock_parts/capacitor = 5,
		/obj/item/stock_parts/cell = 5,
		/obj/item/stack/ore/bluespace_crystal = 5)

// Phase Cannon
/obj/item/circuitboard/machine/phase_cannon
	name = "działo fazowe (płytka)"
	build_path = /obj/machinery/ship_weapon/energy/beam
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	req_components = list(
		/obj/item/stack/sheet/glass = 5,
		/obj/item/stock_parts/micro_laser = 5,
		/obj/item/stock_parts/capacitor = 5,
		/obj/item/stock_parts/cell = 5,
		/obj/item/stack/ore/bluespace_crystal = 5)

// Burst Phaser
/obj/item/circuitboard/machine/burst_phaser
	name = "fazer seryjny MK2 (płytka)"
	build_path = /obj/machinery/ship_weapon/energy
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	req_components = list(
		/obj/item/stack/sheet/glass = 3,
		/obj/item/stock_parts/micro_laser = 3,
		/obj/item/stock_parts/capacitor = 3,
		/obj/item/stock_parts/cell = 3,
		/obj/item/stack/ore/bluespace_crystal = 3)

// Smelter and console
/obj/item/circuitboard/machine/processing_unit
	name = "piec (płytka maszyny)"
	desc = "Topi i oczyszcza rudy."
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/assembly/igniter = 1
	)
	build_path = /obj/machinery/mineral/processing_unit

/obj/item/circuitboard/machine/processing_unit_console
	name = "konsola pieca (płytka maszyny)"
	desc = "Obwód konsoli sterowania piecem."
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/cable_coil = 1
	)
	build_path = /obj/machinery/mineral/processing_unit_console

//Non-magic chem dispenser
/obj/item/circuitboard/machine/refillable_chem_dispenser
	name = "uzupełniany dozownik chemikaliów (płytka maszyny)"
	icon_state = "medical"
	build_path = /obj/machinery/refillable_chem_dispenser
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1)
	needs_anchored = FALSE

//Atmospheric consoles
/obj/item/circuitboard/computer/atmos_control/tank/nucleium_tank
	name = "sterowanie dostawami nukleium (płytka komputera)"
	build_path = /obj/machinery/computer/atmos_control/tank/nucleium_tank

//Bot navbeacon
/obj/item/circuitboard/machine/navbeacon
	name = "radiolatarnia nawigacyjna botów (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/navbeacon
	req_components = list()
