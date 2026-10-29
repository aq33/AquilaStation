////////////////////////////////////////////////////////////////////////////////
/// Drinks.
////////////////////////////////////////////////////////////////////////////////
/obj/item/reagent_containers/food/drinks
	name = "napój"
	desc = "pycha"
	icon = 'icons/obj/drinks.dmi'
	icon_state = null
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	reagent_flags = OPENCONTAINER | DUNKABLE
	var/gulp_size = 5 //This is now officially broken ... need to think of a nice way to fix it.
	possible_transfer_amounts = list(5,10,15,20,25,30,50)
	volume = 50
	resistance_flags = NONE
	var/isGlass = TRUE //Whether the 'bottle' is made of glass or not so that milk cartons dont shatter when someone gets hit by it
	var/beingChugged = FALSE //We don't want people downing 100u super fast with drinking glasses

/obj/item/reagent_containers/food/drinks/on_reagent_change(changetype)
	. = ..()
	gulp_size = max(round(reagents.total_volume / 5), 5)

/obj/item/reagent_containers/food/drinks/attack(mob/living/M, mob/user, def_zone)

	if(!reagents || !reagents.total_volume)
		to_chat(user, "<span class='warning'>[src] jest pusty!</span>")
		return 0

	if(!canconsume(M, user))
		return 0

	if (!is_drainable())
		to_chat(user, "<span class='warning'>[src] nie został otwarty!</span>")
		return 0
	var/gulp_amount = gulp_size
	if(M == user)
		if(user.zone_selected == BODY_ZONE_PRECISE_MOUTH && !beingChugged)
			beingChugged = TRUE
			user.visible_message("<span class='notice'>[user] zaczyna duszkiem pić [src].</span>", \
				"<span class='notice'>Zaczynasz duszkiem pić [src].</span>")
			if(!do_mob(user, M))
				return
			if(!reagents || !reagents.total_volume)
				return
			gulp_amount = 50
			user.visible_message("<span class='notice'>[user] wypija [src] duszkiem.</span>", \
				"<span class='notice'>Wypijasz [src] duszkiem.</span>")
			beingChugged = FALSE
		else
			user.visible_message("<span class='notice'>[user] bierze łyk [src].</span>", \
				"<span class='notice'>Bierzesz łyk [src].</span>")
		if(HAS_TRAIT(M, TRAIT_VORACIOUS))
			M.changeNext_move(CLICK_CD_MELEE * 0.5) //chug! chug! chug!

	else
		M.visible_message("<span class='danger'>[user] próbuje napoić [M] zawartością [src].</span>", \
			"<span class='userdanger'>[user] próbuje napoić cię zawartością [src].</span>")
		if(!do_mob(user, M))
			return
		if(!reagents || !reagents.total_volume)
			return // The drink might be empty after the delay, such as by spam-feeding
		M.visible_message("<span class='danger'>[user] poi [M] zawartością [src].</span>", \
			"<span class='userdanger'>[user] poi cię zawartością [src].</span>")
		log_combat(user, M, "fed", reagents.log_list())

	var/fraction = min(gulp_amount/reagents.total_volume, 1)
	checkLiked(fraction, M)
	reagents.reaction(M, INGEST, fraction)
	reagents.trans_to(M, gulp_amount, transfered_by = user)
	playsound(M.loc,'sound/items/drink.ogg', rand(10,50), 1)
	SEND_SIGNAL(src, COMSIG_DRINK_DRANK, M, user) // AQ EDIT - bitrunning
	return 1

/obj/item/reagent_containers/food/drinks/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return

	if(target.is_refillable() && is_drainable()) //Something like a glass. Player probably wants to transfer TO it.
		if(!reagents.total_volume)
			to_chat(user, "<span class='warning'>[src] jest pusty.</span>")
			return

		if(target.reagents.holder_full())
			to_chat(user, "<span class='warning'>[target] jest pełny.</span>")
			return

		var/refill = reagents.get_master_reagent_id()
		var/trans = src.reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, "<span class='notice'>Przelewasz [trans] j. roztworu do [target].</span>")
		playsound(src, "aquila/sound/items/pour.ogg", 15, TRUE) // AQUILA EDIT

		if(iscyborg(user)) //Cyborg modules that include drinks automatically refill themselves, but drain the borg's cell
			var/mob/living/silicon/robot/bro = user
			bro.cell.use(30)
			addtimer(CALLBACK(reagents, TYPE_PROC_REF(/datum/reagents, add_reagent), refill, trans), 600)

	else if(target.is_drainable()) //A dispenser. Transfer FROM it TO us.
		if (!is_refillable())
			to_chat(user, "<span class='warning'>Zawleczka [src] nie jest otwarta!</span>")
			return

		if(!target.reagents.total_volume)
			to_chat(user, "<span class='warning'>[target] jest pusty.</span>")
			return

		if(reagents.holder_full())
			to_chat(user, "<span class='warning'>[src] jest pełny.</span>")
			return

		var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, transfered_by = user)
		to_chat(user, "<span class='notice'>Napełniasz [src] zawartością [target] ([trans] j.).</span>")

/obj/item/reagent_containers/food/drinks/attackby(obj/item/I, mob/user, params)
	var/hotness = I.is_hot()
	if(hotness && reagents)
		reagents.expose_temperature(hotness)
		to_chat(user, "<span class='notice'>Podgrzewasz [name] za pomocą [I]!</span>")
	..()

/obj/item/reagent_containers/food/drinks/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!.) //if the bottle wasn't caught
		smash(hit_atom, throwingdatum?.thrower, TRUE)

/obj/item/reagent_containers/food/drinks/proc/smash(atom/target, mob/thrower, ranged = FALSE)
	if(!isGlass)
		return
	if(QDELING(src) || !target)		//Invalid loc
		return
	if(bartender_check(target) && ranged)
		return
	var/obj/item/broken_bottle/B = new (loc)
	B.icon_state = icon_state
	var/icon/I = new('icons/obj/drinks.dmi', src.icon_state)
	I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = I
	B.name = "[name] (uszkodzenie)"
	if(ranged)
		B.throw_scatter() // AQUILA EDIT - Yogstation#12789
	if(prob(33))
		var/obj/item/shard/S = new(drop_location())
		target.Bumped(S)
	playsound(src, "shatter", 70, 1)
	transfer_fingerprints_to(B)
	qdel(src)
	target.Bumped(B)

/obj/item/reagent_containers/food/drinks/bullet_act(obj/item/projectile/P)
	. = ..()
	if(!(P.nodamage) && P.damage_type == BRUTE && !QDELETED(src))
		var/atom/T = get_turf(src)
		smash(T)
		return



////////////////////////////////////////////////////////////////////////////////
/// Drinks. END
////////////////////////////////////////////////////////////////////////////////


/obj/item/reagent_containers/food/drinks/trophy
	name = "cynowy puchar"
	desc = "Każdy dostaje trofeum."
	icon_state = "pewter_cup"
	w_class = WEIGHT_CLASS_TINY
	force = 1
	throwforce = 1
	amount_per_transfer_from_this = 5
	materials = list(/datum/material/iron=100)
	possible_transfer_amounts = list()
	volume = 5
	flags_1 = CONDUCT_1
	spillable = TRUE
	resistance_flags = FIRE_PROOF
	isGlass = FALSE

/obj/item/reagent_containers/food/drinks/trophy/gold_cup
	name = "złoty puchar"
	desc = "Jesteś zwycięzca!"
	icon_state = "golden_cup"
	w_class = WEIGHT_CLASS_BULKY
	force = 14
	throwforce = 10
	amount_per_transfer_from_this = 20
	materials = list(/datum/material/gold=1000)
	volume = 150

/obj/item/reagent_containers/food/drinks/trophy/silver_cup
	name = "srebrny puchar"
	desc = "Najlepszy z przegranych!"
	icon_state = "silver_cup"
	w_class = WEIGHT_CLASS_NORMAL
	force = 10
	throwforce = 8
	amount_per_transfer_from_this = 15
	materials = list(/datum/material/silver=800)
	volume = 100


/obj/item/reagent_containers/food/drinks/trophy/bronze_cup
	name = "brązowy puchar"
	desc = "Przynajmniej jesteś na podium!"
	icon_state = "bronze_cup"
	w_class = WEIGHT_CLASS_SMALL
	force = 5
	throwforce = 4
	amount_per_transfer_from_this = 10
	materials = list(/datum/material/iron=400)
	volume = 25

///////////////////////////////////////////////Drinks
//Notes by Darem: Drinks are simply containers that start preloaded. Unlike condiments, the contents can be ingested directly
//	rather then having to add it to something else first. They should only contain liquids. They have a default container size of 50.
//	Formatting is the same as food.

/obj/item/reagent_containers/food/drinks/coffee
	name = "krzepka kawa"
	desc = "Ostrożnie, napój, którym zaraz się delektujesz, jest bardzo gorący."
	icon = 'nsv13/icons/obj/coffee.dmi' //NSV13 - COFFEE ICON
	icon_state = "coffee"
	list_reagents = list(/datum/reagent/consumable/coffee = 30)
	spillable = TRUE
	resistance_flags = FREEZE_PROOF
	isGlass = FALSE
	foodtype = BREAKFAST

/obj/item/reagent_containers/food/drinks/ice
	name = "kubek z lodem"
	desc = "Ostrożnie, zimny lód, nie gryźć."
	custom_price = 5
	icon_state = "coffee"
	list_reagents = list(/datum/reagent/consumable/ice = 30)
	spillable = TRUE
	isGlass = FALSE

/obj/item/reagent_containers/food/drinks/ice/prison
	name = "kubek z brudnym lodem"
	desc = "Albo wodociąg Nanotrasen jest skażony, albo ta maszyna naprawdę wydaje cytrynowy, czekoladowy i wiśniowy kruszony lód."
	list_reagents  = list(/datum/reagent/consumable/ice = 25, /datum/reagent/liquidgibs = 5)

/obj/item/reagent_containers/food/drinks/mug/ // parent type is literally just so empty mug sprites are a thing
	name = "kubek"
	desc = "Napój podany w eleganckim kubku."
	icon_state = "tea"
	item_state = "coffee"
	spillable = TRUE

/obj/item/reagent_containers/food/drinks/mug/on_reagent_change(changetype)
	if(reagents.total_volume)
		icon_state = "tea"
	else
		icon_state = "tea_empty"

/obj/item/reagent_containers/food/drinks/mug/tea
	name = "herbata Duke Purple"
	desc = "Obraza Duke Purple to obraza Kosmicznej Królowej! Każdy porządny dżentelmen stanie z tobą do walki, jeśli zbezcześcisz tę herbatę."
	list_reagents = list(/datum/reagent/consumable/tea = 30)

/obj/item/reagent_containers/food/drinks/mug/cocoa
	name = "holenderskie gorące kakao"
	desc = "Wyprodukowano w Kosmicznej Ameryce Południowej."
	list_reagents = list(/datum/reagent/consumable/cocoa/hot_cocoa = 15, /datum/reagent/consumable/sugar = 5)
	foodtype = SUGAR
	resistance_flags = FREEZE_PROOF
	custom_price = 42

/obj/item/reagent_containers/food/drinks/dry_ramen
	name = "kubek ramenu"
	desc = "Wystarczy dodać 5 ml wody, sam się podgrzewa! Smak, który przypomina ci lata szkolne. Teraz w nowej, słonej wersji!"
	icon_state = "ramen"
	list_reagents = list(
		/datum/reagent/consumable/dry_ramen = 15,
		/datum/reagent/consumable/sodiumchloride = 3,
		/datum/reagent/consumable/maltodextrin = 5
	)
	foodtype = GRAIN
	isGlass = FALSE
	custom_price = 38

/obj/item/reagent_containers/food/drinks/beer
	name = "kosmiczne piwo"
	desc = "Piwo. W kosmosie."
	icon_state = "beer"
	list_reagents = list(/datum/reagent/consumable/ethanol/beer = 30)
	foodtype = GRAIN | ALCOHOL

/obj/item/reagent_containers/food/drinks/beer/almost_empty
	var/amount
	list_reagents = null

/obj/item/reagent_containers/food/drinks/beer/almost_empty/Initialize(mapload)
	. = ..()
	amount = rand(1,4)
	reagents.add_reagent(/datum/reagent/consumable/ethanol/beer, amount)

/obj/item/reagent_containers/food/drinks/syndicatebeer
	name = "piwo Syndykatu"
	desc = "Pijane tylko przez najlepszych agentów Syndykatu. Okrągła etykieta ostrzega: „Nie pij więcej niż jednego pod rząd!”"
	icon_state = "syndicatebeer"
	list_reagents = list(/datum/reagent/consumable/ethanol/beer = 10, /datum/reagent/medicine/antitoxin = 20)
	foodtype = GRAIN | ALCOHOL

/obj/item/reagent_containers/food/drinks/ftliver
	name = "Szybsze-Niż-Wątroba"
	desc = "Weszli w kratę!"
	icon_state = "ftliver"
	list_reagents = list(/datum/reagent/consumable/ethanol/ftliver = 30)
	foodtype = ALCOHOL

/obj/item/reagent_containers/food/drinks/beer/light
	name = "Carp Lite"
	desc = "Warzone na „czystej źródlanej wodzie z lodowej asteroidy”."
	list_reagents = list(/datum/reagent/consumable/ethanol/beer/light = 30)

/obj/item/reagent_containers/food/drinks/ale
	name = "Magm-Ale"
	desc = "Ulubiony trunek prawdziwego krasnoluda."
	icon_state = "alebottle"
	item_state = "beer"
	list_reagents = list(/datum/reagent/consumable/ethanol/ale = 30)
	foodtype = GRAIN | ALCOHOL

/obj/item/reagent_containers/food/drinks/sillycup
	name = "kubek papierowy"
	desc = "Papierowy kubek na wodę."
	icon_state = "water_cup_e"
	possible_transfer_amounts = list()
	volume = 10
	spillable = TRUE
	isGlass = FALSE

/obj/item/reagent_containers/food/drinks/sillycup/on_reagent_change(changetype)
	if(reagents.total_volume)
		icon_state = "water_cup"
	else
		icon_state = "water_cup_e"

/obj/item/reagent_containers/food/drinks/sillycup/smallcarton
	name = "mały karton"
	desc = "Mały karton na napoje."
	icon_state = "juicebox"
	volume = 15 //I figure if you have to craft these it should at least be slightly better than something you can get for free from a watercooler

/obj/item/reagent_containers/food/drinks/sillycup/smallcarton/smash(atom/target, mob/thrower, ranged = FALSE)
	if(bartender_check(target) && ranged)
		return
	var/obj/item/broken_bottle/B = new (loc)
	B.icon_state = icon_state
	var/icon/I = new('icons/obj/drinks.dmi', src.icon_state)
	I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = I
	B.name = "[name] (uszkodzenie)"
	B.force = 0
	B.throwforce = 0
	B.desc = "Karton z rozerwaną dolną połową. Można się o niego skaleczyć."
	if(ranged)
		B.throw_scatter() // AQUILA EDIT - Yogstation#12789
	transfer_fingerprints_to(B)
	qdel(src)
	target.Bumped(B)

/obj/item/reagent_containers/food/drinks/sillycup/smallcarton/on_reagent_change(changetype)
	if (reagents.reagent_list.len)
		switch(reagents.get_master_reagent_id())
			if(/datum/reagent/consumable/orangejuice)
				icon_state = "orangebox"
				name = "kartonik soku pomarańczowego"
				desc = "Świetne źródło witamin. Dbaj o zdrowie!"
				foodtype = FRUIT | BREAKFAST
			if(/datum/reagent/consumable/milk)
				icon_state = "milkbox"
				name = "karton mleka"
				desc = "Doskonałe źródło wapnia dla rosnących kosmicznych odkrywców."
				foodtype = DAIRY | BREAKFAST
			if(/datum/reagent/consumable/applejuice)
				icon_state = "juicebox"
				name = "kartonik soku jabłkowego"
				desc = "Słodki sok jabłkowy. Nie spóźnij się do szkoły!"
				foodtype = FRUIT
			if(/datum/reagent/consumable/grapejuice)
				icon_state = "grapebox"
				name = "kartonik soku winogronowego"
				desc = "Smaczny sok winogronowy w zabawnym małym opakowaniu. Bezalkoholowy!"
				foodtype = FRUIT
			if(/datum/reagent/consumable/pineapplejuice)
				icon_state = "pineapplebox"
				name = "kartonik soku ananasowego"
				desc = "Po co ci to w ogóle?"
			if(/datum/reagent/consumable/milk/chocolate_milk)
				icon_state = "chocolatebox"
				name = "karton mleka czekoladowego"
				desc = "Mleko dla fajnych dzieciaków!"
				foodtype = SUGAR
			if(/datum/reagent/consumable/ethanol/eggnog)
				icon_state = "nog2"
				name = "karton ajerkoniaku"
				desc = "Na najwspanialszy czas w roku."
				foodtype = MEAT
	else
		icon_state = "juicebox"
		name = "mały karton"
		desc = "Mały karton na napoje."

/obj/item/reagent_containers/food/drinks/honeycomb
	name = "plaster miodu"
	desc = "Plaster miodu zrobiony przez apida. Wygląda na zrobiony z wosku pszczelego i dość kruchy."
	icon = 'icons/obj/hydroponics/harvest.dmi'
	icon_state = "honeycomb"
	list_reagents = list(/datum/reagent/consumable/honey = 25)

/obj/item/reagent_containers/food/drinks/honeycomb/attack_self(mob/user)
	if(!reagents.total_volume)
		user.visible_message("<span class='warning'>[user] łamie [src] na 2 kawałki!</span>",
		"<span class='notice'>Łamiesz [src] na pół.</span>")
		new /obj/item/stack/sheet/mineral/wax(user.loc, 2)
		qdel(src)
		return
	return ..()

//////////////////////////drinkingglass and shaker//
//Note by Darem: This code handles the mixing of drinks. New drinks go in three places: In Chemistry-Reagents.dm (for the drink
//	itself), in Chemistry-Recipes.dm (for the reaction that changes the components into the drink), and here (for the drinking glass
//	icon states.

/obj/item/reagent_containers/food/drinks/shaker
	name = "shaker"
	desc = "Metalowy shaker do mieszania drinków."
	icon_state = "shaker"
	materials = list(/datum/material/iron=1500)
	amount_per_transfer_from_this = 10
	volume = 100
	isGlass = FALSE

/obj/item/reagent_containers/food/drinks/flask
	name = "piersiówka"
	desc = "Każdy dobry kosmonauta wie, że warto mieć przy sobie parę kufli whisky, gdziekolwiek się wybiera."
	custom_price = 30
	icon_state = "flask"
	materials = list(/datum/material/iron=250)
	volume = 60
	isGlass = FALSE

/obj/item/reagent_containers/food/drinks/flask/gold
	name = "piersiówka kapitana"
	desc = "Złota piersiówka należąca do kapitana."
	icon_state = "flask_gold"
	materials = list(/datum/material/gold=500)

/obj/item/reagent_containers/food/drinks/flask/det
	name = "piersiówka detektywa"
	desc = "Jedyny prawdziwy przyjaciel detektywa."
	icon_state = "detflask"
	list_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 30)

/obj/item/reagent_containers/food/drinks/britcup
	name = "kubek"
	desc = "Kubek z wymalowaną brytyjską flagą."
	icon_state = "britcup"
	volume = 30
	spillable = TRUE


//////////////////////////soda_cans//
//These are in their own group to be used as IED's in /obj/item/grenade/ghettobomb.dm

/obj/item/reagent_containers/food/drinks/soda_cans
	name = "puszka"
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	reagent_flags = NONE
	spillable = FALSE
	isGlass = FALSE
	custom_price = 10

/obj/item/reagent_containers/food/drinks/soda_cans/suicide_act(mob/living/carbon/human/H)
	if(!reagents.total_volume)
		H.visible_message("<span class='warning'>[H] próbuje pociągnąć duży łyk z [src]... Puszka jest pusta!</span>")
		return SHAME
	if(!is_drainable())
		open_soda()
		sleep(10)
	H.visible_message("<span class='suicide'>[H] pociąga duży łyk z [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	playsound(H,'sound/items/drink.ogg', 80, 1)
	reagents.trans_to(H, src.reagents.total_volume, transfered_by = H) //a big sip
	sleep(5)
	H.say(pick("O, Outbomb Cuban Pete, TO dopiero była gra.", "Te wszystkie nowomodne automaty są za wolne. Wolę klasyki.", "Już nie robią takich gier jak Orion Trail.", "Wiesz, jak to mówią. Najgorszy dzień łowienia kosmicznych karpi jest lepszy od najlepszego dnia w pracy.", "Już nie robią takich porządnych, staroświeckich silników osobliwości."))
	if(H.age >= 30)
		H.Stun(50)
		sleep(50)
		playsound(H,'sound/items/drink.ogg', 80, 1)
		H.say(pick("Kolejny dzień, kolejny dolar.", "Ciekawe, czy powinienem trzymać?", "Dywersyfikacja jest dla młokosów.", "Ano, to były dobre czasy."))
		return MANUAL_SUICIDE_NONLETHAL
	sleep(20) //dramatic pause
	return TOXLOSS

/obj/item/reagent_containers/food/drinks/soda_cans/attack(mob/M, mob/user)
	if(M == user && !src.reagents.total_volume && user.combat_mode && user.zone_selected == BODY_ZONE_HEAD)
		user.visible_message("<span class='warning'>[user] zgniata puszkę [src] na swoim czole!</span>", "<span class='notice'>Zgniatasz puszkę [src] na swoim czole.</span>")
		playsound(user.loc,'sound/weapons/pierce.ogg', rand(10,50), 1)
		var/obj/item/trash/can/crushed_can = new /obj/item/trash/can(user.loc)
		crushed_can.icon_state = icon_state
		qdel(src)
	..()

/obj/item/reagent_containers/food/drinks/soda_cans/bullet_act(obj/item/projectile/P)
	. = ..()
	if(!(P.nodamage) && P.damage_type == BRUTE && !QDELETED(src))
		var/obj/item/trash/can/crushed_can = new /obj/item/trash/can(src.loc)
		crushed_can.icon_state = icon_state
		var/atom/throw_target = get_edge_target_turf(crushed_can, pick(GLOB.alldirs))
		crushed_can.throw_at(throw_target, rand(1,2), 7)
		qdel(src)
		return

/obj/item/reagent_containers/food/drinks/soda_cans/proc/open_soda(mob/user)
	to_chat(user, "Odciągasz zawleczkę [src] z satysfakcjonującym pyknięciem.") //Ahhhhhhhh
	ENABLE_BITFIELD(reagents.flags, OPENCONTAINER)
	playsound(src, "can_open", 50, 1)
	spillable = TRUE

/obj/item/reagent_containers/food/drinks/soda_cans/attack_self(mob/user)
	if(!is_drainable())
		open_soda(user)
	return ..()

/obj/item/reagent_containers/food/drinks/soda_cans/cola
	name = "Kosmiczna Cola"
	desc = "Cola. W kosmosie."
	icon_state = "cola"
	list_reagents = list(/datum/reagent/consumable/space_cola = 30)
	foodtype = SUGAR

/obj/item/reagent_containers/food/drinks/soda_cans/tonic
	name = "tonik T-Borga"
	desc = "Chinina smakuje dziwnie, ale przynajmniej odstrasza kosmiczną malarię."
	icon_state = "tonic"
	list_reagents = list(/datum/reagent/consumable/tonic = 50)
	foodtype = ALCOHOL

/obj/item/reagent_containers/food/drinks/soda_cans/sodawater
	name = "woda sodowa"
	desc = "Puszka wody sodowej. Może zrobisz szkocką z wodą sodową?"
	icon_state = "sodawater"
	list_reagents = list(/datum/reagent/consumable/sodawater = 50)

/obj/item/reagent_containers/food/drinks/soda_cans/lemon_lime
	name = "oranżada"
	desc = "Chciałeś POMARAŃCZOWEJ. Dostałeś Cytrynowo-Limonkowy."
	icon_state = "lemon-lime"
	list_reagents = list(/datum/reagent/consumable/lemon_lime = 30)
	foodtype = FRUIT

/obj/item/reagent_containers/food/drinks/soda_cans/lemon_lime/Initialize(mapload)
	. = ..()
	name = "napój cytrynowo-limonkowy"

/obj/item/reagent_containers/food/drinks/soda_cans/space_up
	name = "Kosmo-Up!"
	desc = "Smakuje jak wyłom w kadłubie, tylko w ustach."
	icon_state = "space-up"
	list_reagents = list(/datum/reagent/consumable/space_up = 30)
	foodtype = SUGAR | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/starkist
	name = "Star-kist"
	desc = "Smak gwiazdy w płynie. I trochę tuńczyka...?"
	icon_state = "starkist"
	list_reagents = list(/datum/reagent/consumable/space_cola = 15, /datum/reagent/consumable/orangejuice = 15)
	foodtype = SUGAR | FRUIT | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/space_mountain_wind
	name = "Kosmiczny Górski Wiatr"
	desc = "Przewiewa cię na wylot jak kosmiczny wiatr."
	icon_state = "space_mountain_wind"
	list_reagents = list(/datum/reagent/consumable/spacemountainwind = 30)
	foodtype = SUGAR | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/thirteenloko
	name = "Trzynaście Loko"
	desc = "Ordynator ostrzega załogę, że picie Trzynaście Loko może wywołać drgawki, ślepotę, upicie, a nawet śmierć. Pij odpowiedzialnie."
	icon_state = "thirteen_loko"
	list_reagents = list(/datum/reagent/consumable/ethanol/thirteenloko = 30)
	foodtype = SUGAR | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/dr_gibb
	name = "Dr. Gibb"
	desc = "Pyszna mieszanka 42 różnych smaków."
	icon_state = "dr_gibb"
	list_reagents = list(/datum/reagent/consumable/dr_gibb = 30)
	foodtype = SUGAR | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/pwr_game
	name = "Pwr Game"
	desc = "Jedyny napój z MOCĄ, której pragną prawdziwi gracze."
	icon_state = "purple_can"
	list_reagents = list(/datum/reagent/consumable/pwr_game = 30)

/obj/item/reagent_containers/food/drinks/soda_cans/shamblers
	name = "Sok Shamblera"
	desc = "~Wstrząśnij mi trochę tego Soku Shamblera!~"
	icon_state = "shamblers"
	list_reagents = list(/datum/reagent/consumable/shamblers = 30)
	foodtype = SUGAR | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/grey_bull
	name = "Szary Byk"
	desc = "Szary Byk doda ci rękawic!"
	icon_state = "energy_drink"
	list_reagents = list(/datum/reagent/consumable/grey_bull = 20)
	foodtype = SUGAR | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/monkey_energy
	name = "Małpia Energia"
	desc = "Uwolnij małpę!"
	icon_state = "monkey_energy"
	list_reagents = list(/datum/reagent/consumable/monkey_energy = 50)
	foodtype = SUGAR | JUNKFOOD

/obj/item/reagent_containers/food/drinks/soda_cans/air
	name = "powietrze w puszce"
	desc = "Nie ma niedoboru powietrza. Nie pić."
	icon_state = "air"
	list_reagents = list(/datum/reagent/nitrogen = 24, /datum/reagent/oxygen = 6)
