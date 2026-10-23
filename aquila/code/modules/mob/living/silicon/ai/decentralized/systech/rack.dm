/obj/item/server_rack
	name = "rack serwerowy"
	desc = "Samodzielny rack z procesorami i pamięcią dla systemu sztucznej inteligencji. Gotowy do włożenia do szafy serwerowej."
	icon = 'aquila/icons/obj/machines/ai_servers.dmi'
	icon_state = "server_rack"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'

	flags_1 = CONDUCT_1
	force = 5
	w_class = WEIGHT_CLASS_BULKY
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron = 1000)

	var/list/obj/item/ai_cpu/contained_cpus = list()
	var/contained_ram = 0

/obj/item/server_rack/Destroy()
	QDEL_LIST(contained_cpus)
	return ..()

/obj/item/server_rack/examine(mob/user)
	. = ..()
	var/total = get_cpu()
	for(var/obj/item/ai_cpu/CPU as anything in contained_cpus)
		. += span_notice("Zamontowano [CPU.name]: [CPU.speed] THz, [CPU.get_power_usage()] W.")
	. += span_notice("Łączne taktowanie: [total] THz.")
	. += span_notice("Pamięć RAM: [get_ram()] TB.")
	. += span_notice("Pobór mocy: [get_power_usage()] W.")

/obj/item/server_rack/proc/get_cpu()
	var/amount = 0
	for(var/obj/item/ai_cpu/CPU as anything in contained_cpus)
		amount += CPU.speed
	return amount

/obj/item/server_rack/proc/get_ram()
	return contained_ram

/obj/item/server_rack/proc/get_power_usage()
	var/usage = 0
	for(var/obj/item/ai_cpu/CPU as anything in contained_cpus)
		usage += CPU.get_power_usage()
	usage += contained_ram * AI_POWER_PER_CARD
	return usage

/obj/item/server_rack/roundstart/Initialize(mapload)
	. = ..()
	var/obj/item/ai_cpu/CPU = new(src)
	contained_cpus += CPU
	contained_ram = 1
