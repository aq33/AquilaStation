/////////////////////////////
//                          //
//    SELF TELEKINESIS      ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //
//////////////////////////////Not a real spell, but informs the player that moving consums blood.

/datum/action/cooldown/spell/pointed/soulblade
	icon_icon = 'aquila/icons/bloodcult/spells.dmi'
	button_icon = 'aquila/icons/bloodcult/spells.dmi'
	background_icon_state = "const_spell_base"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	var/blood_cost = 0

// AQUILA: w drafcie ścieżka miała literówkę (soulblade/soulblade) i koszt krwi nie był sprawdzany
/datum/action/cooldown/spell/pointed/soulblade/PreActivate(atom/target)
	var/obj/item/melee/soulblade/SB = owner.loc
	if(!istype(SB))
		return FALSE
	if (SB.blood < blood_cost)
		to_chat(owner, span_danger("Nie masz już dość krwi na ten ruch.") )
		return FALSE
	return ..()

/datum/action/cooldown/spell/pointed/soulblade/is_valid_target(atom/cast_on)
	return TRUE

/datum/action/cooldown/spell/pointed/soulblade/after_cast(atom/cast_on)
	..()
	var/obj/item/melee/soulblade/SB = owner.loc
	if(istype(SB))
		SB.blood = max(0, SB.blood-blood_cost)
	var/mob/shade = owner
	shade.DisplayUI("Soulblade")


/datum/action/cooldown/spell/pointed/soulblade/blade_kinesis
	name = "Telekineza"
	desc = "(1 KRWI) Poruszasz się sam, bez potrzeby trzymania cię przez kogoś."
	button_icon_state = "souldblade_move"



//////////////////////////////Basic attack
//                          //Can be used by clicking anywhere on the screen for convenience
//        SPIN SLASH        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //Attackes EVERY (almost) atoms on your turf, and the one in the direction you're facing.
//////////////////////////////That means unexpected behaviours are likely, for instance you can open doors, harvest meat off dead animals, or break important stuff

/datum/action/cooldown/spell/pointed/soulblade/blade_spin
	name = "Cięcie z obrotu"
	desc = "(5 KRWI) Zatrzymujesz rozpęd i tniesz przed sobą."
	button_icon_state = "soulblade_spin"

	blood_cost = 5
	COOLDOWN_DECLARE(spin_cooldown) //gotta use that to get a more strict cooldown at such a small value

/datum/action/cooldown/spell/pointed/soulblade/blade_spin/PreActivate(atom/target)
	. = ..()
	if(!COOLDOWN_FINISHED(src, spin_cooldown))
		return

/datum/action/cooldown/spell/pointed/soulblade/blade_spin/cast(atom/cast_on)
	..()
	if(!COOLDOWN_FINISHED(src, spin_cooldown))
		return
	COOLDOWN_START(src, spin_cooldown, 1 SECONDS)
	var/obj/item/melee/soulblade/SB = owner.loc
	if(!istype(SB))
		return
	var/turf/source_turf = SB.loc
	SB.reflector = TRUE

	addtimer(VARSET_CALLBACK(SB, reflector, FALSE), 0.4 SECONDS)
	SB.throwing = FALSE

	if (istype(SB.loc, /obj/item/projectile))
		var/obj/item/projectile/P = SB.loc
		qdel(P)
	var/obj/structure/cult/altar/altar = cast_on
	var/turf/step_turf = get_step(source_turf, SB.dir)
	if (istype(altar))
		altar.attackby(SB, owner)
		return//gotta make sure we're not gonna bug ourselves out of the altar if there's one by hitting a table or something.
	flick("soulblade-spin", SB)
	for(var/atom/listed in source_turf.contents)
		if(listed == SB)
			continue

		listed.attackby(SB, owner)
	for(var/atom/listed in step_turf.contents)
		if(listed == SB)
			continue
		listed.attackby(SB, owner)

//////////////////////////////Puts the blade inside a bullet that shoots forward.
//                          //Can be used by drag n dropping from turf A to turf B. Will cause the bullet to fire first toward A then change direction toward B
//        PERFORATE         ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //You need to hit at least two living mobs to make up for the cost of using this spell
//////////////////////////////The blade moves much faster from A to B than from starting to A

/datum/action/cooldown/spell/pointed/soulblade/blade_perforate
	name = "Przeszycie"
	desc = "(20 KRWI) Ciskasz się w powietrze. Zaklęcie można też rzucić, przeciągając myszą z pola na pole, by uzyskać ciekawszy tor lotu. Jeśli trafisz kultystę, automatycznie cię złapie."
	button_icon_state = "soulblade_perforate"

	blood_cost = 20

/datum/action/cooldown/spell/pointed/soulblade/blade_perforate/cast(atom/cast_on)
	..()
	perforate(cast_on)

/// Wystrzał ostrza: najpierw w stronę cast_on, potem (przy przeciąganiu myszą) w stronę second_cast
/datum/action/cooldown/spell/pointed/soulblade/blade_perforate/proc/perforate(atom/cast_on, atom/second_cast)
	var/obj/item/melee/soulblade/blade = owner.loc
	if(!istype(blade))
		return
	if (istype(blade.loc, /obj/item/projectile))
		var/obj/item/projectile/P = blade.loc
		qdel(P)
	var/turf/starting = get_turf(blade)
	var/turf/target = cast_on
	var/obj/item/projectile/soulbullet/soul_bullet = new (starting)
	soul_bullet.preparePixelProjectile(target, starting)
	soul_bullet.secondary_target = second_cast
	soul_bullet.shade = owner
	soul_bullet.blade = blade
	blade.forceMove(soul_bullet)
	soul_bullet.fire()
	soul_bullet.process()


/client/MouseDrop(src_object, over_object, src_location, over_location, src_control, over_control, params)
	if(!mob || !isshade(mob) || !istype(mob.loc, /obj/item/melee/soulblade))
		return ..()
	var/obj/item/melee/soulblade/SB = mob.loc
	var/turf/from_turf = get_turf(src_object)
	var/turf/to_turf = get_turf(over_object)
	if(!from_turf || !to_turf || from_turf == to_turf)
		return ..()
	var/datum/action/cooldown/spell/pointed/soulblade/blade_perforate/BP = locate() in mob.actions
	if (BP && isturf(SB.loc) && BP.IsAvailable() && SB.blood >= BP.blood_cost)
		BP.perforate(from_turf, to_turf)
		BP.StartCooldown()
		SB.blood = max(0, SB.blood - BP.blood_cost)


//////////////////////////////
//                          //Spend 10 blood -> Heal 10 brute damage on your wielder and clamp their bleeding wounds. Good trade, yes?
//        MEND              ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //
//////////////////////////////

/datum/action/cooldown/spell/pointed/soulblade/blade_mend
	name = "Opatrzenie"
	desc = "(10 KRWI) Leczysz część obrażeń fizycznych swojego właściciela kosztem swojej krwi."
	button_icon_state = "soulblade_mend"

	blood_cost = 10

/datum/action/cooldown/spell/pointed/soulblade/blade_mend/cast(atom/cast_on)
	..()
	var/obj/item/melee/soulblade/SB = owner.loc
	var/mob/living/wielder = SB?.loc
	if(!isliving(wielder))
		return
	if(iscarbon(wielder))
		var/mob/living/carbon/C = wielder
		C.cauterise_wounds() // u nas krwawienie to jeden status, nie rany tg

	//playsound(wielder.loc, 'sound/magic/staff_healing.ogg', 50, 0, -2)
	wielder.adjustBruteLoss(-10)
	to_chat(owner, "Leczysz część ran swojego właściciela.")
	to_chat(wielder, "[owner] leczy część twoich ran.")


//////////////////////////////
//                          //
//    TOGGLE BLADE HARM     ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //
//////////////////////////////

/datum/action/cooldown/spell/pointed/soulblade/blade_harm
	name = "Krzywda dla obcych"
	desc = "(ZA DARMO) Decydujesz, czy pozwalasz używać się osobom, które nie są kultystami ani tym, kto cię schwytał."
	button_icon_state = "soulblade_harm"

/datum/action/cooldown/spell/pointed/soulblade/blade_harm/cast(atom/cast_on)
	. = ..()
	var/mob/living/simple_animal/shade/user = owner
	if (istype(user))
		if (user.blade_harm)
			user.blade_harm = FALSE
			button_icon_state = "soulblade_calm"
			to_chat(user, span_notice("Pozwalasz teraz każdemu się używać.") )
		else
			user.blade_harm = TRUE
			button_icon_state = "soulblade_harm"
			to_chat(user, span_notice("Teraz ranisz i oszałamiasz nicponi, którzy próbują cię używać.") )

		var/obj/item/melee/soulblade/SB = user.loc
		if (istype(SB))
			var/mob/living/M = SB.loc//bloke holding the blade
			if (istype(M) && !IS_CULTIST(M) && (user.master != M))
				if (user.blade_harm)
					M.adjust_dizzy(120)
					to_chat(M, span_warning("Przechodzi cię dreszcz, gdy mordercze zamiary [SB] nagle zwracają się przeciwko tobie.") )
				else
					M.adjust_dizzy(-120)
					to_chat(M, span_notice("Energia bijąca od [SB] nieco słabnie i możesz go używać.") )
