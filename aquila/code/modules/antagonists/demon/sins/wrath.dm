/obj/effect/proc_holder/spell/targeted/shapeshift/demon/wrath //emergency get out of jail card, but better.
	name = "Postać demona gniewu"
	shapeshift_type = /mob/living/simple_animal/lesserdemon/wrath

/mob/living/simple_animal/lesserdemon/wrath //slightly more damage.
	name = "demon gniewu"
	real_name = "demon gniewu"
	melee_damage = 24
	icon_state = "lesserdaemon_wrath"
	icon_living = "lesserdaemon_wrath"

/obj/effect/proc_holder/spell/targeted/inflict_handler/ignite
	name = "Podpal"
	desc = "To zaklęcie podpala człowieka z odległości."
	school = "transmutation"
	invocation = "PŁOŃ!!"
	invocation_type = "shout"
	charge_max = 600
	clothes_req = FALSE
	action_icon = 'aquila/icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "ignite"
	action_background_icon_state = "bg_demon"
	amt_firestacks = 5
	ignites = TRUE
	sound = 'sound/magic/fireball.ogg'

/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/sin/wrath
	name = "Większe demoniczne przejście"
	desc = "Na chwilę obracasz się w żar i popiół, więc swobodnie przenikasz przez obiekty. Trwa nieco krócej niż zwykle, ale łatwiej go użyć."
	charge_max = 25 SECONDS
	cooldown_min = 25 SECONDS
	jaunt_duration = 2 SECONDS
	jaunt_in_time = 0
