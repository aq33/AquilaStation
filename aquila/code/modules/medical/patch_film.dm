// AQUILA - a new chemical patch comes with a protective film. Use it in hand (Z) to peel the film off, only then it sticks.

/obj/item/reagent_containers/pill/patch
	/// The protective film is still on, the patch will not stick
	var/has_film = TRUE

/obj/item/reagent_containers/pill/patch/examine(mob/user)
	. = ..()
	if(has_film)
		. += "<span class='notice'>Ma jeszcze folię ochronną. Oderwij ją (Z), zanim go nakleisz.</span>"
	else
		. += "<span class='notice'>Folia ochronna jest oderwana, plaster jest gotowy do naklejenia.</span>"

/obj/item/reagent_containers/pill/patch/attack_self(mob/user)
	. = ..()
	if(!has_film)
		return
	peel_film(user)

/obj/item/reagent_containers/pill/patch/proc/peel_film(mob/user)
	has_film = FALSE
	playsound(src, 'sound/items/poster_ripped.ogg', 15, TRUE)
	if(user)
		to_chat(user, "<span class='notice'>Odrywasz folię ochronną z [src].</span>")

/obj/item/reagent_containers/pill/patch/attack(mob/living/L, mob/user, obj/item/bodypart/affecting)
	if(has_film)
		balloon_alert(user, "najpierw oderwij folię (Z)")
		return FALSE
	return ..()
