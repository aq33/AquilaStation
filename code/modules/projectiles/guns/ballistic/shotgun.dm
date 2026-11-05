/obj/item/gun/ballistic/shotgun
	name = "strzelba"
	desc = "Tradycyjna strzelba z drewnianymi okładzinami i podlufowym magazynkiem na cztery naboje."
	icon_state = "shotgun"
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	item_state = "shotgun"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	fire_sound = "sound/weapons/shotgunshot.ogg"
	vary_fire_sound = FALSE
	fire_sound_volume = 90
	rack_sound = "sound/weapons/shotgunpump.ogg"
	load_sound = "sound/weapons/shotguninsert.ogg"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	flags_1 =  CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/shot
	weapon_weight = WEAPON_MEDIUM
	semi_auto = FALSE
	internal_magazine = TRUE
	casing_ejector = FALSE
	bolt_wording = "pump"
	bolt_type = BOLT_TYPE_PUMP
	cartridge_wording = "shell"
	tac_reloads = FALSE
	fire_rate = 1 //reee
	recoil = 1
	pb_knockback = 2

/obj/item/gun/ballistic/shotgun/blow_up(mob/user)
	. = 0
	if(chambered?.BB)
		process_fire(user, user, FALSE)
		. = 1

/obj/item/gun/ballistic/shotgun/lethal
	mag_type = /obj/item/ammo_box/magazine/internal/shot/lethal

// RIOT SHOTGUN //

/obj/item/gun/ballistic/shotgun/riot //for spawn in the armory
	name = "strzelba prewencyjna"
	desc = "Wytrzymała strzelba z dłuższym magazynkiem i stałą kolbą taktyczną, przeznaczona do nieśmiercionośnego tłumienia zamieszek."
	icon_state = "riotshotgun"
	item_state = "shotgun"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/riot
	sawn_desc = "Chodź ze mną, jeśli chcesz żyć."

/obj/item/gun/ballistic/shotgun/riot/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/circular_saw) || istype(A, /obj/item/gun/energy/plasmacutter))
		sawoff(user)
	if(istype(A, /obj/item/melee/transforming/energy))
		var/obj/item/melee/transforming/energy/W = A
		if(W.active)
			sawoff(user)

// Automatic Shotguns//

/obj/item/gun/ballistic/shotgun/automatic
	weapon_weight = WEAPON_HEAVY

/obj/item/gun/ballistic/shotgun/automatic/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
	..()
	rack()

/obj/item/gun/ballistic/shotgun/automatic/combat
	name = "strzelba bojowa"
	desc = "Półautomatyczna strzelba z taktycznymi okładzinami i podlufowym magazynkiem na sześć nabojów."
	icon_state = "cshotgun"
	item_state = "shotgun_combat"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/com
	w_class = WEIGHT_CLASS_HUGE

/obj/item/gun/ballistic/shotgun/automatic/combat/compact
	name = "kompaktowa strzelba bojowa"
	desc = "Kompaktowa wersja półautomatycznej strzelby bojowej. Do bliskich spotkań."
	icon_state = "cshotgunc"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/com/compact
	weapon_weight = WEAPON_MEDIUM
	w_class = WEIGHT_CLASS_BULKY

/obj/item/gun/ballistic/shotgun/automatic/combat/compact/shoot_live_shot(mob/living/user, pointblank, atom/pbtarget, message)
	if(!is_wielded)
		recoil = 6
	else
		recoil = initial(recoil)
	. = ..()

// Breaching Shotgun //

/obj/item/gun/ballistic/shotgun/automatic/breaching
	name = "taktyczna strzelba wyważająca"
	desc = "Kompaktowa strzelba półautomatyczna do strzelania brenekami wyważającymi i szybkiego robienia wejść."
	icon_state = "breachingshotgun"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/breaching
	w_class = WEIGHT_CLASS_NORMAL //compact so it fits in backpacks

//Dual Feed Shotgun

/obj/item/gun/ballistic/shotgun/automatic/dual_tube
	name = "strzelba dwumagazynkowa"
	desc = "Zaawansowana strzelba z dwoma osobnymi magazynkami rurowymi, które pozwalają szybko przełączać rodzaj amunicji."
	icon_state = "cycler"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/tube
	w_class = WEIGHT_CLASS_HUGE
	var/toggled = FALSE
	var/obj/item/ammo_box/magazine/internal/shot/alternate_magazine
	semi_auto = TRUE

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-klik, by przeładować.</span>"

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/Initialize(mapload)
	. = ..()
	if (!alternate_magazine)
		alternate_magazine = new mag_type(src)

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/attack_self(mob/living/user)
	if(!chambered && magazine.contents.len)
		rack()
	else
		toggle_tube(user)

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/proc/toggle_tube(mob/living/user)
	var/current_mag = magazine
	var/alt_mag = alternate_magazine
	magazine = alt_mag
	alternate_magazine = current_mag
	toggled = !toggled
	if(toggled)
		to_chat(user, "Przełączasz na magazynek B.")
	else
		to_chat(user, "Przełączasz na magazynek A.")

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	rack()

// Bulldog shotgun //

/obj/item/gun/ballistic/shotgun/bulldog
	name = "\improper strzelba Bulldog"
	desc = "Półautomatyczna strzelba zasilana z magazynka, do walki w ciasnych korytarzach, z wbudowanym tłumieniem odrzutu. Oddziały abordażowe nazywają ją „Bulldogiem”. Przyjmuje tylko specjalne 8-nabojowe magazynki bębnowe."
	icon_state = "bulldog"
	item_state = "bulldog"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_MEDIUM
	mag_type = /obj/item/ammo_box/magazine/m12g
	can_suppress = FALSE
	burst_size = 1
	fire_delay = 0
	pin = /obj/item/firing_pin/implant/pindicate
	spread_unwielded = 15
	actions_types = list()
	mag_display = TRUE
	empty_indicator = TRUE
	empty_alarm = TRUE
	special_mags = TRUE
	semi_auto = TRUE
	internal_magazine = FALSE
	tac_reloads = TRUE
	fire_rate = 2
	automatic = 1
	recoil = 0
	bolt_type = BOLT_TYPE_STANDARD	//Not using a pump
	full_auto = TRUE

/obj/item/gun/ballistic/shotgun/bulldog/unrestricted
	pin = /obj/item/firing_pin
/////////////////////////////
// DOUBLE BARRELED SHOTGUN //
/////////////////////////////

/obj/item/gun/ballistic/shotgun/doublebarrel
	name = "dwururka"
	desc = "Prawdziwy klasyk."
	icon_state = "dshotgun"
	item_state = "shotgun_db"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	force = 10
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/shot/dual
	sawn_desc = "Omar idzie!"
	obj_flags = UNIQUE_RENAME
	rack_sound_volume = 0
	unique_reskin = list("Domyślny" = "dshotgun",
						"Ciemnoczerwone wykończenie" = "dshotgun_d",
						"Jesion" = "dshotgun_f",
						"Spłowiała szarość" = "dshotgun_g",
						"Klon" = "dshotgun_l",
						"Palisander" = "dshotgun_p"
						)
	semi_auto = TRUE
	bolt_type = BOLT_TYPE_NO_BOLT
	fire_rate = 2 //being double barrelled, you don't rely on internal mechanisms.
	pb_knockback = 3

/obj/item/gun/ballistic/shotgun/doublebarrel/AltClick(mob/user)
	. = ..()
	if(unique_reskin && !current_skin && user.canUseTopic(src, BE_CLOSE, NO_DEXTERY))
		reskin_obj(user)

/obj/item/gun/ballistic/shotgun/doublebarrel/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/melee/transforming/energy))
		var/obj/item/melee/transforming/energy/W = A
		if(W.active)
			sawoff(user)
	if(istype(A, /obj/item/circular_saw) || istype(A, /obj/item/gun/energy/plasmacutter))
		sawoff(user)

// IMPROVISED SHOTGUN //

/obj/item/gun/ballistic/shotgun/doublebarrel/improvised
	name = "improwizowana strzelba"
	desc = "W zasadzie rura, która celuje nabojami do strzelby."
	icon_state = "ishotgun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	slot_flags = null
	mag_type = /obj/item/ammo_box/magazine/internal/shot/improvised
	sawn_desc = "Jestem tu tylko po benzynę."
	unique_reskin = null
	recoil = 2
	var/slung = FALSE

/obj/item/gun/ballistic/shotgun/doublebarrel/improvised/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/stack/cable_coil) && !sawn_off)
		var/obj/item/stack/cable_coil/C = A
		if(C.use(10))
			slot_flags = ITEM_SLOT_BACK
			to_chat(user, "<span class='notice'>Przywiązujesz do strzelby odcinki kabla, robiąc z nich pas.</span>")
			slung = TRUE
			update_icon()
		else
			to_chat(user, "<span class='warning'>Potrzebujesz co najmniej dziesięciu odcinków kabla, by zrobić pas!</span>")

/obj/item/gun/ballistic/shotgun/doublebarrel/improvised/update_icon()
	..()
	if(slung)
		add_overlay("improvised_sling")

/obj/item/gun/ballistic/shotgun/doublebarrel/improvised/sawoff(mob/user)
	. = ..()
	if(. && slung) //sawing off the gun removes the sling
		new /obj/item/stack/cable_coil(get_turf(src), 10)
		slung = 0
		update_icon()

/obj/item/gun/ballistic/shotgun/doublebarrel/improvised/sawn
	name = "improwizowany obrzyn"
	desc = "Jednostrzałowa strzelba. Lepiej nie pudłuj."
	icon_state = "ishotgun"
	item_state = "gun"
	w_class = WEIGHT_CLASS_NORMAL
	sawn_off = TRUE
	slot_flags = ITEM_SLOT_BELT
	recoil = SAWN_OFF_RECOIL

/obj/item/gun/ballistic/shotgun/doublebarrel/hook
	name = "obrzyn przerobiony na hak"
	desc = "Zasięg to żaden problem, gdy możesz przyciągnąć ofiarę do siebie."
	icon_state = "hookshotgun"
	item_state = "shotgun"
	load_sound = "sound/weapons/shotguninsert.ogg"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/bounty
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	force = 10 //it has a hook on it
	attack_verb = list("ciacha", "zahacza", "dźga")
	hitsound = 'sound/weapons/bladeslice.ogg'
	//our hook gun!
	var/obj/item/gun/magic/hook/bounty/hook

/obj/item/gun/ballistic/shotgun/doublebarrel/hook/Initialize(mapload)
	. = ..()
	hook = new /obj/item/gun/magic/hook/bounty(src)

/obj/item/gun/ballistic/shotgun/doublebarrel/hook/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Prawym przyciskiem myszy wystrzelisz hak.</span>"

/obj/item/gun/ballistic/shotgun/doublebarrel/hook/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	hook.afterattack(target, user, proximity_flag, click_parameters)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

