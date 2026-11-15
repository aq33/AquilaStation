// AQUILA - amunicja klasy I z kuźni: wykuta automatycznie pod młotem mechanicznym, bez ręcznego wykańczania.
// Broń ręczna: trzy razy szybsze zużycie (gunplay/condition.dm) i szansa na zacięcie, które usuwa użycie broni w ręce.
// Broń okrętowa: każdy strzał zjada dodatkowe punkty do konserwacji, a czasem od razu wywołuje usterkę (smarowanie olejem).
// Amunicja z cargo i pokryta w galwanizerze nie jest „surowa”, więc nic z tego jej nie dotyczy.

/// Szansa na zacięcie broni ręcznej po strzale amunicją klasy I (procent)
#define AQ_ROUGH_JAM_CHANCE 5
/// Ile razy szybciej amunicja klasy I zużywa broń ręczną
#define AQ_ROUGH_WEAR_MULT 3
/// Ile dodatkowych punktów maint_req zjada strzał z działa amunicją klasy I
#define AQ_ROUGH_SHIP_WEAR 2
/// Szansa na usterkę działa po strzale amunicją klasy I (procent)
#define AQ_ROUGH_SHIP_MALFUNCTION_CHANCE 5

/// Wyrób z kuźni klasy I (nie galwanizowany)
/proc/aq_is_rough_munition(atom/thing)
	if(!thing)
		return FALSE
	var/datum/component/forged_munition/forged = thing.GetComponent(/datum/component/forged_munition)
	return forged && !forged.galvanized && forged.quality?.level == 0

/obj/item/gun
	/// Zacięcie po amunicji klasy I: broń nie strzela, dopóki właściciel jej nie odblokuje (użycie w ręce)
	var/aq_jammed = FALSE

/obj/item/gun/add_wear(obj/item/ammo_casing/casing)
	var/before = gun_wear
	. = ..()
	if(aq_is_rough_munition(casing))
		gun_wear = min(before + (gun_wear - before) * AQ_ROUGH_WEAR_MULT, 100)

/obj/item/gun/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
	var/obj/item/ammo_casing/fired = chambered
	. = ..()
	if(aq_is_rough_munition(fired) && prob(AQ_ROUGH_JAM_CHANCE))
		aq_jammed = TRUE
		if(user)
			balloon_alert(user, "zacięcie!")
			to_chat(user, "<span class='warning'>[src] się zacina! Użyj broni w ręce, żeby ją odblokować.</span>")

/obj/item/gun/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0, aimed = FALSE)
	if(aq_jammed)
		if(user)
			balloon_alert(user, "zacięta!")
		playsound(src, dry_fire_sound, 20, TRUE)
		return FALSE
	return ..()

/obj/item/gun/ballistic/attack_self(mob/living/user)
	if(aq_jammed)
		aq_jammed = FALSE
		to_chat(user, "<span class='notice'>Szarpiesz zamek i usuwasz zacięcie z [src].</span>")
		playsound(src, rack_sound, rack_sound_volume, rack_sound_vary)
		return
	return ..()

/obj/item/gun/examine(mob/user)
	. = ..()
	if(aq_jammed)
		. += "<span class='warning'>Jest zacięta. Użyj jej w ręce, żeby ją odblokować.</span>"

/obj/machinery/ship_weapon/local_fire()
	if(maintainable && aq_is_rough_munition(chambered))
		maint_req = max(0, maint_req - AQ_ROUGH_SHIP_WEAR)
		if(prob(AQ_ROUGH_SHIP_MALFUNCTION_CHANCE))
			weapon_malfunction()
	return ..()

#undef AQ_ROUGH_JAM_CHANCE
#undef AQ_ROUGH_WEAR_MULT
#undef AQ_ROUGH_SHIP_WEAR
#undef AQ_ROUGH_SHIP_MALFUNCTION_CHANCE
