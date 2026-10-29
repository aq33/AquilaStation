
/datum/rune_spell/communication
	name = "Komunikacja"
	desc = "Mów tak, by każdy kultysta usłyszał twój głos. Działa nawet wtedy, gdy w pobliżu nie ma iglicy."
	desc_talisman = "Użyj, by napisać i wysłać wiadomość do wszystkich wyznawców Nar-Sie. W trakcie rytuału użyj ponownie, by przekazać wiadomość, którą wszyscy zapamiętają."
	invocation = "O bidai nabora se'sma!"
	rune_flags = RUNE_STAND
	talisman_uses = 10
	var/obj/effect/cult_ritual/cult_communication/comms = null
	word1 = /datum/rune_word/self
	word2 = /datum/rune_word/other
	word3 = /datum/rune_word/technology
	page = "Gdy staniesz na runie i jej dotkniesz, cały kult usłyszy to, co powiesz albo wyszepczesz. \
		Używając jej, zawsze mówisz też w języku kultu.\
		<br><br>Talizmany z tą runą można użyć 10 razy, by wysłać wiadomość do reszty kultu.\
		<br><br>Dotknięcie runy po raz drugi, gdy już jej używasz, pozwala zostawić przypomnienia dla kultu, które usłyszą nowo nawróceni i które trafią do ich notatek.\
		<br><br>Ta runa zostaje po użyciu, można jej używać wielokrotnie."

/datum/rune_spell/communication/cast()
	var/obj/effect/new_rune/R = spell_holder
	R.one_pulse()
	var/mob/living/user = activator
	comms = new /obj/effect/cult_ritual/cult_communication(spell_holder.loc, user, src)

/datum/rune_spell/communication/midcast(mob/living/user)
	var/datum/team/cult/cult = locate_team(/datum/team/cult)
	if (!istype(cult))
		return
	if (!istype(user)) // Ghosts
		return
	var/reminder = stripped_multiline_input(user, "Napisz przypomnienie.", "Przypomnienie kultu")
	if (!reminder)
		return
	var/number = cult.cult_reminders.len
	var/text = "[number + 1]) [reminder], od [user.real_name]."
	cult.cult_reminders += text
	for(var/datum/mind/mind in cult.members)
		if (IS_CULTIST(mind.current))//failsafe for cultist brains put in MMIs
			to_chat(mind.current, span_cult("Głos <b>[user.real_name]</b> odbija się echem w twojej głowie: [span_cultbold(reminder)]"))

	for(var/mob/living/simple_animal/astral_projection/astral in GLOB.astral_projections)
		to_chat(astral, span_cult("Głos <b>[user.real_name]</b> odbija się echem w twojej głowie: [span_cultbold(reminder)]"))

	for(var/mob/dead/observer/observer in GLOB.player_list)
		to_chat(observer, span_cult("Głos <b>[user.real_name]</b> odbija się echem w twojej głowie: [span_cultbold(reminder)]"))

	user.log_talk(reminder, LOG_SAY, tag = "cult reminder")

/datum/rune_spell/communication/cast_talisman()//we write our message on the talisman, like in previous versions.
	var/message = stripped_multiline_input(activator, "Napisz wiadomość do swoich akolitów.", "List z krwi", max_length = MAX_MESSAGE_LEN)
	if(!message)
		qdel(src)
		return

	var/datum/antagonist/cult/team = IS_CULTIST(activator)
	var/datum/team/cult = team?.cult_team
	if(!cult)
		qdel(src)
		return
	for (var/datum/mind/mind in cult.members)
		if (IS_CULTIST(mind.current))//failsafe for cultist brains put in MMIs
			to_chat(mind.current, span_cult("Głos <b>[activator.real_name]</b> odbija się echem w twojej głowie: [span_cultbold(message)]"))

	for(var/mob/living/simple_animal/astral_projection/astral in GLOB.astral_projections)
		to_chat(astral, span_cult("Głos <b>[activator.real_name]</b> odbija się echem w twojej głowie: [span_cultbold(message)]"))

	for(var/mob/dead/observer/observer in GLOB.player_list)
		to_chat(observer, span_cult("Głos <b>[activator.real_name]</b> odbija się echem w twojej głowie: [span_cultbold(message)]"))

	activator.log_talk(message, LOG_SAY, tag = "cult talisman")

	qdel(src)

/datum/rune_spell/communication/Destroy()
	destroying_self = 1
	if (comms)
		qdel(comms)
	comms = null
	return ..()

/obj/effect/cult_ritual/cult_communication
	anchored = 1
	icon_state = "rune_communication"
	pixel_y = 8
	alpha = 200
	layer = ABOVE_OBJ_LAYER
	plane = GAME_PLANE
	mouse_opacity = 0
	var/mob/living/caster = null
	var/datum/rune_spell/communication/source = null
	/// AQUILA - w vg flaga PROXMOVE, u nas monitor zbliżeń
	var/datum/proximity_monitor/proximity_monitor


/obj/effect/cult_ritual/cult_communication/New(turf/loc, mob/living/user, datum/rune_spell/communication/runespell)
	..()
	caster = user
	source = runespell
	become_hearing_sensitive(ROUNDSTART_TRAIT)
	proximity_monitor = new(src, 1)

/obj/effect/cult_ritual/cult_communication/Destroy()
	QDEL_NULL(proximity_monitor)
	caster = null
	source = null
	return ..()

/obj/effect/cult_ritual/cult_communication/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	. = ..()
	if(!speaker || speaker.loc != loc || radio_freq)
		return
	var/speaker_name = speaker.name
	var/mob/living/L
	if (isliving(speaker))
		L = speaker
		if (!IS_CULTIST(L))//geez we don't want that now do we
			return
	if (ishuman(speaker))
		var/mob/living/carbon/human/human = speaker
		speaker_name = human.real_name
		L = speaker

	var/datum/antagonist/cult/user = IS_CULTIST(L)
	var/datum/team/cult/cult = user?.cult_team
	if (!cult)
		return
	for (var/datum/mind/mind in cult.members)
		if (mind.current == speaker)//echoes are annoying
			continue
		if (IS_CULTIST(mind.current))//failsafe for cultist brains put in MMIs
			to_chat(mind.current, "<span class='game say'>Głos <b>[speaker_name]</b> odbija się echem w twojej głowie: [span_cultlarge(raw_message)]</span>")

	for(var/mob/living/simple_animal/astral_projection/astral in GLOB.astral_projections)
		to_chat(astral, "<span class='game say'><b>[speaker_name]</b> przekazuje: [span_cultlarge(raw_message)]</span>")

	for(var/mob/dead/observer/observer in GLOB.player_list)
		to_chat(observer, "<span class='game say'><b>[speaker_name]</b> przekazuje: [span_cultlarge(raw_message)]</span>")
	L.log_talk(raw_message, LOG_SAY, tag = "cult communication rune")

/obj/effect/cult_ritual/cult_communication/HasProximity(atom/movable/AM)
	if (!caster || caster.loc != loc)
		if (source)
			source.abort(RITUALABORT_GONE)
		qdel(src)
