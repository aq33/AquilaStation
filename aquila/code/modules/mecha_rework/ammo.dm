// AQUILA - amunicja do broni balistycznej mechów (wzór: /obj/item/mecha_ammo z Shiptestu i tg).
// Każda broń balistyczna mecha ma zapas (aq_ammo_cache) uzupełniany skrzynkami amunicji mecha, zwykłą amunicją
// pasującego kalibru (luźne naboje, pudełka, magazynki) albo, w wyrzutniach, tym, co wystrzeliwują (granaty, bole,
// skórki od banana). Tą drogą do mechów trafia też amunicja z kuźni amunicji: kuźnia robi przedmioty, mech przyjmuje
// każdy nabój pasującego kalibru. Przeładowanie bierze tylko z zapasu: amunicji nie dobija się już z ogniwa.

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic
	/// Rodzaj skrzynki amunicji mecha, który pasuje (null = żaden)
	var/aq_ammo_type
	/// Naboje w zapasie
	var/aq_ammo_cache = 0
	/// Pojemność zapasu
	var/aq_ammo_cache_max = 0
	/// Kalibry zwykłej amunicji, którą da się załadować do zapasu
	var/list/aq_calibers
	/// Przedmiot ładowany sztuka po sztuce (wyrzutnie: domyślnie to, co wystrzeliwują)
	var/aq_item_ammo

// Pełne nadpisanie bez ..(): rdzeń dobija amunicję z ogniwa, u nas przeładowanie idzie tylko z zapasu (LEGACY_OVERRIDES.md)
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/rearm()
	var/missing = initial(projectiles) - projectiles
	if(missing <= 0 || aq_ammo_cache <= 0)
		return FALSE
	var/taken = min(missing, aq_ammo_cache)
	projectiles += taken
	aq_ammo_cache -= taken
	playsound(chassis || src, 'sound/weapons/bulletinsert.ogg', 40, TRUE)
	SStgui.update_uis(chassis)
	log_message("Rearmed [src.name] from ammo storage.", LOG_MECHA)
	return TRUE

/// Pusta broń przeładowuje się z zapasu; bez zapasu odmawia strzału
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/aq_ready_ammo()
	if(projectiles > 0)
		return TRUE
	if(aq_ammo_cache > 0)
		return rearm()
	occupant_message("<span class='warning'>Brak amunicji w [src]!</span>")
	return FALSE

/// Po strzale: ładowarka uzbrojenia sama przeładowuje pustą broń
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/aq_after_shot()
	if(projectiles <= 0 && aq_ammo_cache > 0 && (locate(/obj/item/mecha_parts/mecha_equipment/aq_utility/weapons_loader) in chassis?.equipment))
		rearm()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/action(atom/target, params)
	if(!aq_ready_ammo())
		return 0
	. = ..()
	if(.)
		aq_after_shot()

// rdzeniowe action() wyrzutni nie woła ..() broni balistycznej
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/action(atom/target, params)
	if(!aq_ready_ammo())
		return 0
	. = ..()
	if(.)
		aq_after_shot()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/aq_item_ammo_type()
	return aq_item_ammo

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/aq_item_ammo_type()
	return aq_item_ammo || projectile

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/get_equip_info()
	. = ..()
	if(aq_ammo_cache_max)
		. += " <span style='color:#aaa'>zapas: [aq_ammo_cache]/[aq_ammo_cache_max]</span>"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/examine(mob/user)
	. = ..()
	if(aq_ammo_cache_max)
		var/obj/item/item_ammo = aq_item_ammo_type()
		. += "<span class='notice'>Naboje: [projectiles]/[initial(projectiles)], zapas [aq_ammo_cache]/[aq_ammo_cache_max][length(aq_calibers) ? ", przyjmuje kaliber: [english_list(aq_calibers)]" : ""][item_ammo ? ", ładuje się: [initial(item_ammo.name)]" : ""].</span>"

/// Ile miejsca w zapasie
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/aq_cache_space()
	var/max_cache = aq_ammo_cache_max
	if(chassis && (locate(/obj/item/mecha_parts/mecha_equipment/aq_utility/weapons_loader) in chassis.equipment))
		max_cache *= 2
	return max(0, max_cache - aq_ammo_cache)

/// Ładuje zwykłą amunicję (nabój, pudełko, magazynek). Zwraca liczbę załadowanych naboi.
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/aq_load_casings(obj/item/I)
	if(!length(aq_calibers))
		return 0
	var/loaded = 0
	if(istype(I, /obj/item/ammo_casing))
		var/obj/item/ammo_casing/C = I
		if(C.BB && (C.caliber in aq_calibers) && aq_cache_space())
			aq_ammo_cache++
			qdel(C)
			return 1
		return 0
	if(istype(I, /obj/item/ammo_box))
		var/obj/item/ammo_box/box = I
		for(var/obj/item/ammo_casing/C in box.stored_ammo.Copy())
			if(!aq_cache_space())
				break
			if(!C.BB || !(C.caliber in aq_calibers))
				continue
			box.stored_ammo -= C
			qdel(C)
			aq_ammo_cache++
			loaded++
		if(loaded)
			box.update_icon()
	return loaded

/// Ładuje skrzynkę amunicji mecha. Zwraca liczbę naboi.
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/aq_load_box(obj/item/mecha_ammo/box)
	if(!aq_ammo_type || box.ammo_type != aq_ammo_type || box.rounds <= 0)
		return 0
	var/n = min(box.rounds, aq_cache_space())
	if(n <= 0)
		return 0
	box.rounds -= n
	aq_ammo_cache += n
	box.update_ammo_name()
	return n

/// Ładuje przedmiot, który broń wystrzeliwuje (granat, bola, skórka od banana). Zwraca 1, jeśli wszedł.
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/proc/aq_load_item(obj/item/I)
	var/ammo_path = aq_item_ammo_type()
	if(!ammo_path || !istype(I, ammo_path) || !aq_cache_space())
		return 0
	if(istype(I, /obj/item/grenade))
		var/obj/item/grenade/G = I
		if(G.active)
			return 0
	aq_ammo_cache++
	qdel(I)
	return 1

/obj/mecha/attackby(obj/item/W, mob/user, params)
	if(aq_load_ammo(W, user))
		return
	return ..()

/// Ładuje amunicję do pasującej broni mecha. Zwraca TRUE, jeśli coś weszło.
/obj/mecha/proc/aq_load_ammo(obj/item/W, mob/user)
	var/total = 0
	for(var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/gun in equipment)
		if(istype(W, /obj/item/mecha_ammo))
			total += gun.aq_load_box(W)
		else if(!QDELETED(W))
			total += gun.aq_load_casings(W)
			if(!QDELETED(W))
				total += gun.aq_load_item(W)
		if(total && QDELETED(W))
			break
	if(!total)
		return FALSE
	if(user)
		to_chat(user, "<span class='notice'>Ładujesz [total] [total == 1 ? "nabój" : "naboi"] do [src].</span>")
	playsound(src, 'sound/weapons/bulletinsert.ogg', 50, TRUE)
	SStgui.update_uis(src)
	return TRUE

// ---------------------------------------------------------------- skrzynki amunicji mecha
/obj/item/mecha_ammo
	name = "skrzynka amunicji egzoszkieletu"
	desc = "Skrzynka amunicji do broni egzoszkieletów. Użyj jej na mechu, żeby załadować pasującą broń."
	icon = 'aquila/icons/mecha/aq_mecha_ammo.dmi'
	icon_state = "empty"
	w_class = WEIGHT_CLASS_BULKY
	var/rounds = 0
	var/ammo_type

/obj/item/mecha_ammo/proc/update_ammo_name()
	if(rounds <= 0)
		name = "pusta skrzynka amunicji egzoszkieletu"
		desc = "Opróżniona skrzynka po amunicji egzoszkieletu. Złóż ją w ręce, żeby odzyskać blachę."
		icon_state = "empty"

/obj/item/mecha_ammo/attack_self(mob/user)
	. = ..()
	if(rounds > 0)
		to_chat(user, "<span class='warning'>Nie da się złożyć pełnej skrzynki.</span>")
		return
	to_chat(user, "<span class='notice'>Składasz [src] na płasko.</span>")
	var/obj/item/stack/sheet/iron/sheet = new(user.drop_location())
	qdel(src)
	user.put_in_hands(sheet)

/obj/item/mecha_ammo/examine(mob/user)
	. = ..()
	if(rounds > 0)
		. += "<span class='notice'>Zostało naboi: [rounds].</span>"

/obj/item/mecha_ammo/lmg
	name = "skrzynka amunicji do lekkiego karabinu maszynowego mecha"
	desc = "Taśma do lekkiego karabinu maszynowego Ultra AC 2. Użyj jej na mechu, żeby załadować broń."
	icon_state = "lmg"
	rounds = 300
	ammo_type = "lmg"

/obj/item/mecha_ammo/incendiary
	name = "skrzynka amunicji zapalającej egzoszkieletu"
	desc = "Naboje zapalające do karabinka FNX-99 \"Hades\". Użyj jej na mechu, żeby załadować broń."
	icon_state = "incendiary"
	rounds = 48
	ammo_type = "incendiary"

/obj/item/mecha_ammo/scattershot
	name = "skrzynka śrutu egzoszkieletu"
	desc = "Śrut do działka LBX AC 10. Użyj jej na mechu, żeby załadować broń."
	icon_state = "scattershot"
	rounds = 40
	ammo_type = "scattershot"

/obj/item/mecha_ammo/missiles_he
	name = "skrzynka rakiet SRM-8"
	desc = "Lekkie rakiety wybuchowe do wyrzutni SRM-8. Użyj jej na mechu, żeby załadować broń."
	icon_state = "missile_he"
	rounds = 8
	ammo_type = "missiles_he"

/obj/item/mecha_ammo/missiles_breaching
	name = "skrzynka rakiet wyłomowych PEP-6"
	desc = "Rakiety wyłomowe do wyrzutni PEP-6: kruszą ściany i drzwi, ludzi tylko ogłuszają. Użyj jej na mechu, żeby załadować broń."
	icon_state = "missile_br"
	rounds = 6
	ammo_type = "missiles_br"

/obj/item/mecha_ammo/umg2
	name = "magazynek do karabinu UMG-2"
	desc = "Wymienny magazynek do karabinu maszynowego UMG-2 (7,62 mm). Użyj go na mechu, żeby załadować broń."
	icon_state = "lmg"
	rounds = 60
	ammo_type = "umg2"

/obj/item/mecha_ammo/executor
	name = "magazynek do karabinu Executor"
	desc = "Pociski przeciwpancerne 20x160 mm do karabinu Executor. Użyj go na mechu, żeby załadować broń."
	icon_state = "railgun"
	rounds = 10
	ammo_type = "executor"

/obj/item/mecha_ammo/sentinel
	name = "skrzynka pocisków działa Sentinela"
	desc = "Ciężkie pociski odłamkowo-burzące do działa Sentinela. Użyj jej na mechu, żeby załadować broń."
	icon_state = "missile_he"
	rounds = 10
	ammo_type = "sentinel"

/obj/item/mecha_ammo/smilgas
	name = "skrzynka rakiet kierowanych Smilgas"
	desc = "Kierowane rakiety przeciwpancerne do wyrzutni M/RP-66. Użyj jej na mechu, żeby załadować broń."
	icon_state = "missile_br"
	rounds = 4
	ammo_type = "smilgas"

/obj/item/mecha_ammo/fpw
	name = "magazynek do portów strzeleckich M56"
	desc = "Amunicja 10 mm do broni portów strzeleckich mecha. Użyj go na mechu, żeby załadować broń."
	icon_state = "lmg"
	rounds = 90
	ammo_type = "fpw"

// Stare bronie balistyczne też ładują się tylko z zapasu: skrzynkami, nabojami albo tym, co wystrzeliwują
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg
	aq_ammo_type = "lmg"
	aq_ammo_cache_max = 600
	aq_calibers = list("a762", "n762")

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine
	aq_ammo_type = "incendiary"
	aq_ammo_cache_max = 96

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot
	aq_ammo_type = "scattershot"
	aq_ammo_cache_max = 80
	aq_calibers = list("shotgun")

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	aq_ammo_type = "missiles_he"
	aq_ammo_cache_max = 16
	aq_calibers = list("84mm")

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/silenced
	aq_ammo_cache_max = 12
	aq_calibers = list(".45")

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/BBchaingun
	aq_ammo_cache_max = 200
	aq_calibers = list("foam_force")

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang
	aq_ammo_cache_max = 12

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/clusterbang
	aq_ammo_cache_max = 6

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/smart_foam
	aq_ammo_cache_max = 12

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar
	aq_ammo_cache_max = 30

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar/bombanana
	aq_ammo_cache_max = 16

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/mousetrap_mortar
	aq_ammo_cache_max = 30
	aq_item_ammo = /obj/item/assembly/mousetrap

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/punching_glove
	aq_ammo_cache_max = 10
	aq_item_ammo = /obj/item/clothing/gloves/boxing
