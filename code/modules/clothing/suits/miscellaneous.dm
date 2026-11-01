/*
 * Contains:
 *		Lasertag
 *		Costume
 *		Misc
 */

/*
 * Lasertag
 */
/obj/item/clothing/suit/bluetag
	name = "niebieski pancerz do laser taga"
	desc = "Plastikowy pancerz. Ma czujniki reagujące na czerwone światło." //Lasers are concentrated light
	icon_state = "bluetag"
	item_state = "bluetag"
	blood_overlay_type = "armor"
	body_parts_covered = CHEST
	allowed = list (/obj/item/gun/energy/laser/bluetag)
	resistance_flags = NONE

/obj/item/clothing/suit/redtag
	name = "czerwony pancerz do laser taga"
	desc = "Plastikowy pancerz. Ma czujniki reagujące na niebieskie światło."
	icon_state = "redtag"
	item_state = "redtag"
	blood_overlay_type = "armor"
	body_parts_covered = CHEST
	allowed = list (/obj/item/gun/energy/laser/redtag)
	resistance_flags = NONE

// Aristocrat Coats

/obj/item/clothing/suit/aristo_orange
	name = "pomarańczowy płaszcz arystokraty"
	desc = "Wytworny płaszcz z jedwabiu. Ten jest pomarańczowy."
	icon_state = "aristo_orange"
	item_state = "aristo_orange"

/obj/item/clothing/suit/aristo_red
	name = "czerwony płaszcz arystokraty"
	desc = "Wytworny płaszcz z jedwabiu. Ten jest czerwony."
	icon_state = "aristo_red"
	item_state = "aristo_red"

/obj/item/clothing/suit/aristo_brown
	name = "brązowy płaszcz arystokraty"
	desc = "Wytworny płaszcz z jedwabiu. Ten jest brązowy."
	icon_state = "aristo_brown"
	item_state = "aristo_brown"

/obj/item/clothing/suit/aristo_blue
	name = "niebieski płaszcz arystokraty"
	desc = "Wytworny płaszcz z jedwabiu. Ten jest niebieski."
	icon_state = "aristo_blue"
	item_state = "aristo_blue"

/*
 * Costume
 */
/obj/item/clothing/suit/hooded/flashsuit
	name = "błyskotliwe przebranie"
	desc = "A czego się spodziewałeś?"
	icon_state = "flashsuit"
	item_state = "armor"
	body_parts_covered = CHEST|GROIN
	hoodtype = /obj/item/clothing/head/hooded/flashsuit

/obj/item/clothing/suit/hooded/hastur
	name = "\improper szata Hastura"
	desc = "Szaty, których nie powinien nosić człowiek."
	icon_state = "hastur"
	item_state = "hastur"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	hoodtype = /obj/item/clothing/head/hooded/hasturhood

/obj/item/clothing/head/hooded/flashsuit
	name = "przycisk flasha"
	desc = "Nauczysz się bać flasha."
	icon_state = "flashsuit"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR|HIDEEARS|HIDEFACIALHAIR|HIDEFACE|HIDEMASK|HIDESNOUT

/obj/item/clothing/suit/pirate
	name = "płaszcz piracki"
	desc = "Jarr."
	icon_state = "pirate"
	item_state = "pirate"
	allowed = list(/obj/item/melee/transforming/energy/sword/pirate, /obj/item/clothing/glasses/eyepatch, /obj/item/reagent_containers/food/drinks/bottle/rum)

/obj/item/clothing/suit/pirate/captain
	name = "płaszcz kapitana piratów"
	desc = "Jarr."
	icon_state = "hgpirate"
	item_state = "hgpirate"


/obj/item/clothing/suit/cyborg_suit
	name = "strój cyborga"
	desc = "Strój do przebrania za cyborga."
	icon_state = "death"
	item_state = "death"
	flags_1 = CONDUCT_1
	fire_resist = T0C+5200
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/justice
	name = "strój sprawiedliwości"
	desc = "wygląda to dość śmiesznie" //Needs no fixing
	icon_state = "justice"
	item_state = "justice"
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/judgerobe
	name = "toga sędziowska"
	desc = "Ta toga budzi respekt."
	icon_state = "judge"
	item_state = "judge"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	allowed = list(/obj/item/storage/fancy/cigarettes, /obj/item/stack/spacecash)
	flags_inv = HIDEJUMPSUIT


/obj/item/clothing/suit/apron/overalls
	name = "ogrodniczki"
	desc = "Dżinsowe ogrodniczki."
	icon_state = "overalls"
	item_state = "overalls"
	body_parts_covered = CHEST|GROIN|LEGS

/obj/item/clothing/suit/apron/purple_bartender
	name = "fioletowy fartuch barmana"
	desc = "Wytworny fioletowy fartuch dla osoby z klasą."
	icon_state = "purplebartenderapron"
	item_state = "purplebartenderapron"
	body_parts_covered = CHEST|GROIN|LEGS

/obj/item/clothing/suit/syndicatefake
	name = "replika czarno-czerwonego skafandra kosmicznego"
	icon_state = "syndicate-black-red"
	item_state = "syndicate-black-red"
	desc = "Plastikowa replika skafandra kosmicznego Syndykatu. Wyglądasz w niej zupełnie jak prawdziwy morderczy agent Syndykatu! To zabawka, nie nadaje się do użytku w kosmosie!"
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	resistance_flags = NONE

/obj/item/clothing/suit/hastur
	name = "\improper szata Hastura"
	desc = "Szaty, których nie powinien nosić człowiek."
	icon_state = "hastur"
	item_state = "hastur"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/imperium_monk
	name = "\improper strój mnicha Imperium"
	desc = "Czy TY zabiłeś dziś ksenomorfa?"
	icon_state = "imperium_monk"
	item_state = "imperium_monk"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	flags_inv = HIDESHOES|HIDEJUMPSUIT
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/food/drinks/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen)


/obj/item/clothing/suit/chickensuit
	name = "strój kurczaka"
	desc = "Strój uszyty dawno temu przez starożytne imperium KFC."
	icon_state = "chickensuit"
	item_state = "chickensuit"
	body_parts_covered = CHEST|ARMS|GROIN|LEGS|FEET
	flags_inv = HIDESHOES|HIDEJUMPSUIT


/obj/item/clothing/suit/monkeysuit
	name = "strój małpy"
	desc = "Strój, który wygląda jak naczelny."
	icon_state = "monkeysuit"
	item_state = "monkeysuit"
	body_parts_covered = CHEST|ARMS|GROIN|LEGS|FEET|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT

/obj/item/clothing/suit/toggle/owlwings
	name = "sowia peleryna"
	desc = "Miękka brązowa peleryna z syntetycznych piór. Miła w dotyku, stylowa, a 2-metrowa rozpiętość skrzydeł doprowadzi panie do szaleństwa."
	icon_state = "owl_wings"
	item_state = "owl_wings"
	togglename = "skrzydła"
	body_parts_covered = ARMS|CHEST
	actions_types = list(/datum/action/item_action/toggle_wings)

/obj/item/clothing/suit/toggle/owlwings/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_vest_allowed

/obj/item/clothing/suit/toggle/owlwings/griffinwings
	name = "gryfia peleryna"
	desc = "Pluszowa biała peleryna z syntetycznych piór. Miła w dotyku, stylowa, a 2-metrowa rozpiętość skrzydeł doprowadzi twoich jeńców do szaleństwa."
	icon_state = "griffin_wings"
	item_state = "griffin_wings"

/obj/item/clothing/suit/cardborg
	name = "strój kartonborga"
	desc = "Zwykłe kartonowe pudło z otworami wyciętymi po bokach."
	icon_state = "cardborg"
	item_state = "cardborg"
	body_parts_covered = CHEST|GROIN
	flags_inv = HIDEJUMPSUIT
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/suit/cardborg/equipped(mob/living/user, slot)
	..()
	if(slot == ITEM_SLOT_OCLOTHING)
		disguise(user)

/obj/item/clothing/suit/cardborg/dropped(mob/living/user)
	..()
	user.remove_alt_appearance("standard_borg_disguise")

/obj/item/clothing/suit/cardborg/proc/disguise(mob/living/carbon/human/H, obj/item/clothing/head/cardborg/borghead)
	if(istype(H))
		if(!borghead)
			borghead = H.head
		if(istype(borghead, /obj/item/clothing/head/cardborg)) //why is this done this way? because equipped() is called BEFORE THE ITEM IS IN THE SLOT WHYYYY
			var/image/I = image(icon = 'icons/mob/robots.dmi' , icon_state = "robot", loc = H)
			I.override = 1
			I.add_overlay(mutable_appearance('icons/mob/robots.dmi', "robot_e")) //gotta look realistic
			add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "standard_borg_disguise", I) //you look like a robot to robots! (including yourself because you're totally a robot)


/obj/item/clothing/suit/snowman
	name = "strój bałwana"
	desc = "Dwie białe kule pokryte białym brokatem. Taki to czas."
	icon_state = "snowman"
	item_state = "snowman"
	body_parts_covered = CHEST|GROIN
	flags_inv = HIDEJUMPSUIT

/obj/item/clothing/suit/poncho
	name = "ponczo"
	desc = "Klasyczne, wcale nie rasistowskie ponczo."
	icon_state = "classicponcho"
	item_state = "classicponcho"

/obj/item/clothing/suit/poncho/green
	name = "zielone ponczo"
	desc = "Klasyczne, wcale nie rasistowskie ponczo. To jest zielone."
	icon_state = "greenponcho"
	item_state = "greenponcho"

/obj/item/clothing/suit/poncho/red
	name = "czerwone ponczo"
	desc = "Klasyczne, wcale nie rasistowskie ponczo. To jest czerwone."
	icon_state = "redponcho"
	item_state = "redponcho"

/obj/item/clothing/suit/poncho/ponchoshame
	name = "ponczo hańby"
	desc = "Skazany na życie z hańbą udawanego Meksykanina, zrastasz się ze swoim ponczem. Dosłownie."
	icon_state = "ponchoshame"
	item_state = "ponchoshame"

/obj/item/clothing/suit/poncho/ponchoshame/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, SHAMEBRERO_TRAIT)

/obj/item/clothing/suit/whitedress
	name = "biała sukienka"
	desc = "Wytworna biała sukienka."
	icon_state = "white_dress"
	item_state = "w_suit"
	body_parts_covered = CHEST|GROIN|LEGS|FEET
	flags_inv = HIDEJUMPSUIT|HIDESHOES

/obj/item/clothing/suit/hooded/carp_costume
	name = "przebranie karpia"
	desc = "Przebranie z „syntetycznych” łusek karpia. Śmierdzi."
	icon_state = "carp_casual"
	item_state = "labcoat"
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT	//Space carp like space, so you should too
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/pneumatic_cannon/speargun)
	hoodtype = /obj/item/clothing/head/hooded/carp_hood

/obj/item/clothing/head/hooded/carp_hood
	name = "kaptur karpia"
	desc = "Kaptur przyczepiony do przebrania karpia."
	icon_state = "carp_casual"
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEHAIR|HIDEEARS

/obj/item/clothing/head/hooded/hasturhood
	name = "kaptur Hastura"
	desc = "Jest <i>niewypowiedzianie</i> stylowy."
	icon_state = "hasturhood"
	body_parts_covered = HEAD
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/hooded/carp_hood/equipped(mob/living/carbon/human/user, slot)
	..()
	if (slot == ITEM_SLOT_HEAD)
		user.faction |= "carp"

/obj/item/clothing/head/hooded/carp_hood/dropped(mob/living/carbon/human/user)
	..()
	if (user.head == src)
		user.faction -= "carp"

/obj/item/clothing/suit/hooded/ian_costume	//It's Ian, rub his bell- oh god what happened to his inside parts?
	name = "przebranie corgi"
	desc = "Przebranie wygląda, jakby ktoś zrobił człekokształtnego corgiego. Drapania po brzuchu nie gwarantuje."
	icon_state = "ian"
	item_state = "labcoat"
	body_parts_covered = CHEST|GROIN|ARMS
	//cold_protection = CHEST|GROIN|ARMS
	//min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	allowed = list()
	hoodtype = /obj/item/clothing/head/hooded/ian_hood
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/head/hooded/ian_hood
	name = "kaptur corgi"
	desc = "Kaptur wyglądający zupełnie jak głowa corgiego. Psich ciasteczek nie gwarantuje."
	icon_state = "ian"
	body_parts_covered = HEAD
	//cold_protection = HEAD
	//min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEHAIR|HIDEEARS

/obj/item/clothing/suit/hooded/bee_costume // It's Hip!
	name = "przebranie pszczoły"
	desc = "Bądź prawdziwą królową!"
	icon_state = "bee"
	item_state = "labcoat"
	body_parts_covered = CHEST|GROIN|ARMS
	clothing_flags = THICKMATERIAL
	hoodtype = /obj/item/clothing/head/hooded/bee_hood

/obj/item/clothing/head/hooded/bee_hood
	name = "kaptur pszczoły"
	desc = "Kaptur przyczepiony do przebrania pszczoły."
	icon_state = "bee"
	body_parts_covered = HEAD
	clothing_flags = THICKMATERIAL | SNUG_FIT
	flags_inv = HIDEHAIR|HIDEEARS
	dynamic_hair_suffix = ""

/obj/item/clothing/suit/hooded/bee_costume/syndie
	name = "przebranie BLF"
	armor = list("melee" = 30, "bullet" = 50, "laser" = 20,"energy" = 40, "bomb" = 0, "bio" = 60, "rad" = 0, "fire" = 0, "acid" = 50, "stamina" = 30) //NSV13
	hoodtype = /obj/item/clothing/head/hooded/bee_hood/syndie

/obj/item/clothing/head/hooded/bee_hood/syndie
	armor = list("melee" = 30, "bullet" = 40, "laser" = 20,"energy" = 40, "bomb" = 0, "bio" = 60, "rad" = 0, "fire" = 0, "acid" = 50, "stamina" = 30) //NSV13

/obj/item/clothing/suit/hooded/bloated_human	//OH MY GOD WHAT HAVE YOU DONE!?!?!?
	name = "strój z rozdętego człowieka"
	desc = "Potwornie rozdęty strój uszyty z ludzkich skór."
	icon_state = "lingspacesuit"
	item_state = "labcoat"
	body_parts_covered = CHEST|GROIN|ARMS
	allowed = list()
	actions_types = list(/datum/action/item_action/toggle_human_head)
	hoodtype = /obj/item/clothing/head/hooded/human_head


/obj/item/clothing/head/hooded/human_head
	name = "rozdęta ludzka głowa"
	desc = "Potwornie rozdęta i niedopasowana ludzka głowa."
	icon_state = "lingspacehelmet"
	body_parts_covered = HEAD
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/suit/security/officer/russian
	name = "\improper kurtka rosyjskiego oficera"
	desc = "Kurtka na te szczególne okazje, kiedy rosyjski oficer nie musi nosić pancerza."
	icon_state = "officertanjacket"
	item_state = "officertanjacket"
	body_parts_covered = CHEST|ARMS

/////////////////
//DONATOR ITEMS//
/////////////////

/obj/item/clothing/suit/delinquent
	name = "kurtka chuligana"
	desc = "Yare yare daze."
	icon_state = "jocoat"

/obj/item/clothing/suit/madsci
	name = "fartuch laboratoryjny szalonego naukowca"
	desc = "El psy congroo."
	icon_state = "madsci"

/obj/item/clothing/suit/hooded/renault_costume
	name = "przebranie Renault"
	desc = "Najsłodsza piżama, jaką kiedykolwiek widziałeś."
	icon_state = "renault_suit"
	hoodtype = /obj/item/clothing/head/hooded/renault_hood

/obj/item/clothing/head/hooded/renault_hood
	name = "bluza z kapturem Renault"
	desc = "Urocza bluza z kapturem, która trochę przypomina Renault."
	icon_state = "renault_hoodie"
	flags_inv = HIDEEARS

/obj/item/clothing/suit/retro_jacket
	name = "kurtka retro"
	desc = "Lubisz krzywdzić innych ludzi?"
	icon_state = "retro_jacket"

/*
 * Misc
 */

/obj/item/clothing/suit/straight_jacket
	name = "kaftan bezpieczeństwa"
	desc = "Strój, który całkowicie unieruchamia noszącego. Produkcja: Antyphun Corp." //Straight jacket is antifun
	icon_state = "straight_jacket"
	item_state = "straight_jacket"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	equip_delay_self = 50
	strip_delay = 60
	breakouttime = 3000
	pocket_storage_component_path = FALSE

/obj/item/clothing/suit/ianshirt
	name = "znoszona koszulka"
	desc = "Znoszona, zaskakująco wygodna koszulka z podobizną Iana. Nie powiesz, że czujesz się w niej jak w czyichś objęciach, ale niewiele brakuje. Dobra do spania."
	icon_state = "ianshirt"
	item_state = "ianshirt"

/obj/item/clothing/suit/nerdshirt
	name = "koszulka gracza"
	desc = "Workowata koszulka z Phanikiem Łasicą, postacią ze starej gry. Po co ktoś miałby to nosić?"
	icon_state = "nerdshirt"
	item_state = "nerdshirt"

/obj/item/clothing/suit/vapeshirt //wearing this is asking to get beat.
	name = "koszulka Vape Naysh"
	desc = "Tania biała koszulka z wielkim, tandetnym „VN” z przodu. Po co nosić to na serio?"
	icon_state = "vapeshirt"
	item_state = "vapeshirt"

/obj/item/clothing/suit/striped_sweater
	name = "sweter w paski"
	desc = "Kogoś ci przypomina, ale nie możesz sobie przypomnieć kogo..."
	icon_state = "waldo_shirt"
	item_state = "waldo_shirt"

/obj/item/clothing/suit/jacket
	name = "kurtka pilotka"
	desc = "Okulary pilotki nie wchodzą w zestaw."
	icon_state = "bomberjacket"
	item_state = "brownjsuit"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/radio)
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT

/obj/item/clothing/suit/jacket/leather
	name = "skórzana kurtka"
	desc = "Pompadour nie wchodzi w zestaw."
	icon_state = "leatherjacket"
	item_state = "hostrench"
	resistance_flags = NONE
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/gun/ballistic/automatic/pistol, /obj/item/gun/ballistic/revolver, /obj/item/gun/ballistic/revolver/detective, /obj/item/radio)

/obj/item/clothing/suit/jacket/leather/overcoat
	name = "skórzany płaszcz"
	desc = "Cholernie dobry płaszcz."
	icon_state = "leathercoat"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	cold_protection = CHEST|GROIN|ARMS|LEGS

/obj/item/clothing/suit/jacket/puffer
	name = "kurtka puchowa"
	desc = "Gruba kurtka z gumowaną, wodoodporną powłoką."
	icon_state = "pufferjacket"
	item_state = "hostrench"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 50, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0)

/obj/item/clothing/suit/jacket/puffer/vest
	name = "kamizelka puchowa"
	desc = "Gruba kamizelka z gumowaną, wodoodporną powłoką."
	icon_state = "puffervest"
	item_state = "armor"
	body_parts_covered = CHEST|GROIN
	cold_protection = CHEST|GROIN
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 30, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0)

/obj/item/clothing/suit/jacket/miljacket
	name = "kurtka wojskowa"
	desc = "Płócienna kurtka w stylu klasycznego amerykańskiego munduru. Solidna, a zarazem wygodna."
	icon_state = "militaryjacket"
	item_state = "militaryjacket"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/gun/ballistic/automatic/pistol, /obj/item/gun/ballistic/revolver, /obj/item/radio)

/obj/item/clothing/suit/jacket/letterman
	name = "kurtka uczelniana"
	desc = "Klasyczna brązowa kurtka uczelniana. Wygląda na gorącą i ciężką."
	icon_state = "letterman"
	item_state = "letterman"

/obj/item/clothing/suit/jacket/letterman_red
	name = "czerwona kurtka uczelniana"
	desc = "Kurtka uczelniana w odlotowym czerwonym kolorze. Radykalnie."
	icon_state = "letterman_red"
	item_state = "letterman_red"

/obj/item/clothing/suit/jacket/letterman_syndie
	name = "krwistoczerwona kurtka uczelniana"
	desc = "Dziwne, ta kurtka ma chyba na plecach duże S..."
	icon_state = "letterman_s"
	item_state = "letterman_s"

/obj/item/clothing/suit/jacket/letterman_nanotrasen
	name = "niebieska kurtka uczelniana"
	desc = "Niebieska kurtka uczelniana z dumnym N Nanotrasen na plecach. Metka mówi, że uszyto ją w Kosmicznych Chinach."
	icon_state = "letterman_n"
	item_state = "letterman_n"

/obj/item/clothing/suit/dracula
	name = "płaszcz Draculi"
	desc = "Wygląda, jakby pochodził z planu bardzo starego filmu."
	icon_state = "draculacoat"
	item_state = "draculacoat"

/obj/item/clothing/suit/drfreeze_coat
	name = "fartuch laboratoryjny doktora Freeze'a"
	desc = "Fartuch laboratoryjny przesiąknięty mocą lodu i mrozu."
	icon_state = "drfreeze_coat"
	item_state = "drfreeze_coat"

/obj/item/clothing/suit/gothcoat
	name = "gotycki płaszcz"
	desc = "Idealny dla tych, którzy lubią czaić się w kącie baru."
	icon_state = "gothcoat"
	item_state = "gothcoat"

/obj/item/clothing/suit/xenos
	name = "strój ksenomorfa"
	desc = "Strój uszyty z chitynowej skóry obcego."
	icon_state = "xenos"
	item_state = "xenos_helm"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	allowed = list(/obj/item/clothing/mask/facehugger/toy)

/obj/item/clothing/suit/nemes
	name = "tunika faraona"
	desc = "Wystawny kosmiczny grobowiec nie wchodzi w zestaw."
	icon_state = "pharoah"
	icon_state = "pharoah"
	body_parts_covered = CHEST|GROIN

/obj/item/clothing/suit/caution
	name = "znak „mokra podłoga”"
	desc = "Uwaga! Mokra podłoga!"
	icon_state = "caution"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	custom_price = 10
	force = 1
	throwforce = 3
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	body_parts_covered = CHEST|GROIN
	attack_verb = list("ostrzega", "upomina", "rozbija")
	armor = list("melee" = 5, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0)



// WINTER COATS

/obj/item/clothing/suit/hooded/wintercoat
	name = "kurtka zimowa"
	desc = "Ciężka kurtka z „syntetycznych” zwierzęcych futer."
	icon_state = "coatwinter"
	item_state = "coatwinter"
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)

/obj/item/clothing/head/hooded/winterhood
	name = "kaptur kurtki zimowej"
	desc = "Kaptur przyczepiony do ciężkiej kurtki zimowej."
	icon_state = "winterhood"
	body_parts_covered = HEAD
	cold_protection = HEAD
	min_cold_protection_temperature = FIRE_SUIT_MIN_TEMP_PROTECT
	flags_inv = HIDEHAIR|HIDEEARS

/obj/item/clothing/suit/hooded/wintercoat/captain
	name = "kurtka zimowa kapitana"
	icon_state = "coatcaptain"
	item_state = "coatcaptain"
	armor = list("melee" = 30, "bullet" = 50, "laser" = 20, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "stamina" = 30) //NSV13
	hoodtype = /obj/item/clothing/head/hooded/winterhood/captain

/obj/item/clothing/suit/hooded/wintercoat/captain/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/captain
	icon_state = "winterhood_captain"

/obj/item/clothing/suit/hooded/wintercoat/security
	name = "policyjna kurtka zimowa"
	icon_state = "coatsecurity"
	item_state = "coatsecurity"
	armor = list("melee" = 35, "bullet" = 45, "laser" = 10, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 45, "stamina" = 30) //NSV13
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security

/obj/item/clothing/suit/hooded/wintercoat/security/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/security
	icon_state = "winterhood_security"

/obj/item/clothing/suit/hooded/wintercoat/medical
	name = "medyczna kurtka zimowa"
	icon_state = "coatmedical"
	item_state = "coatmedical"
	allowed = list(/obj/item/analyzer, /obj/item/sensor_device, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/healthanalyzer, /obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/reagent_containers/pill, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/melee/classic_baton/police/telescopic, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 50, "rad" = 0, "fire" = 0, "acid" = 45, "stamina" = 0)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical

/obj/item/clothing/head/hooded/winterhood/medical
	icon_state = "winterhood_medical"

/obj/item/clothing/suit/hooded/wintercoat/science
	name = "kurtka zimowa nauki"
	icon_state = "coatscience"
	item_state = "coatscience"
	allowed = list(/obj/item/analyzer, /obj/item/stack/medical, /obj/item/dnainjector, /obj/item/reagent_containers/dropper, /obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray, /obj/item/healthanalyzer, /obj/item/flashlight/pen, /obj/item/reagent_containers/glass/bottle, /obj/item/reagent_containers/glass/beaker, /obj/item/reagent_containers/pill, /obj/item/storage/pill_bottle, /obj/item/paper, /obj/item/melee/classic_baton/police/telescopic, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science

/obj/item/clothing/head/hooded/winterhood/science
	icon_state = "winterhood_science"

/obj/item/clothing/suit/hooded/wintercoat/engineering
	name = "inżynieryjna kurtka zimowa"
	icon_state = "coatengineer"
	item_state = "coatengineer"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 20, "fire" = 30, "acid" = 45, "stamina" = 0)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/t_scanner, /obj/item/construction/rcd, /obj/item/pipe_dispenser, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering

/obj/item/clothing/head/hooded/winterhood/engineering
	icon_state = "winterhood_engineer"

/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos
	name = "kurtka zimowa atmosferyki"
	icon_state = "coatatmos"
	item_state = "coatatmos"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/atmos

/obj/item/clothing/head/hooded/winterhood/engineering/atmos
	icon_state = "winterhood_atmos"

/obj/item/clothing/suit/hooded/wintercoat/hydro
	name = "kurtka zimowa botaniki"
	icon_state = "coathydro"
	item_state = "coathydro"
	allowed = list(/obj/item/reagent_containers/spray/plantbgone, /obj/item/plant_scanner, /obj/item/plant_seeds, /obj/item/reagent_containers/glass/bottle, /obj/item/cultivator, /obj/item/reagent_containers/spray/pestspray, /obj/item/hatchet, /obj/item/storage/bag/plants, /obj/item/toy, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/hydro

/obj/item/clothing/head/hooded/winterhood/hydro
	icon_state = "winterhood_hydro"

/obj/item/clothing/suit/hooded/wintercoat/cargo
	name = "kurtka zimowa zaopatrzenia"
	icon_state = "coatcargo"
	item_state = "coatcargo"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/cargo

/obj/item/clothing/head/hooded/winterhood/cargo
	icon_state = "winterhood_cargo"

/obj/item/clothing/suit/hooded/wintercoat/miner
	name = "górnicza kurtka zimowa"
	icon_state = "coatminer"
	item_state = "coatminer"
	allowed = list(/obj/item/pickaxe, /obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/toy, /obj/item/storage/fancy/cigarettes, /obj/item/lighter)
	armor = list("melee" = 10, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0)
	hoodtype = /obj/item/clothing/head/hooded/winterhood/miner

/obj/item/clothing/head/hooded/winterhood/miner
	icon_state = "winterhood_miner"

//Old winter coats

/obj/item/clothing/suit/hooded/wintercoat/old
	name = "nostalgiczna kurtka zimowa"
	desc = "Mocno znoszona ciężka kurtka z „syntetycznych” zwierzęcych futer."
	icon_state = "old_coatwinter"

/obj/item/clothing/head/hooded/winterhood/old
	name = "kaptur kurtki zimowej"
	desc = "Stary kaptur przyczepiony do mocno znoszonej ciężkiej kurtki zimowej."
	icon_state = "old_winterhood"

/obj/item/clothing/suit/hooded/wintercoat/security/old
	name = "nostalgiczna policyjna kurtka zimowa"
	icon_state = "old_coatsecurity"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/security/old

/obj/item/clothing/suit/hooded/wintercoat/security/old/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_wintercoat_allowed

/obj/item/clothing/head/hooded/winterhood/security/old
	icon_state = "old_winterhood_security"

/obj/item/clothing/suit/hooded/wintercoat/medical/old
	name = "nostalgiczna medyczna kurtka zimowa"
	icon_state = "old_coatmedical"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/medical/old

/obj/item/clothing/head/hooded/winterhood/medical/old
	icon_state = "old_winterhood_medical"

/obj/item/clothing/suit/hooded/wintercoat/science/old
	name = "nostalgiczna kurtka zimowa nauki"
	icon_state = "old_coatscience"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/science/old

/obj/item/clothing/head/hooded/winterhood/science/old
	icon_state = "old_winterhood_science"

/obj/item/clothing/suit/hooded/wintercoat/engineering/old
	name = "nostalgiczna inżynieryjna kurtka zimowa"
	icon_state = "old_coatengineer"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/old

/obj/item/clothing/head/hooded/winterhood/engineering/old
	icon_state = "old_winterhood_engineer"

/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos/old
	name = "nostalgiczna kurtka zimowa atmosferyki"
	icon_state = "old_coatatmos"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/engineering/atmos/old

/obj/item/clothing/head/hooded/winterhood/engineering/atmos/old
	icon_state = "old_winterhood_atmos"

/obj/item/clothing/suit/hooded/wintercoat/hydro/old
	name = "nostalgiczna kurtka zimowa botaniki"
	icon_state = "old_coathydro"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/hydro/old

/obj/item/clothing/head/hooded/winterhood/hydro/old
	icon_state = "old_winterhood_hydro"

//end of winter coats

/obj/item/clothing/suit/spookyghost
	name = "upiorny duch"
	desc = "To oczywiście tylko prześcieradło, ale może je przymierzysz?"
	icon_state = "bedsheet"
	user_vars_to_edit = list("name" = "Upiorny duch", "real_name" = "Upiorny duch" , "incorporeal_move" = INCORPOREAL_MOVE_BASIC, "appearance_flags" = KEEP_TOGETHER|TILE_BOUND, "alpha" = 150)
	alternate_worn_layer = ABOVE_BODY_FRONT_LAYER //so the bedsheet goes over everything but fire

/obj/item/clothing/suit/bronze
	name = "brązowa zbroja"
	desc = "Wielka, brzęcząca zbroja z brązu, która nie daje żadnej ochrony i wygląda bardzo niemodnie. Super."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_cuirass_old"
	armor = list("melee" = 5, "bullet" = 0, "laser" = -5, "energy" = 0, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 20, "stamina" = 30)

/obj/item/clothing/suit/ghost_sheet
	name = "prześcieradło ducha"
	desc = "Dłonie unoszą się same, więc jest jeszcze straszniej."
	icon_state = "ghost_sheet"
	item_state = "ghost_sheet"
	throwforce = 0
	throw_speed = 1
	throw_range = 2
	w_class = WEIGHT_CLASS_TINY
	flags_inv = HIDEGLOVES|HIDEEARS|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	alternate_worn_layer = UNDER_HEAD_LAYER

/obj/item/clothing/under/costume/joker
	name = "strój komika"
	desc = "Najgorsze w chorobie psychicznej jest to, że ludzie oczekują, że będziesz się zachowywać, jakbyś jej nie miał."
	icon_state = "joker"
	item_state = "joker"
	can_adjust = FALSE

/obj/item/clothing/suit/joker
	name = "płaszcz komika"
	desc = "No bo czy żeby być komikiem, nie trzeba być zabawnym?"
	icon_state = "joker_coat"
	item_state = "joker_coat"

/obj/item/clothing/suit/toggle/softshell
	name = "kurtka softshell"
	desc = "Kurtka softshell z logo Nanotrasen."
	icon_state = "softshell"
	item_state = "softshell"
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/t_scanner, /obj/item/radio)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 30, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0)
	togglename = "zamek"
	body_parts_covered = CHEST|GROIN|ARMS
