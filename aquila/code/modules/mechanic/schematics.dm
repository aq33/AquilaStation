// AQUILA - Mechanik: skaner maszyn, czytnik schematów (jak Ruckingenur kit z Goona), flatpacker z tg i paczki z maszynami.
// Kod napisany od nowa na wzór tgstation/tgstation#83836 (flatpacker) i opisu pętli z Goonstation (bez kodu Goona, licencja NC).
// Sprite'y: flatpacker, paczka i wózek z tgstation (CC BY-SA 3.0); skaner (deviceana), czytnik (rkit) i pakownica
// (deconstruction-saw) z Goonstation (CC BY-NC-SA 3.0, jak inne ikony z goon/ w repo).
// Ten plik: czarna lista, schemat maszyny, liczenie kosztu części i baza schematów w techwebie.

/// Maszyny, których zwykły skaner i pakownica nie biorą: uzbrojenie i amunicja okrętu, konsole statku, reaktory,
/// sprzęt ochrony i klonowanie. Narzędzia z uplinku omijają tę listę, a flatpacker robi takie paczki tylko po emagu.
GLOBAL_LIST_INIT(mechanic_blacklist, typecacheof(list(
	/obj/machinery/ship_weapon,
	/obj/machinery/computer/ship,
	/obj/machinery/deck_turret,
	/obj/machinery/missile_builder,
	/obj/machinery/ammo_sorter,
	/obj/machinery/computer/ammo_sorter,
	/obj/machinery/computer/anti_air,
	/obj/machinery/computer/ams,
	/obj/machinery/computer/iff_console,
	/obj/machinery/computer/boarding_guns,
	/obj/machinery/atmospherics/components/binary/railgun_filler,
	/obj/machinery/atmospherics/components/unary/plasma_loader,
	/obj/machinery/railgun_forge,
	/obj/machinery/railgun_forge_coating_tank,
	/obj/machinery/railgun_forge_core_tank,
	/obj/machinery/computer/deckgun,
	/obj/machinery/computer/laser_pd,
	/obj/machinery/computer/reactor,
	/obj/machinery/computer/sts_bsa_control,
	/obj/machinery/computer/bsa_control,
	/obj/machinery/broadside_shell_packer,
	/obj/machinery/gauss_dispenser,
	/obj/machinery/railgun_charger,
	/obj/machinery/munitions_forge,
	/obj/machinery/armour_plating_nanorepair_pump,
	/obj/machinery/armour_plating_nanorepair_well,
	/obj/machinery/atmospherics/components/binary/stormdrive_reactor,
	/obj/machinery/atmospherics/components/trinary/nuclear_reactor,
	/obj/machinery/computer/security,
	/obj/machinery/computer/secure_data,
	/obj/machinery/computer/prisoner,
	/obj/machinery/computer/warrant,
	/obj/machinery/gulag_teleporter,
	/obj/machinery/gulag_item_reclaimer,
	/obj/machinery/clonepod,
	/obj/machinery/computer/cloning,
)))

/// TRUE, jeśli maszyna danego typu jest na czarnej liście mechanika
/proc/mechanic_is_blacklisted(machine_path)
	return !!GLOB.mechanic_blacklist[machine_path]

/// Projekt techwebu, który robi przedmiot danego typu (pierwszy znaleziony), albo null
/proc/mechanic_design_for(item_path)
	var/static/list/design_by_path
	if(!design_by_path)
		design_by_path = list()
		for(var/design_id in SSresearch.techweb_designs)
			var/datum/design/design = SSresearch.techweb_designs[design_id]
			if(design.build_path && !design_by_path[design.build_path])
				design_by_path[design.build_path] = design
	return design_by_path[item_path]

/**
 * Materiały potrzebne na jedną sztukę przedmiotu (lista: materiał = ilość).
 * Najpierw projekt z techwebu, a gdy go nie ma, materiały samego przedmiotu.
 * Pusta lista znaczy, że przedmiotu nie da się zrobić z materiałów i trzeba go włożyć ręcznie.
 */
/proc/mechanic_unit_cost(item_path)
	var/static/list/cost_cache = list()
	if(cost_cache[item_path])
		return cost_cache[item_path]
	var/list/cost = list()
	// Stosy liczymy z materiałów jednej sztuki, projekty stosów robią po kilka naraz
	var/datum/design/design = ispath(item_path, /obj/item/stack) ? null : mechanic_design_for(item_path)
	if(design)
		for(var/material_key in design.materials)
			// Projekty z wyborem materiału mają w kluczu kategorię, liczymy je jako żelazo
			var/datum/material/material = istext(material_key) ? getmaterialref(/datum/material/iron) : material_key
			cost[material] += design.materials[material_key]
	else
		var/obj/item/sample = ispath(item_path, /obj/item/stack) ? new item_path(null, 1) : new item_path(null)
		var/list/sample_materials = sample.get_unit_materials()
		for(var/material_key in sample_materials)
			var/datum/material/material = getmaterialref(material_key) || material_key
			cost[material] += sample_materials[material_key]
		qdel(sample)
	cost_cache[item_path] = cost
	return cost

/// Najwyższy tier części na liście (typ = ilość)
/proc/mechanic_parts_tier(list/part_types)
	. = 1
	for(var/part_path in part_types)
		if(ispath(part_path, /obj/item/stock_parts))
			var/obj/item/stock_parts/part = part_path
			. = max(., initial(part.rating))

/**
 * Schemat maszyny: płytka, cel budowy i części, z którymi maszynę zeskanowano (z ich tierem).
 * Skaner trzyma kopie, czytnik wpisuje je do bazy techwebu, a flatpacker robi z nich paczki.
 */
/datum/machine_schematic
	/// Nazwa maszyny pokazywana w oknach
	var/name
	/// Typ płytki, którą flatpacker drukuje do paczki
	var/board_type
	/// Maszyna, którą płytka buduje (płytki z wyborem typu, np. automaty, pamiętają wybór)
	var/build_path
	/// Części poza płytką: typ = ilość (stosy liczone w sztukach)
	var/list/part_types = list()
	/// Najwyższy tier części
	var/tier = 1
	/// Maszyna z czarnej listy, zeskanowana narzędziem z uplinku
	var/illegal = FALSE

/datum/machine_schematic/proc/get_key()
	return "[build_path]-[tier]"

/// Wypełnia schemat z działającej maszyny. Zwraca FALSE, jeśli maszyny nie da się opisać.
/datum/machine_schematic/proc/read_machine(obj/machinery/machine)
	var/obj/item/circuitboard/board = machine.circuit
	if(!istype(board) || !board.build_path)
		return FALSE
	board_type = board.type
	build_path = board.build_path
	var/obj/machinery/target = build_path
	name = initial(target.name)
	part_types = list()
	for(var/obj/item/part in machine.component_parts)
		if(part == board)
			continue
		if(isstack(part))
			var/obj/item/stack/stack = part
			part_types[part.type] += stack.amount
		else
			part_types[part.type] += 1
	tier = mechanic_parts_tier(part_types)
	illegal = mechanic_is_blacklisted(machine.type)
	return TRUE

/datum/machine_schematic/proc/copy()
	var/datum/machine_schematic/clone = new
	clone.name = name
	clone.board_type = board_type
	clone.build_path = build_path
	clone.part_types = part_types.Copy()
	clone.tier = tier
	clone.illegal = illegal
	return clone

/// Opis do okien: nazwa z tierem
/datum/machine_schematic/proc/display_name()
	return "[name] (tier [tier])"

/// Schematy odczytane przez czytniki podłączone do tej sieci badań: klucz = /datum/machine_schematic
/datum/techweb/var/list/machine_schematics = list()

/datum/techweb/Destroy()
	for(var/key in machine_schematics)
		qdel(machine_schematics[key])
	machine_schematics = null
	return ..()

/// Wpisuje schemat do bazy i odblokowuje projekt płytki, jeśli taki istnieje. Zwraca TRUE dla nowego schematu.
/datum/techweb/proc/add_machine_schematic(datum/machine_schematic/schematic)
	var/key = schematic.get_key()
	if(machine_schematics[key])
		return FALSE
	machine_schematics[key] = schematic
	if(!schematic.illegal)
		var/datum/design/board_design = mechanic_design_for(schematic.board_type)
		if(board_design && !researched_designs[board_design.id])
			add_design(board_design, TRUE)
	return TRUE
