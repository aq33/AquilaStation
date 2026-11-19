// AQUILA - szyny i kule (AquilaMed 5).
// Szyna: pomysł i sprite'y z Baystation12 (code/game/objects/items/stacks/medical.dm, icons/obj/medical.dmi, CC-BY-SA 3.0).
// U nas bandaż już unieruchamia złamanie (wounds/blunt.dm). Szyna robi to lepiej: broń nie wypada z ręki, utykanie
// spada o połowę względem bandaża, boli mniej, a kiedy kość się zrośnie, szyna spada i da się jej użyć jeszcze raz.
// Prowizoryczna szyna (deski i taśma) unieruchamia tylko jak bandaż.
// Złamana noga bez bandaża, szyny i kuli czasem ugina się przy chodzeniu (jak w Bay).
// Kula: sprite'y z tgstation (icons/obj/weapons/staff.dmi, CC-BY-SA 3.0). Trzymana w ręce zmniejsza o połowę spowolnienie
// od ran nóg (dwie kule do jednej czwartej), chroni przed upadkiem na złamanej nodze i przed podcięciem nogi
// przy stłuczonym kręgosłupie. Przy złamanym kręgosłupie nie pomaga, nogi są sparaliżowane.

/// Splinted fractures lose this part of the treated limp
#define AQ_SPLINT_LIMP_MULT 0.5
/// Splinted fractures hurt this much of a bandaged one
#define AQ_SPLINT_PAIN_MULT 0.6
/// Chance per step that an untreated broken leg gives way, fracture and compound fracture; halved while walking
#define AQ_BROKEN_LEG_FALL_CHANCE 3
#define AQ_BROKEN_LEG_FALL_CHANCE_COMPOUND 6

/obj/item/stack/medical/splint
	name = "szyna"
	singular_name = "szyna"
	desc = "Modułowa szyna, która mocno unieruchamia złamaną kończynę: kość się nie przesuwa, mniej boli, a ręka nie upuszcza broni. Nie leczy, a kiedy kość się zrośnie, szynę da się założyć jeszcze raz."
	icon = 'aquila/icons/obj/medical/medycyna5.dmi'
	icon_state = "splint"
	amount = 5
	max_amount = 5
	novariants = TRUE
	w_class = WEIGHT_CLASS_SMALL
	full_w_class = WEIGHT_CLASS_SMALL
	self_delay = 6 SECONDS
	/// A real splint: no dropping, half the treated limp, less pain, falls off when the bone heals. FALSE works like a bandage.
	var/proper = TRUE

/obj/item/stack/medical/splint/one
	amount = 1

/obj/item/stack/medical/splint/improvised
	name = "prowizoryczna szyna"
	singular_name = "prowizoryczna szyna"
	desc = "Deski przywiązane taśmą. Unieruchomi złamaną kończynę tak jak bandaż, ale nic poza tym."
	icon_state = "tape-splint"
	amount = 1
	max_amount = 3
	resistance_flags = FLAMMABLE
	proper = FALSE

/// Szyna nie leczy obrażeń: bez złamania do unieruchomienia nic nie robi
/obj/item/stack/medical/splint/attack(mob/living/M, mob/user)
	if(iscarbon(M) && try_treat_wound(M, user))
		return
	to_chat(user, "<span class='warning'>Tu nie ma złamania, które [src] mogłaby unieruchomić.</span>")

/datum/crafting_recipe/improvised_splint
	name = "prowizoryczna szyna"
	result = /obj/item/stack/medical/splint/improvised
	time = 4 SECONDS
	reqs = list(/obj/item/stack/sheet/mineral/wood = 2, /obj/item/stack/sticky_tape = 2)
	category = CAT_MISC

// --- Szyna na złamaniu (wounds/blunt.dm) ---

/datum/wound/blunt/proc/apply_splint(obj/item/stack/medical/splint/splint, mob/user)
	var/self = user == victim
	user.visible_message("<span class='notice'>[user] zaczyna zakładać [splint.singular_name] na [limb.name] [victim].</span>", "<span class='notice'>Zaczynasz zakładać [splint.singular_name] na [limb.name] [self ? "" : "[victim]"].</span>")
	if(!do_mob(user, victim, self ? splint.self_delay : 3 SECONDS))
		return FALSE
	if(QDELETED(src) || splinted || (treated && !splint.proper) || !splint.use(1))
		return FALSE
	treated = TRUE
	splinted = splint.proper
	victim.update_wound_slowdown()
	victim.aq_medical_overlays_changed()
	user.visible_message("<span class='green'>[user] zakłada [splint.singular_name] na [limb.name] [victim].</span>", "<span class='green'>Zakładasz [splint.singular_name] na [limb.name] [self ? "" : "[victim]"].</span>")
	return TRUE

/datum/wound/blunt/get_limp_slowdown()
	. = ..()
	if(splinted)
		. *= AQ_SPLINT_LIMP_MULT

/datum/wound/blunt/get_pain()
	. = ..()
	if(splinted)
		. *= AQ_SPLINT_PAIN_MULT

/datum/wound/blunt/get_scan_status()
	if(splinted)
		return heal_time ? " (w szynie, goi się)" : " (w szynie, wymaga operacji)"
	return ..()

/datum/wound/blunt/apply_wound(obj/item/bodypart/new_limb, silent = FALSE)
	. = ..()
	if(severity >= WOUND_SEVERITY_SEVERE && (limb.body_zone == BODY_ZONE_L_LEG || limb.body_zone == BODY_ZONE_R_LEG))
		RegisterSignal(victim, COMSIG_MOVABLE_MOVED, PROC_REF(aq_on_victim_moved))

/// A fracture that gets worse or better keeps its splint: it moves to the new wound instead of falling off
/datum/wound/blunt/aq_before_replace()
	if(!splinted)
		return
	aq_splint_moving = TRUE
	aq_splint_drop = victim && isturf(victim.loc) ? victim.drop_location() : null
	splinted = FALSE // Destroy does not drop it, the new wound gets it

/datum/wound/blunt/aq_after_replace(datum/wound/replacement)
	if(!aq_splint_moving)
		return
	var/datum/wound/blunt/fracture = replacement
	if(istype(fracture))
		fracture.splinted = TRUE
		fracture.treated = TRUE // szyna zawsze opatruje złamanie (apply_splint)
		fracture.victim?.update_wound_slowdown()
	else if(aq_splint_drop) // healed into nothing that holds a splint
		new /obj/item/stack/medical/splint/one(aq_splint_drop)
	aq_splint_drop = null

/datum/wound/blunt/Destroy()
	if(victim)
		UnregisterSignal(victim, COMSIG_MOVABLE_MOVED)
		if(splinted && !QDELETED(victim) && isturf(victim.loc))
			new /obj/item/stack/medical/splint/one(victim.drop_location())
			to_chat(victim, "<span class='notice'>Szyna zsuwa się z [limb ? limb.name : "kończyny"].</span>")
	return ..()

/// An untreated broken leg can give way under the victim
/datum/wound/blunt/proc/aq_on_victim_moved(datum/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	if(forced || treated || !isturf(victim.loc) || victim.buckled || victim.stat != CONSCIOUS || !(victim.mobility_flags & MOBILITY_STAND))
		return
	if((victim.movement_type & (FLYING | FLOATING)) || victim.aq_walking_aids())
		return
	var/chance = severity >= WOUND_SEVERITY_CRITICAL ? AQ_BROKEN_LEG_FALL_CHANCE_COMPOUND : AQ_BROKEN_LEG_FALL_CHANCE
	if(victim.m_intent == MOVE_INTENT_WALK)
		chance /= 2
	if(!prob(chance))
		return
	victim.Knockdown(2 SECONDS)
	victim.visible_message("<span class='danger'>[victim] przewraca się, bo złamana noga ugina się pod ciężarem!</span>", "<span class='userdanger'>[capitalize(limb.name)] ugina się pod tobą! Złamaną nogę trzeba unieruchomić albo podeprzeć kulą.</span>")
	INVOKE_ASYNC(victim, TYPE_PROC_REF(/mob, emote), "scream")

// --- Kule ---

/obj/item/cane/crutch
	name = "kula medyczna"
	desc = "Kula dla kogoś ze złamaną nogą albo stłuczonym kręgosłupem: mniej utykania i żadnych upadków, ale zajęta ręka. Przy dwóch kulach idzie się jeszcze sprawniej."
	icon = 'aquila/icons/obj/medical/medycyna5.dmi'
	icon_state = "crutch_med"
	item_state = "crutch_med"
	lefthand_file = 'aquila/icons/mob/inhands/equipment/medycyna5_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/equipment/medycyna5_righthand.dmi'
	force = 12
	throwforce = 8
	w_class = WEIGHT_CLASS_BULKY
	custom_materials = list(/datum/material/iron = 100)

/obj/item/cane/crutch/wood
	name = "drewniana kula"
	desc = "Ręcznie zrobiona kula. Podeprze złamaną nogę, a w razie czego posłuży za pałkę."
	icon_state = "crutch_wood"
	item_state = "crutch_wood"
	custom_materials = list(/datum/material/wood = 10000)

/obj/item/cane/crutch/equipped(mob/user, slot)
	. = ..()
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		carbon_user.update_wound_slowdown()

/obj/item/cane/crutch/dropped(mob/user, silent)
	. = ..()
	if(iscarbon(user))
		var/mob/living/carbon/carbon_user = user
		addtimer(CALLBACK(carbon_user, TYPE_PROC_REF(/mob/living/carbon, update_wound_slowdown)), 0) // po wyjęciu z rąk


/datum/crafting_recipe/wooden_crutch
	name = "drewniana kula"
	result = /obj/item/cane/crutch/wood
	time = 8 SECONDS
	reqs = list(/obj/item/stack/sheet/mineral/wood = 5)
	tools = list(TOOL_SAW)
	category = CAT_MISC

/// Crutches held in hands
/mob/living/carbon/proc/aq_walking_aids()
	. = 0
	for(var/obj/item/cane/crutch/crutch in held_items)
		.++

/// Leg wound slowdown multiplier from crutches: one halves it, two quarter it
/mob/living/carbon/proc/aq_walking_aid_mult()
	switch(aq_walking_aids())
		if(0)
			return 1
		if(1)
			return 0.5
	return 0.25

#undef AQ_SPLINT_LIMP_MULT
#undef AQ_SPLINT_PAIN_MULT
#undef AQ_BROKEN_LEG_FALL_CHANCE
#undef AQ_BROKEN_LEG_FALL_CHANCE_COMPOUND
