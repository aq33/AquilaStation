// AQUILA - połączenia rur w szablonie wczytanym obok innego (części ruin z generatora, losowe pokoje) muszą działać
// w obie strony. Rura z nowej części potrafi wziąć za węzeł urządzenie, które ma już swój węzeł w tę stronę; wtedy
// budowa sieci (build_pipeline_blocking) woła set_pipenet() na urządzeniu bez tej rury w nodes i sypie
// „list index out of bounds” (misja Opuszczona stacja: część syndicate_listening; pokój gułagu sk_rdm_glg_05).
// Wołane z setup_template_machinery() między atmos_init() a budową sieci (hook w code/controllers/subsystem/air.dm).

/// Uzgadnia jednostronne połączenia: zwykła rura z wolnym wejściem w tę stronę dostaje węzeł z powrotem,
/// a w pozostałych przypadkach (urządzenie z zajętym wejściem) połączenie jest ucinane po stronie, która je wzięła
/datum/controller/subsystem/air/proc/fix_template_node_links(list/atmos_machines)
	for(var/obj/machinery/atmospherics/machine as anything in atmos_machines)
		for(var/obj/machinery/atmospherics/node as anything in template_links(machine))
			if(!node || (machine in template_links(node)))
				continue
			if(link_back(node, machine))
				continue
			if(istype(machine, /obj/machinery/atmospherics/pipe/layer_manifold))
				var/obj/machinery/atmospherics/pipe/layer_manifold/manifold = machine
				manifold.front_nodes -= node
				manifold.back_nodes -= node
			var/index = machine.nodes.Find(node)
			if(index)
				machine.nodes[index] = null

/// Węzły urządzenia; adapter warstw trzyma je w osobnych listach
/datum/controller/subsystem/air/proc/template_links(obj/machinery/atmospherics/machine)
	if(istype(machine, /obj/machinery/atmospherics/pipe/layer_manifold))
		var/obj/machinery/atmospherics/pipe/layer_manifold/manifold = machine
		return manifold.get_all_connected_nodes()
	return machine.nodes.Copy()

/// Dopina machine jako węzeł zwykłej rury node, jeśli rura ma wolne wejście skierowane na machine
/datum/controller/subsystem/air/proc/link_back(obj/machinery/atmospherics/node, obj/machinery/atmospherics/machine)
	if(!istype(node, /obj/machinery/atmospherics/pipe) || istype(node, /obj/machinery/atmospherics/pipe/layer_manifold))
		return FALSE
	var/list/connects = node.get_node_connects()
	for(var/j in 1 to node.device_type)
		if(!node.nodes[j] && get_step(node, connects[j]) == get_turf(machine) && node.can_be_node(machine, j))
			node.nodes[j] = machine
			return TRUE
	return FALSE
