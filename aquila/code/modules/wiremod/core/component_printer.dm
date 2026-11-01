// Drukarka komponentów zostaje naszym fabrykatorem modułowym (silos, kolejka, okno fabrykatora).
// Z tg doszło łączenie z układem: uderzenie układem w drukarkę pozwala drukować komponenty z okna układu
// i oddawać do niej odłączone komponenty. Bez duplikatora modułów i bez okna ComponentPrinter z tg.
/obj/machinery/modular_fabricator/component_printer
	name = "drukarka komponentów"
	desc = "Wytwarza komponenty do budowy układów scalonych. Uderz w nią układem, aby je połączyć."
	icon = 'aquila/icons/obj/wiremod/wiremod_fab.dmi'
	icon_state = "fab-idle"
	circuit = /obj/item/circuitboard/machine/component_printer

	remote_materials = TRUE
	auto_link = TRUE
	can_sync = TRUE

	//Quick.
	minimum_construction_time = 5

	stored_research_type = /datum/techweb/specialized/autounlocking/component_printer

	categories = WIREMODE_CATEGORIES

/obj/machinery/modular_fabricator/component_printer/crowbar_act(mob/living/user, obj/item/tool)
	if(..())
		return TRUE
	return default_deconstruction_crowbar(tool)

/obj/machinery/modular_fabricator/component_printer/screwdriver_act(mob/living/user, obj/item/tool)
	if(..())
		return TRUE
	return default_deconstruction_screwdriver(user, "fab-o", "fab-idle", tool)

/obj/machinery/modular_fabricator/component_printer/attackby(obj/item/tool, mob/living/user, params)
	var/obj/item/integrated_circuit/circuit
	if(istype(tool, /obj/item/integrated_circuit))
		circuit = tool
	else if(istype(tool, /obj/item/circuit_component/module))
		var/obj/item/circuit_component/module/module = tool
		circuit = module.internal_circuit
	if(circuit)
		circuit.linked_component_printer = WEAKREF(src)
		circuit.update_static_data_for_all_viewers()
		balloon_alert(user, "połączono z układem scalonym")
		return TRUE
	if(istype(tool, /obj/item/circuit_component) && user.a_intent != INTENT_HARM)
		recycle_component(user, tool)
		return TRUE
	return ..()

/// Odzysk materiałów z komponentu, także z okna połączonego układu.
/obj/machinery/modular_fabricator/component_printer/proc/recycle_component(mob/living/user, obj/item/circuit_component/component)
	var/datum/component/material_container/materials = get_material_container()
	if(!materials)
		return FALSE
	var/amount_inserted = materials.insert_item(component)
	if(amount_inserted)
		to_chat(user, span_notice("[src] przetwarza [component] o wartości [amount_inserted / MINERAL_MATERIAL_AMOUNT] arkuszy materiału"))
		qdel(component)
		return TRUE
	to_chat(user, span_warning("[src] odrzuca [component]"))
	return FALSE

/// Komponenty, które da się wydrukować z okna połączonego układu: ścieżka komponentu -> id projektu.
/obj/machinery/modular_fabricator/component_printer/proc/current_unlocked_designs()
	. = list()
	for(var/design_id in stored_research?.researched_designs)
		var/datum/design/design = SSresearch.techweb_design_by_id(design_id)
		if(!design || !(design.build_type & COMPONENT_PRINTER) || !ispath(design.build_path, /obj/item/circuit_component))
			continue
		.[design.build_path] = design.id

/// Drukuje od razu jeden komponent dla połączonego układu.
/obj/machinery/modular_fabricator/component_printer/proc/print_component(typepath)
	if(machine_stat & (NOPOWER|BROKEN))
		return
	var/list/designs = current_unlocked_designs()
	var/datum/design/design = SSresearch.techweb_design_by_id(designs[typepath])
	if(!design)
		return
	var/datum/component/material_container/materials = get_material_container()
	if(!materials)
		return
	var/coefficient = design_cost_coefficient(design)
	if(!materials.has_materials(design.materials, coefficient))
		return
	materials.use_materials(design.materials, coefficient)
	return new design.build_path(drop_location())

/obj/item/circuitboard/machine/component_printer
	name = "drukarka komponentów (płytka maszyny)"
	icon_state = "science"
	build_path = /obj/machinery/modular_fabricator/component_printer
	req_components = list(
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/reagent_containers/glass/beaker = 2,
	)
