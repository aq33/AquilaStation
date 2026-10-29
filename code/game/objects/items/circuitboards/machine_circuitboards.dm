//Command


/obj/item/circuitboard/machine/bsa/back
	name = "generator artylerii bluespace (płytka maszyny)"
	icon_state = "command"
	build_path = /obj/machinery/bsa/back //No freebies!
	req_components = list(
		/obj/item/stock_parts/capacitor/quadratic = 5,
		/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/bsa/middle
	name = "fuzor artylerii bluespace (płytka maszyny)"
	icon_state = "command"
	build_path = /obj/machinery/bsa/middle
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 20,
		/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/bsa/front
	name = "lufa artylerii bluespace (płytka maszyny)"
	icon_state = "command"
	build_path = /obj/machinery/bsa/front
	req_components = list(
		/obj/item/stock_parts/manipulator/femto = 5,
		/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/dna_vault
	name = "skarbiec DNA (płytka maszyny)"
	icon_state = "command"
	build_path = /obj/machinery/dna_vault //No freebies!
	req_components = list(
		/obj/item/stock_parts/capacitor/super = 5,
		/obj/item/stock_parts/manipulator/pico = 5,
		/obj/item/stack/cable_coil = 2)


//Engineering


/obj/item/circuitboard/machine/announcement_system
	name = "automatyczny system ogłoszeń (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/announcement_system
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/autolathe
	name = "autolat (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/modular_fabricator/autolathe
	req_components = list(
		/obj/item/stock_parts/matter_bin = 3,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/grounding_rod
	name = "pręt uziemiający (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/power/grounding_rod
	req_components = list(/obj/item/stock_parts/capacitor = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/telecomms/broadcaster
	name = "nadajnik podprzestrzenny (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/broadcaster
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/subspace/filter = 1,
		/obj/item/stock_parts/subspace/crystal = 1,
		/obj/item/stock_parts/micro_laser = 2)

/obj/item/circuitboard/machine/telecomms/bus
	name = "magistrala telekomunikacyjna (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/bus
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/subspace/filter = 1)

/obj/item/circuitboard/machine/telecomms/hub
	name = "węzeł telekomunikacyjny (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/hub
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/subspace/filter = 2)

/obj/item/circuitboard/machine/telecomms/processor
	name = "procesor telekomunikacyjny (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/processor
	req_components = list(
		/obj/item/stock_parts/manipulator = 3,
		/obj/item/stock_parts/subspace/filter = 1,
		/obj/item/stock_parts/subspace/treatment = 2,
		/obj/item/stock_parts/subspace/analyzer = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/subspace/amplifier = 1)

/obj/item/circuitboard/machine/telecomms/receiver
	name = "odbiornik podprzestrzenny (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/receiver
	req_components = list(
		/obj/item/stock_parts/subspace/ansible = 1,
		/obj/item/stock_parts/subspace/filter = 1,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/machine/telecomms/relay
	name = "przekaźnik telekomunikacyjny (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/relay
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/subspace/filter = 2)

/obj/item/circuitboard/machine/telecomms/server
	name = "serwer telekomunikacyjny (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/server
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/subspace/filter = 1)

/obj/item/circuitboard/machine/telecomms/message_server
	name = "serwer wiadomości (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/telecomms/message_server
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stock_parts/subspace/filter = 3)

/obj/item/circuitboard/machine/tesla_coil
	name = "cewka Tesli (płytka maszyny)"
	icon_state = "engineering"
	desc = "Śrubokrętem możesz przełączać między badaniami a wytwarzaniem energii."
	build_path = /obj/machinery/power/tesla_coil
	req_components = list(/obj/item/stock_parts/capacitor = 1)
	needs_anchored = FALSE

#define PATH_POWERCOIL /obj/machinery/power/tesla_coil/power
#define PATH_RPCOIL /obj/machinery/power/tesla_coil/research

/obj/item/circuitboard/machine/tesla_coil/Initialize(mapload)
	. = ..()
	if(build_path)
		build_path = PATH_POWERCOIL

/obj/item/circuitboard/machine/tesla_coil/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		var/obj/item/circuitboard/new_type
		var/new_setting
		switch(build_path)
			if(PATH_POWERCOIL)
				new_type = /obj/item/circuitboard/machine/tesla_coil/research
				new_setting = "badania"
			if(PATH_RPCOIL)
				new_type = /obj/item/circuitboard/machine/tesla_coil/power
				new_setting = "energia"
		name = initial(new_type.name)
		build_path = initial(new_type.build_path)
		I.play_tool_sound(src)
		to_chat(user, "<span class='notice'>Zmieniasz ustawienie płytki na \"[new_setting]\".</span>")
	else
		return ..()

/obj/item/circuitboard/machine/tesla_coil/power
	name = "cewka Tesli (płytka maszyny)"
	build_path = PATH_POWERCOIL

/obj/item/circuitboard/machine/tesla_coil/research
	name = "badawcza cewka Tesli (płytka maszyny)"
	build_path = PATH_RPCOIL

#undef PATH_POWERCOIL
#undef PATH_RPCOIL


/obj/item/circuitboard/machine/cell_charger
	name = "ładowarka ogniw (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/cell_charger
	req_components = list(/obj/item/stock_parts/capacitor = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/circulator
	name = "cyrkulator/wymiennik ciepła (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/atmospherics/components/binary/circulator
	req_components = list()

/obj/item/circuitboard/machine/emitter
	name = "emiter (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/power/emitter
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/generator
	name = "generator termoelektryczny (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/power/generator
	req_components = list()

/obj/item/circuitboard/machine/ntnet_relay
	name = "przekaźnik NTNet (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/ntnet_relay
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/subspace/filter = 1)

/obj/item/circuitboard/machine/pacman
	name = "przenośny generator typu P.A.C.M.A.N. (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/power/port_gen/pacman
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/capacitor = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/pacman/super
	name = "przenośny generator typu S.U.P.E.R.P.A.C.M.A.N. (płytka maszyny)"
	build_path = /obj/machinery/power/port_gen/pacman/super

/obj/item/circuitboard/machine/pacman/mrs
	name = "przenośny generator typu M.R.S.P.A.C.M.A.N. (płytka maszyny)"
	build_path = /obj/machinery/power/port_gen/pacman/mrs

/obj/item/circuitboard/machine/power_compressor
	name = "sprężarka (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/power/compressor
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/manipulator = 6)

/obj/item/circuitboard/machine/power_turbine
	name = "turbina energetyczna (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/power/turbine
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/capacitor = 6)

/obj/item/circuitboard/machine/igniter
	name = "zapalnik (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/igniter
	req_components = list(
		/obj/item/assembly/igniter = 1
	)

/obj/item/circuitboard/machine/protolathe/department/engineering
	name = "działowy protolat – inżynieria (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/rnd/production/protolathe/department/engineering

/obj/item/circuitboard/machine/rad_collector
	name = "kolektor promieniowania (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/power/rad_collector
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/sheet/plasmarglass = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/rtg
	name = "RTG (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/power/rtg
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stack/sheet/mineral/uranium = 10) // We have no Pu-238, and this is the closest thing to it.

/obj/item/circuitboard/machine/rtg/advanced
	name = "zaawansowany RTG (płytka maszyny)"
	build_path = /obj/machinery/power/rtg/advanced
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/mineral/uranium = 10,
		/obj/item/stack/sheet/mineral/plasma = 5)

/obj/item/circuitboard/machine/shuttle/engine
	name = "silnik manewrowy (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/shuttle/engine
	req_components = list()

/obj/item/circuitboard/machine/shuttle/engine/plasma
	name = "plazmowy silnik manewrowy (płytka maszyny)"
	build_path = /obj/machinery/shuttle/engine/plasma
	req_components = list(/obj/item/stock_parts/capacitor = 2,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/machine/shuttle/engine/void
	name = "silnik pustki (płytka maszyny)"
	build_path = /obj/machinery/shuttle/engine/void
	req_components = list(/obj/item/stock_parts/capacitor/quadratic = 2,
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/micro_laser/quadultra = 1)

/obj/item/circuitboard/machine/shuttle/heater
	name = "podgrzewacz silnika (płytka maszyny)"
	build_path = /obj/machinery/atmospherics/components/unary/shuttle/heater
	req_components = list(/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/matter_bin = 1)

/obj/item/circuitboard/machine/plasma_refiner
	name = "rafineria plazmy (płytka maszyny)"
	build_path = /obj/machinery/atmospherics/components/unary/plasma_refiner
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/assembly/igniter = 1
	)

/obj/item/circuitboard/machine/scanner_gate
	name = "bramka skanująca (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/scanner_gate
	req_components = list(
		/obj/item/stock_parts/scanning_module = 3)

/obj/item/circuitboard/machine/smes
	name = "SMES (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/power/smes
	req_components = list(
		/obj/item/stack/cable_coil = 5,
		/obj/item/stock_parts/cell = 5,
		/obj/item/stock_parts/capacitor = 1)
	def_components = list(/obj/item/stock_parts/cell = /obj/item/stock_parts/cell/high/empty)

/obj/item/circuitboard/machine/techfab/department/engineering
	name = "działowy techfab – inżynieria (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/rnd/production/techfab/department/engineering

/obj/item/circuitboard/machine/teleporter_hub
	name = "węzeł teleportera (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/teleport/hub
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 3,
		/obj/item/stock_parts/matter_bin = 1)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)

/obj/item/circuitboard/machine/teleporter_station
	name = "stacja teleportera (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/teleport/station
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 2,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stack/sheet/glass = 1)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)

/obj/item/circuitboard/machine/thermomachine
	name = "termomaszyna (płytka maszyny)"
	icon_state = "engineering"
	build_path = /obj/machinery/atmospherics/components/unary/thermomachine/freezer
	var/pipe_layer = PIPING_LAYER_DEFAULT
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/thermomachine/multitool_act(mob/living/user, obj/item/multitool/I)
	. = ..()
	if(istype(I))
		pipe_layer = (pipe_layer >= PIPING_LAYER_MAX) ? PIPING_LAYER_MIN : (pipe_layer + 1)
		to_chat(user, "<span class='notice'>Zmieniasz warstwę płytki na [pipe_layer].</span>")

/obj/item/circuitboard/machine/thermomachine/examine()
	. = ..()
	. += "<span class='notice'>Ustawiona na warstwę [pipe_layer].</span>"

//Generic


/obj/item/circuitboard/machine/circuit_imprinter
	name = "drukarka obwodów (płytka maszyny)"
	icon_state = "generic"
	build_path = /obj/machinery/rnd/production/circuit_imprinter
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/reagent_containers/glass/beaker = 2)

/obj/item/circuitboard/machine/circuit_imprinter/department
	name = "działowa drukarka obwodów (płytka maszyny)"
	build_path = /obj/machinery/rnd/production/circuit_imprinter/department

/obj/item/circuitboard/machine/holopad
	name = "holopad SI (płytka maszyny)"
	icon_state = "generic"
	build_path = /obj/machinery/holopad
	req_components = list(/obj/item/stock_parts/capacitor = 1)
	needs_anchored = FALSE //wew lad
	var/secure = FALSE // AQ EDIT - port BeeStation #14515

// AQ EDIT START - port BeeStation #14515: a multitool switches the board to a secure holopad
/obj/item/circuitboard/machine/holopad/multitool_act(mob/living/user, obj/item/tool)
	secure = !secure
	if(secure)
		build_path = /obj/machinery/holopad/secure
		to_chat(user, "<span class='notice'>Włączasz zabezpieczenia: [src].</span>")
	else
		build_path = /obj/machinery/holopad
		to_chat(user, "<span class='notice'>Wyłączasz zabezpieczenia: [src].</span>")
	return TRUE

/obj/item/circuitboard/machine/holopad/examine(mob/user)
	. = ..()
	. += "Na płytce jest port połączeniowy, który można <b>pobudzić impulsem</b>."
	if(secure)
		. += "Obok słowa „secure” miga czerwona lampka."
// AQ EDIT END

/obj/item/circuitboard/machine/launchpad
	name = "wyrzutnia bluespace (płytka maszyny)"
	icon_state = "generic"
	build_path = /obj/machinery/launchpad
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stock_parts/manipulator = 1)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)

/obj/item/circuitboard/machine/paystand
	name = "stojak płatniczy (płytka maszyny)"
	icon_state = "generic"
	build_path = /obj/machinery/paystand
	req_components = list()

/obj/item/circuitboard/machine/protolathe
	name = "protolat (płytka maszyny)"
	icon_state = "generic"
	build_path = /obj/machinery/rnd/production/protolathe
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/reagent_containers/glass/beaker = 2)

/obj/item/circuitboard/machine/protolathe/department
	name = "działowy protolat (płytka maszyny)"
	build_path = /obj/machinery/rnd/production/protolathe/department

/obj/item/circuitboard/machine/reagentgrinder
	name = "młynek wielofunkcyjny (płytka maszyny)"
	icon_state = "generic"
	build_path = /obj/machinery/reagentgrinder/constructed
	req_components = list(
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/smartfridge
	name = "inteligentna lodówka (płytka maszyny)"
	icon_state = "generic"
	build_path = /obj/machinery/smartfridge
	req_components = list(/obj/item/stock_parts/matter_bin = 1)
	var/static/list/fridges_name_paths = list(/obj/machinery/smartfridge = "plony roślin",
		/obj/machinery/smartfridge/food = "jedzenie",
		/obj/machinery/smartfridge/drinks = "napoje",
		/obj/machinery/smartfridge/extract = "szlamy",
		/obj/machinery/smartfridge/organ = "organy",
		/obj/machinery/smartfridge/chemistry = "chemikalia",
		/obj/machinery/smartfridge/chemistry/virology = "wirusy",
		/obj/machinery/smartfridge/disks = "dyski")
	needs_anchored = FALSE

/obj/item/circuitboard/machine/smartfridge/Initialize(mapload, new_type)
	if(new_type)
		build_path = new_type
	return ..()

/obj/item/circuitboard/machine/smartfridge/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		var/position = fridges_name_paths.Find(build_path, fridges_name_paths)
		position = (position == fridges_name_paths.len) ? 1 : (position + 1)
		build_path = fridges_name_paths[position]
		to_chat(user, "<span class='notice'>Ustawiasz płytkę na [fridges_name_paths[build_path]].</span>")
	else
		return ..()

/obj/item/circuitboard/machine/smartfridge/examine(mob/user)
	. = ..()
	. += "<span class='info'>[src] jest ustawiona na [fridges_name_paths[build_path]]. Możesz ją przekonfigurować śrubokrętem.</span>"


/obj/item/circuitboard/machine/space_heater
	name = "grzejnik przenośny (płytka maszyny)"
	icon_state = "generic"
	build_path = /obj/machinery/space_heater
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stack/cable_coil = 3)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/techfab
	name = "techfab (płytka maszyny)"
	icon_state = "generic"
	build_path = /obj/machinery/rnd/production/techfab
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/reagent_containers/glass/beaker = 2)

/obj/item/circuitboard/machine/techfab/department
	name = "działowy techfab (płytka maszyny)"
	build_path = /obj/machinery/rnd/production/techfab/department

/obj/item/circuitboard/machine/vendor
	name = "własny automat (płytka maszyny)"
	icon_state = "generic"
	desc = "Śrubokrętem możesz przekręcić pokrętło „wybór marki”."
	custom_premium_price = 30
	build_path = /obj/machinery/vending/custom
	req_components = list(/obj/item/vending_refill/custom = 1)

	var/static/list/vending_names_paths = list(
		/obj/machinery/vending/boozeomat = "Booze-O-Mat",
		/obj/machinery/vending/coffee = "Solar's Best Hot Drinks",
		/obj/machinery/vending/snack = "Getmore Chocolate Corp",
		/obj/machinery/vending/cola = "Robust Softdrinks",
		/obj/machinery/vending/cigarette = "ShadyCigs Deluxe",
		/obj/machinery/vending/games = "\improper Good Clean Fun",
		/obj/machinery/vending/autodrobe = "AutoDrobe",
		/obj/machinery/vending/wardrobe/sec_wardrobe = "Mundurownia Policyjna", //AQUILA EDIT
		/obj/machinery/vending/wardrobe/det_wardrobe = "DetDrobe",
		/obj/machinery/vending/wardrobe/medi_wardrobe = "MediDrobe",
		/obj/machinery/vending/wardrobe/engi_wardrobe = "EngiDrobe",
		/obj/machinery/vending/wardrobe/atmos_wardrobe = "AtmosDrobe",
		/obj/machinery/vending/wardrobe/cargo_wardrobe = "CargoDrobe",
		/obj/machinery/vending/wardrobe/robo_wardrobe = "RoboDrobe",
		/obj/machinery/vending/wardrobe/science_wardrobe = "SciDrobe",
		/obj/machinery/vending/wardrobe/hydro_wardrobe = "HyDrobe",
		/obj/machinery/vending/wardrobe/curator_wardrobe = "CuraDrobe",
		/obj/machinery/vending/wardrobe/bar_wardrobe = "BarDrobe",
		/obj/machinery/vending/wardrobe/chef_wardrobe = "ChefDrobe",
		/obj/machinery/vending/wardrobe/jani_wardrobe = "JaniDrobe",
		/obj/machinery/vending/wardrobe/law_wardrobe = "LawDrobe",
		/obj/machinery/vending/wardrobe/chap_wardrobe = "ChapDrobe",
		/obj/machinery/vending/wardrobe/chem_wardrobe = "ChemDrobe",
		/obj/machinery/vending/wardrobe/gene_wardrobe = "GeneDrobe",
		/obj/machinery/vending/wardrobe/viro_wardrobe = "ViroDrobe",
		/obj/machinery/vending/clothing = "ClothesMate",
		/obj/machinery/vending/medical = "NanoMed Plus",
		/obj/machinery/vending/wallmed = "NanoMed",
		/obj/machinery/vending/assist  = "Vendomat",
		/obj/machinery/vending/engivend = "Engi-Vend",
		/obj/machinery/vending/tool = "YouTool",
		/obj/machinery/vending/hydronutrients = "NutriMax",
		/obj/machinery/vending/hydroseeds = "MegaSeed Servitor",
		/obj/machinery/vending/sustenance = "Prowiant",
		/obj/machinery/vending/dinnerware = "Zastawa Plasteel Chef",
		/obj/machinery/vending/job_disk = "PTech",
		/obj/machinery/vending/robotics = "Robotech Deluxe",
		/obj/machinery/vending/engineering = "Robco Tool Maker",
		/obj/machinery/vending/sovietsoda = "BODA",
		/obj/machinery/vending/security = "Zbrojownia Policyjna", //AQUILA EDIT
		/obj/machinery/vending/modularpc = "Deluxe Silicate Selections",
		/obj/machinery/vending/custom = "własny")

/obj/item/circuitboard/machine/vendor/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		var/static/list/display_vending_names_paths
		if(!display_vending_names_paths)
			display_vending_names_paths = list()
			for(var/path in vending_names_paths)
				display_vending_names_paths[vending_names_paths[path]] = path
		var/choice =  input(user,"Wybierz nową markę","Wybierz przedmiot") as null|anything in display_vending_names_paths
		set_type(display_vending_names_paths[choice])
	else
		return ..()

/obj/item/circuitboard/machine/vendor/proc/set_type(obj/machinery/vending/typepath)
	build_path = typepath
	name = "automat: [vending_names_paths[build_path]] (płytka maszyny)"
	req_components = list(initial(typepath.refill_canister) = 1)

/obj/item/circuitboard/machine/vendor/apply_default_parts(obj/machinery/M)
	for(var/typepath in vending_names_paths)
		if(istype(M, typepath))
			set_type(typepath)
			break
	return ..()


/obj/item/circuitboard/machine/vending/donksofttoyvendor
	name = "automat z zabawkami Donksoft (płytka maszyny)"
	icon_state = "generic"
	build_path = /obj/machinery/vending/donksofttoyvendor
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/vending_refill/donksoft = 1)

/obj/item/circuitboard/machine/vending/syndicatedonksofttoyvendor
	name = "automat z zabawkami Donksoft Syndykatu (płytka maszyny)"
	icon_state = "generic"
	build_path = /obj/machinery/vending/toyliberationstation
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/vending_refill/donksoft = 1)

/obj/item/circuitboard/machine/fax
	name = "faks (płytka maszyny)"
	build_path = /obj/machinery/fax
	req_components = list(
		/obj/item/stock_parts/subspace/crystal = 1,
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/manipulator = 1)


//Medical


/obj/item/circuitboard/machine/chem_dispenser
	name = "dozownik chemikaliów (płytka maszyny)"
	icon_state = "medical"
	build_path = /obj/machinery/chem_dispenser
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell = 1)
	def_components = list(/obj/item/stock_parts/cell = /obj/item/stock_parts/cell/high)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/chem_dispenser/botany				//probably should be generic but who cares
	name = "mały botaniczny dozownik chemikaliów (płytka maszyny)"
	build_path = /obj/machinery/chem_dispenser/mutagensaltpetersmall
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell = 1)
	def_components = list(/obj/item/stock_parts/cell = /obj/item/stock_parts/cell/high)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/chem_dispenser/fullupgrade
	build_path = /obj/machinery/chem_dispenser/fullupgrade
	req_components = list(
		/obj/item/stock_parts/matter_bin/bluespace = 2,
		/obj/item/stock_parts/capacitor/quadratic = 2,
		/obj/item/stock_parts/manipulator/femto = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell/bluespace = 1,
	)

/obj/item/circuitboard/machine/chem_dispenser/mutagensaltpeter
	build_path = /obj/machinery/chem_dispenser/mutagensaltpeter
	req_components = list(
		/obj/item/stock_parts/matter_bin/bluespace = 2,
		/obj/item/stock_parts/capacitor/quadratic = 2,
		/obj/item/stock_parts/manipulator/femto = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell/bluespace = 1,
	)

/obj/item/circuitboard/machine/chem_dispenser/abductor
	name = "syntezator odczynników (płytka maszyny porywaczy)"
	icon_state = "abductor_mod"
	build_path = /obj/machinery/chem_dispenser/abductor
	req_components = list(
		/obj/item/stock_parts/matter_bin/bluespace = 2,
		/obj/item/stock_parts/capacitor/quadratic = 2,
		/obj/item/stock_parts/manipulator/femto = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell/bluespace = 1,
	)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/chem_heater
	name = "podgrzewacz chemiczny (płytka maszyny)"
	icon_state = "medical"
	build_path = /obj/machinery/chem_heater
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/chem_master
	name = "ChemMaster 3000 (płytka maszyny)"
	icon_state = "medical"
	build_path = /obj/machinery/chem_master
	desc = "Śrubokrętem możesz przekręcić pokrętło „wybór trybu”."
	req_components = list(
		/obj/item/reagent_containers/glass/beaker = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/chem_master/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		var/new_name = "ChemMaster"
		var/new_path = /obj/machinery/chem_master

		if(build_path == /obj/machinery/chem_master)
			new_name = "CondiMaster"
			new_path = /obj/machinery/chem_master/condimaster

		build_path = new_path
		name = "[new_name] 3000 (płytka maszyny)"
		to_chat(user, "<span class='notice'>Zmieniasz ustawienie płytki na \"[new_name]\".</span>")
	else
		return ..()

/obj/item/circuitboard/machine/clonepod
	name = "kapsuła klonująca (płytka maszyny)"
	icon_state = "medical"
	build_path = /obj/machinery/clonepod
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/reagent_containers/glass/beaker = 2)

/obj/item/circuitboard/machine/clonepod/experimental
	name = "eksperymentalna kapsuła klonująca (płytka maszyny)"
	build_path = /obj/machinery/clonepod/experimental

/obj/item/circuitboard/machine/clonescanner
	name = "skaner DNA (płytka maszyny)"
	icon_state = "medical"
	build_path = /obj/machinery/dna_scannernew
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stack/cable_coil = 2)

/obj/item/circuitboard/machine/cryo_tube
	name = "kriokomora (płytka maszyny)"
	icon_state = "medical"
	build_path = /obj/machinery/atmospherics/components/unary/cryo_cell
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 4)

/obj/item/circuitboard/machine/fat_sucker
	name = "ekstraktor lipidów (płytka maszyny)"
	icon_state = "medical"
	build_path = /obj/machinery/fat_sucker
	req_components = list(/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/scalpel = 1)

/obj/item/circuitboard/machine/harvester
	name = "żniwiarka organów (płytka maszyny)"
	icon_state = "medical"
	build_path = /obj/machinery/harvester
	req_components = list(/obj/item/stock_parts/micro_laser = 4)

/obj/item/circuitboard/machine/limbgrower
	name = "hodowla kończyn (płytka maszyny)"
	icon_state = "medical"
	build_path = /obj/machinery/limbgrower
	req_components = list(
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/reagent_containers/glass/beaker = 2,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/protolathe/department/medical
	name = "działowy protolat – medyczny (płytka maszyny)"
	icon_state = "medical"
	build_path = /obj/machinery/rnd/production/protolathe/department/medical

/obj/item/circuitboard/machine/sleeper
	name = "sleeper (płytka maszyny)"
	icon_state = "medical"
	build_path = /obj/machinery/sleeper
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 2)

/obj/item/circuitboard/machine/sleeper/fullupgrade
	name = "sleeper (płytka maszyny)"
	icon_state = "medical"
	build_path = /obj/machinery/sleeper/syndie/fullupgrade
	req_components = list(
		/obj/item/stock_parts/matter_bin/bluespace = 1,
		/obj/item/stock_parts/manipulator/femto = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 2)

/obj/item/circuitboard/machine/smoke_machine
	name = "wytwornica dymu (płytka maszyny)"
	icon_state = "medical"
	build_path = /obj/machinery/smoke_machine
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/stasis
	name = "łóżko stazy (płytka maszyny)"
	icon_state = "medical"
	build_path = /obj/machinery/stasis
	req_components = list(
		/obj/item/stack/cable_coil = 3,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/capacitor = 1)

/obj/item/circuitboard/machine/techfab/department/medical
	name = "działowy techfab – medyczny (płytka maszyny)"
	icon_state = "medical"
	build_path = /obj/machinery/rnd/production/techfab/department/medical


//Science

/obj/item/circuitboard/machine/circuit_imprinter/department/science
	name = "działowa drukarka obwodów – nauka (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/rnd/production/circuit_imprinter/department/science

/obj/item/circuitboard/machine/cyborgrecharger
	name = "stacja ładowania cyborgów (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/recharge_station
	req_components = list(
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/cell = 1,
		/obj/item/stock_parts/manipulator = 1)
	def_components = list(/obj/item/stock_parts/cell = /obj/item/stock_parts/cell/high)

/obj/item/circuitboard/machine/destructive_analyzer
	name = "analizator destrukcyjny (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/rnd/destructive_analyzer
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1)

/obj/item/circuitboard/machine/experimentor
	name = "E.X.P.E.R.I-MENTOR (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/rnd/experimentor
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 2)

/obj/item/circuitboard/machine/mech_recharger
	name = "port zasilania warsztatu mechów (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/mech_bay_recharge_port
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/capacitor = 5)

/obj/item/circuitboard/machine/mechfab
	name = "fabrykator egzoszkieletów (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/modular_fabricator/exosuit_fab
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/monkey_recycler
	name = "recykler małp (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/monkey_recycler
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/nanite_chamber
	name = "komora nanitów (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/nanite_chamber
	req_components = list(
		/obj/item/stock_parts/scanning_module = 2,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/machine/nanite_program_hub
	name = "centrum programów nanitów (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/nanite_program_hub
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/machine/nanite_programmer
	name = "programator nanitów (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/nanite_programmer
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/scanning_module = 1)

/obj/item/circuitboard/machine/processor/slime
	name = "przetwórnia szlamów (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/processor/slime

/obj/item/circuitboard/machine/protolathe/department/science
	name = "działowy protolat – nauka (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/rnd/production/protolathe/department/science

/obj/item/circuitboard/machine/public_nanite_chamber
	name = "publiczna komora nanitów (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/public_nanite_chamber
	var/cloud_id = 1
	req_components = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/manipulator = 1)

/obj/item/circuitboard/machine/public_nanite_chamber/multitool_act(mob/living/user)
	var/new_cloud = input("Ustaw ID chmury publicznej komory nanitów (1-100).", "ID chmury", cloud_id) as num|null
	if(new_cloud == null)
		return
	cloud_id = CLAMP(round(new_cloud, 1), 1, 100)

/obj/item/circuitboard/machine/public_nanite_chamber/examine(mob/user)
	. = ..()
	. += "ID chmury jest obecnie ustawione na [cloud_id]."


/obj/item/circuitboard/machine/quantumpad
	name = "pad kwantowy (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/quantumpad
	req_components = list(
		/obj/item/stack/ore/bluespace_crystal = 1,
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1)
	def_components = list(/obj/item/stack/ore/bluespace_crystal = /obj/item/stack/ore/bluespace_crystal/artificial)

/obj/item/circuitboard/machine/rdserver
	name = "serwer B+R (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/rnd/server
	req_components = list(
		/obj/item/stack/cable_coil = 2,
		/obj/item/stock_parts/scanning_module = 1)

/obj/item/circuitboard/machine/techfab/department/science
	name = "działowy techfab – nauka (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/rnd/production/techfab/department/science

/obj/item/circuitboard/machine/ecto_sniffer
	name = "ektoskopowy wykrywacz (płytka maszyny)"
	build_path = /obj/machinery/ecto_sniffer
	req_components = list(
		/obj/item/stock_parts/scanning_module = 1)
//Security


/obj/item/circuitboard/machine/protolathe/department/security
	name = "działowy protolat – ochrona (płytka maszyny)"
	icon_state = "security"
	build_path = /obj/machinery/rnd/production/protolathe/department/security

/obj/item/circuitboard/machine/recharger
	name = "ładowarka broni (płytka maszyny)"
	icon_state = "security"
	build_path = /obj/machinery/recharger
	req_components = list(/obj/item/stock_parts/capacitor = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/techfab/department/security
	name = "działowy techfab – ochrona (płytka maszyny)"
	icon_state = "security"
	build_path = /obj/machinery/rnd/production/techfab/department/security


//Service


/obj/item/circuitboard/machine/biogenerator
	name = "biogenerator (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/biogenerator
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/stack/sheet/glass = 1)

/obj/item/circuitboard/machine/chem_dispenser/drinks
	name = "dozownik napojów (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/chem_dispenser/drinks

/obj/item/circuitboard/machine/chem_dispenser/drinks/fullupgrade
	build_path = /obj/machinery/chem_dispenser/drinks/fullupgrade
	req_components = list(
		/obj/item/stock_parts/matter_bin/bluespace = 2,
		/obj/item/stock_parts/capacitor/quadratic = 2,
		/obj/item/stock_parts/manipulator/femto = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell/bluespace = 1,
	)

/obj/item/circuitboard/machine/chem_dispenser/drinks/beer
	name = "dozownik alkoholi (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/chem_dispenser/drinks/beer

/obj/item/circuitboard/machine/chem_dispenser/drinks/beer/fullupgrade
	build_path = /obj/machinery/chem_dispenser/drinks/beer/fullupgrade
	req_components = list(
		/obj/item/stock_parts/matter_bin/bluespace = 2,
		/obj/item/stock_parts/capacitor/quadratic = 2,
		/obj/item/stock_parts/manipulator/femto = 2,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/cell/bluespace = 1,
	)

/obj/item/circuitboard/machine/chem_master/condi
	name = "CondiMaster 3000 (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/chem_master/condimaster

/obj/item/circuitboard/machine/deep_fryer
	name = "frytkownica (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/deepfryer
	req_components = list(/obj/item/stock_parts/micro_laser = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/griddle
	name = "płyta grillowa (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/griddle
	req_components = list(/obj/item/stock_parts/micro_laser = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/oven
	name = "piekarnik (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/oven
	req_components = list(/obj/item/stock_parts/micro_laser = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/dish_drive
	name = "zbieracz naczyń (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/dish_drive
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/matter_bin = 2)
	var/suction = TRUE
	var/transmit = TRUE
	needs_anchored = FALSE

/obj/item/circuitboard/machine/dish_drive/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Funkcja ssania jest [suction ? "włączona" : "wyłączona"]. Użyj w ręce, by przełączyć.</span>\n"+\
	"<span class='notice'>Funkcja automatycznego przesyłania do zsypu jest [transmit ? "włączona" : "wyłączona"]. Alt-kliknij, by przełączyć.</span>"

/obj/item/circuitboard/machine/dish_drive/attack_self(mob/living/user)
	suction = !suction
	to_chat(user, "<span class='notice'>[suction ? "Włączasz" : "Wyłączasz"] funkcję ssania płytki.</span>")

/obj/item/circuitboard/machine/dish_drive/AltClick(mob/living/user)
	if(!user.Adjacent(src))
		return
	transmit = !transmit
	to_chat(user, "<span class='notice'>[transmit ? "Włączasz" : "Wyłączasz"] automatyczne przesyłanie do zsypu na płytce.</span>")


/obj/item/circuitboard/machine/gibber
	name = "maszynka do mięsa (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/gibber
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/microwave
	name = "mikrofalówka (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/microwave
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stack/cable_coil = 2,
		/obj/item/stack/sheet/glass = 2)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/mass_driver
	name = "wyrzutnia masowa (płytka maszyny)"
	build_path = /obj/machinery/mass_driver
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/capacitor = 1
	)

/obj/item/circuitboard/machine/processor
	name = "malakser (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/processor
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/processor/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(build_path == /obj/machinery/processor)
			name = "przetwórnia szlamów (płytka maszyny)"
			build_path = /obj/machinery/processor/slime
			to_chat(user, "<span class='notice'>Protokoły nazewnictwa zaktualizowane pomyślnie.</span>")
		else
			name = "malakser (płytka maszyny)"
			build_path = /obj/machinery/processor
			to_chat(user, "<span class='notice'>Przywracanie domyślnych protokołów nazewnictwa.</span>")
	else
		return ..()

/obj/item/circuitboard/machine/protolathe/department/service
	name = "działowy protolat – służba (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/rnd/production/protolathe/department/service

/obj/item/circuitboard/machine/recycler
	name = "recykler (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/recycler
	req_components = list(
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/manipulator = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/techfab/department/service
	name = "działowy techfab – służba (płytka maszyny)"
	icon_state = "service"
	build_path = /obj/machinery/rnd/production/techfab/department/service


//Supply


/obj/item/circuitboard/machine/techfab/department/cargo
	name = "działowy techfab – zaopatrzenie (płytka maszyny)"
	icon_state = "supply"
	build_path = /obj/machinery/rnd/production/techfab/department/cargo

/obj/item/circuitboard/machine/mining_equipment_vendor
	name = "automat ze sprzętem górniczym (płytka maszyny)"
	icon_state = "supply"
	build_path = /obj/machinery/vendor/mining
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/matter_bin = 3)

/obj/item/circuitboard/machine/exploration_equipment_vendor
	name = "automat ze sprzętem odkrywców (płytka maszyny)"
	icon_state = "supply"
	build_path = /obj/machinery/vendor/exploration
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/matter_bin = 3)


/obj/item/circuitboard/machine/mining_equipment_vendor/golem
	name = "automat ze sprzętem statku golemów (płytka maszyny)"
	build_path = /obj/machinery/vendor/mining/golem

/obj/item/circuitboard/machine/pump
	name = "przenośna pompa cieczy (płytka maszyny)"
	icon_state = "supply"
	build_path = /obj/machinery/power/liquid_pump
	needs_anchored = FALSE
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/matter_bin = 2)

/obj/item/circuitboard/machine/ore_redemption
	name = "maszyna wymiany rudy (płytka maszyny)"
	icon_state = "supply"
	build_path = /obj/machinery/mineral/ore_redemption
	req_components = list(
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/matter_bin = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/assembly/igniter = 1)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/ore_silo
	name = "silos rudy (płytka maszyny)"
	icon_state = "supply"
	build_path = /obj/machinery/ore_silo
	req_components = list()

/obj/item/circuitboard/machine/protolathe/department/cargo
	name = "działowy protolat – zaopatrzenie (płytka maszyny)"
	icon_state = "supply"
	build_path = /obj/machinery/rnd/production/protolathe/department/cargo

/obj/item/circuitboard/machine/stacking_machine
	name = "maszyna stertująca (płytka maszyny)"
	icon_state = "supply"
	build_path = /obj/machinery/mineral/stacking_machine
	req_components = list(
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/matter_bin = 2)

/obj/item/circuitboard/machine/stacking_unit_console
	name = "konsola maszyny stertującej (płytka maszyny)"
	icon_state = "supply"
	build_path = /obj/machinery/mineral/stacking_unit_console
	req_components = list(
		/obj/item/stack/sheet/glass = 2,
		/obj/item/stack/cable_coil = 5)

/obj/item/circuitboard/machine/processing_unit
	name = "piec hutniczy (płytka maszyny)"
	build_path = /obj/machinery/mineral/processing_unit
	req_components = list(
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/assembly/igniter = 1)

/obj/item/circuitboard/machine/processing_unit_console
	name = "konsola pieca hutniczego (płytka maszyny)"
	build_path = /obj/machinery/mineral/processing_unit_console
	req_components = list()


//Misc


/obj/item/circuitboard/machine/abductor
	name = "obca płytka (zgłoś to)"
	icon_state = "abductor_mod"

/obj/item/circuitboard/machine/abductor/core
	name = "obca płytka (rdzeń pustki)"
	build_path = /obj/machinery/power/rtg/abductor
	req_components = list(
		/obj/item/stock_parts/capacitor = 1,
		/obj/item/stock_parts/micro_laser = 1,
		/obj/item/stock_parts/cell/infinite/abductor = 1)
	def_components = list(
		/obj/item/stock_parts/capacitor = /obj/item/stock_parts/capacitor/quadratic,
		/obj/item/stock_parts/micro_laser = /obj/item/stock_parts/micro_laser/quadultra)

/obj/item/circuitboard/machine/chem_dispenser/abductor
	name = "syntezator odczynników (płytka maszyny porywaczy)"
	icon_state = "abductor_mod"
	build_path = /obj/machinery/chem_dispenser/abductor
	def_components = list(/obj/item/stock_parts/cell = /obj/item/stock_parts/cell/high)
	needs_anchored = FALSE

/obj/item/circuitboard/machine/clockwork
	name = "mechaniczna płytka (zgłoś to)"
	icon_state = "clock_mod"

/obj/item/circuitboard/machine/allaccess
	name = "dozownik pełnego dostępu (płytka maszyny)"
	icon_state = "generic"
	build_path = /obj/machinery/allaccess
	req_components = list(
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/micro_laser = 1)
