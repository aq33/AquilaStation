// Gracz (tg): nastrój zależy od wygranych i przegranych na automatach do gier, bez grania przychodzi głód gier.
// Automaty nie wysyłają u nas sygnałów gry, więc wysyłają je nadpisania poniżej (z wywołaniem ..()).

#define AQ_GAMING_WITHDRAWAL_TIME (15 MINUTES)

/datum/quirk/gamer
	name = "Zapalony gracz"
	desc = "Jesteś zapalonym graczem i musisz grać. Kochasz wygrywać i nienawidzisz przegrywać. Smakuje ci tylko jedzenie dla graczy."
	icon = "gamepad"
	value = 0
	mob_trait = TRAIT_GAMER
	mood_quirk = TRUE
	gain_text = "<span class='notice'>Nagle masz ochotę pograć.</span>"
	lose_text = "<span class='notice'>Granie zupełnie przestało cię interesować.</span>"
	medical_record_text = "Pacjent jest ciężko uzależniony od gier wideo."
	/// Licznik do głodu gier
	var/gaming_withdrawal_timer = TIMER_ID_NULL

/datum/quirk/gamer/add()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/organ/tongue/tongue = human_holder.getorganslot(ORGAN_SLOT_TONGUE)
	if(tongue)
		tongue.liked_food = JUNKFOOD // dieta gracza
	RegisterSignal(quirk_holder, COMSIG_MOB_WON_VIDEOGAME, PROC_REF(won_game))
	RegisterSignal(quirk_holder, COMSIG_MOB_LOST_VIDEOGAME, PROC_REF(lost_game))
	RegisterSignal(quirk_holder, COMSIG_MOB_PLAYED_VIDEOGAME, PROC_REF(gamed))
	// Gracz zaczyna nasycony
	gaming_withdrawal_timer = addtimer(CALLBACK(src, PROC_REF(enter_withdrawal)), AQ_GAMING_WITHDRAWAL_TIME, TIMER_STOPPABLE)

/datum/quirk/gamer/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/organ/tongue/tongue = human_holder.getorganslot(ORGAN_SLOT_TONGUE)
	if(tongue)
		tongue.liked_food = initial(tongue.liked_food)
	UnregisterSignal(quirk_holder, list(COMSIG_MOB_WON_VIDEOGAME, COMSIG_MOB_LOST_VIDEOGAME, COMSIG_MOB_PLAYED_VIDEOGAME))
	if(gaming_withdrawal_timer != TIMER_ID_NULL)
		deltimer(gaming_withdrawal_timer)
		gaming_withdrawal_timer = TIMER_ID_NULL
	SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "gamer_withdrawal")

/// Wygrana gracza
/datum/quirk/gamer/proc/won_game()
	SIGNAL_HANDLER
	SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "gamer_won", /datum/mood_event/gamer_won)

/// Przegrana gracza
/datum/quirk/gamer/proc/lost_game()
	SIGNAL_HANDLER
	SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "gamer_lost", /datum/mood_event/gamer_lost)
	INVOKE_ASYNC(src, PROC_REF(gamer_moment)) // say() może spać

/// Gracz gra: znika głód gier, licznik startuje od nowa
/datum/quirk/gamer/proc/gamed()
	SIGNAL_HANDLER
	SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "gamer_withdrawal")
	if(gaming_withdrawal_timer != TIMER_ID_NULL)
		deltimer(gaming_withdrawal_timer)
	gaming_withdrawal_timer = addtimer(CALLBACK(src, PROC_REF(enter_withdrawal)), AQ_GAMING_WITHDRAWAL_TIME, TIMER_STOPPABLE)

/// Przegrana boli: przekleństwo na radiu
/datum/quirk/gamer/proc/gamer_moment()
	if(QDELETED(quirk_holder))
		return
	quirk_holder.say(";[pick("KURWA", "JA PIERDOLĘ", "CHOLERA JASNA", "SZLAG BY TO", "SKURWYSYN", "KURWA MAĆ")]!!", forced = name)

/datum/quirk/gamer/proc/enter_withdrawal()
	gaming_withdrawal_timer = TIMER_ID_NULL
	if(QDELETED(quirk_holder))
		return
	SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "gamer_withdrawal", /datum/mood_event/gamer_withdrawal)

/datum/mood_event/gamer_won
	description = "<span class='nicegreen'>Uwielbiam wygrywać w gry wideo!</span>\n"
	mood_change = 6
	timeout = 5 MINUTES

/datum/mood_event/gamer_lost
	description = "<span class='boldwarning'>Skoro nie umiem grać w gry wideo, to czy mogę się w ogóle nazywać graczem?</span>\n"
	mood_change = -6
	timeout = 10 MINUTES

/datum/mood_event/gamer_withdrawal
	description = "<span class='warning'>Chciałbym teraz pograć...</span>\n"
	mood_change = -5

// Sygnały gry z automatów

/obj/machinery/computer/arcade/battle/ui_act(action, list/params)
	. = ..()
	if(isliving(usr))
		SEND_SIGNAL(usr, COMSIG_MOB_PLAYED_VIDEOGAME)

/obj/machinery/computer/arcade/battle/arcade_action(mob/user)
	var/was_over = gameover
	. = ..()
	if(was_over || !gameover || !user)
		return
	if(enemy_hp <= 0 || enemy_mp <= 0)
		SEND_SIGNAL(user, COMSIG_MOB_WON_VIDEOGAME)
	else
		SEND_SIGNAL(user, COMSIG_MOB_LOST_VIDEOGAME)

/obj/machinery/computer/arcade/orion_trail/ui_act(action, list/params)
	var/old_status = gameStatus
	. = ..()
	if(!isliving(usr))
		return
	SEND_SIGNAL(usr, COMSIG_MOB_PLAYED_VIDEOGAME)
	// 3 to ORION_STATUS_GAMEOVER z arcade.dm (tam jest #undef)
	if(old_status != 3 && gameStatus == 3)
		SEND_SIGNAL(usr, COMSIG_MOB_LOST_VIDEOGAME)

/obj/machinery/computer/arcade/orion_trail/win(mob/user)
	. = ..()
	if(user)
		SEND_SIGNAL(user, COMSIG_MOB_WON_VIDEOGAME)

#undef AQ_GAMING_WITHDRAWAL_TIME
