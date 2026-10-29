/*
	FYI these used to have scientific names, and some of them were refs to real mushrooms. I dont want to condone the risk of eating these mushrooms irl, so try not to use real latin names
*/
/obj/item/food/grown/mushroom
	name = "grzyb"
	bite_consumption_mod = 3
	foodtypes = VEGETABLES
	wine_power = 40

// Reishi
/obj/item/food/grown/mushroom/reishi
	seed = /obj/item/plant_seeds/preset/reishi
	name = "reishi"
	desc = "Wyjątkowy grzyb znany z właściwości leczniczych i przeciwstresowych."
	icon_state = "reishi"

// Fly Amanita
/obj/item/food/grown/mushroom/amanita
	seed = /obj/item/plant_seeds/preset/amanita
	name = "muchomor czerwony"
	desc = "Naucz się na pamięć trujących grzybów. Zbieraj tylko te, które znasz."
	icon_state = "amanita"

// Destroying Angel
/obj/item/food/grown/mushroom/angel
	seed = /obj/item/plant_seeds/preset/angel
	name = "muchomor jadowity"
	desc = "Śmiertelnie trujący grzyb podstawkowy pełen alfa-amatoksyn."
	icon_state = "angel"
	wine_power = 60
	discovery_points = 300

// Liberty Cap
/obj/item/food/grown/mushroom/libertycap
	seed = /obj/item/plant_seeds/preset/liberty
	name = "łysiczka lancetowata"
	desc = "Wyzwól się!"
	icon_state = "libertycap"
	wine_power = 80

// Plump Helmet
/obj/item/food/grown/mushroom/plumphelmet
	seed = /obj/item/plant_seeds/preset/plump
	name = "pulchny hełm"
	desc = "Pulchny, miękki i t-taki kuszący~"
	icon_state = "plumphelmet"
	distill_reagent = /datum/reagent/consumable/ethanol/manly_dorf

// Walking Mushroom
/obj/item/food/grown/mushroom/walkingmushroom
	seed = /obj/item/plant_seeds/preset/walking
	name = "chodzący grzyb"
	desc = "Początek wielkiej wędrówki."
	icon_state = "walkingmushroom"
	can_distill = FALSE
	discovery_points = 300

// Chanterelle
/obj/item/food/grown/mushroom/chanterelle
	seed = /obj/item/plant_seeds/preset/chanterelle
	name = "kurka"
	desc = "Te wesołe żółte grzybki wyglądają naprawdę smakowicie!"
	icon_state = "chanterelle"

//Jupiter Cup
/obj/item/food/grown/mushroom/jupitercup
	seed = /obj/item/plant_seeds/preset/jupitercup
	name = "czasza Jowisza"
	desc = "Dziwny czerwony grzyb o wilgotnej, śliskiej powierzchni. Zastanawiasz się, ile malutkich robaków spotkał w nim marny los."
	icon_state = "jupitercup"
	discovery_points = 300

// Glowshroom
/obj/item/food/grown/mushroom/glowshroom
	seed = /obj/item/plant_seeds/preset/glowshroom
	name = "świecący grzyb"
	desc = "Ten gatunek grzyba świeci w ciemności."
	icon_state = "glowshroom"
	var/effect_path = /obj/structure/glowshroom
	wine_power = 50
	discovery_points = 300

/obj/item/food/grown/mushroom/glowshroom/attack_self(mob/user)
	if(isspaceturf(user.loc))
		return FALSE
	if(!isturf(user.loc))
		to_chat(user, "<span class='warning'>Potrzebujesz więcej miejsca, by posadzić [src].</span>")
		return FALSE
	var/count = 0
	var/maxcount = 1
	for(var/tempdir in GLOB.cardinals)
		var/turf/closed/wall = get_step(user.loc, tempdir)
		if(istype(wall))
			maxcount++
	for(var/obj/structure/glowshroom/G in user.loc)
		count++
	if(count >= maxcount)
		to_chat(user, "<span class='warning'>Jest tu za dużo grzybów, by posadzić [src].</span>")
		return FALSE
	new effect_path(user.loc, seed)
	to_chat(user, "<span class='notice'>Sadzisz [src].</span>")
	qdel(src)
	return TRUE


// Glowcap
/obj/item/food/grown/mushroom/glowshroom/glowcap
	seed = /obj/item/plant_seeds/preset/glowcap
	name = "świecący kapelusz"
	desc = "Ten gatunek grzyba świeci w ciemności, choć nie jest bioluminescencyjny. W dotyku jest ciepły..."
	icon_state = "glowcap"
	effect_path = /obj/structure/glowshroom/glowcap
	tastes = list("świecący kapelusz" = 1)
	discovery_points = 300

//Shadowshroom
/obj/item/food/grown/mushroom/glowshroom/shadowshroom
	seed = /obj/item/plant_seeds/preset/shadowshroom
	name = "cienisty grzyb"
	desc = "Ten gatunek grzyba zamiast światła wydziela cień."
	icon_state = "shadowshroom"
	effect_path = /obj/structure/glowshroom/shadowshroom
	tastes = list("cień" = 1, "grzyb" = 1)
	wine_power = 60
	discovery_points = 300

/obj/item/food/grown/mushroom/glowshroom/shadowshroom/attack_self(mob/user)
	. = ..()
	if(.)
		investigate_log("was planted by [key_name(user)] at [AREACOORD(user)]", INVESTIGATE_BOTANY)
