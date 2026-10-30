/obj/item/implant/gang
	name = "implant gangu"
	desc = "Robi z ciebie gangstera czy coś."
	activated = 0
	var/datum/team/gang/gang

/obj/item/implant/gang/Initialize(mapload, loc, setgang)
	..()
	gang = setgang

/obj/item/implant/gang/get_data()
	var/dat = {"<b>Specyfikacja implantu:</b><BR>
				<b>Nazwa:</b> przestępczy implant prania mózgu<BR>
				<b>Żywotność:</b> kilka sekund po wstrzyknięciu.<BR>
				<b>Ważne uwagi:</b> nielegalny<BR>
				<HR>
				<b>Szczegóły implantu:</b><BR>
				<b>Działanie:</b> zawiera małą kapsułę nanobotów, które przestawiają mózg nosiciela na lojalność wobec określonej organizacji.<BR>
				<b>Uwaga:</b> najnowsze implanty ochrony umysłu NT przeciwdziałają temu implantowi.<BR>
				<b>Trwałość:</b> najnowszy implant ochrony umysłu NT neutralizuje ten implant."}
	return dat

/obj/item/implant/gang/implant(mob/living/target, mob/user, silent = 0)
	if(!target || !target.mind  || target.stat == DEAD || !ishuman(target) || !..())
		return FALSE
	if (HAS_TRAIT(target, TRAIT_MINDSHIELD))
		target.visible_message("<span class='warning'>[target] zdaje się opierać implantowi!</span>", "<span class='warning'>Opierasz się implantowi gangu. Zamiast tego przypomina ci się kampania przeciw gangom.</span>")
		return FALSE

	var/datum/antagonist/gang/G = target.mind.has_antag_datum(/datum/antagonist/gang)
	if(G)
		if(G.gang == G || istype(G, /datum/antagonist/gang/boss))
			return FALSE
		target.mind.remove_antag_datum(/datum/antagonist/gang)
	target.mind.add_antag_datum(/datum/antagonist/gang, gang)
	qdel(src)
	return TRUE

/obj/item/implanter/gang
	name = "implanter (gang)"

/obj/item/implanter/gang/Initialize(mapload, loc, gang)
	if(!gang)
		qdel(src)
		return
	imp = new /obj/item/implant/gang(src,gang)
	..()



/obj/item/implant/mindshield/implant(mob/living/target, mob/user, silent = FALSE) //putting this here, pls no bulli. - qwerty
	if(..())
		if(!target.mind)
			return TRUE
		if(target.mind.has_antag_datum(/datum/antagonist/gang/boss))
			if(!silent)
				target.visible_message("<span class='warning'>[target] zdaje się opierać implantowi!</span>", "<span class='warning'>Czujesz, że coś zakłóca twoje mentalne uwarunkowanie, ale się opierasz!</span>")
			removed(target, 1)
			qdel(src)
			return FALSE
		target.mind.remove_antag_datum(/datum/antagonist/gang)
		return TRUE
	return FALSE
