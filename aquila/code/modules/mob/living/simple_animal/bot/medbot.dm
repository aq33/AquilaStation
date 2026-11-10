// Wygląd medibota z tg: korpus zależny od apteczki i trybu (idle/active) + nakładki kół i lampek.
// Rdzeń składa medibota ze wspólnej bazy i nakładki "medskin_*", a sprite'y tg mają pełny korpus per apteczka.
// Kerfuś i inne warianty z własnym plikiem ikon zostają przy starym wyglądzie z rdzenia.
/mob/living/simple_animal/bot/medbot/update_icon()
	. = ..()
	if(icon != 'icons/mob/aibots.dmi')
		return
	cut_overlays()
	var/mode_suffix = mode == BOT_HEALING ? "active" : "idle"
	icon_state = "medbot_[get_tg_medbot_skin()]_[mode_suffix]"
	if(!stationary_mode)
		add_overlay("medbot_overlay_wheels")
	if(IsStun() || IsParalyzed())
		add_overlay("medbot_overlay_incapacitated")
		add_overlay(emissive_appearance(icon, "medbot_overlay_incapacitated", alpha = alpha))
	else if(on)
		add_overlay("medbot_overlay_on_[mode_suffix]")
		add_overlay(emissive_appearance(icon, "medbot_overlay_on_[mode_suffix]", alpha = alpha))

/// Nazwa korpusu z tg dla naszej apteczki (rad i robot to nasze przekolorowania, tg ich nie ma).
/mob/living/simple_animal/bot/medbot/proc/get_tg_medbot_skin()
	switch(skin)
		if(MEDBOT_SKIN_ADVANCED)
			return "adv"
		if(MEDBOT_SKIN_BRUTE, MEDBOT_SKIN_BURN, MEDBOT_SKIN_TOXIN, MEDBOT_SKIN_OXY, MEDBOT_SKIN_RADIATION, MEDBOT_SKIN_ROBOT, MEDBOT_SKIN_BEZERK)
			return skin
		if(MEDBOT_SKIN_SYNDI)
			return "bezerk"
	return "generic"
