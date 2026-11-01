/* First aid storage
 * Contains:
 *		First Aid Kits
 * 		Pill Bottles
 *		Dice Pack (in a pill bottle)
 */

/*
 * First Aid Kits
 */

//First Aid kit
/obj/item/storage/firstaid
	name = "apteczka"
	desc = "Apteczka pierwszej pomocy na te poważne kuku."
	icon = 'aquila/icons/obj/medical/medkit.dmi' // AQ EDIT - tgstation medkit sprites
	icon_state = "medkit"
	item_state = "medkit"
	lefthand_file = 'aquila/icons/mob/inhands/equipment/medkit_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/equipment/medkit_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	var/skin_type = MEDBOT_SKIN_DEFAULT
	var/empty = FALSE
	var/damagetype_healed //defines damage type of the medkit. General ones stay null. Used for medibot healing bonuses

/obj/item/storage/firstaid/regular
	icon_state = "medkit" // AQ EDIT
	desc = "Apteczka, za pomocą której wyleczysz typowe obrażenia."

/obj/item/storage/firstaid/regular/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] zaczyna dawać sobie aidsa [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return BRUTELOSS

/obj/item/storage/firstaid/regular/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/suture = 1, // AQ EDIT - tgstation sutures and mesh
		/obj/item/stack/medical/mesh = 1, // AQ EDIT
		/obj/item/reagent_containers/hypospray/medipen = 1,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)


//First MD kit
/obj/item/storage/firstaid/medical
	name = "zestaw medyczny"
	icon_state = "medkit_surgery" // AQ EDIT
	item_state = "medkit-surgical" // AQ EDIT
	desc = "Pojemny zestaw dla lekarzy, pełen zapasów medycznych i podstawowego sprzętu chirurgicznego"
	skin_type = MEDBOT_SKIN_SURGERY

/obj/item/storage/firstaid/medical/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_BULKY //holds the same equipment as a medibelt
	STR.max_items = 12
	STR.max_combined_w_class = 24
	STR.can_hold = typecacheof(list(
		/obj/item/healthanalyzer,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/medspray,
		/obj/item/lighter,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/flashlight/pen,
		/obj/item/extinguisher/mini,
		/obj/item/reagent_containers/hypospray,
		/obj/item/sensor_device,
		/obj/item/radio,
		/obj/item/clothing/gloves/,
		/obj/item/lazarus_injector,
		/obj/item/bikehorn/rubberducky,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath/medical,
		/obj/item/surgical_drapes, //for true paramedics
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/surgicaldrill,
		/obj/item/retractor,
		/obj/item/cautery,
		/obj/item/hemostat,
		/obj/item/blood_filter,
		/obj/item/geiger_counter,
		/obj/item/clothing/neck/stethoscope,
		/obj/item/stamp,
		/obj/item/clothing/glasses,
		/obj/item/wrench/medical,
		/obj/item/clothing/mask/muzzle,
		/obj/item/storage/bag/chemistry,
		/obj/item/storage/bag/bio,
		/obj/item/reagent_containers/blood,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/gun/syringe/syndicate,
		/obj/item/implantcase,
		/obj/item/implant,
		/obj/item/implanter,
		/obj/item/pinpointer/crew,
		/obj/item/holosign_creator/medical
		))

/obj/item/storage/firstaid/medical/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/suture = 1, // AQ EDIT - tgstation sutures and mesh
		/obj/item/stack/medical/mesh = 1, // AQ EDIT
		/obj/item/reagent_containers/hypospray/medipen = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/surgical_drapes = 1,
		/obj/item/scalpel = 1,
		/obj/item/hemostat = 1,
		/obj/item/cautery = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/medical/doctorbag
	name = "torba lekarska"
	icon_state = "medbriefcase" // AQ EDIT
	item_state = "medkit-surgical" // AQ EDIT
	desc = "Elegancki, pojemny zestaw dla lekarzy, pełen zapasów medycznych i podstawowego sprzętu chirurgicznego"
	skin_type = null

//First Aid kit (ancient)
/obj/item/storage/firstaid/ancient
	icon_state = "oldfirstaid" // AQ EDIT
	desc = "Apteczka, za pomocą której wyleczysz typowe obrażenia."
	skin_type = null

/obj/item/storage/firstaid/ancient/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/suture = 2, // AQ EDIT - tgstation sutures and mesh
		/obj/item/stack/medical/mesh = 2) // AQ EDIT
	generate_items_inside(items_inside,src)


//First burn kit
/obj/item/storage/firstaid/fire
	name = "apteczka na oparzenia"
	desc = "Specjalistyczna apteczka na wypadek, gdyby laboratorium toksyn <i>-spontanicznie-</i> spłonęło."
	icon_state = "medkit_burn" // AQ EDIT
	item_state = "medkit-ointment" // AQ EDIT
	damagetype_healed = BURN
	skin_type = MEDBOT_SKIN_BURN

/obj/item/storage/firstaid/fire/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] zaczyna pocierać się [src]! Wygląda na to, że próbuje wzniecić ogień!</span>")
	return FIRELOSS

/obj/item/storage/firstaid/fire/Initialize(mapload)
	. = ..()
	icon_state = "medkit_burn" // AQ EDIT - tgstation medkits have no alternate sprite

/obj/item/storage/firstaid/fire/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/patch/silver_sulf = 4,
		/obj/item/storage/pill_bottle/kelotane = 1,
		/obj/item/reagent_containers/hypospray/medipen = 1,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)


//First toxin kit
/obj/item/storage/firstaid/toxin
	name = "apteczka na zatrucia"
	desc = "Służy do leczenia toksyn we krwi i choroby popromiennej."
	icon_state = "medkit_toxin" // AQ EDIT
	item_state = "medkit-toxin" // AQ EDIT
	damagetype_healed = TOX
	skin_type = MEDBOT_SKIN_TOXIN

/obj/item/storage/firstaid/toxin/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] zaczyna zlizywać farbę ołowiową z [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return TOXLOSS

/obj/item/storage/firstaid/toxin/Initialize(mapload)
	. = ..()
	icon_state = "medkit_toxin" // AQ EDIT - tgstation medkits have no alternate sprite

/obj/item/storage/firstaid/toxin/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/syringe/antitoxin = 3,
		/obj/item/reagent_containers/syringe/calomel = 1,
		/obj/item/reagent_containers/syringe/diphenhydramine = 1,
		/obj/item/storage/pill_bottle/charcoal = 1,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)


//First radiation kit
/obj/item/storage/firstaid/radbgone
	name = "apteczka na promieniowanie"
	desc = "Służy do leczenia niewielkiej ilości toksyn we krwi i ciężkiej choroby popromiennej."
	icon = 'aquila/icons/obj/storage.dmi' // AQ EDIT - no tgstation sprite, keeps the old one
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi' // AQ EDIT
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi' // AQ EDIT
	icon_state = "firstaid-rad"
	item_state = "firstaid-rad"
	skin_type = MEDBOT_SKIN_RADIATION

/obj/item/storage/firstaid/radbgone/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] zaczyna zlizywać farbę ołowiową z [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return TOXLOSS

/obj/item/storage/firstaid/radbgone/PopulateContents()
	if(empty)
		return
	if(prob(50))
		new /obj/item/reagent_containers/pill/mutarad(src)
	if(prob(80))
		new /obj/item/reagent_containers/pill/antirad_plus(src)
	new /obj/item/reagent_containers/syringe/charcoal(src)
	new /obj/item/storage/pill_bottle/charcoal(src)
	new /obj/item/reagent_containers/pill/mutadone(src)
	new /obj/item/reagent_containers/pill/antirad(src)
	new /obj/item/reagent_containers/food/drinks/bottle/vodka(src)
	new /obj/item/healthanalyzer(src)

/obj/item/storage/firstaid/radbgone/Initialize(mapload)
	. = ..()
	icon_state = pick("firstaid-rad","firstaid-radalt")

//First airloss kit
/obj/item/storage/firstaid/o2
	name = "apteczka na niedotlenienie"
	desc = "Pudełko pełne tlenowych dobroci."
	icon_state = "medkit_o2" // AQ EDIT
	item_state = "medkit-o2" // AQ EDIT
	damagetype_healed = OXY
	skin_type = MEDBOT_SKIN_OXY

/obj/item/storage/firstaid/o2/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] zaczyna uderzać się w szyję [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return OXYLOSS

/obj/item/storage/firstaid/o2/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/salbutamol = 2,
		/obj/item/reagent_containers/hypospray/medipen = 2,
		/obj/item/reagent_containers/hypospray/medipen/dexalin = 2,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/o2/Initialize(mapload)
	. = ..()
	icon_state = "medkit_o2" // AQ EDIT - tgstation medkits have no alternate sprite


//First brute kit
/obj/item/storage/firstaid/brute
	name = "apteczka na urazy fizyczne"
	desc = "Apteczka na wypadek, gdyby ktoś cię zdzielił skrzynką narzędziową."
	icon_state = "medkit_brute" // AQ EDIT
	item_state = "medkit-brute" // AQ EDIT
	damagetype_healed = BRUTE
	skin_type = MEDBOT_SKIN_BRUTE

/obj/item/storage/firstaid/brute/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] zaczyna okładać się po głowie [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return BRUTELOSS

/obj/item/storage/firstaid/brute/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/patch/styptic = 4,
		/obj/item/storage/pill_bottle/bicaridine = 1,
		/obj/item/stack/medical/gauze = 2,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/brute/Initialize(mapload)
	. = ..()
	icon_state = "medkit_brute" // AQ EDIT - tgstation medkits have no alternate sprite


//First Advanced kit
/obj/item/storage/firstaid/advanced
	name = "zaawansowana apteczka"
	desc = "Zaawansowany zestaw do radzenia sobie z poważnymi ranami."
	icon_state = "medkit_advanced" // AQ EDIT
	item_state = "medkit-advanced" // AQ EDIT
	custom_premium_price = 600
	skin_type = MEDBOT_SKIN_ADVANCED

/obj/item/storage/firstaid/advanced/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/patch/synthflesh = 3,
		/obj/item/reagent_containers/hypospray/medipen/atropine = 2,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/storage/pill_bottle/penacid = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/advanced/Initialize(mapload)
	. = ..()
	icon_state = "medkit_advanced" // AQ EDIT - tgstation medkits have no alternate sprite

//First Random kit
/obj/item/storage/firstaid/random
	name = "tajemnicza apteczka"
	desc = "Czujesz dziś, że masz szczęście?"
	icon = 'aquila/icons/obj/storage.dmi' // AQ EDIT - no tgstation sprite, keeps the old one
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi' // AQ EDIT
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi' // AQ EDIT
	icon_state = "firstaid-mystery"
	item_state = "firstaid-mystery"
	skin_type = NONE

/obj/item/storage/firstaid/random/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/firstaid/random/PopulateContents()
	if(empty)
		return
	var/supplies = list(
		/obj/item/stack/medical/gauze,
		/obj/item/stack/medical/suture, // AQ EDIT - tgstation sutures and mesh
		/obj/item/stack/medical/mesh, // AQ EDIT
		/obj/item/reagent_containers/hypospray/medipen,
		/obj/item/surgical_drapes,
		/obj/item/scalpel,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/reagent_containers/pill/patch/synthflesh,
		/obj/item/reagent_containers/hypospray/medipen/atropine,
		/obj/item/storage/pill_bottle/penacid,
		/obj/item/reagent_containers/pill/patch/styptic,
		/obj/item/storage/pill_bottle/bicaridine,
		/obj/item/reagent_containers/pill/salbutamol,
		/obj/item/reagent_containers/hypospray/medipen/dexalin,
		/obj/item/reagent_containers/pill/mutadone,
		/obj/item/reagent_containers/pill/antirad,
		/obj/item/reagent_containers/syringe/antitoxin,
		/obj/item/reagent_containers/syringe/calomel,
		/obj/item/reagent_containers/syringe/diphenhydramine,
		/obj/item/storage/pill_bottle/charcoal,
		/obj/item/reagent_containers/pill/patch/silver_sulf,
		/obj/item/storage/pill_bottle/kelotane)
	new /obj/item/healthanalyzer(src)
	for(var/i in 1 to 6)
		var/selected_type = pick(supplies)
		new selected_type(src)

//First Tactical kit
/obj/item/storage/firstaid/tactical
	name = "bojowa apteczka"
	desc = "Mam nadzieję, że masz ubezpieczenie."
	icon_state = "medkit_tactical" // AQ EDIT
	item_state = "medkit-tactical" // AQ EDIT
	skin_type = MEDBOT_SKIN_SYNDI

/obj/item/storage/firstaid/tactical/Initialize(mapload)
	. = ..()
	icon_state = "medkit_tactical" // AQ EDIT - tgstation medkits have no alternate sprite

/obj/item/storage/firstaid/tactical/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/firstaid/tactical/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/defibrillator/compact/combat/loaded = 1,
		/obj/item/reagent_containers/hypospray/combat = 1,
		/obj/item/reagent_containers/pill/patch/styptic = 2,
		/obj/item/reagent_containers/pill/patch/silver_sulf = 2,
		/obj/item/clothing/glasses/hud/health/night = 1)
	generate_items_inside(items_inside,src)

//medibot assembly
/obj/item/storage/firstaid/attackby(obj/item/bodypart/S, mob/user, params)
	if((!istype(S, /obj/item/bodypart/l_arm/robot)) && (!istype(S, /obj/item/bodypart/r_arm/robot)))
		return ..()

	//Making a medibot!
	if(contents.len >= 1)
		to_chat(user, "<span class='warning'>Najpierw musisz opróżnić [src]!</span>")
		return

	if(!src.skin_type)
		to_chat(user, "<span class='warning'>Z [src] nie da się zrobić medibota!</span>")
		return

	var/obj/item/bot_assembly/medbot/A = new
	A.skin = src.skin_type

	user.put_in_hands(A)
	to_chat(user, "<span class='notice'>Dodajesz [S] do [src].</span>")
	A.robot_arm = S.type
	A.firstaid = type
	qdel(S)
	qdel(src)

/*
 * Pill Bottles
 */

/obj/item/storage/pill_bottle
	name = "pojemnik na pigułki"
	desc = "Hermetyczny pojemnik na leki."
	icon_state = "pill_canister_0"
	icon = 'icons/obj/medicine_containers.dmi'
	item_state = "contsolid"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/pill_variance = 100 //probability pill_bottle has a different icon state. Put at 0 for no variance
	var/pill_type = "pill_canister_"

/obj/item/storage/pill_bottle/Initialize(mapload)
	. = ..()
	if(prob(pill_variance))
		icon_state = "[pill_type][rand(0,6)]"

/obj/item/storage/pill_bottle/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.allow_quick_gather = TRUE
	STR.click_gather = TRUE
	STR.can_hold = typecacheof(list(/obj/item/reagent_containers/pill, /obj/item/dice))

/obj/item/storage/pill_bottle/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] próbuje zdjąć zakrętkę z [src]! Wygląda na to, że próbuje popełnić samobójstwo!</span>")
	return (TOXLOSS)

/obj/item/storage/pill_bottle/charcoal
	name = "pojemnik z pigułkami: Węgiel aktywowany"
	desc = "Zawiera pigułki przeciw toksynom."

/obj/item/storage/pill_bottle/charcoal/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/charcoal(src)

/obj/item/storage/pill_bottle/bicaridine
	name = "pojemnik z pigułkami: Bikarydyna"
	desc = "Zawiera pigułki do leczenia drobnych i średnich obrażeń fizycznych."

/obj/item/storage/pill_bottle/bicaridine/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/bicaridine(src)

/obj/item/storage/pill_bottle/kelotane
	name = "pojemnik z pigułkami: Kelotan"
	desc = "Zawiera pigułki do leczenia drobnych i średnich oparzeń."

/obj/item/storage/pill_bottle/kelotane/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/kelotane(src)

/obj/item/storage/pill_bottle/antirad
	name = "pojemnik z pigułkami przeciw promieniowaniu"
	desc = "Zawiera pigułki do leczenia skutków słabego napromieniowania."

/obj/item/storage/pill_bottle/antirad/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/antirad(src)

/obj/item/storage/pill_bottle/epinephrine
	name = "pojemnik z pigułkami: Epinefryna"
	desc = "Zawiera pigułki do stabilizowania pacjentów."

/obj/item/storage/pill_bottle/epinephrine/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/epinephrine(src)

/obj/item/storage/pill_bottle/mutadone
	name = "pojemnik z pigułkami: Mutadon"
	desc = "Zawiera pigułki do leczenia nieprawidłowości genetycznych."

/obj/item/storage/pill_bottle/mutadone/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/mutadone(src)

/obj/item/storage/pill_bottle/mannitol
	name = "pojemnik z pigułkami: Mannitol"
	desc = "Zawiera pigułki do leczenia uszkodzeń mózgu."

/obj/item/storage/pill_bottle/mannitol/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/mannitol(src)

/obj/item/storage/pill_bottle/mannitol/braintumor //For the brain tumor quirk
	desc = "Hojnie zapewnione przez twoje ubezpieczenie zdrowotne Nanotrasen na ten uciążliwy guz w twoim mózgu."

/obj/item/storage/pill_bottle/mannitol/braintumor/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/mannitol/braintumor(src)

/obj/item/storage/pill_bottle/stimulant
	name = "pojemnik z pigułkami pobudzającymi"
	desc = "Gwarantowany dodatkowy zastrzyk energii podczas długiej zmiany!"

/obj/item/storage/pill_bottle/stimulant/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/stimulant(src)

/obj/item/storage/pill_bottle/mining
	name = "pojemnik z plastrami"
	desc = "Zawiera plastry do leczenia obrażeń fizycznych i oparzeń."

/obj/item/storage/pill_bottle/mining/PopulateContents()
	new /obj/item/reagent_containers/pill/patch/silver_sulf(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/pill/patch/styptic(src)

/obj/item/storage/pill_bottle/zoom
	name = "podejrzany pojemnik na pigułki"
	desc = "Etykieta jest dość stara i prawie nieczytelna, rozpoznajesz kilka związków chemicznych."

/obj/item/storage/pill_bottle/zoom/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/zoom(src)

/obj/item/storage/pill_bottle/happy
	name = "podejrzany pojemnik na pigułki"
	desc = "Na wieczku jest buźka."

/obj/item/storage/pill_bottle/happy/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/happy(src)

/obj/item/storage/pill_bottle/lsd
	name = "podejrzany pojemnik na pigułki"
	desc = "Jest na nim prymitywny rysunek, który może przedstawiać grzyba albo zdeformowany księżyc."

/obj/item/storage/pill_bottle/lsd/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/lsd(src)

/obj/item/storage/pill_bottle/aranesp
	name = "podejrzany pojemnik na pigułki"
	desc = "Na etykiecie ktoś w pośpiechu nabazgrał czarnym markerem „pierdolić disablery”."

/obj/item/storage/pill_bottle/aranesp/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/aranesp(src)

/obj/item/storage/pill_bottle/psicodine
	name = "pojemnik z pigułkami: Psykodyna"
	desc = "Zawiera pigułki do leczenia stresu psychicznego i traum."

/obj/item/storage/pill_bottle/psicodine/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/psicodine(src)

/obj/item/storage/pill_bottle/happiness
	name = "pojemnik z pigułkami szczęścia"
	desc = "Etykiety dawno nie ma, w jej miejscu ktoś napisał markerem „H”."

/obj/item/storage/pill_bottle/happiness/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/happiness(src)

/obj/item/storage/pill_bottle/penacid
	name = "pojemnik z pigułkami: Kwas pentetowy"
	desc = "Zawiera pigułki usuwające promieniowanie i toksyny."

/obj/item/storage/pill_bottle/penacid/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/pill/penacid(src)


/obj/item/storage/pill_bottle/neurine
	name = "pojemnik z pigułkami: Neuryna"
	desc = "Zawiera pigułki do leczenia lekkich traum psychicznych."

/obj/item/storage/pill_bottle/neurine/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/neurine(src)

/obj/item/storage/pill_bottle/floorpill
	name = "pojemnik z pigułkami z podłogi"
	desc = "Stary pojemnik na pigułki. Pachnie stęchlizną."

/obj/item/storage/pill_bottle/floorpill/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/pill/P = locate() in src
	name = "pojemnik z pigułkami: [P.name]"

/obj/item/storage/pill_bottle/floorpill/PopulateContents()
	for(var/i in 1 to rand(1,7))
		new /obj/item/reagent_containers/pill/floorpill(src)

/obj/item/storage/pill_bottle/floorpill/full/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/floorpill(src)
