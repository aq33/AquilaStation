/* Backpacks
 * Contains:
 *		Backpack
 *		Backpack Types
 *		Satchel Types
 */

/*
 * Backpack
 */

/obj/item/storage/backpack
	name = "plecak"
	desc = "Nosisz go na plecach i trzymasz w nim rzeczy."
	icon_state = "backpack"
	item_state = "backpack"
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK	//ERROOOOO
	resistance_flags = NONE
	max_integrity = 300

/obj/item/storage/backpack/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 21
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_items = 21

/*
 * Backpack Types
 */

/obj/item/storage/backpack/old/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 12

/obj/item/storage/backpack/holding
	name = "torba bez dna"
	desc = "Plecak, który otwiera się na lokalną kieszeń bluespace."
	icon_state = "holdingpack"
	item_state = "holdingpack"
	resistance_flags = FIRE_PROOF
	item_flags = NO_MAT_REDEMPTION
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 50, "stamina" = 0, "bleed" = 0)
	component_type = /datum/component/storage/concrete/bluespace/bag_of_holding

/obj/item/storage/backpack/holding/clown
	name = "klauńska torba bez dna"
	desc = "Zaawansowany klauński plecak mieszczący ogromne ilości sprzętu do psikusów"
	icon_state = "clownpack"
	item_state = "clownpack"

/obj/item/storage/backpack/holding/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.allow_big_nesting = TRUE
	STR.max_w_class = WEIGHT_CLASS_GIGANTIC
	STR.max_combined_w_class = 35

/obj/item/storage/backpack/holding/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] wskakuje do [src]! Wygląda na to, że próbuje popełnić samobójstwo.</span>")
	user.dropItemToGround(src, TRUE)
	user.Stun(100, ignore_canstun = TRUE)
	sleep(20)
	playsound(src, "rustle", 50, 1, -5)
	qdel(user)

/obj/item/storage/backpack/holding/singularity_act(current_size)
	var/dist = max((current_size - 2),1)
	explosion(src.loc,(dist),(dist*2),(dist*4))

/obj/item/storage/backpack/hammerspace // The Juggernaut gear
	name = "plecak z kieszenią hiperprzestrzeni"
	desc = "Plecak, który otwiera się na niemal nieskończoną kieszeń bluespace."
	icon_state = "hammerspace"
	resistance_flags = FIRE_PROOF
	item_flags = NO_MAT_REDEMPTION
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100, "stamina" = 0, "bleed" = 0)
	component_type = /datum/component/storage/concrete/bluespace/bag_of_holding

/obj/item/storage/backpack/hammerspace/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.allow_big_nesting = TRUE
	STR.max_w_class = WEIGHT_CLASS_GIGANTIC
	STR.max_combined_w_class = 1000
	STR.max_items = 200
	STR.allow_quick_gather = TRUE
	STR.allow_quick_empty = TRUE
	STR.display_numerical_stacking = TRUE
	STR.click_gather = TRUE

/obj/item/storage/backpack/santabag
	name = "worek z prezentami Mikołaja"
	desc = "Kosmiczny Mikołaj rozwozi w nim w Boże Narodzenie prezenty dla wszystkich grzecznych dzieci w kosmosie! Rany, ale jest wielki!"
	icon_state = "giftbag0"
	item_state = "giftbag"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/storage/backpack/santabag/Initialize(mapload)
	. = ..()
	regenerate_presents()

/obj/item/storage/backpack/santabag/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 60

/obj/item/storage/backpack/santabag/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] zakłada [src] na głowę i mocno zaciąga! Chyba nie czuje świątecznej atmosfery...</span>")
	return (OXYLOSS)

/obj/item/storage/backpack/santabag/proc/regenerate_presents()
	addtimer(CALLBACK(src, PROC_REF(regenerate_presents)), 30 SECONDS)

	var/mob/M = get(loc, /mob)
	if(!istype(M))
		return
	if(M.mind && HAS_TRAIT(M.mind, TRAIT_CANNOT_OPEN_PRESENTS))
		var/datum/component/storage/STR = GetComponent(/datum/component/storage)
		var/turf/floor = get_turf(src)
		var/obj/item/I = new /obj/item/a_gift/anything(floor)
		if(STR.can_be_inserted(I, stop_messages=TRUE))
			STR.handle_item_insertion(I, prevent_warning=TRUE)
		else
			qdel(I)


/obj/item/storage/backpack/cultpack
	name = "stelaż na trofea"
	desc = "Przydaje się zarówno do noszenia dodatkowego sprzętu, jak i do dumnego obwieszczania światu swojego szaleństwa."
	icon_state = "cultpack"
	item_state = "backpack"

/obj/item/storage/backpack/clown
	name = "Giggles von Honkerton"
	desc = "Plecak zrobiony przez firmę Honk! Co."
	icon_state = "clownpack"
	item_state = "clownpack"

/obj/item/storage/backpack/explorer
	name = "Torba Górnicza"
	desc = "Solidny plecak do przechowywania łupów."
	icon_state = "explorerpack"
	item_state = "explorerpack"

/obj/item/storage/backpack/mime
	name = "Parcel Parceaux"
	desc = "Cichy plecak stworzony dla cichych pracowników. Slience Corp."
	icon_state = "mimepack"
	item_state = "mimepack"

/obj/item/storage/backpack/medic
	name = "plecak medyczny"
	desc = "Plecak zaprojektowany do użytku w sterylnym środowisku."
	icon_state = "medicalpack"
	item_state = "medicalpack"

/obj/item/storage/backpack/security
	name = "plecak ochrony"
	desc = "Bardzo wytrzymały plecak."
	icon_state = "securitypack"
	item_state = "securitypack"

/obj/item/storage/backpack/captain
	name = "plecak kapitana"
	desc = "Specjalny plecak stworzony wyłącznie dla oficerów Nanotrasen."
	icon_state = "captainpack"
	item_state = "captainpack"

/obj/item/storage/backpack/industrial
	name = "plecak przemysłowy"
	desc = "Wytrzymały plecak na codzienną harówkę na stacji."
	icon_state = "engiepack"
	item_state = "engiepack"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/botany
	name = "plecak botaniki"
	desc = "Plecak wyprodukowany w 100% z naturalnych włókien."
	icon_state = "botpack"
	item_state = "botpack"

/obj/item/storage/backpack/chemistry
	name = "plecak chemii"
	desc = "Plecak zaprojektowany z myślą do przetrwania niebezpiecznych płynów."
	icon_state = "chempack"
	item_state = "chempack"

/obj/item/storage/backpack/genetics
	name = "plecak genetyki"
	desc = "Plecak bardzo wytrzymały, na wypadek gdyby ktoś próbował Cię zabić."
	icon_state = "genepack"
	item_state = "genepack"

/obj/item/storage/backpack/science
	name = "plecak nauki"
	desc = "Specjalnie zaprojektowany plecak. Jest ognioodporny i posiada lekki zapach plazmy."
	icon_state = "toxpack"
	item_state = "toxpack"

/obj/item/storage/backpack/virology
	name = "plecak wirologii"
	desc = "Plecak wyprodukowany z hipoalergicznych materiałów. Pachnie jak małpa."
	icon_state = "viropack"
	item_state = "viropack"

/obj/item/storage/backpack/ert
	name = "plecak Dowódcy Zespołu Reagowania Kryzysowego"
	desc = "Pojemny plecak z mnóstwem kieszeni, noszony przez Dowódcę Zespołu Reagowania Kryzysowego."
	icon_state = "ert_commander"
	item_state = "securitypack"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/ert/security
	name = "plecak Operatora Kryzysowego Reagowania"
	desc = "Pojemny plecak z mnóstwem kieszeni, noszony przez Operatorów Zespołu Reagowania Kryzysowego."
	icon_state = "ert_security"

/obj/item/storage/backpack/ert/medical
	name = "plecak Sanitariusza Kryzysowego Reagowania"
	desc = "Pojemny plecak z mnóstwem kieszeni, noszony przez Sanitariuszy Zespołu Reagowania Kryzysowego."
	icon_state = "ert_medical"

/obj/item/storage/backpack/ert/engineer
	name = "plecak Inżyniera Kryzysowego Reagowania"
	desc = "Pojemny plecak z mnóstwem kieszeni, noszony przez Inżynierów Zespołu Reagowania Kryzysowego."
	icon_state = "ert_engineering"

/////////////////
//DONATOR ITEMS//
/////////////////

/obj/item/storage/backpack/cak
	name = "plecak Cak"
	desc = "Słodki plecak przypominający Cak."
	icon_state = "cakpack"
	item_state = "cakpack"

/obj/item/storage/backpack/ian
	name = "plecak Ian"
	desc = "Słodki plecak przypominający Iana."
	icon_state = "ianpack"
	item_state = "ianpack"

/obj/item/storage/backpack/lisa
	name = "plecak Lisa"
	desc = "Słodki plecak przypominający Lisę."
	icon_state = "lisapack"
	item_state = "lisapack"

/obj/item/storage/backpack/renault
	name = "plecak Renault"
	desc = "Słodki plecak przypominający Renault."
	icon_state = "renaultpack"
	item_state = "renaultpack"

/obj/item/storage/backpack/runtime
	name = "plecak Runtime"
	desc = "Słodki plecak przypominający Runtime."
	icon_state = "runtimepack"
	item_state = "runtimepack"

/*
 * Satchel Types
 */

/obj/item/storage/backpack/satchel
	name = "torba na ramię"
	desc = "Modnie wyglądająca torba na ramię."
	icon_state = "satchel-norm"

/obj/item/storage/backpack/satchel/leather
	name = "skórzana torba na ramię"
	desc = "Bardzo elegancka torba na ramię z porządnej skóry."
	icon_state = "satchel"
	item_state = "satchel"

/obj/item/storage/backpack/satchel/leather/withwallet/PopulateContents()
	new /obj/item/storage/wallet/random(src)

/obj/item/storage/backpack/satchel/fireproof
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/satchel/eng
	name = "przemysłowa torba na ramię"
	desc = "Wytrzymała torba na ramię z dodatkowymi kieszeniami."
	icon_state = "satchel-eng"
	item_state = "satchel-eng"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/satchel/med
	name = "medyczna torba na ramię"
	desc = "Sterylna torba na ramię używana w działach medycznych."
	icon_state = "satchel-med"
	item_state = "satchel-med"

/obj/item/storage/backpack/satchel/vir
	name = "torba na ramię wirologa"
	desc = "Sterylna torba na ramię w barwach wirologów."
	icon_state = "satchel-vir"
	item_state = "satchel-vir"

/obj/item/storage/backpack/satchel/chem
	name = "torba na ramię chemika"
	desc = "Sterylna torba na ramię w barwach chemików."
	icon_state = "satchel-chem"
	item_state = "satchel-chem"

/obj/item/storage/backpack/satchel/gen
	name = "torba na ramię genetyka"
	desc = "Sterylna torba na ramię w barwach genetyków."
	icon_state = "satchel-gen"
	item_state = "satchel-gen"

/obj/item/storage/backpack/satchel/tox
	name = "torba na ramię naukowca"
	desc = "Przydaje się do noszenia materiałów badawczych."
	icon_state = "satchel-tox"
	item_state = "satchel-tox"

/obj/item/storage/backpack/satchel/hyd
	name = "torba na ramię botanika"
	desc = "Torba na ramię w całości z naturalnych włókien."
	icon_state = "satchel-hyd"
	item_state = "satchel-hyd"

/obj/item/storage/backpack/satchel/sec
	name = "policyjna torba na ramię"
	desc = "Solidna torba na ramię na potrzeby ochrony."
	icon_state = "satchel-sec"
	item_state = "satchel-sec"

/obj/item/storage/backpack/satchel/explorer
	name = "torba na ramię odkrywcy"
	desc = "Solidna torba na ramię do chowania łupów."
	icon_state = "satchel-explorer"
	item_state = "satchel-explorer"

/obj/item/storage/backpack/satchel/cap
	name = "torba na ramię kapitana"
	desc = "Ekskluzywna torba na ramię dla oficerów Nanotrasen."
	icon_state = "satchel-cap"
	item_state = "satchel-cap"

/obj/item/storage/backpack/satchel/flat
	name = "torba na ramię przemytnika"
	desc = "Bardzo płaska torba na ramię, która łatwo mieści się w ciasnych miejscach."
	icon_state = "satchel-flat"
	item_state = "satchel-flat"
	w_class = WEIGHT_CLASS_NORMAL //Can fit in backpacks itself.
	level = 1

/obj/item/storage/backpack/satchel/flat/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_T_RAY_VISIBLE, TRAIT_GENERIC)

/obj/item/storage/backpack/satchel/flat/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 15
	STR.cant_hold = typecacheof(list(/obj/item/storage/backpack/satchel/flat)) //muh recursive backpacks

/obj/item/storage/backpack/satchel/flat/hide(intact)
	if(intact)
		invisibility = INVISIBILITY_OBSERVER
		anchored = TRUE //otherwise you can start pulling, cover it, and drag around an invisible backpack.
		icon_state = "[initial(icon_state)]2"
	else
		invisibility = initial(invisibility)
		anchored = FALSE
		icon_state = initial(icon_state)

/obj/item/storage/backpack/satchel/flat/PopulateContents()
	var/datum/supply_pack/costumes_toys/randomised/contraband/C = new
	for(var/i in 1 to 2)
		var/ctype = pick(C.contains)
		new ctype(src)

	qdel(C)

/obj/item/storage/backpack/satchel/flat/with_tools/PopulateContents()
	new /obj/item/stack/tile/plasteel(src)
	new /obj/item/crowbar(src)

	..()

/obj/item/storage/backpack/satchel/flat/empty/PopulateContents()
	return

/obj/item/storage/backpack/duffelbag
	name = "torba podróżna"
	desc = "Duża torba podróżna na dodatkowe rzeczy."
	icon_state = "duffel"
	item_state = "duffel"
	slowdown = 1

/obj/item/storage/backpack/duffelbag/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 30

/obj/item/storage/backpack/duffelbag/captain
	name = "torba podróżna kapitana"
	desc = "Duża torba podróżna na dodatkowe kapitańskie dobra."
	icon_state = "duffel-captain"
	item_state = "duffel-captain"

/obj/item/storage/backpack/duffelbag/med
	name = "medyczna torba podróżna"
	desc = "Duża torba podróżna na dodatkowe zapasy medyczne."
	icon_state = "duffel-med"
	item_state = "duffel-med"

/obj/item/storage/backpack/duffelbag/med/surgery
	name = "chirurgiczna torba podróżna"
	desc = "Duża torba podróżna na dodatkowe zapasy medyczne. Ta wygląda na przeznaczoną do noszenia narzędzi chirurgicznych."

/obj/item/storage/backpack/duffelbag/med/surgery/PopulateContents()
	new /obj/item/scalpel(src)
	new /obj/item/hemostat(src)
	new /obj/item/retractor(src)
	new /obj/item/circular_saw(src)
	new /obj/item/surgicaldrill(src)
	new /obj/item/cautery(src)
	new /obj/item/surgical_drapes(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/razor(src)
	new /obj/item/reagent_containers/medspray/sterilizine(src)
	new /obj/item/blood_filter(src)

/obj/item/storage/backpack/duffelbag/sec
	name = "policyjna torba podróżna"
	desc = "Duża torba podróżna na dodatkowe zapasy ochrony i amunicję."
	icon_state = "duffel-sec"
	item_state = "duffel-sec"

/obj/item/storage/backpack/duffelbag/sec/surgery
	name = "chirurgiczna torba podróżna"
	desc = "Duża torba podróżna na dodatkowe zapasy. Ta ma materiałową wkładkę z miejscem na różne ostro wyglądające narzędzia."

/obj/item/storage/backpack/duffelbag/sec/surgery/PopulateContents()
	new /obj/item/scalpel(src)
	new /obj/item/hemostat(src)
	new /obj/item/retractor(src)
	new /obj/item/circular_saw(src)
	new /obj/item/surgicaldrill(src)
	new /obj/item/cautery(src)
	new /obj/item/surgical_drapes(src)
	new /obj/item/clothing/mask/surgical(src)
	new /obj/item/reagent_containers/medspray/sterilizine(src)
	new /obj/item/blood_filter(src)

/obj/item/storage/backpack/duffelbag/sec/deputy
	name = "torba podróżna ze sprzętem aspiranta"
	desc = "Duża torba podróżna na dodatkowe zapasy. Ta ma przegródki na różne ubrania i sprzęt."
	custom_premium_price = 500

/obj/item/storage/backpack/duffelbag/sec/deputy/PopulateContents()
	new /obj/item/clothing/head/soft/sec(src)
	new /obj/item/radio/headset/headset_sec(src)
	new /obj/item/clothing/glasses/hud/security/deputy(src)
	new /obj/item/clothing/under/rank/security/officer/mallcop/deputy(src) //AQUILA EDIT - mundur policyjny Aspiranta
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/storage/belt/security/deputy(src)
	new /obj/item/clothing/accessory/armband/deputy(src)

/obj/item/storage/backpack/duffelbag/engineering
	name = "przemysłowa torba podróżna"
	desc = "Duża torba podróżna na dodatkowe narzędzia i zapasy."
	icon_state = "duffel-eng"
	item_state = "duffel-eng"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/duffelbag/drone
	name = "torba podróżna drona"
	desc = "Duża torba podróżna na narzędzia i czapki."
	icon_state = "duffel-drone"
	item_state = "duffel-drone"
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/duffelbag/drone/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/stack/cable_coil(src)
	new /obj/item/wirecutters(src)
	new /obj/item/multitool(src)

/obj/item/storage/backpack/duffelbag/clown
	name = "torba podróżna klauna"
	desc = "Duża torba podróżna na mnóstwo zabawnych gagów!"
	icon_state = "duffel-clown"
	item_state = "duffel-clown"

/obj/item/storage/backpack/duffelbag/clown/cream_pie/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/food/pie/cream(src)

/obj/item/storage/backpack/fireproof
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/duffelbag/syndie
	name = "podejrzanie wyglądająca torba podróżna"
	desc = "Duża torba podróżna na dodatkowe zapasy taktyczne."
	icon_state = "duffel-syndie"
	item_state = "duffel-syndieammo"
	slowdown = 0
	resistance_flags = FIRE_PROOF

/obj/item/storage/backpack/duffelbag/syndie/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.silent = TRUE

/obj/item/storage/backpack/duffelbag/syndie/hitman
	desc = "Duża torba podróżna na dodatkowe rzeczy. Z tyłu widnieje logo Nanotrasen."
	icon_state = "duffel-syndieammo"
	item_state = "duffel-syndieammo"

/obj/item/storage/backpack/duffelbag/syndie/hitman/PopulateContents()
	new /obj/item/clothing/under/suit/black(src)
	new /obj/item/clothing/accessory/waistcoat(src)
	new /obj/item/clothing/suit/toggle/lawyer/black(src)
	new /obj/item/clothing/shoes/laceup(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/glasses/sunglasses/advanced(src)
	new /obj/item/clothing/head/fedora(src)

/obj/item/storage/backpack/duffelbag/syndie/med
	name = "medyczna torba podróżna"
	desc = "Duża torba podróżna na dodatkowe taktyczne zapasy medyczne."
	icon_state = "duffel-syndiemed"
	item_state = "duffel-syndiemed"

/obj/item/storage/backpack/duffelbag/syndie/surgery
	name = "chirurgiczna torba podróżna"
	desc = "Podejrzanie wyglądająca torba podróżna na narzędzia chirurgiczne."
	icon_state = "duffel-syndiemed"
	item_state = "duffel-syndiemed"

/obj/item/storage/backpack/duffelbag/syndie/surgery/PopulateContents()
	new /obj/item/scalpel(src)
	new /obj/item/hemostat(src)
	new /obj/item/retractor(src)
	new /obj/item/circular_saw(src)
	new /obj/item/surgicaldrill(src)
	new /obj/item/cautery(src)
	new /obj/item/surgical_drapes(src)
	new /obj/item/clothing/suit/straight_jacket(src)
	new /obj/item/clothing/mask/muzzle(src)
	new /obj/item/mmi/syndie(src)

/obj/item/storage/backpack/duffelbag/syndie/ammo
	name = "torba podróżna na amunicję"
	desc = "Duża torba podróżna na dodatkową amunicję i zapasy."
	icon_state = "duffel-syndieammo"
	item_state = "duffel-syndieammo"

/obj/item/storage/backpack/duffelbag/syndie/ammo/shotgun
	desc = "Duża torba podróżna wypchana po brzegi magazynkami do strzelby Bulldog."

/obj/item/storage/backpack/duffelbag/syndie/ammo/shotgun/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/ammo_box/magazine/m12g/stun(src) //NSV13 - added stun rounds
	new /obj/item/ammo_box/magazine/m12g/slug(src)
	new /obj/item/ammo_box/magazine/m12g/dragon(src)

/obj/item/storage/backpack/duffelbag/syndie/ammo/smg
	desc = "Duża torba podróżna wypchana po brzegi magazynkami do C-20r."

/obj/item/storage/backpack/duffelbag/syndie/ammo/smg/PopulateContents()
	for(var/i in 1 to 9)
		new /obj/item/ammo_box/magazine/smgm45(src)

/obj/item/storage/backpack/duffelbag/syndie/c20rbundle
	desc = "Duża torba podróżna z C-20r, kilkoma magazynkami i tanio wyglądającym tłumikiem."

/obj/item/storage/backpack/duffelbag/syndie/c20rbundle/PopulateContents()
	new /obj/item/ammo_box/magazine/smgm45(src)
	new /obj/item/ammo_box/magazine/smgm45(src)
	new /obj/item/gun/ballistic/automatic/c20r(src)
	new /obj/item/suppressor/specialoffer(src)

/obj/item/storage/backpack/duffelbag/syndie/bulldogbundle
	desc = "Duża torba podróżna z Bulldogiem, kilkoma magazynkami bębnowymi i parą gogli termowizyjnych."

/obj/item/storage/backpack/duffelbag/syndie/bulldogbundle/PopulateContents()
	new /obj/item/gun/ballistic/shotgun/bulldog(src)
	new /obj/item/ammo_box/magazine/m12g/stun(src) //NSV13 - added stun rounds
	new /obj/item/ammo_box/magazine/m12g(src)
	new /obj/item/clothing/glasses/thermal/syndi(src)

/obj/item/storage/backpack/duffelbag/syndie/med/medicalbundle
	desc = "Duża torba podróżna z taktyczną apteczką, karabinem maszynowym Donksoft, wielkim pudłem strzałek przeciwzamieszkowych i podróbką butów magnetycznych."

/obj/item/storage/backpack/duffelbag/syndie/med/medicalbundle/PopulateContents()
	new /obj/item/clothing/shoes/magboots/syndie(src)
	new /obj/item/storage/firstaid/tactical(src)
	new /obj/item/gun/ballistic/automatic/l6_saw/toy(src)
	new /obj/item/ammo_box/foambox/riot(src)

/obj/item/storage/backpack/duffelbag/syndie/med/medicalbundle
	desc = "Duża torba podróżna ze sprzętem medycznym, lekkim karabinem maszynowym Donksoft, wielkim pudłem strzałek przeciwzamieszkowych i podróbką butów magnetycznych."

/obj/item/storage/backpack/duffelbag/syndie/med/medicalbundle/PopulateContents()
	new /obj/item/clothing/shoes/magboots/syndie(src)
	new /obj/item/storage/firstaid/tactical(src)
	new /obj/item/gun/ballistic/automatic/l6_saw/toy(src)
	new /obj/item/ammo_box/foambox/riot(src)

/obj/item/storage/backpack/duffelbag/syndie/med/bioterrorbundle
	desc = "Duża torba podróżna ze śmiertelnymi chemikaliami, ręcznym rozpylaczem chemikaliów, granatem z pianą bioterrorystyczną, karabinkiem szturmowym Donksoft, pudełkiem strzałek przeciwzamieszkowych, pistoletem na strzałki i pudełkiem strzykawek."

/obj/item/storage/backpack/duffelbag/syndie/med/bioterrorbundle/PopulateContents()
	new /obj/item/reagent_containers/spray/chemsprayer/bioterror(src)
	new /obj/item/storage/box/syndie_kit/chemical(src)
	new /obj/item/gun/syringe/syndicate(src)
	new /obj/item/gun/ballistic/automatic/c20r/toy(src)
	new /obj/item/storage/box/syringes(src)
	new /obj/item/ammo_box/foambox/riot(src)
	new /obj/item/grenade/chem_grenade/bioterrorfoam(src)
	if(prob(5))
		new /obj/item/food/pizza/pineapple(src)

/obj/item/storage/backpack/duffelbag/syndie/c4/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/grenade/plastic/c4(src)

/obj/item/storage/backpack/duffelbag/syndie/x4/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/grenade/plastic/x4(src)

/obj/item/storage/backpack/duffelbag/syndie/firestarter
	desc = "Duża torba podróżna z noworosyjskim plecakowym miotaczem ognia, elitarnym hardsuitem, pistoletem Stieczkin APS, minibombą, amunicją i innym sprzętem."

/obj/item/storage/backpack/duffelbag/syndie/firestarter/PopulateContents()
	new /obj/item/clothing/under/syndicate/soviet(src)
	new /obj/item/watertank/op(src)
	new /obj/item/clothing/suit/space/hardsuit/syndi/elite(src)
	new /obj/item/gun/ballistic/automatic/pistol/APS(src)
	new /obj/item/ammo_box/magazine/pistolm9mm(src)
	new /obj/item/ammo_box/magazine/pistolm9mm(src)
	new /obj/item/reagent_containers/food/drinks/bottle/vodka/badminka(src)
	new /obj/item/reagent_containers/hypospray/medipen/stimulants(src)
	new /obj/item/grenade/syndieminibomb(src)

// For ClownOps.
/obj/item/storage/backpack/duffelbag/clown/syndie/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	slowdown = 0
	STR.silent = TRUE

/obj/item/storage/backpack/duffelbag/clown/syndie/PopulateContents()
	new /obj/item/modular_computer/tablet/pda/clown(src)
	new /obj/item/clothing/under/rank/civilian/clown(src)
	new /obj/item/clothing/shoes/clown_shoes(src)
	new /obj/item/clothing/mask/gas/clown_hat(src)
	new /obj/item/bikehorn(src)
	new /obj/item/implanter/sad_trombone(src)
