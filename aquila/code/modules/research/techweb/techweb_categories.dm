// AQUILA - kategorie węzłów sieci badań (okno R&D: Techweb/TechTree.tsx). Kategoria liczy się z id węzła,
// a nie z nazwy, żeby działała też w wersji angielskiej. Nowy węzeł bez pasującego id trafia do inżynierii.
// Każda kategoria to osobne drzewko: zaczyna się od swojego węzła startowego (wymaga tylko podstaw), a wymagania
// z innych kategorii są usuwane przy starcie podsystemu badań, poza krótką listą celowych wyjątków.
// Koszty i poziomy technologii zostają bez zmian.

/// id węzła -> kategoria, sprawdzane najpierw (wyjątki od reguł niżej)
GLOBAL_LIST_INIT(techweb_category_overrides, list(
	"emp_adv" = "engineering",
	"emp_super" = "engineering",
	"adv_shells" = "computing",
	"movable_shells" = "computing",
	"qswapper" = "bluespace",
	"ai" = "robotics",
	"mmi" = "robotics",
	"nanite_bio" = "computing",
	"nanite_neural" = "computing",
	"bitrunning" = "computing",
	"exodrone" = "ship",
	"ftl_slipstream" = "ship",
	"area_inerts" = "ship",
	"job_itemsets" = "robotics",
	"job_itemsets_sec" = "robotics",
))

/// Fragment id -> kategoria; pierwsza pasująca reguła wygrywa
GLOBAL_LIST_INIT(techweb_category_rules, list(
	list("ai_", "computing"),
	list("surg", "medical"), list("bio", "medical"), list("clon", "medical"), list("cryo", "medical"),
	list("autodoc", "medical"), list("autoinjector", "medical"), list("botany", "medical"),
	list("medical_weapons", "medical"), list("xenoorgan", "medical"), list("janitor", "medical"),
	list("cyborg", "robotics"), list("robotics", "robotics"), list("posibrain", "robotics"), list("ipc", "robotics"),
	list("cyber", "robotics"), list("subdermal", "robotics"), list("bci", "robotics"), list("neural", "robotics"),
	list("integrated_huds", "robotics"), list("nvg", "robotics"),
	list("mech", "exosuits"), list("mod", "exosuits"), list("clusterbang", "exosuits"),
	list("weapon", "weapons"), list("ballistic", "weapons"), list("ammo", "weapons"), list("mines", "weapons"),
	list("torpedo", "weapons"), list("warhead", "weapons"), list("countermeasure", "weapons"),
	list("missile", "weapons"), list("sec_basic", "weapons"), list("gravity_gun", "weapons"),
	list("wormholegun", "weapons"), list("syndicate", "weapons"),
	list("fighter", "ship"), list("vehicle", "ship"), list("shuttle", "ship"), list("ship", "ship"), list("maa_", "ship"),
	list("bluespace", "bluespace"), list("anomaly", "bluespace"), list("nullspace", "bluespace"),
	list("alien_engi", "bluespace"), list("bagofholding", "bluespace"),
	list("nanite", "computing"), list("circuit", "computing"), list("comp", "computing"),
	list("server", "computing"), list("telecomms", "computing"), list("recordkeeping", "computing"),
))

/// Węzeł startowy każdej kategorii: wymaga tylko podstaw (base)
GLOBAL_LIST_INIT(techweb_category_roots, list(
	"medical" = "biotech",
	"robotics" = "robotics",
	"exosuits" = "mecha",
	"weapons" = "weaponry",
	"ship" = "fighter_fabrication",
	"bluespace" = "practical_bluespace",
	"computing" = "comptech",
	"engineering" = "engineering",
))

/// Celowe wymagania z innej kategorii (id węzła -> wymagania, które zostają), tylko tam, gdzie mają sens fabularny
GLOBAL_LIST_INIT(techweb_cross_prereq_keep, list(
	"mecha_phazon" = list("micro_bluespace"),
	"fighter_tier3" = list("bluespace_travel"),
	"mod_anomaly" = list("anomaly_research"),
	"bluespace_butt" = list("exp_surgery"),
	"destructive_beam_weapons" = list("bluespace_power"),
))

/datum/techweb_node/proc/aq_category()
	if(GLOB.techweb_category_overrides[id])
		return GLOB.techweb_category_overrides[id]
	var/lower_id = lowertext(id)
	for(var/list/rule as anything in GLOB.techweb_category_rules)
		if(findtext(lower_id, rule[1]))
			return rule[2]
	return "engineering"

/obj/machinery/computer/rdconsole/ui_static_data(mob/user)
	. = ..()
	var/list/node_cache = .["static_data"]?["node_cache"]
	if(!node_cache)
		return
	for(var/node_id in SSresearch.techweb_nodes)
		var/datum/techweb_node/node = SSresearch.techweb_nodes[node_id]
		var/list/entry = node_cache["[compress_id(node.id)]"]
		if(entry)
			entry["category"] = node.aq_category()

/datum/controller/subsystem/research/calculate_techweb_nodes()
	aq_regroup_techweb_prereqs()
	return ..()

/// Usuwa wymagania z innych kategorii. Węzeł, który miał tylko obce wymagania, dostaje węzeł startowy swojej kategorii.
/// Zostają wymagania z tej samej kategorii (podzbiór dotychczasowej sieci) i wyjątki, więc nie powstają cykle.
/datum/controller/subsystem/research/proc/aq_regroup_techweb_prereqs()
	var/has_base = !!techweb_nodes["base"]
	for(var/node_id in techweb_nodes)
		var/datum/techweb_node/node = techweb_nodes[node_id]
		if(node.id == "base")
			continue
		var/category = node.aq_category()
		var/root_id = GLOB.techweb_category_roots[category]
		if(node.id == root_id)
			node.prereq_ids = has_base ? list("base") : list()
			continue
		var/list/keep = GLOB.techweb_cross_prereq_keep[node.id]
		var/list/kept = list()
		var/had_prereqs = length(node.prereq_ids)
		for(var/prereq_id in node.prereq_ids)
			var/datum/techweb_node/prereq = techweb_nodes[prereq_id]
			if(!prereq)
				continue
			if(prereq_id == "base" || prereq.aq_category() == category || (prereq_id in keep))
				kept += prereq_id
		if(had_prereqs && !length(kept))
			kept += techweb_nodes[root_id] ? root_id : (has_base ? "base" : null)
			listclearnulls(kept)
		node.prereq_ids = kept
