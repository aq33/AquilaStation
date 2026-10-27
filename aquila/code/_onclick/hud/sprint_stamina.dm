// Pasek kondycji (sprint): port BeeStation/BeeStation-Hornet#14750 (/atom/movable/screen/stamina).
// U nas błyskawica staminy (ui_stamina) pokazuje już staminę bojową z Bee#11521, więc kondycja ma
// własny wąski pionowy pasek tuż obok, z własną ikoną (aquila/icons/hud/screen_sprint_stamina.dmi).

/datum/hud
	var/atom/movable/screen/sprint_stamina/sprint_stamina

/datum/hud/human/New(mob/living/carbon/human/owner)
	. = ..()
	add_sprint_stamina_display(owner)

/datum/hud/monkey/New(mob/living/carbon/monkey/owner)
	. = ..()
	add_sprint_stamina_display(owner)

/datum/hud/Destroy()
	sprint_stamina = null
	return ..()

/datum/hud/proc/add_sprint_stamina_display(mob/living/carbon/owner)
	sprint_stamina = new /atom/movable/screen/sprint_stamina()
	sprint_stamina.hud = src
	infodisplay += sprint_stamina
	if(istype(owner))
		sprint_stamina.update_from(owner)

/atom/movable/screen/sprint_stamina
	name = "kondycja"
	desc = "Kondycja do sprintu (Shift). Kliknij, żeby zobaczyć dokładną wartość."
	icon = 'aquila/icons/hud/screen_sprint_stamina.dmi'
	icon_state = "sprint_10"
	screen_loc = ui_sprint_stamina
	///Czy pasek pulsuje, bo wyczerpanie jest blisko
	var/warning = FALSE

/atom/movable/screen/sprint_stamina/proc/update_from(mob/living/carbon/owner)
	var/datum/stamina_container/pool = owner.sprint_stamina
	if(!pool || owner.stat == DEAD)
		icon_state = "sprint_dead"
		set_warning(FALSE)
		return
	var/fraction = pool.get_fraction()
	var/level = clamp(round(fraction * 10), 0, 10)
	var/exhausted = HAS_TRAIT(owner, TRAIT_EXHAUSTED)
	icon_state = "[exhausted ? "exhausted" : "sprint"]_[level]"
	set_warning(!exhausted && fraction < SPRINT_STAMINA_EXHAUSTION_WARNING)

/atom/movable/screen/sprint_stamina/proc/set_warning(new_warning)
	if(warning == new_warning)
		return
	warning = new_warning
	if(warning)
		animate(src, color = "#ff4040", time = 0.4 SECONDS, loop = -1, easing = SINE_EASING)
		animate(color = null, time = 0.4 SECONDS)
	else
		animate(src)
		color = null

/atom/movable/screen/sprint_stamina/Click(location, control, params)
	var/mob/living/carbon/C = usr
	if(!istype(C) || !C.sprint_stamina)
		return
	var/datum/stamina_container/pool = C.sprint_stamina
	var/status = "Kondycja: [round(pool.current)]/[pool.maximum], regeneracja [round(pool.regen_rate, 0.1)]/s."
	if(HAS_TRAIT(C, TRAIT_EXHAUSTED))
		status += " Zadyszka minie przy [round(pool.maximum * SPRINT_STAMINA_EXHAUSTION_RECOVERY_THRESHOLD)]."
	else
		status += " Zadyszka zacznie się poniżej [round(pool.maximum * SPRINT_STAMINA_EXHAUSTION_THRESHOLD)]."
	to_chat(C, "<span class='notice'>[status]</span>")

/mob/living/carbon/proc/update_sprint_stamina_hud()
	hud_used?.sprint_stamina?.update_from(src)

/mob/living/carbon/Login()
	. = ..()
	update_sprint_stamina_hud()
