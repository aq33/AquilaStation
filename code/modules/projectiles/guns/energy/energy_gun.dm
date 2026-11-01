/obj/item/gun/energy/e_gun
	name = "broń energetyczna"
	desc = "Podstawowa hybrydowa broń energetyczna z dwoma trybami: obezwładniającym i zabójczym."
	icon_state = "energy"
	w_class = WEIGHT_CLASS_BULKY	//powergaming is kill
	item_state = null	//so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)
	modifystate = 1
	can_flashlight = TRUE
	ammo_x_offset = 3
	flight_x_offset = 15
	flight_y_offset = 10
	weapon_weight = WEAPON_MEDIUM
	dual_wield_spread = 60

/obj/item/gun/energy/e_gun/mini
	name = "miniaturowa broń energetyczna"
	desc = "Mała broń energetyczna wielkości pistoletu z wbudowaną latarką. Ma dwa tryby: obezwładniający i zabójczy."
	icon_state = "mini"
	item_state = "gun"
	w_class = WEIGHT_CLASS_SMALL
	gun_charge = 600
	ammo_x_offset = 2
	charge_sections = 3
	can_flashlight = FALSE // Can't attach or detach the flashlight, and override it's icon update
	weapon_weight = WEAPON_LIGHT

/obj/item/gun/energy/e_gun/mini/heads
	name = "Osobisty Tyci Samoobronny Dezintegrator"
	desc = "OTSD ma wbudowaną latarkę i potrafi sam się naładować w dwie minuty. To standardowe wyposażenie kadry dowódczej Solgovu. Ma dwa tryby: obezwładniający i zabójczy." //NSV13 change Nanotrasen to Solgov
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/hos, /obj/item/ammo_casing/energy/laser) ///uses the hos disabler rounds to slightly weaken the disabler count and also to avoid encountering a visual bug where the gun is out of charge but displays that it has one enough for another shot.
	selfcharge = 1
	charge_delay = 20
	can_charge = FALSE 			///Not compatible with fast charging stations, must recharge slowly.
	icon_state = "personal"
	item_state = "gun"
	ammo_x_offset = 2
	charge_sections = 2
	flight_x_offset = 13
	flight_y_offset = 12

/obj/item/gun/energy/e_gun/mini/Initialize(mapload)
	set_gun_light(new /obj/item/flashlight/seclite(src))
	return ..()

/obj/item/gun/energy/e_gun/stun
	name = "taktyczna broń energetyczna"
	desc = "Wojskowa broń energetyczna, która potrafi strzelać pociskami ogłuszającymi."
	icon_state = "energytac"
	ammo_x_offset = 2
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/spec, /obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)

/obj/item/gun/energy/e_gun/old
	name = "prototypowa broń energetyczna"
	desc = "Prototypowa broń energetyczna NT-P:01. Wczesna faza prac nad wyjątkowym karabinem laserowym z wielofasetową soczewką energetyczną, dzięki której broń na rozkaz zmienia rodzaj wystrzeliwanego pocisku."
	icon_state = "protolaser"
	ammo_x_offset = 2
	ammo_type = list(/obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/electrode/old)

/obj/item/gun/energy/e_gun/mini/practice_phaser
	name = "treningowy fazer"
	desc = "Zmodyfikowana wersja podstawowego fazera. Strzela słabiej skupionymi pociskami energii, przeznaczonymi do ćwiczeń strzeleckich."
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser/practice)
	icon_state = "decloner"

/obj/item/gun/energy/e_gun/hos
	name = "\improper wielofazowa broń energetyczna X-01"
	desc = "Droga, nowoczesna replika zabytkowej broni laserowej. Ma kilka wyjątkowych trybów ognia, ale z czasem sama się nie ładuje."
	gun_charge = 1200
	icon_state = "hoslaser"
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	automatic = 1
	fire_rate = 3
	full_auto = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/hos, /obj/item/ammo_casing/energy/laser/hos, /obj/item/ammo_casing/energy/disabler/hos)
	ammo_x_offset = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	investigate_flags = ADMIN_INVESTIGATE_TARGET

/obj/item/gun/energy/e_gun/dragnet
	name = "\improper DRAGnet"
	desc = "Sieć „Dynamicznego Rychłego Aresztowania Gagatków” to rewolucja w technologii stróżów prawa."
	icon_state = "dragnet"
	item_state = "dragnet"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	ammo_type = list(/obj/item/ammo_casing/energy/net, /obj/item/ammo_casing/energy/trap)
	can_flashlight = FALSE
	ammo_x_offset = 1
	fire_rate = 1.5
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun/energy/e_gun/dragnet/snare
	name = "wyrzutnia sideł energetycznych"
	desc = "Wystrzeliwuje sidła energetyczne, które spowalniają cel."
	ammo_type = list(/obj/item/ammo_casing/energy/trap)

/obj/item/gun/energy/e_gun/turret
	name = "hybrydowe działko wieżyczki"
	desc = "Ciężkie hybrydowe działo energetyczne z dwoma trybami: ogłuszającym i zabójczym."
	icon_state = "turretlaser"
	item_state = "turretlaser"
	slot_flags = null
	w_class = WEIGHT_CLASS_HUGE
	gun_charge = 10000
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser)
	weapon_weight = WEAPON_HEAVY
	can_flashlight = FALSE
	trigger_guard = TRIGGER_GUARD_NONE
	ammo_x_offset = 2
	automatic = 1
	fire_rate = 5

/obj/item/gun/energy/e_gun/nuclear
	name = "zaawansowana broń energetyczna"
	desc = "Broń energetyczna z eksperymentalnym miniaturowym reaktorem jądrowym, który sam ładuje wewnętrzne ogniwo zasilające."
	icon_state = "nucgun"
	item_state = "nucgun"
	charge_delay = 10
	pin = null
	can_charge = FALSE
	ammo_x_offset = 1
	ammo_type = list(/obj/item/ammo_casing/energy/laser, /obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/disabler) //NSV13 - readded electrode
	selfcharge = 1
	var/reactor_overloaded
	var/fail_tick = 0
	var/fail_chance = 0

/obj/item/gun/energy/e_gun/nuclear/process(delta_time)
	if(fail_tick > 0)
		fail_tick -= delta_time * 0.5
	..()

/obj/item/gun/energy/e_gun/nuclear/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
	failcheck()
	update_icon()
	..()

/obj/item/gun/energy/e_gun/nuclear/proc/failcheck()
	if(prob(fail_chance) && isliving(loc))
		var/mob/living/M = loc
		switch(fail_tick)
			if(0 to 200)
				fail_tick += (2*(fail_chance))
				M.rad_act(40)
				to_chat(M, "<span class='userdanger'>Twój [name] robi się cieplejszy.</span>")
			if(201 to INFINITY)
				SSobj.processing.Remove(src)
				M.rad_act(80)
				reactor_overloaded = TRUE
				to_chat(M, "<span class='userdanger'>Reaktor twojego [name] się przeciąża!</span>")

/obj/item/gun/energy/e_gun/nuclear/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	fail_chance = min(fail_chance + round(15/severity), 100)

/obj/item/gun/energy/e_gun/nuclear/update_icon()
	..()
	if(reactor_overloaded)
		add_overlay("[icon_state]_fail_3")
	else
		switch(fail_tick)
			if(0)
				add_overlay("[icon_state]_fail_0")
			if(1 to 150)
				add_overlay("[icon_state]_fail_1")
			if(151 to INFINITY)
				add_overlay("[icon_state]_fail_2")
