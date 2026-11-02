/obj/mecha/combat/honker
	desc = "Produkowany przez „Tyranny of Honk, INC” egzoszkielet ciężkiego wsparcia klaunów. Służy do szerzenia zabawy i radości życia. HONK!"
	name = "\improper H.O.N.K"
	icon_state = "honker"
	step_in = 3
	max_integrity = 140
	deflect_chance = 60
	internal_damage_threshold = 60
	armor = list("melee" = -20, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100, "stamina" = 0, "bleed" = 0)
	max_temperature = 25000
	infra_luminosity = 5
	operation_req_access = list(ACCESS_THEATRE)
	internals_req_access = list(ACCESS_MECH_SCIENCE, ACCESS_THEATRE)
	wreckage = /obj/structure/mecha_wreckage/honker
	add_req_access = 0
	max_equip = 3
	var/squeak = 0

/obj/mecha/combat/honker/mechstep(direction)
	var/result = step(src,direction)
	if(result)
		if(!squeak)
			playsound(src, "clownstep", 70, 1)
			squeak = 1
		else
			squeak = 0
	return result

// AQUILA: dźwięki HONK w oknie TGUI mecha (dawniej w panelu HTML)
/obj/mecha/combat/honker/ui_static_data(mob/user)
	var/list/data = ..()
	data["honk_sounds"] = list(
		list("key" = "sadtrombone", "name" = "Smutny puzon"),
		list("key" = "bikehorn", "name" = "Trąbka rowerowa"),
		list("key" = "airhorn2", "name" = "Syrena pneumatyczna"),
		list("key" = "carhorn", "name" = "Klakson"),
		list("key" = "party_horn", "name" = "Trąbka imprezowa"),
		list("key" = "reee", "name" = "Reee"),
		list("key" = "weeoo1", "name" = "Syrena"),
		list("key" = "hiss1", "name" = "Syczące stworzenie"),
		list("key" = "armbomb", "name" = "Uzbrojony granat"),
		list("key" = "saberon", "name" = "Miecz energetyczny"),
		list("key" = "airlock_alien_prying", "name" = "Wyważanie śluzy"),
		list("key" = "lightningbolt", "name" = "Błyskawica"),
		list("key" = "explosionfar", "name" = "Odległa eksplozja"),
	)
	return data

/obj/mecha/combat/honker/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(action != "play_sound")
		return
	if(usr != occupant || usr.incapacitated())
		return
	switch(params["sound"])
		if("sadtrombone")
			playsound(src, 'sound/misc/sadtrombone.ogg', 50)
		if("bikehorn")
			playsound(src, 'sound/items/bikehorn.ogg', 50)
		if("airhorn2")
			playsound(src, 'sound/items/airhorn2.ogg', 40) //soundfile has higher than average volume
		if("carhorn")
			playsound(src, 'sound/items/carhorn.ogg', 80) //soundfile has lower than average volume
		if("party_horn")
			playsound(src, 'sound/items/party_horn.ogg', 50)
		if("reee")
			playsound(src, 'sound/effects/reee.ogg', 50)
		if("weeoo1")
			playsound(src, 'sound/items/weeoo1.ogg', 50)
		if("hiss1")
			playsound(src, 'sound/voice/hiss1.ogg', 50)
		if("armbomb")
			playsound(src, 'sound/weapons/armbomb.ogg', 50)
		if("saberon")
			playsound(src, 'sound/weapons/saberon.ogg', 50)
		if("airlock_alien_prying")
			playsound(src, 'sound/machines/airlock_alien_prying.ogg', 50)
		if("lightningbolt")
			playsound(src, 'sound/magic/lightningbolt.ogg', 50)
		if("explosionfar")
			playsound(src, 'sound/effects/explosionfar.ogg', 50)
	return TRUE

/proc/rand_hex_color()
	var/list/colors = list("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f")
	var/color=""
	for (var/i=0;i<6;i++)
		color = color+pick(colors)
	return color


