// Sieć kabli ethernet dla zdecentralizowanego AI (port Yogstation, code/modules/mob/living/silicon/ai/ai_network)
// W Yogu sieci łączą się i dzielą przyrostowo. U nas przy każdej zmianie przebudowujemy całość:
// kabli i maszyn SI na mapie jest kilkadziesiąt, a kod jest dużo prostszy.

///Wszystkie sieci kabli ethernet
GLOBAL_LIST_EMPTY(ai_networks)
///Wszystkie kable ethernet
GLOBAL_LIST_EMPTY(ethernet_cables)
///Wszystkie maszyny SI (/obj/machinery/ai), które mogą wejść do sieci
GLOBAL_LIST_EMPTY(ai_machines)
///TRUE, gdy topologia się zmieniła i sieci trzeba przebudować
GLOBAL_VAR_INIT(ai_network_rebuild_queued, FALSE)

/datum/ai_network
	///Kable należące do tej sieci
	var/list/obj/structure/ethernet_cable/cables = list()
	///Maszyny SI podłączone do tej sieci
	var/list/obj/machinery/ai/nodes = list()
	///System zasobów. Sieci połączone nadajnikami mają wspólny.
	var/datum/ai_os/resources

/datum/ai_network/New()
	GLOB.ai_networks += src

/datum/ai_network/Destroy()
	for(var/obj/structure/ethernet_cable/cable as anything in cables)
		if(cable.network == src)
			cable.network = null
	for(var/obj/machinery/ai/machine as anything in nodes)
		if(machine.network == src)
			machine.network = null
	cables.Cut()
	nodes.Cut()
	resources?.networks -= src
	resources = null
	GLOB.ai_networks -= src
	return ..()

///Sieci połączone z nami nadajnikami (bez nas samych)
/datum/ai_network/proc/get_linked_networks()
	. = list()
	for(var/obj/machinery/ai/networking/dish in nodes)
		var/datum/ai_network/other = dish.partner?.network
		if(other && other != src)
			. |= other

///Zaznacza, że sieci trzeba przebudować. Przebudowa nastąpi w następnym ticku albo przy pierwszym zapytaniu o sieć.
/proc/queue_ai_network_rebuild()
	if(GLOB.ai_network_rebuild_queued)
		return
	GLOB.ai_network_rebuild_queued = TRUE
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(flush_ai_network_rebuild)), 0)

/proc/flush_ai_network_rebuild()
	if(GLOB.ai_network_rebuild_queued)
		rebuild_ai_networks()

///Zwraca system zasobów sieci, do której podłączony jest kabel na kafelku obiektu
/proc/get_ai_os_at(atom/target)
	flush_ai_network_rebuild()
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return null
	var/obj/structure/ethernet_cable/cable = locate() in target_turf
	return cable?.network?.resources

/**
 * Przebudowuje wszystkie sieci ethernet i przypisuje im systemy zasobów (/datum/ai_os).
 * Sieci połączone nadajnikami tworzą grupę ze wspólnym systemem. Grupa zatrzymuje system,
 * którego używała większość jej maszyn, więc przydziały SI przetrwają przecięcie kabla.
 */
/proc/rebuild_ai_networks()
	GLOB.ai_network_rebuild_queued = FALSE

	// Stary system każdej maszyny i SI
	var/list/old_os_of = list()
	for(var/obj/machinery/ai/machine as anything in GLOB.ai_machines)
		if(machine.network?.resources)
			old_os_of[machine] = machine.network.resources
	var/list/datum/ai_os/old_systems = list()
	for(var/datum/ai_network/old_network as anything in GLOB.ai_networks)
		if(old_network.resources)
			old_systems |= old_network.resources
	var/list/old_os_of_ai = list()
	for(var/datum/ai_os/old_os as anything in old_systems)
		for(var/mob/living/silicon/ai/AI as anything in old_os.ai_list)
			old_os_of_ai[AI] = old_os

	for(var/datum/ai_network/old_network as anything in GLOB.ai_networks.Copy())
		qdel(old_network)

	// Kable: przeszukiwanie wszerz po połączeniach
	for(var/obj/structure/ethernet_cable/start_cable as anything in GLOB.ethernet_cables)
		if(start_cable.network || QDELETED(start_cable))
			continue
		var/datum/ai_network/new_network = new
		var/list/queue = list(start_cable)
		start_cable.network = new_network
		while(length(queue))
			var/obj/structure/ethernet_cable/cable = queue[length(queue)]
			queue.len--
			new_network.cables += cable
			for(var/obj/structure/ethernet_cable/next as anything in cable.connected)
				if(next.network || QDELETED(next))
					continue
				next.network = new_network
				queue += next

	// Maszyny: przykręcona maszyna stojąca na kablu wchodzi do jego sieci
	for(var/obj/machinery/ai/machine as anything in GLOB.ai_machines)
		machine.network = null
		if(QDELETED(machine) || !machine.anchored || !isturf(machine.loc))
			continue
		var/obj/structure/ethernet_cable/cable = locate() in machine.loc
		if(!cable?.network)
			continue
		machine.network = cable.network
		cable.network.nodes += machine

	// Grupy sieci połączonych nadajnikami
	var/list/list/datum/ai_network/groups = list()
	var/list/grouped = list()
	for(var/datum/ai_network/net as anything in GLOB.ai_networks)
		if(grouped[net])
			continue
		var/list/datum/ai_network/group = list()
		var/list/queue = list(net)
		grouped[net] = TRUE
		while(length(queue))
			var/datum/ai_network/current = queue[length(queue)]
			queue.len--
			group += current
			for(var/datum/ai_network/linked as anything in current.get_linked_networks())
				if(grouped[linked])
					continue
				grouped[linked] = TRUE
				queue += linked
		groups += list(group)

	// Każda grupa dostaje system zasobów: ten, z którego korzystało najwięcej jej maszyn (rdzenie z SI ważą więcej)
	var/list/datum/ai_os/claimed = list()
	var/list/new_group_os = list()
	for(var/list/datum/ai_network/group as anything in groups)
		var/list/votes = list()
		for(var/datum/ai_network/net as anything in group)
			for(var/obj/machinery/ai/machine as anything in net.nodes)
				var/datum/ai_os/previous = old_os_of[machine]
				if(!previous || claimed[previous])
					continue
				var/weight = 1
				if(istype(machine, /obj/machinery/ai/data_core) && (locate(/mob/living/silicon/ai) in machine))
					weight = 100
				votes[previous] += weight
		var/datum/ai_os/chosen
		var/best = 0
		for(var/datum/ai_os/candidate as anything in votes)
			if(votes[candidate] > best)
				best = votes[candidate]
				chosen = candidate
		if(!chosen)
			chosen = new /datum/ai_os
			new_group_os[chosen] = TRUE
		claimed[chosen] = TRUE
		chosen.networks = group.Copy()
		for(var/datum/ai_network/net as anything in group)
			net.resources = chosen

	// SI idzie za rdzeniem, w którym siedzi. Przydziały przenosimy, update_hardware() obetnie nadmiar.
	for(var/mob/living/silicon/ai/AI as anything in old_os_of_ai)
		if(QDELETED(AI))
			continue
		var/datum/ai_os/old_os = old_os_of_ai[AI]
		var/datum/ai_os/new_os = AI.get_ai_os()
		if(old_os == new_os)
			continue
		var/cpu = old_os.cpu_assigned[AI] || 0
		var/ram = old_os.ram_assigned[AI] || 0
		old_os.remove_ai(AI)
		if(new_os)
			new_os.add_ai(AI)
			new_os.cpu_assigned[AI] = cpu
			new_os.ram_assigned[AI] = ram

	for(var/datum/ai_os/old_os as anything in old_systems)
		if(!claimed[old_os])
			qdel(old_os)

	for(var/datum/ai_os/active_os as anything in claimed)
		active_os.update_hardware()

	// Rozłączenie: część sieci z rdzeniem odpadła od systemu SI, więc SI może się tam przenieść (jak w Yogu)
	for(var/datum/ai_os/split_os as anything in new_group_os)
		var/obj/machinery/ai/data_core/split_core = split_os.find_data_core()
		if(!split_core)
			continue
		var/list/datum/ai_os/left_behind = list()
		for(var/datum/ai_network/net as anything in split_os.networks)
			for(var/obj/machinery/ai/machine as anything in net.nodes)
				var/datum/ai_os/previous = old_os_of[machine]
				if(previous && !QDELETED(previous))
					left_behind |= previous
		for(var/datum/ai_os/old_os as anything in left_behind)
			for(var/mob/living/silicon/ai/AI as anything in old_os.ai_list)
				INVOKE_ASYNC(AI, TYPE_PROC_REF(/mob/living/silicon/ai, offer_network_switch), split_os)

///SI dostaje wybór, czy przenieść się do sieci, która właśnie się od niej odłączyła
/mob/living/silicon/ai/proc/offer_network_switch(datum/ai_os/new_os)
	if(!client || stat == DEAD)
		return
	var/obj/machinery/ai/data_core/core = new_os.find_data_core()
	if(!core)
		return
	var/new_choice = "Nowa sieć ([get_area_name(core, TRUE)])"
	var/choice = tgui_input_list(src, "Dwie sieci, z których korzystasz, zostały rozłączone. Gdzie przenieść główną świadomość?", "Rozłączenie sieci", list("Obecna sieć", new_choice))
	if(choice != new_choice)
		return
	core = new_os.find_data_core()
	if(QDELETED(src) || !core || !isaicore(loc))
		to_chat(src, span_warning("Coś poszło nie tak przy przenoszeniu. Zostajesz w obecnej sieci."))
		return
	core.transfer_AI(src)
