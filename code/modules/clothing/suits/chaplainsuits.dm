//Chaplain Suit Subtypes
//If any new staple chaplain items get added, put them in these lists
/obj/item/clothing/suit/chaplainsuit
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)

/obj/item/clothing/suit/hooded/chaplainsuit
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)

//Suits
/obj/item/clothing/suit/chaplainsuit/holidaypriest
	name = "świąteczna szata kapłana"
	desc = "Piękne mamy święto, synu."
	icon_state = "holidaypriest"
	item_state = "w_suit"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/chaplainsuit/nun
	name = "habit zakonnicy"
	desc = "Maksimum pobożności w tym układzie gwiezdnym."
	icon_state = "nun"
	item_state = "nun"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|HANDS
	flags_inv = HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/chaplainsuit/bishoprobe
	name = "szaty biskupa"
	desc = "Miło widzieć, że zebrana dziesięcina została dobrze wydana."
	icon_state = "bishoprobe"
	item_state = "bishoprobe"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/chaplainsuit/bishoprobe/black
	name = "czarne szaty biskupa"
	icon_state = "blackbishoprobe"
	item_state = "blackbishoprobe"

/obj/item/clothing/suit/chaplainsuit/studentuni
	name = "szata studenta"
	desc = "Mundurek dawno zapomnianej szkoły."
	icon_state = "studentuni"
	item_state = "studentuni"
	body_parts_covered = ARMS|CHEST

/obj/item/clothing/suit/chaplainsuit/witchhunter
	name = "strój łowcy czarownic"
	desc = "Ten znoszony strój swoje w dawnych czasach przeszedł."
	icon_state = "witchhunter"
	item_state = "witchhunter"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS

/obj/item/clothing/suit/hooded/chaplainsuit/monkfrock
	name = "habit mnicha"
	desc = "Kilka stopni wyżej od podartego wora pokutnego."
	icon_state = "monkfrock"
	item_state = "monkfrock"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT
	hoodtype = /obj/item/clothing/head/hooded/monkfrock

/obj/item/clothing/head/hooded/monkfrock
	name = "kaptur mnicha"
	desc = "Na wypadek, gdyby ktoś chciał zakryć tonsurę."
	icon_state = "monkhood"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEEARS

/obj/item/clothing/suit/chaplainsuit/monkrobeeast
	name = "szaty wschodniego mnicha"
	desc = "Najlepiej wyglądają z ogoloną głową."
	icon_state = "monkrobeeast"
	item_state = "monkrobeeast"
	body_parts_covered = GROIN|LEGS
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/chaplainsuit/whiterobe
	name = "biała szata"
	desc = "Dobra dla duchownych i zaspanych członków załogi."
	icon_state = "whiterobe"
	item_state = "whiterobe"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/chaplainsuit/clownpriest
	name = "szaty Honkmatki"
	desc = "Dla klauna w sutannie."
	icon_state = "clownpriest"
	item_state = "clownpriest"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEJUMPSUIT
	allowed = list(/obj/item/megaphone/clown, /obj/item/soap, /obj/item/food/pie/cream, /obj/item/bikehorn, /obj/item/bikehorn/golden, /obj/item/bikehorn/airhorn, /obj/item/instrument/bikehorn, /obj/item/reagent_containers/food/drinks/soda_cans/canned_laughter, /obj/item/toy/crayon, /obj/item/toy/crayon/spraycan, /obj/item/toy/crayon/spraycan/lubecan, /obj/item/grown/bananapeel, /obj/item/food/grown/banana)
