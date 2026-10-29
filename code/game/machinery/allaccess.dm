/obj/machinery/allaccess
	name = "dozownik pełnego dostępu"
	desc = "Niektórzy mylą z tym Starszego Oficera. Zawiera fałszywe karty pełnego dostępu, żeby trzymać szarą hołotę na dystans!"
	icon = 'icons/obj/card.dmi'
	icon_state = "aa"
	var/spawnitem = /obj/item/toy/allaccess
	idle_power_usage = 5
	density = FALSE
	circuit = /obj/item/circuitboard/machine/allaccess
	pass_flags = PASSTABLE

/obj/machinery/allaccess/attack_hand(mob/living/user)
	var/output = new spawnitem
	user.put_in_active_hand(output)
	to_chat(user, "<span class='notice'>Wyjmujesz kartę z dozownika.</span>")

/obj/machinery/allaccess/power_change()
	if(machine_stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
	else
		if(powered())
			icon_state = initial(icon_state)
			set_machine_stat(machine_stat & ~NOPOWER)
		else
			icon_state = "[initial(icon_state)]-off"
			machine_stat |= NOPOWER

/obj/machinery/allaccess/real
	desc = "Niektórzy mylą z tym Starszego Oficera. Zawiera prawdziwy pełny dostęp!"  // admin spawn for funnies
	spawnitem = /obj/item/card/id/captains_spare
