/obj/item/gun/energy/ionrifle
	name = "karabin jonowy"
	desc = "Przenośna broń przeciwpancerna do unieszkodliwiania zagrożeń mechanicznych na odległość."
	icon_state = "ionrifle"
	item_state = null	//so the human update icon uses the icon_state instead.
	can_flashlight = TRUE
	w_class = WEIGHT_CLASS_HUGE
	flags_1 =  CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	ammo_type = list(/obj/item/ammo_casing/energy/ion)
	ammo_x_offset = 3
	flight_x_offset = 17
	flight_y_offset = 9

/obj/item/gun/energy/ionrifle/carbine
	name = "karabinek jonowy"
	desc = "Prototypowy projektor jonowy MK.II to lekka, ergonomiczna i wydajna wersja większego karabinu jonowego."
	icon_state = "ioncarbine"
	worn_icon_state = "ioncarbine"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	pin = null
	ammo_x_offset = 2
	flight_x_offset = 18
	flight_y_offset = 11

/obj/item/gun/energy/ionrifle/carbine/pin
	pin = /obj/item/firing_pin

/obj/item/gun/energy/decloner
	name = "biologiczny demolekularyzator"
	desc = "Broń emitująca duże dawki kontrolowanego promieniowania, które powoli rozbijają cel na pierwiastki."
	icon_state = "decloner"
	ammo_type = list(/obj/item/ammo_casing/energy/declone)
	pin = null
	ammo_x_offset = 1

/obj/item/gun/energy/decloner/update_icon()
	..()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(!QDELETED(cell) && (cell.charge > shot.e_cost))
		add_overlay("decloner_spin")

/obj/item/gun/energy/decloner/unrestricted
	pin = /obj/item/firing_pin
	ammo_type = list(/obj/item/ammo_casing/energy/declone/weak)

/obj/item/gun/energy/floragun
	name = "roślinny somatopromiennik"
	desc = "Narzędzie emitujące kontrolowane promieniowanie, które wywołuje mutacje w komórkach roślin."
	icon_state = "flora"
	item_state = "gun"
	ammo_type = list(/obj/item/ammo_casing/energy/flora/yield, /obj/item/ammo_casing/energy/flora/mut)
	modifystate = 1
	ammo_x_offset = 1
	selfcharge = 1

/obj/item/gun/energy/meteorgun
	name = "działko meteorytowe"
	desc = "Na litość boską, upewnij się, że celujesz w dobrą stronę!"
	icon_state = "meteor_gun"
	item_state = "c20r"
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = list(/obj/item/ammo_casing/energy/meteor)
	cell_type = "/obj/item/stock_parts/cell/potato"
	clumsy_check = 0 //Admin spawn only, might as well let clowns use it.
	selfcharge = 1

/obj/item/gun/energy/meteorgun/pen
	name = "długopis meteorytowy"
	desc = "Pióro jest potężniejsze od miecza."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY

/obj/item/gun/energy/mindflayer
	name = "\improper Mind Flayer"
	desc = "Prototypowa broń odzyskana z ruin Stacji Badawczej Epsilon."
	icon_state = "xray"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/mindflayer)
	ammo_x_offset = 2

/obj/item/gun/energy/kinetic_accelerator/crossbow
	name = "mini kusza energetyczna"
	desc = "Broń ulubiona przez specjalistów od skrytych operacji Syndykatu."
	icon_state = "crossbow"
	item_state = "crossbow"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(/datum/material/iron=2000)
	suppressed = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/bolt)
	weapon_weight = WEAPON_LIGHT
	obj_flags = 0
	overheat_time = 20
	holds_charge = TRUE
	unique_frequency = TRUE
	can_flashlight = FALSE
	max_mod_capacity = 0

/obj/item/gun/energy/kinetic_accelerator/crossbow/halloween
	name = "cukierkowa kusza"
	desc = "Broń ulubiona przez zbieraczy słodyczy z Syndykatu."
	icon_state = "crossbow_halloween"
	item_state = "crossbow"
	ammo_type = list(/obj/item/ammo_casing/energy/bolt/halloween)

/obj/item/gun/energy/kinetic_accelerator/crossbow/large
	name = "kusza energetyczna"
	desc = "Broń odtworzona inżynierią wsteczną z technologii Syndykatu."
	icon_state = "crossbowlarge"
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(/datum/material/iron=4000)
	suppressed = null
	ammo_type = list(/obj/item/ammo_casing/energy/bolt/large)
	pin = null

/obj/item/gun/energy/kinetic_accelerator/crossbow/radbow
	name = "łuk gamma"
	desc = "Broń ulubiona przez szaleńców."
	icon_state = "crossbow"
	item_state = "crossbow"
	ammo_type = list(/obj/item/ammo_casing/energy/bolt/radbolt)
	overheat_time = 250

/obj/item/gun/energy/plasmacutter
	name = "przecinak plazmowy"
	desc = "Narzędzie górnicze wyrzucające skoncentrowane impulsy plazmy. Można nim odcinać kończyny ksenomorfom! Albo, no wiesz, kopać."
	icon_state = "plasmacutter"
	item_state = "plasmacutter"
	ammo_type = list(/obj/item/ammo_casing/energy/plasma)
	flags_1 = CONDUCT_1
	attack_verb = list("atakuje", "ciacha", "tnie", "kroi")
	force = 12
	sharpness = IS_SHARP
	can_charge = FALSE
	dead_cell = TRUE

	heat = 3800
	usesound = list('sound/items/welder.ogg', 'sound/items/welder2.ogg')
	tool_behaviour = TOOL_WELDER
	toolspeed = 0.7 //plasmacutters can be used as welders, and are faster than standard welders
	var/progress_flash_divisor = 10  //copypasta is best pasta
	var/light_intensity = 1
	var/charge_weld = 25 //amount of charge used up to start action (multiplied by amount) and per progress_flash_divisor ticks of welding
	weapon_weight = WEAPON_LIGHT
	fire_rate = 3
	automatic = 1

/obj/item/gun/energy/plasmacutter/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 25, 105, 0, 'sound/weapons/plasma_cutter.ogg')

/obj/item/gun/energy/plasmacutter/examine(mob/user)
	. = ..()
	if(cell)
		. += "<span class='notice'>[src] jest naładowany w [round(cell.percent())]%.</span>"

/obj/item/gun/energy/plasmacutter/attackby(obj/item/I, mob/user)
	var/charge_multiplier = 0 //2 = Refined stack, 1 = Ore
	if(istype(I, /obj/item/stack/sheet/mineral/plasma))
		charge_multiplier = 2
	if(istype(I, /obj/item/stack/ore/plasma))
		charge_multiplier = 1
	if(charge_multiplier)
		if(cell.charge == cell.maxcharge)
			to_chat(user, "<span class='notice'>Próbujesz włożyć [I] do [src], ale jest w pełni naładowany.</span>") //my cell is round and full
			return
		I.use(1)
		cell.give(50*charge_multiplier)
		to_chat(user, "<span class='notice'>Wkładasz [I] do [src], ładując go.</span>")
	else
		..()

// Tool procs, in case plasma cutter is used as welder
// Can we start welding?
/obj/item/gun/energy/plasmacutter/tool_start_check(mob/living/user, amount)
	. = tool_use_check(user, amount)
	if(. && user)
		user.flash_act(light_intensity)

// Can we weld? Plasma cutter does not use charge continuously.
// Amount cannot be defaulted to 1: most of the code specifies 0 in the call.
/obj/item/gun/energy/plasmacutter/tool_use_check(mob/living/user, amount)
	if(QDELETED(cell))
		to_chat(user, "<span class='warning'>[src] nie ma ogniwa i nie da się go użyć!</span>")
		return FALSE
	// Amount cannot be used if drain is made continuous, e.g. amount = 5, charge_weld = 25
	// Then it'll drain 125 at first and 25 periodically, but fail if charge dips below 125 even though it still can finish action
	// Alternately it'll need to drain amount*charge_weld every period, which is either obscene or makes it free for other uses
	if(amount ? cell.charge < charge_weld * amount : cell.charge < charge_weld)
		to_chat(user, "<span class='warning'>Potrzebujesz więcej ładunku, by to zrobić!</span>")
		return FALSE

	return TRUE

/obj/item/gun/energy/plasmacutter/use(amount)
	return (!QDELETED(cell) && cell.use(amount ? amount * charge_weld : charge_weld))

// This only gets called by use_tool(delay > 0)
// It's also supposed to not get overridden in the first place.
/obj/item/gun/energy/plasmacutter/tool_check_callback(mob/living/user, amount, datum/callback/extra_checks)
	. = ..() //return tool_use_check(user, amount) && (!extra_checks || extra_checks.Invoke())
	if(. && user)
		if (progress_flash_divisor == 0)
			user.flash_act(min(light_intensity,1))
			progress_flash_divisor = initial(progress_flash_divisor)
		else
			progress_flash_divisor--

/obj/item/gun/energy/plasmacutter/use_tool(atom/target, mob/living/user, delay, amount=1, volume=0, datum/callback/extra_checks)
	if(amount)
		target.add_overlay(GLOB.welding_sparks)
		. = ..()
		target.cut_overlay(GLOB.welding_sparks)
	else
		. = ..(amount=1)


/obj/item/gun/energy/plasmacutter/update_icon()
	return

/obj/item/gun/energy/plasmacutter/adv
	name = "zaawansowany przecinak plazmowy"
	icon_state = "adv_plasmacutter"
	item_state = "adv_plasmacutter"
	force = 15
	ammo_type = list(/obj/item/ammo_casing/energy/plasma/adv)

/obj/item/gun/energy/plasmacutter/cyborg
	name = "przecinak plazmowy cyborga"
	desc = "Wbudowany przecinak plazmowy."
	dead_cell = FALSE
	can_charge = FALSE
	use_cyborg_cell = TRUE
	tool_behaviour = null //because it will drain the cutters cell and not the borgs.
	requires_wielding = FALSE


/obj/item/gun/energy/wormhole_projector
	name = "projektor tuneli bluespace"
	desc = "Projektor emitujący kwantowo sprzężone wiązki bluespace o dużej gęstości."
	ammo_type = list(/obj/item/ammo_casing/energy/wormhole, /obj/item/ammo_casing/energy/wormhole/orange)
	item_state = null
	icon_state = "wormhole_projector"
	var/obj/effect/portal/p_blue
	var/obj/effect/portal/p_orange
	var/atmos_link = FALSE

/obj/item/gun/energy/wormhole_projector/update_icon()
	icon_state = "[initial(icon_state)][select]"
	item_state = icon_state

/obj/item/gun/energy/wormhole_projector/update_ammo_types()
	. = ..()
	for(var/i in 1 to ammo_type.len)
		var/obj/item/ammo_casing/energy/wormhole/W = ammo_type[i]
		if(istype(W))
			W.gun = WEAKREF(src)
			var/obj/item/projectile/beam/wormhole/WH = W.BB
			if(istype(WH))
				WH.gun = WEAKREF(src)

/obj/item/gun/energy/wormhole_projector/process_chamber()
	..()
	select_fire()

/obj/item/gun/energy/wormhole_projector/proc/on_portal_destroy(obj/effect/portal/P)
	if(P == p_blue)
		p_blue = null
	else if(P == p_orange)
		p_orange = null

/obj/item/gun/energy/wormhole_projector/proc/has_blue_portal()
	if(istype(p_blue) && !QDELETED(p_blue))
		return TRUE
	return FALSE

/obj/item/gun/energy/wormhole_projector/proc/has_orange_portal()
	if(istype(p_orange) && !QDELETED(p_orange))
		return TRUE
	return FALSE

/obj/item/gun/energy/wormhole_projector/proc/crosslink()
	if(!has_blue_portal() && !has_orange_portal())
		return
	if(!has_blue_portal() && has_orange_portal())
		p_orange.link_portal(null)
		return
	if(!has_orange_portal() && has_blue_portal())
		p_blue.link_portal(null)
		return
	p_orange.link_portal(p_blue)
	p_blue.link_portal(p_orange)

/obj/item/gun/energy/wormhole_projector/proc/create_portal(obj/item/projectile/beam/wormhole/W, turf/target)
	var/obj/effect/portal/P = new /obj/effect/portal(target, src, 300, null, FALSE, null, atmos_link)
	if(istype(W, /obj/item/projectile/beam/wormhole/orange))
		qdel(p_orange)
		p_orange = P
		P.icon_state = "portal1"
	else
		qdel(p_blue)
		p_blue = P
	crosslink()

/* 3d printer 'pseudo guns' for borgs */

/obj/item/gun/energy/printer
	name = "lekki karabin maszynowy cyborga"
	desc = "Lekki karabin maszynowy strzelający lotkami z drukarki 3D. Zapas powoli uzupełnia się z wewnętrznego źródła zasilania cyborga."
	icon_state = "l6_cyborg"
	icon = 'icons/obj/guns/projectile.dmi'
	cell_type = "/obj/item/stock_parts/cell/secborg"
	ammo_type = list(/obj/item/ammo_casing/energy/c3dbullet)
	can_charge = FALSE
	use_cyborg_cell = TRUE
	automatic = 1
	fire_rate = 6
	requires_wielding = FALSE

/obj/item/gun/energy/printer/update_icon()
	return

/obj/item/gun/energy/printer/emp_act()
	return

/obj/item/gun/energy/temperature
	name = "pistolet temperaturowy"
	icon_state = "freezegun"
	desc = "Broń zmieniająca temperaturę."
	ammo_type = list(/obj/item/ammo_casing/energy/temp, /obj/item/ammo_casing/energy/temp/hot)
	cell_type = "/obj/item/stock_parts/cell/high"
	automatic = 1
	fire_rate = 4
	pin = null

/obj/item/gun/energy/temperature/pin
	pin = /obj/item/firing_pin

/obj/item/gun/energy/temperature/security
	name = "policyjny pistolet temperaturowy"
	desc = "Broń, z której pełnego potencjału skorzystają tylko naprawdę krzepcy."
	pin = /obj/item/firing_pin
	w_class = WEIGHT_CLASS_BULKY

/obj/item/gun/energy/laser/instakill
	name = "karabin natychmiastowej śmierci"
	icon_state = "instagib"
	item_state = "instagib"
	desc = "Specjalistyczny karabin laserowy ASMD, który większość celów dezintegruje jednym trafieniem."
	ammo_type = list(/obj/item/ammo_casing/energy/instakill)
	force = 60

/obj/item/gun/energy/laser/instakill/red
	desc = "Specjalistyczny karabin laserowy ASMD, który większość celów dezintegruje jednym trafieniem. Ten egzemplarz ma czerwone malowanie."
	icon_state = "instagibred"
	item_state = "instagibred"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/red)

/obj/item/gun/energy/laser/instakill/blue
	desc = "Specjalistyczny karabin laserowy ASMD, który większość celów dezintegruje jednym trafieniem. Ten egzemplarz ma niebieskie malowanie."
	icon_state = "instagibblue"
	item_state = "instagibblue"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/blue)

/obj/item/gun/energy/laser/instakill/emp_act() //implying you could stop the instagib
	return

/obj/item/gun/energy/gravity_gun
	name = "jednopunktowy manipulator grawitacyjno-bluespace'owy"
	desc = "Eksperymentalne, wielotrybowe urządzenie strzelające pociskami energii punktu zerowego, które lokalnie zaburzają grawitację."
	ammo_type = list(/obj/item/ammo_casing/energy/gravity/repulse, /obj/item/ammo_casing/energy/gravity/attract, /obj/item/ammo_casing/energy/gravity/chaos)
	item_state = "gravity_gun"
	icon_state = "gravity_gun"
	var/power = 4
