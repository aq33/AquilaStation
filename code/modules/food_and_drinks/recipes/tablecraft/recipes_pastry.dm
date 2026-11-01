
// see code/module/crafting/table.dm

////////////////////////////////////////////////DONUTS////////////////////////////////////////////////

/datum/crafting_recipe/food/donut
	time = 15
	name = "pączek"
	reqs = list(
		/datum/reagent/consumable/sugar = 1,
		/obj/item/food/pastrybase = 1
	)
	result = /obj/item/food/donut/plain
	subcategory = CAT_PASTRY


/datum/crafting_recipe/food/donut/chaos
	name = "pączek chaosu"
	reqs = list(
		/datum/reagent/consumable/frostoil = 5,
		/datum/reagent/consumable/capsaicin = 5,
		/obj/item/food/pastrybase = 1
	)
	result = /obj/item/food/donut/chaos

/datum/crafting_recipe/food/donut/meat
	time = 15
	name = "mięsny pączek"
	reqs = list(
		/obj/item/food/meat/rawcutlet = 1,
		/obj/item/food/pastrybase = 1
	)
	result = /obj/item/food/donut/meat

/datum/crafting_recipe/food/donut/jelly
	name = "pączek z dżemem"
	reqs = list(
		/datum/reagent/consumable/berryjuice = 5,
		/obj/item/food/pastrybase = 1
	)
	result = /obj/item/food/donut/jelly/plain

/datum/crafting_recipe/food/donut/slimejelly
	name = "pączek z dżemem ze szlamu"
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/food/pastrybase = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/plain


/datum/crafting_recipe/food/donut/berry
	name = "różowy pączek"
	reqs = list(
		/datum/reagent/consumable/berryjuice = 3,
		/obj/item/food/donut/plain = 1
	)
	result = /obj/item/food/donut/berry

/datum/crafting_recipe/food/donut/trumpet
	name = "pączek kosmonauty"
	reqs = list(
		/datum/reagent/medicine/polypyr = 3,
		/obj/item/food/donut/plain = 1
	)

	result = /obj/item/food/donut/trumpet

/datum/crafting_recipe/food/donut/apple
	name = "pączek jabłkowy"
	reqs = list(
		/datum/reagent/consumable/applejuice = 3,
		/obj/item/food/donut/plain = 1
	)
	result = /obj/item/food/donut/apple

/datum/crafting_recipe/food/donut/caramel
	name = "pączek karmelowy"
	reqs = list(
		/datum/reagent/consumable/caramel = 3,
		/obj/item/food/donut/plain = 1
	)
	result = /obj/item/food/donut/caramel

/datum/crafting_recipe/food/donut/choco
	name = "pączek czekoladowy"
	reqs = list(
		/obj/item/food/chocolatebar = 1,
		/obj/item/food/donut/plain = 1
	)
	result = /obj/item/food/donut/choco

/datum/crafting_recipe/food/donut/blumpkin
	name = "pączek z blumpkina"
	reqs = list(
		/datum/reagent/consumable/blumpkinjuice = 3,
		/obj/item/food/donut/plain = 1
	)
	result = /obj/item/food/donut/blumpkin

/datum/crafting_recipe/food/donut/bungo
	name = "pączek bungo"
	reqs = list(
		/datum/reagent/consumable/bungojuice = 3,
		/obj/item/food/donut/plain = 1
	)
	result = /obj/item/food/donut/bungo

/datum/crafting_recipe/food/donut/matcha
	name = "pączek matcha"
	reqs = list(
		/datum/reagent/toxin/teapowder = 3,
		/obj/item/food/donut/plain = 1
	)
	result = /obj/item/food/donut/matcha

////////////////////////////////////////////////////JELLY DONUTS///////////////////////////////////////////////////////

/datum/crafting_recipe/food/donut/jelly/berry
	name = "różowy pączek z dżemem"
	reqs = list(
		/datum/reagent/consumable/berryjuice = 3,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/berry

/datum/crafting_recipe/food/donut/jelly/trumpet
	name = "pączek kosmonauty z dżemem"
	reqs = list(
		/datum/reagent/medicine/polypyr = 3,
		/obj/item/food/donut/jelly/plain = 1
	)

	result = /obj/item/food/donut/jelly/trumpet

/datum/crafting_recipe/food/donut/jelly/apple
	name = "jabłkowy pączek z dżemem"
	reqs = list(
		/datum/reagent/consumable/applejuice = 3,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/apple

/datum/crafting_recipe/food/donut/jelly/caramel
	name = "karmelowy pączek z dżemem"
	reqs = list(
		/datum/reagent/consumable/caramel = 3,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/caramel

/datum/crafting_recipe/food/donut/jelly/choco
	name = "czekoladowy pączek z dżemem"
	reqs = list(
		/obj/item/food/chocolatebar = 1,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/choco

/datum/crafting_recipe/food/donut/jelly/blumpkin
	name = "pączek z dżemem z blumpkina"
	reqs = list(
		/datum/reagent/consumable/blumpkinjuice = 3,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/blumpkin

/datum/crafting_recipe/food/donut/jelly/bungo
	name = "pączek bungo z dżemem"
	reqs = list(
		/datum/reagent/consumable/bungojuice = 3,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/bungo

/datum/crafting_recipe/food/donut/jelly/matcha
	name = "pączek matcha z dżemem"
	reqs = list(
		/datum/reagent/toxin/teapowder = 3,
		/obj/item/food/donut/jelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/matcha

////////////////////////////////////////////////////SLIME  DONUTS///////////////////////////////////////////////////////

/datum/crafting_recipe/food/donut/slimejelly/berry
	name = "różowy pączek z dżemem ze szlamu"
	reqs = list(
		/datum/reagent/consumable/berryjuice = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/berry

/datum/crafting_recipe/food/donut/slimejelly/trumpet
	name = "pączek kosmonauty z dżemem ze szlamu"
	reqs = list(
		/datum/reagent/medicine/polypyr = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)

	result = /obj/item/food/donut/jelly/slimejelly/trumpet

/datum/crafting_recipe/food/donut/slimejelly/apple
	name = "jabłkowy pączek z dżemem ze szlamu"
	reqs = list(
		/datum/reagent/consumable/applejuice = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/apple

/datum/crafting_recipe/food/donut/slimejelly/caramel
	name = "karmelowy pączek z dżemem ze szlamu"
	reqs = list(
		/datum/reagent/consumable/caramel = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/caramel

/datum/crafting_recipe/food/donut/slimejelly/choco
	name = "czekoladowy pączek z dżemem ze szlamu"
	reqs = list(
		/obj/item/food/chocolatebar = 1,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/choco

/datum/crafting_recipe/food/donut/slimejelly/blumpkin
	name = "pączek z blumpkina z dżemem ze szlamu"
	reqs = list(
		/datum/reagent/consumable/blumpkinjuice = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/blumpkin

/datum/crafting_recipe/food/donut/slimejelly/bungo
	name = "pączek bungo z dżemem ze szlamu"
	reqs = list(
		/datum/reagent/consumable/bungojuice = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/bungo

/datum/crafting_recipe/food/donut/slimejelly/matcha
	name = "pączek matcha z dżemem ze szlamu"
	reqs = list(
		/datum/reagent/toxin/teapowder = 3,
		/obj/item/food/donut/jelly/slimejelly/plain = 1
	)
	result = /obj/item/food/donut/jelly/slimejelly/matcha

////////////////////////////////////////////////WAFFLES AND PANCAKES////////////////////////////////////////////////

/datum/crafting_recipe/food/waffles
	time = 15
	name = "gofry"
	reqs = list(
		/obj/item/food/pastrybase = 2
	)
	result = /obj/item/food/waffles
	subcategory = CAT_PASTRY


/datum/crafting_recipe/food/soylenviridians
	name = "Soylent Viridians"
	reqs = list(
		/obj/item/food/pastrybase = 2,
		/obj/item/food/grown/soybeans = 1
	)
	result = /obj/item/food/soylenviridians
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/soylentgreen
	name = "Soylent Green"
	reqs = list(
		/obj/item/food/pastrybase = 2,
		/obj/item/food/meat/slab/human = 2
	)
	result = /obj/item/food/soylentgreen
	subcategory = CAT_PASTRY


/datum/crafting_recipe/food/rofflewaffles
	name = "gofry Roffle"
	reqs = list(
		/datum/reagent/drug/mushroomhallucinogen = 5,
		/obj/item/food/pastrybase = 2
	)
	result = /obj/item/food/rofflewaffles
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/pancakes
	name = "naleśnik"
	reqs = list(
		/obj/item/food/pastrybase = 1
	)
	result = /obj/item/food/pancakes
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/bbpancakes
	name = "naleśnik z borówkami"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/berries = 1
	)
	result = /obj/item/food/pancakes/blueberry
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/ccpancakes
	name = "naleśnik z kawałkami czekolady"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/chocolatebar = 1
	)
	result = /obj/item/food/pancakes/chocolatechip
	subcategory = CAT_PASTRY


////////////////////////////////////////////////DONKPOCCKETS////////////////////////////////////////////////

/datum/crafting_recipe/food/donkpocket
	time = 15
	name = "pieróg"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/meatball = 1
	)
	result = /obj/item/food/donkpocket
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/dankpocket
	time = 15
	name = "spizgany pierożek"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/cannabis = 1
	)
	result = /obj/item/food/donkpocket/dankpocket
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/spicy
	time = 15
	name = "ostry pierożek"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/chili = 1
	)
	result = /obj/item/food/donkpocket/spicy
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/teriyaki
	time = 15
	name = "azjatycki pierożek"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/datum/reagent/consumable/soysauce = 3
	)
	result = /obj/item/food/donkpocket/teriyaki
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/pizza
	time = 15
	name = "pizza-pieróg"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/tomato = 1
	)
	result = /obj/item/food/donkpocket/pizza
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/honk
	time = 15
	name = "bananowy pierożek"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/banana = 1,
		/datum/reagent/consumable/sugar = 3
	)
	result = /obj/item/food/donkpocket/honk
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/berry
	time = 15
	name = "jagodowy pierożek"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/berries = 1
	)
	result = /obj/item/food/donkpocket/berry
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/donkpocket/gondola
	time = 15
	name = "pierożek finlandzki"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/datum/reagent/tranquility = 5
	)
	result = /obj/item/food/donkpocket/gondola
	subcategory = CAT_PASTRY

////////////////////////////////////////////////MUFFINS////////////////////////////////////////////////

/datum/crafting_recipe/food/muffin
	time = 15
	name = "muffinka"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/pastrybase = 1
	)
	result = /obj/item/food/muffin
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/berrymuffin
	name = "muffinka jagodowa"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/berries = 1
	)
	result = /obj/item/food/muffin/berry
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/booberrymuffin
	name = "upiorna muffinka"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/berries = 1,
		/obj/item/ectoplasm = 1
	)
	result = /obj/item/food/muffin/booberry
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/moffin
	name = "ćmuffinka"
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/pastrybase = 1,
		/obj/item/stack/sheet/cotton/cloth = 1,
	)
	result = /obj/item/food/muffin/moffin
	subcategory = CAT_PASTRY

////////////////////////////////////////////OTHER////////////////////////////////////////////

/datum/crafting_recipe/food/khachapuri
	name = "chaczapuri"
	reqs = list(
		/datum/reagent/consumable/eggyolk = 5,
		/obj/item/food/cheese/wedge = 1,
		/obj/item/food/bread/plain = 1
	)
	result = /obj/item/food/khachapuri
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/sugarcookie
	time = 15
	name = "ciasteczko cukrowe"
	reqs = list(
		/datum/reagent/consumable/sugar = 5,
		/obj/item/food/pastrybase = 1
	)
	result = /obj/item/food/cookie/sugar
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/fortunecookie
	time = 15
	name = "ciasteczko z wróżbą"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/paper = 1
	)
	parts =	list(
		/obj/item/paper = 1
	)
	result = /obj/item/food/fortunecookie
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/poppypretzel
	time = 15
	name = "precel z makiem"
	reqs = list(
		/obj/item/plant_seeds/preset/poppy = 1,
		/obj/item/food/pastrybase = 1
	)
	result = /obj/item/food/poppypretzel
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/plumphelmetbiscuit
	time = 15
	name = "herbatnik z pulchnego hełmu"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/mushroom/plumphelmet = 1
	)
	result = /obj/item/food/plumphelmetbiscuit
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/cracker
	time = 15
	name = "krakers"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/food/pastrybase = 1,
	)
	result = /obj/item/food/cracker
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/chococornet
	name = "rożek czekoladowy"
	reqs = list(
		/datum/reagent/consumable/sodiumchloride = 1,
		/obj/item/food/pastrybase = 1,
		/obj/item/food/chocolatebar = 1
	)
	result = /obj/item/food/chococornet
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/oatmealcookie
	name = "ciasteczko owsiane"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/oat = 1
	)
	result = /obj/item/food/cookie/oatmeal
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/raisincookie
	name = "ciasteczko z rodzynkami"
	reqs = list(
		/obj/item/food/no_raisin = 1,
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/oat = 1
	)
	result = /obj/item/food/cookie/raisin
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/cherrycupcake
	name = "babeczka wiśniowa"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/cherries = 1
	)
	result = /obj/item/food/cherrycupcake
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/bluecherrycupcake
	name = "babeczka z niebieską wiśnią"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/bluecherries = 1
	)
	result = /obj/item/food/cherrycupcake/blue
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/jupitercupcake
	name = "babeczka jowiszowa"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/food/grown/mushroom/jupitercup = 1,
		/datum/reagent/consumable/caramel = 3,
	)
	result = /obj/item/food/jupitercupcake
	category = CAT_PASTRY

/datum/crafting_recipe/food/honeybun
	name = "bułeczka miodowa"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/datum/reagent/consumable/honey = 5
	)
	result = /obj/item/food/honeybun
	subcategory = CAT_PASTRY

/datum/crafting_recipe/food/ravtart
	name = "Rav'tart"
	reqs = list(
		/obj/item/food/pastrybase = 1,
		/obj/item/stack/tile/bronze = 1,
		/obj/item/food/grown/berries = 2,
		/obj/item/food/grown/citrus/orange = 1
	)
	result = /obj/item/food/ravtart
	subcategory = CAT_PASTRY
