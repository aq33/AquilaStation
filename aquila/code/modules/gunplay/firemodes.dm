// AQUILA - wybierak trybów ognia: bezpiecznik, pojedynczy, seria, ogień ciągły (wzór: Shiptest gun_firemodes, fire_select()).
// Tryby wynikają z tego, co broń już umie: seria z burst_size, ogień ciągły z full_auto.
// Odbezpieczona broń może wystrzelić sama przy upadku właściciela albo po rzuceniu (Shiptest trip_with_gun()/throw_impact()).

/obj/item/gun
	/// Czy broń ma bezpiecznik (pozycja AQ_FIREMODE_SAFE w wybieraku)
	var/has_safety = TRUE
	/// Aktualny tryb ognia
	var/aq_firemode
	/// Ostatni tryb strzelania przed zabezpieczeniem (do niego wraca odbezpieczenie)
	var/aq_last_fire_mode
	/// Dostępne tryby w kolejności przełączania
	var/list/aq_firemodes
	/// Szansa na przypadkowy wystrzał odbezpieczonej broni, gdy właściciel się przewróci
	var/accidental_fall_chance = 7
	/// Szansa na przypadkowy wystrzał odbezpieczonej broni po rzuceniu
	var/accidental_throw_chance = 15

// Broń magiczna, medyczna i strzykawkowa nie ma bezpiecznika ani trybów
/obj/item/gun/magic
	has_safety = FALSE
/obj/item/gun/medbeam
	has_safety = FALSE
/obj/item/gun/syringe
	has_safety = FALSE

/obj/item/gun/Initialize(mapload)
	. = ..()
	build_firemodes()

/// Buduje listę trybów z możliwości broni; nowa broń jest zabezpieczona
/obj/item/gun/proc/build_firemodes()
	aq_firemodes = list()
	if(has_safety)
		aq_firemodes += AQ_FIREMODE_SAFE
	aq_firemodes += AQ_FIREMODE_SEMI
	if(initial(burst_size) > 1)
		aq_firemodes += AQ_FIREMODE_BURST
	if(full_auto)
		aq_firemodes += AQ_FIREMODE_AUTO
	var/start_mode = has_safety ? AQ_FIREMODE_SAFE : aq_firemodes[length(aq_firemodes)]
	set_firemode(start_mode, null, TRUE)
	if(length(aq_firemodes) > 1 && !(locate(/datum/action/item_action/toggle_firemode) in actions))
		var/datum/action/item_action/toggle_firemode/selector = new(src)
		if(ismob(loc))
			selector.Grant(loc)

/// Nazwa trybu dla gracza
/proc/aq_firemode_name(mode)
	switch(mode)
		if(AQ_FIREMODE_SAFE)
			return "bezpiecznik"
		if(AQ_FIREMODE_SEMI)
			return "ogień pojedynczy"
		if(AQ_FIREMODE_BURST)
			return "seria"
		if(AQ_FIREMODE_AUTO)
			return "ogień ciągły"
	return mode

/// Ustawia tryb ognia; tryb serii przywraca burst_size broni, pozostałe strzelają pojedynczo
/obj/item/gun/proc/set_firemode(new_mode, mob/user, silent = FALSE)
	if(!(new_mode in aq_firemodes))
		return FALSE
	var/burst_before = burst_size
	aq_firemode = new_mode
	if(new_mode != AQ_FIREMODE_SAFE)
		aq_last_fire_mode = new_mode
	// Bezpiecznik zostawia serię broni (NPC bezpiecznika nie używają i strzelają jak dawniej, seriami)
	if(new_mode == AQ_FIREMODE_BURST || new_mode == AQ_FIREMODE_SAFE)
		burst_size = initial(burst_size)
		fire_delay = initial(fire_delay)
	else if(initial(burst_size) > 1)
		burst_size = 1
		fire_delay = 0
	if(istype(src, /obj/item/gun/ballistic/automatic))
		var/obj/item/gun/ballistic/automatic/auto = src
		auto.select = (burst_size > 1) ? 1 : 0
	if(autofire_component)
		autofire_component.stop_firing()
	if(!silent && user)
		balloon_alert(user, aq_firemode_name(new_mode))
		playsound(user, 'sound/weapons/empty.ogg', 60, TRUE)
	if(burst_before != burst_size || !silent)
		update_icon()
	for(var/datum/action/action as anything in actions)
		action.UpdateButtonIcon()
	SEND_SIGNAL(src, COMSIG_AQ_GUN_FIREMODE_CHANGED, new_mode)
	return TRUE

/// Następny tryb na liście
/obj/item/gun/proc/cycle_firemode(mob/user)
	if(length(aq_firemodes) < 2)
		return FALSE
	var/index = aq_firemodes.Find(aq_firemode)
	index = (index % length(aq_firemodes)) + 1
	return set_firemode(aq_firemodes[index], user)

/// Bezpiecznik osobno od wybieraka: zabezpiecza albo wraca do ostatniego trybu ognia
/obj/item/gun/proc/toggle_safety(mob/user)
	if(!has_safety)
		if(user)
			balloon_alert(user, "brak bezpiecznika")
		return FALSE
	if(aq_firemode != AQ_FIREMODE_SAFE)
		return set_firemode(AQ_FIREMODE_SAFE, user)
	var/fire_mode = (aq_last_fire_mode in aq_firemodes) ? aq_last_fire_mode : AQ_FIREMODE_SEMI
	return set_firemode(fire_mode, user)

/obj/item/gun/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/toggle_firemode))
		cycle_firemode(user)
		return
	return ..()

// Stary przełącznik serii z automatów i pistoletów z serią prowadzi teraz do wybieraka
/obj/item/gun/ballistic/automatic/burst_select()
	cycle_firemode(usr)

/obj/item/gun/ballistic/automatic/m90/burst_select()
	cycle_firemode(usr)

/obj/item/gun/examine(mob/user)
	. = ..()
	if(length(aq_firemodes) > 1)
		var/list/names = list()
		for(var/mode in aq_firemodes)
			names += aq_firemode_name(mode)
		. += "<span class='notice'>Tryb ognia: <b>[aq_firemode_name(aq_firemode)]</b> (dostępne: [english_list(names, and_text = " i ")]).</span>"

/// Czy bezpiecznik blokuje strzał tej osoby (NPC, cyborgi i wieżyczki go nie używają)
/obj/item/gun/proc/safety_blocks(mob/living/user)
	if(aq_firemode != AQ_FIREMODE_SAFE)
		return FALSE
	if(!istype(user) || !user.client || issilicon(user))
		return FALSE
	if(!(src in user.held_items))
		return FALSE
	return TRUE

// Samobójstwo mnoży obrażenia naboju w komorze ×5 i dopiero potem strzela. Gdy strzał nie padnie (bezpiecznik,
// przegrzanie), mnożnik nie może zostać na naboju i rosnąć z każdą próbą
/obj/item/gun/handle_suicide(mob/living/carbon/human/user, mob/living/carbon/human/target, params, bypass_timer)
	if(safety_blocks(user))
		balloon_alert(user, "bezpiecznik!")
		return
	var/obj/item/projectile/loaded = chambered?.BB
	var/loaded_damage = loaded?.damage
	. = ..()
	if(loaded && !QDELETED(loaded) && !loaded.fired && chambered?.BB == loaded)
		loaded.damage = loaded_damage

/obj/item/gun/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0, aimed = FALSE)
	if(safety_blocks(user))
		balloon_alert(user, "bezpiecznik!")
		playsound(src, dry_fire_sound, 20, TRUE)
		return FALSE
	return ..()

/// Przypadkowy wystrzał w losowym kierunku (upadek, rzut)
/obj/item/gun/proc/accidental_discharge(mob/living/holder)
	if(!has_safety || aq_firemode == AQ_FIREMODE_SAFE || !chambered?.BB || !can_shoot())
		return FALSE
	if(holder && HAS_TRAIT(holder, TRAIT_PACIFISM))
		return FALSE
	// Iglica jak przy zwykłym strzale (bez komunikatów): bez iglicy, z obcą albo bez właściciela broń sama nie odpali
	if(!no_pin_required && (!pin || (!(pin.obj_flags & EMAGGED) && (!holder || !pin.pin_auth(holder)))))
		return FALSE
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return FALSE
	var/obj/item/ammo_casing/casing = chambered
	var/stray_angle = rand(0, 359)
	casing.ready_proj(our_turf, holder, suppressed, ran_zone(BODY_ZONE_CHEST, 30), src) // kuźnia, odczynniki, tłumik
	var/list/strays = list(casing.BB)
	casing.BB = null
	// Śrut: reszta śrucin z łuski, każda z własnym odchyleniem (zwykły strzał robi to w fire_casing())
	for(var/i in 2 to max(casing.pellets, 1))
		var/obj/item/projectile/pellet = new casing.projectile_type(our_turf)
		pellet.firer = holder
		pellet.fired_from = src
		pellet.suppressed = suppressed
		pellet.def_zone = ran_zone(BODY_ZONE_CHEST, 30)
		strays += pellet
	for(var/obj/item/projectile/stray as anything in strays)
		stray.forceMove(our_turf)
		stray.starting = our_turf
		stray.ignore_source_check = TRUE // przypadkowa kula może trafić właściciela
		stray.fire(stray_angle + (length(strays) > 1 ? rand(-casing.variance, casing.variance) : 0))
	fire_sounds()
	visible_message("<span class='danger'>[src] wystrzeliwuje sam!</span>", "<span class='hear'>Słyszysz wystrzał!</span>")
	if(holder)
		log_combat(holder, holder, "accidentally discharged", src)
	process_chamber()
	update_icon()
	return TRUE

/obj/item/gun/equipped(mob/living/user, slot)
	. = ..()
	UnregisterSignal(user, list(COMSIG_LIVING_STATUS_KNOCKDOWN, COMSIG_LIVING_STATUS_PARALYZE))
	if(slot == ITEM_SLOT_HANDS)
		RegisterSignal(user, list(COMSIG_LIVING_STATUS_KNOCKDOWN, COMSIG_LIVING_STATUS_PARALYZE), PROC_REF(on_holder_fall))

/obj/item/gun/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, list(COMSIG_LIVING_STATUS_KNOCKDOWN, COMSIG_LIVING_STATUS_PARALYZE))

/obj/item/gun/proc/on_holder_fall(mob/living/source, amount)
	SIGNAL_HANDLER
	if(amount <= 0 || source.stat == DEAD)
		return
	if(HAS_TRAIT(source, TRAIT_STUNIMMUNE) || !(source.status_flags & CANKNOCKDOWN))
		return
	if(source.IsKnockdown() || source.IsParalyzed() || !(source.mobility_flags & MOBILITY_STAND))
		return // już leży: kolejne ogłuszenie nie jest nowym upadkiem
	if(!prob(accidental_fall_chance))
		return
	INVOKE_ASYNC(src, PROC_REF(accidental_discharge), source)

/obj/item/gun/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(prob(accidental_throw_chance))
		var/mob/living/thrower = throwingdatum?.thrower
		INVOKE_ASYNC(src, PROC_REF(accidental_discharge), istype(thrower) ? thrower : null)

/datum/keybinding/mob/aq_cycle_firemode
	key = "Unbound"
	name = "aq_firemode"
	full_name = "Tryb ognia"
	description = "Przełącz tryb ognia trzymanej broni (bezpiecznik, pojedynczy, seria, ogień ciągły)."
	keybind_signal = COMSIG_KB_AQ_CYCLE_FIREMODE

/datum/keybinding/mob/aq_cycle_firemode/down(client/user)
	. = ..()
	if(.)
		return
	var/obj/item/gun/held_gun = user.mob.get_active_held_item()
	if(!istype(held_gun))
		return
	held_gun.cycle_firemode(user.mob)
	return TRUE

/datum/keybinding/mob/aq_toggle_safety
	key = "Unbound"
	name = "aq_safety"
	full_name = "Bezpiecznik broni"
	description = "Zabezpiecz albo odbezpiecz trzymaną broń. Odbezpieczona wraca do ostatniego trybu ognia."
	keybind_signal = COMSIG_KB_AQ_TOGGLE_SAFETY

/datum/keybinding/mob/aq_toggle_safety/down(client/user)
	. = ..()
	if(.)
		return
	var/obj/item/gun/held_gun = user.mob.get_active_held_item()
	if(!istype(held_gun))
		return
	held_gun.toggle_safety(user.mob)
	return TRUE

