// AQUILA - kategorie węzłów w oknie R&D (Techweb/TechTree.tsx). Tylko podział w oknie: sieć badań,
// wymagania i koszty się nie zmieniają. Kategoria liczy się z id węzła, a nie z nazwy, żeby działała
// też w wersji angielskiej. Nowy węzeł bez pasującego id trafia do inżynierii.

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
))

/// Fragment id -> kategoria; pierwsza pasująca reguła wygrywa
GLOBAL_LIST_INIT(techweb_category_rules, list(
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
