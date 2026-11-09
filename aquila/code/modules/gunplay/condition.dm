// AQUILA - stan broni: powolne zużycie, mnożniki broni dla pocisku, przegrzanie, niewypały i zestaw konserwacji.
// - Zużycie (wzór: Shiptest gun_wear, ale bez zacięć): każdy strzał dodaje trochę zużycia, mocniejszy kaliber więcej.
//   Stan techniczny = 100% - zużycie i działa jak w tg (ready_proj(): integrity_mult = 0,5 + 0,5 × stan):
//   zaniedbana broń daje słabsze i wolniejsze kule.
// - Mnożniki broni dla pocisku (tg projectile_damage_multiplier, projectile_speed_multiplier, projectile_wound_bonus).
// - Przegrzanie (wzór: Monkestation microfusion heat, Nova MG): tylko broń energetyczna i ciężkie karabiny maszynowe.
//   Powyżej 80% ciepła rośnie rozrzut, przy 100% broń blokuje się do ostygnięcia i parzy dłoń bez rękawic.
// - Niewypał z jakości naboju (wzór: Coolstation dud_freq): suchy klik, nabój zostaje w komorze, trzeba przeładować.
//   Co dziesiąty niewypał to przewlekły wystrzał: klik, a pół sekundy później strzał.
// - Rozrzut prędkości kul ±15% (wzór: CM), żeby seria nie leciała sznurkiem.
// - Kule z broni ręcznej lecą półtora raza szybciej niż fabryczne 0,8 ds na kratkę (prośba z testu: „trochę szybsze”).

/// Szansa na niewypał zwykłego fabrycznego naboju (procent)
#define AQ_FACTORY_MISFIRE_CHANCE 0.3
/// Ciepło, poniżej którego przegrzana broń znowu strzela
#define AQ_OVERHEAT_RECOVERY 0.3
/// Przyspieszenie kul z broni ręcznej (pociski energetyczne i działa okrętowe bez zmian)
#define AQ_HANDGUN_BULLET_SPEED_MULT 1.5

/obj/item/gun
	/// Zużycie broni 0-100 (stan techniczny = 100 - zużycie)
	var/gun_wear = 0
	/// Mnożnik zużycia dla tej broni (prosta i solidna broń zużywa się wolniej)
	var/wear_multiplier = 1
	/// Mnożniki pocisku wystrzelonego z tej broni (tg)
	var/projectile_damage_multiplier = 1
	var/projectile_speed_multiplier = 1
	var/projectile_wound_bonus = 0
	/// Aktualne ciepło
	var/gun_heat = 0
	/// Maks. ciepło; 0 = broń się nie grzeje
	var/max_heat = 0
	/// Ciepło na strzał
	var/heat_per_shot = 0
	/// Ile ciepła oddaje na sekundę
	var/heat_dissipation = 0
	/// Broń przegrzana: nie strzela, aż ostygnie
	var/overheated = FALSE
	/// Timer chłodzenia
	var/heat_timer
	/// Przewlekły wystrzał: następny process_fire() nie losuje niewypału
	var/skip_misfire_roll = FALSE

// Przegrzanie: broń energetyczna i ciężkie karabiny maszynowe
/obj/item/gun/energy
	max_heat = 100
	heat_per_shot = 8
	heat_dissipation = 12

/obj/item/gun/ballistic/automatic/l6_saw
	max_heat = 100
	heat_per_shot = 3
	heat_dissipation = 6

/obj/item/ammo_casing
	/// Szansa na niewypał (procent); null = fabryczna albo z jakości kuźni
	var/misfire_chance

/obj/item/ammo_casing/energy
	misfire_chance = 0

/obj/item/ammo_casing/caseless
	misfire_chance = 0

/// Szansa na niewypał tego naboju: fabryczny 0,3%, z kuźni zależnie od klasy, ręcznie robiony więcej
/obj/item/ammo_casing/proc/get_misfire_chance()
	if(!isnull(misfire_chance))
		return misfire_chance
	var/datum/component/forged_munition/forged = GetComponent(/datum/component/forged_munition)
	if(forged && !forged.galvanized)
		// klasa I (bonus 1) 2%, każda wyższa klasa mniej, mistrzowska prawie nigdy
		return max(0.1, 2 - (forged.quality.bonus - 1) * 9.5)
	return AQ_FACTORY_MISFIRE_CHANCE

/obj/item/gun/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_PROJECTILE_BEFORE_FIRE, PROC_REF(on_projectile_before_fire))

/obj/item/gun/Destroy()
	if(heat_timer)
		deltimer(heat_timer)
		heat_timer = null
	return ..()

/// Stan techniczny 0-100
/obj/item/gun/proc/get_condition()
	return clamp(100 - gun_wear, 0, 100)

/obj/item/gun/proc/get_heat_fraction()
	return max_heat ? clamp(gun_heat / max_heat, 0, 1) : 0

/// Pocisk wylatuje z tej broni: mnożniki broni, stan techniczny i rozrzut prędkości
/obj/item/gun/proc/on_projectile_before_fire(datum/source, obj/item/projectile/projectile, atom/original_target)
	SIGNAL_HANDLER
	if(!istype(projectile) || projectile.aq_gun_modifiers_applied)
		return
	projectile.aq_gun_modifiers_applied = TRUE
	var/integrity_mult = 0.5 + 0.5 * get_condition() / 100
	projectile.damage *= projectile_damage_multiplier * integrity_mult
	projectile.stamina *= integrity_mult
	if(projectile.speed > 0)
		var/speed_mult = projectile_speed_multiplier * integrity_mult
		if(projectile.flag == "bullet" && !projectile.hitscan)
			speed_mult *= AQ_HANDGUN_BULLET_SPEED_MULT * rand(85, 115) / 100 // seria nie leci sznurkiem (CM)
		if(speed_mult > 0)
			projectile.speed /= speed_mult // speed to czas na kratkę
	if(projectile_wound_bonus && projectile.wound_bonus != CANT_WOUND)
		projectile.wound_bonus += projectile_wound_bonus
	setup_fired_projectile(projectile)

/obj/item/projectile
	/// Broń już dołożyła swoje mnożniki (śrut i przypadkowe strzały nie liczą ich dwa razy)
	var/aq_gun_modifiers_applied = FALSE

/obj/item/gun/before_firing(atom/target, mob/user, aimed)
	. = ..()
	if(!chambered?.BB)
		return
	if(skip_misfire_roll)
		skip_misfire_roll = FALSE
		return
	if(!prob(chambered.get_misfire_chance()))
		return
	var/obj/item/ammo_casing/dud_casing = chambered
	if(prob(10))
		// Przewlekły wystrzał: klik, a za pół sekundy strzał
		var/obj/item/projectile/held_projectile = dud_casing.BB
		dud_casing.BB = null
		if(user)
			balloon_alert(user, "klik...")
		addtimer(CALLBACK(src, PROC_REF(hang_fire), dud_casing, held_projectile, target, user), 0.5 SECONDS)
		return
	// Niewypał: pocisk zostaje w łusce, ale nabój jest martwy; process_fire() kliknie i nie przeładuje
	QDEL_NULL(dud_casing.BB)
	dud_casing.name = "niewypał"
	dud_casing.desc = "Nabój, który nie wystrzelił. Spłonka jest wgnieciona."
	if(user)
		balloon_alert(user, "niewypał! przeładuj")

/obj/item/gun/proc/hang_fire(obj/item/ammo_casing/casing, obj/item/projectile/held_projectile, atom/target, mob/living/user)
	if(QDELETED(held_projectile))
		return
	if(QDELETED(casing) || chambered != casing || casing.BB || QDELETED(user))
		qdel(held_projectile)
		return
	casing.BB = held_projectile
	skip_misfire_roll = TRUE
	if(get_dist(user, target) > 20 || target?.z != user.z)
		target = get_ranged_target_turf(user, user.dir, 7)
	process_fire(target, user, TRUE)

/obj/item/gun/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
	. = ..()
	add_wear(chambered)
	add_heat()

/// Każdy strzał trochę zużywa broń (mocniejszy kaliber szybciej)
/obj/item/gun/proc/add_wear(obj/item/ammo_casing/casing)
	var/strength = casing ? casing.get_recoil_strength() : 3
	gun_wear = min(gun_wear + strength * 0.02 * wear_multiplier, 100)

/obj/item/gun/proc/add_heat()
	if(!max_heat || !heat_per_shot)
		return
	gun_heat += heat_per_shot
	if(!heat_timer)
		heat_timer = addtimer(CALLBACK(src, PROC_REF(cool_down)), 1 SECONDS, TIMER_STOPPABLE | TIMER_LOOP)
	if(gun_heat >= max_heat && !overheated)
		overheated = TRUE
		var/mob/living/holder = loc
		if(istype(holder))
			balloon_alert(holder, "przegrzana!")
			to_chat(holder, "<span class='warning'>[src] jest rozgrzana do czerwoności i nie strzela, dopóki nie ostygnie.</span>")
			burn_holder_hand(holder)
		playsound(src, 'sound/items/welder.ogg', 30, TRUE)
	update_icon()

/obj/item/gun/proc/burn_holder_hand(mob/living/carbon/holder)
	if(!istype(holder) || holder.gloves)
		return
	var/obj/item/bodypart/hand = holder.get_holding_bodypart_of_item(src)
	holder.apply_damage(5, BURN, hand)
	to_chat(holder, "<span class='danger'>[src] parzy cię w dłoń!</span>")

/obj/item/gun/proc/cool_down()
	gun_heat = max(gun_heat - heat_dissipation, 0)
	if(overheated && gun_heat <= max_heat * AQ_OVERHEAT_RECOVERY)
		overheated = FALSE
		if(isliving(loc))
			balloon_alert(loc, "ostygła")
	if(gun_heat <= 0)
		deltimer(heat_timer)
		heat_timer = null
	if(isliving(loc))
		var/mob/living/holder = loc
		holder.update_ammo_hud()

/obj/item/gun/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0, aimed = FALSE)
	if(overheated)
		if(user)
			balloon_alert(user, "przegrzana!")
		playsound(src, dry_fire_sound, 20, TRUE)
		return FALSE
	return ..()

/obj/item/gun/get_dynamic_spread(mob/living/user)
	. = ..()
	var/heat_fraction = get_heat_fraction()
	if(heat_fraction > 0.8)
		. += (heat_fraction - 0.8) * 50 // do +10° przy pełnym przegrzaniu

/// Stan techniczny słownie
/obj/item/gun/proc/condition_text()
	switch(get_condition())
		if(90 to 100)
			return "zadbana"
		if(70 to 90)
			return "lekko zużyta"
		if(45 to 70)
			return "zabrudzona"
		if(20 to 45)
			return "mocno zużyta"
	return "w opłakanym stanie"

/obj/item/gun/examine(mob/user)
	. = ..()
	if(shows_ammo_hud())
		. += "<span class='notice'>Stan techniczny: <b>[condition_text()]</b>.</span>"
	if(max_heat && gun_heat > max_heat * 0.5)
		. += "<span class='warning'>Lufa jest [overheated ? "rozgrzana do czerwoności" : "gorąca"].</span>"

// --- Zestaw konserwacji ---

/obj/item/gun_maintenance_kit
	name = "zestaw konserwacji broni"
	desc = "Wyciory, szczoteczki, smar i szmatki. Czyści i smaruje broń palną i energetyczną, przywracając jej sprawność."
	icon = 'aquila/icons/obj/gun_maintenance_kit.dmi'
	icon_state = "kit"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(/datum/material/iron = 500, /datum/material/plastic = 500)
	/// Ile razy jeszcze można go użyć
	var/uses = 5
	/// Ile zużycia zdejmuje jedno czyszczenie
	var/wear_removed = 60

/obj/item/gun_maintenance_kit/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Wystarczy jeszcze na [uses] [uses == 1 ? "czyszczenie" : (uses < 5 ? "czyszczenia" : "czyszczeń")].</span>"

/obj/item/gun_maintenance_kit/pre_attack(atom/target, mob/living/user, params)
	if(!istype(target, /obj/item/gun))
		return ..()
	clean_gun(target, user)
	return FALSE

/obj/item/gun_maintenance_kit/proc/clean_gun(obj/item/gun/target_gun, mob/living/user)
	if(uses <= 0)
		balloon_alert(user, "zestaw jest pusty")
		return
	if(target_gun.gun_wear <= 0)
		balloon_alert(user, "broń jest czysta")
		return
	if(target_gun.gun_heat > 0)
		balloon_alert(user, "broń jest jeszcze gorąca")
		return
	user.visible_message("<span class='notice'>[user] rozkłada [target_gun] i zaczyna ją czyścić.</span>", "<span class='notice'>Rozkładasz [target_gun] i zaczynasz ją czyścić.</span>")
	if(!do_after(user, 10 SECONDS, target = target_gun))
		return
	finish_cleaning(target_gun, user)

/obj/item/gun_maintenance_kit/proc/finish_cleaning(obj/item/gun/target_gun, mob/living/user)
	uses--
	target_gun.gun_wear = max(target_gun.gun_wear - wear_removed, 0)
	user.visible_message("<span class='notice'>[user] kończy czyścić [target_gun].</span>", "<span class='notice'>[target_gun] jest teraz [target_gun.condition_text()].</span>")
	playsound(target_gun, 'sound/weapons/gun_magazine_insert_empty_1.ogg', 40, TRUE)
	if(uses <= 0)
		to_chat(user, "<span class='warning'>[src] jest już zużyty.</span>")
		qdel(src)

#undef AQ_FACTORY_MISFIRE_CHANCE
#undef AQ_OVERHEAT_RECOVERY
#undef AQ_HANDGUN_BULLET_SPEED_MULT

// Zestaw konserwacji w pudełku drużyny, gdy zestaw zawiera broń (nie wchodzi do listy zwrotów, więc zużyty zestaw nie daje grzywny)
/obj/machinery/squad_vendor/ui_act(action, params)
	var/datum/squad_loadout/loadout = action == "vend" ? locate(params["item_id"]) : null
	. = ..()
	if(!. || !istype(loadout))
		return
	var/has_gun = FALSE
	for(var/path in loadout.items)
		if(ispath(path, /obj/item/gun))
			has_gun = TRUE
			break
	if(!has_gun)
		return
	for(var/obj/item/storage/box/squad_kit/box in get_turf(src))
		if(!(locate(/obj/item/gun_maintenance_kit) in box))
			new /obj/item/gun_maintenance_kit(box)
