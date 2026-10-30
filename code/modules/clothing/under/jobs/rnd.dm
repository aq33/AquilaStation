/obj/item/clothing/under/rank/rnd/research_director
	name = "kombinezon dyrektora naukowego"
	desc = "Kombinezon noszony przez tych, którzy wiedzą dość, by zostać dyrektorem naukowym. Materiał daje słabą ochronę przed skażeniem biologicznym."
	icon_state = "director"
	item_state = "w_suit"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 10, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 35, "stamina" = 0, "bleed" = 10)
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/rnd/research_director/skirt
	name = "spódnica dyrektora naukowego"
	desc = "Spódnica noszona przez tych, którzy wiedzą dość, by zostać dyrektorem naukowym. Materiał daje słabą ochronę przed skażeniem biologicznym."
	icon_state = "director_skirt"
	item_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/rnd/research_director/alt
	desc = "Może kiedyś stworzysz własną istotę – pół człowieka, pół świnię. Materiał daje słabą ochronę przed skażeniem biologicznym."
	name = "beżowy garnitur dyrektora naukowego"
	icon_state = "rdwhimsy"
	item_state = "rdwhimsy"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 10, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 10)
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/rnd/research_director/alt/skirt
	name = "beżowa garsonka dyrektora naukowego"
	desc = "Może kiedyś stworzysz własną istotę – pół człowieka, pół świnię. Materiał daje słabą ochronę przed skażeniem biologicznym."
	icon_state = "rdwhimsy_skirt"
	item_state = "rdwhimsy"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/rnd/research_director/turtleneck
	desc = "Ciemnofioletowy golf i beżowe spodnie khaki, dla dyrektora o wyjątkowym wyczuciu stylu."
	name = "golf dyrektora naukowego"
	icon_state = "rdturtle"
	item_state = "p_suit"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 10, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 10)
	can_adjust = TRUE
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/rnd/research_director/turtleneck/skirt
	name = "golf ze spódnicą dyrektora naukowego"
	desc = "Ciemnofioletowy golf i beżowa spódnica khaki, dla dyrektora o wyjątkowym wyczuciu stylu."
	icon_state = "rdturtle_skirt"
	item_state = "p_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/rnd/research_director/vest
	desc = "Uszyty ze specjalnego włókna, które daje słabą ochronę przed zagrożeniami biologicznymi. Choć nigdy formalnie go nie wycofano, standardowy strój z kamizelką dyrektora naukowego to rzadki widok."
	name = "strój z kamizelką dyrektora naukowego"
	icon_state = "rd_vest"
	item_state = "lb_suit"
	can_adjust = FALSE

/obj/item/clothing/under/rank/rnd/scientist
	desc = "Uszyty ze specjalnego włókna, które daje słabą ochronę przed wybuchami. Oznaczenia wskazują, że noszący jest naukowcem."
	name = "kombinezon naukowca"
	icon_state = "toxinswhite"
	item_state = "w_suit"
	worn_icon_state = "toxinswhite"
	permeability_coefficient = 0.5
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 10)

/obj/item/clothing/under/rank/rnd/scientist/skirt
	name = "spódnica naukowca"
	desc = "Uszyta ze specjalnego włókna, które daje słabą ochronę przed wybuchami. Oznaczenia wskazują, że noszący jest naukowcem."
	icon_state = "toxinswhite_skirt"
	item_state = "w_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/rnd/roboticist
	desc = "Wyszczuplający czarny kombinezon ze wzmocnionymi szwami; świetny do pracy w przemyśle."
	name = "kombinezon robotyka"
	icon_state = "robotics"
	item_state = "robotics"
	resistance_flags = NONE

/obj/item/clothing/under/rank/rnd/roboticist/skirt
	name = "spódnica robotyka"
	desc = "Wyszczuplająca czarna spódnica ze wzmocnionymi szwami; świetna do pracy w przemyśle."
	icon_state = "robotics_skirt"
	item_state = "robotics"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/rnd/roboticist/retro
	desc = "Wyszczuplający czarny kombinezon ze wzmocnionymi szwami; świetny do pracy w przemyśle. Klasyczny krój, nowoczesny wygląd, a rękawiczki są tylko na pokaz."
	name = "retro kombinezon robotyka"
	icon_state = "robotics_retro"
	item_state = "robotics"
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	fitted = NO_FEMALE_UNIFORM
	alternate_worn_layer = GLOVES_LAYER
	can_adjust = FALSE
