// AQUILA - Mechanik: skaner maszyn. Zapisuje schematy maszyn razem z tierem części; czytnik schematów wpisuje je do bazy.

/obj/item/machine_scanner
	name = "skaner maszyn"
	desc = "Ręczny skaner, który zapisuje schemat maszyny razem z tierem jej części. Skany wgrywa się do czytnika schematów."
	icon = 'aquila/icons/obj/mechanic/devices.dmi'
	icon_state = "scanner"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	custom_materials = list(/datum/material/iron = 1000, /datum/material/glass = 500, /datum/material/silver = 250)
	/// Zapisane schematy, najwyżej max_scans
	var/list/datum/machine_schematic/scans = list()
	var/max_scans = 10
	/// Wersja z uplinku skanuje też maszyny z czarnej listy
	var/ignores_blacklist = FALSE

/obj/item/machine_scanner/Destroy()
	QDEL_LIST(scans)
	return ..()

/obj/item/machine_scanner/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Pamięć: [length(scans)]/[max_scans] skanów. Użyj skanera w ręce, żeby wyczyścić pamięć.</span>"
	for(var/datum/machine_schematic/schematic as anything in scans)
		. += "<span class='notice'>- [schematic.display_name()]</span>"

/obj/item/machine_scanner/attack_self(mob/user, modifiers)
	if(!length(scans))
		to_chat(user, "<span class='notice'>Pamięć skanera jest pusta.</span>")
		return
	if(tgui_alert(user, "Wyczyścić [length(scans)] skanów z pamięci?", "Skaner maszyn", list("Tak", "Nie")) != "Tak")
		return
	if(QDELETED(src) || !user.is_holding(src))
		return
	QDEL_LIST(scans)
	to_chat(user, "<span class='notice'>Czyścisz pamięć skanera.</span>")

/obj/item/machine_scanner/pre_attack(atom/A, mob/living/user, params)
	// Czytnik schematów sam bierze skany w attackby; maszyny bez płytki (np. kosz na śmieci) i walka idą zwykłą drogą
	if(!mechanic_tool_targets(A, user) || istype(A, /obj/machinery/schematic_reader))
		return ..()
	scan_machine(A, user)
	return FALSE

/// TRUE, jeśli narzędzie mechanika ma obsłużyć kliknięcie: maszyna z płytką i gracz poza trybem walki
/proc/mechanic_tool_targets(atom/target, mob/living/user)
	if(!ismachinery(target) || user.combat_mode)
		return FALSE
	var/obj/machinery/machine = target
	return istype(machine.circuit, /obj/item/circuitboard)

/// Zwraca powód, dla którego maszyny nie da się zeskanować albo spakować, albo null, gdy się da
/proc/mechanic_machine_problem(obj/machinery/machine, ignores_blacklist = FALSE)
	if(!istype(machine.circuit, /obj/item/circuitboard))
		return "ta maszyna nie ma płytki"
	if(machine.flags_1 & NODECONSTRUCT_1)
		return "tej maszyny nie da się rozebrać"
	if(!ignores_blacklist && mechanic_is_blacklisted(machine.type))
		return "zabezpieczenia blokują tę maszynę"
	return null

/obj/item/machine_scanner/proc/scan_machine(obj/machinery/machine, mob/user)
	var/problem = mechanic_machine_problem(machine, ignores_blacklist)
	if(problem)
		to_chat(user, "<span class='warning'>[src] pika: [problem].</span>")
		return FALSE
	if(length(scans) >= max_scans)
		to_chat(user, "<span class='warning'>Pamięć [src] jest pełna. Wgraj skany do czytnika schematów albo wyczyść pamięć.</span>")
		return FALSE
	var/datum/machine_schematic/schematic = new
	if(!schematic.read_machine(machine))
		qdel(schematic)
		to_chat(user, "<span class='warning'>[src] nie rozpoznaje [machine].</span>")
		return FALSE
	for(var/datum/machine_schematic/known as anything in scans)
		if(known.get_key() == schematic.get_key())
			qdel(schematic)
			to_chat(user, "<span class='notice'>Ten schemat jest już w pamięci skanera.</span>")
			return FALSE
	user.visible_message("<span class='notice'>[user] skanuje [machine].</span>", "<span class='notice'>Skanujesz [machine]...</span>")
	if(!do_after(user, 1 SECONDS, target = machine))
		qdel(schematic)
		return FALSE
	scans += schematic
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	to_chat(user, "<span class='notice'>Zapisano schemat: [schematic.display_name()].</span>")
	return TRUE

/// Wersja z uplinku: skanuje też uzbrojenie, konsole statku i sprzęt ochrony
/obj/item/machine_scanner/syndicate
	name = "skaner maszyn"
	desc = "Ręczny skaner, który zapisuje schemat maszyny razem z tierem jej części. Ten egzemplarz nie ma blokad bezpieczeństwa."
	color = "#ff7070"
	ignores_blacklist = TRUE
	max_scans = 20
