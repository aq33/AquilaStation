/obj/structure/chair/fancy/sofa //like it's brother fancy chair, this is the father of all sofas
	name = "sofa praojciec"
	desc = "Ten rodzaj sofy wymarł i nie powinien już nawet istnieć. Jeśli zobaczysz ten dziki okaz, skontaktuj się ze stacyjnym Działem do Walki z Kanapowym Surfowaniem."
	icon_state = "sofa_middle"
	icon = 'icons/obj/beds_chairs/sofa.dmi'
	buildstackamount = 1
	item_chair = null

/obj/structure/chair/fancy/sofa/old
	color = rgb(141,70,0)
	name = "stara sofa"
	desc = "Stary projekt, ale wciąż sprawdza się jako sofa."
	icon_state = "sofa_middle"
	colorable = TRUE

/obj/structure/chair/fancy/sofa/old/left
	icon_state = "sofa_end_left"

/obj/structure/chair/fancy/sofa/old/right
	icon_state = "sofa_end_right"

/obj/structure/chair/fancy/sofa/old/corner
	name = "niemożliwy narożnik starej sofy"
	desc = "Ten rodzaj sofy w ogóle nie powinien istnieć. Jeśli zobaczysz ten nieeuklidesowy okaz, skontaktuj się ze stacyjnym Działem do Walki z Kanapowym Surfowaniem."
	icon_state = "sofa_cursed"

/obj/structure/chair/fancy/sofa/old/corner/handle_layer() //only the armrest/back of this chair should cover the mob.
	return

/obj/structure/chair/fancy/sofa/old/corner/concave
	icon_state = "sofa_corner_in"
	name = "stara sofa"
	desc = "Stary projekt, ale wciąż sprawdza się jako sofa. Ta jest wklęsła."

/obj/structure/chair/fancy/sofa/old/corner/convex
	icon_state = "sofa_corner_out"
	name = "stara sofa"
	desc = "Stary projekt, ale wciąż sprawdza się jako sofa. Ta jest wypukła."

// Original icon ported from Eris(?) and updated to work here.
/obj/structure/chair/fancy/sofa/corp
	name = "korporacyjna sofa"
	desc = "Miękka i mięciutka, a jednak profesjonalna."
	icon_state = "corp_sofa_middle"

/obj/structure/chair/fancy/sofa/corp/left
	icon_state = "corp_sofa_end_left"

/obj/structure/chair/fancy/sofa/corp/right
	icon_state = "corp_sofa_end_right"

/obj/structure/chair/fancy/sofa/corp/corner
	name = "niemożliwy narożnik korporacyjnej sofy"
	desc = "Ten rodzaj sofy w ogóle nie powinien istnieć. Jeśli zobaczysz ten nieeuklidesowy okaz, skontaktuj się ze stacyjnym Działem do Walki z Kanapowym Surfowaniem."
	icon_state = "corp_sofa_cursed"

/obj/structure/chair/fancy/sofa/corp/corner/handle_layer()
	return

/obj/structure/chair/fancy/sofa/corp/corner/concave
	icon_state = "corp_sofa_corner_in"
	name = "korporacyjna sofa"
	desc = "Miękka i mięciutka, a jednak profesjonalna. Ta jest wklęsła."

/obj/structure/chair/fancy/sofa/corp/corner/convex
	icon_state = "corp_sofa_corner_out"
	name = "korporacyjna sofa"
	desc = "Miękka i mięciutka, a jednak profesjonalna. Ta jest wypukła."
