/datum/gang_item
	var/name
	var/item_path
	var/cost
	var/spawn_msg
	var/category
	var/list/gang_whitelist = list()
	var/list/gang_blacklist = list()
	var/id

/datum/gang_item/proc/purchase(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool, check_canbuy = TRUE)
	if(check_canbuy && !can_buy(user, gang, gangtool))
		return FALSE
	var/real_cost = get_cost(user, gang, gangtool)
	if(!spawn_item(user, gang, gangtool))
		gang.adjust_influence(-real_cost)
		to_chat(user, "<span class='notice'>Kupujesz: [name].</span>")
		return TRUE

/datum/gang_item/proc/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool) // If this returns anything other than null, something fucked up and influence won't lower.
	if(item_path)
		var/obj/item/O = new item_path(user.loc)
		user.put_in_hands(O)
	else
		return TRUE
	if(spawn_msg)
		to_chat(user, spawn_msg)

/datum/gang_item/proc/can_buy(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	return gang && (gang.influence >= get_cost(user, gang, gangtool)) && can_see(user, gang, gangtool)

/datum/gang_item/proc/can_see(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	return TRUE

/datum/gang_item/proc/get_cost(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	return cost

/datum/gang_item/proc/get_cost_display(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	return "([get_cost(user, gang, gangtool)] wpływów)"

/datum/gang_item/proc/get_name_display(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	return name

/datum/gang_item/proc/get_extra_info(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	return

///////////////////
//Essential Gang Tools
///////////////////

/datum/gang_item/essentials
	category = "Kup niezbędne przedmioty:"

/datum/gang_item/essentials/spraycan
	name = "Farba do oznaczania terytorium"
	id = "spraycan"
	cost = 10
	item_path = /obj/item/toy/crayon/spraycan/gang

/datum/gang_item/essentials/implant_breaker
	name = "Implant przeprogramowujący"
	id = "implant_breaker"
	cost = 25
	item_path = /obj/item/implanter/gang
	spawn_msg = "<span class='notice'><b>Implant przeprogramowujący</b> to jednorazowy implant, który przeprogramowuje cel na członka twojego gangu. Jest za słaby, by przełamać najnowsze implanty ochrony umysłu NT lub przeprogramować poruczników.</span>"

/datum/gang_item/essentials/implant_breaker/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	var/obj/item/O = new item_path(get_turf(user), gang)
	user.put_in_hands(O)

/datum/gang_item/essentials/gangtool
	id = "gangtool"
	cost = 50

/datum/gang_item/essentials/gangtool/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	var/item_type
	if(gang)
		item_type = /obj/item/device/gangtool/spare/lt
		if(gang.leaders.len < MAX_LEADERS_GANG)
			to_chat(user, "<span class='notice'><b>Gangtoole</b> pozwalają awansować gangstera na porucznika, który może werbować i kupować przedmioty jak ty. Wystarczy, że zarejestruje gangtool. Możesz awansować jeszcze maksymalnie [MAX_LEADERS_GANG-gang.leaders.len] poruczników.</span>")
	else
		item_type = /obj/item/device/gangtool/spare
	var/obj/item/device/gangtool/spare/tool = new item_type(user.loc)
	user.put_in_hands(tool)

/datum/gang_item/essentials/gangtool/get_name_display(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	if(gang && (gang.leaders.len < gang.max_leaders))
		return "Awansuj gangstera"
	return "Zapasowy gangtool"

/datum/gang_item/essentials/spraycan/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	var/obj/item/O = new item_path(user.loc, gang)
	user.put_in_hands(O)

/datum/gang_item/essentials/pen
	name = "Długopis werbunkowy"
	id = "pen"
	cost = 50
	item_path = /obj/item/pen/gang
	spawn_msg = "<span class='notice'>Więcej <b>długopisów werbunkowych</b> pozwoli szybciej werbować gangsterów. Werbować długopisami mogą tylko przywódcy gangu.</span>"

/datum/gang_item/essentials/pen/purchase(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	if(..())
		gangtool.free_pen = FALSE
		return TRUE
	return FALSE

/datum/gang_item/essentials/pen/get_cost(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	if(gangtool?.free_pen)
		return 0
	return ..()

/datum/gang_item/essentials/pen/get_cost_display(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	if(gangtool?.free_pen)
		return "(JEDEN GRATIS)"
	return ..()
	
/datum/gang_item/essentials/reinforce
	name = "Wezwij posiłki"
	id = "reinforce"
	cost = 250
	item_path = /obj/item/antag_spawner/gangster

///////////////////
//CLOTHING
///////////////////

/datum/gang_item/clothing
	category = "Kup ubrania gangu (dodatkowe wpływy dają tylko kombinezon, kapelusz i strój):"

/datum/gang_item/clothing/basic
	name = "Mundur gangu"
	id = "under"
	cost = 5

/datum/gang_item/clothing/basic/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	var/obj/item/storage/box/uniform_box = new (get_turf(user))

	new gang.outfit(uniform_box)
	new gang.suit(uniform_box)
	new gang.hat(uniform_box)

	user.put_in_hands(uniform_box)
	to_chat(user, "<span class='notice'> To oficjalny mundur twojego gangu, noszenie go zwiększa twoje wpływy")
	return TRUE

/datum/gang_item/clothing/armor
	name = "Opancerzone okrycie gangu"
	id = "armor"
	cost = 200

/datum/gang_item/clothing/armor/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	var/obj/item/storage/box/armor_box = new (get_turf(user))

	var/obj/item/clothing/suit/suit = new gang.suit(armor_box)
	suit.armor = suit.armor.setRating(melee = 20, bullet = 35, laser = 10, energy = 10, bomb = 30, bio = 0, rad = 0, fire = 30, acid = 30)
	suit.desc += " Uszyty dla bandy [gang.name], by zapewnić noszącemu umiarkowaną ochronę przed pociskami i urazami fizycznymi."

	var/obj/item/clothing/head/hat = new gang.hat(armor_box)
	hat.armor = hat.armor.setRating(melee = 20, bullet = 35, laser = 10, energy = 10, bomb = 30, bio = 0, rad = 0, fire = 30, acid = 30)
	hat.desc += " Uszyty dla bandy [gang.name], by zapewnić noszącemu umiarkowaną ochronę przed pociskami i urazami fizycznymi."

	user.put_in_hands(armor_box)
	to_chat(user, "<span class='notice'> To oficjalny mundur twojego gangu, noszenie go zwiększa twoje wpływy")
	return TRUE

/datum/gang_item/clothing/ssuit
	name = "Kosmoszczelne okrycie gangu"
	id = "ssuit"
	cost = 200

/datum/gang_item/clothing/ssuit/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	var/obj/item/storage/box/armor_box = new (get_turf(user))

	var/obj/item/clothing/suit/suit = new gang.suit(armor_box)
	suit.clothing_flags |= STOPSPRESSUREDAMAGE | THICKMATERIAL
	suit.cold_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	suit.heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	suit.min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	suit.max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	suit.desc += " Uszyty dla bandy [gang.name], by zapewnić noszącemu umiarkowaną ochronę przed pociskami i urazami fizycznymi."

	var/obj/item/clothing/head/hat = new gang.hat(armor_box)
	hat.clothing_flags |= STOPSPRESSUREDAMAGE | THICKMATERIAL
	hat.cold_protection = HEAD
	hat.heat_protection = HEAD
	hat.min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	hat.max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	hat.desc += " Uszyty dla bandy [gang.name], by zapewnić noszącemu umiarkowaną ochronę przed pociskami i urazami fizycznymi."

	user.put_in_hands(armor_box)
	to_chat(user, "<span class='notice'> To oficjalny mundur twojego gangu, noszenie go zwiększa twoje wpływy")
	return TRUE

/datum/gang_item/clothing/mask
	name = "Złota maska śmierci"
	id = "mask"
	cost = 50
	item_path = /obj/item/clothing/mask/gskull

/obj/item/clothing/mask/gskull
	name = "złota maska śmierci"
	icon_state = "gskull"
	desc = "Zasiej w sercach wrogów strach i zazdrość."

/datum/gang_item/clothing/shoes
	name = "Błyszczące buty"
	id = "boots"
	cost = 50
	item_path = /obj/item/clothing/shoes/gang

/obj/item/clothing/shoes/gang
	name = "wypasione błyszczące buty"
	desc = "Z drogi, chłopi."
	icon_state = "bling"

/datum/gang_item/clothing/neck
	name = "Złoty łańcuch"
	id = "necklace"
	cost = 25
	item_path = /obj/item/clothing/neck/necklace/dope

/datum/gang_item/clothing/hands
	name = "Ozdobny kastet"
	id = "hand"
	cost = 50
	item_path = /obj/item/clothing/gloves/gang

/obj/item/clothing/gloves/gang
	name = "kastet chwalipięty"
	desc = "Czysto ozdobny, nie sprawdzaj tego na własnej skórze."
	icon_state = "knuckles"
	w_class = 3

/datum/gang_item/clothing/belt
	name = "Twardzielski pas"
	id = "belt"
	cost = 25
	item_path = /obj/item/storage/belt/military/gang

/obj/item/storage/belt/military/gang
	name = "twardzielski pas"
	icon_state = "gangbelt"
	item_state = "gang"
	desc = "Na sprzączce widnieje po prostu napis „BAMF”."

///////////////////
//WEAPONS
///////////////////

/datum/gang_item/weapon
	category = "Kup broń:"

/datum/gang_item/weapon/emp
	name = "Granat EMP"
	id = "EMP"
	cost = 50
	item_path = /obj/item/grenade/empgrenade

/datum/gang_item/weapon/c4
	name = "Ładunek C4"
	id = "c4"
	cost = 100
	item_path = /obj/item/grenade/plastic/c4

/datum/gang_item/weapon/switchblade
	name = "Nóż sprężynowy"
	id = "switchblade"
	cost = 100
	item_path = /obj/item/switchblade

/datum/gang_item/weapon/shuriken
	name = "Pudełko shurikenów"
	id = "shuriken"
	cost = 150
	item_path = /obj/item/storage/box/shuriken_box

/obj/item/storage/box/shuriken_box
	name = "pudełko shurikenów"

/obj/item/storage/box/shuriken_box/PopulateContents()
	for (var/i in 1 to 4)
		new /obj/item/throwing_star(src)

/datum/gang_item/weapon/pistol
	name = "Pistolet 10 mm"
	id = "pistol"
	cost = 500
	item_path = /obj/item/gun/ballistic/automatic/pistol

/datum/gang_item/weapon/pistol_ammo
	name = "Amunicja 10 mm"
	id = "pistol_ammo"
	cost = 50
	item_path = /obj/item/ammo_box/magazine/m10mm

/datum/gang_item/weapon/uzi
	name = "PM Uzi"
	id = "uzi"
	cost = 500
	item_path = /obj/item/gun/ballistic/automatic/mini_uzi

/datum/gang_item/weapon/uzi_ammo
	name = "Amunicja do Uzi"
	id = "uzi_ammo"
	cost = 50
	item_path = /obj/item/ammo_box/magazine/uzim9mm

/datum/gang_item/weapon/laser
	name = "Karabin laserowy"
	id = "laser"
	cost = 500
	item_path = /obj/item/gun/energy/laser/retro

///////////////////
//EQUIPMENT
///////////////////

/datum/gang_item/equipment
	category = "Kup sprzęt wsparcia:"

/datum/gang_item/equipment/healcigs
	name = "Lecznicze papierosy"
	id = "healcigs"
	cost = 20
	item_path = /obj/item/storage/fancy/cigarettes/cigpack_syndicate

/datum/gang_item/equipment/mulah
	name = "Kosmiczna gotówka (1000 kr.)"
	id = "mulah"
	cost = 25
	item_path = /obj/item/stack/spacecash/c1000

/datum/gang_item/equipment/drugs
	name = "Zapas narkotyków"
	id = "drugs"
	cost = 50
	item_path = /obj/item/storage/box

/datum/gang_item/equipment/drugs/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	var/obj/item/O
	var/turf/T = get_turf(user)
	switch (rand(1,10))
		if (1)
			O = new /obj/item/storage/pill_bottle/lsd(T)
		if (2)
			O = new /obj/item/storage/pill_bottle/happy(T)
		if (3)
			O = new /obj/item/storage/pill_bottle/zoom(T)
		if (4)
			O = new /obj/item/storage/pill_bottle/aranesp(T)
		if (5)
			O = new /obj/item/storage/pill_bottle/happiness(T)
		if (6)
			O = new /obj/item/storage/pill_bottle/psicodine(T)
		if (7)
			O = new /obj/item/storage/pill_bottle/psicodine(T)
		if (8)
			O = new /obj/item/food/grown/cannabis(T)
		if (9)
			O = new /obj/item/food/grown/cannabis/rainbow(T)
		if (10)
			O = new /obj/item/food/grown/cannabis/white(T)
	if (O)
		user.put_in_hands(O)

/datum/gang_item/equipment/aids
	name = "Polowa apteczka"
	id = "aids"
	cost = 75
	item_path = /obj/item/storage/firstaid/shifty/battle

/datum/gang_item/equipment/hangover
	name = "Zestaw na zły odlot"
	id = "hangover"
	cost = 75
	item_path = /obj/item/storage/firstaid/shifty/hangover

/obj/item/storage/firstaid/shifty
	name = "podejrzana apteczka"
	desc = "Podejrzana apteczka złożona ze ścinków i resztek."
	icon_state = "oldbezerk" // AQ EDIT - tgstation medkit sprite

/obj/item/storage/firstaid/shifty/battle/PopulateContents()
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/patch/silver_sulf = 2,
		/obj/item/reagent_containers/pill/patch/styptic = 2,
		/obj/item/reagent_containers/medspray/synthflesh = 1,
		/obj/item/reagent_containers/hypospray/medipen = 1,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/shifty/hangover/PopulateContents()
	var/static/items_inside = list(
		/obj/item/storage/pill_bottle/charcoal = 1,
		/obj/item/reagent_containers/syringe/antitoxin = 1,
		/obj/item/reagent_containers/hypospray/medipen = 2,
		/obj/item/reagent_containers/hypospray/medipen/dexalin = 2,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)
