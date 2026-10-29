/**********************Resonator**********************/
/obj/item/resonator
	name = "rezonator"
	icon = 'icons/obj/mining.dmi'
	icon_state = "resonator"
	item_state = "resonator"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	desc = "Ręczne urządzenie tworzące małe pola energii, które rezonują aż do wybuchu, kruszącego skałę. Zadaje większe obrażenia przy niskim ciśnieniu."
	w_class = WEIGHT_CLASS_NORMAL
	force = 15
	throwforce = 10
	var/burst_time = 30
	var/fieldlimit = 4
	var/list/fields = list()
	var/quick_burst_mod = 0.8

/obj/item/resonator/upgraded
	name = "ulepszony rezonator"
	desc = "Ulepszona wersja rezonatora, która tworzy więcej pól naraz i nie traci obrażeń przy wcześniejszym rozerwaniu pola rezonansowego."
	icon_state = "resonator_u"
	item_state = "resonator_u"
	fieldlimit = 6
	quick_burst_mod = 1

/obj/item/resonator/AltClick(mob/user)
	if(burst_time == 50)
		burst_time = 30
		to_chat(user, "<span class='info'>Ustawiasz pola rezonatora na detonację po 3 sekundach.</span>")
	else
		burst_time = 50
		to_chat(user, "<span class='info'>Ustawiasz pola rezonatora na detonację po 5 sekundach.</span>")

/obj/item/resonator/attack_self(mob/user)
	if(LAZYLEN(fields) == 0)
		return
	to_chat(user, "<span class='info'>Detonujesz wszystkie aktywne pola rezonatora.</span>")
	for(var/obj/effect/temp_visual/resonance/F in fields)
		F.damage_multiplier = quick_burst_mod
		F.burst()


/obj/item/resonator/proc/CreateResonance(target, mob/user)
	var/turf/T = get_turf(target)
	var/obj/effect/temp_visual/resonance/R = locate(/obj/effect/temp_visual/resonance) in T
	if(R)
		R.damage_multiplier = quick_burst_mod
		R.burst()
		return
	if(LAZYLEN(fields) < fieldlimit)
		new /obj/effect/temp_visual/resonance(T, user, src, burst_time)
		user.changeNext_move(CLICK_CD_MELEE)

/obj/item/resonator/pre_attack(atom/target, mob/user, params)
	if(check_allowed_items(target, 1))
		CreateResonance(target, user)
	return TRUE

//resonance field, crushes rock, damages mobs
/obj/effect/temp_visual/resonance
	name = "pole rezonansowe"
	desc = "Rezonujące pole, które przy rozerwaniu poważnie rani wszystko w swoim wnętrzu. Groźniejsze przy niskim ciśnieniu."
	icon_state = "shield1"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 50
	var/resonance_damage = 20
	var/damage_multiplier = 1
	var/creator
	var/obj/item/resonator/res

/obj/effect/temp_visual/resonance/Initialize(mapload, set_creator, set_resonator, set_duration)
	duration = set_duration
	. = ..()
	creator = set_creator
	res = set_resonator
	if(res)
		res.fields += src
	playsound(src,'sound/weapons/resonator_fire.ogg',50,1)
	transform = matrix()*0.75
	animate(src, transform = matrix()*1.5, time = duration)
	deltimer(timerid)
	timerid = addtimer(CALLBACK(src, PROC_REF(burst)), duration, TIMER_STOPPABLE)

/obj/effect/temp_visual/resonance/Destroy()
	if(res)
		res.fields -= src
		res = null
	creator = null
	. = ..()

/obj/effect/temp_visual/resonance/proc/check_pressure(turf/proj_turf)
	if(!proj_turf)
		proj_turf = get_turf(src)
	resonance_damage = initial(resonance_damage)
	if(lavaland_equipment_pressure_check(proj_turf))
		name = "silne [initial(name)]"
		resonance_damage *= 3
	else
		name = initial(name)
	resonance_damage *= damage_multiplier

/obj/effect/temp_visual/resonance/proc/burst()
	var/turf/T = get_turf(src)
	new /obj/effect/temp_visual/resonance_crush(T)
	if(ismineralturf(T))
		var/turf/closed/mineral/M = T
		M.gets_drilled(creator)
	check_pressure(T)
	playsound(T,'sound/weapons/resonator_blast.ogg',50,1)
	for(var/mob/living/L in T)
		if(creator)
			log_combat(creator, L, "used a resonator field on", "resonator")
		to_chat(L, "<span class='userdanger'>[src] pęka, gdy jesteś w środku!</span>")
		L.apply_damage(resonance_damage, BRUTE)
	qdel(src)

/obj/effect/temp_visual/resonance_crush
	icon_state = "shield1"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 4

/obj/effect/temp_visual/resonance_crush/Initialize(mapload)
	. = ..()
	transform = matrix()*1.5
	animate(src, transform = matrix()*0.1, alpha = 50, time = 4)
