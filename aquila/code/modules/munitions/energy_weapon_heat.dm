// Port BeeStation/NSV13#2677 (Pockets-byte, sprite radiatora Invictus282): ciepło, soczewki i strojenie broni energetycznych.
// Strzał grzeje broń, chłodnice podprzestrzenne (subspace_cooling.dm) odprowadzają ciepło, a magazyny ciepła podnoszą próg.
// Każda strzelanina zużywa soczewki (alignment), a gorąca broń i rozjechane soczewki psują strojenie (freq).
// Przegrzanie wyłącza broń i wypuszcza parę, zerowe soczewki rozsadzają broń przy strzale, a słabe strojenie przerywa strzał.
// Serwis: śrubokręt i klucz otwierają obudowę, multitool ustawia soczewki, a ręka wpisuje sekwencję strojenia (minigra z DS13).
// Różnice względem oryginału (opis w PR): wbudowane chłodzenie równe jednej chłodnicy, chłodnice z mapy łączą się same,
// chłodnica liczy się tylko włączona, bez paska ciepła na ekranie, poprawione błędy wersji WIP.

#define ENERGY_STATE_NOTHING 0
#define ENERGY_STATE_VENTING 1
#define ENERGY_STATE_OVERLOAD 2
/// Wbudowane chłodzenie: tyle chłodnic ma każda broń bez podłączonych
#define ENERGY_BUILTIN_COOLERS 1
/// Od tylu podłączonych urządzeń broń wybucha (jak w oryginale)
#define ENERGY_MAX_COOLING_LINKS 10

/// Stany ikon przegrzanej broni (kopia energy_weapons.dmi z oryginału ze stanami _overheat)
GLOBAL_LIST_INIT(energy_weapon_heat_states, icon_states('aquila/icons/obj/munitions/energy_weapons_heat.dmi'))

/obj/machinery/ship_weapon/energy
	maintainable = TRUE
	max_integrity = 1200
	obj_integrity = 1200
	charge_rate = 400000
	power_modifier_cap = 8
	/// Ustawienie soczewek (0-100): spada przy strzałach, przy 0 broń wybucha
	var/alignment = 100
	/// Strojenie częstotliwości (0-100): spada od ciepła i słabych soczewek, przy 10 i mniej strzał się przerywa
	var/freq = 100
	var/max_freq = 100
	/// Ile najwyżej strojenia traci jedna usterka
	var/freq_max = 10
	/// Znaki sekwencji strojenia -> ikona w menu kołowym
	var/list/alignment_options
	/// Która pozycja sekwencji jest teraz do wpisania
	var/combo = 1
	var/list/combo_target = list()
	/// Podłączone chłodnice i magazyny ciepła
	var/list/cooling = list()
	var/cooling_amount = 0
	var/storage_amount = 0
	/// O ile jeden magazyn ciepła podnosi próg przegrzania
	var/storage_rate = 150
	/// Do jakiego ciepła trwa odprowadzanie
	var/vent_target = 0
	var/heat = 0
	var/heat_per_shot = 150
	/// Ile ciepła na tick odprowadza jedna chłodnica
	var/heat_rate = 10
	var/max_heat = 1000
	/// Trwa serwis (minigra albo ustawianie soczewek)
	var/lockout = FALSE
	var/weapon_state = ENERGY_STATE_NOTHING
	/// Soczewki termiczne: ciepło broni dodaje do 70% obrażeń
	var/thermal = TRUE
	var/overheat_sound = 'sound/effects/smoke.ogg'

/obj/machinery/ship_weapon/energy/beam
	charge_rate = 700000
	heat_per_shot = 1000 // dwa strzały z dwoma magazynami ciepła
	heat_rate = 20
	storage_rate = 250
	thermal = FALSE

/obj/machinery/ship_weapon/energy/beam/bsa
	maintainable = FALSE // Centrala nie musi serwisować swojego działa

/obj/machinery/ship_weapon/energy/ams
	maintainable = TRUE
	max_heat = 800
	heat_per_shot = 100
	heat_rate = 30
	storage_rate = 100
	freq_max = 4
	thermal = FALSE
	charge_rate = 1500000 // przy mocy 2 to 3 MW na tick
	max_charge = 6000000 // dwa ładunki

/obj/machinery/ship_weapon/energy/laser_pd
	maintainable = FALSE
	thermal = FALSE

/obj/item/projectile/beam/laser/phaser
	damage = 35

/datum/overmap_ship_weapon/burst_phaser
	weapon_firing_flags = NONE
	weapon_facing_flags = OSW_FACING_FRONT
	firing_arc = 60

/datum/overmap_ship_weapon/laser_ams
	burst_size = 2
	fire_delay = 0.1 SECONDS // szybszy, bo broń trzeba teraz serwisować

/obj/machinery/ship_weapon/energy/Initialize(mapload)
	. = ..()
	alignment_options = list(
		"delta" = image(icon = 'aquila/icons/obj/munitions/energy_alignment_radial.dmi', icon_state = "delta"),
		"omega" = image(icon = 'aquila/icons/obj/munitions/energy_alignment_radial.dmi', icon_state = "omega"),
		"phi" = image(icon = 'aquila/icons/obj/munitions/energy_alignment_radial.dmi', icon_state = "phi"),
	)
	realign()

/obj/machinery/ship_weapon/energy/Destroy()
	for(var/obj/machinery/cooling/unit as anything in cooling)
		unit.parent = null
	cooling.Cut()
	return ..()

/// Nowa sekwencja strojenia (4-9 znaków)
/obj/machinery/ship_weapon/energy/proc/realign()
	combo = 1
	combo_target = list()
	for(var/i in 1 to rand(4, 9))
		combo_target += pick(alignment_options)

/obj/machinery/ship_weapon/energy/examine(mob/user)
	. = ..()
	if(!maintainable)
		. += "<span class='notice'>Ma samoczynny układ chłodzenia i nanoogniskowanie wiązki, nie wymaga serwisu.</span>"
		return
	. += "<span class='notice'>Przekaźnik termiczny: podłączone urządzenia [length(cooling)]/[ENERGY_MAX_COOLING_LINKS].</span>"
	if(thermal)
		. += "<span class='notice'>Kwantowe soczewki termiczne zamieniają ciepło broni w moc wiązki.</span>"
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>Ciepło: <b>[round(heat)]</b> z <b>[max_heat]</b>. Soczewki: [alignment]%, strojenie: [freq]%.</span>"
		if(maint_state != MSTATE_CLOSED)
			. += "<span class='warning'>Sekwencja strojenia: [jointext(combo_target, ", ")].</span>"
		if(maint_state == MSTATE_UNBOLTED)
			. += "<span class='notice'>Multitoolem ustawisz soczewki, a ręką wpiszesz sekwencję strojenia.</span>"
		if(weapon_state == ENERGY_STATE_VENTING)
			. += "<span class='warning'>Układ chłodzenia pracuje na pełnej mocy.</span>"
		if(weapon_state == ENERGY_STATE_OVERLOAD)
			. += "<span class='danger'>Układ chłodzenia jest w trybie awaryjnym po przegrzaniu.</span>"

/obj/machinery/ship_weapon/energy/ui_act(action, params)
	. = ..()
	if(.)
		return
	if(action == "vent")
		vent()
		return TRUE

/obj/machinery/ship_weapon/energy/ui_data(mob/user)
	. = ..()
	.["maintainable"] = maintainable
	.["alignment"] = alignment
	.["heat"] = round(heat)
	.["maxheat"] = max_heat
	.["frequency"] = freq
	.["overloaded"] = weapon_state == ENERGY_STATE_OVERLOAD
	.["venting"] = weapon_state == ENERGY_STATE_VENTING

/obj/machinery/ship_weapon/energy/attack_hand(mob/user)
	if(maint_state == MSTATE_UNBOLTED && maintainable && !lockout)
		lockout = TRUE
		while(align(user)) // każdy dobry znak otwiera menu na następny
			continue
		lockout = FALSE
		return
	return ..()

/// Jeden znak sekwencji strojenia; TRUE = wpisuj dalej
/obj/machinery/ship_weapon/energy/proc/align(mob/living/user)
	SEND_SOUND(user, pick('nsv13/sound/effects/computer/beep.ogg', 'nsv13/sound/effects/computer/beep2.ogg', 'nsv13/sound/effects/computer/beep3.ogg', 'nsv13/sound/effects/computer/beep4.ogg', 'nsv13/sound/effects/computer/beep5.ogg', 'nsv13/sound/effects/computer/beep6.ogg'))
	var/choice = show_radial_menu(user, src, alignment_options, require_near = TRUE)
	if(!choice || QDELETED(src) || maint_state != MSTATE_UNBOLTED)
		return FALSE
	to_chat(user, "<span class='notice'>Wpisujesz [choice] do sekwencji.</span>")
	playsound(src, 'sound/machines/sm/supermatter3.ogg', 20, TRUE)
	if(combo_target[combo] != choice)
		to_chat(user, "<span class='warning'>Strojenie nieudane. Kolejne pomyłki grożą przegrzaniem. Sekwencja zmieniona.</span>")
		playsound(src, 'aquila/sound/effects/energy_weapon_overload.ogg', 100, TRUE)
		heat = min(heat + heat_per_shot * 4, max_heat + 50) // kara za pomyłkę
		realign()
		return FALSE
	if(combo == length(combo_target))
		to_chat(user, "<span class='notice'>Strojenie macierzy kierunkowej wiązki zakończone.</span>")
		playsound(src, 'sound/machines/sm/supermatter1.ogg', 30, TRUE)
		freq = max_freq
		realign()
		return FALSE
	combo++
	return TRUE

/obj/machinery/ship_weapon/energy/multitool_act(mob/living/user, obj/item/I)
	if(lockout)
		return TRUE
	if(!maintainable)
		return ..()
	switch(maint_state)
		if(MSTATE_UNSCREWED)
			to_chat(user, "<span class='notice'>Najpierw <i>odkręć</i> kluczem wewnętrzną obudowę, żeby dostać się do soczewek!</span>")
			return TRUE
		if(MSTATE_UNBOLTED)
			if(alignment >= 100)
				to_chat(user, "<span class='notice'>Soczewki [src] są ustawione.</span>")
				return TRUE
			to_chat(user, "<span class='notice'>Zaczynasz ustawiać soczewki.</span>")
			lockout = TRUE
			while(alignment < 100)
				if(!do_after(user, 0.5 SECONDS, target = src))
					break
				alignment = min(alignment + rand(1, 2), 100)
			if(alignment >= 100)
				to_chat(user, "<span class='notice'>Kończysz ustawiać soczewki.</span>")
			lockout = FALSE
			return TRUE
	return ..()

/obj/machinery/ship_weapon/energy/default_deconstruction_crowbar(obj/item/I, ignore_panel)
	if(maintainable && (freq < max_freq || alignment < 100) && usr)
		var/confirm = tgui_alert(usr, "Broń nie jest gotowa do rozebrania. Delikatne soczewki z kryształów bluespace mogą przy tym pęknąć. Na pewno?", "Rozbieranie: [src]", list("Tak", "Nie"))
		if(confirm != "Tak" || QDELETED(src))
			return FALSE
		if(prob(50))
			visible_message("<span class='danger'>Ze środka [src] dobiega okropny trzask, gdy [usr] rozbiera broń!</span>")
			playsound(src, 'sound/effects/glass_step.ogg', 100, TRUE, extrarange = 30)
			for(var/obj/item/stack/ore/bluespace_crystal/crystal in component_parts)
				component_parts -= crystal
				qdel(crystal)
		else
			visible_message("<span class='notice'>[usr] zdejmuje delikatne soczewki, zanim wyjmie główny moduł.</span>")
	return ..()

/// Odprowadzanie ciepła na pełnej mocy (jak w Starsectorze): broń nie strzela, dopóki nie zejdzie do 1/4 progu
/obj/machinery/ship_weapon/energy/proc/vent()
	if(!maintainable || weapon_state == ENERGY_STATE_OVERLOAD)
		playsound(src, pick('nsv13/sound/effects/computer/error.ogg', 'nsv13/sound/effects/computer/error2.ogg', 'nsv13/sound/effects/computer/error3.ogg'), 100, TRUE)
		return FALSE
	if(heat <= max_heat * 0.25)
		playsound(src, pick('nsv13/sound/effects/computer/error.ogg', 'nsv13/sound/effects/computer/error2.ogg', 'nsv13/sound/effects/computer/error3.ogg'), 100, TRUE)
		return FALSE
	weapon_state = ENERGY_STATE_VENTING
	vent_target = max_heat * 0.25
	playsound(src, 'sound/effects/turbolift/turbolift-close.ogg', 100, TRUE)
	playsound(src, overheat_sound, 100, TRUE)
	return TRUE

/obj/machinery/ship_weapon/energy/can_fire(atom/target, shots = linked_overmap_ship_weapon.burst_size)
	if(get_ammo() < shots)
		return FALSE
	if(!maintainable)
		return TRUE
	if(weapon_state != ENERGY_STATE_NOTHING) // przegrzana albo odprowadza ciepło
		return FALSE
	if(freq <= 10)
		for(var/mob/living/M in range(10, get_turf(src)))
			shake_with_inertia(M, 2, 1)
		visible_message("<span class='userdanger'>Wykryto usterkę w [src]! Sekwencja strzału przerwana!</span>")
		overload()
		return FALSE
	if(alignment <= 0)
		playsound(src, malfunction_sound, 100, TRUE)
		for(var/mob/living/M in get_hearers_in_view(7, src))
			if(M.stat != DEAD && M.get_eye_protection() < 2)
				M.flash_act(10)
				to_chat(M, "<span class='warning'>Przez sekundę widzisz, jak obudowa broni żarzy się na czerwono, zanim rozsadza ją oślepiający błysk!</span>")
		explosion(get_turf(src), 0, 1, 3, 5, flame_range = 4)
		overload()
		return FALSE
	return TRUE

/obj/machinery/ship_weapon/energy/animate_projectile(atom/target)
	var/obj/item/projectile/P = ..()
	if(thermal && maintainable && istype(P) && max_heat)
		P.damage += P.damage * 0.7 * min(heat / max_heat, 1)
	return P

/obj/machinery/ship_weapon/energy/process()
	process_heat()
	return ..()

/obj/machinery/ship_weapon/energy/maint_wear()
	if(!maintainable)
		return
	heat += heat_per_shot
	handle_alignment()

/obj/machinery/ship_weapon/energy/after_fire()
	if(maintainable && maint_state != MSTATE_CLOSED)
		// strzał z otwartą obudową razi prądem wszystkich wokół
		tesla_zap(src, 4, 1000)
		for(var/mob/living/carbon/C in orange(4, src))
			C.flash_act()
		for(var/mob/living/carbon/C in orange(12, src))
			to_chat(C, "<span class='danger'>Z odsłoniętego mechanizmu spustowego strzelają łuki elektryczne.</span>")
	return ..()

/// Odprowadzanie ciepła co tick SSmachines
/obj/machinery/ship_weapon/energy/proc/process_heat()
	if(!maintainable)
		return
	cooling_amount = ENERGY_BUILTIN_COOLERS
	storage_amount = 0
	for(var/obj/machinery/cooling/unit as anything in cooling)
		if(!unit.is_working())
			continue
		if(istype(unit, /obj/machinery/cooling/storage))
			storage_amount++
		else
			cooling_amount++
	max_heat = initial(max_heat) + storage_amount * storage_rate
	var/dissipation = cooling_amount * heat_rate
	if(weapon_state == ENERGY_STATE_VENTING)
		dissipation += cooling_amount * heat_rate * 1.25
	heat = max(heat - dissipation, 0)
	switch(weapon_state)
		if(ENERGY_STATE_OVERLOAD)
			if(heat <= max_heat / 50)
				recover_from_overload()
			return
		if(ENERGY_STATE_VENTING)
			if(heat <= vent_target)
				weapon_state = ENERGY_STATE_NOTHING
			return
	if(heat >= max_heat)
		overload()

/// Najgorsze poza wybuchem: przegrzanie wyłącza broń, wypuszcza gorącą parę i zeruje soczewki i strojenie
/obj/machinery/ship_weapon/energy/proc/overload()
	if(weapon_state == ENERGY_STATE_OVERLOAD)
		return
	if(initial(icon) == 'nsv13/icons/obj/energy_weapons.dmi')
		icon = 'aquila/icons/obj/munitions/energy_weapons_heat.dmi'
		icon_state = ("[initial(icon_state)]_overheat" in GLOB.energy_weapon_heat_states) ? "[initial(icon_state)]_overheat" : "overheat"
	playsound(src, malfunction_sound, 100, TRUE)
	playsound(src, overheat_sound, 100, TRUE)
	do_sparks(4, FALSE, src)
	weapon_state = ENERGY_STATE_OVERLOAD
	alignment = 0
	freq = 0
	say("UWAGA! Krytyczna gęstość ciepła, awaryjne odprowadzanie i wyłączenie!")
	atmos_spawn_air("[GAS_H2O]=200;TEMP=1000")
	heat = max_heat
	charge = 0

/obj/machinery/ship_weapon/energy/proc/recover_from_overload()
	weapon_state = ENERGY_STATE_NOTHING
	icon = initial(icon)
	icon_state = initial(icon_state)

/// Usterki przy strzale: im gorsze soczewki, tym częściej iskry, wybuchy i zabłąkane wiązki w okręcie
/obj/machinery/ship_weapon/energy/proc/handle_alignment()
	var/turf/detonation_turf = get_turf(src)
	if(heat >= max_heat * 0.75)
		freq = max(freq - rand(1, max(1, round(freq_max * 0.4))), 0)
	switch(alignment)
		if(51 to 75)
			if(prob(50))
				do_sparks(4, FALSE, src)
				freq = max(freq - rand(1, freq_max), 0)
		if(26 to 50)
			switch(rand(1, 20))
				if(1 to 9)
					do_sparks(4, FALSE, src)
					freq = max(freq - rand(1, freq_max), 0)
					playsound(src, malfunction_sound, 100, TRUE)
				if(10)
					playsound(src, malfunction_sound, 100, TRUE)
					freq = max(freq - rand(1, freq_max), 0)
					explosion(detonation_turf, 0, 0, 2, 3, flame_range = 2)
				if(11 to 20)
					pass() // tym razem bez usterki
		if(0 to 25)
			switch(rand(1, 4))
				if(1)
					do_sparks(4, FALSE, src)
					playsound(src, malfunction_sound, 100, TRUE)
					freq = max(freq - rand(1, freq_max), 0)
				if(2)
					playsound(src, malfunction_sound, 100, TRUE)
					freq = max(freq - rand(1, freq_max), 0)
					explosion(detonation_turf, 0, 0, 3, 4, flame_range = 3)
				if(3, 4)
					var/list/ring = RANGE_TURFS(5, detonation_turf) - RANGE_TURFS(4, detonation_turf)
					var/obj/item/projectile/beam/laser/stray = new(detonation_turf)
					stray.range = 6
					stray.preparePixelProjectile(pick(ring), detonation_turf)
					stray.fire()
					freq = max(freq - rand(1, freq_max), 0)
	alignment = max(alignment - rand(0, 4), 0)

/// AMS strzela w losowe z pierwszych dziesięciu torped lecących na okręt, a bez torped nie strzela
/obj/machinery/ship_weapon/energy/ams/fire(atom/target, shots = linked_overmap_ship_weapon.burst_size, manual = TRUE)
	if(!linked)
		return FALSE
	var/list/targets = linked.torpedoes_to_target.Copy(1, min(length(linked.torpedoes_to_target), 10) + 1)
	if(!length(targets))
		return FALSE
	if(!can_fire(target, shots))
		return FALSE
	if(manual)
		linked.last_fired = overlay
	for(var/i in 1 to shots)
		do_animation()
		local_fire()
		overmap_fire(pick(targets))
		charge -= charge_per_shot
		after_fire()
		. = TRUE
		if(shots > 1)
			sleep(linked_overmap_ship_weapon.burst_fire_delay)
	return TRUE

#undef ENERGY_STATE_NOTHING
#undef ENERGY_STATE_VENTING
#undef ENERGY_STATE_OVERLOAD
#undef ENERGY_BUILTIN_COOLERS
