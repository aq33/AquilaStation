// AQUILA - zmiany cienia z kultu „Cult 4” (Monkestation/Monkestation2.0#3867, vgstation) nałożone na naszego
// /mob/living/simple_animal/shade z code/modules/mob/living/simple_animal/shade.dm: sprite z vg, ostrze dusz
// (soulblade: moce, regeneracja krwi), powrót do ciała po śmierci (cień z rytuału reinkarnacji / projekcji).

/mob/living/simple_animal/shade
	icon = 'aquila/icons/bloodcult/mob.dmi'
	icon_state = "shade"
	icon_living = "shade"
	/// Cień powstał z rytuału ostrza dusz (samobójstwo na ostrzu)
	var/soulblade_ritual = FALSE
	/// Ostrze rani i oszałamia niekultystów, którzy próbują go używać
	var/blade_harm = TRUE
	/// Kto schwytał cienia (właściciel ostrza dusz)
	var/mob/master = null
	/// Ciało, do którego cień wraca po śmierci
	var/mob/living/carbon/human/body

/mob/living/simple_animal/shade/Destroy()
	master = null
	body = null
	return ..()

/mob/living/simple_animal/shade/death(gibbed)
	if(body && !QDELETED(body))
		body.forceMove(get_turf(src))
		mind?.transfer_to(body)
	return ..()

/mob/living/simple_animal/shade/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/melee/soulblade))
		var/obj/item/melee/soulblade/blade = O
		blade.capture_shade(src, user)
		return
	return ..()

/mob/living/simple_animal/shade/Life(seconds, times_fired)
	. = ..()
	if(!istype(loc, /obj/item/melee/soulblade))
		return
	var/obj/item/melee/soulblade/SB = loc
	if(istype(SB.loc, /obj/structure/cult/altar))
		if(SB.blood < SB.maxblood)
			SB.blood = min(SB.maxblood, SB.blood+10)//fastest blood regen when planted on an altar
		if(SB.obj_integrity < SB.max_integrity)
			SB.obj_integrity = min(SB.max_integrity, SB.obj_integrity+10)//and health regen on top
	else if(isliving(SB.loc))
		var/mob/living/L = SB.loc
		if(IS_CULTIST(L) && SB.blood < SB.maxblood)
			SB.blood = min(SB.maxblood, SB.blood+3)//fast blood regen when held by a cultist (stacks with the one below for an effective +5)
	if(SB.linked_cultist && (get_dist(get_turf(SB.linked_cultist), get_turf(src)) <= 5))
		SB.blood = min(SB.maxblood, SB.blood+2)//slow blood regen when near your linked cultist
	if(SB.passivebloodregen < (SB.blood/3))
		SB.passivebloodregen++
	if((SB.passivebloodregen >= (SB.blood/3)) && (SB.blood < SB.maxblood))
		SB.passivebloodregen = 0
		SB.blood++//very slow passive blood regen that goes slower and slower the more blood you currently have.
	SB.update_icon()

/mob/living/simple_animal/shade/ClickOn(atom/A, params)
	// Celowanie zaklęciem (np. Perforate) nie może jednocześnie ciąć
	var/had_intercept = !!click_intercept
	. = ..()
	if(had_intercept || !istype(loc, /obj/item/melee/soulblade))
		return
	var/obj/item/melee/soulblade/SB = loc
	SB.setDir(get_dir(get_turf(SB), A))
	var/datum/action/cooldown/spell/pointed/soulblade/blade_spin/BS = locate() in actions
	if(BS && BS.IsAvailable())
		BS.Activate(A)

//Giving the spells
/mob/living/simple_animal/shade/proc/give_blade_powers()
	if(!istype(loc, /obj/item/melee/soulblade))
		return
	DisplayUI("Soulblade")

	var/obj/item/melee/soulblade/SB = loc
	var/datum/control/new_control = new /datum/control/soulblade(src, SB)
	control_object = new_control
	new_control.take_control()

	grant_actions_by_list(list(
		/datum/action/cooldown/spell/pointed/soulblade/blade_kinesis,
		/datum/action/cooldown/spell/pointed/soulblade/blade_spin,
		/datum/action/cooldown/spell/pointed/soulblade/blade_perforate,
		/datum/action/cooldown/spell/pointed/soulblade/blade_mend,
		/datum/action/cooldown/spell/pointed/soulblade/blade_harm,
	))

//Removing the spells, this should always fire when the shade gets removed from the blade, such as when it gets destroyed
/mob/living/simple_animal/shade/proc/remove_blade_powers()
	HideUI("Soulblade")
	if(istype(control_object, /datum/control))
		qdel(control_object)
	control_object = null
	for(var/datum/action/cooldown/spell/pointed/soulblade/spell_to_remove in actions)
		qdel(spell_to_remove)

/mob/living/simple_animal/shade/proc/add_HUD(mob/user)
	DisplayUI("Soulblade")
