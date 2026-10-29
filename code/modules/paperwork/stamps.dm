/obj/item/stamp
	name = "\improper pieczątka ZATWIERDZONO"
	desc = "Gumowa pieczątka do stemplowania ważnych dokumentów."
	icon = 'icons/obj/bureaucracy.dmi' //NSV13 use nsv copy of bureaucracy.dmi
	icon_state = "stamp-ok"
	item_state = "stamp"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	materials = list(/datum/material/iron=60)
	pressure_resistance = 2
	attack_verb = list("stempluje")

/obj/item/stamp/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] przybija sobie na czole pieczątkę „UNIEWAŻNIONO”, po czym natychmiast pada martwy.</span>")
	return (OXYLOSS)

/obj/item/stamp/get_writing_implement_details()
	var/datum/asset/spritesheet/sheet = get_asset_datum(/datum/asset/spritesheet/simple/paper)
	return list(
		interaction_mode = MODE_STAMPING,
		stamp_icon_state = icon_state,
		stamp_class = sheet.icon_class_name(icon_state)
	)

/obj/item/stamp/quartermaster
	name = "pieczątka kwatermistrza"
	icon_state = "stamp-qm"
	dye_color = DYE_QM

/obj/item/stamp/law
	name = "pieczątka kancelarii prawnej"
	icon_state = "stamp-law"
	dye_color = DYE_LAW

/obj/item/stamp/captain
	name = "pieczątka kapitana"
	icon_state = "stamp-cap"
	dye_color = DYE_CAPTAIN

/obj/item/stamp/head_of_personnel
	name = "pieczątka starszego oficera"
	icon_state = "stamp-hop"
	dye_color = DYE_HOP

/obj/item/stamp/hos
	name = "pieczątka komendanta"
	icon_state = "stamp-hos"
	dye_color = DYE_HOS

/obj/item/stamp/chief_engineer
	name = "pieczątka głównego inżyniera"
	icon_state = "stamp-ce"
	dye_color = DYE_CE

/obj/item/stamp/research_director
	name = "pieczątka dyrektora naukowego"
	icon_state = "stamp-rd"
	dye_color = DYE_RD

/obj/item/stamp/cmo
	name = "pieczątka ordynatora"
	icon_state = "stamp-cmo"
	dye_color = DYE_CMO

/obj/item/stamp/denied
	name = "\improper pieczątka ODRZUCONO"
	icon_state = "stamp-deny"
	dye_color = DYE_REDCOAT

/obj/item/stamp/void
	name = "pieczątka UNIEWAŻNIONO"
	icon_state = "stamp-void"

/obj/item/stamp/clown
	name = "pieczątka klauna"
	icon_state = "stamp-clown"
	dye_color = DYE_CLOWN

/obj/item/stamp/attack_paw(mob/user)
	return attack_hand(user)
