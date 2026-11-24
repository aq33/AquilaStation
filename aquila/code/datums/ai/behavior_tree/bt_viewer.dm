// Podgląd drzewa zachowań dla adminów. tg ma okno TGUI BehaviorTreeViewer (code/datums/ai/bt_viewer.dm);
// u nas tekstowy zrzut stanu drzewa i tablicy (blackboard) do czatu, bez nowego okna.

/world/AVerbsDebug()
	. = ..()
	. += /client/proc/view_behavior_tree

/client/proc/view_behavior_tree(mob/target in world)
	set name = "Pokaż drzewo zachowań"
	set category = "Debug"
	if(!check_rights(R_DEBUG))
		return
	var/datum/ai_controller/controller = target?.ai_controller
	if(!controller)
		to_chat(src, span_warning("[target] nie ma kontrolera AI."))
		return
	to_chat(src, examine_block(controller.behavior_tree_report()))

/// Tekst stanu kontrolera: drzewo (* działa, o czeka) albo planning subtrees i tablica
/datum/ai_controller/proc/behavior_tree_report()
	var/list/out = list("<b>[pawn] ([type])</b>", "Stan AI: [ai_status]")
	if(uses_behavior_tree())
		out += "Drzewo: [behavior_tree_json || "behavior_nodes"]"
		for(var/line in get_behavior_tree_lines())
			out += replacetext(line, "  ", "&nbsp;&nbsp;")
	else
		out += "Planning subtrees:"
		for(var/datum/ai_planning_subtree/subtree as anything in planning_subtrees)
			out += "  [subtree.type]"
		for(var/datum/ai_behavior/behavior as anything in current_behaviors)
			out += "  * [behavior.type]"
	out += "<b>Tablica:</b>"
	for(var/key in blackboard)
		var/value = blackboard[key]
		out += "  [key] = [islist(value) ? "list([length(value)])" : "[value]"]"
	return jointext(out, "<br>")
