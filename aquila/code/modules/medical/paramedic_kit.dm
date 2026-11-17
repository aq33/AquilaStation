// AQUILA - zestaw ratownika (AquilaMed 5), na wzór tgstation: medipeny na konkretne obrażenia
// (code/modules/reagents/reagent_containers/hypospray.dm), pas ratownika (code/game/objects/items/storage/belt.dm),
// latarka UV ratownika (code/game/objects/items/devices/flashlight.dm) i medyczny zestaw przetrwania.
// Sprite'y z tgstation (CC-BY-SA 3.0) w aquila/icons/obj/medical/medycyna5.dmi.
// Różnice: medipen „pierwsza pomoc” ma u nas epinefrynę, spaceacylinę i salbutamol (koagulantu z tg nie mamy),
// pas niesie medipeny, a latarka UV gasi zakażenie oparzeń z naszych ran (wounds/burn.dm).

// --- Medipeny ---

/obj/item/reagent_containers/hypospray/medipen/salacid
	name = "medipen z kwasem salicylowym"
	desc = "Autostrzykawka z kwasem salicylowym na ciężkie stłuczenia i rany."
	icon = 'aquila/icons/obj/medical/medycyna5.dmi'
	icon_state = "salacid"
	item_state = "salacid"
	lefthand_file = 'aquila/icons/mob/inhands/equipment/medycyna5_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/equipment/medycyna5_righthand.dmi'
	volume = 10
	amount_per_transfer_from_this = 10
	list_reagents = list(/datum/reagent/medicine/sal_acid = 10)

/obj/item/reagent_containers/hypospray/medipen/oxandrolone
	name = "medipen z oksandrolonem"
	desc = "Autostrzykawka z oksandrolonem na ciężkie oparzenia."
	icon = 'aquila/icons/obj/medical/medycyna5.dmi'
	icon_state = "oxapen"
	item_state = "oxapen"
	lefthand_file = 'aquila/icons/mob/inhands/equipment/medycyna5_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/equipment/medycyna5_righthand.dmi'
	volume = 10
	amount_per_transfer_from_this = 10
	list_reagents = list(/datum/reagent/medicine/oxandrolone = 10)

/obj/item/reagent_containers/hypospray/medipen/salbutamol
	name = "medipen z salbutamolem"
	desc = "Autostrzykawka z salbutamolem: szybko leczy niedotlenienie i duszność."
	icon = 'aquila/icons/obj/medical/medycyna5.dmi'
	icon_state = "salpen"
	item_state = "salpen"
	lefthand_file = 'aquila/icons/mob/inhands/equipment/medycyna5_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/equipment/medycyna5_righthand.dmi'
	volume = 10
	amount_per_transfer_from_this = 10
	list_reagents = list(/datum/reagent/medicine/salbutamol = 10)

/obj/item/reagent_containers/hypospray/medipen/penacid
	name = "medipen z kwasem pentetowym"
	desc = "Autostrzykawka z kwasem pentetowym na zatrucie i napromieniowanie."
	icon = 'aquila/icons/obj/medical/medycyna5.dmi'
	icon_state = "penacid"
	item_state = "penacid"
	lefthand_file = 'aquila/icons/mob/inhands/equipment/medycyna5_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/equipment/medycyna5_righthand.dmi'
	volume = 10
	amount_per_transfer_from_this = 10
	list_reagents = list(/datum/reagent/medicine/pen_acid = 10)

/obj/item/reagent_containers/hypospray/medipen/ekit
	name = "medipen pierwszej pomocy"
	desc = "Autostrzykawka z epinefryną, antybiotykiem i salbutamolem. Stabilizuje pacjenta do czasu właściwego leczenia."
	icon = 'aquila/icons/obj/medical/medycyna5.dmi'
	icon_state = "firstaid"
	volume = 15
	amount_per_transfer_from_this = 15
	list_reagents = list(/datum/reagent/medicine/epinephrine = 10, /datum/reagent/medicine/spaceacillin = 2, /datum/reagent/medicine/salbutamol = 3)

// --- Pas ratownika ---

/obj/item/storage/belt/medical/paramedic
	name = "pas ratownika"
	desc = "Pas ratownika medycznego z przegródkami na medipeny i sprzęt pierwszej pomocy."
	icon = 'aquila/icons/obj/medical/medycyna5.dmi'
	icon_state = "emt"
	item_state = "security"
	worn_icon = 'aquila/icons/mob/clothing/belt_emt.dmi'
	worn_icon_state = "emt"

/obj/item/storage/belt/medical/paramedic/PopulateContents()
	new /obj/item/reagent_containers/hypospray/medipen/salacid(src)
	new /obj/item/reagent_containers/hypospray/medipen/oxandrolone(src)
	new /obj/item/reagent_containers/hypospray/medipen/salbutamol(src)
	new /obj/item/reagent_containers/hypospray/medipen/penacid(src)
	new /obj/item/reagent_containers/hypospray/medipen/ekit(src)
	new /obj/item/stack/medical/splint(src, 2)
	new /obj/item/flashlight/pen/paramedic(src)

// --- Latarka UV ---

/obj/item/flashlight/pen/paramedic
	name = "latarka UV ratownika"
	desc = "Mocna latarka z lampą UV. Poświecenie na zakażone oparzenie przyhamowuje zakażenie do czasu opatrunku. Lepiej nie patrzeć w nią prosto."
	icon = 'aquila/icons/obj/medical/medycyna5.dmi'
	icon_state = "penlight_surgical"
	light_color = "#8FEEFF"
	/// Next time the UV lamp can be used again
	COOLDOWN_DECLARE(uv_cooldown)

/obj/item/flashlight/pen/paramedic/attack(mob/living/M, mob/living/user)
	if(!iscarbon(M) || user.combat_mode || user.zone_selected == BODY_ZONE_PRECISE_EYES)
		return ..()
	var/mob/living/carbon/patient = M
	var/obj/item/bodypart/limb = patient.get_bodypart(check_zone(user.zone_selected))
	var/datum/wound/burn/burn = limb?.get_wound(WOUND_BURN)
	if(!burn)
		return ..()
	if(!COOLDOWN_FINISHED(src, uv_cooldown))
		to_chat(user, "<span class='warning'>Lampa UV jeszcze się ładuje.</span>")
		return
	COOLDOWN_START(src, uv_cooldown, 4 SECONDS)
	limb.aq_add_germs(-20) // zarazki kończyny (germs.dm)
	user.visible_message("<span class='notice'>[user] świeci lampą UV na oparzenie [patient] ([limb.name]).</span>", "<span class='notice'>Świecisz lampą UV na oparzenie [patient == user ? "" : "[patient] "]([limb.name]). Zakażenie słabnie.</span>")

// --- Medyczny zestaw przetrwania ---

/obj/item/storage/box/survival/medical
	name = "medyczny zestaw przetrwania"
	desc = "Zestaw przetrwania z medyczną maską oddechową i medipenem pierwszej pomocy."

/obj/item/storage/box/survival/medical/PopulateContents()
	..()
	for(var/obj/item/clothing/mask/breath/mask in src)
		qdel(mask)
	new /obj/item/clothing/mask/breath/medical(src)
	var/obj/item/reagent_containers/hypospray/medipen/plain = locate(/obj/item/reagent_containers/hypospray/medipen) in src
	if(plain && plain.type == /obj/item/reagent_containers/hypospray/medipen)
		qdel(plain)
	new /obj/item/reagent_containers/hypospray/medipen/ekit(src)
