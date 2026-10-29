// AQUILA - port z ParadiseSS13 (code/game/dna/mutations/mutation_powers.dm, disabilities.dm)
// Geny bez zdolności do wciśnięcia.

// Regenerate - powolne leczenie obrażeń fizycznych i oparzeń

/datum/mutation/regenerate
	name = "Regeneracja"
	desc = "Przyspiesza naprawę komórek pacjenta, przez co rany i oparzenia powoli się zamykają."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Twoje rany zaczynają się goić.</span>"
	text_lose_indication = "<span class='notice'>Czujesz, że twoja regeneracja zniknęła.</span>"
	instability = 20
	difficulty = 14
	power_coeff = 1

/datum/mutation/regenerate/on_life()
	if(owner.stat == DEAD)
		return
	var/heal = 1 * GET_MUTATION_POWER(src)
	owner.adjustBruteLoss(-heal, FALSE)
	owner.adjustFireLoss(-heal)

// Psy-Resist - zamknięty umysł

/datum/mutation/psy_resist
	name = "Odporność psioniczna"
	desc = "Usprawnia obszary mózgu kojarzone z energią metamentalną i osłania umysł przed telepatią."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Twój umysł wydaje się zamknięty.</span>"
	text_lose_indication = "<span class='notice'>Czujesz się dziwnie odsłonięty.</span>"
	instability = 10
	difficulty = 10
	mutation_traits = list(TRAIT_PSY_RESIST)

// Hallucinate - co jakiś czas fala halucynacji

/datum/mutation/hallucinate
	name = "Halucynacje"
	desc = "Mózg pacjenta co jakiś czas szwankuje i wywołuje żywe halucynacje."
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>Twój umysł mówi „Cześć”.</span>"
	text_lose_indication = "<span class='notice'>Wraca ci rozsądek. A może nie?</span>"
	synchronizer_coeff = 1

/datum/mutation/hallucinate/on_life()
	if(owner.stat == DEAD)
		return
	if(prob(1 * GET_MUTATION_SYNCHRONIZER(src)))
		owner.adjust_hallucinations(45 SECONDS)

// Paraplegic - nogi nie działają, nawet protezy

/datum/mutation/paraplegic
	name = "Paraplegia"
	desc = "Przerywa sygnały z mózgu do nóg. Nawet protezy nie pomogą."
	quality = NEGATIVE
	text_gain_indication = "<span class='danger'>MOJA NOGA!</span>"
	text_lose_indication = "<span class='notice'>Znów czujesz swoje nogi.</span>"
	mutation_traits = list(TRAIT_PARALYSIS_L_LEG, TRAIT_PARALYSIS_R_LEG)

/datum/mutation/paraplegic/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	owner.update_disabled_bodyparts()

/datum/mutation/paraplegic/on_losing(mob/living/carbon/owner)
	if(..())
		return
	owner.update_disabled_bodyparts()

// Alien Voice - bełkot pismem wingdings

/datum/mutation/alien_voice
	name = "Obcy głos"
	desc = "Zniekształca głos pacjenta w niezrozumiały bełkot."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='wingdings'>Twoje struny głosowe wydają się obce.</span>"
	text_lose_indication = "<span class='notice'>Twoje struny głosowe nie wydają się już obce.</span>"

/datum/mutation/alien_voice/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(handle_speech))

/datum/mutation/alien_voice/on_losing(mob/living/carbon/owner)
	if(..())
		return
	UnregisterSignal(owner, COMSIG_MOB_SAY)

/datum/mutation/alien_voice/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	var/message = speech_args[SPEECH_MESSAGE]
	if(!message)
		return
	var/static/upper_letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	var/static/lower_letters = "abcdefghijklmnopqrstuvwxyz"
	var/garbled = ""
	for(var/i in 1 to length_char(message))
		var/char = copytext_char(message, i, i + 1)
		if(char != lowertext(char))
			var/pos = rand(1, 26)
			garbled += copytext(upper_letters, pos, pos + 1)
		else if(char != uppertext(char))
			var/pos = rand(1, 26)
			garbled += copytext(lower_letters, pos, pos + 1)
		else
			garbled += char
	speech_args[SPEECH_MESSAGE] = garbled
	speech_args[SPEECH_SPANS] |= "wingdings"

// Horns - rogi z keratyny

/datum/mutation/horns
	name = "Rogi"
	desc = "Na głowie pacjenta wyrastają twarde narośla z keratyny."
	quality = MINOR_NEGATIVE
	text_gain_indication = "<span class='notice'>Z twojej głowy wyrasta para rogów.</span>"
	text_lose_indication = "<span class='notice'>Twoje rogi kruszą się w nicość.</span>"
	layer_used = FRONT_MUTATIONS_LAYER

/datum/mutation/horns/New(class_ = MUT_OTHER, timer, datum/mutation/copymut)
	..()
	if(!(type in visual_indicators))
		// nad włosami, pod nakryciem głowy
		visual_indicators[type] = list(mutable_appearance('aquila/icons/mutations/paradise/effects.dmi', "horns_s", -HAIR_LAYER + 0.5))

/datum/mutation/horns/get_visual_indicator()
	return visual_indicators[type][1]

// Cloak of Darkness - znikanie w ciemności, wyklucza się z Chameleon

/datum/mutation/darkcloak
	name = "Płaszcz ciemności"
	desc = "Pacjent zakrzywia wokół siebie słabe światło i staje się trudny do zauważenia."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Zaczynasz rozpływać się w cieniu.</span>"
	text_lose_indication = "<span class='notice'>Stajesz się w pełni widoczny.</span>"
	instability = 25
	difficulty = 16
	conflicts = list(/datum/mutation/chameleon)

/datum/mutation/darkcloak/on_acquiring(mob/living/carbon/owner)
	if(..())
		return TRUE
	owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY

/datum/mutation/darkcloak/on_life()
	var/turf/T = get_turf(owner)
	if(!T)
		return
	if(T.get_lumcount() * 10 <= 2)
		owner.alpha = round(owner.alpha * 0.8)
		if(owner.alpha < 20)
			owner.alpha = 0
	else
		owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY

/datum/mutation/darkcloak/on_losing(mob/living/carbon/owner)
	if(..())
		return
	owner.alpha = 255
