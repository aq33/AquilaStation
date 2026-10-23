// AQUILA - kuźnia amunicji: ręczny analizator (na wzór material_analyzer z Monkestation).
// Skanuje część, wyrób z kuźni albo piec łukowy i drukuje kartkę z wynikiem.

/obj/item/munitions_analyzer
	name = "analizator amunicji"
	desc = "Skaner do kuźni amunicji. Pokazuje, co dają materiał, stop, klasa i wypełnienie. Użyj w ręce, żeby wydrukować ostatni wynik."
	icon = 'icons/obj/device.dmi'
	icon_state = "adv_spectrometer"
	item_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	materials = list(/datum/material/iron = 500, /datum/material/glass = 200)
	/// Ostatni wynik do wydruku
	var/list/last_scan
	var/last_scan_name
	COOLDOWN_DECLARE(print_cooldown)

/obj/item/munitions_analyzer/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	var/list/lines = analyze(target)
	if(!length(lines))
		return
	playsound(src, 'sound/machines/ping.ogg', 20, FALSE)
	last_scan = lines
	last_scan_name = "[target]"
	to_chat(user, EXAMINE_BLOCK("<span class='notice'><b>[target]</b>\n[jointext(lines, "\n")]</span>"))

/// Pusta lista = nie ma czego skanować
/obj/item/munitions_analyzer/proc/analyze(atom/target)
	. = list()
	if(istype(target, /obj/machinery/munitions_forge/arc_forge))
		var/obj/machinery/munitions_forge/arc_forge/forge = target
		var/datum/component/material_container/container = forge.get_container()
		for(var/key in GLOB.munition_materials)
			var/datum/munition_material/M = GLOB.munition_materials[key]
			var/amount = container ? round(container.get_material_amount(M.material_type) / MINERAL_MATERIAL_AMOUNT, 0.1) : 0
			. += "<b>[M.name]</b> ([amount] ark.): [jointext(M.stat_lines(), " ")]"
		. += "Stop dwóch materiałów: średnia liczb, cechy obu składników ze słabszą siłą."
		return
	if(istype(target, /obj/item/munition_part))
		var/obj/item/munition_part/part = target
		. += "Klasa [part.quality.roman] ([part.quality.name]), obrażenia i wytrzymałość ×[part.quality.bonus]."
		if(!isnull(part.forging_accuracy))
			. += "Wykuto z celnością [round(part.forging_accuracy * 100)]%."
		else if(part.hammer_time)
			. += "Niewykuty: [part.forging_notes()] uderzeń na kowadle."
		var/obj/item/munition_part/body/body = part
		if(istype(body) && body.material)
			. += "<b>[body.material.name]</b>: [jointext(body.material.stat_lines(), " ")]"
		var/obj/item/munition_part/filler/filler_part = part
		if(istype(filler_part))
			var/datum/munition_filler/F = get_munition_filler(filler_part.filler_type)
			. += "[F.name]: obrażenia ×[F.damage_mult], przebicie [F.armour_pen_add >= 0 ? "+" : ""][F.armour_pen_add]. [F.desc]"
		return
	var/datum/component/forged_munition/forged = get_forged_munition(target)
	if(!forged)
		return
	. += "[forged.galvanized ? "Pokryto" : "Wykuto"]: [forged.material.name], klasa [forged.quality.roman] ([forged.quality.name])."
	. += "Razem: obrażenia ×[round(forged.damage_mult(), 0.01)], przebicie [forged.armour_pen_add() >= 0 ? "+" : ""][forged.armour_pen_add()], prędkość ×[forged.material.speed_mult], wytrzymałość ×[round(forged.material.integrity_mult * forged.quality.bonus, 0.01)]."
	if(forged.filler)
		. += "Wypełnienie: [forged.filler.name]."
	. += forged.trait_lines()

/obj/item/munitions_analyzer/attack_self(mob/user)
	if(!length(last_scan))
		to_chat(user, "<span class='notice'>Nie ma czego drukować, najpierw coś zeskanuj.</span>")
		return
	if(!COOLDOWN_FINISHED(src, print_cooldown))
		to_chat(user, "<span class='warning'>[src] jeszcze drukuje.</span>")
		return
	COOLDOWN_START(src, print_cooldown, 5 SECONDS)
	var/obj/item/paper/report = new(get_turf(src))
	report.name = "raport analizatora: [last_scan_name]"
	report.add_raw_text("<b>[last_scan_name]</b><br>[jointext(last_scan, "<br>")]")
	report.update_icon()
	user.put_in_hands(report)
	playsound(src, 'sound/machines/copier.ogg', 50, TRUE)
