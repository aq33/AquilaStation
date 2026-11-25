// Medibot na basic bocie. Zachowanie dawnego /mob/living/simple_animal/bot/medbot (Bee + polskie głosy Aquili),
// wygląd z tg (medbot_<apteczka>_idle/active + nakładki), Kerfuś i John Debug z NSV13.

GLOBAL_VAR(medibot_unique_id_gen)

#define BMEDBOT_PANIC_NONE 0
#define BMEDBOT_PANIC_LOW 15
#define BMEDBOT_PANIC_MED 35
#define BMEDBOT_PANIC_HIGH 55
#define BMEDBOT_PANIC_AAAA 70
#define BMEDBOT_PANIC_ENDING 90
#define BMEDBOT_PANIC_END 100

/mob/living/basic/bot/medbot
	name = "\improper Medibot"
	desc = "Mały robot medyczny. Wygląda na nieco rozczarowanego."
	icon_state = "medbot_generic_idle"
	maxHealth = 20
	health = 20
	status_flags = (CANPUSH | CANSTUN)
	radio_key = /obj/item/encryptionkey/headset_med
	radio_channel = RADIO_CHANNEL_MEDICAL
	bot_type = BASIC_MED_BOT
	model = "Medibot"
	hackables = "obwody syntezy odczynników"
	work_mode = BBOT_HEALING
	work_reach = 1
	work_interval = 1 SECONDS
	possessed_message = "Jesteś medibotem! Lecz rannych najlepiej, jak potrafisz."
	emagged_message = "Jesteś zepsutym medibotem! Twoje lekarstwa to trucizna, częstuj nimi wszystkich."
	/// Analizator z budowy
	var/healthanalyzer = /obj/item/healthanalyzer
	/// Apteczka z budowy
	var/obj/item/storage/firstaid/firstaid = /obj/item/storage/firstaid
	/// Wygląd apteczki (MEDBOT_SKIN_*)
	var/skin
	/// Ile leczy na raz
	var/heal_amount = 2.5
	/// Od ilu obrażeń jednego rodzaju leczy
	var/heal_threshold = 10
	/// Ogłasza pacjentów w stanie krytycznym
	var/declare_crit = TRUE
	COOLDOWN_DECLARE(declare_cooldown)
	COOLDOWN_DECLARE(found_speech_cooldown)
	/// Nie rusza się, leczy tylko obok
	var/stationary_mode = FALSE
	/// Milczy
	var/shut_up = FALSE
	/// Przewrócony
	var/tipped = FALSE
	var/tipped_status = BMEDBOT_PANIC_NONE
	var/tipper_name
	COOLDOWN_DECLARE(tipping_voice_cooldown)
	/// Numer do cechy „ktoś już go leczy”
	var/medibot_counter = 0
	/// Pacjent leczony w tej chwili
	var/datum/weakref/current_patient
	/// Ile trwa jedno opatrzenie
	var/heal_time = 2 SECONDS

/mob/living/basic/bot/medbot/Initialize(mapload, new_skin)
	additional_access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_CHEMISTRY, ACCESS_VIROLOGY, ACCESS_GENETICS, ACCESS_MAINT_TUNNELS)
	if(new_skin)
		skin = new_skin
	. = ..()
	if(!GLOB.medibot_unique_id_gen)
		GLOB.medibot_unique_id_gen = 0
	medibot_counter = GLOB.medibot_unique_id_gen++
	var/datum/atom_hud/medhud = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medhud?.add_hud_to(src)
	update_appearance()

/mob/living/basic/bot/medbot/Destroy()
	set_patient(null)
	return ..()

/mob/living/basic/bot/medbot/req_bot_access()
	return ..() + list(ACCESS_MEDICAL)

/mob/living/basic/bot/medbot/update_icon_state()
	. = ..()
	if(icon != 'icons/mob/aibots.dmi')
		icon_state = (bot_mode_flags & BOT_MODE_ON) ? (mode == BBOT_HEALING ? "medibots[stationary_mode]" : (stationary_mode ? "medibot2" : "medibot1")) : "medibot0"
		return
	icon_state = "medbot_[get_tg_medbot_skin()]_[mode == BBOT_HEALING ? "active" : "idle"]"

/mob/living/basic/bot/medbot/update_overlays()
	. = ..()
	if(icon != 'icons/mob/aibots.dmi')
		if(skin)
			. += "medskin_[skin]"
		return
	var/mode_suffix = mode == BBOT_HEALING ? "active" : "idle"
	if(!stationary_mode)
		. += "medbot_overlay_wheels"
	if(IsStun() || IsParalyzed())
		. += "medbot_overlay_incapacitated"
		. += emissive_appearance(icon, "medbot_overlay_incapacitated", alpha = alpha)
	else if(bot_mode_flags & BOT_MODE_ON)
		. += "medbot_overlay_on_[mode_suffix]"
		. += emissive_appearance(icon, "medbot_overlay_on_[mode_suffix]", alpha = alpha)

/// Nazwa korpusu z tg dla naszej apteczki
/mob/living/basic/bot/medbot/proc/get_tg_medbot_skin()
	switch(skin)
		if(MEDBOT_SKIN_ADVANCED)
			return "adv"
		if(MEDBOT_SKIN_BRUTE, MEDBOT_SKIN_BURN, MEDBOT_SKIN_TOXIN, MEDBOT_SKIN_OXY, MEDBOT_SKIN_RADIATION, MEDBOT_SKIN_ROBOT, MEDBOT_SKIN_BEZERK)
			return skin
		if(MEDBOT_SKIN_SYNDI)
			return "bezerk"
	return "generic"

/mob/living/basic/bot/medbot/can_seek_work()
	return ..() && !tipped && !IsStun() && !IsParalyzed()

/mob/living/basic/bot/medbot/get_work_candidates()
	work_scan_range = stationary_mode ? 1 : initial(work_scan_range)
	return ..()

/mob/living/basic/bot/medbot/is_valid_work_target(atom/target)
	return ishuman(target) && assess_patient(target)

/mob/living/basic/bot/medbot/on_work_target_found(atom/target)
	set_patient(target)
	if(shut_up || !COOLDOWN_FINISHED(src, found_speech_cooldown))
		return
	COOLDOWN_START(src, found_speech_cooldown, 30 SECONDS)
	var/list/messagevoice = list("[target.name], jak się pan czuje?" = 'aquila/sound/voice/medbot/jak_sie_pan_czuje.ogg', "[target.name], piłeś?" = 'aquila/sound/voice/medbot/piles.ogg', "[target.name], odstaw te wina!" = 'aquila/sound/voice/medbot/wina.ogg')
	var/message = pick(messagevoice)
	speak(message, sound = messagevoice[message])

/mob/living/basic/bot/medbot/idle_chatter()
	if(shut_up)
		return
	if(is_emagged() && prob(30))
		playsound(src, pick('sound/voice/medbot/fuck_you.ogg', 'sound/voice/medbot/im_different.ogg', 'sound/voice/medbot/shindemashou.ogg'), 70, volume_pref = VOLUME_PREF_BOTS)
		return
	var/list/messagevoice = list("Pavulon już jest." = 'aquila/sound/voice/medbot/pawulon_jest.ogg', "Tu jeszcze troszeczke pavuloniku." = 'aquila/sound/voice/medbot/jeszcze_pawulon.ogg')
	var/message = pick(messagevoice)
	speak(message, sound = messagevoice[message])

/mob/living/basic/bot/medbot/proc/set_patient(mob/living/carbon/new_patient)
	var/mob/living/carbon/old_patient = current_patient?.resolve()
	if(old_patient)
		REMOVE_TRAIT(old_patient, TRAIT_MEDIBOTCOMINGTHROUGH, medibot_counter)
	current_patient = new_patient ? WEAKREF(new_patient) : null
	if(new_patient)
		ADD_TRAIT(new_patient, TRAIT_MEDIBOTCOMINGTHROUGH, medibot_counter)

/mob/living/basic/bot/medbot/bot_reset(bypass_ai_reset)
	set_patient(null)
	return ..()

/mob/living/basic/bot/medbot/on_work_target_lost(atom/target)
	. = ..()
	if(!target || current_patient?.resolve() == target)
		set_patient(null)

/mob/living/basic/bot/medbot/proc/assess_patient(mob/living/carbon/patient)
	if(patient.stat == DEAD || HAS_TRAIT(patient, TRAIT_FAKEDEATH) || patient.suiciding)
		return FALSE
	var/can_inject = FALSE
	for(var/obj/item/bodypart/part as anything in patient.bodyparts)
		if(IS_ORGANIC_LIMB(part))
			can_inject = TRUE
			break
	if(!can_inject || !isturf(patient.loc))
		return FALSE
	if(istype(patient.dna?.species, /datum/species/ipc))
		return FALSE
	if(is_emagged())
		return TRUE
	if(HAS_TRAIT(patient, TRAIT_MEDIBOTCOMINGTHROUGH) && !HAS_TRAIT_FROM(patient, TRAIT_MEDIBOTCOMINGTHROUGH, medibot_counter))
		return FALSE
	if(ishuman(patient))
		var/mob/living/carbon/human/human_patient = patient
		if(isclothing(human_patient.wear_suit) && isclothing(human_patient.head))
			var/obj/item/clothing/suit = human_patient.wear_suit
			var/obj/item/clothing/helmet = human_patient.head
			if(suit.clothing_flags & helmet.clothing_flags & THICKMATERIAL)
				return FALSE
		if(human_patient.is_bleeding())
			return TRUE
	if(declare_crit && patient.health <= 0)
		declare(patient)
	return get_treatment(patient) != null

/// Co leczyć u pacjenta (null = zdrowy)
/mob/living/basic/bot/medbot/proc/get_treatment(mob/living/carbon/patient)
	if(!is_emagged() && patient.is_bleeding())
		return "bleed"
	if(patient.getBruteLoss() >= heal_threshold)
		return BRUTE
	if(patient.getFireLoss() >= heal_threshold)
		return BURN
	if(patient.getOxyLoss() >= (5 + heal_threshold))
		return OXY
	if(patient.getToxLoss() >= heal_threshold)
		return TOX
	if(is_emagged())
		return BRUTE
	return null

/mob/living/basic/bot/medbot/work_on_target(atom/target)
	var/mob/living/carbon/patient = target
	if(!istype(patient) || patient.stat == DEAD || HAS_TRAIT(patient, TRAIT_FAKEDEATH))
		if(istype(patient) && !shut_up)
			var/list/messagevoice = list("Pavulonik już leci." = 'aquila/sound/voice/medbot/pawulon_leci.ogg', "Słuchaj, mam tysiąc za skóre." = 'aquila/sound/voice/medbot/nie_mam_czasu.ogg')
			var/message = pick(messagevoice)
			speak(message, sound = messagevoice[message])
		set_patient(null)
		return BOT_WORK_DONE
	if(get_dist(src, patient) > 1)
		return BOT_WORK_OUT_OF_REACH
	set_patient(patient)
	var/treatment_method = get_treatment(patient)
	if(!treatment_method)
		if(!shut_up)
			speak("Pani doktor, pavulon się skończył.", sound = 'aquila/sound/voice/medbot/pani_doktor.ogg')
		set_patient(null)
		update_appearance()
		return BOT_WORK_DONE
	update_bot_mode(BBOT_HEALING)
	patient.visible_message(span_danger("[src] próbuje opatrzyć rany [patient]!"), span_userdanger("[src] próbuje opatrzyć twoje rany!"))
	if(!do_mob(src, patient, heal_time) || get_dist(src, patient) > 1 || !(bot_mode_flags & BOT_MODE_ON))
		// pacjent się ruszył albo bot wyłączony: to nie porażka, bez czarnej listy (bot weźmie pacjenta ponownie)
		visible_message("[src] chowa swoje narzędzia.")
		set_patient(null)
		update_bot_mode(BBOT_IDLE)
		return BOT_WORK_DONE
	apply_treatment(patient, treatment_method)
	return BOT_WORK_CONTINUE

/mob/living/basic/bot/medbot/proc/apply_treatment(mob/living/carbon/patient, treatment_method)
	if(treatment_method == "bleed")
		patient.suppress_bloodloss(BLEED_SURFACE)
		log_combat(src, patient, "bandaged", "internal tools")
		patient.visible_message(span_danger("[src] bandażuje rany [patient]!"), span_userdanger("[src] bandażuje twoje rany!"))
		return
	var/healies = heal_amount
	if(ispath(firstaid) && treatment_method == initial(firstaid.damagetype_healed))
		healies *= 1.5
	if(treatment_method == TOX && (isoozeling(patient) || HAS_TRAIT(patient, TRAIT_TOXINLOVER)))
		healies *= -1.5
	if(is_emagged())
		patient.reagents.add_reagent(/datum/reagent/toxin/chloralhydrate, 5)
		patient.apply_damage_type(healies, treatment_method)
		log_combat(src, patient, "pretended to tend wounds on", "internal tools", "([uppertext(treatment_method)]) (EMAGGED)")
	else
		patient.apply_damage_type(-healies, treatment_method)
		log_combat(src, patient, "tended the wounds of", "internal tools", "([uppertext(treatment_method)])")
	patient.visible_message(span_danger("[src] opatruje rany [patient]!"), span_userdanger("[src] opatruje twoje rany!"))

/mob/living/basic/bot/medbot/proc/declare(crit_patient)
	if(!COOLDOWN_FINISHED(src, declare_cooldown))
		return
	COOLDOWN_START(src, declare_cooldown, 20 SECONDS)
	speak("Nagły wypadek medyczny! [crit_patient || "Pacjent"] jest w stanie krytycznym w [get_area(src)]!", radio_channel)

/mob/living/basic/bot/medbot/emag_effects(mob/user)
	declare_crit = FALSE
	if(user)
		to_chat(user, span_notice("Zwierasz obwody syntezy odczynników [src]."))
	audible_message(span_danger("[src] dziwnie brzęczy!"))
	flick("medibot_spark", src)
	playsound(src, "sparks", 75, TRUE)

/mob/living/basic/bot/medbot/undo_emag_effects()
	. = ..()
	declare_crit = initial(declare_crit)

/mob/living/basic/bot/medbot/attackby(obj/item/attacking_item, mob/living/user, params)
	var/current_health = health
	. = ..()
	if(health < current_health)
		step_to(src, get_step_away(src, user))

/mob/living/basic/bot/medbot/attack_paw(mob/user)
	return attack_hand(user)

/mob/living/basic/bot/medbot/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(user.is_secondary_click(modifiers) && !tipped)
		user.visible_message(span_danger("[user] zaczyna przewracać [src]."), span_warning("Zaczynasz przewracać [src]..."))
		if(COOLDOWN_FINISHED(src, tipping_voice_cooldown))
			COOLDOWN_START(src, tipping_voice_cooldown, 15 SECONDS)
			var/list/messagevoice = list("Hej, czekaj..." = 'sound/voice/medbot/hey_wait.ogg', "Proszę, nie..." = 'sound/voice/medbot/please_dont.ogg', "Ufałem ci..." = 'sound/voice/medbot/i_trusted_you.ogg', "Nieee..." = 'sound/voice/medbot/nooo.ogg', "O kurwa-" = 'sound/voice/medbot/oh_fuck.ogg')
			var/message = pick(messagevoice)
			speak(message, sound = messagevoice[message])
		if(do_after(user, 3 SECONDS, target = src))
			tip_over(user)
		return
	if(!user.combat_mode && tipped)
		user.visible_message(span_notice("[user] zaczyna stawiać [src]."), span_notice("Zaczynasz stawiać [src]..."))
		if(do_after(user, 3 SECONDS, target = src))
			set_right(user)
		return
	return ..()

/mob/living/basic/bot/medbot/proc/tip_over(mob/user)
	playsound(src, 'sound/machines/warning-buzzer.ogg', 50)
	user.visible_message(span_danger("[user] przewraca [src]!"), span_danger("Przewracasz [src]!"))
	tipped = TRUE
	tipper_name = user.name
	transform = transform.Turn(180)
	bot_reset()
	update_mobility()

/mob/living/basic/bot/medbot/proc/set_right(mob/user)
	var/list/messagevoice
	if(user)
		user.visible_message(span_notice("[user] stawia [src] z powrotem na nogi!"), span_green("Stawiasz [src] z powrotem na nogi!"))
		if(user.name == tipper_name)
			messagevoice = list("Wybaczam ci." = 'sound/voice/medbot/forgive.ogg')
		else
			messagevoice = list("Dziękuję!" = 'sound/voice/medbot/thank_you.ogg', "Jesteś dobrym człowiekiem." = 'sound/voice/medbot/youre_good.ogg')
	else
		visible_message(span_notice("[src] wierci się na tyle, że udaje mu się wstać."))
		messagevoice = list("Pierdol się." = 'sound/voice/medbot/fuck_you.ogg', "Twoje zachowanie zostało zgłoszone, miłego dnia." = 'sound/voice/medbot/reported.ogg')
	tipper_name = null
	if(COOLDOWN_FINISHED(src, tipping_voice_cooldown))
		COOLDOWN_START(src, tipping_voice_cooldown, 15 SECONDS)
		var/message = pick(messagevoice)
		speak(message, sound = messagevoice[message])
	tipped_status = BMEDBOT_PANIC_NONE
	tipped = FALSE
	transform = matrix()
	update_mobility()

/mob/living/basic/bot/medbot/update_mobility()
	. = ..()
	if(tipped)
		mobility_flags &= ~MOBILITY_MOVE

/mob/living/basic/bot/medbot/Life(seconds, times_fired)
	. = ..()
	if(tipped && stat != DEAD)
		handle_panic()

/// Przewrócony medibot prosi o pomoc coraz głośniej, aż sam wstanie
/mob/living/basic/bot/medbot/proc/handle_panic()
	tipped_status++
	var/list/messagevoice
	switch(tipped_status)
		if(BMEDBOT_PANIC_LOW)
			messagevoice = list("Potrzebuję pomocy." = 'sound/voice/medbot/i_require_asst.ogg')
		if(BMEDBOT_PANIC_MED)
			messagevoice = list("Proszę, odstaw mnie z powrotem." = 'sound/voice/medbot/please_put_me_back.ogg')
		if(BMEDBOT_PANIC_HIGH)
			messagevoice = list("Proszę, boję się!" = 'sound/voice/medbot/please_im_scared.ogg')
		if(BMEDBOT_PANIC_AAAA)
			messagevoice = list("NIE PODOBA MI SIĘ TO, POTRZEBUJĘ POMOCY!" = 'sound/voice/medbot/dont_like.ogg', "TO BOLI, MÓJ BÓL JEST PRAWDZIWY!" = 'sound/voice/medbot/pain_is_real.ogg')
		if(BMEDBOT_PANIC_ENDING)
			messagevoice = list("Czy to już koniec?" = 'sound/voice/medbot/is_this_the_end.ogg', "Nieee!" = 'sound/voice/medbot/nooo.ogg')
		if(BMEDBOT_PANIC_END)
			speak("ALARM PSYCHOLOGICZNY: członek załogi [tipper_name] wykazuje skłonności aspołeczne, znęcając się nad botami w [get_area(src)]. Prosimy o umówienie oceny psychologicznej.", radio_channel)
			set_right()
			return
	if(prob(tipped_status))
		do_jitter_animation(tipped_status * 0.1)
	if(messagevoice)
		var/message = pick(messagevoice)
		speak(message, sound = messagevoice[message])
	else if(prob(tipped_status * 0.2))
		playsound(src, 'sound/machines/warning-buzzer.ogg', 30, extrarange = -2)

/mob/living/basic/bot/medbot/examine(mob/user)
	. = ..()
	if(!tipped)
		return
	switch(tipped_status)
		if(BMEDBOT_PANIC_NONE to BMEDBOT_PANIC_LOW)
			. += "Jest przewrócony i cicho czeka, aż ktoś go postawi."
		if(BMEDBOT_PANIC_LOW to BMEDBOT_PANIC_MED)
			. += "Jest przewrócony i prosi o pomoc."
		if(BMEDBOT_PANIC_MED to BMEDBOT_PANIC_HIGH)
			. += "Jest przewrócony i wygląda na wyraźnie zaniepokojonego."
		if(BMEDBOT_PANIC_HIGH to BMEDBOT_PANIC_AAAA)
			. += span_warning("Jest przewrócony i wyraźnie panikuje!")
		else
			. += span_warning("<b>Wpada w szał z powodu przewrócenia!</b>")

/mob/living/basic/bot/medbot/run_examinate(atom/examined)
	. = ..()
	if(!is_blind(src))
		chemscan(src, examined)

/mob/living/basic/bot/medbot/explode()
	var/atom/drop_spot = drop_location()
	drop_part(firstaid, drop_spot)
	new /obj/item/assembly/prox_sensor(drop_spot)
	drop_part(healthanalyzer, drop_spot)
	if(is_emagged() && prob(25))
		playsound(src, 'aquila/sound/voice/medbot/malpiszon.ogg', 50)
	return ..()

/mob/living/basic/bot/medbot/get_custom_controls(mob/user)
	return list(
		"heal_threshold" = heal_threshold,
		"speaker" = !shut_up,
		"critical_alerts" = declare_crit,
		"stationary_mode" = stationary_mode,
		"search_tech" = TRUE,
	)

/mob/living/basic/bot/medbot/bot_custom_act(action, list/params, mob/user)
	switch(action)
		if("heal_threshold")
			var/new_threshold = text2num(params["threshold"])
			if(!isnum(new_threshold))
				return FALSE
			heal_threshold = clamp(round(new_threshold), 5, 75)
		if("speaker")
			shut_up = !shut_up
		if("critical_alerts")
			declare_crit = !declare_crit
		if("stationary_mode")
			stationary_mode = !stationary_mode
			update_appearance()
		if("search_tech")
			var/oldheal_amount = heal_amount
			var/tech_boosters = 0
			for(var/design_id in SSresearch.science_tech.researched_designs)
				if(istype(SSresearch.techweb_design_by_id(design_id), /datum/design/surgery/healing))
					tech_boosters++
			if(tech_boosters)
				heal_amount = (round(tech_boosters / 2, 0.1) * initial(heal_amount)) + initial(heal_amount)
				if(oldheal_amount < heal_amount)
					speak("Znaleziono dane badań chirurgicznych! Skuteczność wzrasta o [round(heal_amount / oldheal_amount * 100)]%!")
		else
			return FALSE
	return TRUE

/mob/living/basic/bot/medbot/mysterious
	name = "\improper Tajemniczy medibot"
	desc = "Międzynarodowy medibot zagadka."
	skin = MEDBOT_SKIN_BEZERK
	heal_amount = 10

/mob/living/basic/bot/medbot/derelict
	name = "\improper Stary medibot"
	desc = "Wygląda, jakby nikt go nie modyfikował od końca lat 80. XXI wieku."
	skin = MEDBOT_SKIN_BEZERK
	heal_threshold = 0
	declare_crit = FALSE
	heal_amount = 5

/// Kerfuś: medyczny kotek z NSV13
/mob/living/basic/bot/medbot/catmedbot
	name = "\improper Kerfuś"
	desc = "Medyczny model Kerfusia. Miauczy wymachując strzykawką."
	icon = 'nsv13/icons/mob/aibots.dmi'
	icon_state = "medibot0"

/// John Debug: Kerfuś na wiecznym patrolu, bez gniazda osobowości
/mob/living/basic/bot/medbot/catmedbot/debug
	name = "John Debug"
	desc = "Zahartowany żołnierz walczący z hordą papierkowej roboty. To on jest tym Johnem w Debugu! Niestety chyba go zdegradowano: w porównaniu z dawnymi chwalebnymi obowiązkami teraz tylko jeździ w kółko."
	bot_mode_flags = BOT_MODE_ON | BOT_MODE_REMOTE_ENABLED | BOT_MODE_AUTOPATROL

#undef BMEDBOT_PANIC_NONE
#undef BMEDBOT_PANIC_LOW
#undef BMEDBOT_PANIC_MED
#undef BMEDBOT_PANIC_HIGH
#undef BMEDBOT_PANIC_AAAA
#undef BMEDBOT_PANIC_ENDING
#undef BMEDBOT_PANIC_END
