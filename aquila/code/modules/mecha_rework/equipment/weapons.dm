// AQUILA - nowa broń dystansowa mechów. Źródła w opisach typów; balans: ciężka broń (działa, rakiety, laser
// rentgenowski, miotacz ognia) tylko na mechach bojowych (rdzeniowe can_attach broni), nieśmiercionośne wyrzutnie też na roboczych.

/obj/item/mecha_parts/mecha_equipment/weapon
	icon = 'icons/mecha/mecha_equipment.dmi'

/// Broń dla mechów roboczych (ochrona, porządek): nie wymaga mecha bojowego
/obj/item/mecha_parts/mecha_equipment/weapon/proc/aq_allows_working()
	return FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/can_attach(obj/mecha/M)
	if(aq_allows_working() && !istype(M, /obj/mecha/combat))
		if(!M.aq_free_slot_for(src))
			return FALSE
		return M.equipment.len < M.max_equip
	return ..()

// ---------------------------------------------------------------- balistyczna na magazynki
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/aq_umg2
	name = "\improper karabin maszynowy UMG-2"
	desc = "Karabin maszynowy dla egzoszkieletów (Shiptest) zasilany wymiennymi magazynkami 7,62 mm. Nie dobija amunicji z ogniwa: ładuje się go magazynkami UMG-2 albo luźną amunicją 7,62."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "aq_umg2"
	equip_cooldown = 8
	projectile = /obj/item/projectile/bullet/lmg
	projectiles = 60
	projectiles_per_shot = 4
	variance = 8
	randomspread = 1
	projectile_delay = 1.5
	fire_sound = 'sound/weapons/gunshot_smg.ogg'
	harmful = TRUE
	aq_ammo_type = "umg2"
	aq_ammo_cache = 60
	aq_ammo_cache_max = 240
	aq_calibers = list("a762", "n762")

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/aq_executor
	name = "\improper karabin mecha Executor"
	desc = "Ciężki, celny karabin mecha (MonkeStation) na pociski przeciwpancerne. Przebija ludzi i mechy, ładuje się magazynkami Executora albo amunicją .50."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "mecha_heavy"
	equip_cooldown = 34
	projectile = /obj/item/projectile/bullet/p50
	projectiles = 10
	fire_sound = 'sound/weapons/sniper_shot.ogg'
	harmful = TRUE
	aq_ammo_type = "executor"
	aq_ammo_cache = 10
	aq_ammo_cache_max = 50
	aq_calibers = list(".50")

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/aq_sentinel_cannon
	name = "działo Sentinela"
	desc = "Wielkie działo artyleryjskie w wieży Sentinela (MonkeStation). Strzela parą pocisków odłamkowo-burzących. Pasuje tylko do Sentinela."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "sentinel_cannon"
	equip_cooldown = 120
	projectile = /obj/item/projectile/bullet/aq_sentinel_shell
	projectiles = 10
	projectiles_per_shot = 2
	variance = 10
	randomspread = 3
	projectile_delay = 1
	fire_sound = 'aquila/sound/mecha/lighttankgun.ogg'
	harmful = TRUE
	aq_ammo_type = "sentinel"
	aq_ammo_cache = 10
	aq_ammo_cache_max = 30

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/aq_sentinel_cannon/can_attach(obj/mecha/M)
	if(!istype(M, /obj/mecha/combat/aq_sentinel))
		return FALSE
	return ..()

/obj/item/projectile/bullet/aq_sentinel_shell
	name = "pocisk Sentinela"
	icon_state = "missile"
	damage = 15
	armour_penetration = 100
	dismemberment = 10

/obj/item/projectile/bullet/aq_sentinel_shell/on_hit(atom/target, blocked = FALSE)
	. = ..()
	explosion(get_turf(target), -1, 1, 2, flame_range = 2, flash_range = 3)
	return BULLET_ACT_HIT

/obj/item/mecha_parts/mecha_equipment/weapon/energy/aq_sentinel_laser
	name = "działo laserowe Sentinela"
	desc = "Ogromny turbolaser w wieży Sentinela (MonkeStation). Pasuje tylko do Sentinela."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "sentinel_cannon_laser"
	equip_cooldown = 50
	energy_drain = 300
	projectile = /obj/item/projectile/beam/laser/heavylaser
	projectiles_per_shot = 2
	projectile_delay = 1
	fire_sound = 'sound/weapons/lasercannonfire.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/aq_sentinel_laser/can_attach(obj/mecha/M)
	if(!istype(M, /obj/mecha/combat/aq_sentinel))
		return FALSE
	return ..()

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/aq_venom
	name = "\improper karabinek K0-B3 \"Snakebite\""
	desc = "Broń do bojowych egzoszkieletów (Yogstation). Strzela pociskami z jadem, który wykańcza cel bez węgla aktywnego. Sprzęt Syndykatu."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "mecha_venom"
	equip_cooldown = 10
	projectile = /obj/item/projectile/bullet/aq_mech_venom
	projectiles = 24
	fire_sound = 'sound/weapons/gunshot_smg.ogg'
	harmful = TRUE
	aq_ammo_cache_max = 96
	aq_calibers = list(".45")

/obj/item/projectile/bullet/aq_mech_venom
	name = "pocisk z jadem"
	damage = 15
	var/venom = 4

/obj/item/projectile/bullet/aq_mech_venom/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target) && blocked < 100)
		var/mob/living/carbon/C = target
		C.reagents?.add_reagent(/datum/reagent/toxin/venom, venom)

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/aq_fpw
	name = "\improper broń portów strzeleckich M56 FPW"
	desc = "Karabin w porcie strzeleckim kabiny (CM-SS13). Strzela nim drugi załogant z wnętrza mecha, w dowolną stronę, niezależnie od tego, dokąd patrzy mech."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "aq_fpw"
	equip_cooldown = 6
	projectile = /obj/item/projectile/bullet/c10mm
	projectiles = 30
	projectiles_per_shot = 3
	projectile_delay = 1
	variance = 6
	randomspread = 1
	fire_sound = 'sound/weapons/gunshot_smg.ogg'
	harmful = TRUE
	aq_ammo_type = "fpw"
	aq_ammo_cache = 30
	aq_ammo_cache_max = 180
	aq_calibers = list("10mm")
	COOLDOWN_DECLARE(port_cooldown)

/// Strzał z portu: bez sprawdzania kierunku mecha, strzelcem jest drugi załogant
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/aq_fpw/proc/port_fire(atom/target, mob/living/shooter, params)
	if(!COOLDOWN_FINISHED(src, port_cooldown) || chassis.equipment_disabled)
		return FALSE
	if(projectiles <= 0)
		if(aq_ammo_cache > 0)
			rearm()
		else
			to_chat(shooter, "<span class='warning'>Brak amunicji w [src]!</span>")
			return FALSE
	if(HAS_TRAIT(shooter, TRAIT_PACIFISM))
		to_chat(shooter, "<span class='warning'>Nie chcesz krzywdzić innych żywych istot!</span>")
		return FALSE
	var/turf/curloc = get_turf(chassis)
	if(!curloc || get_turf(target) == curloc)
		return FALSE
	COOLDOWN_START(src, port_cooldown, equip_cooldown)
	for(var/i in 1 to min(projectiles, projectiles_per_shot))
		var/obj/item/projectile/P = new projectile(curloc)
		P.firer = shooter
		P.original = target
		P.preparePixelProjectile(target, shooter, params, round((rand() - 0.5) * variance))
		P.fire()
		playsound(chassis, fire_sound, 50, TRUE)
		projectiles--
		sleep(projectile_delay)
	log_combat(shooter, target, "fired at", src, "(port strzelecki)")
	SStgui.update_uis(chassis)
	return TRUE

/obj/mecha/click_action(atom/target, mob/user, params)
	if(user != occupant && user == aq_copilot)
		if(user.incapacitated() || phasing || !get_charge())
			return
		var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/aq_fpw/port = locate() in equipment
		if(port)
			INVOKE_ASYNC(port, TYPE_PROC_REF(/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/aq_fpw, port_fire), target, user, params)
		return
	return ..()

// ---------------------------------------------------------------- rakiety
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/aq_smilgas
	name = "\improper wyrzutnia rakiet kierowanych M/RP-66 \"Smilgas\""
	desc = "Przeciwpancerne rakiety kierowane (Nova Sector), które same skręcają za wskazanym celem. Broń dla strzelca Savannah i przeciw wrogim mechom."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "aq_smilgas"
	equip_cooldown = 50
	projectile = /obj/item/projectile/bullet/aq_smilgas
	projectiles = 4
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	harmful = TRUE
	aq_ammo_type = "smilgas"
	aq_ammo_cache = 4
	aq_ammo_cache_max = 8

/obj/item/projectile/bullet/aq_smilgas
	name = "rakieta kierowana"
	icon_state = "missile"
	damage = 30
	armour_penetration = 60
	speed = 1.2
	homing = TRUE
	homing_turn_speed = 25

/obj/item/projectile/bullet/aq_smilgas/fire(angle, atom/direct_target)
	if(original)
		set_homing_target(original)
	return ..()

/obj/item/projectile/bullet/aq_smilgas/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ismecha(target))
		var/obj/mecha/M = target
		M.take_damage(80, BRUTE, "bomb", FALSE)
	explosion(get_turf(target), -1, 0, 2, flash_range = 2)
	return BULLET_ACT_HIT

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/aq_breaching
	name = "\improper wyrzutnia rakiet wyłomowych PEP-6"
	desc = "Wyrzutnia rakiet wyłomowych (tg, BeeStation): kruszą ściany i drzwi, a ludzi tylko przewracają. Do wyważania przejść przy abordażu i na opuszczonych stacjach."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "mecha_missilerack_six"
	equip_cooldown = 60
	projectile = /obj/item/projectile/bullet/aq_breaching
	projectiles = 6
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	harmful = TRUE
	aq_ammo_type = "missiles_br"
	aq_ammo_cache_max = 12

/obj/item/projectile/bullet/aq_breaching
	name = "rakieta wyłomowa"
	icon_state = "missile"
	damage = 10

/obj/item/projectile/bullet/aq_breaching/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iswallturf(target))
		var/turf/closed/wall/W = target
		W.dismantle_wall(TRUE)
	else if(istype(target, /obj/machinery/door) || istype(target, /obj/structure/window) || istype(target, /obj/structure/grille))
		var/obj/O = target
		O.take_damage(600, BRUTE, "bomb", FALSE)
	else if(isliving(target))
		var/mob/living/L = target
		L.Knockdown(3 SECONDS)
	playsound(get_turf(target), 'sound/effects/meteorimpact.ogg', 60, TRUE)
	new /obj/effect/temp_visual/explosion/fast(get_turf(target))
	return BULLET_ACT_HIT

// ---------------------------------------------------------------- energia i ogień
/obj/item/mecha_parts/mecha_equipment/weapon/energy/aq_xray
	name = "\improper laser rentgenowski CH-XS"
	desc = "Laser rentgenowski dla egzoszkieletów (Aurora, Polaris, Paradise). Wiązka przenika ściany i okna, więc da się nim razić boarderów zza grodzi."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "mecha_xray"
	equip_cooldown = 25
	energy_drain = 150
	projectile = /obj/item/projectile/beam/xray
	fire_sound = 'sound/weapons/laser3.ogg'
	harmful = TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/aq_gamma
	name = "laser gamma egzoszkieletu"
	desc = "Laser (CHOMPStation, VOREStation), który zamiast palić napromieniowuje cel. Groźny dla ludzi, prawie nie rusza konstrukcji."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "aq_gamma"
	equip_cooldown = 20
	energy_drain = 120
	projectile = /obj/item/projectile/beam/aq_gamma
	fire_sound = 'sound/weapons/laser3.ogg'
	harmful = TRUE

/obj/item/projectile/beam/aq_gamma
	name = "wiązka gamma"
	icon_state = "xray"
	damage = 5
	damage_type = TOX
	irradiate = 600
	light_color = LIGHT_COLOR_GREEN

/obj/item/mecha_parts/mecha_equipment/weapon/aq_flamethrower
	name = "montowany miotacz ognia"
	desc = "Miotacz ognia na wkład z chemikaliami (Polaris, Baystation). Płomień zależy od mieszanki: paliwo spawalnicze sięga 3 pól, plazma 4, napalm i flogiston 5. Wkład napełnia się, celując w zbiornik albo pojemnik z chemikaliami obok mecha."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "mecha_pyrogun"
	range = MECHA_MELEE | MECHA_RANGED
	equip_cooldown = 20
	energy_drain = 30
	harmful = TRUE
	fire_sound = 'aquila/sound/weapons/flamethrower.ogg'
	var/per_shot = 5

/obj/item/mecha_parts/mecha_equipment/weapon/aq_flamethrower/Initialize(mapload)
	. = ..()
	create_reagents(150, OPENCONTAINER)

/obj/item/mecha_parts/mecha_equipment/weapon/aq_flamethrower/get_equip_info()
	return "[..()] \[[round(reagents.total_volume)]/[reagents.maximum_volume] j.\]"

/obj/item/mecha_parts/mecha_equipment/weapon/aq_flamethrower/proc/flame_range()
	if(reagents.has_reagent(/datum/reagent/napalm) || reagents.has_reagent(/datum/reagent/phlogiston))
		return 5
	if(reagents.has_reagent(/datum/reagent/toxin/plasma))
		return 4
	if(reagents.has_reagent(/datum/reagent/fuel))
		return 3
	return 0

/obj/item/mecha_parts/mecha_equipment/weapon/aq_flamethrower/action(atom/target, params)
	if(!action_checks(target))
		return 0
	if(chassis.Adjacent(target) && target.is_drainable() && target.reagents?.total_volume)
		var/moved = target.reagents.trans_to(src, reagents.maximum_volume - reagents.total_volume)
		occupant_message("<span class='notice'>Napełniasz wkład miotacza ([round(moved)] j.).</span>")
		return 1
	var/dist = flame_range()
	if(!dist || reagents.total_volume < per_shot)
		occupant_message("<span class='warning'>Wkład miotacza jest pusty albo nie ma w nim nic palnego.</span>")
		return 0
	reagents.remove_any(per_shot)
	playsound(chassis, fire_sound, 50, TRUE)
	var/list/turfs = getline(chassis, target)
	var/turf/prev = get_turf(chassis)
	var/count = 0
	for(var/turf/T in turfs)
		if(T == prev)
			continue
		if(T.density || count >= dist)
			break
		if(!prev.CanAtmosPass(T))
			break
		count++
		if(isopenturf(T))
			var/turf/open/O = T
			O.hotspot_expose(1200, 200)
		for(var/mob/living/L in T)
			if(L == chassis.occupant)
				continue
			L.adjust_fire_stacks(2)
			L.IgniteMob()
		prev = T
	chassis.log_message("Fired [src] at [target].", LOG_MECHA)
	return 1

// ---------------------------------------------------------------- wyrzutnie nieśmiercionośne i użytkowe
/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/aq_mkv7
	name = "\improper wyrzutnia ładunków użytkowych MKV-7"
	desc = "Wyrzutnia granatów dymnych i flar (TGMC). Dym zasłania abordaż, flary oświetlają planety nocą. Tryb przełącza się w oknie mecha."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "aq_mkv7"
	projectile = /obj/item/grenade/smokebomb
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	projectiles = 6
	missile_speed = 1.5
	equip_cooldown = 40
	harmful = FALSE
	aq_ammo_cache_max = 12
	var/flare_mode = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/aq_mkv7/aq_allows_working()
	return TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/aq_mkv7/get_equip_info()
	return "[..()] - <a href='byond://?src=[REF(src)];aq_mode=1'>[flare_mode ? "flary" : "dym"]</a>"

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/aq_mkv7/Topic(href, href_list)
	..()
	if(href_list["aq_mode"])
		flare_mode = !flare_mode
		projectile = flare_mode ? /obj/item/flashlight/flare : /obj/item/grenade/smokebomb
		occupant_message("Tryb: [flare_mode ? "flary" : "granaty dymne"].")
		SStgui.update_uis(chassis)

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/aq_mkv7/proj_init(obj/O)
	if(istype(O, /obj/item/grenade))
		var/obj/item/grenade/G = O
		addtimer(CALLBACK(G, TYPE_PROC_REF(/obj/item/grenade, prime)), 2 SECONDS)
	else if(istype(O, /obj/item/flashlight/flare))
		var/obj/item/flashlight/flare/F = O
		F.on = TRUE
		F.update_brightness()
		START_PROCESSING(SSobj, F)

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/aq_bola
	name = "\improper wyrzutnia bol PCMK-6"
	desc = "Wyrzutnia bol oplatających nogi uciekiniera (/vg/station, Paradise). Nieśmiercionośne łapanie dla Paddy i mechów ochrony."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "aq_bola"
	projectile = /obj/item/restraints/legcuffs/bola
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	projectiles = 10
	missile_speed = 2
	equip_cooldown = 20
	harmful = FALSE
	aq_ammo_cache_max = 20

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/aq_bola/aq_allows_working()
	return TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/aq_stinger
	name = "\improper granatnik granatów stinger"
	desc = "Granatnik granatów stinger rażących gumowymi kulkami (Aurora). Nieśmiercionośny granatnik obszarowy dla ochrony."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "aq_stinger"
	projectile = /obj/item/grenade/stingbang
	projectiles = 6
	harmful = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/flashbang/aq_stinger/aq_allows_working()
	return TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/aq_flash
	name = "błysk egzoszkieletu"
	desc = "Obszarowy błysk (Baystation) oślepiający wszystkich wokół mecha bez ochrony oczu. Nieśmiercionośne rozpędzanie tłumu."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "aq_flash"
	range = MECHA_MELEE | MECHA_RANGED
	equip_cooldown = 100
	energy_drain = 300
	harmful = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/aq_flash/aq_allows_working()
	return TRUE

/obj/item/mecha_parts/mecha_equipment/weapon/aq_flash/action(atom/target, params)
	if(!action_checks(target))
		return 0
	playsound(chassis, 'sound/weapons/flash.ogg', 100, TRUE)
	chassis.visible_message("<span class='danger'>[chassis] błyska oślepiającym światłem!</span>")
	for(var/mob/living/carbon/C in viewers(3, chassis))
		if(C == chassis.occupant || C == chassis.aq_copilot)
			continue
		if(C.flash_act(1, 1))
			C.Paralyze(3 SECONDS)
			C.confused += 5
	chassis.log_message("Used [src].", LOG_MECHA)
	return 1

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/aq_forge_cannon
	name = "\improper działo fabrykujące M/FC-8-LF \"Forge\""
	desc = "Działo, które samo wytwarza amunicję z włożonych materiałów (Nova Sector). Żelazo daje 5 pocisków z arkusza, części z kuźni amunicji po 10. Załaduj je, używając ich na mechu."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "aq_forge_cannon"
	equip_cooldown = 12
	projectile = /obj/item/projectile/bullet/aq_forge_slug
	projectiles = 10
	projectiles_per_shot = 1
	fire_sound = 'sound/weapons/gunshot.ogg'
	harmful = TRUE
	aq_ammo_cache = 0
	aq_ammo_cache_max = 100

/obj/item/projectile/bullet/aq_forge_slug
	name = "kulka z fabrykatora"
	damage = 22
	armour_penetration = 10

/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/aq_forge_cannon/proc/aq_feed(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/sheet/iron))
		var/obj/item/stack/sheet/iron/S = I
		var/sheets = min(S.amount, round(aq_cache_space() / 5))
		if(sheets <= 0)
			return 0
		S.use(sheets)
		aq_ammo_cache += sheets * 5
		return sheets * 5
	if(istype(I, /obj/item/munition_part))
		if(aq_cache_space() < 10)
			return 0
		qdel(I)
		aq_ammo_cache += 10
		return 10
	return 0

/obj/mecha/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/sheet/iron) || istype(W, /obj/item/munition_part))
		for(var/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/aq_forge_cannon/forge in equipment)
			var/n = forge.aq_feed(W, user)
			if(n)
				to_chat(user, "<span class='notice'>Działo fabrykujące przerabia materiał na [n] pocisków.</span>")
				playsound(src, 'sound/items/rped.ogg', 40, TRUE)
				return
	return ..()


// ---------------------------------------------------------------- staza
/obj/item/mecha_parts/mecha_equipment/weapon/energy/aq_stasis
	name = "ładunek stazy egzoszkieletu"
	desc = "Moduł z podów (Goonstation): pocisk zamrażający cel w stazie na kilka sekund. Unieruchamia bez obrażeń, przydatny przy pojmaniu boarderów."
	icon = 'aquila/icons/mecha/aq_mecha_equipment.dmi'
	icon_state = "mecha_cryogun"
	equip_cooldown = 80
	energy_drain = 600
	projectile = /obj/item/projectile/energy/aq_stasis
	fire_sound = 'sound/weapons/pulse3.ogg'
	harmful = FALSE

/obj/item/mecha_parts/mecha_equipment/weapon/energy/aq_stasis/aq_allows_working()
	return TRUE

/obj/item/projectile/energy/aq_stasis
	name = "ładunek stazy"
	icon_state = "bluespace"
	damage = 0
	nodamage = TRUE

/obj/item/projectile/energy/aq_stasis/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isliving(target) && blocked < 100)
		var/mob/living/L = target
		L.apply_status_effect(STATUS_EFFECT_STASIS, 6 SECONDS)
		addtimer(CALLBACK(L, TYPE_PROC_REF(/mob/living, remove_status_effect), STATUS_EFFECT_STASIS), 6 SECONDS)
