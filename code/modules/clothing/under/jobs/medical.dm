/obj/item/clothing/under/rank/medical/chief_medical_officer
	desc = "Kombinezon noszony przez tych, którzy mają dość doświadczenia, by zostać ordynatorem. Daje słabą ochronę biologiczną."
	name = "kombinezon ordynatora"
	icon_state = "cmo"
	item_state = "w_suit"
	permeability_coefficient = 0.5
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 10)

/obj/item/clothing/under/rank/medical/chief_medical_officer/skirt
	name = "spódnica ordynatora"
	desc = "Spódnica noszona przez tych, którzy mają dość doświadczenia, by zostać ordynatorem. Daje słabą ochronę biologiczną."
	icon_state = "cmo_skirt"
	item_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/medical/geneticist
	desc = "Uszyty ze specjalnego włókna, które daje szczególną ochronę przed zagrożeniami biologicznymi. Ma pasek oznaczający genetyka."
	name = "kombinezon genetyka"
	icon_state = "genetics"
	item_state = "w_suit"
	permeability_coefficient = 0.5
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 10)

/obj/item/clothing/under/rank/medical/geneticist/skirt
	name = "spódnica genetyka"
	desc = "Uszyta ze specjalnego włókna, które daje szczególną ochronę przed zagrożeniami biologicznymi. Ma pasek oznaczający genetyka."
	icon_state = "geneticswhite_skirt"
	item_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/medical/virologist
	desc = "Uszyty ze specjalnego włókna, które daje szczególną ochronę przed zagrożeniami biologicznymi. Ma pasek oznaczający wirologa."
	name = "kombinezon wirologa"
	icon_state = "virology"
	item_state = "w_suit"
	permeability_coefficient = 0.5
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 10)

/obj/item/clothing/under/rank/medical/virologist/skirt
	name = "spódnica wirologa"
	desc = "Uszyta ze specjalnego włókna, które daje szczególną ochronę przed zagrożeniami biologicznymi. Ma pasek oznaczający wirologa."
	icon_state = "virologywhite_skirt"
	item_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/medical/paramedic
	name = "kombinezon ratownika medycznego"
	desc = "Standardowy kombinezon ratowników medycznych na stacjach kosmicznych. Ze specjalnego włókna, zapewniającego ochronę przed zagrożeniami biologicznymi."
	icon_state = "emt"
	permeability_coefficient = 0.5
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 10)
	can_adjust = FALSE

/obj/item/clothing/under/rank/medical/paramedic/skirt
	name = "spódnica ratownika medycznego"
	desc = "Uszyta ze specjalnego włókna, które daje słabą ochronę przed zagrożeniami biologicznymi. Ciemnoniebieski krzyż na piersi oznacza, że noszący jest wyszkolonym ratownikiem medycznym."
	icon_state = "emt_skirt"
	item_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/medical/doctor/nurse
	desc = "Kombinezon często noszony przez personel pielęgniarski działu medycznego."
	name = "strój pielęgniarki"
	icon_state = "nursesuit"
	item_state = "w_suit"
	permeability_coefficient = 0.5
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 10)
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE

/obj/item/clothing/under/rank/medical/doctor
	desc = "Uszyty ze specjalnego włókna, które daje słabą ochronę przed zagrożeniami biologicznymi. Krzyż na piersi oznacza, że noszący należy do wyszkolonego personelu medycznego."
	name = "kombinezon lekarza"
	icon_state = "medical"
	item_state = "w_suit"
	permeability_coefficient = 0.5
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 10)

/obj/item/clothing/under/rank/medical/doctor/skirt
	name = "spódnica lekarza"
	desc = "Uszyta ze specjalnego włókna, które daje słabą ochronę przed zagrożeniami biologicznymi. Krzyż na piersi oznacza, że noszący należy do wyszkolonego personelu medycznego."
	icon_state = "medical_skirt"
	item_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/medical/doctor/blue
	name = "strój chirurgiczny"
	desc = "Ze specjalnego włókna, zapewniającego niewielką ochronę przed zagrożeniami biologicznymi. Ten jest błękitny."
	icon_state = "scrubsblue"
	can_adjust = FALSE

/obj/item/clothing/under/rank/medical/doctor/green
	name = "strój chirurgiczny"
	desc = "Ze specjalnego włókna, zapewniającego niewielką ochronę przed zagrożeniami biologicznymi. Ten jest ciemnozielony."
	icon_state = "scrubsgreen"
	can_adjust = FALSE

/obj/item/clothing/under/rank/medical/doctor/purple
	name = "strój chirurgiczny"
	desc = "Ze specjalnego włókna, zapewniającego niewielką ochronę przed zagrożeniami biologicznymi. Ten jest ciemnofioletowy."
	icon_state = "scrubspurple"
	can_adjust = FALSE

/obj/item/clothing/under/rank/medical/chemist
	desc = "Uszyty ze specjalnego włókna, które daje szczególną ochronę przed zagrożeniami biologicznymi. Ma pasek oznaczający chemika."
	name = "kombinezon chemika"
	icon_state = "chemistry"
	item_state = "w_suit"
	permeability_coefficient = 0.5
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 50, "acid" = 65, "stamina" = 0, "bleed" = 10)

/obj/item/clothing/under/rank/medical/chemist/skirt
	name = "spódnica chemika"
	desc = "Uszyta ze specjalnego włókna, które daje szczególną ochronę przed zagrożeniami biologicznymi. Ma pasek oznaczający chemika."
	icon_state = "chemistrywhite_skirt"
	item_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON
