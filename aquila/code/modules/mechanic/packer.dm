// AQUILA - Mechanik: pakownica. Składa działającą maszynę w paczkę z jej płytką i częściami (odpowiednik urządzenia
// do rozbiórki z Goona, napisany od nowa). Maszyna musi mieć otwarty właz serwisowy i nikogo w środku.

/obj/item/machine_packer
	name = "pakownica maszyn"
	desc = "Składa maszynę z otwartym włazem serwisowym w paczkę razem z płytką i częściami. Paczkę rozkłada się multitoolem."
	icon = 'aquila/icons/obj/mechanic/devices.dmi'
	icon_state = "packer"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron = 4000, /datum/material/glass = 1000, /datum/material/titanium = 1000)
	/// Czas składania maszyny
	var/pack_time = 5 SECONDS
	/// Wersja z uplinku pakuje też maszyny z czarnej listy
	var/ignores_blacklist = FALSE

/obj/item/machine_packer/pre_attack(atom/A, mob/living/user, params)
	if(!mechanic_tool_targets(A, user))
		return ..()
	try_pack(A, user)
	return FALSE

/// Powód, dla którego tej maszyny nie da się teraz spakować, albo null
/obj/item/machine_packer/proc/pack_problem(obj/machinery/machine)
	var/problem = mechanic_machine_problem(machine, ignores_blacklist)
	if(problem)
		return problem
	if(machine.occupant)
		return "ktoś jest w środku"
	if(!istype(machine, /obj/machinery/computer) && !machine.panel_open)
		return "najpierw otwórz właz serwisowy"
	return null

/obj/item/machine_packer/proc/try_pack(obj/machinery/machine, mob/living/user)
	var/problem = pack_problem(machine)
	if(problem)
		balloon_alert(user, problem)
		return FALSE
	user.visible_message("<span class='notice'>[user] zaczyna składać [machine] w paczkę.</span>", "<span class='notice'>Zaczynasz składać [machine] w paczkę...</span>")
	playsound(machine, 'sound/items/rped.ogg', 50, TRUE)
	if(!do_after(user, pack_time, target = machine))
		return FALSE
	if(QDELETED(machine) || pack_problem(machine))
		return FALSE
	var/obj/item/flatpack/pack = mechanic_pack_machine(machine)
	playsound(pack, 'sound/items/deconstruct.ogg', 50, TRUE)
	to_chat(user, "<span class='notice'>Składasz maszynę w [pack].</span>")
	return TRUE

/// Wersja z uplinku: szybsza i pakuje też uzbrojenie, konsole statku i sprzęt ochrony
/obj/item/machine_packer/syndicate
	desc = "Składa maszynę z otwartym włazem serwisowym w paczkę razem z płytką i częściami. Paczkę rozkłada się multitoolem. Ten egzemplarz nie ma blokad bezpieczeństwa."
	color = "#ff7070"
	pack_time = 3 SECONDS
	ignores_blacklist = TRUE
