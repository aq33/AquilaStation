/*!
 * Contains Heretic grenades
 * They spread rust and obliterate borgs/mechs
 */

/obj/item/grenade/chem_grenade/rust_sower
	name = "rust sower"
	desc = "Sprytne cacko, które wybucha rdzą. Cyborgi i mechy zostają doszczętnie zniszczone."
	icon = 'aquila/icons/obj/weapons/grenade.dmi'
	icon_state = "rustgrenade"
	item_state = "flashbang"
	stage = GRENADE_READY
	det_time = 5 SECONDS

/obj/item/grenade/chem_grenade/rust_sower/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/large/beaker_one = new(src)
	var/obj/item/reagent_containers/glass/beaker/large/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/heretic_rust, 50)
	beaker_one.reagents.add_reagent(/datum/reagent/potassium, 50)
	beaker_two.reagents.add_reagent(/datum/reagent/phosphorus, 50)
	beaker_two.reagents.add_reagent(/datum/reagent/consumable/sugar, 50)

	beakers += beaker_one
	beakers += beaker_two

// Ikona zawsze ta sama (bez stanów obudowy)
/obj/item/grenade/chem_grenade/rust_sower/stage_change(N)
	if(N)
		stage = N
	name = initial(name)
	desc = initial(desc)
	icon_state = active ? "rustgrenade_active" : initial(icon_state)

// Nie da się rozkręcić ani przestawić (tg: tool_blocker na śrubokręt, klucz i multitool)
/obj/item/grenade/chem_grenade/rust_sower/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour in list(TOOL_SCREWDRIVER, TOOL_WRENCH, TOOL_MULTITOOL, TOOL_WIRECUTTER))
		to_chat(user, span_warning("[src] nie poddaje się [I]."))
		return
	return ..()

// Nie da się zmielić i wyciągnąć chemikaliów
/obj/item/grenade/chem_grenade/rust_sower/on_grind()
	return -1

/obj/item/grenade/chem_grenade/rust_sower/preprime(mob/user, delayoverride, msg = TRUE, volume = 60)
	. = ..()
	playsound(src, 'aquila/sound/items/weapons/rust_sower_armbomb.ogg', 70, FALSE)
	icon_state = "rustgrenade_active"

/obj/item/grenade/chem_grenade/rust_sower/prime(mob/living/lanced_by)
	var/turf/our_turf = get_turf(src)
	. = ..()
	playsound(our_turf, 'aquila/sound/items/weapons/rust_sower_explode.ogg', 70, FALSE)
	if(!QDELETED(src))
		qdel(src)

/datum/reagent/heretic_rust
	name = "Eldritch Rust"
	description = "Lepka, grudkowata, brązowa breja."
	color = "#A0522D" // Rust color
	taste_description = "zgniłą miedź"
	chem_flags = CHEMICAL_NOT_SYNTH

/datum/reagent/heretic_rust/reaction_obj(obj/O, volume)
	. = ..()
	if(ismecha(O))
		O.take_damage(300, BURN)

/datum/reagent/heretic_rust/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0, obj/item/bodypart/affecting)
	. = ..()
	if(!ishuman(M))
		if(issilicon(M) || isbot(M))
			M.adjust_brute_loss(500)
		return
	if(IS_HERETIC(M))
		return
	if(M.can_block_magic(MAGIC_RESISTANCE_HOLY))
		return

	var/mob/living/carbon/victim = M
	if(method == TOUCH || method == VAPOR)
		// you need both eye and mouth protection
		if(!victim.is_eyes_covered() || !victim.is_mouth_covered())
			if(prob(5))
				victim.emote("scream")
			victim.emote("cry")
			victim.set_eye_blur_if_lower(10 SECONDS)
			victim.adjust_temp_blindness(6 SECONDS)
			victim.set_confusion_if_lower(5 SECONDS)
			victim.Knockdown(3 SECONDS)
			victim.add_movespeed_modifier(MOVESPEED_ID_PEPPER_SPRAY, update = TRUE, priority = 100, multiplicative_slowdown = 0.25, blacklisted_movetypes = (FLYING|FLOATING))
			addtimer(CALLBACK(victim, TYPE_PROC_REF(/mob, remove_movespeed_modifier), MOVESPEED_ID_PEPPER_SPRAY), 10 SECONDS)
		victim.update_damage_hud()
		victim.adjust_disgust(5)
		for(var/obj/item/bodypart/robotic_limb as anything in victim.get_bodyparts())
			if(robotic_limb.bodytype & BODYTYPE_ROBOTIC)
				robotic_limb.receive_damage(5, 5)
	if(method == INGEST)
		if(!holder?.has_reagent(/datum/reagent/consumable/milk))
			if(prob(15))
				to_chat(M, span_danger("[pick("Głowa ci pęka.", "Usta płoną ci żywym ogniem.", "Kręci ci się w głowie.")]"))
			if(prob(10))
				victim.set_eye_blur_if_lower(2 SECONDS)
			if(prob(10))
				victim.set_dizzy_if_lower(2 SECONDS)
			if(prob(5))
				victim.vomit()

/datum/reagent/heretic_rust/reaction_turf(turf/T, volume)
	. = ..()
	T.rust_heretic_act(RUST_RESISTANCE_TITANIUM)

/datum/reagent/heretic_rust/on_mob_life(mob/living/carbon/M)
	if(!holder.has_reagent(/datum/reagent/consumable/milk))
		if(prob(5))
			M.visible_message(span_warning("[M] [pick("ma suche torsje!", "kaszle!", "krztusi się!")]"))
	return ..()
