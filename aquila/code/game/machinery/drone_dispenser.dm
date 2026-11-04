// Fabrykator swarmerów robi najwyżej jednego swarmera na swoim kafelku: czeka, dopóki leży tam
// niezajęta powłoka albo stoi swarmer, zamiast zasypywać kafelek powłokami co 30 sekund.
/obj/machinery/droneDispenser/swarmer
	maximum_idle = 1

/obj/machinery/droneDispenser/swarmer/count_shells()
	. = ..()
	for(var/mob/living/simple_animal/hostile/swarmer/swarmer in loc)
		.++
