// AQUILA - przepisy browaru w drewnianej beczce. Wzór: MonkeStation, monkestation/code/modules/brewin_and_chewin/brewing
// (Monkestation/Monkestation2.0). Bez przepisów, które potrzebują rzeczy, których nie mamy (ocet, glukoza,
// słonecznik, dzwonek): śmietana, ocet, koła sera, enzym, glukoza, „Nic”, likier cukierkowy. Ceny sprzedaży to
// połowa cen Monke. Do tego polskie trunki i napoje.

/datum/brewing_recipe
	/// Co powstaje w beczce
	var/reagent_to_brew
	var/display_name
	/// Plon => ile „jednostek plonu” (zwykły plon daje 5, lepszy więcej, najwyżej 10)
	var/list/needed_crops = list()
	/// Przedmiot => ile sztuk
	var/list/needed_items = list()
	/// Odczynnik => ile jednostek musi być w beczce (zużywa się tylko tyle)
	var/list/needed_reagents = list()
	/// Odczynnik, który musi już być w beczce (drugi etap, np. jasne piwo => piwo); zużywa się cały
	var/pre_reqs
	/// Ile jednostek trunku powstaje
	var/brewed_amount = 100
	var/brew_time = 2 MINUTES
	/// Cena całej warki w zaopatrzeniu
	var/cargo_valuation = 1000
	var/helpful_hints

/datum/brewing_recipe/proc/describe_needs()
	. = list()
	for(var/atom/crop as anything in needed_crops)
		. += "[initial(crop.name)]: [needed_crops[crop]] j."
	for(var/atom/item as anything in needed_items)
		. += "[initial(item.name)]: [needed_items[item]] szt."
	for(var/datum/reagent/reagent as anything in needed_reagents)
		. += "[initial(reagent.name)]: [needed_reagents[reagent]] j."
	if(pre_reqs)
		var/datum/reagent/previous = pre_reqs
		. += "w beczce gotowy trunek: [initial(previous.name)]"

/// Przepis => instancja, ładowane raz
GLOBAL_LIST_INIT(brewing_recipes, init_brewing_recipes())

/proc/init_brewing_recipes()
	. = list()
	for(var/path in subtypesof(/datum/brewing_recipe))
		var/datum/brewing_recipe/recipe = new path
		if(recipe.reagent_to_brew)
			. += recipe

/// Cena 1 j. trunku z beczki (0, gdy trunek nie pochodzi z browaru). Najwyższa z przepisów, które go robią.
/proc/brewing_unit_price(reagent_type)
	. = 0
	for(var/datum/brewing_recipe/recipe as anything in GLOB.brewing_recipes)
		if(recipe.reagent_to_brew == reagent_type)
			. = max(., recipe.cargo_valuation / max(recipe.brewed_amount, 1))

// ---------- Piwa ----------

/datum/brewing_recipe/light_beer
	reagent_to_brew = /datum/reagent/consumable/ethanol/beer/light
	display_name = "Jasne piwo"
	needed_crops = list(/obj/item/food/grown/wheat = 40, /obj/item/food/grown/poppy = 5)
	needed_reagents = list(/datum/reagent/water = 60)
	brewed_amount = 300
	brew_time = 2 MINUTES
	cargo_valuation = 875
	helpful_hints = "Gotowe jasne piwo można dalej warzyć na piwo."

/datum/brewing_recipe/beer
	reagent_to_brew = /datum/reagent/consumable/ethanol/beer
	display_name = "Piwo"
	pre_reqs = /datum/reagent/consumable/ethanol/beer/light
	needed_crops = list(/obj/item/food/grown/wheat = 10, /obj/item/food/grown/poppy = 5)
	needed_reagents = list(/datum/reagent/water = 60)
	brewed_amount = 300
	brew_time = 2 MINUTES
	cargo_valuation = 1125

/datum/brewing_recipe/ale
	reagent_to_brew = /datum/reagent/consumable/ethanol/ale
	display_name = "Ale"
	needed_crops = list(/obj/item/food/grown/wheat = 60, /obj/item/food/grown/poppy = 5)
	needed_reagents = list(/datum/reagent/water = 120, /datum/reagent/consumable/honey = 5)
	brewed_amount = 300
	brew_time = 9 MINUTES
	cargo_valuation = 1000

// ---------- Mocne ----------

/datum/brewing_recipe/whiskey
	reagent_to_brew = /datum/reagent/consumable/ethanol/whiskey
	display_name = "Whisky"
	needed_crops = list(/obj/item/food/grown/wheat = 40)
	needed_reagents = list(/datum/reagent/water = 120)
	brewed_amount = 250
	brew_time = 15 MINUTES
	cargo_valuation = 1000

/datum/brewing_recipe/patron
	reagent_to_brew = /datum/reagent/consumable/ethanol/patron
	display_name = "Patron"
	needed_crops = list(/obj/item/food/grown/wheat = 80)
	needed_reagents = list(/datum/reagent/water = 30, /datum/reagent/consumable/menthol = 5)
	brewed_amount = 50
	brew_time = 90 SECONDS
	cargo_valuation = 1000

/datum/brewing_recipe/gin
	reagent_to_brew = /datum/reagent/consumable/ethanol/gin
	display_name = "Gin"
	needed_crops = list(/obj/item/food/grown/berries = 40, /obj/item/food/grown/citrus/lemon = 40)
	needed_items = list(/obj/item/grown/log = 5)
	needed_reagents = list(/datum/reagent/water = 160, /datum/reagent/consumable/sugar = 15)
	brewed_amount = 150
	brew_time = 6 MINUTES
	cargo_valuation = 1600

/datum/brewing_recipe/tequila
	reagent_to_brew = /datum/reagent/consumable/ethanol/tequila
	display_name = "Tequila"
	needed_crops = list(/obj/item/food/grown/citrus/lemon = 40, /obj/item/food/grown/citrus/lime = 40, /obj/item/food/grown/pineapple = 10)
	needed_items = list(/obj/item/grown/log = 5)
	needed_reagents = list(/datum/reagent/water = 50, /datum/reagent/consumable/sodiumchloride = 5)
	brewed_amount = 100
	brew_time = 3 MINUTES
	cargo_valuation = 1125

/datum/brewing_recipe/rum
	reagent_to_brew = /datum/reagent/consumable/ethanol/rum
	display_name = "Rum"
	needed_crops = list(/obj/item/food/grown/sugarcane = 60)
	needed_items = list(/obj/item/grown/log = 5)
	needed_reagents = list(/datum/reagent/water = 120, /datum/reagent/consumable/sodiumchloride = 5)
	brewed_amount = 200
	brew_time = 3 MINUTES
	cargo_valuation = 1000
	helpful_hints = "Gotowy rum z kawą i cukrem można dalej warzyć na kahluę."

/datum/brewing_recipe/kahlua
	reagent_to_brew = /datum/reagent/consumable/ethanol/kahlua
	display_name = "Kahlua"
	pre_reqs = /datum/reagent/consumable/ethanol/rum
	needed_reagents = list(/datum/reagent/consumable/sugar = 15, /datum/reagent/consumable/coffee = 60)
	brewed_amount = 150
	brew_time = 2 MINUTES
	cargo_valuation = 2500

// ---------- Miody i wina ----------

/datum/brewing_recipe/mead
	reagent_to_brew = /datum/reagent/consumable/ethanol/mead
	display_name = "Miód pitny"
	needed_reagents = list(/datum/reagent/water = 50, /datum/reagent/consumable/honey = 50)
	brewed_amount = 200
	brew_time = 6 MINUTES
	cargo_valuation = 1500

/datum/brewing_recipe/wine
	reagent_to_brew = /datum/reagent/consumable/ethanol/wine
	display_name = "Wino"
	needed_crops = list(/obj/item/food/grown/grapes = 60)
	needed_items = list(/obj/item/grown/log = 5)
	needed_reagents = list(/datum/reagent/water = 160, /datum/reagent/consumable/sugar = 15)
	brewed_amount = 100
	brew_time = 6 MINUTES
	cargo_valuation = 1500
	helpful_hints = "Gotowe wino można dalej warzyć na wermut albo trujące wino grzybowe."

/datum/brewing_recipe/vermouth
	reagent_to_brew = /datum/reagent/consumable/ethanol/vermouth
	display_name = "Wermut"
	pre_reqs = /datum/reagent/consumable/ethanol/wine
	needed_crops = list(/obj/item/food/grown/grapes = 60, /obj/item/food/grown/berries = 15)
	needed_items = list(/obj/item/grown/log = 7)
	needed_reagents = list(/datum/reagent/water = 160)
	brewed_amount = 150
	brew_time = 8 MINUTES
	cargo_valuation = 2500

/datum/brewing_recipe/fungal_wine
	reagent_to_brew = /datum/reagent/consumable/ethanol/fungal_wine
	display_name = "Wino grzybowe"
	pre_reqs = /datum/reagent/consumable/ethanol/wine
	needed_crops = list(/obj/item/food/grown/grapes = 10, /obj/item/food/grown/mushroom/plumphelmet = 5)
	needed_items = list(/obj/item/grown/log = 5)
	needed_reagents = list(/datum/reagent/toxin/amatoxin = 15)
	brewed_amount = 50
	brew_time = 16 MINUTES
	cargo_valuation = 4500

/datum/brewing_recipe/melon_liquor
	reagent_to_brew = /datum/reagent/consumable/ethanol/melon_liquor
	display_name = "Likier melonowy"
	needed_crops = list(/obj/item/food/grown/watermelon = 80, /obj/item/food/grown/poppy = 35)
	needed_items = list(/obj/item/grown/log = 5)
	needed_reagents = list(/datum/reagent/water = 160)
	brewed_amount = 100
	brew_time = 6 MINUTES
	cargo_valuation = 1000

/datum/brewing_recipe/lizard_wine
	reagent_to_brew = /datum/reagent/consumable/ethanol/lizardwine
	display_name = "Wino jaszczurcze"
	needed_crops = list(/obj/item/food/grown/poppy = 5)
	needed_items = list(/obj/item/organ/tail/lizard = 1)
	needed_reagents = list(/datum/reagent/water = 50, /datum/reagent/consumable/ethanol = 100)
	brewed_amount = 150
	brew_time = 10 MINUTES
	cargo_valuation = 5000

// ---------- Polskie ----------

/datum/brewing_recipe/kvass
	reagent_to_brew = /datum/reagent/consumable/kvass
	display_name = "Kwas chlebowy"
	needed_items = list(/obj/item/food/bread/plain = 1)
	needed_reagents = list(/datum/reagent/water = 100, /datum/reagent/consumable/sugar = 10)
	brewed_amount = 150
	brew_time = 3 MINUTES
	cargo_valuation = 600

/datum/brewing_recipe/kompot
	reagent_to_brew = /datum/reagent/consumable/kompot
	display_name = "Kompot"
	needed_crops = list(/obj/item/food/grown/apple = 20, /obj/item/food/grown/cherries = 10)
	needed_reagents = list(/datum/reagent/water = 120, /datum/reagent/consumable/sugar = 10)
	brewed_amount = 150
	brew_time = 2 MINUTES
	cargo_valuation = 500

/datum/brewing_recipe/wisniowka
	reagent_to_brew = /datum/reagent/consumable/ethanol/wisniowka
	display_name = "Wiśniówka"
	needed_crops = list(/obj/item/food/grown/cherries = 40)
	needed_reagents = list(/datum/reagent/consumable/ethanol/vodka = 60, /datum/reagent/consumable/sugar = 20)
	brewed_amount = 100
	brew_time = 8 MINUTES
	cargo_valuation = 2000

/datum/brewing_recipe/sliwowica
	reagent_to_brew = /datum/reagent/consumable/ethanol/sliwowica
	display_name = "Śliwowica"
	needed_crops = list(/obj/item/food/grown/plum = 60)
	needed_items = list(/obj/item/grown/log = 5)
	needed_reagents = list(/datum/reagent/water = 100, /datum/reagent/consumable/sugar = 20)
	brewed_amount = 100
	brew_time = 12 MINUTES
	cargo_valuation = 2250

/datum/brewing_recipe/zubrowka
	reagent_to_brew = /datum/reagent/consumable/ethanol/zubrowka
	display_name = "Żubrówka"
	needed_crops = list(/obj/item/food/grown/grass = 10)
	needed_reagents = list(/datum/reagent/consumable/ethanol/vodka = 90)
	brewed_amount = 100
	brew_time = 4 MINUTES
	cargo_valuation = 1500

/datum/brewing_recipe/krupnik
	reagent_to_brew = /datum/reagent/consumable/ethanol/krupnik
	display_name = "Krupnik"
	needed_reagents = list(/datum/reagent/consumable/ethanol/vodka = 60, /datum/reagent/consumable/honey = 30, /datum/reagent/water = 20)
	brewed_amount = 100
	brew_time = 5 MINUTES
	cargo_valuation = 1750

// ---------- Nowe trunki ----------

/datum/reagent/consumable/ethanol/melon_liquor
	name = "Likier melonowy"
	description = "Słodki, zielony likier z arbuzów."
	color = "#138808"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 30
	taste_description = "słodki melon"
	glass_icon_state = "glass_green"
	glass_name = "kieliszek likieru melonowego"
	glass_desc = "Słodki, zielony i mocniejszy, niż się wydaje."
	shot_glass_icon_state = "shotglassgreen"

/datum/reagent/consumable/ethanol/fungal_wine
	name = "Wino grzybowe"
	description = "Wino nastawione na trujących grzybach. Dla odważnych."
	color = "#6B4C8B"
	chem_flags = CHEMICAL_BASIC_DRINK
	boozepwr = 40
	taste_description = "ziemista, gorzka słodycz"
	glass_icon_state = "wineglass"
	glass_name = "kieliszek wina grzybowego"
	glass_desc = "Fioletowe i lekko świecące. Raczej nie powinno się tego pić."
	shot_glass_icon_state = "shotglassred"

/datum/reagent/consumable/ethanol/fungal_wine/on_mob_life(mob/living/carbon/drinker)
	drinker.adjustToxLoss(1, FALSE)
	drinker.adjust_hallucinations_up_to(4 SECONDS, 60 SECONDS)
	return ..()

/datum/reagent/consumable/kvass
	name = "Kwas chlebowy"
	description = "Lekko musujący, słodko-kwaśny napój z chleba."
	color = "#7A4A1C"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	taste_description = "słodki chleb"
	glass_icon_state = "glass_brown"
	glass_name = "szklanka kwasu chlebowego"
	glass_desc = "Orzeźwia lepiej niż niejedna cola."

/datum/reagent/consumable/kompot
	name = "Kompot"
	description = "Gotowane owoce w osłodzonej wodzie, jak u babci."
	color = "#B5414B"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	taste_description = "gotowane owoce"
	glass_icon_state = "glass_red"
	glass_name = "szklanka kompotu"
	glass_desc = "Z pływającymi wiśniami."

/datum/reagent/consumable/ethanol/wisniowka
	name = "Wiśniówka"
	description = "Nalewka z wiśni na wódce."
	color = "#8B1A1A"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 45
	taste_description = "słodkie wiśnie i wódka"
	glass_icon_state = "glass_red"
	glass_name = "kieliszek wiśniówki"
	glass_desc = "Ciemnoczerwona i słodka."
	shot_glass_icon_state = "shotglassred"

/datum/reagent/consumable/ethanol/sliwowica
	name = "Śliwowica"
	description = "Bardzo mocna wódka ze śliwek."
	color = "#E8D8B0"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 75
	taste_description = "śliwki i ogień"
	glass_icon_state = "glass_clear"
	glass_name = "kieliszek śliwowicy"
	glass_desc = "Pachnie śliwkami, pali jak spirytus."
	shot_glass_icon_state = "shotglassclear"

/datum/reagent/consumable/ethanol/zubrowka
	name = "Żubrówka"
	description = "Wódka z trawą żubrową, lekko ziołowa."
	color = "#D8E0A0"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 65
	taste_description = "trawa i wódka"
	glass_icon_state = "ginvodkaglass"
	glass_name = "kieliszek żubrówki"
	glass_desc = "Z jednym źdźbłem trawy w środku."
	shot_glass_icon_state = "shotglassclear"

/datum/reagent/consumable/ethanol/krupnik
	name = "Krupnik"
	description = "Słodki likier miodowy na wódce."
	color = "#C88A1E"
	chem_flags = CHEMICAL_BASIC_DRINK | CHEMICAL_RNG_GENERAL
	boozepwr = 40
	taste_description = "miód i przyprawy"
	glass_icon_state = "meadglass"
	glass_name = "kieliszek krupniku"
	glass_desc = "Złoty i słodki, najlepszy na ciepło."
	shot_glass_icon_state = "shotglassgold"
