/obj/item/clothing/suit/armor
	allowed = null
	body_parts_covered = CHEST|GROIN // debatable
	cold_protection = CHEST|GROIN
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	strip_delay = 60
	equip_delay_other = 40
	max_integrity = 250
	resistance_flags = NONE
	armor = list("melee" = 30, "bullet" = 50, "laser" = 20, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "stamina" = 30, "bleed" = 50) //NSV13
	clothing_flags = THICKMATERIAL

/obj/item/clothing/suit/armor/Initialize(mapload)
	. = ..()
	if(!allowed)
		allowed = GLOB.security_vest_allowed

/obj/item/clothing/suit/armor/vest
	name = "kamizelka kuloodporna"
	desc = "Smukła kamizelka kuloodporna typu I-A, która dobrze chroni przed większością obrażeń."
	icon_state = "armoralt"
	item_state = "armoralt"
	blood_overlay_type = "armor"
	dog_fashion = /datum/dog_fashion/back

/obj/item/clothing/suit/armor/vest/alt
	desc = "Kamizelka kuloodporna typu I-B w alternatywnym kroju, która dobrze chroni przed większością obrażeń. W praktyce działa tak samo jak I-A."
	icon_state = "armor"
	item_state = "armor"

/obj/item/clothing/suit/armor/vest/old
	name = "zużyta kamizelka kuloodporna"
	desc = "Kamizelka kuloodporna typu 1 starszej generacji. Z czasem się zużyła, więc ruszać się w niej jest znacznie trudniej."
	icon_state = "armor"
	item_state = "armor"
	slowdown = 1

/obj/item/clothing/suit/armor/vest/blueshirt
	name = "duża kamizelka kuloodporna"
	desc = "Duży, ale wygodny pancerz zszyty przez zbuntowanego kwatermistrza – prezent. Typ H-L" //NSV13
	icon_state = "blueshift"
	item_state = "blueshift"
	custom_premium_price = 600
	armor = list("melee" = 50, "bullet" = 5, "laser" = 5, "energy" = 10, "bomb" = 15, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "stamina" = 40) //NSV13
	body_parts_covered = CHEST|GROIN

/obj/item/clothing/suit/armor/vest/corporate
	name = "kurtka korporacyjna"
	desc = "Stylowa kurtka korporacyjna, która przy okazji chroni."
	icon_state = "secjacket"
	item_state = "secjacket"
	body_parts_covered = CHEST|GROIN|ARMS
	armor = list("melee" = 35, "bullet" = 45, "laser" = 10, "energy" = 30, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 45, "acid" = 45, "stamina" = 30, "bleed" = 20) //NSV13

/obj/item/clothing/suit/armor/hos
	name = "opancerzony płaszcz"
	desc = "Płaszcz wzmocniony specjalnym stopem – dodatkowa ochrona i styl dla tych, którzy mają w sobie coś z dowódcy."
	icon_state = "hos"
	item_state = "greatcoat"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	armor = list("melee" = 40, "bullet" = 60, "laser" = 15, "energy" = 30, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 90, "stamina" = 40, "bleed" = 40) //NSV13
	cold_protection = CHEST|GROIN|LEGS|ARMS
	heat_protection = CHEST|GROIN|LEGS|ARMS
	strip_delay = 80

/obj/item/clothing/suit/armor/hos/trenchcoat
	name = "opancerzony trencz"
	desc = "Trencz wzmocniony specjalnym lekkim kevlarem. Szczyt taktycznego ubioru cywilnego."
	icon_state = "hostrench"
	item_state = "hostrench"
	flags_inv = 0
	strip_delay = 80

/obj/item/clothing/suit/armor/vest/warden
	name = "kurtka Naczelnika"
	desc = "Granatowa opancerzona kurtka z niebieskimi oznaczeniami na ramionach i napisem „/Naczelnik/” wyszytym na jednej z kieszeni na piersi."
	icon_state = "warden_alt"
	item_state = "armor"
	body_parts_covered = CHEST|GROIN|ARMS
	armor = list("melee" = 30, "bullet" = 55, "laser" = 15, "energy" = 40, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 70, "acid" = 90, "stamina" = 40) //NSV13
	cold_protection = CHEST|GROIN|ARMS|HANDS
	heat_protection = CHEST|GROIN|ARMS|HANDS
	strip_delay = 70
	resistance_flags = FLAMMABLE
	dog_fashion = null

/obj/item/clothing/suit/armor/vest/warden/alt
	name = "opancerzona kurtka Naczelnika"
	desc = "Czerwona kurtka ze srebrnymi gwiazdkami stopnia i przypiętym na wierzchu pancerzem."
	icon_state = "warden_jacket"

/obj/item/clothing/suit/armor/vest/leather
	name = "płaszcz policyjny"
	desc = "Lekko opancerzony skórzany płaszcz do codziennego noszenia przez wysokich rangą oficerów. Ma herb ochrony Nanotrasen."
	icon_state = "leathercoat-sec"
	item_state = "hostrench"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	cold_protection = CHEST|GROIN|LEGS|ARMS
	heat_protection = CHEST|GROIN|LEGS|ARMS
	dog_fashion = null

/obj/item/clothing/suit/armor/vest/capcarapace
	name = "napierśnik kapitana"
	desc = "Ognioodporny opancerzony napierśnik wzmocniony ceramicznymi płytami i naramiennikami z plastali. Zapewnia dodatkową ochronę, nie ograniczając ruchów. Wydawany tylko najlepszym na statku, choć obciera sutki."
	icon_state = "capcarapace"
	item_state = "armor"
	body_parts_covered = CHEST|GROIN
	armor = list("melee" = 50, "bullet" = 50, "laser" = 20, "energy" = 60, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 90, "stamina" = 40, "bleed" = 60) //NSV13
	dog_fashion = null
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/armor/vest/capcarapace/syndicate
	name = "kamizelka kapitana Syndykatu"
	desc = "Złowrogo wyglądająca kamizelka z zaawansowanym pancerzem, noszona na czarno-czerwonej ognioodpornej kurtce. Złoty kołnierz i ramiona oznaczają, że należy do wysokiego rangą oficera Syndykatu."
	icon_state = "syndievest"

/obj/item/clothing/suit/armor/vest/capcarapace/alt
	name = "paradna kurtka kapitana"
	desc = "Na wypadek, gdy kamizelka kuloodporna nie jest dość modna."
	icon_state = "capformal"
	item_state = "capspacesuit"

/obj/item/clothing/suit/armor/vest/capcarapace/jacket
	name = "kurtka kapitana"
	desc = "Opancerzona kurtka w barwach kapitana"
	icon_state = "capjacket"
	item_state = "capspacesuit"
	body_parts_covered = CHEST|ARMS
	armor = list("melee" = 40, "bullet" = 50, "laser" = 20, "energy" = 50, "bomb" = 55, "bio" = 0, "rad" = 0, "fire" = 90, "acid" = 80, "stamina" = 40, "bleed" = 30) //NSV13

/obj/item/clothing/suit/armor/riot
	name = "strój prewencyjny"
	desc = "Półelastyczny poliwęglanowy pancerz z grubą wyściółką, który chroni przed atakami wręcz. Pomaga nie dać się popchnąć w ciasnych pomieszczeniach."
	icon_state = "riot"
	item_state = "swat_suit"
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list("melee" = 60, "bullet" = 10, "laser" = 10, "energy" = 15, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80, "stamina" = 50, "bleed" = 70) //NSV13
	blocks_shove_knockdown = TRUE
	strip_delay = 80
	equip_delay_other = 60
	slowdown = 0.05
	move_sound = list('sound/effects/suitstep1.ogg', 'sound/effects/suitstep2.ogg')

/obj/item/clothing/suit/armor/bone
	name = "pancerz z kości"
	desc = "Plemienny napierśnik wykonany ze zwierzęcych kości."
	icon_state = "bonearmor"
	item_state = "bonearmor"
	blood_overlay_type = "armor"
	armor = list("melee" = 35, "bullet" = 25, "laser" = 25, "energy" = 30, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "stamina" = 20, "bleed" = 50)
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS

/obj/item/clothing/suit/armor/bulletproof
	name = "pancerz kuloodporny"
	desc = "Ciężka kamizelka kuloodporna typu III, która świetnie chroni przed tradycyjną bronią palną, a w mniejszym stopniu także przed wybuchami."
	icon_state = "bulletproof"
	item_state = "armor"
	blood_overlay_type = "armor"
	armor = list("melee" = 15, "bullet" = 60, "laser" = 10, "energy" = 10, "bomb" = 40, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50, "stamina" = 40, "bleed" = 60)
	strip_delay = 70
	equip_delay_other = 50

/obj/item/clothing/suit/armor/laserproof
	name = "kamizelka refleksyjna"
	desc = "Kamizelka, która świetnie chroni przed pociskami energetycznymi, a czasem nawet je odbija."
	icon_state = "armor_reflec"
	item_state = "armor_reflec"
	blood_overlay_type = "armor"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 60, "energy" = 80, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100, "stamina" = 40, "bleed" = 10)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/hit_reflect_chance = 40

/obj/item/clothing/suit/armor/laserproof/IsReflect(def_zone)
	if(!(def_zone in list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN))) //If not shot where ablative is covering you, you don't get the reflection bonus!
		return 0
	if (prob(hit_reflect_chance))
		return 1

/obj/item/clothing/suit/armor/vest/det_suit
	name = "kamizelka kuloodporna detektywa"
	desc = "Kamizelka kuloodporna z odznaką detektywa."
	icon_state = "detective-armor"
	resistance_flags = FLAMMABLE
	dog_fashion = null

/obj/item/clothing/suit/armor/vest/det_suit/Initialize(mapload)
	. = ..()
	allowed = GLOB.detective_vest_allowed

//All of the armor below is mostly unused

/obj/item/clothing/suit/armor/centcom
	name = "\improper pancerz Centrali"
	desc = "Strój, który chroni przed częścią obrażeń."
	icon_state = "centcom"
	item_state = "centcom"
	w_class = WEIGHT_CLASS_BULKY
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/gun/energy, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 60, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 90, "stamina" = 70)

/obj/item/clothing/suit/armor/heavy
	name = "ciężki pancerz"
	desc = "Mocno opancerzony strój, który chroni przed umiarkowanymi obrażeniami."
	icon_state = "heavy"
	item_state = "swat_suit"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.9
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	slowdown = 3
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 60, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 90, "stamina" = 60, "bleed" = 70)
	move_sound = list('sound/effects/suitstep1.ogg', 'sound/effects/suitstep2.ogg')

/obj/item/clothing/suit/armor/tdome
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list("melee" = 80, "bullet" = 80, "laser" = 50, "energy" = 60, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 90, "acid" = 90, "stamina" = 0, "bleed" = 0)
	move_sound = list('sound/effects/suitstep1.ogg', 'sound/effects/suitstep2.ogg')

/obj/item/clothing/suit/armor/tdome/red
	name = "strój Thunderdome"
	desc = "Czerwonawy pancerz."
	icon_state = "tdred"
	item_state = "tdred"

/obj/item/clothing/suit/armor/tdome/green
	name = "strój Thunderdome"
	desc = "Pancerz w kolorze wymiocin."	//classy.
	icon_state = "tdgreen"
	item_state = "tdgreen"

/obj/item/clothing/suit/armor/tdome/holosuit
	name = "strój Thunderdome"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0, "stamina" = 0, "bleed" = 0)
	cold_protection = null
	heat_protection = null

/obj/item/clothing/suit/armor/tdome/holosuit/red
	desc = "Czerwonawy pancerz."
	icon_state = "tdred"
	item_state = "tdred"

/obj/item/clothing/suit/armor/tdome/holosuit/green
	desc = "Pancerz w kolorze wymiocin."
	icon_state = "tdgreen"
	item_state = "tdgreen"

/obj/item/clothing/suit/armor/riot/knight
	name = "zbroja płytowa"
	desc = "Klasyczna zbroja płytowa, bardzo skuteczna przeciw atakom wręcz."
	icon_state = "knight_green"
	item_state = "knight_green"
	move_sound = null

/obj/item/clothing/suit/armor/riot/knight/yellow
	icon_state = "knight_yellow"
	item_state = "knight_yellow"

/obj/item/clothing/suit/armor/riot/knight/blue
	icon_state = "knight_blue"
	item_state = "knight_blue"

/obj/item/clothing/suit/armor/riot/knight/red
	icon_state = "knight_red"
	item_state = "knight_red"

/obj/item/clothing/suit/armor/vest/durathread
	name = "kamizelka z duranici"
	desc = "Kamizelka z duranici z pasami skóry pełniącymi funkcję płyt ochronnych."
	icon_state = "durathread"
	item_state = "durathread"
	strip_delay = 60
	equip_delay_other = 40
	max_integrity = 200
	resistance_flags = FLAMMABLE
	armor = list("melee" = 25, "bullet" = 25, "laser" = 10, "energy" = 30, "bomb" = 15, "bio" = 0, "rad" = 0, "fire" = 40, "acid" = 50, "stamina" = 30, "bleed" = 60) //NSV13

/obj/item/clothing/suit/armor/vest/russian
	name = "rosyjska kamizelka"
	desc = "Kamizelka kuloodporna w leśnym kamuflażu. Dobrze, że jest tu tyle lasów, w których można się ukryć, prawda?"
	icon_state = "rus_armor"
	item_state = "rus_armor"
	armor = list("melee" = 25, "bullet" = 30, "laser" = 0, "energy" = 15, "bomb" = 10, "bio" = 0, "rad" = 20, "fire" = 20, "acid" = 50, "stamina" = 25, "bleed" = 20)

/obj/item/clothing/suit/armor/vest/russian_coat
	name = "rosyjski płaszcz bojowy"
	desc = "Noszony na wyjątkowo mroźnych frontach. Uszyty z prawdziwych niedźwiedzi."
	icon_state = "rus_coat"
	item_state = "rus_coat"
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	armor = list("melee" = 25, "bullet" = 30, "laser" = 10, "energy" = 30, "bomb" = 20, "bio" = 50, "rad" = 20, "fire" = -10, "acid" = 50, "stamina" = 30, "bleed" = 20) //NSV13
