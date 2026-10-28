// Port BeeStation/BeeStation-Hornet#11521 (tgstation#53974, #64011, #71623): wskaźnik staminy na HUD-zie,
// od Bee#14750 pokazuje jedną pulę staminy (pulsuje przed wyczerpaniem, kliknięcie podaje wartość). Ludzie i małpy.
// Stamina znika przy tym ze wskaźnika zdrowia (AQ EDIT w /mob/living/carbon/human/update_health_hud()).
// Pozycja inna niż w Bee: u nas CENTER-3 zajmuje nastrój, a CENTER-4 lokalizator dowódcy oddziału.

/datum/hud
	var/atom/movable/screen/stamina/stamina

/datum/hud/human/New(mob/living/carbon/human/owner)
	. = ..()
	add_stamina_display()

/datum/hud/monkey/New(mob/living/carbon/monkey/owner)
	. = ..()
	add_stamina_display()

/datum/hud/Destroy()
	stamina = null
	return ..()

/datum/hud/proc/add_stamina_display()
	stamina = new /atom/movable/screen/stamina()
	stamina.hud = src
	infodisplay += stamina

/atom/movable/screen/stamina
	name = "stamina"
	desc = "Stamina (sprint, zamachy, odpychanie). Kliknij, żeby zobaczyć dokładną wartość."
	icon = 'aquila/icons/hud/screen_stamina.dmi'
	icon_state = "stamina_full"
	screen_loc = ui_stamina
	///Czy wskaźnik pulsuje, bo wyczerpanie jest blisko
	var/warning = FALSE

/atom/movable/screen/stamina/proc/set_warning(new_warning)
	if(warning == new_warning)
		return
	warning = new_warning
	if(warning)
		animate(src, color = "#ff4040", time = 0.4 SECONDS, loop = -1, easing = SINE_EASING)
		animate(color = null, time = 0.4 SECONDS)
	else
		animate(src)
		color = null

/atom/movable/screen/stamina/Click(location, control, params)
	var/mob/living/carbon/C = usr
	if(!istype(C) || !C.stamina)
		return
	var/datum/stamina_container/pool = C.stamina
	var/status = "Stamina: [round(pool.current)]/[pool.maximum], regeneracja [round(pool.regen_rate, 0.1)]/s."
	if(HAS_TRAIT(C, TRAIT_EXHAUSTED))
		status += " Wyczerpanie minie przy [round(pool.maximum * STAMINA_EXHAUSTION_RECOVERY_THRESHOLD_MODIFIER)]."
	else
		status += " Wyczerpanie zacznie się poniżej [round(pool.maximum * STAMINA_EXHAUSTION_THRESHOLD_MODIFIER)]."
	to_chat(C, "<span class='notice'>[status]</span>")

/// Changes the stamina HUD based on new information
/mob/proc/update_stamina_hud()
	return

/mob/living/carbon/update_stamina_hud(shown_stamina_loss)
	// Bez sprawdzania client jak w oryginale: hud_used i tak istnieje tylko u graczy, a test może go założyć sam
	if(!hud_used?.stamina || !stamina)
		return

	var/atom/movable/screen/stamina/display = hud_used.stamina
	if(stat == DEAD)
		display.icon_state = "stamina_dead"
		display.set_warning(FALSE)
		return

	var/max = stamina.maximum
	display.set_warning(!HAS_TRAIT(src, TRAIT_EXHAUSTED) && !HAS_TRAIT(src, TRAIT_NOSTAMCRIT) && stamina.current < max * STAMINA_EXHAUSTION_WARNING_MODIFIER)
	if(isnull(shown_stamina_loss))
		shown_stamina_loss = stamina.loss

	if(shown_stamina_loss >= max || is_stamcrit())
		display.icon_state = "stamina_crit"
	else if(shown_stamina_loss > max * 0.8)
		display.icon_state = "stamina_5"
	else if(shown_stamina_loss > max * 0.6)
		display.icon_state = "stamina_4"
	else if(shown_stamina_loss > max * 0.4)
		display.icon_state = "stamina_3"
	else if(shown_stamina_loss > max * 0.2)
		display.icon_state = "stamina_2"
	else if(shown_stamina_loss > 0)
		display.icon_state = "stamina_1"
	else
		display.icon_state = "stamina_full"

/mob/living/carbon/Login()
	. = ..()
	update_stamina_hud()
