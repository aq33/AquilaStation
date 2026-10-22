/**
*MICROFUSION GUN UPGRADE ATTACHMENTS
*For adding unique abilities to microfusion guns, these can directly interact with the gun!
*/

/obj/item/microfusion_gun_attachment
	name = "microfusion gun attachment"
	desc = "Jeśli to widzisz, krzycz na kodera."
	icon = 'aquila/icons/microfusion/microfusion_gun_attachments.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	/// The attachment overlay icon state.
	var/attachment_overlay_icon_state
	/// Any incompatible upgrade types.
	var/list/incompatible_attachments = list()
	/// The added heat produced by having this module installed.
	var/heat_addition = 0
	/// The slot this attachment is installed in.
	var/slot = GUN_SLOT_UNIQUE
	/// How much extra power do we use?
	var/power_usage = 0
	/// Spread adjustment. Moved up to the base attachment type because of barrel mods and grips being in separate slots.
	var/spread_adjust
	/// Recoil adjustment. Also moved up to base attachment because of barrel mods and grips being in separate slots.
	var/recoil_adjust

/obj/item/microfusion_gun_attachment/examine(mob/user)
	. = ..()
	. += "Pasuje do slotu: <b>[slot]</b>."

/obj/item/microfusion_gun_attachment/proc/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	SHOULD_CALL_PARENT(TRUE)
	microfusion_gun.heat_per_shot += heat_addition
	microfusion_gun.update_appearance()
	microfusion_gun.extra_power_usage += power_usage
	if(spread_adjust)
		microfusion_gun.attachment_spread += spread_adjust
		microfusion_gun.recalculate_spread()
	if(recoil_adjust)
		microfusion_gun.attachment_recoil += recoil_adjust
		microfusion_gun.recalculate_recoil()
	return

/obj/item/microfusion_gun_attachment/proc/process_attachment(obj/item/gun/microfusion/microfusion_gun, delta_time)
	return

//Firing the gun right before we let go of it, tis is called.
/obj/item/microfusion_gun_attachment/proc/process_fire(obj/item/gun/microfusion/microfusion_gun, obj/item/ammo_casing/chambered)
	return

/obj/item/microfusion_gun_attachment/proc/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	SHOULD_CALL_PARENT(TRUE)
	microfusion_gun.heat_per_shot -= heat_addition
	microfusion_gun.update_appearance()
	microfusion_gun.extra_power_usage -= power_usage
	if(spread_adjust)
		microfusion_gun.attachment_spread -= spread_adjust
		microfusion_gun.recalculate_spread()
	if(recoil_adjust)
		microfusion_gun.attachment_recoil -= recoil_adjust
		microfusion_gun.recalculate_recoil()
	return

/*
Returns a list of modifications of this attachment, it must return a list within a list list(list()).
All of the following must be returned.
list(list("title" = "Toggle [toggle ? "OFF" : "ON"]", "icon" = "power-off", "color" = "blue" "reference" = "toggle_on_off"))
title - The title of the modification button
icon - The icon of the modification button
color - The color of the modification button
reference - The reference of the modification button, this is used to call the proc when the run modify data proc is called.
*/
/obj/item/microfusion_gun_attachment/proc/get_modify_data()
	return

/obj/item/microfusion_gun_attachment/proc/run_modify_data(params, mob/living/user, obj/item/gun/microfusion/microfusion_gun)
	return

/obj/item/microfusion_gun_attachment/proc/get_information_data()
	return

// base type for the barrel mods because i got Really Tired of re-re-redefined variables
/obj/item/microfusion_gun_attachment/barrel
	slot = GUN_SLOT_BARREL
	/// If this isn't null, the lens fires this projectile type while the attachment is installed.
	var/projectile_override
	/// If this isn't null, on attachment, this becomes the new fire sound.
	var/new_fire_sound
	/// If this isn't null or zero, adds this fire delay to the gun.
	var/delay_to_add
	/// If this isn't null or zero, adds this burst to the gun's burst size.
	var/burst_to_add

// Monkestation replaced the loaded projectile on every shot. Our pellet_cloud makes the extra pellets
// from the casing's projectile_type, so the lens itself fires the override while the barrel is installed.
/obj/item/microfusion_gun_attachment/barrel/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	if(projectile_override)
		microfusion_gun.microfusion_lens.projectile_type = projectile_override
		microfusion_gun.refresh_shot()
	if(new_fire_sound)
		microfusion_gun.fire_sound = new_fire_sound
	if(delay_to_add)
		microfusion_gun.fire_delay += delay_to_add
	if(burst_to_add)
		microfusion_gun.burst_size += burst_to_add

/obj/item/microfusion_gun_attachment/barrel/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	if(projectile_override)
		var/obj/item/ammo_casing/energy/laser/microfusion/lens = microfusion_gun.microfusion_lens
		lens.projectile_type = initial(lens.projectile_type)
		microfusion_gun.refresh_shot()
	if(new_fire_sound)
		microfusion_gun.fire_sound = microfusion_gun.microfusion_lens.fire_sound
	if(delay_to_add)
		microfusion_gun.fire_delay -= delay_to_add
	if(burst_to_add)
		microfusion_gun.burst_size -= burst_to_add

/*
SCATTER ATTACHMENT

Turns the gun into a shotgun.
*/
/obj/item/microfusion_gun_attachment/barrel/scatter
	name = "rozpraszająca soczewka microfusion"
	desc = "Układ soczewek rozpraszających, który dzieli jedną wiązkę na trzy."
	icon_state = "attachment_scatter"
	attachment_overlay_icon_state = "attachment_scatter"
	projectile_override = /obj/item/projectile/beam/laser/microfusion/scatter
	/// How many pellets are we going to add to the existing amount on the gun?
	var/pellets_to_add = 2
	/// The variation in pellet scatter.
	var/variance_to_add = 20

/obj/item/microfusion_gun_attachment/barrel/scatter/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.microfusion_lens.pellets += pellets_to_add
	microfusion_gun.microfusion_lens.variance += variance_to_add

/obj/item/microfusion_gun_attachment/barrel/scatter/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.microfusion_lens.pellets -= pellets_to_add
	microfusion_gun.microfusion_lens.variance -= variance_to_add

/*
CRYSTALLINE SCATTER ATTACHMENT

An overclocked shotgun.
*/

/obj/item/microfusion_gun_attachment/barrel/scatter/max
	name = "krystaliczna rozpraszająca soczewka microfusion"
	desc = "Eksperymentalny układ soczewek rozpraszających, który dzieli jedną wiązkę na siedem. Za to daje odrzut i pobiera więcej energii."
	icon_state = "attachment_scattermax"
	attachment_overlay_icon_state = "attachment_scattermax"
	pellets_to_add = 6
	variance_to_add = 25
	recoil_adjust = 1
	spread_adjust = 15
	projectile_override = /obj/item/projectile/beam/laser/microfusion/scatter/max
	power_usage = 20

/*
SUPERHEAT ATTACHMENT

Lasers set the target on fire.
*/

/obj/item/microfusion_gun_attachment/barrel/superheat
	name = "przegrzewacz emitera fazowego"
	desc = "Dodatek na lufę podpięty do emitera fazowego. Zmienia długość fali wiązki tak, że niesie potężną falę ciepła i podpala cele."
	icon_state = "attachment_superheat"
	attachment_overlay_icon_state = "attachment_superheat"
	heat_addition = 90
	projectile_override = /obj/item/projectile/beam/laser/microfusion/superheated
	new_fire_sound = 'aquila/sound/microfusion/vaporize.ogg'

/*
HELLFIRE ATTACHMENT

Makes the gun shoot hellfire lasers.
*/
/obj/item/microfusion_gun_attachment/barrel/hellfire
	name = "piekielny emiter"
	desc = "Dodatek na lufę podpięty do emitera fazowego. Zmienia długość fali wiązki tak, że niesie dodatkową falę ciepła: wiązki lecą szybciej i zadają paskudniejsze rany."
	icon_state = "attachment_hellfire"
	attachment_overlay_icon_state = "attachment_hellfire"
	heat_addition = 50
	power_usage = 20
	projectile_override = /obj/item/projectile/beam/laser/microfusion/hellfire
	new_fire_sound = 'aquila/sound/microfusion/melt.ogg'

/*
REPEATER ATTACHMENT

The gun can fire volleys of shots.
*/
/obj/item/microfusion_gun_attachment/barrel/repeater
	name = "powtarzacz emitera fazowego"
	desc = "Dodatek na lufę, po którym emiter fazowy wystrzeliwuje dwie wiązki szybko jedna po drugiej. Szybkostrzelność rośnie, ale ciepło i odrzut też."
	icon_state = "attachment_repeater"
	attachment_overlay_icon_state = "attachment_repeater"
	heat_addition = 40
	spread_adjust = 15
	recoil_adjust = 1
	burst_to_add = 1
	delay_to_add = 5
	projectile_override = /obj/item/projectile/beam/laser/microfusion/repeater

/*
FOCUSED REPEATER ATTACHMENT

The gun can fire volleys of shots that penetrate armor.
*/

/obj/item/microfusion_gun_attachment/barrel/repeater/penetrator
	name = "skupiony powtarzacz emitera fazowego"
	desc = "Skupiona wersja powtarzacza. Wiązki przebijają pancerz, ale broń pobiera dużo więcej energii."
	icon_state = "attachment_penetrator"
	attachment_overlay_icon_state = "attachment_penetrator"
	projectile_override = /obj/item/projectile/beam/laser/microfusion/penetrator
	power_usage = 80 // A price to pay to penetrate through armor

/*
X-RAY ATTACHMENT

The gun can fire X-RAY shots.
*/
/obj/item/microfusion_gun_attachment/barrel/xray
	name = "kwantowy odwracacz fazy" //Yes quantum makes things sound cooler.
	desc = "Eksperymentalny dodatek na lufę, który przestawia częstotliwość emitera fazowego na promieniowanie rentgenowskie. \
	Wiązki bez trudu przechodzą przez szkło i lite ściany, ale w przeciwieństwie do zwykłego lasera rentgenowskiego nie radzą sobie lepiej z pancerzem, \
	bo przelatują przez cel i robią mniej szkód w środku. Dodatek jest prądożerny i szybko się grzeje, ale inżynierowie uznali to za koszt, który warto ponieść."
	icon_state = "attachment_xray"
	attachment_overlay_icon_state = "attachment_xray"
	heat_addition = 90
	power_usage = 50
	new_fire_sound = 'aquila/sound/microfusion/incinerate.ogg'
	projectile_override = /obj/item/projectile/beam/laser/microfusion/xray

/obj/item/microfusion_gun_attachment/barrel/xray/examine(mob/user)
	. = ..()
	. += "<span class='warning'>UWAGA: emiter fazowy grzeje się bardzo szybko, ciągły ogień niezalecany!</span>"

/*
SUPPRESSOR ATTACHMENT

Makes operators operate operatingly.
*/

/obj/item/microfusion_gun_attachment/barrel/suppressor
	name = "tłumik laserowy" // sure it makes no sense but its cool
	desc = "Eksperymentalny dodatek na lufę, który tłumi falę dźwiękową emitera, więc strzały są dużo cichsze. Najlepiej z czarnym malowaniem."
	icon_state = "attachment_suppressor"
	attachment_overlay_icon_state = "attachment_suppressor"

/obj/item/microfusion_gun_attachment/barrel/suppressor/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.suppressed = TRUE

/obj/item/microfusion_gun_attachment/barrel/suppressor/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.suppressed = null

/*
BIKEHORN ATTACHMENT

HONK!! Does subpar stamina damage but slips people.
*/

/obj/item/microfusion_gun_attachment/barrel/honk
	name = "bananiowy emiter fazowy"
	desc = "Honksperymentalny dodatek na lufę, po którym twoje lasery są zabawniejsze."
	icon_state = "attachment_honk"
	attachment_overlay_icon_state = "attachment_honk"
	delay_to_add = 2 SECONDS
	new_fire_sound = 'sound/items/bikehorn.ogg'
	projectile_override = /obj/item/projectile/beam/laser/microfusion/honk

/obj/item/microfusion_gun_attachment/barrel/honk/examine(mob/user)
	. = ..()
	. += "<span class='warning'>UWAGA: broń, którą trzymasz, jest skrajnie zabawna!</span>"

/*
LANCE ATTACHMENT

The gun fires fast heavy lasers but takes a long time to fire.
*/
/obj/item/microfusion_gun_attachment/barrel/lance
	name = "indukcyjna karetka lancy"
	desc = "Zestaw, który robi z MCR karabin wyborowy. Wiązki są silniejsze i szybsze, ale zwiększony przepływ mocno drenuje ogniwo i generuje ogromne ilości ciepła. \
	Każdy strzał musi trafić."
	icon = 'icons/obj/storage.dmi'
	icon_state = "sec-case"
	incompatible_attachments = list(/obj/item/microfusion_gun_attachment/camo, /obj/item/microfusion_gun_attachment/camo/nanotrasen, /obj/item/microfusion_gun_attachment/camo/honk)
	attachment_overlay_icon_state = "attachment_lance"
	heat_addition = 150
	power_usage = 100
	delay_to_add = 2.5 SECONDS
	new_fire_sound = 'sound/weapons/lasercannonfire.ogg'
	projectile_override = /obj/item/projectile/beam/laser/microfusion/lance

/obj/item/microfusion_gun_attachment/barrel/lance/examine(mob/user)
	. = ..()
	. += "<span class='warning'>UWAGA: emiter fazowy grzeje się bardzo szybko!</span>"

/*
PULSE ATTACHMENT

The gun can fire PULSE shots.
*/
/obj/item/microfusion_gun_attachment/barrel/pulse
	name = "indukcyjna karetka pulsacyjna"
	desc = "Najnowocześniejsza macierz kondensatorów bluespace i przebudowane soczewki z laboratoriów Nanotrasen, dzięki którym karabiny microfusion strzelają wojskowymi pociskami pulsacyjnymi. Ma cykliczne chłodzenie, licznik amunicji i wzmocnioną klatkę na ogniwo. Może skrócić żywotność spustu."
	icon_state = "attachment_pulse"
	attachment_overlay_icon_state = "attachment_pulse"
	heat_addition = 150
	power_usage = 50
	projectile_override = /obj/item/projectile/beam/pulse
	burst_to_add = 2
	delay_to_add = 2

/obj/item/microfusion_gun_attachment/barrel/pulse/examine(mob/user)
	. = ..()
	. += "<span class='warning'>UWAGA: emiter fazowy grzeje się bardzo szybko, ciągły ogień niezalecany!</span>"

/*
GRIP ATTACHMENT

Greatly reduces recoil and spread.
*/
/obj/item/microfusion_gun_attachment/grip
	name = "chwyt"
	desc = "Prosty chwyt, który poprawia celność."
	icon_state = "attachment_grip"
	attachment_overlay_icon_state = "attachment_grip"
	slot = GUN_SLOT_UNDERBARREL
	spread_adjust = -10
	recoil_adjust = -1

/*
HEATSINK ATTACHMENT

"Greatly increases the phase emitter cooling rate."
*/
/obj/item/microfusion_gun_attachment/heatsink
	name = "radiator emitera fazowego"
	desc = "Znacznie przyspiesza chłodzenie emitera fazowego."
	icon_state = "attachment_heatsink"
	attachment_overlay_icon_state = "attachment_heatsink"
	slot = GUN_SLOT_UNDERBARREL
	/// Cooling bonus.
	var/cooling_rate_increase = 50

/obj/item/microfusion_gun_attachment/heatsink/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.heat_dissipation_bonus += cooling_rate_increase

/obj/item/microfusion_gun_attachment/heatsink/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.heat_dissipation_bonus -= cooling_rate_increase

/*
RGB ATTACHMENT

Enables you to change the light color of the laser.
*/
/obj/item/microfusion_gun_attachment/rgb
	name = "spektrograf emitera fazowego"
	desc = "Dodatek podpięty do emitera fazowego, którym ustawisz kolor wiązki. Popularny we wszystkich frakcjach, które dorwały się do broni microfusion, czy to jako znak rozpoznawczy, czy dla zabawy."
	icon_state = "attachment_rgb"
	attachment_overlay_icon_state = "attachment_rgb"
	/// What color are we changing the sprite to?
	var/color_to_apply = COLOR_RED

/obj/item/microfusion_gun_attachment/rgb/process_fire(obj/item/gun/microfusion/microfusion_gun, obj/item/ammo_casing/chambered)
	. = ..()
	var/obj/item/projectile/loaded_projectile = chambered?.BB
	if(!loaded_projectile)
		return
	loaded_projectile.icon_state = "laser_greyscale"
	loaded_projectile.color = color_to_apply
	loaded_projectile.set_light_color(color_to_apply)

/obj/item/microfusion_gun_attachment/rgb/proc/select_color(mob/living/user)
	var/new_color = tgui_color_picker(user, "Wybierz nowy kolor wiązki", "Kolor lasera", color_to_apply)
	if(!new_color)
		return
	color_to_apply = new_color

/obj/item/microfusion_gun_attachment/rgb/attack_self(mob/user, modifiers)
	. = ..()
	select_color(user)

/obj/item/microfusion_gun_attachment/rgb/get_modify_data()
	return list(list("title" = "Zmień kolor", "icon" = "wrench", "reference" = "color", "color" = "blue"))

/obj/item/microfusion_gun_attachment/rgb/run_modify_data(params, mob/living/user)
	if(params == "color")
		select_color(user)

/*
RAIL ATTACHMENT

Allows for flashlights bayonets and adds 1 slot to equipment.
*/
/obj/item/microfusion_gun_attachment/rail
	name = "szyna montażowa"
	desc = "Prosty zestaw szyn na punkty montażowe broni. Pozwala zamontować latarkę albo bagnet."
	icon_state = "attachment_rail"
	attachment_overlay_icon_state = "attachment_rail"
	slot = GUN_SLOT_RAIL

/obj/item/microfusion_gun_attachment/rail/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.can_flashlight = TRUE
	microfusion_gun.can_bayonet = TRUE

/obj/item/microfusion_gun_attachment/rail/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	microfusion_gun.can_flashlight = FALSE
	microfusion_gun.can_bayonet = FALSE
	microfusion_gun.clear_gunlight() // drops the light on the floor
	var/obj/item/old_bayonet = microfusion_gun.bayonet
	if(microfusion_gun.clear_bayonet())
		old_bayonet.forceMove(get_turf(microfusion_gun))
	microfusion_gun.remove_all_attachments()

/*
SCOPE ATTACHMENT

Allows for a scope to be attached to the gun.
*/

/obj/item/microfusion_gun_attachment/scope
	name = "luneta"
	desc = "Prosta luneta teleskopowa do strzelania na duże odległości. Nie daje widzenia w ciemności."
	icon_state = "attachment_scope"
	attachment_overlay_icon_state = "attachment_scope"
	slot = GUN_SLOT_RAIL

/obj/item/microfusion_gun_attachment/scope/run_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	if(microfusion_gun.zoomable)
		return
	microfusion_gun.zoomable = TRUE
	microfusion_gun.zoom_amt = 7
	microfusion_gun.build_zooming()
	if(ismob(microfusion_gun.loc))
		microfusion_gun.azoom.Grant(microfusion_gun.loc)

/obj/item/microfusion_gun_attachment/scope/remove_attachment(obj/item/gun/microfusion/microfusion_gun)
	. = ..()
	if(!microfusion_gun.azoom)
		return
	if(ismob(microfusion_gun.loc))
		microfusion_gun.azoom.Remove(microfusion_gun.loc)
	QDEL_NULL(microfusion_gun.azoom)
	microfusion_gun.zoomable = initial(microfusion_gun.zoomable)
	microfusion_gun.zoom_amt = initial(microfusion_gun.zoom_amt)

/*
BLACK CAMO ATTACHMENT

Allows for a black camo to be applied to the gun.
All tactical, all the time.
*/

/obj/item/microfusion_gun_attachment/camo
	name = "czarna rama microfusion"
	desc = "Przeróbka ramy MCR-01, która zmienia kolor broni na czarny."
	slot = GUN_SLOT_CAMO
	icon_state = "attachment_black"
	attachment_overlay_icon_state = "attachment_black"

/*
HONK CAMO ATTACHMENT

Allows for a clown camo to be applied to the gun.
HONK!!
*/
/obj/item/microfusion_gun_attachment/camo/honk
	name = "bananiowa rama microfusion"
	desc = "Przeróbka ramy MCR-01, która pokrywa broń bananium."
	icon_state = "attachment_honk_camo"
	attachment_overlay_icon_state = "attachment_honk_camo"

/*
SYNDIE CAMO ATTACHMENT

Allows for a blood red camo to be applied to the gun.
Totally not property of a hostile corporation.
*/
/obj/item/microfusion_gun_attachment/camo/syndicate
	name = "krwistoczerwona rama microfusion"
	desc = "Przeróbka ramy MCR-01, która zmienia kolor broni na elegancką krwistą czerwień."
	icon_state = "attachment_syndi_camo"
	attachment_overlay_icon_state = "attachment_syndi_camo"

/*
NANOTRASEN CAMO ATTACHMENT

Allows for an official blue camo to be applied to the gun.
Hail Nanotrasen.
*/
/obj/item/microfusion_gun_attachment/camo/nanotrasen
	name = "rama microfusion marki Nanotrasen"
	desc = "Przeróbka ramy MCR-01, która zmienia kolor broni na niebieski."
	icon_state = "attachment_nt_camo"
	attachment_overlay_icon_state = "attachment_nt_camo"
