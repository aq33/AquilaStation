/*
 *	Everything derived from the common cardboard box.
 *	Basically everything except the original is a kit (starts full).
 *
 *	Contains:
 *		Empty box, starter boxes (survival/engineer),
 *		Latex glove and sterile mask boxes,
 *		Syringe, beaker, dna injector boxes,
 *		Blanks, flashbangs, and EMP grenade boxes,
 *		Tracking and chemical implant boxes,
 *		Prescription glasses and drinking glass boxes,
 *		Condiment bottle and silly cup boxes,
 *		Donkpocket and monkeycube boxes,
 *		ID and security PDA cart boxes,
 *		Handcuff, mousetrap, and pillbottle boxes,
 *		Snap-pops and matchboxes,
 *		Replacement light boxes.
 *		Action Figure Boxes
 *		Various paper bags.
 *		Encrpytion key boxes.
 *
 *		For syndicate call-ins see uplink_kits.dm
 */

/obj/item/storage/box
	name = "pudełko"
	desc = "Zwykłe pudełko."
	icon_state = "box"
	item_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FLAMMABLE
	var/foldable = /obj/item/stack/sheet/cardboard
	var/illustration = "writing"
	drop_sound = 'sound/items/handling/cardboardbox_drop.ogg'
	pickup_sound =  'sound/items/handling/cardboardbox_pickup.ogg'

/obj/item/storage/box/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/storage/box/suicide_act(mob/living/carbon/user)
	var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)
	if(myhead)
		user.visible_message("<span class='suicide'>[user] wkłada głowę do [src] i zaczyna je zamykać! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
		myhead.dismember()
		myhead.forceMove(src)//force your enemies to kill themselves with your head collection box!
		playsound(user,pick('sound/misc/desecration-01.ogg','sound/misc/desecration-02.ogg','sound/misc/desecration-01.ogg') ,50, 1, -1)
		return BRUTELOSS
	user.visible_message("<span class='suicide'>[user] okłada się [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return BRUTELOSS

/obj/item/storage/box/update_icon()
	. = ..()
	if(illustration)
		cut_overlays()
		add_overlay(illustration)

/obj/item/storage/box/attack_self(mob/user)
	..()

	if(!foldable || (flags_1 & HOLOGRAM_1))
		return
	if(contents.len)
		to_chat(user, "<span class='warning'>Nie możesz złożyć tego pudełka, gdy są w nim przedmioty!</span>")
		return
	if(!ispath(foldable))
		return

	to_chat(user, "<span class='notice'>Składasz [src] na płasko.</span>")
	var/obj/item/I = new foldable
	qdel(src)
	user.put_in_hands(I)

/obj/item/storage/box/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/package_wrap))
		return 0
	return ..()

//Locker overloading issue solving boxes
/obj/item/storage/box/suitbox
	name = "kompresyjne pudełko z niewidzialnymi strojami"
	desc = "Pudełko z zatwierdzoną przez Nanotrasen technologią kompresji bluespace, ale strasznie ciężkie... Jeśli to pudełko przykleiło ci się do ręki, wyjmij zawartość i złóż je."
	w_class = WEIGHT_CLASS_HUGE
	item_flags = SLOWS_WHILE_IN_HAND
	slowdown = 4
	drag_slowdown = 4 // do not steal by dragging
	/* Note for the compression box:
		Do not put any box (or suit) into this box, or it will allow infinite storage.
		non-storage items are only legit for this box. (suits are storage too, so, no.)
		nor it will allow a glitch when you can access different boxes at the same time.
		examples exist in `closets/secure/security.dm` */

/obj/item/storage/box/suitbox/wardrobe // for `wardrobe.dm`
	name = "kompresyjne pudełko ze strojami załogi"
	var/list/repeated_items = list( // just as a sample
		/obj/item/clothing/under/color/blue,
		/obj/item/clothing/under/color/jumpskirt/blue,
		/obj/item/clothing/shoes/sneakers/brown
	)
	var/max_repetition = 2

/obj/item/storage/box/suitbox/wardrobe/PopulateContents()
	for(var/i in 1 to max_repetition)
		for(var/O in repeated_items)
			new O(src)

//Mime spell boxes

/obj/item/storage/box/mime
	name = "niewidzialne pudełko"
	desc = "Niestety za małe, żeby zamknąć w nim mima."
	foldable = null
	icon_state = "box"
	item_state = null
	alpha = 0

/obj/item/storage/box/mime/attack_hand(mob/user, list/modifiers)
	..()
	if(user.mind.miming)
		alpha = 255

/obj/item/storage/box/mime/Moved(oldLoc, dir)
	if (iscarbon(oldLoc))
		alpha = 0
	..()

//Disk boxes

/obj/item/storage/box/disks
	name = "pudełko dyskietek"
	illustration = "disk_kit"

/obj/item/storage/box/disks/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/disk/data(src)


/obj/item/storage/box/disks_plantgene
	name = "pudełko dysków z danymi roślin"
	illustration = "disk_kit"

/obj/item/storage/box/disks_plantgene/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/disk/plant_disk(src)

/obj/item/storage/box/disks_nanite
	name = "pudełko dysków z programami nanitów"
	illustration = "disk_kit"

/obj/item/storage/box/disks_nanite/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/disk/nanite_program(src)

// Ordinary survival box
/obj/item/storage/box/survival/PopulateContents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/reagent_containers/hypospray/medipen(src)
	new /obj/item/clothing/head/helmet/space/skinsuit(src) //NSV13 - rollup skinsuit
	new /obj/item/clothing/suit/space/skinsuit(src) //NSV13 - rollup skinsuit

	if(!isplasmaman(loc))
		new /obj/item/tank/internals/emergency_oxygen(src)
	else
		new /obj/item/tank/internals/plasmaman/belt(src)

	if(HAS_TRAIT(SSstation, STATION_TRAIT_PREMIUM_INTERNALS))
		new /obj/item/flashlight/flare(src)
		new /obj/item/radio/off(src)

/obj/item/storage/box/survival/radio/PopulateContents()
	..() // we want the survival stuff too.
	new /obj/item/radio/off(src)

// Mining survival box
/obj/item/storage/box/survival_mining/PopulateContents()
	new /obj/item/clothing/mask/gas/explorer(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/reagent_containers/hypospray/medipen(src)
	new /obj/item/clothing/head/helmet/space/skinsuit(src) //NSV13 - rollup skinsuit
	new /obj/item/clothing/suit/space/skinsuit(src) //NSV13 - rollup skinsuit

	if(!isplasmaman(loc))
		new /obj/item/tank/internals/emergency_oxygen(src)
	else
		new /obj/item/tank/internals/plasmaman/belt(src)

// Engineer survival box
/obj/item/storage/box/engineer/PopulateContents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/reagent_containers/hypospray/medipen(src)
	new /obj/item/clothing/head/helmet/space/skinsuit(src) //NSV13 - rollup skinsuit
	new /obj/item/clothing/suit/space/skinsuit(src) //NSV13 - rollup skinsuit

	if(!isplasmaman(loc))
		new /obj/item/tank/internals/emergency_oxygen/engi(src)
	else
		new /obj/item/tank/internals/plasmaman/belt(src)

/obj/item/storage/box/engineer/radio/PopulateContents()
	..() // we want the regular items too.
	new /obj/item/radio/off(src)

// Syndie survival box
/obj/item/storage/box/syndie/PopulateContents()
	new /obj/item/clothing/mask/gas/syndicate(src)

	if(!isplasmaman(loc))
		new /obj/item/tank/internals/emergency_oxygen/engi(src)
	else
		new /obj/item/tank/internals/plasmaman/belt(src)

// Security survival box
/obj/item/storage/box/security/PopulateContents()
	new /obj/item/clothing/mask/gas/sechailer(src)
	new /obj/item/reagent_containers/hypospray/medipen(src)
	new /obj/item/clothing/head/helmet/space/skinsuit(src) //NSV13 - rollup skinsuit
	new /obj/item/clothing/suit/space/skinsuit(src) //NSV13 - rollup skinsuit

	if(!isplasmaman(loc))
		new /obj/item/tank/internals/emergency_oxygen(src)
	else
		new /obj/item/tank/internals/plasmaman/belt(src)

/obj/item/storage/box/security/radio/PopulateContents()
	..() // we want the regular stuff too
	new /obj/item/radio/off(src)

/obj/item/storage/box/gloves
	name = "pudełko rękawiczek lateksowych"
	desc = "Zawiera sterylne rękawiczki lateksowe."
	illustration = "latex"

/obj/item/storage/box/gloves/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/clothing/gloves/color/latex(src)

/obj/item/storage/box/masks
	name = "pudełko maseczek chirurgicznych"
	desc = "W tym pudełku są sterylne maseczki medyczne."
	illustration = "sterile"

/obj/item/storage/box/masks/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/clothing/mask/surgical(src)

/obj/item/storage/box/syringes
	name = "pudełko strzykawek"
	desc = "Pudełko pełne strzykawek."
	illustration = "syringe"

/obj/item/storage/box/syringes/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/syringe(src)

/obj/item/storage/box/syringes/variety
	name = "pudełko z różnymi strzykawkami"

/obj/item/storage/box/syringes/variety/PopulateContents()
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/syringe/lethal(src)
	new /obj/item/reagent_containers/syringe/cryo(src)
	new /obj/item/reagent_containers/syringe/piercing(src)
	new /obj/item/reagent_containers/syringe/bluespace(src)

/obj/item/storage/box/medipens
	name = "pudełko medipenów"
	desc = "Pudełko pełne medipenów z epinefryną."
	illustration = "syringe"

/obj/item/storage/box/medipens/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/hypospray/medipen(src)

/obj/item/storage/box/medipens/utility
	name = "oszczędnościowy zestaw stymulantów"
	desc = "Pudełko z kilkoma medipenami ze stymulantem dla oszczędnego górnika."
	illustration = "syringe"

/obj/item/storage/box/medipens/utility/PopulateContents()
	..() // includes regular medipens.
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/hypospray/medipen/stimpack(src)

/obj/item/storage/box/beakers
	name = "pudełko zlewek"
	illustration = "beaker"

/obj/item/storage/box/beakers/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/glass/beaker( src )

/obj/item/storage/box/beakers/bluespace
	name = "pudełko zlewek bluespace"
	illustration = "bbeaker"

/obj/item/storage/box/beakers/bluespace/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/glass/beaker/bluespace(src)

/obj/item/storage/box/beakers/variety
	name = "pudełko z różnymi zlewkami"

/obj/item/storage/box/beakers/variety/PopulateContents()
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/beaker/large(src)
	new /obj/item/reagent_containers/glass/beaker/plastic(src)
	new /obj/item/reagent_containers/glass/beaker/meta(src)
	new /obj/item/reagent_containers/glass/beaker/noreact(src)
	new /obj/item/reagent_containers/glass/beaker/bluespace(src)

/obj/item/storage/box/medsprays
	name = "pudełko rozpylaczy medycznych"
	desc = "Pudełko pełne rozpylaczy medycznych z odkręcanymi nakrętkami i precyzyjnymi dyszami."

/obj/item/storage/box/medsprays/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/medspray( src )

/obj/item/storage/box/injectors
	name = "pudełko iniektorów DNA"
	desc = "W tym pudełku są chyba iniektory."
	illustration = "dna"

/obj/item/storage/box/injectors/PopulateContents()
	var/static/items_inside = list(
		/obj/item/dnainjector/h2m = 3,
		/obj/item/dnainjector/m2h = 3)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/flashbangs
	name = "pudełko granatów hukowo-błyskowych (UWAGA)"
	desc = "<B>UWAGA: te urządzenia są bardzo niebezpieczne i przy wielokrotnym użyciu mogą spowodować ślepotę lub głuchotę.</B>"
	icon_state = "secbox"
	illustration = "flashbang"

/obj/item/storage/box/flashbangs/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/grenade/flashbang(src)

/obj/item/storage/box/flashes
	name = "pudełko żarówek do flashy"
	desc = "<B>UWAGA: flashe mogą poważnie uszkodzić wzrok, wymagane są okulary ochronne.</B>"
	icon_state = "secbox"
	illustration = "flash"

/obj/item/storage/box/flashes/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/assembly/flash/handheld(src)
	for(var/i in 1 to 6)
		new /obj/item/flashbulb(src)

/obj/item/storage/box/stingbangs
	name = "pudełko granatów odłamkowo-hukowych (UWAGA)"
	desc = "<B>UWAGA: te urządzenia są bardzo niebezpieczne i przy wielokrotnym użyciu mogą spowodować ciężkie obrażenia lub śmierć.</B>"
	icon_state = "secbox"
	illustration = "flashbang"

/obj/item/storage/box/stingbangs/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/grenade/stingbang(src)

/obj/item/storage/box/wall_flash
	name = "zestaw ściennego flasha"
	desc = "W tym pudełku jest wszystko, czego potrzebujesz do zbudowania ściennego flasha. <B>UWAGA: flashe mogą poważnie uszkodzić wzrok, wymagane są okulary ochronne.</B>"
	icon_state = "secbox"
	illustration = "flash"

/obj/item/storage/box/wall_flash/PopulateContents()
	var/id = rand(1000, 9999)
	// FIXME what if this conflicts with an existing one?

	new /obj/item/wallframe/button(src)
	new /obj/item/electronics/airlock(src)
	var/obj/item/assembly/control/flasher/remote = new(src)
	remote.id = id
	var/obj/item/wallframe/flasher/frame = new(src)
	frame.id = id
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/screwdriver(src)


/obj/item/storage/box/teargas
	name = "pudełko granatów z gazem łzawiącym (UWAGA)"
	desc = "<B>UWAGA: te urządzenia są bardzo niebezpieczne i mogą spowodować ślepotę oraz podrażnienie skóry.</B>"
	icon_state = "secbox"
	illustration = "grenade"

/obj/item/storage/box/teargas/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/grenade/chem_grenade/teargas(src)

/obj/item/storage/box/emps
	name = "pudełko granatów EMP"
	desc = "Pudełko z 5 granatami EMP."
	illustration = "emp"

/obj/item/storage/box/emps/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/grenade/empgrenade(src)

/obj/item/storage/box/trackimp
	name = "zestaw implantów namierzających"
	desc = "Pudełko pełne przyborów do namierzania szumowin."
	icon_state = "secbox"
	illustration = "implant"

/obj/item/storage/box/trackimp/PopulateContents()
	var/static/items_inside = list(
		/obj/item/implantcase/tracking = 4,
		/obj/item/implanter = 1,
		/obj/item/implantpad = 1,
		/obj/item/locator = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/minertracker
	name = "zestaw implantów namierzających"
	desc = "Do odnajdywania tych, którzy zginęli na przeklętym świecie lawy."
	illustration = "implant"

/obj/item/storage/box/minertracker/PopulateContents()
	var/static/items_inside = list(
		/obj/item/implantcase/tracking = 3,
		/obj/item/implanter = 1,
		/obj/item/implantpad = 1,
		/obj/item/locator = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/chemimp
	name = "zestaw implantów chemicznych"
	desc = "Pudełko z rzeczami do wszczepiania chemikaliów."
	illustration = "implant"

/obj/item/storage/box/chemimp/PopulateContents()
	var/static/items_inside = list(
		/obj/item/implantcase/chem = 5,
		/obj/item/implanter = 1,
		/obj/item/implantpad = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/exileimp
	name = "zestaw implantów wygnania"
	desc = "Pudełko implantów wygnania. Na obrazku klaun znika w netpodzie, a z drugiej strony macha z Pętli." // AQ EDIT
	illustration = "implant"

/obj/item/storage/box/exileimp/PopulateContents()
	var/static/items_inside = list(
		/obj/item/implantcase/exile = 5,
		/obj/item/implanter = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/bodybags
	name = "worki na zwłoki"
	desc = "Według etykiety w środku są worki na zwłoki."
	illustration = "bodybags"

/obj/item/storage/box/bodybags/PopulateContents()
	..()
	for(var/i in 1 to 7)
		new /obj/item/bodybag(src)

/obj/item/storage/box/rxglasses
	name = "pudełko okularów korekcyjnych"
	desc = "W tym pudełku są okulary kujona."
	illustration = "glasses"

/obj/item/storage/box/rxglasses/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/clothing/glasses/regular(src)

/obj/item/storage/box/drinkingglasses
	name = "pudełko szklanek"
	desc = "Jest na nim obrazek szklanek."
	illustration = "drinkglass"

/obj/item/storage/box/drinkingglasses/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/food/drinks/drinkingglass(src)

/obj/item/storage/box/condimentbottles
	name = "pudełko butelek na przyprawy"
	desc = "Ma na sobie dużą smugę ketchupu."
	illustration = "condiment"

/obj/item/storage/box/condimentbottles/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/food/condiment(src)

/obj/item/storage/box/cups
	name = "pudełko kubków papierowych"
	desc = "Z przodu ma obrazki kubków papierowych."
	illustration = "cup"

/obj/item/storage/box/cups/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/food/drinks/sillycup( src )

/obj/item/storage/box/donkpockets

/obj/item/storage/box/donkpockets/PopulateContents()
    for(var/i in 1 to 6)
        new donktype(src)

/obj/item/storage/box/donkpockets //AQUILA EDIT BEGIN
	name = "karton pierogów"
	desc = "<B>Instrukcja:</B> <I>Odgrzej w mikrofalówce. Produkt straci ciepło po siedmiu minutach.</I>"
	icon_state = "donkpocketbox"
	icon = 'aquila/icons/obj/storage.dmi'
	illustration=null
	var/donktype = /obj/item/food/donkpocket
	donktype = /obj/item/food/donkpocket

/obj/item/storage/box/donkpockets/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.can_hold = typecacheof(list(/obj/item/food/donkpocket))

/obj/item/storage/box/donkpockets/donkpocketspicy
	name = "karton pierogów pikantnych"
	icon_state = "donkpocketboxspicy"
	donktype = /obj/item/food/donkpocket/spicy

/obj/item/storage/box/donkpockets/donkpocketteriyaki
	name = "karton pierogów azjatyckich"
	icon_state = "donkpocketboxteriyaki"
	donktype = /obj/item/food/donkpocket/teriyaki

/obj/item/storage/box/donkpockets/donkpocketpizza
	name = "karton pierogów włoskich"
	icon_state = "donkpocketboxpizza"
	donktype = /obj/item/food/donkpocket/pizza

/obj/item/storage/box/donkpockets/donkpocketgondola
	name = "karton pierogów finlandzkich"
	icon_state = "donkpocketboxgondola"
	donktype = /obj/item/food/donkpocket/gondola

/obj/item/storage/box/donkpockets/donkpocketgondolafinlandia
	name = "laatikko gondolin makuisia pieróg-taskuja"
	desc = "<B>Ohjeet:</B> <I>Lämmitä mikroaaltouunissa. Tuote jäähtyy, jos sitä ei syödä seitsemän minuutin kuluessa.</I>"
	icon_state = "donkpocketboxgondola"
	donktype = /obj/item/food/donkpocket/gondola

/obj/item/storage/box/donkpockets/donkpocketberry
	name = "karton jagodowych pierogów"
	icon_state = "donkpocketboxberry"
	donktype = /obj/item/food/donkpocket/berry

/obj/item/storage/box/donkpockets/donkpockethonk
	name = "karton bananowych pierogów"
	icon_state = "donkpocketboxbanana"
	donktype = /obj/item/food/donkpocket/honk //AQUILA EDIT END

/obj/item/storage/box/monkeycubes
	name = "pudełko małpich kostek"
	desc = "Małpie kostki marki Drymate. Wystarczy dodać wody!"
	icon_state = "monkeycubebox"
	illustration = null
	var/cube_type = /obj/item/food/monkeycube

/obj/item/storage/box/monkeycubes/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 7
	STR.can_hold = typecacheof(list(/obj/item/food/monkeycube))

/obj/item/storage/box/monkeycubes/PopulateContents()
	for(var/i in 1 to 5)
		new cube_type(src)

/obj/item/storage/box/monkeycubes/syndicate
	desc = "Małpie kostki marki Waffle Co. Wystarczy dodać wody i szczyptę podstępu!"
	cube_type = /obj/item/food/monkeycube/syndicate

/obj/item/storage/box/gorillacubes
	name = "pudełko gorylich kostek"
	desc = "Gorylie kostki marki Waffle Co. Nie drażnić."
	icon_state = "monkeycubebox"
	illustration = null

/obj/item/storage/box/gorillacubes/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 3
	STR.can_hold = typecacheof(list(/obj/item/food/monkeycube))

/obj/item/storage/box/gorillacubes/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/food/monkeycube/gorilla(src)

/obj/item/storage/box/mixedcubes
	name = "pudełko kostek z mieszanką zwierząt hodowlanych"
	desc = "Nowe kostki Farm Town, dzięki którym spełnisz swoje rolnicze marzenia. Wystarczy dodać wody!"
	icon_state = "monkeycubebox"
	illustration = null

/obj/item/storage/box/mixedcubes/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.can_hold = typecacheof(list(/obj/item/food/monkeycube))

/obj/item/storage/box/mixedcubes/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/food/monkeycube/goat(src)
		new /obj/item/food/monkeycube/sheep(src)
		new /obj/item/food/monkeycube/cow(src)

/obj/item/storage/box/ids
	name = "pudełko zapasowych identyfikatorów"
	desc = "Jest w nim mnóstwo pustych identyfikatorów."
	illustration = "id"

/obj/item/storage/box/ids/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/card/id(src)

//Some spare PDAs in a box
/obj/item/storage/box/PDAs
	name = "zapasowe PDA"
	desc = "Pudełko zapasowych mikrokomputerów PDA."
	illustration = "pda"

/obj/item/storage/box/PDAs/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/modular_computer/tablet/pda(src)
	new /obj/item/computer_hardware/hard_drive/role/head(src)

	var/newcart = pick(	/obj/item/computer_hardware/hard_drive/role/engineering,
						/obj/item/computer_hardware/hard_drive/role/security,
						/obj/item/computer_hardware/hard_drive/role/medical,
						/obj/item/computer_hardware/hard_drive/role/signal/toxins,
						/obj/item/computer_hardware/hard_drive/role/cargo_technician)
	new newcart(src)

/obj/item/storage/box/silver_ids
	name = "pudełko zapasowych srebrnych identyfikatorów"
	desc = "Błyszczące identyfikatory dla ważnych ludzi."
	illustration = "id"

/obj/item/storage/box/silver_ids/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/card/id/silver(src)

/obj/item/storage/box/prisoner
	name = "pudełko identyfikatorów więźniów"
	desc = "Odbierz im ostatni strzęp godności, czyli imię."
	icon_state = "secbox"
	illustration = "id"

/obj/item/storage/box/prisoner/PopulateContents()
	..()
	new /obj/item/card/id/gulag/one(src)
	new /obj/item/card/id/gulag/two(src)
	new /obj/item/card/id/gulag/three(src)
	new /obj/item/card/id/gulag/four(src)
	new /obj/item/card/id/gulag/five(src)
	new /obj/item/card/id/gulag/six(src)
	new /obj/item/card/id/gulag/seven(src)

/obj/item/storage/box/seccarts
	name = "pudełko dysków zawodowych PDA ochrony"
	desc = "Pudełko pełne dysków zawodowych PDA używanych przez ochronę."
	icon_state = "secbox"
	illustration = "pda"

/obj/item/storage/box/seccarts/PopulateContents()
	new /obj/item/computer_hardware/hard_drive/role/detective(src)
	for(var/i in 1 to 6)
		new /obj/item/computer_hardware/hard_drive/role/security(src)

/obj/item/storage/box/firingpins
	name = "pudełko standardowych iglic"
	desc = "Pudełko pełne standardowych iglic, dzięki którym nowo opracowana broń palna może działać."
	icon_state = "secbox"
	illustration = "firingpin"

/obj/item/storage/box/firingpins/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/firing_pin(src)

/obj/item/storage/box/firingpins/paywall
	name = "pudełko płatnych iglic"
	desc = "Pudełko pełne płatnych iglic, dzięki którym nowo opracowana broń palna działa po wniesieniu ustalonej opłaty."
	illustration = "firingpin"

/obj/item/storage/box/firingpins/paywall/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/firing_pin/paywall(src)

/obj/item/storage/box/lasertagpins
	name = "pudełko iglic do laser taga"
	desc = "Pudełko pełne iglic do laser taga, przez które nowo opracowana broń palna działa tylko w jaskrawym plastikowym pancerzu."
	illustration = "firingpin"

/obj/item/storage/box/lasertagpins/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/firing_pin/tag/red(src)
		new /obj/item/firing_pin/tag/blue(src)

/obj/item/storage/box/handcuffs
	name = "pudełko zapasowych kajdanek"
	desc = "Pudełko pełne kajdanek."
	icon_state = "secbox"
	illustration = "handcuff"

/obj/item/storage/box/handcuffs/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/restraints/handcuffs(src)

/obj/item/storage/box/zipties
	name = "pudełko zapasowych opasek zaciskowych"
	desc = "Pudełko pełne opasek zaciskowych."
	icon_state = "secbox"
	illustration = "handcuff"

/obj/item/storage/box/zipties/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/restraints/handcuffs/cable/zipties(src)

/obj/item/storage/box/alienhandcuffs
	name = "pudełko zapasowych kajdanek"
	desc = "Pudełko pełne kajdanek."
	icon_state = "alienbox"
	illustration = "handcuff"

/obj/item/storage/box/alienhandcuffs/PopulateContents()
	for(var/i in 1 to 7)
		new	/obj/item/restraints/handcuffs/alien(src)

/obj/item/storage/box/fakesyndiesuit
	name = "skafander kosmiczny z hełmem w pudełku"
	desc = "Eleganckie, solidne pudełko na repliki skafandrów kosmicznych."
	icon_state = "syndiebox"
	illustration = "syndiesuit"

/obj/item/storage/box/fakesyndiesuit/PopulateContents()
	new /obj/item/clothing/head/syndicatefake(src)
	new /obj/item/clothing/suit/syndicatefake(src)

/obj/item/storage/box/mousetraps
	name = "pudełko pułapek na myszy Pest-B-Gon"
	desc = "<span class='alert'>Przechowywać w miejscu niedostępnym dla dzieci.</span>"
	illustration = "mousetrap"

/obj/item/storage/box/mousetraps/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/assembly/mousetrap(src)

/obj/item/storage/box/pillbottles
	name = "pudełko pojemników na pigułki"
	desc = "Z przodu ma obrazki pojemników na pigułki."
	illustration = "pillbox"

/obj/item/storage/box/pillbottles/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/storage/pill_bottle(src)

/obj/item/storage/box/snappops
	name = "pudełko strzelających kapiszonów"
	desc = "Osiem opakowań zabawy! Od 8 lat. Nie nadaje się dla dzieci."
	icon = 'icons/obj/toy.dmi'
	icon_state = "spbox"

/obj/item/storage/box/snappops/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.can_hold = typecacheof(list(/obj/item/toy/snappop))
	STR.max_items = 8

/obj/item/storage/box/snappops/PopulateContents()
	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_FILL_TYPE, /obj/item/toy/snappop)

/obj/item/storage/box/matches
	name = "pudełko zapałek"
	desc = "Małe pudełko zapałek Prawie Ale Nie Całkiem Plazmowych Premium."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "matchbox"
	item_state = "zippo"
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	drop_sound = 'sound/items/handling/matchbox_drop.ogg'
	pickup_sound =  'sound/items/handling/matchbox_pickup.ogg'

/obj/item/storage/box/matches/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 10
	STR.can_hold = typecacheof(list(/obj/item/match))

/obj/item/storage/box/matches/PopulateContents()
	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_FILL_TYPE, /obj/item/match)

/obj/item/storage/box/matches/attackby(obj/item/match/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/match))
		W.matchignite()
		playsound(src.loc, 'sound/items/matchstick_lit.ogg', 100, 1)

/obj/item/storage/box/lights
	name = "pudełko zapasowych żarówek"
	icon = 'icons/obj/storage.dmi'
	illustration = "light"
	desc = "To pudełko jest wyprofilowane w środku tak, że mieszczą się w nim tylko świetlówki i żarówki."
	item_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	foldable = /obj/item/stack/sheet/cardboard //BubbleWrap

/obj/item/storage/box/lights/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 21
	STR.can_hold = typecacheof(list(/obj/item/light/tube, /obj/item/light/bulb))
	STR.max_combined_w_class = 21
	STR.click_gather = FALSE //temp workaround to re-enable filling the light replacer with the box

/obj/item/storage/box/lights/bulbs/PopulateContents()
	for(var/i in 1 to 21)
		new /obj/item/light/bulb(src)

/obj/item/storage/box/lights/tubes
	name = "pudełko zapasowych świetlówek"
	illustration = "lighttube"

/obj/item/storage/box/lights/tubes/PopulateContents()
	for(var/i in 1 to 21)
		new /obj/item/light/tube(src)

/obj/item/storage/box/lights/mixed
	name = "pudełko zapasowych źródeł światła"
	illustration = "lightmixed"

/obj/item/storage/box/lights/mixed/PopulateContents()
	for(var/i in 1 to 14)
		new /obj/item/light/tube(src)
	for(var/i in 1 to 7)
		new /obj/item/light/bulb(src)

/obj/item/storage/box/metalfoam
	name = "pudełko granatów z pianą metalową"
	desc = "Do szybkiego uszczelniania wyrw w kadłubie."
	illustration = "grenade"

/obj/item/storage/box/metalfoam/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/grenade/chem_grenade/metalfoam(src)

/obj/item/storage/box/smart_metal_foam
	name = "pudełko granatów z inteligentną pianą metalową"
	desc = "Do szybkiego uszczelniania wyrw w kadłubie. Ta odmiana dopasowuje się do ścian obszaru."
	illustration = "grenade"

/obj/item/storage/box/smart_metal_foam/PopulateContents()
	for(var/i in 1 to 7)
		new/obj/item/grenade/chem_grenade/smart_metal_foam(src)

/obj/item/storage/box/hug
	name = "pudełko przytulasów"
	desc = "Specjalne pudełko dla wrażliwych ludzi."
	icon_state = "hugbox"
	illustration = "heart"
	foldable = null

/obj/item/storage/box/hug/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] zaciska pudełko przytulasów na swojej tętnicy szyjnej! Chyba jednak nie było takie przytulaśne...</span>")
	return (BRUTELOSS)

/obj/item/storage/box/hug/attack_self(mob/user)
	..()
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, "rustle", 50, 1, -5)
	user.visible_message("<span class='notice'>[user] przytula [src].</span>","<span class='notice'>Przytulasz [src].</span>")

/////clown box & honkbot assembly
/obj/item/storage/box/clown
	name = "pudełko klauna"
	desc = "Kolorowe kartonowe pudełko dla klauna"
	illustration = "clown"

/obj/item/storage/box/clown/attackby(obj/item/I, mob/user, params)
	if((istype(I, /obj/item/bodypart/l_arm/robot)) || (istype(I, /obj/item/bodypart/r_arm/robot)))
		if(contents.len) //prevent accidently deleting contents
			to_chat(user, "<span class='warning'>Najpierw musisz opróżnić [src]!</span>")
			return
		if(!user.temporarilyRemoveItemFromInventory(I))
			return
		qdel(I)
		to_chat(user, "<span class='notice'>Dodajesz kółka do [src]! Masz teraz zespół honkbota! Honk!</span>")
		var/obj/item/bot_assembly/honkbot/A = new
		qdel(src)
		user.put_in_hands(A)
	else
		return ..()

//////
/obj/item/storage/box/hug/medical/PopulateContents()
	new /obj/item/stack/medical/suture(src) // AQ EDIT - tgstation sutures and mesh
	new /obj/item/stack/medical/mesh(src) // AQ EDIT
	new /obj/item/reagent_containers/hypospray/medipen(src)

// Clown survival box
/obj/item/storage/box/hug/survival/PopulateContents()
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/reagent_containers/hypospray/medipen(src)

	if(!isplasmaman(loc))
		new /obj/item/tank/internals/emergency_oxygen/clown(src)
	else
		new /obj/item/tank/internals/plasmaman/belt(src)

	if(HAS_TRAIT(SSstation, STATION_TRAIT_PREMIUM_INTERNALS))
		new /obj/item/flashlight/flare(src)
		new /obj/item/radio/off(src)

/obj/item/storage/box/rubbershot
	name = "pudełko naboi z gumowym śrutem"
	desc = "Pudełko pełne naboi z gumowym śrutem do strzelb przeciwzamieszkowych."
	icon_state = "rubbershot_box"
	illustration = null

/obj/item/storage/box/rubbershot/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/ammo_casing/shotgun/rubbershot(src)

/obj/item/storage/box/lethalshot
	name = "pudełko śmiercionośnych naboi do strzelby"
	desc = "Pudełko pełne śmiercionośnych naboi do strzelb przeciwzamieszkowych."
	icon_state = "lethalshot_box"
	illustration = null

/obj/item/storage/box/lethalshot/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/ammo_casing/shotgun/buckshot(src)

/obj/item/storage/box/beanbag
	name = "pudełko naboi z woreczkiem"
	desc = "Pudełko pełne naboi z woreczkiem."
	icon_state = "rubbershot_box"
	illustration = null

/obj/item/storage/box/beanbag/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/ammo_casing/shotgun/beanbag(src)

/obj/item/storage/box/breacherslug
	name = "pudełko naboi wyważających do strzelby"
	desc = "Pudełko pełne breneki wyważającej, do szybkiego wejścia."
	icon_state = "breachershot_box"
	illustration = null

/obj/item/storage/box/breacherslug/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/ammo_casing/shotgun/breacher(src)

/obj/item/storage/box/actionfigure
	name = "pudełko figurek"
	desc = "Najnowszy zestaw kolekcjonerskich figurek."
	icon_state = "box"

/obj/item/storage/box/actionfigure/PopulateContents()
	for(var/i in 1 to 4)
		var/randomFigure = pick(subtypesof(/obj/item/toy/figure))
		new randomFigure(src)

#define NODESIGN "None"
#define NANOTRASEN "NanotrasenStandard"
#define SYNDI "SyndiSnacks"
#define HEART "Heart"
#define SMILEY "SmileyFace"

/obj/item/storage/box/papersack
	name = "papierowa torba"
	desc = "Starannie zrobiona torba z papieru."
	icon_state = "paperbag_None"
	item_state = "paperbag_None"
	resistance_flags = FLAMMABLE
	foldable = null
	var/design = NODESIGN

/obj/item/storage/box/papersack/update_icon()
	if(contents.len == 0)
		icon_state = "[item_state]"
	else icon_state = "[item_state]_closed"

/obj/item/storage/box/papersack/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pen))
		//if a pen is used on the sack, dialogue to change its design appears
		if(contents.len)
			to_chat(user, "<span class='warning'>Nie możesz modyfikować [src], gdy są w nim przedmioty!</span>")
			return
		var/list/designs = list(NODESIGN, NANOTRASEN, SYNDI, HEART, SMILEY, "Anuluj")
		var/switchDesign = input("Wybierz wzór:", "Wzór papierowej torby", designs[1]) in sortList(designs)
		if(get_dist(usr, src) > 1)
			to_chat(usr, "<span class='warning'>Oddalasz się za bardzo!</span>")
			return
		var/choice = designs.Find(switchDesign)
		if(design == designs[choice] || designs[choice] == "Anuluj")
			return 0
		to_chat(usr, "<span class='notice'>Modyfikujesz [src] długopisem.</span>")
		design = designs[choice]
		icon_state = "paperbag_[design]"
		item_state = "paperbag_[design]"
		switch(designs[choice])
			if(NODESIGN)
				desc = "Starannie zrobiona torba z papieru."
			if(NANOTRASEN)
				desc = "Standardowa papierowa torba śniadaniowa Nanotrasen dla lojalnych pracowników w biegu."
			if(SYNDI)
				desc = "Wzór na tej papierowej torbie to pozostałość po osławionym programie „SyndieSnacks”."
			if(HEART)
				desc = "Papierowa torba z sercem wyrytym na boku."
			if(SMILEY)
				desc = "Papierowa torba z prymitywnym uśmiechem wyrytym na boku."
		return 0
	else if(W.is_sharp())
		if(!contents.len)
			if(item_state == "paperbag_None")
				user.show_message("<span class='notice'>Wycinasz w [src] otwory na oczy.</span>", MSG_VISUAL)
				new /obj/item/clothing/head/papersack(user.loc)
				qdel(src)
				return 0
			else if(item_state == "paperbag_SmileyFace")
				user.show_message("<span class='notice'>Wycinasz w [src] otwory na oczy i zmieniasz wzór.</span>", MSG_VISUAL)
				new /obj/item/clothing/head/papersack/smiley(user.loc)
				qdel(src)
				return 0
	return ..()

#undef NODESIGN
#undef NANOTRASEN
#undef SYNDI
#undef HEART
#undef SMILEY

/obj/item/storage/box/ingredients //This box is for the randomely chosen version the chef spawns with, it shouldn't actually exist.
	name = "pudełko składników"
	illustration = "fruit"
	var/theme_name

/obj/item/storage/box/ingredients/Initialize(mapload)
	. = ..()
	if(theme_name)
		name = "[name] ([theme_name])"
		desc = "Pudełko z dodatkowymi składnikami dla aspirującego kucharza. Motyw pudełka: „[theme_name]”."
		item_state = "syringe_kit"

/obj/item/storage/box/ingredients/wildcard
	theme_name = "niespodzianka"

/obj/item/storage/box/ingredients/wildcard/PopulateContents()
	for(var/i in 1 to 7)
		var/randomFood = pick(
			/obj/item/food/grown/chili,
			/obj/item/food/grown/tomato,
			/obj/item/food/grown/carrot,
			/obj/item/food/grown/potato,
			/obj/item/food/grown/potato/sweet,
			/obj/item/food/grown/apple,
			/obj/item/food/chocolatebar,
			/obj/item/food/grown/cherries,
			/obj/item/food/grown/banana,
			/obj/item/food/grown/cabbage,
			/obj/item/food/grown/soybeans,
			/obj/item/food/grown/corn,
			/obj/item/food/grown/mushroom/plumphelmet,
			/obj/item/food/grown/mushroom/chanterelle,)
		new randomFood(src)

/obj/item/storage/box/ingredients/fiesta
	theme_name = "fiesta"

/obj/item/storage/box/ingredients/fiesta/PopulateContents()
	new /obj/item/food/tortilla(src)
	for(var/i in 1 to 2)
		new /obj/item/food/grown/corn(src)
		new /obj/item/food/grown/soybeans(src)
		new /obj/item/food/grown/chili(src)

/obj/item/storage/box/cheese
	name = "pudełko zaawansowanych bakterii serowych"

/obj/item/storage/box/cheese/PopulateContents()
	new /obj/item/reagent_containers/food/condiment/mesophilic(src)
	new /obj/item/reagent_containers/food/condiment/thermophilic(src)
	new /obj/item/reagent_containers/food/condiment/pcandidum(src)
	new /obj/item/reagent_containers/food/condiment/proqueforti(src)

/obj/item/storage/box/ingredients/italian
	theme_name = "kuchnia włoska"

/obj/item/storage/box/ingredients/italian/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/food/grown/tomato(src)
		new /obj/item/food/meatball(src)
	new /obj/item/reagent_containers/food/drinks/bottle/wine(src)

/obj/item/storage/box/ingredients/vegetarian
	theme_name = "wegetariańskie"

/obj/item/storage/box/ingredients/vegetarian/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/food/grown/carrot(src)
	new /obj/item/food/grown/eggplant(src)
	new /obj/item/food/grown/potato(src)
	new /obj/item/food/grown/apple(src)
	new /obj/item/food/grown/corn(src)
	new /obj/item/food/grown/tomato(src)

/obj/item/storage/box/ingredients/american
	theme_name = "kuchnia amerykańska"

/obj/item/storage/box/ingredients/american/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/food/grown/potato(src)
		new /obj/item/food/grown/tomato(src)
		new /obj/item/food/grown/corn(src)
	new /obj/item/food/meatball(src)

/obj/item/storage/box/ingredients/fruity
	theme_name = "owocowe"

/obj/item/storage/box/ingredients/fruity/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/food/grown/apple(src)
		new /obj/item/food/grown/citrus/orange(src)
	new /obj/item/food/grown/citrus/lemon(src)
	new /obj/item/food/grown/citrus/lime(src)
	new /obj/item/food/grown/watermelon(src)

/obj/item/storage/box/ingredients/sweets
	theme_name = "słodycze"

/obj/item/storage/box/ingredients/sweets/PopulateContents()
	for(var/i in 1 to 2)
		new/obj/item/food/grown/cherries(src)
		new /obj/item/food/grown/banana(src)
	new /obj/item/food/chocolatebar(src)
	new /obj/item/food/grown/cocoapod(src)
	new /obj/item/food/grown/apple(src)

/obj/item/storage/box/ingredients/delights
	theme_name = "przysmaki"

/obj/item/storage/box/ingredients/delights/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/food/grown/potato/sweet(src)
		new /obj/item/food/grown/bluecherries(src)
	new /obj/item/food/grown/vanillapod(src)
	new /obj/item/food/grown/cocoapod(src)
	new /obj/item/food/grown/berries(src)

/obj/item/storage/box/ingredients/grains
	theme_name = "zboża"

/obj/item/storage/box/ingredients/grains/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/food/grown/oat(src)
	new /obj/item/food/grown/wheat(src)
	new /obj/item/food/grown/cocoapod(src)
	new /obj/item/reagent_containers/honeycomb(src)
	new /obj/item/plant_seeds/preset/poppy(src)

/obj/item/storage/box/ingredients/carnivore
	theme_name = "dla mięsożerców"

/obj/item/storage/box/ingredients/carnivore/PopulateContents()
	new /obj/item/food/meat/slab/bear(src)
	new /obj/item/food/meat/slab/spider(src)
	new /obj/item/food/spidereggs(src)
	new /obj/item/food/fishmeat/carp(src)
	new /obj/item/food/meat/slab/xeno(src)
	new /obj/item/food/meat/slab/corgi(src)
	new /obj/item/food/meatball(src)

/obj/item/storage/box/ingredients/exotic
	theme_name = "egzotyczne"

/obj/item/storage/box/ingredients/exotic/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/food/fishmeat/carp(src)
		new /obj/item/food/grown/soybeans(src)
		new /obj/item/food/grown/cabbage(src)
	new /obj/item/food/grown/chili(src)

/obj/item/storage/box/emptysandbags
	name = "pudełko pustych worków z piaskiem"
	illustration = "sandbag"

/obj/item/storage/box/emptysandbags/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/emptysandbag(src)

/obj/item/storage/box/rndboards
	name = "\proper dziedzictwo Wyzwoliciela"
	desc = "Pudełko z prezentem dla godnych golemów."
	illustration = "scicircuit"

/obj/item/storage/box/rndboards/PopulateContents()
	new /obj/item/circuitboard/machine/protolathe(src)
	new /obj/item/circuitboard/machine/destructive_analyzer(src)
	new /obj/item/circuitboard/machine/circuit_imprinter(src)
	new /obj/item/circuitboard/computer/rdconsole(src)

/obj/item/storage/box/silver_sulf
	name = "pudełko plastrów z sulfadiazyną srebra"
	desc = "Zawiera plastry do leczenia oparzeń."
	illustration = "firepatch"

/obj/item/storage/box/silver_sulf/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/patch/silver_sulf(src)

/obj/item/storage/box/fountainpens
	name = "pudełko piór wiecznych"
	illustration = "fpen"

/obj/item/storage/box/fountainpens/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/pen/fountain(src)

/obj/item/storage/box/holy_grenades
	name = "pudełko świętych granatów ręcznych"
	desc = "Zawiera kilka granatów do szybkiego wypleniania herezji."
	illustration = "grenade"

/obj/item/storage/box/holy_grenades/PopulateContents()
	for(var/i in 1 to 7)
		new/obj/item/grenade/chem_grenade/holy(src)

/obj/item/storage/box/stockparts/basic //for ruins where it's a bad idea to give access to an autolathe/protolathe, but still want to make stock parts accessible
	name = "pudełko części"
	desc = "Zawiera różne podstawowe części."

/obj/item/storage/box/stockparts/basic/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stock_parts/capacitor = 3,
		/obj/item/stock_parts/scanning_module = 3,
		/obj/item/stock_parts/manipulator = 3,
		/obj/item/stock_parts/micro_laser = 3,
		/obj/item/stock_parts/matter_bin = 3)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/stockparts/deluxe
	name = "pudełko luksusowych części"
	desc = "Zawiera różne luksusowe części."
	icon_state = "syndiebox"

/obj/item/storage/box/stockparts/deluxe/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stock_parts/capacitor/quadratic = 3,
		/obj/item/stock_parts/scanning_module/triphasic = 3,
		/obj/item/stock_parts/manipulator/femto = 3,
		/obj/item/stock_parts/micro_laser/quadultra = 3,
		/obj/item/stock_parts/matter_bin/bluespace = 3)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/dishdrive
	name = "zestaw do samodzielnego złożenia Dish Drive"
	desc = "Zawiera wszystko, czego potrzebujesz do zbudowania własnego Dish Drive!"
	custom_premium_price = 200

/obj/item/storage/box/dishdrive/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stack/sheet/iron/five = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/circuitboard/machine/dish_drive = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/screwdriver = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/material
	name = "pudełko materiałów"
	illustration = "implant"

/obj/item/storage/box/material/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 1000
	STR.max_w_class = WEIGHT_CLASS_GIGANTIC
	STR.max_items = 1000
	STR.allow_big_nesting = TRUE

/obj/item/storage/box/material/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stack/sheet/iron/fifty=1, \
		/obj/item/stack/sheet/glass/fifty=1,\
		/obj/item/stack/sheet/rglass=50,\
		/obj/item/stack/sheet/mineral/copper/fifty=1,\
		/obj/item/stack/sheet/plasmaglass=50,\
		/obj/item/stack/sheet/plasmarglass=50,\
		/obj/item/stack/sheet/titaniumglass=50,\
		/obj/item/stack/sheet/plastitaniumglass=50,\
		/obj/item/stack/sheet/plasteel=50,\
		/obj/item/stack/sheet/mineral/plastitanium=50,\
		/obj/item/stack/sheet/mineral/titanium=50,\
		/obj/item/stack/sheet/mineral/gold=50,\
		/obj/item/stack/sheet/mineral/silver=50,\
		/obj/item/stack/sheet/mineral/uranium=50,\
		/obj/item/stack/sheet/mineral/plasma=50,\
		/obj/item/stack/sheet/mineral/diamond=50,\
		/obj/item/stack/ore/bluespace_crystal/refined=50,\
		/obj/item/stack/sheet/mineral/bananium=50,\
		/obj/item/stack/sheet/plastic/fifty=1,\
		/obj/item/stack/sheet/runed_metal/fifty=1,\
		/obj/item/stack/tile/brass/fifty=1,\
		/obj/item/stack/sheet/mineral/abductor=50,\
		/obj/item/stack/sheet/mineral/adamantine=50,\
		/obj/item/stack/sheet/mineral/wood=50,\
		/obj/item/stack/sheet/cotton/cloth=50,\
		/obj/item/stack/sheet/leather=50,\
		/obj/item/stack/sheet/bone=12,\
		/obj/item/stack/sheet/cardboard/fifty=1,\
		/obj/item/stack/sheet/mineral/sandstone=50,\
		/obj/item/stack/sheet/mineral/snow=50
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/debugtools
	name = "pudełko narzędzi debugowania"
	icon_state = "syndiebox"

/obj/item/storage/box/debugtools/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 1000
	STR.max_w_class = WEIGHT_CLASS_GIGANTIC
	STR.max_items = 1000
	STR.allow_big_nesting = TRUE

/obj/item/storage/box/debugtools/PopulateContents()
	var/static/items_inside = list(
		/obj/item/flashlight/emp/debug=1,\
		/obj/item/modular_computer/tablet/pda=1,\
		/obj/item/modular_computer/tablet/preset/advanced=1,\
		/obj/item/storage/belt/military/abductor/full=1,\
		/obj/item/geiger_counter=1,\
		/obj/item/holosign_creator/atmos=1,\
		/obj/item/pipe_dispenser=1,\
		/obj/item/construction/rcd/combat/admin=1,\
		/obj/item/areaeditor/blueprints=1,\
		/obj/item/card/emag=1,\
		/obj/item/stack/spacecash/c1000=50,\
		/obj/item/healthanalyzer/advanced=1,\
		/obj/item/disk/tech_disk/debug=1,\
		/obj/item/disk/surgery/debug=1,\
		/obj/item/disk/data/debug=1,\
		/obj/item/uplink/debug=1,\
		/obj/item/uplink/nuclear/debug=1,\
		/obj/item/spellbook=1,\
		/obj/item/storage/box/beakers/bluespace=1,\
		/obj/item/storage/box/beakers/variety=1,\
		/obj/item/storage/box/material=1
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/deputy
	name = "pudełko opasek aspiranta"
	desc = "Do wydania osobom upoważnionym do pełnienia funkcji aspiranta ochrony."
	icon_state = "secbox"
	illustration = "depband"

/obj/item/storage/box/deputy/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/clothing/accessory/armband/deputy(src)
		new /obj/item/card/id/pass/deputy(src)

/obj/item/storage/box/radiokey
	name = "pudełko zwykłych kluczy szyfrujących"
	desc = "Nie powinieneś tego widzieć. Napisz ahelpa."
	icon_state = "radiobox"
	var/radio_key = /obj/item/encryptionkey

/obj/item/storage/box/radiokey/PopulateContents()
	for(var/i in 1 to 7)
		new radio_key(src)

/obj/item/storage/box/radiokey/com
	name = "pudełko kluczy szyfrujących dowództwa"
	desc = "Zapasowy klucz szyfrujący dla każdego członka dowództwa, do tego klucz wzmacniający i ogólny klucz dowództwa."
	icon_state = "radiobox_gold"

/obj/item/storage/box/radiokey/com/PopulateContents()
	new /obj/item/encryptionkey/heads/rd(src)
	new /obj/item/encryptionkey/heads/hos(src)
	new /obj/item/encryptionkey/heads/ce(src)
	new /obj/item/encryptionkey/heads/cmo(src)
	new /obj/item/encryptionkey/heads/hop(src)
	new /obj/item/encryptionkey/heads/master_at_arms(src) //NSV13 - added MAA
	new /obj/item/encryptionkey/headset_com(src)
	new /obj/item/encryptionkey/amplification(src)

/obj/item/storage/box/radiokey/sci
	name = "pudełko kluczy szyfrujących nauki"
	desc = "Dla NAUKI!"
	radio_key = /obj/item/encryptionkey/headset_sci

/obj/item/storage/box/radiokey/sec
	name = "pudełko kluczy szyfrujących ochrony"
	desc = "Daje dostęp do radia ochrony stacji."
	radio_key = /obj/item/encryptionkey/headset_sec

/obj/item/storage/box/radiokey/eng
	name = "pudełko kluczy szyfrujących inżynierii"
	desc = "Skazuje cię na słuchanie Poly'ego przez całą wieczność."
	radio_key = /obj/item/encryptionkey/headset_eng

/obj/item/storage/box/radiokey/med
	name = "pudełko kluczy szyfrujących medycyny"
	desc = "Polecane przez 9 na 10 lekarzy."
	radio_key = /obj/item/encryptionkey/headset_med

/obj/item/storage/box/radiokey/srv
	name = "pudełko kluczy szyfrujących serwisu"
	desc = "Kanał dla służby."
	radio_key = /obj/item/encryptionkey/headset_service

/obj/item/storage/box/radiokey/car
	name = "pudełko kluczy szyfrujących zaopatrzenia"  // qm can always buy mining conscript
	desc = "Czyni cię niewolnikiem kwatermistrza."
	radio_key = /obj/item/encryptionkey/headset_cargo

/obj/item/storage/box/radiokey/cap  // admin spawn
	name = "wspaniałe pudełko kluczy szyfrujących kapitana"
	desc = "Radio z pełnym dostępem."
	icon_state = "radiobox_gold"
	radio_key = /obj/item/encryptionkey/heads/captain

/obj/item/storage/box/radiokey/clown  // honk
	name = "\improper fałszywe klucze szyfrujące H.O.N.K. CO"
	desc = "Zrób przyjaciołom totalnego psikusa tymi realistycznymi kluczami szyfrującymi!"

/obj/item/storage/box/radiokey/clown/PopulateContents()
	new /obj/item/encryptionkey/heads/rd/fake(src)
	new /obj/item/encryptionkey/heads/hos/fake(src)
	new /obj/item/encryptionkey/heads/ce/fake(src)
	new /obj/item/encryptionkey/heads/cmo/fake(src)
	new /obj/item/encryptionkey/heads/hop/fake(src)
	new /obj/item/encryptionkey/heads/master_at_arms/fake(src) //NSV13 - added MAA
