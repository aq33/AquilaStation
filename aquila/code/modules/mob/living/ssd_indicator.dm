// AQUILA - wskaźnik SSD nad postacią (port Monkestation2.0 monkestation/code/modules/indicators/ssd_indicator.dm).
// Pojawia się, gdy gracz się rozłączy, i znika przy powrocie, wyjściu duchem albo śmierci.

GLOBAL_VAR_INIT(ssd_indicator_overlay, mutable_appearance('aquila/icons/monke/ssd_indicator.dmi', "default0", FLY_LAYER))

/mob/living
	/// Is the SSD indicator shown over this mob
	var/ssd_indicator = FALSE
	/// world.time when the player last left this mob
	var/lastclienttime = 0

/mob/living/proc/set_ssd_indicator(state)
	if(state == ssd_indicator)
		return
	ssd_indicator = state
	if(ssd_indicator)
		add_overlay(GLOB.ssd_indicator_overlay)
		log_message("<font color='green'>has went SSD and got their indicator!</font>", LOG_ATTACK)
	else
		cut_overlay(GLOB.ssd_indicator_overlay)
		log_message("<font color='green'>is no longer SSD and lost their indicator!</font>", LOG_ATTACK)

/// Examine line with how long this mob has been SSD, empty when it is not
/mob/living/proc/ssd_examine_text()
	if(!ssd_indicator || client)
		return ""
	var/minutes = round((world.time - lastclienttime) / (1 MINUTES))
	if(minutes < 1)
		return "Rozłączył się przed chwilą."
	return "Jest nieobecny od [minutes] min."

/mob/living/Logout()
	. = ..()
	if(stat == DEAD)
		return
	lastclienttime = world.time
	set_ssd_indicator(TRUE)

/mob/living/Login()
	. = ..()
	set_ssd_indicator(FALSE)

// Wyjście duchem to nie rozłączenie (Logout ciała odpala się przy przejściu do ducha)
/mob/living/ghostize(can_reenter_corpse, sentience_retention)
	. = ..()
	set_ssd_indicator(FALSE)

/mob/living/death(gibbed)
	set_ssd_indicator(FALSE)
	return ..()

// Gracz przeniesiony do innego ciała (zamiana umysłów, klonowanie itd.) nie zostawia znacznika na starym
/datum/mind/transfer_to(mob/new_character, force_key_move = 0)
	var/mob/living/old_body = current
	. = ..()
	if(istype(old_body) && old_body != current)
		old_body.set_ssd_indicator(FALSE)
