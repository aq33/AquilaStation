
/datum/rune_spell/pulse
	name = "Mroczny Impuls"
	desc = "Zakłóca obwody pobliskich urządzeń."
	desc_talisman = "Użyj, by zakłócić obwody pobliskich urządzeń."
	invocation = "Ta'gh fara'qha fel d'amar det!"
	word1 = /datum/rune_word/destroy
	word2 = /datum/rune_word/see
	word3 = /datum/rune_word/technology
	page = "Ta runa wywołuje silny impuls elektromagnetyczny, który psuje maszyny, urządzenia i roboty w promieniu 3 pól.\
		<br><br>Kultyści i to, co przy sobie noszą, pozostają nietknięci.\
		<br><br>Możesz też przyłożyć talizman bezpośrednio do kogoś, by efekt dotknął tylko jego, ale z podwójną siłą."
	touch_cast = 1

/datum/rune_spell/pulse/cast_touch(mob/M)
	var/turf/T = get_turf(M)
	invoke(activator, invocation, 1)
	playsound(T, 'sound/items/welder2.ogg', 25, 0, -5)
	playsound(T, 'aquila/sound/bloodcult/bloodboil.ogg', 25, 0, -5)
	dark_pulse_animation(T)
	M.emp_act(EMP_HEAVY)
	M.emp_act(EMP_HEAVY)
	qdel(src)

/datum/rune_spell/pulse/cast()
	var/turf/T = get_turf(spell_holder)
	playsound(T, 'sound/items/welder2.ogg', 25, 1)
	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(darkpulse), T, 3, 3, 0, activator)
	qdel(spell_holder)

/// Animacja impulsu z dymem kultu na polu (w drafcie spawn z sleep)
/proc/dark_pulse_animation(turf/T)
	var/obj/effect/abstract/animation = anim(target = T, a_icon = 'aquila/icons/bloodcult/cult.dmi', flick_anim = "rune_pulse", sleeptime = 15, plane = GAME_PLANE_UPPER, lay = ABOVE_MOB_LAYER)
	animation.add_particles(PS_CULT_SMOKE_BOX)
	addtimer(CALLBACK(animation, TYPE_PROC_REF(/atom, adjust_particles), PVAR_SPAWNING, 0, PS_CULT_SMOKE_BOX), 6)

/proc/darkpulse(turf/epicenter, heavy_range, light_range, log = 0, mob/living/cultist = null)
	if(!epicenter)
		return

	if(!istype(epicenter, /turf))
		epicenter = get_turf(epicenter.loc)

	if(heavy_range > light_range)
		light_range = heavy_range

	var/max_range = max(heavy_range, light_range)

	var/x0 = epicenter.x
	var/y0 = epicenter.y
	var/z0 = epicenter.z

	if(log)
		message_admins("EMP o zasięgu ([heavy_range], [light_range]) w obszarze [epicenter.loc.name] ([x0], [y0], [z0]) [ADMIN_JMP(epicenter)].")
		log_game("EMP with size ([heavy_range], [light_range]) in area [epicenter.loc.name].")

	for (var/mob/M in GLOB.player_list)
		//Double check for client
		if(M && M.client)
			var/turf/M_turf = get_turf(M)
			if(M_turf && (M_turf.z == epicenter.z))
				var/dist = cheap_pythag(M_turf.x - x0, M_turf.y - y0)
				if((dist <= round(heavy_range + world.view - 2, 1)) && (M_turf.z - epicenter.z <= max_range) && (epicenter.z - M_turf.z <= max_range))
					M.playsound_local(epicenter, 'aquila/sound/bloodcult/bloodboil.ogg', 25, 0)

	var/datum/antagonist/cult/cult_datum = IS_CULTIST(cultist)
	for(var/turf/T in spiral_range(max_range, epicenter))
		CHECK_TICK
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(dark_pulse_animation), T), max(1, get_dist(T, epicenter)))
		var/dist = cheap_pythag(T.x - x0, T.y - y0)
		if(dist > max_range)
			continue
		var/act = EMP_LIGHT
		if(dist <= heavy_range)
			act = EMP_HEAVY
		for(var/atom/movable/A in T.contents)
			if (cultist && isliving(A))
				var/mob/living/L = A
				if (IS_CULTIST(L))
					continue
				else if (L.client && L.stat != DEAD)
					cult_datum?.gain_devotion(50, DEVOTION_TIER_2, "EMP", L)
			A.emp_act(act)
	return
