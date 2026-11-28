// AQUILA - 10 broni wybranych z przeglądu 119 kodów (raport/bronie_pancerze_02_plan_wdrozenia.md).
// Sprite'y i dźwięki (CC-BY-SA-3.0): TeguStation (M19C4), VOREStation (karabin antycząstkowy, P90), Quasar-13 (XM29,
// X-41 jako wygląd disablera), Baystation12 (karabin bojowy), CEV-Eris (Atreides), Skyrat-tg (M44A),
// Space Station 14 (AKMS, XL8, magazynek AKMS). Statystyki są przeliczone na nasz balans, nie przepisane z oryginałów.

// ---------------------------------------------------------------- energetyczne

/// M19C4 z TeguStation: wojskowy karabin pulsacyjny, słabszy od karabinu pulsacyjnego Centrali
/obj/item/gun/energy/laser/m19c4
	name = "wojskowy karabin pulsacyjny M19C4"
	desc = "Karabin pulsacyjny z powiększonym bankiem energii, na wyposażeniu oddziałów szybkiego reagowania. Strzela pojedynczo, seriami i ogniem ciągłym."
	icon = 'aquila/icons/obj/guns/bronie_wybrane.dmi'
	icon_state = "m19c4"
	item_state = "m19c4"
	lefthand_file = 'aquila/icons/mob/inhands/weapons/bronie_wybrane_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/weapons/bronie_wybrane_righthand.dmi'
	worn_icon_state = "pulse"
	fire_sound = 'aquila/sound/weapons/bronie_wybrane/m19c4.ogg'
	ammo_type = list(/obj/item/ammo_casing/energy/laser/m19c4)
	gun_charge = 2400
	shaded_charge = TRUE
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	weapon_weight = WEAPON_HEAVY
	force = 15
	burst_size = 3
	fire_delay = 2
	full_auto = TRUE
	fire_rate = 4

/obj/item/ammo_casing/energy/laser/m19c4
	projectile_type = /obj/item/projectile/beam/laser/m19c4
	e_cost = 50
	fire_sound = 'aquila/sound/weapons/bronie_wybrane/m19c4.ogg'

/obj/item/projectile/beam/laser/m19c4
	name = "impuls pulsacyjny"
	icon_state = "bluelaser"
	damage = 22
	armour_penetration = 20
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE

/// Karabin antycząstkowy z VOREStation: górnicza broń do próżni, w atmosferze zawodzi
/obj/item/gun/energy/antyczastkowy
	name = "zaawansowany karabin antycząstkowy"
	desc = "Wytwarza drobiny antymaterii i miota je polem elektromagnetycznym. Samo się ładuje i urabia skałę. Działa niezawodnie tylko w próżni: w powietrzu pocisk zderza się z gazem, zanim doleci do celu."
	icon = 'aquila/icons/obj/guns/bronie_wybrane.dmi'
	icon_state = "antyczastkowy"
	item_state = "antyczastkowy"
	lefthand_file = 'aquila/icons/mob/inhands/weapons/bronie_wybrane_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/weapons/bronie_wybrane_righthand.dmi'
	fire_sound = 'sound/weapons/blaster.ogg'
	ammo_type = list(/obj/item/ammo_casing/energy/antyczastka)
	gun_charge = 1200
	shaded_charge = TRUE
	selfcharge = 1
	charge_delay = 3
	can_charge = FALSE
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BELT
	force = 8

/obj/item/ammo_casing/energy/antyczastka
	projectile_type = /obj/item/projectile/plasma/antyczastka
	e_cost = 100
	select_name = "antyczastka"
	fire_sound = 'sound/weapons/blaster.ogg'

/obj/item/projectile/plasma/antyczastka
	name = "drobina antymaterii"
	damage = 30
	damage_type = BURN
	flag = "energy"
	range = 12
	mine_range = 1
	dismemberment = 0

/// Próg ciśnienia (kPa), od którego karabin antycząstkowy może zawieść
#define AQ_ANTYCZASTKA_PROG_CISNIENIA 10

/obj/item/gun/energy/antyczastkowy/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Powyżej [AQ_ANTYCZASTKA_PROG_CISNIENIA] kPa każdy strzał może się nie udać: zacięcie, przepalony strzał, rozładowanie ogniwa, a przy pełnym ciśnieniu nawet wybuch.</span>"

/obj/item/gun/energy/antyczastkowy/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0, aimed = FALSE)
	var/turf/here = get_turf(src)
	var/datum/gas_mixture/air = here?.return_air()
	var/pressure = air ? air.return_pressure() : 0
	if(pressure >= AQ_ANTYCZASTKA_PROG_CISNIENIA && prob(min(pressure, 100)))
		if(aq_antyczastka_awaria(rand(1, max(1, round(pressure))), user))
			return FALSE
	return ..()

/// Awaria karabinu w atmosferze (wzór: pressuremalfunction() z VOREStation). Zwraca TRUE, gdy strzał nie poszedł.
/obj/item/gun/energy/antyczastkowy/proc/aq_antyczastka_awaria(severity, mob/living/user)
	var/turf/here = get_turf(src)
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(severity <= 10)
		if(user)
			to_chat(user, "<span class='warning'>[src] się zacina.</span>")
		playsound(src, 'sound/weapons/empty.ogg', 100, TRUE)
		return TRUE
	if(severity <= 60)
		if(user)
			user.visible_message("<span class='warning'>[user] strzela z [src], ale pocisk rozpada się w powietrzu!</span>", "<span class='warning'>Strzelasz, ale pocisk rozpada się w powietrzu!</span>")
		cell.use(shot.e_cost)
		playsound(src, fire_sound, 100, TRUE)
		do_sparks(2, TRUE, here)
		update_icon()
		return TRUE
	if(severity <= 90)
		if(user)
			user.visible_message("<span class='warning'>[src] w rękach [user] sypie iskrami i gaśnie!</span>", "<span class='warning'>[src] sypie iskrami i ogniwo pada!</span>")
		cell.use(cell.charge)
		do_sparks(3, TRUE, here)
		update_icon()
		return TRUE
	if(user)
		user.visible_message("<span class='danger'>[src] w rękach [user] wybucha!</span>", "<span class='danger'>[src] wybucha ci w rękach!</span>")
		log_combat(user, src, "wysadził się", src)
	if(severity <= 150)
		explosion(here, -1, -1, 1, 1)
	else
		explosion(here, -1, 1, 2, 2)
	qdel(src)
	return TRUE

#undef AQ_ANTYCZASTKA_PROG_CISNIENIA

/datum/design/aq_antyczastkowy
	name = "Zaawansowany karabin antycząstkowy"
	desc = "Górniczy karabin antymaterii: samo się ładuje i urabia skałę, ale niezawodnie działa tylko w próżni."
	id = "aq_antyczastkowy"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 1500, /datum/material/plasma = 3000, /datum/material/uranium = 1000, /datum/material/gold = 1000)
	build_path = /obj/item/gun/energy/antyczastkowy
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/techweb_node/adv_mining/New()
	. = ..()
	design_ids += "aq_antyczastkowy"

/// X-41 z Quasar-13 jako nowy wygląd disablera (stany: disabler, disabler_charge1-4, disabler_empty)
/obj/item/gun/energy/disabler
	icon = 'aquila/icons/obj/guns/bronie_wybrane.dmi'
	shaded_charge = TRUE

// ---------------------------------------------------------------- balistyczne

/// AKMS z SS14: zużyty karabin dla piratów i złomiarzy
/obj/item/gun/ballistic/automatic/akms
	name = "karabin AKMS"
	desc = "Mocno sfatygowany karabin szturmowy starej ziemskiej konstrukcji. Ceniony przez przestępców i milicje za niezawodność. Strzela nabojami 7,62×39 mm."
	icon = 'aquila/icons/obj/guns/bronie_wybrane.dmi'
	icon_state = "akms"
	item_state = "akms"
	lefthand_file = 'aquila/icons/mob/inhands/weapons/bronie_wybrane_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/weapons/bronie_wybrane_righthand.dmi'
	worn_icon = 'aquila/icons/mob/clothing/back_bronie_wybrane.dmi'
	fire_sound = 'aquila/sound/weapons/bronie_wybrane/akms.ogg'
	mag_type = /obj/item/ammo_box/magazine/akms
	mag_display = TRUE
	can_suppress = FALSE
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	weapon_weight = WEAPON_HEAVY
	burst_size = 1
	fire_delay = 1
	fire_rate = 5
	full_auto = TRUE
	spread = 8
	recoil = 0.5

/obj/item/ammo_box/magazine/akms
	name = "magazynek AKMS (7,62×39 mm)"
	icon = 'aquila/icons/obj/guns/bronie_wybrane.dmi'
	icon_state = "akms_magazynek"
	ammo_type = /obj/item/ammo_casing/akms
	caliber = "akms762"
	max_ammo = 30

/obj/item/ammo_casing/akms
	name = "łuska 7,62×39 mm"
	desc = "Łuska 7,62×39 mm."
	icon_state = "762-casing"
	caliber = "akms762"
	projectile_type = /obj/item/projectile/bullet/akms

/obj/item/projectile/bullet/akms
	name = "pocisk 7,62×39 mm"
	damage = 28

/// XL8 z SS14: drogi karabin Nanotrasen z lunetą, do kupienia w cargo. Bierze magazynki 5,56 jak Beryl.
/obj/item/gun/ballistic/automatic/xl8
	name = "karabin XL8"
	desc = "Eksperymentalny karabin szturmowy Nanotrasen z wbudowaną optyką. Strzela seriami po trzy, pojedynczo albo ogniem ciągłym. Bierze magazynki 5,56 mm."
	icon = 'aquila/icons/obj/guns/bronie_wybrane.dmi'
	icon_state = "xl8"
	item_state = "xl8"
	lefthand_file = 'aquila/icons/mob/inhands/weapons/bronie_wybrane_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/weapons/bronie_wybrane_righthand.dmi'
	worn_icon = 'aquila/icons/mob/clothing/back_bronie_wybrane.dmi'
	fire_sound = 'aquila/sound/weapons/bronie_wybrane/xl8.ogg'
	mag_type = /obj/item/ammo_box/magazine/m556
	mag_display = TRUE
	can_suppress = FALSE
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	weapon_weight = WEAPON_HEAVY
	burst_size = 3
	fire_delay = 2
	fire_rate = 4
	full_auto = TRUE
	zoomable = TRUE
	zoom_amt = 3
	recoil = 0.3

/// Karabin bojowy z Baya: ciężki 7,62 dla Syndykatu, celny tylko ogniem pojedynczym
/obj/item/gun/ballistic/automatic/karabin_bojowy
	name = "karabin bojowy"
	desc = "Ciężki karabin samopowtarzalny, prawie niezmieniony od połowy XX wieku. Niezawodny w najgorszych warunkach. Strzela nabojami 7,62 mm z 18-nabojowych magazynków."
	icon = 'aquila/icons/obj/guns/bronie_wybrane.dmi'
	icon_state = "battlerifle"
	item_state = "battlerifle"
	lefthand_file = 'aquila/icons/mob/inhands/weapons/bronie_wybrane_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/weapons/bronie_wybrane_righthand.dmi'
	worn_icon_state = "sniper-mag"
	fire_sound = 'aquila/sound/weapons/bronie_wybrane/karabin_bojowy.ogg'
	mag_type = /obj/item/ammo_box/magazine/karabin_bojowy
	mag_display = TRUE
	can_suppress = FALSE
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK
	weapon_weight = WEAPON_HEAVY
	burst_size = 1
	fire_delay = 4
	spread_unwielded = 30
	recoil = 1
	pin = /obj/item/firing_pin/implant/pindicate

/obj/item/gun/ballistic/automatic/karabin_bojowy/unrestricted
	pin = /obj/item/firing_pin

/obj/item/ammo_box/magazine/karabin_bojowy
	name = "magazynek karabinu bojowego (7,62 mm)"
	icon_state = "5.56m"
	ammo_type = /obj/item/ammo_casing/a762
	caliber = "a762"
	max_ammo = 18

/// P90K z CHOMP: PDW 9 mm z magazynkiem na 50 naboi ładowanym od góry
/obj/item/gun/ballistic/automatic/p90
	name = "PDW P90K"
	desc = "Unowocześniona wersja prastarego FN P90: zwarty pistolet maszynowy z ogromnym magazynkiem ładowanym od góry i znikomym odrzutem. Strzela nabojami 9 mm."
	icon = 'aquila/icons/obj/guns/bronie_wybrane.dmi'
	icon_state = "p90"
	item_state = "p90"
	lefthand_file = 'aquila/icons/mob/inhands/weapons/bronie_wybrane_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/weapons/bronie_wybrane_righthand.dmi'
	fire_sound = 'sound/weapons/gunshot_smg.ogg'
	mag_type = /obj/item/ammo_box/magazine/p90
	mag_display = TRUE
	can_suppress = TRUE
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	burst_size = 3
	fire_delay = 1
	spread_unwielded = 15
	pin = /obj/item/firing_pin/implant/pindicate

/obj/item/gun/ballistic/automatic/p90/unrestricted
	pin = /obj/item/firing_pin

/obj/item/ammo_box/magazine/p90
	name = "magazynek P90 (9 mm)"
	icon_state = "46x30mmt-20"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 50

/// Atreides z CEV-Eris: tani PM gangów zamiast Uzi
/obj/item/gun/ballistic/automatic/atreides
	name = "PM Atreides"
	desc = "Replika starego, popularnego pistoletu maszynowego. Tani i produkowany masowo: ani dobry, ani zły. Strzela nabojami 9 mm z 35-nabojowych magazynków."
	icon = 'aquila/icons/obj/guns/bronie_wybrane.dmi'
	icon_state = "atreides"
	item_state = "atreides"
	lefthand_file = 'aquila/icons/mob/inhands/weapons/bronie_wybrane_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/weapons/bronie_wybrane_righthand.dmi'
	fire_sound = 'aquila/sound/weapons/bronie_wybrane/atreides.ogg'
	mag_type = /obj/item/ammo_box/magazine/atreides
	mag_display = TRUE
	can_suppress = TRUE
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	burst_size = 1
	fire_rate = 5
	full_auto = TRUE
	spread = 5

/obj/item/ammo_box/magazine/atreides
	name = "magazynek Atreidesa (9 mm)"
	icon_state = "smg9mm-42"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 35

/// M44A ze Skyrata: karabin NT na bezłuskowe naboje .300, strzela tylko z implantem mindshield
/obj/item/gun/ballistic/automatic/m44a
	name = "karabin pulsacyjny NT M44A"
	desc = "Wyspecjalizowany karabin Nanotrasen z magazynkami ze sprężaniem bluespace na 99 bezłuskowych naboi .300. Mimo nazwy strzela kulami. Wystrzeli tylko w rękach osoby z implantem mindshield."
	icon = 'aquila/icons/obj/guns/bronie_wybrane.dmi'
	icon_state = "m44a"
	item_state = "m44a"
	lefthand_file = 'aquila/icons/mob/inhands/weapons/bronie_wybrane_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/weapons/bronie_wybrane_righthand.dmi'
	fire_sound = 'aquila/sound/weapons/bronie_wybrane/m44a.ogg'
	mag_type = /obj/item/ammo_box/magazine/m44a
	mag_display = TRUE
	can_suppress = FALSE
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BELT
	weapon_weight = WEAPON_HEAVY
	burst_size = 1
	fire_rate = 6
	full_auto = TRUE
	spread = 6
	pin = /obj/item/firing_pin/implant/mindshield

/obj/item/ammo_box/magazine/m44a
	name = "magazynek M44A (.300 sprężone)"
	desc = "Magazynek z komorą sprężania bluespace na 99 bezłuskowych naboi .300 do karabinu M44A."
	icon = 'aquila/icons/obj/guns/bronie_wybrane.dmi'
	icon_state = "m44a_magazynek"
	ammo_type = /obj/item/ammo_casing/caseless/c300
	caliber = "300comp"
	max_ammo = 99
	multiple_sprites = 2

/obj/item/ammo_casing/caseless/c300
	name = "bezłuskowy nabój .300"
	desc = "Bezłuskowy nabój .300 do broni Nanotrasen."
	caliber = "300comp"
	projectile_type = /obj/item/projectile/bullet/c300

/obj/item/projectile/bullet/c300
	name = "pocisk .300"
	damage = 13
	armour_penetration = 30

/// SG-XM29 z Quasar-13: M-90gl z serią i bębnem na 5 granatów
/obj/item/gun/ballistic/automatic/m90/xm29
	name = "SG-XM29 „Determinator”"
	desc = "Granatnik z przyczepionym karabinem 5,56. Nigdy nie wszedł oficjalnie na uzbrojenie, ale lubią go najemnicy. Podlufowy bęben mieści pięć granatów 40 mm, z których strzelasz prawym przyciskiem myszy."
	icon = 'aquila/icons/obj/guns/bronie_wybrane.dmi'
	icon_state = "xm29"
	empty_indicator = FALSE
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY
	fire_delay = 1
	zoomable = TRUE
	zoom_amt = 4

/obj/item/gun/ballistic/automatic/m90/xm29/Initialize(mapload)
	. = ..()
	QDEL_NULL(underbarrel)
	underbarrel = new /obj/item/gun/ballistic/revolver/grenadelauncher/xm29(src)
	update_icon()

/obj/item/gun/ballistic/automatic/m90/xm29/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/revolver/grenadelauncher/xm29
	mag_type = /obj/item/ammo_box/magazine/internal/grenadelauncher/xm29
	pin = /obj/item/firing_pin

/obj/item/ammo_box/magazine/internal/grenadelauncher/xm29
	name = "bęben granatnika XM29"
	max_ammo = 5
