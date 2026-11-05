/obj/item/clothing/under/rank/cargo/quartermaster
	name = "kombinezon kwatermistrza"
	desc = "Kombinezon noszony przez kwatermistrza. Specjalnie zaprojektowany, by zapobiegać urazom kręgosłupa od przekładania papierów."
	icon_state = "qm"
	item_state = "qm"

/obj/item/clothing/under/rank/cargo/quartermaster/skirt
	name = "spódnica kwatermistrza"
	desc = "Spódnica noszona przez kwatermistrza. Specjalnie zaprojektowana, by zapobiegać urazom kręgosłupa od przekładania papierów."
	icon_state = "qm_skirt"
	item_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/cargo/quartermaster/turtleneck
	name = "golf kwatermistrza"
	desc = "Przylegający golf noszony przez kwatermistrza, wyróżniający się drogo wyglądającymi spodniami od garnituru."
	icon_state = "qmturtle"
	item_state = "qmturtle"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE

/obj/item/clothing/under/rank/cargo/quartermaster/turtleneck/skirt
	name = "golf ze spódnicą kwatermistrza"
	desc = "Przylegający golf noszony przez kwatermistrza, co zdradza elegancka podwójna podszewka jedwabnej spódnicy."
	icon_state = "qmturtle_skirt"
	item_state = "qmturtle_skirt"
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/cargo/tech
	name = "kombinezon magazyniera"
	desc = "Szoooorty! Są wygodne i łatwo się je nosi!"
	icon_state = "cargo"
	item_state = "cargo"
	body_parts_covered = CHEST|GROIN|ARMS
	supports_variations = DIGITIGRADE_VARIATION
	alt_covers_chest = TRUE

/obj/item/clothing/under/rank/cargo/tech/skirt
	name = "spódnica magazyniera"
	desc = "Spódniiiiice! Są wygodne i łatwo się je nosi!"
	icon_state = "cargo_skirt"
	item_state = "lb_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON

/obj/item/clothing/under/rank/cargo/miner
	desc = "Zgrabny kombinezon z solidnymi ogrodniczkami. Jest bardzo brudny."
	name = "kombinezon górnika"
	icon_state = "miner"
	item_state = "miner"

/obj/item/clothing/under/rank/cargo/miner/lavaland
	desc = "Zielony mundur do pracy w niebezpiecznym środowisku."
	name = "kombinezon górnika"
	icon_state = "explorer"
	item_state = "explorer"
	can_adjust = FALSE

/obj/item/clothing/under/rank/cargo/exploration
	name = "mundur odkrywcy"
	desc = "Wytrzymały mundur używany przez zespoły odkrywców."
	icon_state = "curator"
	item_state = "curator"
	can_adjust = FALSE

/obj/item/clothing/under/misc/mailman
	name = "kombinezon listonosza"
	desc = "<i>„Przesyłka specjalna!”</i>"
	icon_state = "mailman"
	item_state = "b_suit"

/obj/item/clothing/under/misc/mailman/skirt
	name = "spódnica listonosza"
	desc = "<i>„Przesyłka specjalna!”</i> Uważaj na kosmiczny wiatr."
	icon_state = "mailman_skirt"
	item_state = "b_suit"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE
	fitted = FEMALE_UNIFORM_TOP
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON
