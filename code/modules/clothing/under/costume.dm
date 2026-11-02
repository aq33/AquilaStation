/obj/item/clothing/under/costume/roman
	name = "\improper rzymski pancerz"
	desc = "Starożytny rzymski pancerz z metalowych i skórzanych pasów."
	icon_state = "roman"
	item_state = "armor"
	can_adjust = FALSE
	strip_delay = 100
	resistance_flags = NONE

/obj/item/clothing/under/costume/jabroni
	name = "strój jabroni"
	desc = "Klub skórzany jest dwa sektory dalej."
	icon_state = "darkholme"
	item_state = "darkholme"
	can_adjust = FALSE

/obj/item/clothing/under/costume/owl
	name = "strój sowy"
	desc = "Miękki brązowy kombinezon z syntetycznych piór i silnego przekonania."
	icon_state = "owl"
	can_adjust = FALSE

/obj/item/clothing/under/costume/griffin
	name = "strój gryfa"
	desc = "Miękki brązowy kombinezon z białym kołnierzem z syntetycznych piór i żądzy chaosu."
	icon_state = "griffin"
	can_adjust = FALSE

/obj/item/clothing/under/costume/cloud
	name = "przebranie chmurki"
	desc = "Przebranie przypominające puszystą chmurkę. Miejmy nadzieję, że zakrywa wszystko, czego dzieci nie powinny zobaczyć."
	icon_state = "cloud"
	can_adjust = FALSE

/obj/item/clothing/under/costume/schoolgirl
	name = "niebieski mundurek uczennicy"
	desc = "Zupełnie jak w moich japońskich anime!"
	icon_state = "schoolgirl"
	item_state = "schoolgirl"
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/costume/schoolgirl/red
	name = "czerwony mundurek uczennicy"
	icon_state = "schoolgirlred"
	item_state = "schoolgirlred"

/obj/item/clothing/under/costume/schoolgirl/green
	name = "zielony mundurek uczennicy"
	icon_state = "schoolgirlgreen"
	item_state = "schoolgirlgreen"

/obj/item/clothing/under/costume/schoolgirl/orange
	name = "pomarańczowy mundurek uczennicy"
	icon_state = "schoolgirlorange"
	item_state = "schoolgirlorange"

/obj/item/clothing/under/costume/pirate
	name = "strój pirata"
	desc = "Arr."
	icon_state = "pirate"
	item_state = "pirate"
	random_sensor = FALSE //NSV13 disabled by default
	can_adjust = FALSE

/obj/item/clothing/under/costume/soviet
	name = "radziecki mundur"
	desc = "Za Ojczyznę!"
	icon_state = "soviet"
	item_state = "soviet"
	can_adjust = FALSE

/obj/item/clothing/under/costume/redcoat
	name = "mundur czerwonego kubraka"
	desc = "Wygląda staro."
	icon_state = "redcoat"
	item_state = "redcoat"
	can_adjust = FALSE

/obj/item/clothing/under/costume/kilt
	name = "kilt"
	desc = "Buty i pled w zestawie."
	icon_state = "kilt"
	item_state = "kilt"
	body_parts_covered = CHEST|GROIN|LEGS|FEET
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/costume/kilt/highlander
	desc = "Tylko ty jesteś godny tego kiltu."

/obj/item/clothing/under/costume/kilt/highlander/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HIGHLANDER)

/obj/item/clothing/under/costume/gladiator
	name = "strój gladiatora"
	desc = "Czy nie jesteście zabawieni? Czy nie po to tu przyszliście?"
	icon_state = "gladiator"
	item_state = "gladiator"
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE

/obj/item/clothing/under/costume/gladiator/ash_walker
	desc = "Ten strój gladiatora jest pokryty popiołem i dość przestarzały."
	has_sensor = NO_SENSORS

/obj/item/clothing/under/costume/maid
	name = "strój pokojówki"
	desc = "Maid in China."
	icon_state = "maid"
	item_state = "maid"
	body_parts_covered = CHEST|GROIN
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/costume/maid/Initialize(mapload)
	. = ..()
	var/obj/item/clothing/accessory/maidapron/A = new (src)
	attach_accessory(A)

/obj/item/clothing/under/costume/geisha
	name = "strój gejszy"
	desc = "Słodki kosmiczny ninja senpai nie wchodzi w zestaw."
	icon_state = "geisha"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE

/obj/item/clothing/under/costume/kamishimo
	name = "kamishimo"
	desc = "Tradycyjne, starożytne japońskie kamishimo z Ziemi."
	icon_state = "kamishimo"
	body_parts_covered = CHEST|GROIN|ARMS
	can_adjust = FALSE

/obj/item/clothing/under/costume/villain
	name = "strój złoczyńcy"
	desc = "Zmiana garderoby to konieczność, jeśli chcesz kiedykolwiek złapać prawdziwego superbohatera."
	icon_state = "villain"
	can_adjust = FALSE

/obj/item/clothing/under/costume/sailor
	name = "strój marynarski"
	desc = "Szyper siedzi w mesie i pije dżin."
	icon_state = "sailor"
	item_state = "b_suit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/singer
	desc = "Na sam widok masz ochotę śpiewać."
	body_parts_covered = CHEST|GROIN|ARMS
	alternate_worn_layer = ABOVE_SHOES_LAYER
	can_adjust = FALSE

/obj/item/clothing/under/costume/singer/yellow
	name = "żółty strój artysty"
	icon_state = "ysing"
	item_state = "ysing"
	fitted = NO_FEMALE_UNIFORM

/obj/item/clothing/under/costume/singer/blue
	name = "niebieski strój artysty"
	icon_state = "bsing"
	item_state = "bsing"
	fitted = FEMALE_UNIFORM_TOP

/obj/item/clothing/under/costume/mummy
	name = "bandaże mumii"
	desc = "Oddaj tablicę albo cierp przez moje zwietrzałe nawiązania."
	icon_state = "mummy"
	item_state = "mummy"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE

/obj/item/clothing/under/costume/scarecrow
	name = "ubranie stracha na wróble"
	desc = "Idealny kamuflaż do ukrywania się w botanice."
	icon_state = "scarecrow"
	item_state = "scarecrow"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE

/obj/item/clothing/under/costume/draculass
	name = "płaszcz drakulessy"
	desc = "Suknia inspirowana starożytną epoką „wiktoriańską”."
	icon_state = "draculass"
	item_state = "draculass"
	body_parts_covered = CHEST|GROIN|ARMS
	fitted = FEMALE_UNIFORM_TOP
	can_adjust = FALSE

/obj/item/clothing/under/costume/drfreeze
	name = "kombinezon doktora Freeze'a"
	desc = "Przerobiony kombinezon naukowca, żeby wyglądać wyjątkowo chłodno."
	icon_state = "drfreeze"
	item_state = "drfreeze"
	can_adjust = FALSE

/obj/item/clothing/under/costume/lobster
	name = "piankowy strój homara"
	desc = "Kto ściął głowę maskotce uczelni?"
	icon_state = "lobster"
	item_state = "lobster"
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE

/obj/item/clothing/under/costume/gondola
	name = "strój ze skóry gondoli"
	desc = "No, to rozumiem."
	icon_state = "gondola"
	item_state = "lb_suit"
	can_adjust = FALSE

/obj/item/clothing/under/costume/skeleton
	name = "kombinezon szkieletu"
	desc = "Czarny kombinezon z nadrukowanym białym wzorem kości. Upiorne!"
	icon_state = "skeleton"
	item_state = "skeleton"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	fitted = NO_FEMALE_UNIFORM
	can_adjust = FALSE
	resistance_flags = NONE

/obj/item/clothing/under/costume/mech_suit
	name = "czerwony strój pilota mecha"
	desc = "Czerwony strój pilota mecha. Może sprawić, że twój tyłek wygląda na duży."
	icon_state = "red_mech_suit"
	item_state = "red_mech_suit"
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	fitted = NO_FEMALE_UNIFORM
	alternate_worn_layer = GLOVES_LAYER //covers hands but gloves can go over it. This is how these things work in my head.
	can_adjust = FALSE

/obj/item/clothing/under/costume/mech_suit/white
	name = "biały strój pilota mecha"
	desc = "Biały strój pilota mecha. Bardzo twarzowy."
	icon_state = "white_mech_suit"
	item_state = "white_mech_suit"

/obj/item/clothing/under/costume/mech_suit/blue
	name = "niebieski strój pilota mecha"
	desc = "Niebieski strój pilota mecha. Dla bardziej niechętnych pilotów mechów."
	icon_state = "blue_mech_suit"
	item_state = "blue_mech_suit"

/obj/item/clothing/under/costume/russian_officer
	name = "\improper mundur rosyjskiego oficera"
	desc = "Ostatni krzyk mody wśród rosyjskich strojów."
	icon_state = "hostanclothes"
	item_state = "hostanclothes"
	alt_covers_chest = TRUE
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 30, "stamina" = 10, "bleed" = 15)
	strip_delay = 50
	alt_covers_chest = TRUE
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE

/obj/item/clothing/under/costume/swagoutfit
	name = "szpanerski strój"
	desc = "Może pójdziesz zgarnąć jakieś laski?"
	icon_state = "SwagOutfit"
	item_state = "SwagOutfit"
	can_adjust = FALSE
