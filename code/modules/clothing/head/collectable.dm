
//Hat Station 13

/* 

	Contents: 

		Pete's collectible hat
		Collectable slime cap
		Collectable xenomorph helmet
		Collectable chef's hat
		Collectable paper hat
		Collectable top hat
		Collectable captain's hat
		Collectable polic officer's hat
		Collectable beret
		Collectable welding helmet
		Collectable slime hat
		Collectable flat cap
		Collectable pirate hat
		Collectable kitty ears
		Collectable rabbit ears
		Collectable wizard's hat
		Collectable hard hat
		Collectable HoS hat
		Collectable HoP hat
		Collectable thunderdome helmet
		Collectable SWAT helmet

*/

/obj/item/clothing/head/collectable
	name = "kolekcjonerski kapelusz"
	desc = "Rzadki kolekcjonerski kapelusz."

/obj/item/clothing/head/collectable/petehat
	name = "ultrarzadki kapelusz Pete'a"
	desc = "Pachnie lekko plazmą."
	icon_state = "petehat"

/obj/item/clothing/head/collectable/slime
	name = "kolekcjonerska czapka ze szlamu"
	desc = "Sama przyczepia się na swoim miejscu!"
	icon_state = "slime"
	clothing_flags = SNUG_FIT
	dynamic_hair_suffix = ""

/obj/item/clothing/head/collectable/xenom
	name = "kolekcjonerski hełm ksenomorfa"
	desc = "Hss hss hss!"
	icon_state = "xenom"
	clothing_flags = SNUG_FIT

/obj/item/clothing/head/collectable/chef
	name = "kolekcjonerska czapka kucharza"
	desc = "Rzadka czapka kucharza dla kolekcjonerów nakryć głowy!"
	icon_state = "chef"
	item_state = "chef"
	dynamic_hair_suffix = ""

	dog_fashion = /datum/dog_fashion/head/chef

/obj/item/clothing/head/collectable/paper
	name = "kolekcjonerska papierowa czapka"
	desc = "To, co wygląda na zwykłą papierową czapkę, to w rzeczywistości rzadka i cenna kolekcjonerska edycja papierowej czapki. Chronić przed wodą, ogniem i bibliotekarzami."
	icon_state = "paper"

	dog_fashion = /datum/dog_fashion/head

/obj/item/clothing/head/collectable/tophat
	name = "kolekcjonerski cylinder"
	desc = "Cylinder noszony tylko przez najbardziej prestiżowych kolekcjonerów nakryć głowy."
	icon_state = "tophat"
	item_state = "that"

/obj/item/clothing/head/collectable/captain
	name = "kolekcjonerska czapka kapitana"
	desc = "Kolekcjonerska czapka, w której wyglądasz jak prawdziwy dowódca!"
	icon_state = "captain"
	item_state = "caphat"

	dog_fashion = /datum/dog_fashion/head/captain

/obj/item/clothing/head/collectable/police
	name = "kolekcjonerska czapka policjanta"
	desc = "Kolekcjonerska czapka policjanta. Podkreśla, że to ty jesteś PRAWEM."
	icon_state = "policehelm"
	dynamic_hair_suffix = ""

	dog_fashion = /datum/dog_fashion/head/warden

/obj/item/clothing/head/collectable/beret
	name = "kolekcjonerski beret"
	desc = "Kolekcjonerski czerwony beret. Pachnie lekko czosnkiem."
	icon_state = "beret"

	dog_fashion = /datum/dog_fashion/head/beret

/obj/item/clothing/head/collectable/welding
	name = "kolekcjonerska przyłbica spawalnicza"
	desc = "Kolekcjonerska przyłbica spawalnicza. Teraz z ołowiem o 80% mniej! Nie do prawdziwego spawania. Każde spawanie w tej przyłbicy odbywa się na własne ryzyko właściciela!"
	icon_state = "welding"
	item_state = "welding"
	clothing_flags = SNUG_FIT

/obj/item/clothing/head/collectable/slime
	name = "kolekcjonerski kapelusz ze szlamu"
	desc = "Zupełnie jak prawdziwy ślimak mózgowy!"
	icon_state = "headslime"
	item_state = "headslime"
	clothing_flags = SNUG_FIT

/obj/item/clothing/head/collectable/flatcap
	name = "kolekcjonerski kaszkiet"
	desc = "Kolekcjonerski kaszkiet rolnika!"
	icon_state = "flat_cap"
	item_state = "detective"

/obj/item/clothing/head/collectable/pirate
	name = "kolekcjonerski kapelusz piracki"
	desc = "Byłby z ciebie świetny Straszliwy Syndyk Roberts!"
	icon_state = "pirate"
	item_state = "pirate"

	dog_fashion = /datum/dog_fashion/head/pirate

/obj/item/clothing/head/collectable/kitty
	name = "kolekcjonerskie kocie uszy"
	desc = "Futerko w dotyku jest... trochę zbyt realistyczne."
	icon_state = "kitty"
	item_state = "kitty"
	clothing_flags = SNUG_FIT
	dynamic_hair_suffix = ""

	dog_fashion = /datum/dog_fashion/head/kitty

/obj/item/clothing/head/collectable/rabbitears
	name = "kolekcjonerskie królicze uszy"
	desc = "Nie przynoszą tyle szczęścia co łapka!"
	icon_state = "bunny"
	item_state = "bunny"
	clothing_flags = SNUG_FIT
	dynamic_hair_suffix = ""

	dog_fashion = /datum/dog_fashion/head/rabbit

/obj/item/clothing/head/collectable/wizard
	name = "kolekcjonerski kapelusz czarodzieja"
	desc = "UWAGA: wszelkie magiczne moce zdobyte dzięki noszeniu tego kapelusza są czysto przypadkowe."
	icon_state = "wizard"

	dog_fashion = /datum/dog_fashion/head/blue_wizard

/obj/item/clothing/head/collectable/hardhat
	name = "kolekcjonerski kask"
	desc = "UWAGA! Nie daje prawdziwej ochrony ani światła, ale, cholera, jak elegancko wygląda!"
	icon_state = "hardhat0_yellow"
	item_state = "hardhat0_yellow"
	clothing_flags = SNUG_FIT

	dog_fashion = /datum/dog_fashion/head

/obj/item/clothing/head/collectable/HoS
	name = "kolekcjonerska czapka Komendanta"
	desc = "Teraz ty też możesz bić więźniów, wymierzać głupie wyroki i aresztować bez powodu!"
	icon_state = "hoscap"
	dynamic_hair_suffix = ""

/obj/item/clothing/head/collectable/HoP
	name = "kolekcjonerska czapka Starszego Oficera"
	desc = "Twoja kolej, żeby żądać stosów papierów, podpisów i pieczątek i zatrudniać kolejnych klaunów! Dokumenty proszę!"
	icon_state = "hopcap"

	dog_fashion = /datum/dog_fashion/head/hop

/obj/item/clothing/head/collectable/thunderdome
	name = "kolekcjonerski hełm z Thunderdome"
	desc = "Naprzód, Czerwoni! To znaczy Zieloni! To znaczy Czerwoni! Nie, Zieloni!"
	icon_state = "thunderdome"
	item_state = "thunderdome"
	clothing_flags = SNUG_FIT
	flags_inv = HIDEHAIR

/obj/item/clothing/head/collectable/swat
	name = "kolekcjonerski hełm SWAT"
	desc = "To nie jest prawdziwa krew. To czerwona farba." //Reference to the actual description
	icon_state = "swat"
	item_state = "swat"
	clothing_flags = SNUG_FIT
	flags_inv = HIDEHAIR
