// Port tgstation/tgstation#94172 - "Gun Muzzle Flash (2)".
// Krótki, kierunkowy błysk światła z lufy przy każdym strzale z broni ręcznej.
// Kolor bierze się z broni (light_color), a w broniach energetycznych z wybranego trybu (muzzle_flash_color łuski).
// Bez błysku: tłumiki, zabawki, e-bow (suppressed), magia, strzykawki, granatniki, rakiety, medbeam, chem gun, łuki.

#ifndef LIGHT_COLOR_DIM_YELLOW
#define LIGHT_COLOR_DIM_YELLOW "#E1E17D"
#endif
#ifndef COLOR_SOFT_RED
#define COLOR_SOFT_RED "#FA8282"
#endif
#ifndef COLOR_STRONG_BLUE
#define COLOR_STRONG_BLUE "#1919c8"
#endif
#ifndef COLOR_AMMO_HELLFIRE
#define COLOR_AMMO_HELLFIRE "#f60021"
#endif

/obj/item/gun
	light_on = FALSE
	light_system = MOVABLE_LIGHT_DIRECTIONAL
	light_range = 3
	light_color = LIGHT_COLOR_ORANGE
	light_power = 0.5
	/// Czy ta broń w ogóle błyska przy strzale
	var/can_muzzle_flash = TRUE
	/// Jak długo trwa błysk
	var/muzzle_flash_time = 0.1 SECONDS

/obj/item/gun/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
	. = ..()
	muzzle_flash_on()

/obj/item/gun/proc/muzzle_flash_on()
	// U nas tłumik to zmienna suppressed (też e-bow ma suppressed = TRUE), więc zamiast przestawiać can_muzzle_flash przy montażu tłumika sprawdzamy ją tutaj
	if(!can_muzzle_flash || suppressed)
		muzzle_flash_off()
		return
	set_light_on(TRUE)
	addtimer(CALLBACK(src, PROC_REF(muzzle_flash_off)), muzzle_flash_time, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/item/gun/proc/muzzle_flash_off()
	set_light_on(FALSE)

// Kolory błysku z łusek
/obj/item/ammo_casing
	/// Kolor błysku z lufy dla tej amunicji (w broniach energetycznych ustawiany przy zmianie trybu)
	var/muzzle_flash_color = LIGHT_COLOR_ORANGE

/obj/item/ammo_casing/energy
	muzzle_flash_color = LIGHT_COLOR_CYAN

/obj/item/ammo_casing/energy/laser
	muzzle_flash_color = COLOR_SOFT_RED

/obj/item/ammo_casing/energy/lasergun
	muzzle_flash_color = COLOR_SOFT_RED

/obj/item/ammo_casing/energy/laser/pulse
	muzzle_flash_color = LIGHT_COLOR_BLUE

/obj/item/ammo_casing/energy/ion
	muzzle_flash_color = LIGHT_COLOR_BLUE

/obj/item/ammo_casing/energy/electrode
	muzzle_flash_color = LIGHT_COLOR_DIM_YELLOW

/obj/item/ammo_casing/energy/disabler
	muzzle_flash_color = LIGHT_COLOR_CYAN

/obj/item/ammo_casing/energy/instakill
	muzzle_flash_color = LIGHT_COLOR_BLUE

/obj/item/ammo_casing/energy/xray
	muzzle_flash_color = LIGHT_COLOR_GREEN

/obj/item/gun/energy/select_fire(mob/living/user)
	. = ..()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(istype(shot) && shot.muzzle_flash_color)
		set_light_color(shot.muzzle_flash_color)

/obj/item/gun/energy/update_ammo_types()
	. = ..()
	// AQ: broń energetyczna bez własnego koloru bierze go z domyślnego trybu (w tg zostawała pomarańczowa do pierwszej zmiany trybu)
	if(light_color != LIGHT_COLOR_ORANGE)
		return
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(istype(shot) && shot.muzzle_flash_color)
		set_light_color(shot.muzzle_flash_color)

// Kolory poszczególnych broni energetycznych
/obj/item/gun/energy/e_gun
	light_color = LIGHT_COLOR_CYAN

/obj/item/gun/energy/laser
	light_color = COLOR_SOFT_RED

/obj/item/gun/energy/laser/captain
	light_color = COLOR_AMMO_HELLFIRE

/obj/item/gun/energy/xray
	light_color = LIGHT_COLOR_GREEN

/obj/item/gun/energy/pulse
	light_color = COLOR_BLUE

/obj/item/gun/energy/ionrifle
	light_color = LIGHT_COLOR_BLUE

/obj/item/gun/energy/taser
	light_color = LIGHT_COLOR_DIM_YELLOW

/obj/item/gun/energy/beam_rifle
	light_color = COLOR_STRONG_BLUE

/obj/item/gun/energy/laser/instakill
	light_color = LIGHT_COLOR_BLUE

// Bronie bez błysku
/obj/item/gun/magic
	can_muzzle_flash = FALSE

/obj/item/gun/chem
	can_muzzle_flash = FALSE

/obj/item/gun/grenadelauncher
	can_muzzle_flash = FALSE

/obj/item/gun/medbeam
	can_muzzle_flash = FALSE

/obj/item/gun/syringe
	can_muzzle_flash = FALSE

/obj/item/gun/ballistic/revolver/grenadelauncher
	can_muzzle_flash = FALSE

/obj/item/gun/ballistic/rocketlauncher
	can_muzzle_flash = FALSE

/obj/item/gun/ballistic/automatic/toy
	can_muzzle_flash = FALSE

/obj/item/gun/ballistic/shotgun/toy
	can_muzzle_flash = FALSE

/obj/item/gun/ballistic/automatic/c20r/toy
	can_muzzle_flash = FALSE

/obj/item/gun/ballistic/automatic/l6_saw/toy
	can_muzzle_flash = FALSE

// AQ: łuki (też shadow caster darkspawna) nie mają czym błysnąć
/obj/item/gun/ballistic/bow
	can_muzzle_flash = FALSE
