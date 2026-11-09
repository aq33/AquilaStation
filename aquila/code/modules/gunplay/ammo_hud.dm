// AQUILA - licznik amunicji na HUD-zie z Nova Sector (modular_nova/modules/gunhud, /atom/movable/screen/ammo_counter,
// /datum/element/ammo_hud). Sprite'y z Novy (CC-BY-SA 3.0) bez stanów z angielskimi napisami (OUT, MAG, JAM):
// pusty magazynek to czerwone 000, brak magazynka to wygaszone cyfry. W okienku pod cyframi jest tryb ognia.
// Różnice: licznik ma każdy żywy mob z bronią w ręku (bez komponentu na broni), odświeża go update_icon() broni
// (strzał, przeładowanie, ładowanie ogniwa), zmiana ręki i zmiana trybu; tło zmienia kolor przy przegrzaniu.

#define AQ_AMMO_HUD_COLOR_BALLISTIC "#00ffff"
#define AQ_AMMO_HUD_COLOR_EMPTY "#ff3030"
#define AQ_AMMO_HUD_COLOR_HOT "#ff8c00"

/atom/movable/screen/aq_ammo_counter
	name = "licznik amunicji"
	icon = 'aquila/icons/hud/gun_hud.dmi'
	icon_state = "backing"
	screen_loc = ui_aq_ammo_counter
	maptext_width = 64
	maptext_height = 32
	/// Kolor cyfr, podświetlenia i ikony trybu
	var/backing_color = AQ_AMMO_HUD_COLOR_BALLISTIC
	/// Cyfry: jedności, dziesiątki, setki (stany oX, tX, hX; "oe" itd. to wygaszona cyfra)
	var/oth_o
	var/oth_t
	var/oth_h
	/// Ikona w okienku pod cyframi (tryb ognia)
	var/indicator

/atom/movable/screen/aq_ammo_counter/proc/set_hud(new_color, new_o, new_t, new_h, new_indicator)
	backing_color = new_color
	oth_o = new_o
	oth_t = new_t
	oth_h = new_h
	indicator = new_indicator
	// Licznik broni energetycznej ma inne tło i tekst: po zmianie broni wracamy do zwykłego wyświetlacza
	icon_state = "backing"
	maptext = null
	cut_overlays()
	var/list/new_overlays = list()
	for(var/state in list("oth_light", oth_o, oth_t, oth_h, indicator))
		if(!state)
			continue
		var/mutable_appearance/part = mutable_appearance(icon, state)
		part.color = backing_color
		new_overlays += part
	add_overlay(new_overlays)

/atom/movable/screen/aq_ammo_counter/Click(location, control, params)
	var/mob/living/user = usr
	if(!istype(user))
		return
	var/obj/item/gun/held_gun = user.get_active_held_item()
	if(istype(held_gun))
		user.examinate(held_gun)

/mob/living
	/// Licznik amunicji na HUD-zie (tworzony przy pierwszej broni w ręku)
	var/atom/movable/screen/aq_ammo_counter/aq_ammo_hud

/// Broń, którą pokazuje licznik: najpierw aktywna ręka, potem druga
/mob/living/proc/get_ammo_hud_gun()
	var/obj/item/gun/active_gun = get_active_held_item()
	if(istype(active_gun))
		return active_gun
	var/obj/item/gun/inactive_gun = get_inactive_held_item()
	if(istype(inactive_gun))
		return inactive_gun
	return null

/mob/living/proc/update_ammo_hud()
	if(!client || !hud_used)
		return
	var/obj/item/gun/shown_gun = get_ammo_hud_gun()
	if(!shown_gun || !shown_gun.shows_ammo_hud())
		if(aq_ammo_hud)
			client.screen -= aq_ammo_hud
		return
	if(!aq_ammo_hud)
		aq_ammo_hud = new
	client.screen |= aq_ammo_hud
	shown_gun.fill_ammo_hud(aq_ammo_hud)

/mob/living/Destroy()
	QDEL_NULL(aq_ammo_hud)
	return ..()

/mob/living/carbon/swap_hand(held_index)
	. = ..()
	update_ammo_hud()
	update_gun_cursor()

/// Czy ta broń ma licznik (magia, broń bez amunicji: nie)
/obj/item/gun/proc/shows_ammo_hud()
	return FALSE

/obj/item/gun/ballistic/shows_ammo_hud()
	return TRUE

/obj/item/gun/energy/shows_ammo_hud()
	return TRUE

/// Kolor tła zależny od ciepła broni
/obj/item/gun/proc/get_ammo_hud_color(base_color)
	var/heat_fraction = get_heat_fraction()
	if(heat_fraction >= 0.8)
		return AQ_AMMO_HUD_COLOR_EMPTY
	if(heat_fraction >= 0.5)
		return AQ_AMMO_HUD_COLOR_HOT
	return base_color

/obj/item/gun/proc/fill_ammo_hud(atom/movable/screen/aq_ammo_counter/hud)
	return

/obj/item/gun/ballistic/fill_ammo_hud(atom/movable/screen/aq_ammo_counter/hud)
	var/mode_indicator = aq_firemode
	if(!magazine && !chambered)
		hud.set_hud(get_ammo_hud_color(AQ_AMMO_HUD_COLOR_EMPTY), "oe", "te", "he", mode_indicator)
		return
	var/rounds = get_ammo(TRUE)
	if(!rounds)
		hud.set_hud(AQ_AMMO_HUD_COLOR_EMPTY, "o0", "t0", "h0", mode_indicator)
		return
	var/rounds_text = num2text(min(rounds, 999))
	var/len = length(rounds_text)
	var/oth_o = "o[rounds_text[len]]"
	var/oth_t = len >= 2 ? "t[rounds_text[len - 1]]" : null
	var/oth_h = len >= 3 ? "h[rounds_text[len - 2]]" : null
	hud.set_hud(get_ammo_hud_color(AQ_AMMO_HUD_COLOR_BALLISTIC), oth_o, oth_t, oth_h, mode_indicator)

/obj/item/gun/energy/fill_ammo_hud(atom/movable/screen/aq_ammo_counter/hud)
	hud.cut_overlays()
	if(QDELETED(cell))
		hud.icon_state = "eammo_counter_empty"
		hud.maptext = null
		return
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	var/batt_percent = FLOOR(clamp(cell.charge / cell.maxcharge, 0, 1) * 100, 1)
	var/shot_cost_percent = FLOOR(clamp(shot.e_cost / cell.maxcharge, 0, 1) * 100, 1)
	var/batt_color = "#32ff32"
	if(!can_shoot())
		batt_color = AQ_AMMO_HUD_COLOR_EMPTY
		hud.icon_state = "eammo_counter_empty"
	else
		hud.icon_state = "eammo_counter"
		if(batt_percent <= 25)
			batt_color = "#ffff00"
	var/heat_color = get_ammo_hud_color(AQ_AMMO_HUD_COLOR_BALLISTIC)
	hud.maptext_x = (batt_percent > 99 || shot_cost_percent > 99) ? -12 : -8
	hud.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative'><font color='[batt_color]'><b>[batt_percent]%</b></font><br><font color='[heat_color]'>[shot_cost_percent]%</font></div>")

/obj/item/gun/update_icon()
	. = ..()
	if(isliving(loc))
		var/mob/living/holder = loc
		holder.update_ammo_hud()

/obj/item/gun/equipped(mob/living/user, slot)
	. = ..()
	if(istype(user))
		user.update_ammo_hud()

/obj/item/gun/dropped(mob/user)
	. = ..()
	if(isliving(user))
		var/mob/living/living_user = user
		// dropped() przychodzi przed zdjęciem z ręki, więc licznik odświeżamy chwilę później
		addtimer(CALLBACK(living_user, TYPE_PROC_REF(/mob/living, update_ammo_hud)), 1)

/obj/item/gun/set_firemode(new_mode, mob/user, silent = FALSE)
	. = ..()
	if(isliving(loc))
		var/mob/living/holder = loc
		holder.update_ammo_hud()

#undef AQ_AMMO_HUD_COLOR_BALLISTIC
#undef AQ_AMMO_HUD_COLOR_EMPTY
#undef AQ_AMMO_HUD_COLOR_HOT
