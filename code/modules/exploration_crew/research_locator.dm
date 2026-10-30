
/obj/item/research_disk_pinpointer
	name = "lokalizator dysków badawczych"
	desc = "Małe ręczne urządzenie wykrywające pobliskie dyski badawcze. Mimo bardzo wysokiej czułości sygnał zwrotny z dysków jest tak słaby, że ma tylko krótki zasięg."
	icon = 'icons/obj/device.dmi'
	icon_state = "researchlocator"
	var/next_use_time = 0
	var/range = 30

/obj/item/research_disk_pinpointer/attack_self(mob/user)
	if(world.time < next_use_time)
		to_chat(user, "<span class='notice'>Wewnętrzne kondensatory się ładują...</span>")
		return
	to_chat(user, "<span class='notice'>Wysyłasz impuls w poszukiwaniu pobliskich dysków badawczych.</span>")
	pulse_effect(get_turf(src), 6)
	next_use_time = world.time + 10 SECONDS
	for(var/obj/item/disk/tech_disk/research/research_disk in SSorbits.research_disks)
		var/dist = get_dist(user, research_disk)
		if(dist <= range && isturf(research_disk.loc) && research_disk.get_virtual_z_level() == get_virtual_z_level())
			var/direction = get_dir(user, research_disk)
			dir = direction
			say("Wykryto słaby sygnał: [dir2text(direction)] od obecnego położenia, [dist] m stąd.")
			return
