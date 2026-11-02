/obj/structure/chair/fancy/sofa/mono
	color = rgb(76, 78, 82)
	name = "stara wytarta sofa"
	desc = "Stary model, ale nadal spełnia swoje zadanie jako sofa."
	icon_state = "sofa_middle"
	colorable = TRUE
	item_chair = null

/obj/structure/chair/fancy/sofa/mono/left
	icon_state = "sofa_end_left"

/obj/structure/chair/fancy/sofa/mono/right
	icon_state = "sofa_end_right"

/obj/structure/chair/fancy/sofa/mono/corner
	name = "niemożliwy narożnik starej sofy"
	desc = "Taka sofa w ogóle nie powinna istnieć. Jeśli widzisz ten nieeuklidesowy okaz, skontaktuj się z Działem Przeciwdziałania Surfowaniu po Kanapach."
	icon_state = "sofa_cursed"

/obj/structure/chair/fancy/sofa/mono/corner/handle_layer() //only the armrest/back of this chair should cover the mob.
	return

/obj/structure/chair/fancy/sofa/mono/corner/concave
	icon_state = "sofa_corner_in"
	name = "stara wytarta sofa"
	desc = "Stary model, ale nadal spełnia swoje zadanie jako sofa. Ta jest wklęsła."

/obj/structure/chair/fancy/sofa/mono/corner/convex
	icon_state = "sofa_corner_out"
	name = "stara wytarta sofa"
	desc = "Stary model, ale nadal spełnia swoje zadanie jako sofa. Ta jest wypukła."
