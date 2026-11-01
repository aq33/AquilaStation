/// Dragging sounds for closets, body bags and cardboard boxes (body bags also play the closet sound through ..())
/obj/structure/closet/Moved(atom/OldLoc, Dir)
	. = ..()
	if(has_gravity())
		playsound(src, 'aquila/sound/effects/closetpull.ogg', 80, 0)

/obj/structure/closet/body_bag/Moved(atom/OldLoc, Dir)
	. = ..()
	if(has_gravity())
		playsound(src, 'aquila/sound/effects/bodybagpull.ogg', 25, 0)

/obj/structure/closet/cardboard/Moved(atom/OldLoc, Dir)
	. = ..()
	if(has_gravity())
		playsound(src, 'sound/effects/footstep/crawl1.ogg', 30, 0)

/// Alt blokuje i odblokowuje zamek jak w Bee. Prawy przycisk robi to samo, ale bez combat mode otwiera menu BYOND.
/obj/structure/closet/AltClick(mob/user)
	. = ..()
	if(opened || !secure || !user.canUseTopic(src, BE_CLOSE) || !isturf(loc))
		return
	togglelock(user)
