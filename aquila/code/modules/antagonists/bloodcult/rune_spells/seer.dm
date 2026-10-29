
/datum/rune_spell/seer
	name = "Jasnowidzenie"
	desc = "Pozwala widzieć niewidzialne, umarłych, ukryte oraz skłonność żywych do służenia naszej sprawie."
	desc_talisman = "Przez całą minutę pozwala widzieć niewidzialne, umarłych, ukryte oraz skłonność żywych do służenia naszej sprawie."
	invocation = "Rash'tla sektath mal'zua. Zasan therium viortia."
	rune_flags = RUNE_STAND
	talisman_uses = 10
	word1 = /datum/rune_word/see
	word2 = /datum/rune_word/hell
	word3 = /datum/rune_word/join
	page = "Ta runa pozwala widzieć niewidzialne duchy, runy i budowle, ale przede wszystkim pokazuje, czy członkowie załogi przyjmą konwersję. Wskazują to znaki nad ich głowami:\
		<br><br><b>Zielone znaki</b> to osoby, które zawsze przyjmą konwersję.\
		<br><br><b>Żółte znaki</b> to osoby, które mogą ją przyjąć albo odrzucić.\
		<br><br><b>Czerwone znaki z dwoma kolcami</b> to członkowie załogi z implantem lojalności, którzy odrzucą konwersję niezależnie od swojej woli.\
		<br><br><b>Czerwone znaki z trzema kolcami</b> to członkowie załogi, którzy poprzysięgli walczyć z kultem. Nie muszą automatycznie odrzucić konwersji, ale raczej nie wyrosną na przydatnych kultystów.\
		<br><br>Pamiętaj też, że możesz uruchamiać runy, gdy są ukryte. Talizman ma 10 użyć, każde trwa minutę. Uruchom talizman przed wejściem w publiczne miejsce, żeby nikt nie usłyszał szeptanej inkantacji.\
		<br><br>Ta runa zostaje po użyciu, można jej używać wielokrotnie."
	cost_invoke = 5
	var/obj/effect/cult_ritual/seer/seer_ritual = null
	var/talisman_duration = 60 SECONDS

/datum/rune_spell/seer/Destroy()
	destroying_self = 1
	if (seer_ritual && !seer_ritual.talisman)
		qdel(seer_ritual)
	seer_ritual = null
	return ..()

/datum/rune_spell/seer/cast()
	var/obj/effect/new_rune/R = spell_holder
	R.one_pulse()

	if (pay_blood())
		seer_ritual = new /obj/effect/cult_ritual/seer(R.loc, activator, src)
	else
		qdel(src)

/datum/rune_spell/seer/cast_talisman()
	var/mob/living/M = activator

	if (locate(/obj/effect/cult_ritual/seer) in M)
		var/obj/item/talisman/T = spell_holder
		T.uses++
		to_chat(M, span_warning("Wciąż działa na ciebie talizman Jasnowidzenia.") )
		qdel(src)
		return

	anim(target = M, a_icon = 'aquila/icons/bloodcult/160x160.dmi', a_icon_state = "rune_seer", lay = ABOVE_OBJ_LAYER, offX = -32*2, offY = -32*2, plane = GAME_PLANE, invis = INVISIBILITY_OBSERVER, alph = 200, sleeptime = talisman_duration, animate_movement = TRUE)
	new /obj/effect/cult_ritual/seer(activator, activator, null, TRUE, talisman_duration)
	qdel(src)

GLOBAL_LIST_EMPTY(seer_rituals)

/obj/effect/cult_ritual/seer
	anchored = 1
	icon = 'aquila/icons/bloodcult/160x160.dmi'
	icon_state = "rune_seer"
	pixel_x = -32*2
	pixel_y = -32*2
	alpha = 200
	invisibility = INVISIBILITY_OBSERVER
	layer = ABOVE_OBJ_LAYER
	plane = GAME_PLANE
	mouse_opacity = 0
	var/mob/living/caster = null
	var/datum/rune_spell/seer/source = null
	/// Znaki skłonności do konwersji, które widzi rzucający
	var/list/propension = list()
	var/talisman = FALSE
	///Proximity monitor associated with this atom, needed for proximity checks.
	var/datum/proximity_monitor/proximity_monitor

/obj/effect/cult_ritual/seer/New(turf/loc, mob/living/user, datum/rune_spell/seer/runespell, talisman_ritual = FALSE, talisman_duration = 60 SECONDS)
	..()
	talisman = talisman_ritual
	caster = user
	source = runespell
	if (!caster)
		if (source)
			source.abort(RITUALABORT_GONE)
		qdel(src)
		return
	proximity_monitor = new(src, 1)
	ADD_TRAIT(caster, TRAIT_SEER, REF(src))
	LAZYADD(GLOB.seer_rituals, src)
	// AQUILA - see_override zamiast see_invisible_override z vg (nasze update_sight nadpisuje see_invisible)
	caster.see_override = SEE_INVISIBLE_OBSERVER
	caster.update_sight()
	START_PROCESSING(SSobj, src)
	to_chat(caster, span_notice("Dostrzegasz szczeliny w zasłonie. Widzisz drugą stronę i możesz z nią oddziaływać, a także poznajesz skłonność załogi do konwersji: czy są <b><font color='green'>Chętni</font></b>, <b><font color='orange'>Niepewni</font></b>, czy <b><font color='red'>Nienawracalni</font></b>.") )
	if (talisman)
		QDEL_IN(src, talisman_duration)


/obj/effect/cult_ritual/seer/Destroy()
	STOP_PROCESSING(SSobj, src)
	QDEL_NULL(proximity_monitor)
	LAZYREMOVE(GLOB.seer_rituals, src)
	if(caster)
		clear_propension()
		REMOVE_TRAIT(caster, TRAIT_SEER, REF(src))
		to_chat(caster, span_notice("Nie potrafisz już przejrzeć zasłony."))
		caster.see_override = 0
		caster.update_sight()
	caster = null
	if (source)
		source.abort()
	source = null
	return ..()

/// AQUILA - w drafcie przez hovering_information z Monke, w vg zakomentowane process(). Znaki nad głowami załogi w zasięgu wzroku.
/obj/effect/cult_ritual/seer/process()
	if (!caster?.client)
		return
	clear_propension()
	for(var/mob/living/carbon/C in dview(world.view, get_turf(caster), INVISIBILITY_MAXIMUM))
		if (IS_CULTIST(C))
			continue
		propension += C.update_convertibility()
	caster.client.images |= propension

/obj/effect/cult_ritual/seer/proc/clear_propension()
	if (caster?.client)
		caster.client.images -= propension
	propension.Cut()

/obj/effect/cult_ritual/seer/HasProximity(atom/movable/AM)
	if (!talisman)
		if (!caster || caster.loc != loc)
			qdel(src)
