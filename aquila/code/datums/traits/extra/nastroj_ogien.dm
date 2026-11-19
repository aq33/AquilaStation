// Piromania (tg). Lęk przed ogniem jest rodzajem Fobii (nastroj_fobie.dm).

/datum/quirk/pyromania
	name = "Piromania"
	desc = "Ogień cię fascynuje. Przy ogniu masz lepszy humor i jesteś trochę odporniejszy na gorąco i płomienie."
	icon = "fire"
	value = 2
	mood_quirk = TRUE
	process = TRUE
	gain_text = "<span class='warning'>Czujesz palącą chęć wzniecania pożarów.</span>"
	lose_text = "<span class='notice'>Zdajesz sobie sprawę, jak niebezpieczny potrafi być ogień.</span>"
	medical_record_text = "Pacjent jest zafascynowany ogniem i wykazuje kompulsywną chęć wzniecania pożarów."
	/// Mnożnik obrażeń od gorąca
	var/damage_mod = 0.67
	/// Ostatnio policzone płomienie (żeby nie spamować nastrojem)
	var/last_fire_size = -1
	/// Kiedy znów można odruchowo pstryknąć zapalniczką
	COOLDOWN_DECLARE(start_fire_cd)

/datum/quirk/pyromania/post_add()
	to_chat(quirk_holder, "<span class='info'>Pamiętaj: piromania NIE daje ci żadnego dodatkowego prawa do wzniecania pożarów.</span>")

/datum/quirk/pyromania/add()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.physiology.heat_mod *= damage_mod
	RegisterSignal(quirk_holder, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(damage_taken))

/datum/quirk/pyromania/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOB_APPLY_DAMAGE)
	if(QDELETED(quirk_holder))
		return
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.physiology.heat_mod /= damage_mod
	SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "pyromania_fire")

/datum/quirk/pyromania/on_process(delta_time)
	var/fire_size = aq_count_nearby_fire_sources(quirk_holder)
	if(fire_size != last_fire_size)
		// Ta sama kategoria z tym samym typem nie odświeża się sama, więc najpierw czyścimy
		SEND_SIGNAL(quirk_holder, COMSIG_CLEAR_MOOD_EVENT, "pyromania_fire")
		if(fire_size >= 1)
			SEND_SIGNAL(quirk_holder, COMSIG_ADD_MOOD_EVENT, "pyromania_fire", /datum/mood_event/pyromania, fire_size)
	last_fire_size = fire_size

	if(!COOLDOWN_FINISHED(src, start_fire_cd))
		return
	var/datum/component/mood/mood = quirk_holder.GetComponent(/datum/component/mood)
	if(!mood || !DT_PROB((SANITY_NEUTRAL - mood.sanity) / 5, delta_time))
		return
	for(var/obj/item/lighter/lighter in quirk_holder.held_items)
		if(lighter.lit)
			continue
		to_chat(quirk_holder, "<span class='warning'>Odruchowo pstrykasz [lighter.name], próbując skrzesać płomień...</span>")
		lighter.attack_self(quirk_holder)
		COOLDOWN_START(src, start_fire_cd, 4 SECONDS)
		break

/// Przy obrywaniu nie ma czasu na zabawę zapalniczką
/datum/quirk/pyromania/proc/damage_taken(datum/source, damage_amount, damage_type)
	SIGNAL_HANDLER
	if(damage_amount >= 5 && (damage_type == BRUTE || damage_type == BURN || damage_type == STAMINA))
		COOLDOWN_START(src, start_fire_cd, 12 SECONDS)

/datum/mood_event/pyromania
	description = "<span class='nicegreen'>Piękny, ciepły ogień...</span>\n"
	mood_change = 1

/datum/mood_event/pyromania/add_effects(fire_size = 0)
	mood_change = fire_size
