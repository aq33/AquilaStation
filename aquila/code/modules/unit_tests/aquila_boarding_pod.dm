/// AQUILA - abordaż kapsułą (aquila/code/modules/overmap/modules/boarding_pod.dm): kapsuła leci tylko na wrogi okręt z
/// wnętrzem i bez tarcz, a zestrzelona w locie (pocisk znika bez trafienia) wyrzuca rannego pasażera zamiast go zgubić.
/datum/unit_test/aquila_boarding_pod

/datum/unit_test/aquila_boarding_pod/Run()
	var/obj/structure/overmap/syndicate/ai/gunboat/morale_test/target = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	var/obj/structure/overmap/syndicate/ai/gunboat/morale_test/ours = allocate(/obj/structure/overmap/syndicate/ai/gunboat/morale_test)
	ours.faction = "nanotrasen"
	target.faction = "syndicate"
	if(!length(target.possible_interior_maps))
		target.possible_interior_maps = list(/datum/map_template/boarding/barracuda)
	target.interior_mode = INTERIOR_EXCLUSIVE
	var/blocked = boarding_pod_target_blocked(ours, target)
	if(blocked)
		return Fail("Wrogi okręt z wnętrzem i bez tarcz jest zablokowany jako cel kapsuły: [blocked]")
	target.faction = "nanotrasen"
	if(!boarding_pod_target_blocked(ours, target))
		return Fail("Kapsuła może lecieć na okręt własnej frakcji")
	target.faction = "syndicate"
	target.interior_mode = NO_INTERIOR
	if(!boarding_pod_target_blocked(ours, target))
		return Fail("Kapsuła może lecieć na okręt bez wnętrza")
	target.interior_mode = INTERIOR_EXCLUSIVE

	// Kabina kapsuły ma powietrze pod normalnym ciśnieniem (w locie pasażer jest poza mapą i oddycha z kabiny);
	// dawniej wzór bez ONE_ATMOSPHERE dawał ok. 1 kPa i pasażer obrywał od niskiego ciśnienia przez cały lot
	var/obj/structure/drop_pod/cabin = allocate(/obj/structure/drop_pod, run_loc_floor_bottom_left)
	var/pressure = cabin.return_air().return_pressure()
	if(pressure < 90 || pressure > 110)
		return Fail("Ciśnienie w kabinie kapsuły to [pressure] kPa zamiast około 101")

	// Zestrzał: pocisk-kapsuła znika bez trafienia, pasażer wypada ranny (bez okrętu źródłowego: na polu startu)
	var/mob/living/carbon/human/trooper = allocate(/mob/living/carbon/human, run_loc_floor_bottom_left)
	var/obj/structure/drop_pod/pod = allocate(/obj/structure/drop_pod, run_loc_floor_bottom_left)
	pod.origin = run_loc_floor_bottom_left
	trooper.forceMove(pod)
	pod.moveToNullspace()
	var/obj/item/projectile/guided_munition/boarding_pod/flight = allocate(/obj/item/projectile/guided_munition/boarding_pod, run_loc_floor_bottom_left)
	flight.pod = pod
	flight.pod_target = target
	qdel(flight)
	// zestrzał obsługuje kapsuła w timerze bez opóźnienia, tuż po zniknięciu pocisku: czekamy najwyżej kilka ticków
	var/shot_down_timeout = world.time + 5
	while(!QDELETED(pod) && world.time < shot_down_timeout)
		sleep(world.tick_lag)
	if(trooper.loc != run_loc_floor_bottom_left)
		return Fail("Pasażer zestrzelonej kapsuły nie wypadł na pole startu ([trooper.loc?.type])")
	if(trooper.getBruteLoss() < 50)
		return Fail("Pasażer zestrzelonej kapsuły nie jest ranny ([trooper.getBruteLoss()] obrażeń)")
	if(!QDELETED(pod))
		return Fail("Zestrzelona kapsuła została w grze")
