// AQUILA - kosmetyczne i uciążliwe objawy z wirusologii disease2 Monkestation
// (monkestation/code/modules/virology/disease/symtoms/flavor/ i annoying/), przerobione na advance disease.

/// Prosty objaw, który co jakiś czas wywołuje emotkę albo komunikat. Służy głównie do strojenia statystyk choroby.
/datum/symptom/flavor_emote
	level = -1
	severity = 0
	symptom_delay_min = 15
	symptom_delay_max = 45
	/// Emotka wywoływana przez objaw
	var/emote_key
	/// Komunikat dla nosiciela, losowany z listy
	var/list/messages
	/// Od którego stadium objaw działa
	var/required_stage = 2

/datum/symptom/flavor_emote/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < required_stage)
		return
	var/mob/living/M = A.affected_mob
	if(length(messages))
		to_chat(M, "<span class='warning'>[pick(messages)]</span>")
	if(emote_key)
		M.emote(emote_key)

/datum/symptom/flavor_emote/drool
	name = "Ślinotok"
	from_disease2 = TRUE
	desc = "Wirus pobudza ślinianki. Nosiciel się ślini."
	stealth = -1
	resistance = 1
	stage_speed = 2
	transmission = 1
	level = 1
	emote_key = "drool"
	prefixes = list("Drooling ")

/datum/symptom/flavor_emote/eyewater
	name = "Łzawienie"
	from_disease2 = TRUE
	desc = "Wirus podrażnia kanaliki łzowe. Nosicielowi łzawią oczy."
	stealth = -1
	resistance = 2
	stage_speed = 1
	transmission = 1
	level = 1
	emote_key = "cry"
	messages = list("Oczy cię pieką i łzawią!")
	prefixes = list("Teary ")

/datum/symptom/flavor_emote/wheeze
	name = "Świszczący oddech"
	from_disease2 = TRUE
	desc = "Wirus lekko utrudnia oddychanie, przez co nosiciel świszczy."
	stealth = 0
	resistance = 2
	stage_speed = 0
	transmission = 2
	level = 1
	emote_key = "gasp"
	messages = list("Świszczesz przy oddechu.", "Trudno ci złapać pełny oddech.")
	prefixes = list("Wheezing ")

/datum/symptom/flavor_emote/groan
	name = "Zespół jęczenia"
	from_disease2 = TRUE
	desc = "Nosiciel co jakiś czas jęczy bez wyraźnego powodu."
	stealth = -2
	resistance = 1
	stage_speed = 3
	transmission = 0
	level = 1
	emote_key = "groan"
	required_stage = 4
	prefixes = list("Groaning ")

/datum/symptom/flavor_emote/twitch
	name = "Drgawki"
	from_disease2 = TRUE
	desc = "Wirus podrażnia nerwy ruchowe. Nosiciel mimowolnie drga."
	stealth = 1
	resistance = 0
	stage_speed = 2
	transmission = 0
	level = 2
	emote_key = "twitch"
	prefixes = list("Twitching ")

/datum/symptom/flavor_emote/giggle
	name = "Niekontrolowany śmiech"
	from_disease2 = TRUE
	desc = "Wirus daje nosicielowi poczucie humoru, czy tego chce, czy nie."
	stealth = -1
	resistance = 0
	stage_speed = 1
	transmission = 2
	level = 2
	emote_key = "giggle"
	required_stage = 4
	prefixes = list("Giggling ")

/datum/symptom/soreness
	name = "Zespół bólu mięśni"
	from_disease2 = TRUE
	desc = "Wirus wyczula nosiciela na bóle i zakwasy, przez co szybciej się męczy."
	stealth = 2
	resistance = 1
	stage_speed = 0
	transmission = 0
	level = 2
	severity = 1
	symptom_delay_min = 15
	symptom_delay_max = 40
	prefixes = list("Sore ")
	threshold_desc = "<b>Szybkość stadiów 6:</b> bóle mocniej męczą."

/datum/symptom/soreness/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 6)
		power = 3

/datum/symptom/soreness/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 2)
		return
	var/mob/living/M = A.affected_mob
	to_chat(M, "<span class='notice'>Trochę cię wszystko boli.</span>")
	M.adjustStaminaLoss(5 * power)

/datum/symptom/disfiguration
	name = "Zniekształcenie"
	from_disease2 = TRUE
	desc = "Wirus rozpuszcza mięśnie twarzy. Nosiciel staje się nierozpoznawalny."
	stealth = 2
	resistance = 0
	stage_speed = 0
	transmission = -1
	level = 4
	severity = 1
	symptom_delay_min = 20
	symptom_delay_max = 40
	prefixes = list("Faceless ")
	var/disfigured = FALSE

/datum/symptom/disfiguration/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(disfigured || A.stage < 3)
		return
	var/mob/living/M = A.affected_mob
	ADD_TRAIT(M, TRAIT_DISFIGURED, DISEASE_TRAIT)
	disfigured = TRUE
	M.visible_message("<span class='warning'>Twarz [M] zapada się!</span>", "<span class='notice'>Czujesz, jak twoja twarz się marszczy i zapada!</span>")

/datum/symptom/disfiguration/End(datum/disease/advance/A)
	if(!..())
		return
	if(disfigured)
		REMOVE_TRAIT(A.affected_mob, TRAIT_DISFIGURED, DISEASE_TRAIT)
		disfigured = FALSE

/datum/symptom/chickenpox
	name = "Kurza ospa"
	from_disease2 = TRUE
	desc = "Nosiciel gdacze i wykrztusza kurze jajka."
	stealth = -2
	resistance = 1
	stage_speed = 1
	transmission = 1
	level = 3
	severity = 1
	symptom_delay_min = 15
	symptom_delay_max = 35
	prefixes = list("Poultry ")
	threshold_desc = "<b>Szybkość stadiów 7:</b> jajka pojawiają się częściej."
	/// Szansa na jajko przy każdym odpaleniu
	var/egg_chance = 15

/datum/symptom/chickenpox/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 7)
		egg_chance = 40

/datum/symptom/chickenpox/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 4)
		return
	var/mob/living/M = A.affected_mob
	if(prob(30))
		M.say(pick("KOKO!", "KOOOKO!", "KO-KO-KODAK!", "KOKOKO!", "KUKURYKU!"), forced = "kurza ospa")
	if(prob(egg_chance))
		M.visible_message("<span class='warning'>[M] wykrztusza kurze jajko!</span>", "<span class='warning'>Wykrztuszasz kurze jajko!</span>")
		playsound(get_turf(M), 'sound/effects/splat.ogg', 50, TRUE)
		new /obj/item/food/egg(get_turf(M))

/datum/symptom/dizzy
	name = "Zawroty głowy"
	from_disease2 = TRUE
	desc = "Wirus wywołuje zapalenie błędnika. Nosicielowi kręci się w głowie."
	stealth = 1
	resistance = 2
	stage_speed = -1
	transmission = 0
	level = 3
	severity = 2
	symptom_delay_min = 15
	symptom_delay_max = 30
	prefixes = list("Spinning ")
	threshold_desc = "<b>Szybkość stadiów 5:</b> silne zawroty głowy.<br><b>Transmisja 6:</b> do zawrotów dochodzą zaburzenia widzenia.<br><b>Ukrycie 4:</b> wcześniejsze stadia bez komunikatów."

/datum/symptom/dizzy/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 5)
		power = 2
	if(A.transmission >= 6)
		power = 3
	if(A.stealth >= 4)
		suppress_warning = TRUE

/datum/symptom/dizzy/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	if(A.stage < 4 || power < 2)
		if(!suppress_warning && prob(base_message_chance))
			to_chat(M, "<span class='warning'>[pick("Kręci ci się w głowie.", "Świat wiruje.")]</span>")
		return
	to_chat(M, "<span class='userdanger'>Zalewa cię fala zawrotów głowy!</span>")
	M.Dizzy(10)
	if(power >= 3)
		M.set_drugginess(20)

/datum/symptom/wendigo_hallucination
	name = "Zespół upiornego umysłu"
	from_disease2 = TRUE
	desc = "Nosiciel słyszy szepty, krzyki i kroki, których nie ma, a o sobie mówi w liczbie mnogiej."
	stealth = 1
	resistance = 1
	stage_speed = 0
	transmission = 1
	level = 4
	severity = 2
	symptom_delay_min = 20
	symptom_delay_max = 45
	prefixes = list("Eldritch ")
	/// Czy mowa jest już podpięta
	var/speech_hooked = FALSE

/datum/symptom/wendigo_hallucination/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 4)
		return
	var/mob/living/M = A.affected_mob
	if(!speech_hooked)
		RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
		speech_hooked = TRUE
	M.Jitter(10)
	var/static/list/possible_sounds = list(
		'sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/behind_you2.ogg', 'sound/hallucinations/far_noise.ogg',
		'sound/hallucinations/growl1.ogg', 'sound/hallucinations/growl2.ogg', 'sound/hallucinations/growl3.ogg',
		'sound/hallucinations/i_see_you1.ogg', 'sound/hallucinations/i_see_you2.ogg', 'sound/hallucinations/im_here1.ogg',
		'sound/hallucinations/im_here2.ogg', 'sound/hallucinations/look_up1.ogg', 'sound/hallucinations/look_up2.ogg',
		'sound/hallucinations/over_here1.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/over_here3.ogg',
		'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/turn_around2.ogg', 'sound/hallucinations/veryfar_noise.ogg',
		'sound/hallucinations/wail.ogg')
	M.playsound_local(get_turf(M), pick(possible_sounds), 50)

/datum/symptom/wendigo_hallucination/End(datum/disease/advance/A)
	if(!..())
		return
	if(speech_hooked)
		UnregisterSignal(A.affected_mob, COMSIG_MOB_SAY)
		speech_hooked = FALSE

/datum/symptom/wendigo_hallucination/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER
	var/message = speech_args[SPEECH_MESSAGE]
	// po polsku: „ja” → „my”, „mnie/mi” → „nas/nam”
	message = replacetext(message, regex(@"\bja\b", "gi"), "my")
	message = replacetext(message, regex(@"\bmnie\b", "gi"), "nas")
	message = replacetext(message, regex(@"\bmi\b", "gi"), "nam")
	speech_args[SPEECH_MESSAGE] = message

/datum/symptom/bloodynose
	name = "Krwotok z nosa"
	from_disease2 = TRUE
	desc = "Wirus uszkadza naczynia w nosie. Nosiciel krwawi z nosa, a krew może nieść wirusa."
	stealth = -1
	resistance = 1
	stage_speed = 1
	transmission = 3
	level = 3
	severity = 1
	symptom_delay_min = 10
	symptom_delay_max = 30
	prefixes = list("Bloody ")

/datum/symptom/bloodynose/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 3)
		return
	var/mob/living/carbon/M = A.affected_mob
	if(!iscarbon(M) || (NOBLOOD in M.dna?.species?.species_traits))
		return
	to_chat(M, "<span class='warning'>Leci ci krew z nosa.</span>")
	M.add_splatter_floor(get_turf(M), TRUE)

/datum/symptom/cyborg_vomit
	name = "Zespół olejowy"
	from_disease2 = TRUE
	desc = "Wirus syntetyzuje w ciele olej i inne materiały nieorganiczne, które nosiciel zwraca. Rzadko z ust wyskakuje cały robot."
	stealth = -2
	resistance = 2
	stage_speed = 0
	transmission = 1
	level = 5
	severity = 2
	symptom_delay_min = 25
	symptom_delay_max = 50
	prefixes = list("Oily ")
	threshold_desc = "<b>Szybkość stadiów 8:</b> większa szansa, że wyskoczy robot."
	/// Szansa na robota zamiast oleju
	var/bot_chance = 10
	/// Czy robot właśnie się „rodzi”
	var/bursting = FALSE

/datum/symptom/cyborg_vomit/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 8)
		bot_chance = 25

/datum/symptom/cyborg_vomit/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 3 || bursting)
		return
	var/mob/living/carbon/M = A.affected_mob
	if(!iscarbon(M) || HAS_TRAIT(M, TRAIT_NOHUNGER))
		return
	if(!prob(bot_chance))
		M.visible_message("<span class='danger'>[M] wymiotuje olejem!</span>", "<span class='danger'>Wymiotujesz olejem!</span>")
		M.adjustToxLoss(-3)
		new /obj/effect/decal/cleanable/oil(get_turf(M))
		playsound(get_turf(M), 'sound/effects/splat.ogg', 50, TRUE)
		M.Stun(5)
		return
	to_chat(M, "<span class='danger'>Czujesz, że coś zaraz z ciebie wyskoczy!</span>")
	bursting = TRUE
	addtimer(CALLBACK(src, PROC_REF(burst), M), 10 SECONDS)

/datum/symptom/cyborg_vomit/proc/burst(mob/living/carbon/M)
	bursting = FALSE
	if(QDELETED(M) || M.stat == DEAD)
		return
	var/static/list/possible_bots = list(
		/mob/living/simple_animal/bot/medbot,
		/mob/living/simple_animal/bot/secbot,
		/mob/living/simple_animal/bot/floorbot,
		/mob/living/simple_animal/bot/buttbot,
	)
	var/bot_type = pick(possible_bots)
	var/mob/living/newbot = new bot_type(get_turf(M))
	new /obj/effect/decal/cleanable/blood(get_turf(M))
	M.visible_message("<span class='danger'>[newbot] wyskakuje z ust [M]!</span>", "<span class='userdanger'>[newbot] wyskakuje ci z ust!</span>")
	playsound(get_turf(M), 'sound/effects/splat.ogg', 50, TRUE)
	M.emote("scream")
	M.adjustBruteLoss(15)
	M.Stun(10)

/datum/symptom/cult_hallucination
	name = "Wizje dni ostatecznych"
	from_disease2 = TRUE
	desc = "Nosiciel szepcze w nieznanym języku i widzi wokół siebie krwawe runy. Nie działa na kultystów ani w kaplicy."
	stealth = 2
	resistance = 0
	stage_speed = 1
	transmission = -1
	level = 4
	severity = 1
	symptom_delay_min = 30
	symptom_delay_max = 60
	prefixes = list("Apocalyptic ")
	threshold_desc = "<b>Szybkość stadiów 7:</b> więcej run."
	/// Szansa (%) na runę na każdym wolnym polu w zasięgu
	var/rune_chance = 2

/datum/symptom/cult_hallucination/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 7)
		rune_chance = 5

/datum/symptom/cult_hallucination/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 2)
		return
	var/mob/living/M = A.affected_mob
	var/turf/mob_turf = get_turf(M)
	if(!mob_turf || !M.client || IS_CULTIST(M) || istype(get_area(M), /area/chapel/main))
		return
	M.whisper("...[pick("ire","ego","nahlizet","certum","veri","jatkaa","mgar","balaq", "karazet", "geeri")]...")
	for(var/turf/open/T in RANGE_TURFS(10, mob_turf))
		if(!prob(rune_chance) || istype(get_area(T), /area/chapel/main))
			continue
		var/blocked = FALSE
		for(var/obj/O in T)
			if(O.density)
				blocked = TRUE
				break
		if(blocked)
			continue
		addtimer(CALLBACK(src, PROC_REF(show_rune), M, T), rand(0, 5 SECONDS))

/datum/symptom/cult_hallucination/proc/show_rune(mob/living/victim, turf/T)
	// obrazy należą do klienta, nie do mobka: trzymamy go, bo gracz może opuścić ciało,
	// zanim runa zniknie, i wtedy zostałaby na ekranie już jako duch
	var/client/viewer = victim?.client
	if(!viewer)
		return
	var/image/rune = image('icons/obj/rune.dmi', T, "[rand(1, 7)]")
	rune.color = RUNE_COLOR_RED
	rune.alpha = 0
	viewer.images += rune
	animate(rune, alpha = 255, time = 3 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(hide_rune), viewer, rune), rand(20 SECONDS, 40 SECONDS))

/datum/symptom/cult_hallucination/proc/hide_rune(client/viewer, image/rune)
	if(!viewer)
		return
	animate(rune, alpha = 0, time = 1.2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(remove_rune), viewer, rune), 1.2 SECONDS)

/datum/symptom/cult_hallucination/proc/remove_rune(client/viewer, image/rune)
	viewer?.images -= rune

/datum/symptom/vitreous
	name = "Rezonans szklisty"
	from_disease2 = TRUE
	desc = "Nosiciel drży z częstotliwością rozbijającą szkło. Trzymana szklanka pęka, a ręka albo się goi, albo dostaje oparzeń."
	stealth = -1
	resistance = 1
	stage_speed = 2
	transmission = 0
	level = 4
	severity = 1
	symptom_delay_min = 10
	symptom_delay_max = 25
	prefixes = list("Resonant ")
	threshold_desc = "<b>Odporność 7:</b> ręka częściej się goi, rzadziej parzy."
	/// Szansa (%), że ręka po pęknięciu szklanki się wyleczy
	var/heal_chance = 50

/datum/symptom/vitreous/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 7)
		heal_chance = 90

/datum/symptom/vitreous/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 3)
		return
	var/mob/living/carbon/human/victim = A.affected_mob
	victim.Shake(3, 3, 3 SECONDS)
	if(ishuman(victim))
		addtimer(CALLBACK(src, PROC_REF(shatter), victim), 0.5 SECONDS)

/datum/symptom/vitreous/proc/shatter(mob/living/carbon/human/victim)
	if(QDELETED(victim))
		return
	var/obj/item/glass = victim.get_active_held_item()
	if(!istype(glass, /obj/item/reagent_containers/food/drinks/drinkingglass))
		return
	var/obj/item/bodypart/arm = victim.get_bodypart(victim.active_hand_index % 2 ? BODY_ZONE_L_ARM : BODY_ZONE_R_ARM)
	to_chat(victim, "<span class='warning'>Twoja ręka rezonuje ze szklanką i rozbija ją w drobny mak!</span>")
	glass.reagents?.reaction(victim, TOUCH)
	new /obj/effect/decal/cleanable/generic(get_turf(victim))
	playsound(victim, 'sound/effects/glassbr1.ogg', 25, TRUE)
	qdel(glass)
	if(arm)
		addtimer(CALLBACK(src, PROC_REF(deresonate), victim, arm), 1 SECONDS)

/datum/symptom/vitreous/proc/deresonate(mob/living/carbon/human/victim, obj/item/bodypart/arm)
	if(QDELETED(victim) || QDELETED(arm))
		return
	if(prob(heal_chance))
		to_chat(victim, "<span class='notice'>Ręka przestaje rezonować i całkiem się goi!</span>")
		arm.heal_damage(arm.max_damage, arm.max_damage)
	else
		to_chat(victim, "<span class='warning'>Ręka przestaje rezonować, ale zostają oparzenia!</span>")
		arm.receive_damage(burn = 15)
	victim.update_damage_overlays()

/datum/symptom/fullness
	name = "Zespół pustego żołądka"
	from_disease2 = TRUE
	desc = "Nosiciel jest ciągle głodny, nawet zaraz po jedzeniu."
	stealth = 2
	resistance = 1
	stage_speed = 0
	transmission = 0
	level = 2
	severity = 1
	symptom_delay_min = 15
	symptom_delay_max = 40
	prefixes = list("Hungry ")
	threshold_desc = "<b>Szybkość stadiów 6:</b> głód rośnie szybciej."
	/// Ile odżywienia zabiera każde odpalenie
	var/hunger = 10

/datum/symptom/fullness/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 6)
		hunger = 25

/datum/symptom/fullness/Activate(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage < 2)
		return
	var/mob/living/M = A.affected_mob
	to_chat(M, "<span class='warning'>[pick("Burczy ci w brzuchu.", "Masz ochotę coś przekąsić.", "Taki głód...", "Żołądek wydaje się pusty.", "Głód...", "Kim my jesteśmy...?")]</span>")
	M.adjust_nutrition(-hunger)
