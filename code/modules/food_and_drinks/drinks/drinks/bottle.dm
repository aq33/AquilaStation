

///////////////////////////////////////////////Alchohol bottles! -Agouri //////////////////////////
//Functionally identical to regular drinks. The only difference is that the default bottle size is 100. - Darem
//Bottles now knockdown and break when smashed on people's heads. - Giacom

/obj/item/reagent_containers/food/drinks/bottle
	amount_per_transfer_from_this = 10
	volume = 100
	throwforce = 15
	item_state = "broken_beer" //Generic held-item sprite until unique ones are made.
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	isGlass = TRUE
	foodtype = ALCOHOL
	///Directly relates to the 'knockdown' duration. Lowered by armor (i.e. helmets)
	var/bottle_knockdown_duration = 1.3 SECONDS

/obj/item/reagent_containers/food/drinks/bottle/smash(mob/living/target, mob/thrower, ranged = FALSE)
	//Creates a shattering noise and replaces the bottle with a broken_bottle
	if(bartender_check(target) && ranged)
		return
	var/obj/item/broken_bottle/B = new (loc)
	if(!ranged && thrower)
		thrower.put_in_hands(B)
	else
		B.throw_scatter() // AQUILA EDIT - Yogstation#12789
	B.icon_state = icon_state

	var/icon/I = new('icons/obj/drinks.dmi', src.icon_state)
	I.Blend(B.broken_outline, ICON_OVERLAY, rand(5), 1)
	I.SwapColor(rgb(255, 0, 220, 255), rgb(0, 0, 0, 0))
	B.icon = I

	if(isGlass)
		if(prob(33))
			var/obj/item/shard/S = new(drop_location())
			target.Bumped(S)
		playsound(src, "shatter", 70, 1)
	else
		B.force = 0
		B.throwforce = 0
		B.desc = "Karton z rozerwanym dnem. Można się o niego skaleczyć jak o papier."
	B.name = "[name] (uszkodzenie)"
	transfer_fingerprints_to(B)

	qdel(src)
	target.Bumped(B)

/obj/item/reagent_containers/food/drinks/bottle/attack(mob/living/target, mob/living/user)

	if(!target)
		return

	if(!user.combat_mode || !isGlass)
		return ..()

	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, "<span class='warning'>Nie chcesz zrobić krzywdy [target]!</span>")
		return

	force = 15 //Smashing bottles over someoen's head hurts.

	var/obj/item/bodypart/affecting = user.zone_selected //Find what the player is aiming at

	var/armor_block = 0 //Get the target's armor values for normal attack damage.
	var/armor_duration = 0 //The more force the bottle has, the longer the duration.

	//Calculating duration and calculating damage.
	if(ishuman(target))

		var/mob/living/carbon/human/H = target
		var/headarmor = 0 // Target's head armor
		armor_block = H.run_armor_check(affecting, "melee","","",armour_penetration) // For normal attack damage

		//If they have a hat/helmet and the user is targeting their head.
		if(istype(H.head, /obj/item/clothing/head) && affecting == BODY_ZONE_HEAD)
			headarmor = H.head.armor.melee
		else
			headarmor = 0

		//Calculate the knockdown duration for the target.
		armor_duration = (bottle_knockdown_duration - headarmor) + force

	else
		//Only humans can have armor, right?
		armor_block = target.run_armor_check(affecting, "melee")
		if(affecting == BODY_ZONE_HEAD)
			armor_duration = bottle_knockdown_duration + force

	//Apply the damage!
	armor_block = min(90,armor_block)
	target.apply_damage(force, BRUTE, affecting, armor_block)

	// You are going to knock someone down for longer if they are not wearing a helmet.
	var/head_attack_message = ""
	if(affecting == BODY_ZONE_HEAD && istype(target, /mob/living/carbon/))
		head_attack_message = " w głowę"
		//Knock down the target for the duration that we calculated and divide it by 5.
		if(armor_duration)
			target.apply_effect(min(armor_duration, 200) , EFFECT_KNOCKDOWN)

	//Display an attack message.
	if(target != user)
		target.visible_message("<span class='danger'>[user] uderza [target][head_attack_message] butelką [src.name]!</span>", \
				"<span class='userdanger'>[user] uderza cię[head_attack_message] butelką [src.name]!</span>")
	else
		target.visible_message("<span class='danger'>[target] uderza się butelką [src.name][head_attack_message]!</span>", \
				"<span class='userdanger'>Uderzasz się butelką [src.name][head_attack_message]!</span>")

	//Attack logs
	log_combat(user, target, "attacked", src)

	//The reagents in the bottle splash all over the target, thanks for the idea Nodrak
	SplashReagents(target)

	//Finally, smash the bottle. This kills (del) the bottle.
	smash(target, user)

	return

//Keeping this here for now, I'll ask if I should keep it here.
/obj/item/broken_bottle
	name = "rozbita butelka"
	desc = "Butelka z ostrym, rozbitym dnem."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "broken_bottle"
	force = 9
	bleed_force = BLEED_SURFACE
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	item_state = "beer"
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("dźga", "ciacha", "atakuje")
	sharpness = IS_SHARP
	var/static/icon/broken_outline = icon('icons/obj/drinks.dmi', "broken")

/obj/item/broken_bottle/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 200, 55)

/obj/item/reagent_containers/food/drinks/bottle/gin
	name = "gin Griffeater"
	desc = "Butelka wysokiej jakości ginu, produkowanego na stacji kosmicznej Nowy Londyn."
	icon_state = "ginbottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/gin = 100)

/obj/item/reagent_containers/food/drinks/bottle/whiskey
	name = "specjalna rezerwa Wujka Gita"
	desc = "Najwyższej klasy whisky single malt, powoli dojrzewająca w tunelach schronu atomowego. WHISKY Z TUNELU RZĄDZI."
	icon_state = "whiskeybottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/whiskey = 100)

/obj/item/reagent_containers/food/drinks/bottle/vodka
	name = "potrójnie destylowana Tunguska"
	desc = "Ach, wódka. Ulubiony napój ORAZ paliwo Rosjan na całym świecie."
	icon_state = "vodkabottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/vodka = 100)

/obj/item/reagent_containers/food/drinks/bottle/vodka/badminka
	name = "wódka Badminka"
	desc = "Etykieta jest napisana cyrylicą. Odczytujesz tylko nazwę i słowo, które przypomina „Wódka”."
	icon_state = "badminka"
	list_reagents = list(/datum/reagent/consumable/ethanol/vodka = 100)

/obj/item/reagent_containers/food/drinks/bottle/tequila
	name = "tequila Caccavo o gwarantowanej jakości"
	desc = "Zrobiona z najlepszych destylatów ropy naftowej, czystej talidomidu i innych wyśmienitych składników!"
	icon_state = "tequilabottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/tequila = 100)

/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing
	name = "butelka niczego"
	desc = "Butelka wypełniona niczym."
	icon_state = "bottleofnothing"
	list_reagents = list(/datum/reagent/consumable/nothing = 100)
	foodtype = NONE

/obj/item/reagent_containers/food/drinks/bottle/patron
	name = "Patron Wrapp Artiste"
	desc = "Tequila ze srebrem, serwowana w kosmicznych klubach nocnych w całej galaktyce."
	icon_state = "patronbottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/patron = 100)

/obj/item/reagent_containers/food/drinks/bottle/rum
	name = "kubański rum korzenny Kapitana Pete'a"
	desc = "To nie jest zwykły rum, o nie. To praktycznie GRIEF w butelce."
	icon_state = "rumbottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/rum = 100)

/obj/item/reagent_containers/food/drinks/bottle/holywater
	name = "flaszka wody święconej"
	desc = "Flaszka wody święconej kapłana."
	icon_state = "holyflask"
	list_reagents = list(/datum/reagent/water/holywater = 100)
	foodtype = NONE

/obj/item/reagent_containers/food/drinks/bottle/holywater/hell
	desc = "Flaszka wody święconej... choć trochę już przeleżała w Nekropolii."
	list_reagents = list(/datum/reagent/hellwater = 100)

/obj/item/reagent_containers/food/drinks/bottle/vermouth
	name = "wermut Goldeneye"
	desc = "Słodka, słodka wytrawność~"
	icon_state = "vermouthbottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/vermouth = 100)

/obj/item/reagent_containers/food/drinks/bottle/kahlua
	name = "likier kawowy Roberta Robusta"
	desc = "Powszechnie znany meksykański likier o smaku kawy. Produkowany od 1936 roku, HONK."
	icon_state = "kahluabottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/kahlua = 100)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/drinks/bottle/goldschlager
	name = "goldschläger College Girl"
	desc = "Bo tylko one wypiją cynamonowy sznaps o mocy 50%."
	icon_state = "goldschlagerbottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/goldschlager = 100)

/obj/item/reagent_containers/food/drinks/bottle/cognac
	name = "koniak premium Chateau de Baton"
	desc = "Słodki i bardzo mocny trunek, powstały po wielu destylacjach i latach dojrzewania. Tym razem możesz sobie darować krzyk „GÓWNOCHRONA”."
	icon_state = "cognacbottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/cognac = 100)

/obj/item/reagent_containers/food/drinks/bottle/wine
	name = "brodate wino specjalne Podwójnej Brody"
	desc = "Butelkę otacza delikatna aura niepokoju i bólu tyłka."
	icon_state = "winebottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/wine = 100)
	foodtype = FRUIT | ALCOHOL

/obj/item/reagent_containers/food/drinks/bottle/absinthe
	name = "bardzo mocny absynt"
	desc = "Mocny trunek warzony i rozprowadzany przez firmę"
	icon_state = "absinthebottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/absinthe = 100)

/obj/item/reagent_containers/food/drinks/bottle/absinthe/Initialize(mapload)
	. = ..()
	redact()

/obj/item/reagent_containers/food/drinks/bottle/absinthe/proc/redact()
	// There was a large fight in the coderbus about a player reference
	// in absinthe. Ergo, this is why the name generation is now so
	// complicated. Judge us kindly.
	var/shortname = pickweight(
		list("T&T" = 1, "A&A" = 1, "Generic" = 1))
	var/fullname
	switch(shortname)
		if("T&T")
			fullname = "Teal and Tealer"
		if("A&A")
			fullname = "Ash and Asher"
		if("Generic")
			fullname = "Nanotrasen Cheap Imitations"
	var/removals = list("\[REDACTED\]", "\[EXPLETIVE DELETED\]",
		"\[EXPUNGED\]", "\[INFORMATION ABOVE YOUR SECURITY CLEARANCE\]",
		"\[MOVE ALONG CITIZEN\]", "\[NOTHING TO SEE HERE\]")
	var/chance = 50

	if(prob(chance))
		shortname = pick_n_take(removals)

	var/list/final_fullname = list()
	for(var/word in splittext(fullname, " "))
		if(prob(chance))
			word = pick_n_take(removals)
		final_fullname += word

	fullname = jointext(final_fullname, " ")

	// Actually finally setting the new name and desc
	name = "[shortname] [name]"
	desc = "[desc] [fullname] Inc."


/obj/item/reagent_containers/food/drinks/bottle/absinthe/premium
	name = "absynt premium Gwyna"
	desc = "Mocny trunek, przy którym prawie zapominasz o popiele w płucach."
	icon_state = "absinthepremium"

/obj/item/reagent_containers/food/drinks/bottle/absinthe/premium/redact()
	return

/obj/item/reagent_containers/food/drinks/bottle/lizardwine
	name = "butelka wina jaszczurczego"
	desc = "Trunek z Kosmicznych Chin, robiony przez moczenie jaszczurczych ogonów w etanolu. Z niewyjaśnionych powodów popularny wśród dowództwa."
	icon_state = "lizardwine"
	list_reagents = list(/datum/reagent/consumable/ethanol/lizardwine = 100)
	foodtype = FRUIT | ALCOHOL

/obj/item/reagent_containers/food/drinks/bottle/hcider
	name = "mocny cydr Jian"
	desc = "Sok jabłkowy dla dorosłych."
	icon_state = "hcider"
	volume = 50
	list_reagents = list(/datum/reagent/consumable/ethanol/hcider = 50)

/obj/item/reagent_containers/food/drinks/bottle/grappa
	name = "dobrze leżakowana grappa Phillipesa"
	desc = "Butelka grappy."
	icon_state = "grappabottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/grappa = 100)

/obj/item/reagent_containers/food/drinks/bottle/sake
	name = "tradycyjne sake Ryo"
	desc = "Słodkie jak tylko się da, a w gardle pali jak ogień."
	icon_state = "sakebottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/sake = 100)

/obj/item/reagent_containers/food/drinks/bottle/sake/Initialize(mapload)
	. = ..()
	if(prob(10))
		name = "sake Puszysty Ogon"
		desc += " Na butelce jest obrazek kitsune z dziewięcioma ogonami do pogłaskania."
		icon_state = "sakebottle_k"
	else if(prob(10))
		name = "domowy wyrób Inubashiri"
		desc += " Auuu."
		icon_state = "sakebottle_i"

/obj/item/reagent_containers/food/drinks/bottle/fernet
	name = "Fernet Bronca"
	desc = "Butelka czystego Fernet Bronca, produkowanego na stacji kosmicznej Kordoba"
	icon_state = "fernetbottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/fernet = 100)

/obj/item/reagent_containers/food/drinks/bottle/beer
	name = "kosmiczne piwo"
	desc = "Piwo. W kosmosie. W większej butelce."
	icon_state = "beer"
	list_reagents = list(/datum/reagent/consumable/ethanol/beer = 100)

/obj/item/reagent_containers/food/drinks/bottle/ale
	name = "Magm-Ale"
	desc = "Ulubiony trunek prawdziwego krasnoluda, teraz w MĘSKIEJ butelce."
	icon_state = "alebottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/ale = 100)

/obj/item/reagent_containers/food/drinks/bottle/homemaderum
	name = "domowy rum Cookie"
	desc = "Pędzony jeszcze na Stacji Kosmicznej 3. Może wyjaśnić, skąd ciągle biorą się te kapelusze-kosze z owocami."
	icon_state = "moonshinebottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/rum = 95, /datum/reagent/drug/mushroomhallucinogen = 5)

//////////////////////////JUICES AND STUFF ///////////////////////

/obj/item/reagent_containers/food/drinks/bottle/orangejuice
	name = "sok pomarańczowy"
	desc = "Pełen witamin i pyszności!"
	custom_price = 10
	icon_state = "orangejuice"
	item_state = "carton"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	isGlass = FALSE
	list_reagents = list(/datum/reagent/consumable/orangejuice = 100)
	foodtype = FRUIT | BREAKFAST

/obj/item/reagent_containers/food/drinks/bottle/cream
	name = "śmietanka"
	desc = "To śmietanka. Z mleka. A czego się tam spodziewałeś?"
	custom_price = 10
	icon_state = "cream"
	item_state = "carton"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	isGlass = FALSE
	list_reagents = list(/datum/reagent/consumable/cream = 100)
	foodtype = DAIRY

/obj/item/reagent_containers/food/drinks/bottle/tomatojuice
	name = "sok pomidorowy"
	desc = "No, przynajmniej WYGLĄDA jak sok pomidorowy. Przy tej czerwieni trudno to stwierdzić."
	custom_price = 10
	icon_state = "tomatojuice"
	item_state = "carton"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	isGlass = FALSE
	list_reagents = list(/datum/reagent/consumable/tomatojuice = 100)
	foodtype = VEGETABLES

/obj/item/reagent_containers/food/drinks/bottle/limejuice
	name = "sok z limonki"
	desc = "Słodko-kwaśna pyszność."
	custom_price = 10
	icon_state = "limejuice"
	item_state = "carton"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	isGlass = FALSE
	list_reagents = list(/datum/reagent/consumable/limejuice = 100)
	foodtype = FRUIT

/obj/item/reagent_containers/food/drinks/bottle/pineapplejuice
	name = "sok ananasowy"
	desc = "Bardzo cierpki, żółty sok."
	custom_price = 10
	icon_state = "pineapplejuice"
	item_state = "carton"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	isGlass = FALSE
	list_reagents = list(/datum/reagent/consumable/pineapplejuice = 100)
	foodtype = FRUIT | PINEAPPLE

/obj/item/reagent_containers/food/drinks/bottle/menthol
	name = "mentol"
	desc = "Ma naturalnie miętowy smak i lekko znieczula."
	custom_price = 10
	icon_state = "mentholbox"
	item_state = "carton"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	isGlass = FALSE
	list_reagents = list(/datum/reagent/consumable/menthol = 100)

/obj/item/reagent_containers/food/drinks/bottle/grenadine
	name = "grenadyna Jester"
	desc = "Zawiera 0% prawdziwych wiśni!"
	custom_price = 10
	icon_state = "grenadine"
	isGlass = TRUE
	list_reagents = list(/datum/reagent/consumable/grenadine = 100)
	foodtype = FRUIT

/obj/item/reagent_containers/food/drinks/bottle/synthflesh
	name = "karton syntetycznego ciała"
	desc = "Karton syntetycznego ciała bez marki. Wygląda na spleśniały. I wygląda na to, że TWOJA NIEKOMPETENTNA DUPA TO JEDYNY KURWA POWÓD, DLA KTÓREGO TO W OGÓLE ISTNIEJE!!!!"
	custom_price = 10
	icon_state = "synthflesh"
	item_state = "carton"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	isGlass = FALSE
	list_reagents = list(/datum/reagent/medicine/synthflesh = 100)

/obj/item/reagent_containers/food/drinks/bottle/virusfood
	name = "karton pożywki dla wirusów"
	desc = "Karton gotowej pożywki dla wirusów. Nie pić."
	custom_price = 10
	icon_state = "virusfood"
	item_state = "carton"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	isGlass = FALSE
	list_reagents = list(/datum/reagent/consumable/virus_food = 100)

/obj/item/reagent_containers/food/drinks/bottle/applejack
	name = "applejack Buckin' Bronco"
	desc = "Kopie jak koń, smakuje jak jabłko!"
	custom_price = 10
	icon_state = "applejack_bottle"
	isGlass = TRUE
	list_reagents = list(/datum/reagent/consumable/ethanol/applejack = 100)
	foodtype = FRUIT

/obj/item/reagent_containers/food/drinks/bottle/champagne
	name = "szampan Eau d' Dandy Brut"
	desc = "Pochodzi wyłącznie z najbardziej pretensjonalnych francuskich winnic."
	custom_premium_price = 200
	icon_state = "champagne_bottle"
	isGlass = TRUE
	list_reagents = list(/datum/reagent/consumable/ethanol/champagne = 100)

/obj/item/reagent_containers/food/drinks/bottle/blazaam
	name = "Blazaam Ginbada"
	desc = "Masz wrażenie, że przed otwarciem warto porządnie potrzeć butelkę."
	icon_state = "blazaambottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/blazaam = 100)

/obj/item/reagent_containers/food/drinks/bottle/trappist
	name = "Mont de Requin Trappistes Bleu"
	desc = "Warzone w kosmicznej Belgii. Wytworne!"
	custom_premium_price = 50
	icon_state = "trappistbottle"
	volume = 50
	list_reagents = list(/datum/reagent/consumable/ethanol/trappist = 50)

/obj/item/reagent_containers/food/drinks/bottle/hooch
	name = "butelka bimbru"
	desc = "Butelka sikacza. Właściciel, wykazując się uliczną mądrością, sprytnie ukrył ją w brązowej papierowej torbie."
	icon_state = "hoochbottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/hooch = 100)

/obj/item/reagent_containers/food/drinks/bottle/moonshine
	name = "dzbanek samogonu"
	desc = "Mówi się, że dawni mieszkańcy Appalachów łapali w takie kamionkowe dzbany błyskawice."
	icon_state = "moonshinebottle"
	list_reagents = list(/datum/reagent/consumable/ethanol/moonshine = 100)

/obj/item/reagent_containers/food/drinks/bottle/blank //Don't let players print these from a lathe, bottles should be obtained in mass from the bar only.
	name = "szklana butelka"
	desc = "Ta pusta butelka jest nieubłaganie anonimowa i nie zdradza niczego o swojej zawartości."
	icon_state = "glassbottle"
	fill_icon_thresholds = list(0, 10, 20, 30, 40, 50, 60, 70, 80, 90)

/obj/item/reagent_containers/food/drinks/bottle/blank/update_icon()
	..()
	add_overlay("[initial(icon_state)]shine")

/obj/item/reagent_containers/food/drinks/bottle/blank/small
	name = "mała szklana butelka"
	desc = "Ta mała butelka jest nieubłaganie anonimowa i nie zdradza niczego o swojej zawartości."
	icon_state = "glassbottlesmall"
	volume = 50

////////////////////////// MOLOTOV ///////////////////////
/obj/item/reagent_containers/food/drinks/bottle/molotov
	name = "koktajl Mołotowa"
	desc = "Broń miotana do podpalania, zwykle wypełniona substancją łatwopalną. Gorąco polecana przez zadymiarzy i rewolucjonistów. Podpal i rzuć."
	icon_state = "vodkabottle"
	list_reagents = list()
	var/active = 0

/obj/item/reagent_containers/food/drinks/bottle/molotov/CheckParts(list/parts_list)
	..()
	var/obj/item/reagent_containers/food/drinks/bottle/B = locate() in contents
	if(B)
		icon_state = B.icon_state
		B.reagents.copy_to(src,100)
		if(!B.isGlass)
			desc += " Nie wiesz, czy zrobienie tego z kartonu było najmądrzejszym pomysłem."
			isGlass = FALSE
	return

/obj/item/reagent_containers/food/drinks/bottle/molotov/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	var/fire_power = reagents.get_total_accelerant_quality()
	if(active && fire_power > 0)
		hit_atom.fire_act()
		if(isliving(hit_atom))
			var/mob/living/L = hit_atom
			L.adjust_fire_stacks(1)
			L.IgniteMob()
		if(fire_power > 10)
			var/turf/center_turf = get_turf(hit_atom)
			if(isclosedturf(center_turf) && isopenturf(get_turf(src)))
				center_turf = get_turf(src) // if it hits a wall, light the floor in front of the wall on fire, not the wall itself
			center_turf.IgniteTurf(fire_power)
			for(var/turf/T in center_turf.GetAtmosAdjacentTurfs())
				if(prob(fire_power))
					T.IgniteTurf(fire_power)
	return ..()

/obj/item/reagent_containers/food/drinks/bottle/molotov/attackby(obj/item/I, mob/user, params)
	if(I.is_hot() && !active)
		active = TRUE
		log_bomber(user, "has primed a", src, "for detonation")

		to_chat(user, "<span class='info'>Podpalasz [src].</span>")
		add_overlay(custom_fire_overlay ? custom_fire_overlay : GLOB.fire_overlay)
		if(!isGlass)
			spawn(50)
				if(active)
					var/counter
					var/target = src.loc
					for(counter = 0, counter<2, counter++)
						if(istype(target, /obj/item/storage))
							var/obj/item/storage/S = target
							target = S.loc
					if(istype(target, /atom))
						var/atom/A = target
						SplashReagents(A)
						A.fire_act()
					qdel(src)

/obj/item/reagent_containers/food/drinks/bottle/molotov/attack_self(mob/user)
	if(active)
		if(!isGlass)
			to_chat(user, "<span class='danger'>Płomień rozprzestrzenił się za bardzo!</span>")
			return
		to_chat(user, "<span class='info'>Gasisz płomień na [src].</span>")
		cut_overlay(custom_fire_overlay ? custom_fire_overlay : GLOB.fire_overlay)
		active = 0
