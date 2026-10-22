// AQUILA - port z tgstation (code/datums/mutations/webbing.dm), na naszych pająkach z tg (aquila/code/game/objects/effects/spiderwebs.dm)

/datum/mutation/webbing
	name = "Webbing Production"
	desc = "The subject gains the ability to lay webbing, and travel through it."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Twoja skóra wydaje się pajęcza.</span>"
	instability = 25 // przydatne, dopóki cię nie zlinczują
	action_path = /datum/action/cooldown/spider/lay_web/genetic
	energy_coeff = 1
	mutation_traits = list(TRAIT_WEB_WEAVER)

/// Chromosom energii przyspiesza snucie zamiast skracać odnowienie
/datum/mutation/webbing/modify()
	. = ..()
	var/datum/action/cooldown/spider/lay_web/genetic/to_modify = action_power
	if(!istype(to_modify))
		return
	to_modify.cooldown_time = initial(to_modify.cooldown_time)
	to_modify.webbing_time = (GET_MUTATION_ENERGY(src) == 1) ? initial(to_modify.webbing_time) : 2 SECONDS

/// Sieć z genetyki: przechodzi przez nią bez problemu tylko twórca
/datum/action/cooldown/spider/lay_web/genetic
	desc = "Utkaj sieć. Tylko ty przejdziesz przez nią bez problemu."
	cooldown_time = 4 SECONDS

/datum/action/cooldown/spider/lay_web/genetic/plant_web(turf/target_turf, obj/structure/spider/stickyweb/existing_web)
	new /obj/structure/spider/stickyweb/genetic(target_turf, owner)

/obj/structure/spider/stickyweb/genetic
	desc = "Ciągnie się, klei i wyszło z twojego współpracownika."
	/// Kto przechodzi bez problemu
	var/datum/weakref/allowed_mob_ref

/obj/structure/spider/stickyweb/genetic/Initialize(mapload, mob/living/allowed_mob)
	allowed_mob_ref = WEAKREF(allowed_mob)
	. = ..()
	// Fioletowy odcień, żeby pająki nie dziwiły się, że tędy nie przejdą
	add_filter("web_colour_tint", 10, list("type" = "outline", "color" = "#ffaaf8ff", "size" = 0.1))

/obj/structure/spider/stickyweb/genetic/is_whitelisted(mob/living/candidate)
	return candidate == allowed_mob_ref?.resolve()

/// tg TRAIT_WEB_WEAVER: tkacz zwija sieć w tkaninę gołą ręką
/obj/structure/spider/stickyweb/attack_hand(mob/living/user, list/modifiers)
	if(!sealed && isliving(user) && HAS_TRAIT(user, TRAIT_WEB_WEAVER) && !user.combat_mode)
		INVOKE_ASYNC(src, PROC_REF(weave_cloth), user)
		return TRUE
	return ..()
