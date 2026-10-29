// AQUILA - zaklęcia doskonałego rzemieślnika (vg, draft Monke #3867) na naszym /datum/action/cooldown/spell.

/datum/action/cooldown/spell/pointed/conjure/hex
	name = "Przywołaj hex"
	desc = "Budujesz mniejszy konstrukt, który broni terenu."
	icon_icon = 'aquila/icons/bloodcult/spells.dmi'
	button_icon_state = "const_hex"
	button_icon = 'aquila/icons/bloodcult/spells.dmi'
	background_icon_state = "const_spell_base"

	cooldown_time = 2 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

	cast_range = 3
	cast_delay = 6 SECONDS
	summon_type = list(/mob/living/simple_animal/hostile/hex)

/datum/action/cooldown/spell/pointed/conjure/hex/post_summon(atom/summoned_object, atom/cast_on)
	var/mob/living/simple_animal/hostile/hex/AM = summoned_object
	var/mob/living/simple_animal/hostile/construct/builder/perfect/builder = owner
	if(!istype(AM) || !istype(builder))
		return
	AM.master = builder
	AM.no_master = FALSE
	builder.minions.Add(AM)
	AM.setupglow(builder.construct_color)
	if(length(builder.minions) >= 3)
		var/mob/living/simple_animal/hostile/hex/SA = builder.minions[1]
		builder.minions.Remove(SA)
		SA.master = null//The old hex will crumble on its own within the next 10 seconds.

	if(IS_CULTIST(builder))
		builder.DisplayUI("Cultist Right Panel")

	var/datum/antagonist/cult/cult_datum = builder.mind?.has_antag_datum(/datum/antagonist/cult)
	cult_datum?.gain_devotion(40, DEVOTION_TIER_2, "summon_hex", AM)

/datum/action/cooldown/spell/pointed/conjure/struct
	name = "Wznieś strukturę"
	desc = "Wznosisz strukturę kultu, której potem możesz używać: ołtarz, kuźnię albo iglicę."
	icon_icon = 'aquila/icons/bloodcult/spells.dmi'
	button_icon_state = "const_struct"
	button_icon = 'aquila/icons/bloodcult/spells.dmi'
	background_icon_state = "const_spell_base"

	cast_range = 4
	cast_delay = 12 SECONDS
	summon_type = list(/obj/structure/cult/altar)

	cooldown_time = 120 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

	var/structure

/datum/action/cooldown/spell/pointed/conjure/struct/PreActivate(atom/target)
	if(locate(/obj/structure/cult) in range(owner, 1))
		to_chat(owner, span_warning("Nie możesz odprawić tego rytuału tak blisko innej podobnej struktury."))
		return FALSE
	var/turf/T = owner.loc
	if(!istype(T))
		return FALSE
	var/list/choices = list(
		list("Altar", "radial_altar", "Pozwala tworzyć klejnoty dusz i odprawiać różne inne rytuały kultu."),
		list("Spire", "radial_spire", "Pozwala wszystkim kultystom na poziomie porozumiewać się przez :x"),
		list("Forge", "radial_forge", "Pozwala wykuwać ostrza i zbroje kultu oraz nowe powłoki konstruktów. Ogrzewa pobliskie istoty."),
	)

	var/list/made_choices = list()
	for(var/list/choice in choices)
		var/datum/radial_menu_choice/option = new
		option.image = image(icon = 'aquila/icons/bloodcult/cult_radial3.dmi', icon_state = choice[2])
		option.info = span_boldnotice(choice[3])
		made_choices[choice[1]] = option

	structure = show_radial_menu(owner, T, made_choices, tooltips = TRUE)
	if(!T.Adjacent(owner) || !structure)
		return FALSE
	switch(structure)
		if("Altar")
			summon_type = list(/obj/structure/cult/altar)
		if("Spire")
			summon_type = list(/obj/structure/cult/spire)
		if("Forge")
			summon_type = list(/obj/structure/cult/forge)
	return Activate(target)

/datum/action/cooldown/spell/pointed/conjure/struct/post_summon(atom/summoned_object, atom/cast_on)
	var/datum/antagonist/cult/cult_datum = owner?.mind?.has_antag_datum(/datum/antagonist/cult)
	cult_datum?.gain_devotion(10, DEVOTION_TIER_1, "raise_structure", structure)

/datum/action/cooldown/spell/pointed/conjure/pylon
	name = "Przywołaj pylon"
	desc = "Przywołujesz kruchy kryształ z królestwa Nar'Sie. Wygodne źródło światła albo słaba przeszkoda."
	icon_icon = 'aquila/icons/bloodcult/spells.dmi'
	button_icon_state = "const_pylon"
	button_icon = 'aquila/icons/bloodcult/spells.dmi'
	background_icon_state = "const_spell_base"

	cooldown_time = 60 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	cast_range = 4
	cast_delay = 10 SECONDS
	summon_type = list(/obj/structure/cult/pylon)

/datum/action/cooldown/spell/pointed/conjure/pylon/post_summon(atom/summoned_object, atom/cast_on)
	var/datum/antagonist/cult/cult_datum = owner?.mind?.has_antag_datum(/datum/antagonist/cult)
	cult_datum?.gain_devotion(10, DEVOTION_TIER_1, "raise_structure", "Pylon")

/datum/action/cooldown/spell/pointed/conjure/door
	name = "Przywołaj drzwi"
	desc = "Przywołujesz drzwi kultu. Same otwierają się i zamykają przed kultystą, konstruktem albo cieniem."
	icon_icon = 'aquila/icons/bloodcult/spells.dmi'
	button_icon_state = "const_door"
	button_icon = 'aquila/icons/bloodcult/spells.dmi'
	background_icon_state = "const_spell_base"
	cooldown_time = 25 SECONDS
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE
	cast_range = 1
	cast_delay = 4 SECONDS

	summon_type = list(/obj/machinery/door/airlock/cult)

/datum/action/cooldown/spell/pointed/conjure/door/conjure_animation(obj/effect/abstract/animation, turf/target)
	animation.icon_state = ""
	flick("", animation)
	shadow(target, owner.loc, "artificer_convert")
	QDEL_IN(animation, 1 SECONDS)

/datum/action/cooldown/spell/pointed/conjure/door/post_summon(atom/summoned_object, atom/cast_on)
	var/datum/antagonist/cult/cult_datum = owner?.mind?.has_antag_datum(/datum/antagonist/cult)
	cult_datum?.gain_devotion(10, DEVOTION_TIER_1, "summon_door", summoned_object)
