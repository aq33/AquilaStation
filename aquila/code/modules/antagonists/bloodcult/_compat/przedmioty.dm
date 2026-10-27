// AQUILA - warstwa zgodności kultu krwi dla przedmiotów, struktur, efektów i pocisków (Cult 4 z Monkestation/vgstation).

// ---- kamień dusz: klejnot kultu jest „doskonały” (z draftu Monke, zmiana w soulstone.dm) ----

/obj/item/soulstone
	/// Klejnot dusz z ołtarza kultu tworzy doskonałe konstrukty
	var/perfect = FALSE

// ---- przejęcie ruchu przez /datum/control (draft zmieniał /client/proc/Move_object w core) ----

/client/Move_object(direct)
	var/datum/control/control = mob?.control_object
	if(istype(control))
		control.Move_object(direct)
		return
	return ..()

// ---- blokowanie szansą jak w tg (block_chance) na naszym hit_reaction ----

/// tg: przedmiot blokuje atak z szansą final_block_chance. U nas Bee blokuje poziomami (block_level), więc kult ma własną szansę.
/obj/item/proc/cult_chance_block(mob/living/carbon/human/owner, attack_text, final_block_chance)
	if(!prob(final_block_chance))
		return FALSE
	owner.visible_message(span_danger("[owner] blokuje [attack_text] za pomocą [src]!"))
	playsound(src, block_sound, 50, TRUE)
	return TRUE

// ---- obrót sprite'a pocisków rysowanych po skosie (tg/Monke: extra_rotation w projectile.dm) ----

/obj/item/projectile
	/// Kąt dodawany do obrotu sprite'a (pociski kultu rysowane po przekątnej)
	var/extra_rotation = 0

/// Nakłada extra_rotation na obrót sprite'a. Nasze setAngle/pixel_move ustawiają sam Angle.
/obj/item/projectile/proc/cult_apply_rotation()
	if(nondirectional_sprite || !extra_rotation)
		return
	var/matrix/rotation = new
	rotation.Turn(Angle + extra_rotation)
	transform = rotation

// ---- krew ----

/// tg: HAS_TRAIT(mob, TRAIT_NOBLOOD). U nas brak krwi to cecha gatunku NOBLOOD albo TRAIT_NO_BLOOD.
/mob/living/proc/cult_no_blood()
	return HAS_TRAIT(src, TRAIT_NO_BLOOD)

/mob/living/carbon/human/cult_no_blood()
	return ..() || (NOBLOOD in dna?.species?.species_traits)
