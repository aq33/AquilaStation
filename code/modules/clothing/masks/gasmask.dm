/obj/item/clothing/mask/gas
	name = "maska gazowa"
	desc = "Maska zakrywająca twarz, którą można podłączyć do źródła powietrza. Dobrze ukrywa tożsamość, ale słabo blokuje przepływ gazów." //More accurate
	icon_state = "gas_alt"
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	w_class = WEIGHT_CLASS_NORMAL
	item_state = "gas_alt"
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH
	resistance_flags = NONE

// **** Welding gas mask ****

/obj/item/clothing/mask/gas/welding
	name = "maska spawalnicza"
	desc = "Maska gazowa z wbudowanymi goglami spawalniczymi i osłoną twarzy. Wygląda jak czaszka - wyraźnie zaprojektował ją nerd."
	icon_state = "weldingmask"
	materials = list(/datum/material/iron=4000, /datum/material/glass=2000)
	flash_protect = 2
	tint = 2
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 55, "stamina" = 15, "bleed" = 5)
	actions_types = list(/datum/action/item_action/toggle)
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	flags_cover = MASKCOVERSEYES
	visor_flags_inv = HIDEEYES
	visor_flags_cover = MASKCOVERSEYES
	resistance_flags = FIRE_PROOF

/obj/item/clothing/mask/gas/welding/attack_self(mob/user)
	weldingvisortoggle(user)

/obj/item/clothing/mask/gas/welding/up

/obj/item/clothing/mask/gas/welding/up/Initialize(mapload)
	. = ..()
	visor_toggling()

// ********************************************************************

//Plague Dr suit can be found in clothing/suits/bio.dm
/obj/item/clothing/mask/gas/plaguedoctor
	name = "maska doktora plagi"
	desc = "Unowocześniona wersja klasycznego wzoru. Ta maska nie tylko filtruje toksyny, ale można ją też podłączyć do źródła powietrza."
	icon_state = "plaguedoctor"
	item_state = "gas_mask"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 2,"energy" = 2, "bomb" = 0, "bio" = 75, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 0)

/obj/item/clothing/mask/gas/syndicate
	name = "maska Syndykatu"
	desc = "Dopasowana maska taktyczna, którą można podłączyć do źródła powietrza."
	icon_state = "syndicate"
	strip_delay = 60

/obj/item/clothing/mask/gas/clown_hat
	name = "peruka i maska klauna"
	desc = "Strój twarzy prawdziwego dowcipnisia. Klaun bez peruki i maski nie jest pełnym klaunem."
	clothing_flags = MASKINTERNALS | SHOWEROKAY //NSV13 - kept SHOWEROKAY
	icon_state = "clown"
	item_state = "clown_hat"
	dye_color = "clown"
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE
	actions_types = list(/datum/action/item_action/adjust)
	dog_fashion = /datum/dog_fashion/head/clown

/obj/item/clothing/mask/gas/clown_hat/ui_action_click(mob/user)
	if(!istype(user) || user.incapacitated())
		return

	var/list/options = list()
	options["Prawdziwa forma"] = "clown"
	options["Feministka"] = "sexyclown"
	options["Szaleniec"] = "joker"
	options["Tęczowe barwy"] ="rainbow"
	options["Błazen"] ="chaos" //Nepeta33Leijon is holding me captive and forced me to help with this please send help
	options["Wariat"] = "trickymask"

	var/choice = input(user,"W jaką formę chcesz przemienić tę maskę?","Przemiana maski") in sortList(options)

	if(src && choice && !user.incapacitated() && in_range(user,src))
		icon_state = options[choice]
		user.update_inv_wear_mask()
		for(var/X in actions)
			var/datum/action/A = X
			A.UpdateButtonIcon()
		to_chat(user, "<span class='notice'>Twoja maska klauna przemieniła się w [choice], chwała Honkmatce!</span>")
		return 1

/obj/item/clothing/mask/gas/sexyclown
	name = "peruka i maska seksownej klaunicy"
	desc = "Kobieca maska klauna dla początkujących crossdresserów i artystek estradowych."
	clothing_flags = MASKINTERNALS | SHOWEROKAY //NSV13 - kept SHOWEROKAY
	icon_state = "sexyclown"
	item_state = "sexyclown"
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/mime
	name = "maska mima"
	desc = "Tradycyjna maska mima. Ma niepokojący wyraz twarzy."
	clothing_flags = MASKINTERNALS | SHOWEROKAY //NSV13 - kept SHOWEROKAY
	icon_state = "mime"
	item_state = "mime"
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE
	actions_types = list(/datum/action/item_action/adjust)


/obj/item/clothing/mask/gas/mime/ui_action_click(mob/user)
	if(!istype(user) || user.incapacitated())
		return

	var/list/options = list()
	options["Blanc"] = "mime"
	options["Triste"] = "sadmime"
	options["Effrayé"] = "scaredmime"
	options["Excité"] ="sexymime"

	var/choice = input(user,"W jaką formę chcesz przemienić tę maskę?","Przemiana maski") in sortList(options)

	if(src && choice && !user.incapacitated() && in_range(user,src))
		icon_state = options[choice]
		user.update_inv_wear_mask()
		for(var/X in actions)
			var/datum/action/A = X
			A.UpdateButtonIcon()
		to_chat(user, "<span class='notice'>Twoja maska mima przemieniła się w [choice]!</span>")
		return 1

/obj/item/clothing/mask/gas/monkeymask
	name = "maska małpy"
	desc = "Maska do odgrywania małpy."
	clothing_flags = MASKINTERNALS
	icon_state = "monkeymask"
	item_state = "monkeymask"
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/sexymime
	name = "maska seksownej mimki"
	desc = "Tradycyjna maska mimki."
	clothing_flags = MASKINTERNALS | SHOWEROKAY //NSV13 - kept SHOWEROKAY
	icon_state = "sexymime"
	item_state = "sexymime"
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/death_commando
	name = "maska komandosa śmierci"
	icon_state = "death_commando_mask"
	item_state = "death_commando_mask"

/obj/item/clothing/mask/gas/cyborg
	name = "wizjer cyborga"
	desc = "Bip bup."
	icon_state = "death"
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/owl_mask
	name = "maska sowy"
	desc = "Hu-huuu!"
	icon_state = "owl"
	clothing_flags = MASKINTERNALS
	flags_cover = MASKCOVERSEYES
	resistance_flags = FLAMMABLE

/obj/item/clothing/mask/gas/carp
	name = "maska karpia"
	desc = "Kłap kłap."
	icon_state = "carp_mask"

/obj/item/clothing/mask/gas/tiki_mask
	name = "maska tiki"
	desc = "Upiorna drewniana maska. Zaskakująco wyrazista jak na niezgrabnie wyrzeźbiony kawałek drewna."
	icon_state = "tiki_eyebrow"
	item_state = "tiki_eyebrow"
	resistance_flags = FLAMMABLE
	max_integrity = 100
	actions_types = list(/datum/action/item_action/adjust)
	dog_fashion = null


/obj/item/clothing/mask/gas/tiki_mask/ui_action_click(mob/user)
	var/mob/M = usr
	var/list/options = list()
	options["Oryginalna tiki"] = "tiki_eyebrow"
	options["Wesoła tiki"] = "tiki_happy"
	options["Zdezorientowana tiki"] = "tiki_confused"
	options["Wściekła tiki"] ="tiki_angry"

	var/choice = input(M,"W jaką formę chcesz zmienić tę maskę?","Przemiana maski") in sortList(options)

	if(src && choice && !M.stat && in_range(M,src))
		icon_state = options[choice]
		user.update_inv_wear_mask()
		for(var/X in actions)
			var/datum/action/A = X
			A.UpdateButtonIcon()
		to_chat(M, "Maska tiki zmieniła się w maskę [choice]!")
		return 1

/obj/item/clothing/mask/gas/tiki_mask/yalp_elor
	icon_state = "tiki_yalp"
	actions_types = list()

/obj/item/clothing/mask/gas/hunter
	name = "maska łowcy nagród"
	desc = "Przerobiona maska taktyczna z dodanymi naklejkami."
	icon_state = "hunter"
	item_state = "hunter"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEFACIALHAIR|HIDEFACE|HIDEEYES|HIDEEARS|HIDEHAIR|HIDESNOUT

/obj/item/clothing/mask/gas/old
	desc = "Maska zakrywająca twarz, którą można podłączyć do źródła powietrza. Ta wygląda na jeden ze starszych modeli."
	icon_state = "gas_alt_old"
	item_state = "gas_alt_old"
