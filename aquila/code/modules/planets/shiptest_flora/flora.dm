// AQUILA - roślinność planety wulkanicznej z Shiptesta (shiptest-ss13/Shiptest, kod AGPLv3, ikony CC BY-SA 3.0):
// code/game/objects/structures/flora.dm. Losowanie wariantów robią już nasze Initialize typów bazowych
// (ausbushes, rock, tree/dead), więc tutaj tylko nowe ikony, nazwy i światło.

/obj/structure/flora/firebush
	name = "płonący krzew"
	desc = "Krzew trawiony przez płomienie. Może odrodzi się z popiołów jak feniks?"
	icon = 'aquila/icons/planets/flora/hellflora.dmi'
	icon_state = "hell_bush"
	light_color = "#e08300"
	light_power = 2
	light_range = 3
	resistance_flags = LAVA_PROOF

// Piekielne krzewy: kolor światła losowany przed ..(), żeby źródło światła powstało już z nim

/obj/structure/flora/ausbushes/fullgrass/hell
	name = "gęsta piekielna trawa"
	desc = "Gęsta kępa trawy o czerwonym odcieniu."
	icon = 'aquila/icons/planets/flora/hellflora.dmi'
	light_range = 2
	light_power = 3
	resistance_flags = LAVA_PROOF
	gender = PLURAL

/obj/structure/flora/ausbushes/fullgrass/hell/Initialize(mapload)
	light_color = pick("#e87800", "#780606")
	. = ..()

/obj/structure/flora/ausbushes/sparsegrass/hell
	name = "rzadka piekielna trawa"
	desc = "Rzadka kępa trawy o czerwonym odcieniu."
	icon = 'aquila/icons/planets/flora/hellflora.dmi'
	light_range = 2
	light_power = 3
	resistance_flags = LAVA_PROOF
	gender = PLURAL

/obj/structure/flora/ausbushes/sparsegrass/hell/Initialize(mapload)
	light_color = pick("#e87800", "#780606")
	. = ..()

/obj/structure/flora/ausbushes/grassybush/hell
	name = "szkarłatny krzew"
	desc = "Szkarłatny krzew rosnący na planetach wulkanicznych."
	icon = 'aquila/icons/planets/flora/hellflora.dmi'
	light_color = "#c70404"
	light_range = 2
	light_power = 3
	resistance_flags = LAVA_PROOF

/obj/structure/flora/ausbushes/hell
	name = "tlący się krzew"
	desc = "Jakaś pomarańczowa roślina, która chyba powoli się spala."
	icon = 'aquila/icons/planets/flora/hellflora.dmi'
	light_range = 2
	light_power = 1
	resistance_flags = LAVA_PROOF

/obj/structure/flora/ausbushes/hell/Initialize(mapload)
	light_color = pick("#e87800", "#780606")
	. = ..()

/obj/structure/flora/ausbushes/fernybush/hell
	name = "piekielna paproć"
	desc = "Jakaś pomarańczowa paproć."
	icon = 'aquila/icons/planets/flora/hellflora.dmi'
	light_range = 2
	light_power = 1
	resistance_flags = LAVA_PROOF

/obj/structure/flora/ausbushes/fernybush/hell/Initialize(mapload)
	light_color = pick("#e87800", "#780606")
	. = ..()

/obj/structure/flora/ausbushes/genericbush/hell
	name = "piekielny krzew"
	desc = "Mały szkarłatny krzew."
	icon = 'aquila/icons/planets/flora/hellflora.dmi'
	light_range = 2
	light_power = 2
	resistance_flags = LAVA_PROOF

/obj/structure/flora/ausbushes/genericbush/hell/Initialize(mapload)
	light_color = pick("#e87800", "#780606")
	. = ..()

/obj/structure/flora/ausbushes/ywflowers/hell
	name = "lawokwiaty"
	desc = "Czerwone i pomarańczowe kwiaty. Chyba lekko się żarzą."
	icon = 'aquila/icons/planets/flora/hellflora.dmi'
	light_color = "#aba507"
	light_power = 3
	light_range = 2
	resistance_flags = LAVA_PROOF
	gender = PLURAL

// Skały

/obj/structure/flora/rock/lava
	name = "lawowa skała"
	desc = "Wulkaniczna skała, z której tryska lawa."
	icon = 'aquila/icons/planets/flora/lavarocks.dmi'
	light_color = "#ab4907"
	light_power = 3
	light_range = 2

/obj/structure/flora/rock/pile/lava
	name = "odłamki skalne"
	desc = "Postrzępione odłamki skały wulkanicznej wystające z ziemi."
	icon = 'aquila/icons/planets/flora/lavarocks.dmi'
	gender = PLURAL

/// Ten sam sprite co nasza /obj/structure/flora/rock, inna nazwa i opis
/obj/structure/flora/rock/hell
	name = "skała"
	desc = "Wulkaniczna skała, jedna z niewielu znajomych rzeczy na tej planecie."

// Drzewa

/obj/structure/flora/tree/dead/hell
	name = "szkarłatne drzewo"
	desc = "Szkarłatne drzewo, z którego sączy się lawa, dając lekką poświatę."
	icon = 'aquila/icons/planets/flora/lavatrees.dmi'
	light_color = LIGHT_COLOR_BLOOD_MAGIC
	light_range = 2
	light_power = 0.85
	resistance_flags = LAVA_PROOF

/obj/structure/flora/tree/dead/tall
	name = "wysokie martwe drzewo"
	desc = "Ostatnie ślady niegdyś majestatycznego drzewa."
	icon = 'aquila/icons/planets/flora/tall_trees.dmi'
	resistance_flags = LAVA_PROOF

/obj/structure/flora/tree/dead/tall/Initialize(mapload)
	. = ..()
	icon_state = "tree_[rand(1, 3)]"

/obj/structure/flora/tree/dead/tall/grey
	name = "skamieniały pień"
	desc = "Pradawne drzewo zwęglone przez ogień i popiół. Został z niego tylko szkielet."
	icon = 'aquila/icons/planets/flora/tall_trees_dead.dmi'

/obj/structure/flora/tree/dead/barren
	name = "skamieniałe drzewo"
	desc = "Pradawny pień zmumifikowany przez upływ czasu. Ten wciąż ma w sobie trochę fioletu."
	icon = 'aquila/icons/planets/flora/barren_tree.dmi'
	icon_state = "barren_large"
	color = "#846996"

/obj/structure/flora/tree/dead/barren/Initialize(mapload)
	. = ..()
	color = pick("#846996", "#7b4e99", "#924fab")
	icon_state = "barren_large"
