/obj/item/melee/cultblade
	name = "ostrze kultu"
	desc = "Tajemna broń dzierżona przez wyznawców Nar-Sie. U nasady obsydianowego ostrza ma zgrabne, okrągłe gniazdo."
	item_state = "cultblade"
	worn_icon_state = "cultblade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	icon = 'aquila/icons/bloodcult/cult.dmi'
	icon_state = "cultblade"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	w_class = WEIGHT_CLASS_BULKY
	force = 30
	throwforce = 10
	sharpness = SHARP_EDGED
	/// AQUILA - szansa bloku jak w tg (u nas Bee blokuje poziomami, patrz cult_chance_block)
	var/block_chance = 50 // now it's officially a cult esword
	hitsound = 'sound/weapons/bladeslice.ogg'
	block_sound = 'sound/weapons/parry.ogg'
	attack_verb = list("atakuje", "ciacha", "dźga", "kroi", "rozdziera", "szarpie", "rozrywa", "siecze", "rozpłatuje")

	var/checkcult = 1


/obj/item/melee/cultblade/salt_act()
	new /obj/item/melee/cultblade/nocult(loc)
	qdel(src)

/obj/item/melee/cultblade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 4 SECONDS, 100)

/obj/item/melee/cultblade/narsie_act()
	return

/obj/item/melee/cultblade/attack(mob/living/target, mob/living/carbon/human/user)
	if(!checkcult)
		return ..()
	if (IS_CULTIST(user))
		if (!IS_CULTIST(target) && target.stat != DEAD)
			var/datum/antagonist/cult/cult_datum = user.mind.has_antag_datum(/datum/antagonist/cult)
			if (target.mind)
				cult_datum.gain_devotion(30, DEVOTION_TIER_3, "attack_cultblade", target)
			else
				cult_datum.gain_devotion(30, DEVOTION_TIER_2, "attack_cultblade_nomind", target)
		if (ishuman(target) && target.resting)
			var/obj/structure/cult/altar/altar = locate() in target.loc
			if (altar)
				altar.attackby(src, user)
				return
			else
				return ..()
		else
			return ..()
	else
		user.Paralyze(0.5 SECONDS)
		user.dropItemToGround(src, TRUE)
		to_chat(user, span_warning("Niewytłumaczalna siła z mocą odpycha [src] od [target]!") )

/obj/item/melee/cultblade/pickup(mob/living/user)
	. = ..()
	if(checkcult && !IS_CULTIST(user))
		to_chat(user, span_warning("Gdy podnosisz [src], ogarnia cię przytłaczające uczucie grozy. Rozsądnie byłoby szybko się tego pozbyć.") )
		user.set_dizzy_if_lower(12 SECONDS)


/obj/item/melee/cultblade/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/soulstone/gem))
		var/turf/T = get_turf(user)
		playsound(T, 'sound/items/Deconstruct.ogg', 50, 1)
		user.dropItemToGround(src)
		var/obj/item/melee/soulblade/SB = new (T)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/item/melee/cultblade, give_soulblade), user, SB), 1)
		var/obj/item/soulstone/gem/sgem = I
		var/mob/living/simple_animal/shade/shadeMob = locate(/mob/living/simple_animal/shade) in sgem.contents
		if (shadeMob)
			shadeMob.forceMove(SB)
			SB.shade = shadeMob
			sgem.contents -= shadeMob
			if (shadeMob.mind)
				shadeMob.give_blade_powers()
			else
				to_chat(user, span_warning("Choć klejnot zdaje się więzić cień, ten najwyraźniej nie ma umysłu zdolnego władać ostrzem.") )
				to_chat(user, span_danger("(to błąd, zgłoś go i opisz dokładnie, skąd masz ten cień).") )
				message_admins("[key_name(usr)] somehow placed a soul gem containing a shade with no mind inside a soul blade.")
		SB.update_icon()
		qdel(sgem)
		qdel(src)
		return 1
	if(istype(I, /obj/item/soulstone))
		to_chat(user, span_warning("[I] nie pasuje do gniazda [src].") )
		return 1
	..()

/// AQUILA - spawn(1) z draftu jako timer
/obj/item/melee/cultblade/proc/give_soulblade(mob/user, obj/item/melee/soulblade/SB)
	if(QDELETED(SB) || QDELETED(user))
		return
	user.put_in_active_hand(SB)
	if (IS_CULTIST(user))
		SB.linked_cultist = user
		to_chat(SB.shade, span_notice("Nawiązujesz kontakt z [user]. Dopóki jesteś w promieniu 5 pól od tej osoby, możesz poruszać się sam bez utraty krwi i szybciej odnawiasz krew."))

/obj/item/melee/cultblade/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	if(cult_chance_block(owner, attack_text, block_chance))
		return TRUE
	return ..()


/obj/item/melee/cultblade/nocult
	name = "złamane ostrze kultu"
	desc = "To, co zostało z tajemnej broni wyznawców Nar-Sie. W tym stanie można ją trzymać w zasadzie bez ryzyka."
	icon_state = "cultblade-broken"
	checkcult = 0
	force = 15

/obj/item/melee/cultblade/nocult/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/talisman) || istype(I, /obj/item/paper))
		return 1
	..()


/obj/item/melee/cultblade/dagger
	name = "rytualny sztylet"
	desc = "Dziwny sztylet, którym podobno złowrogie grupy „przygotowują” zwłoki przed złożeniem ich w ofierze swoim mrocznym bogom."
	icon = 'aquila/icons/bloodcult/monke/obj/cult/items_and_weapons.dmi'
	icon_state = "render"
	item_state = "cultdagger"
	worn_icon_state = "render"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	w_class = WEIGHT_CLASS_SMALL
	force = 15
	throwforce = 25
	block_chance = 25
	armour_penetration = 35
	block_sound = 'sound/weapons/parry.ogg'

/obj/item/melee/cultblade/dagger/Initialize(mapload)
	. = ..()
	var/image/silicon_image = image(icon = 'icons/effects/blood.dmi', icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "cult_dagger", silicon_image)

	var/examine_text = {"Pozwala kreślić krwawe runy kultu Nar'Sie.
Uderzenie w strukturę kultu odkręca ją lub przykręca. Dźwigary kultu niszczy jednym ciosem.
Można nim zeskrobać krwawe runy, nie zostawiając śladu.
Uderzenie innego kultysty usuwa z niego całą wodę święconą i zmienia ją w nieświętą.
Uderzenie niekultysty rozrywa za to jego ciało."}

	AddComponent(/datum/component/cult_ritual_item, span_cult(examine_text))

/obj/item/melee/cultblade/dagger/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	var/final_block_chance = block_chance
	var/block_message = "[owner] paruje [attack_text] za pomocą [src]"
	if(owner.get_active_held_item() != src)
		block_message = "[owner] paruje [attack_text] za pomocą [src] trzymanego w drugiej ręce"

	if(IS_CULTIST(owner) && prob(final_block_chance) && attack_type != PROJECTILE_ATTACK)
		new /obj/effect/temp_visual/cult/sparks(get_turf(owner))
		owner.visible_message(span_danger("[block_message]"))
		return TRUE
	else
		return FALSE

/obj/item/melee/cultblade/ghost
	name = "nadprzyrodzony miecz"
	force = 19 //can't break normal airlocks
	item_flags = NEEDS_PERMIT | DROPDEL
	flags_1 = NONE
	block_chance = 25 //these dweebs don't get full block chance, because they're free cultists
	block_sound = 'sound/weapons/parry.ogg'

/obj/item/melee/cultblade/ghost/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CULT_TRAIT)

/obj/item/melee/cultblade/pickup(mob/living/user)
	..()
	if(!IS_CULTIST(user))
		to_chat(user, span_cultlarge("\"Nie radziłbym.\""))

/datum/action/innate/dash/cult
	name = "Rozedrzyj Zasłonę"
	desc = "Przetnij mieczem kruchą tkankę rzeczywistości i teleportuj się do celu."
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "phaseshift"
	dash_sound = 'sound/magic/enter_blood.ogg'
	recharge_sound = 'sound/magic/exit_blood.ogg'
	beam_effect = "sendbeam"
	phasein = /obj/effect/temp_visual/dir_setting/cult/phase
	phaseout = /obj/effect/temp_visual/dir_setting/cult/phase/out

/datum/action/innate/dash/cult/IsAvailable()
	if(IS_CULTIST(owner) && current_charges)
		return TRUE
	else
		return FALSE


/obj/item/melee/cultblade/halberd
	name = "krwawa halabarda"
	desc = "Halabarda z niestabilnym ostrzem z krystalicznej krwi. Wydaje się związana ze swoim twórcą. I, prawdę mówiąc, to bardziej topór bojowy niż halabarda."
	icon = 'aquila/icons/bloodcult/monke/obj/cult/items_and_weapons.dmi'
	icon_state = "occultpoleaxe0"
	base_icon_state = "occultpoleaxe"
	item_state = "occultpoleaxe0"
	w_class = WEIGHT_CLASS_HUGE
	force = 17
	throwforce = 40
	throw_speed = 2
	armour_penetration = 30
	block_chance = 30
	slot_flags = null
	attack_verb = list("atakuje", "kroi", "szatkuje", "rozłupuje", "szarpie", "rozcina")
	sharpness = SHARP_EDGED
	hitsound = 'sound/weapons/bladeslice.ogg'
	block_sound = 'sound/weapons/parry.ogg'
	var/datum/action/innate/cult/halberd/halberd_act
	/// AQUILA - u nas nie ma TRAIT_WIELDED, chwyt oburęczny śledzimy sygnałami komponentu two_handed
	var/wielded = FALSE

/obj/item/melee/cultblade/halberd/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 10 SECONDS, 90)
	AddComponent(/datum/component/two_handed, \
		force_unwielded = 17, \
		force_wielded = 24, \
	)
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, PROC_REF(on_wield))
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, PROC_REF(on_unwield))

/obj/item/melee/cultblade/halberd/proc/on_wield(obj/item/source, mob/user)
	SIGNAL_HANDLER
	wielded = TRUE
	update_icon()

/obj/item/melee/cultblade/halberd/proc/on_unwield(obj/item/source, mob/user)
	SIGNAL_HANDLER
	wielded = FALSE
	update_icon()

/obj/item/melee/cultblade/halberd/update_icon_state()
	icon_state = wielded ? "[base_icon_state]1" : "[base_icon_state]0"
	item_state = wielded ? "[base_icon_state]1" : "[base_icon_state]0"
	return ..()

/obj/item/melee/cultblade/halberd/Destroy()
	if(halberd_act)
		QDEL_NULL(halberd_act)
	return ..()

/obj/item/melee/cultblade/halberd/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/turf/T = get_turf(hit_atom)
	if(isliving(hit_atom))
		var/mob/living/target = hit_atom

		if(IS_CULTIST(target) && target.put_in_active_hand(src))
			playsound(src, 'sound/weapons/throwtap.ogg', 50)
			target.visible_message(span_warning("[target] chwyta [src] w locie!"))
			return
		if(target.can_block_magic() || IS_CULTIST(target))
			target.visible_message(span_warning("[src] odbija się od [target], jakby odepchnięta niewidzialną siłą!"))
			return
		if(!..())
			target.Paralyze(50)
			break_halberd(T)
	else
		..()

/obj/item/melee/cultblade/halberd/proc/break_halberd(turf/T)
	if(src)
		if(!T)
			T = get_turf(src)
		if(T)
			T.visible_message(span_warning("[src] roztrzaskuje się i rozpływa z powrotem w krew!"))
			new /obj/effect/temp_visual/cult/sparks(T)
			new /obj/effect/decal/cleanable/blood/splatter(T)
			playsound(T, 'sound/effects/glassbr3.ogg', 100)
	qdel(src)

/obj/item/melee/cultblade/halberd/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	var/final_block_chance = block_chance
	if(wielded)
		final_block_chance *= 2
	if(IS_CULTIST(owner) && prob(final_block_chance))
		owner.visible_message(span_danger("[owner] paruje [attack_text] za pomocą [src]!"))
		new /obj/effect/temp_visual/cult/sparks(get_turf(owner))
		return TRUE
	else
		return FALSE

/datum/action/innate/cult/halberd
	name = "Krwawa Więź"
	desc = "Przywołaj krwawą halabardę z powrotem do ręki!"
	background_icon_state = "bg_demon"
	icon_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "bloodspear"
	var/obj/item/melee/cultblade/halberd/halberd
	var/cooldown = 0

/datum/action/innate/cult/halberd/Grant(mob/user, obj/blood_halberd)
	. = ..()
	halberd = blood_halberd

/datum/action/innate/cult/halberd/Activate()
	if(owner == halberd.loc || cooldown > world.time)
		return
	var/halberd_location = get_turf(halberd)
	var/owner_location = get_turf(owner)
	if(get_dist(owner_location, halberd_location) > 10)
		to_chat(owner,span_cult("Halabarda jest za daleko!"))
	else
		cooldown = world.time + 20
		if(isliving(halberd.loc))
			var/mob/living/current_owner = halberd.loc
			current_owner.dropItemToGround(halberd)
			current_owner.visible_message(span_warning("Niewidzialna siła wyrywa krwawą halabardę z rąk [current_owner]!"))
		halberd.throw_at(owner, 10, 2, owner)
