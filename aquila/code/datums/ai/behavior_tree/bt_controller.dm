/*
 * Drzewa zachowań (behavior trees) z tgstation w wariancie hybrydowym.
 *
 * tg zastąpiło planning subtrees drzewami w całości. U nas 76 kontrolerów dalej planuje przez planning_subtrees
 * i singletony /datum/ai_behavior (code/datums/ai/_ai_controller.dm, bez zmian). Kontroler, który ustawia
 * behavior_tree_json (ścieżka źródłowego .bt.json względna od repo) albo behavior_nodes (lista typów/opisów węzłów),
 * idzie drzewem: SelectBehaviors() tika korzeń, a liście (/datum/bt_node/ai_behavior) same ruszają pionkiem.
 *
 * Węzły drzewa są instancjami na kontroler (tg), więc trzymają własny stan (running, cooldowny, indeksy dzieci).
 *
 * Pliki .bt.json kompiluje tools/build_bt.py (podstawia define'y, SECONDS itd.) do aquila/behavior_trees/ i zapisuje
 * indeks aquila/code/datums/ai/behavior_tree/_compiled_trees.dm, który dołącza skompilowane drzewa do .rsc.
 * Po zmianie .bt.json albo użytego w nim define'a uruchom `python tools/build_bt.py`; CI sprawdza to przez --check.
 */

/datum/ai_controller
	/// Źródłowy .bt.json (ścieżka od korzenia repo). Kontroler z tym ustawionym idzie drzewem zachowań.
	var/behavior_tree_json = null
	/// Korzenie drzewa: na starcie typy albo opisy węzłów, po initialize_behavior_tree() instancje /datum/bt_node
	var/list/behavior_nodes
	/// Indeks ostatniego liścia, który zwrócił BT_RUNNING (podpowiedź między tikami)
	var/active_execution_index = 0
	/// Indeks liścia tikanego w tej chwili (0 poza tikiem)
	var/ticking_execution_index = 0
	/// Ustawiane przez cancel_current_plan() w trakcie tiku, żeby rodzice przerwali bieżący przebieg
	var/cancelled_during_tick = FALSE
	/// Dziennik indeksów liści wykonanych od ostatniego odczytu podglądu (null bez podglądu)
	var/list/bt_execution_log = null
	/// override_id -> /datum/bt_node/subtree, miejsca na podmianę poddrzewa w czasie gry
	var/list/override_slots = null
	/// Dekoratory bez sygnałów, sprawdzane co tik
	var/list/polling_observers = null

/datum/ai_controller/New(atom/new_pawn)
	initialize_behavior_tree()
	return ..()

/datum/ai_controller/Destroy(force)
	. = ..()
	QDEL_LIST(behavior_nodes)
	override_slots = null
	polling_observers = null

/// TRUE, gdy kontroler idzie drzewem zachowań zamiast planning subtrees
/datum/ai_controller/proc/uses_behavior_tree()
	return LAZYLEN(behavior_nodes) > 0

/datum/ai_controller/SelectBehaviors(delta_time)
	if(!uses_behavior_tree())
		return ..()
	cancelled_during_tick = FALSE
	if(LAZYLEN(polling_observers))
		for(var/datum/bt_node/decorator/dec as anything in polling_observers.Copy())
			dec.poll_condition(src)
	for(var/datum/bt_node/node as anything in behavior_nodes)
		if(node.tick(src, delta_time) == BT_RUNNING)
			break

/// Drzewo nie „zawodzi planowania”: brak bieżących /datum/ai_behavior to u niego normalny stan
/datum/ai_controller/planning_failed()
	if(uses_behavior_tree())
		return
	return ..()

/datum/ai_controller/CancelActions()
	. = ..()
	if(uses_behavior_tree())
		cancel_current_plan()

/datum/ai_controller/UnpossessPawn(destroy)
	reset_bt_tick_states()
	return ..()

/datum/ai_controller/should_idle()
	if(uses_behavior_tree() && active_execution_index)
		return FALSE
	return ..()

/datum/ai_controller/get_minimum_distance()
	if(uses_behavior_tree())
		return isnull(blackboard[BB_CURRENT_MIN_MOVE_DISTANCE]) ? 1 : blackboard[BB_CURRENT_MIN_MOVE_DISTANCE]
	return ..()

/// Przerywa bieżący plan drzewa: wszystkie węzły wracają do stanu początkowego, działające liście kończą się porażką
/datum/ai_controller/proc/cancel_current_plan()
	active_execution_index = 0
	cancelled_during_tick = TRUE
	reset_bt_tick_states()

/// Podmienia korzenie drzewa na nowe (typy albo opisy) i buduje je od nowa
/datum/ai_controller/proc/replace_behavior_nodes(list/new_nodes)
	var/list/old_nodes = behavior_nodes
	if(uses_behavior_tree())
		reset_bt_tick_states()
	behavior_nodes = new_nodes
	behavior_tree_json = null
	initialize_behavior_tree()
	QDEL_LIST(old_nodes)

/// Rozwiązuje dzieci kompozytu, dekoratora albo poddrzewa zadeklarowane na typie
/datum/ai_controller/proc/resolve_node_children(datum/bt_node/node)
	if(istype(node, /datum/bt_node/composite))
		var/datum/bt_node/composite/comp = node
		if(!LAZYLEN(comp.children_typepaths) || LAZYLEN(comp.children))
			return
		var/list/resolved_children = list()
		for(var/child_type in comp.children_typepaths)
			var/list/config = comp.children_typepaths[child_type]
			var/datum/bt_node/child = resolve_child_node(child_type, config)
			if(isnull(child))
				stack_trace("BT composite [node.type] references unknown child type [child_type]")
				continue
			resolved_children += child
		comp.children = resolved_children
	else if(istype(node, /datum/bt_node/decorator))
		var/datum/bt_node/decorator/dec = node
		if(isnull(dec.child_typepath) || !isnull(dec.child))
			return
		dec.child = resolve_child_node(dec.child_typepath, null)
		if(isnull(dec.child))
			stack_trace("BT decorator [node.type] references unknown child type [dec.child_typepath]")
	else if(istype(node, /datum/bt_node/subtree))
		var/datum/bt_node/subtree/sub = node
		if(!isnull(sub.behavior_nodes) && isnull(sub.root))
			sub.root = build_node_from_descriptor(sub.behavior_nodes)
		else if(!isnull(sub.behavior_tree_json) && isnull(sub.root))
			var/list/raw_desc = load_bt_descriptor(sub.behavior_tree_json)
			if(isnull(raw_desc))
				stack_trace("BT subtree [sub.type] could not load [sub.behavior_tree_json]")
				return
			if(LAZYLEN(sub.bindings) || !isnull(raw_desc[BT_DESC_BINDINGS]))
				raw_desc = apply_bindings_to_descriptor(raw_desc, sub.bindings)
			sub.root = build_node_from_descriptor(raw_desc)

/datum/ai_controller/proc/resolve_child_node(child_type, list/config)
	if(!ispath(child_type, /datum/bt_node))
		return null
	var/datum/bt_node/child = new child_type
	if(config)
		child.configure(config)
	resolve_node_children(child)
	return child

/datum/ai_controller/proc/get_or_build_node(entry)
	if(ispath(entry))
		if(!ispath(entry, /datum/bt_node))
			stack_trace("get_or_build_node() received non-BT typepath: [entry]")
			return null
		var/datum/bt_node/node = new entry
		resolve_node_children(node)
		return node
	if(islist(entry))
		return build_node_from_descriptor(entry)
	stack_trace("get_or_build_node() received unexpected entry type: [entry]")
	return null

/**
 * Czyta skompilowany opis drzewa dla źródłowego .bt.json.
 * AQUILA: najpierw z indeksu w .rsc (GLOB.bt_compiled_trees), potem z dysku obok .dmb, jak w tg.
 * Zwraca świeżą listę (json_decode), więc można ją zmieniać.
 */
/proc/load_bt_descriptor(json_path)
	var/compiled = GLOB.bt_compiled_trees[json_path]
	var/text
	if(compiled)
		text = file2text(compiled)
	else
		var/compiled_path = BT_COMPILED_PATH(json_path)
		if(fexists(compiled_path))
			text = file2text(file(compiled_path))
	if(!text)
		return null
	return json_decode(text)

/datum/ai_controller/proc/load_tree_from_json(json_path)
	var/list/desc = load_bt_descriptor(json_path)
	if(isnull(desc))
		return null
	return build_node_from_descriptor(desc)

/// Łączy wartości z miejsca wywołania z domyślnymi z deklaracji i podstawia „$nazwa” w opisie
/datum/ai_controller/proc/apply_bindings_to_descriptor(list/desc, list/call_site_bindings)
	var/list/merged = list()
	var/list/declared = desc[BT_DESC_BINDINGS]
	for(var/name in declared)
		merged[name] = declared[name]["default"]
	for(var/name in call_site_bindings)
		merged[name] = call_site_bindings[name]
	return substitute_bt_bindings(desc, merged)

/datum/ai_controller/proc/substitute_bt_bindings(list/desc, list/merged)
	var/list/out = list()
	for(var/key in desc)
		if(key == BT_DESC_BINDINGS)
			continue
		var/value = desc[key]
		if(islist(value))
			out[key] = substitute_bt_bindings_in_list(value, merged)
		else if(istext(value) && copytext(value, 1, 2) == "$")
			var/binding_name = copytext(value, 2)
			out[key] = isnull(merged[binding_name]) ? value : merged[binding_name]
		else
			out[key] = value
	return out

/datum/ai_controller/proc/substitute_bt_bindings_in_list(list/input, list/merged)
	var/list/resolved_list = list()
	for(var/item in input)
		var/assoc_value = (isnum(item) || islist(item)) ? null : input[item]
		if(!isnull(assoc_value))
			if(islist(assoc_value))
				resolved_list[item] = substitute_bt_bindings_in_list(assoc_value, merged)
			else if(istext(assoc_value) && copytext(assoc_value, 1, 2) == "$")
				var/binding_name = copytext(assoc_value, 2)
				resolved_list[item] = isnull(merged[binding_name]) ? assoc_value : merged[binding_name]
			else
				resolved_list[item] = assoc_value
		else if(islist(item))
			resolved_list += list(substitute_bt_bindings(item, merged))
		else if(istext(item) && copytext(item, 1, 2) == "$")
			var/binding_name = copytext(item, 2)
			var/resolved = isnull(merged[binding_name]) ? item : merged[binding_name]
			if(islist(resolved))
				resolved_list += list(resolved)
			else
				resolved_list += resolved
		else
			resolved_list += item
	return resolved_list

/**
 * Buduje węzeł (z dziećmi) z opisu. BT_DESC_TYPE i BT_DESC_CHILDREN zużywa sam, pozostałe klucze trafiają do vars węzła.
 * Tekst zaczynający się od „/”, który jest ścieżką typu, zamienia na typ.
 */
/datum/ai_controller/proc/build_node_from_descriptor(list/desc)
	var/raw_type = desc[BT_DESC_TYPE]
	if(!raw_type)
		return null
	var/node_type = ispath(raw_type) ? raw_type : text2path(raw_type)
	if(isnull(node_type))
		stack_trace("build_node_from_descriptor(): unknown typepath '[raw_type]'")
		return null
	var/datum/bt_node/node = new node_type
	for(var/key in desc)
		if(key == BT_DESC_TYPE || key == BT_DESC_CHILDREN || key == BT_DESC_BINDINGS)
			continue
		var/value = desc[key]
		if(islist(value))
			var/list/resolved = value
			for(var/i in 1 to length(resolved))
				if(istext(resolved[i]) && copytext(resolved[i], 1, 2) == "/")
					var/as_path = text2path(resolved[i])
					if(!isnull(as_path))
						resolved[i] = as_path
		else if(istext(value) && copytext(value, 1, 2) == "/")
			var/as_path = text2path(value)
			if(!isnull(as_path))
				value = as_path
		if(!(key in node.vars))
			stack_trace("build_node_from_descriptor(): [node_type] has no var '[key]'")
			continue
		node.vars[key] = value
	resolve_node_children(node)
	var/list/children_descs = desc[BT_DESC_CHILDREN]
	if(LAZYLEN(children_descs))
		node.set_descriptor_children(children_descs, src)
	return node

/// Buduje drzewo tego kontrolera z behavior_tree_json albo behavior_nodes i je finalizuje
/datum/ai_controller/proc/initialize_behavior_tree()
	if(!isnull(behavior_tree_json) && !LAZYLEN(behavior_nodes))
		var/datum/bt_node/root = load_tree_from_json(behavior_tree_json)
		if(isnull(root))
			stack_trace("[type] failed to load behavior tree [behavior_tree_json]")
			return
		behavior_nodes = list(root)
		finalize_tree()
		return
	if(!LAZYLEN(behavior_nodes))
		return
	var/list/temp_subtree_list = list()
	if(!isnull(behavior_nodes[BT_DESC_TYPE]))
		var/datum/bt_node/node_instance = get_or_build_node(behavior_nodes)
		if(isnull(node_instance))
			stack_trace("[type]'s behavior_nodes BT descriptor could not be built")
		else
			temp_subtree_list += node_instance
	else
		for(var/entry in behavior_nodes)
			if(istype(entry, /datum/bt_node))
				temp_subtree_list += entry
				continue
			var/datum/bt_node/node_instance = get_or_build_node(entry)
			if(isnull(node_instance))
				stack_trace("[type]'s behavior_nodes contains unknown entry: [entry]")
				continue
			temp_subtree_list += node_instance
	behavior_nodes = temp_subtree_list
	finalize_tree()

/// Ustawia owning_controller i parent_node, rejestruje miejsca podmian i nadaje indeksy wykonania
/datum/ai_controller/proc/finalize_tree()
	if(!LAZYLEN(behavior_nodes))
		return
	override_slots = null
	var/list/to_visit = behavior_nodes.Copy()
	for(var/datum/bt_node/root in behavior_nodes)
		root.parent_node = null
	var/index = 1
	while(index <= length(to_visit))
		var/datum/bt_node/node = to_visit[index++]
		node.finalize_node(src, to_visit)
	var/counter = 1
	for(var/datum/bt_node/root in behavior_nodes)
		counter = root.assign_execution_indices(counter)

/datum/ai_controller/proc/reset_bt_tick_states()
	if(!LAZYLEN(behavior_nodes))
		return
	var/list/to_visit = behavior_nodes.Copy()
	var/index = 1
	while(index <= length(to_visit))
		var/datum/bt_node/node = to_visit[index++]
		node.reset_tick_state()
		node.collect_reset_children(to_visit)

/// Wstawia albo zdejmuje podmianę poddrzewa w miejscu o danym id
/datum/ai_controller/proc/set_behavior_tree_override(id, override_subtree)
	var/datum/bt_node/subtree/slot = LAZYACCESS(override_slots, id)
	if(isnull(slot))
		return
	var/current_type = isnull(slot.override_node) ? null : slot.override_node.type
	if(current_type == override_subtree)
		return
	if(slot.override_node)
		slot.override_node.reset_tick_state()
		QDEL_NULL(slot.override_node)
	if(isnull(override_subtree))
		finalize_tree()
		SEND_SIGNAL(pawn, COMSIG_AI_OVERRIDE_SLOT_CHANGED(id), null)
		return
	var/datum/bt_node/subtree/new_node = new override_subtree
	resolve_node_children(new_node)
	slot.override_node = new_node
	finalize_tree()
	cancel_current_plan()
	SEND_SIGNAL(pawn, COMSIG_AI_OVERRIDE_SLOT_CHANGED(id), override_subtree)

/// Linie stanu całego drzewa (* działa, o czeka) do podglądu
/datum/ai_controller/proc/get_behavior_tree_lines()
	var/list/lines = list()
	for(var/datum/bt_node/root as anything in behavior_nodes)
		root.append_full_tree_state(lines, "")
	return lines

// Ruch: tg wysyła sygnał, gdy ścieżka się poddaje, a liść move_to_target na nim kończy się porażką
/datum/ai_movement/increment_pathing_failures(datum/ai_controller/controller)
	if(controller.uses_behavior_tree() && controller.consecutive_pathing_attempts + 1 >= max_pathing_attempts && controller.pawn)
		SEND_SIGNAL(controller.pawn, COMSIG_MOB_AI_MOVEMENT_FAILED)
	return ..()

/datum/ai_movement/start_moving_towards(datum/ai_controller/controller, atom/current_movement_target, min_distance)
	. = ..()
	if(controller.pawn)
		SEND_SIGNAL(controller.pawn, COMSIG_MOB_AI_MOVEMENT_STARTED, current_movement_target)
