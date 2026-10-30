/obj/structure/closet/crate/secure
	desc = "Zabezpieczona skrzynia."
	name = "zabezpieczona skrzynia"
	icon_state = "secure_crate"
	secure = TRUE
	locked = TRUE
	max_integrity = 500
	armor = list("melee" = 30, "bullet" = 50, "laser" = 50, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 80, "stamina" = 0, "bleed" = 0)
	var/tamperproof = 0
	icon_door = "crate"

/obj/structure/closet/crate/secure/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == "melee" && damage_amount < 25)
		return 0
	. = ..()

/obj/structure/closet/crate/secure/update_icon()
	..()
	if(broken)
		add_overlay(icon_emagged)
	else if(locked)
		add_overlay(icon_locked)
	else
		add_overlay(icon_unlocked)

/obj/structure/closet/crate/secure/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)
	if(prob(tamperproof) && damage_amount >= DAMAGE_PRECISION)
		boom()
	else
		return ..()


/obj/structure/closet/crate/secure/proc/boom(mob/user)
	if(user)
		to_chat(user, "<span class='danger'>Aktywuje się system antymanipulacyjny skrzyni!</span>")
		log_bomber(user, "has detonated a", src)
	for(var/obj/loot in src)
		SSexplosions.high_mov_atom += loot
	explosion(get_turf(src), 0, 1, 5, 5)
	qdel(src)

/obj/structure/closet/crate/secure/weapon
	desc = "Zabezpieczona skrzynia z bronią."
	name = "skrzynia z bronią"
	icon_state = "weapon_crate"
	icon_door = null
	icon_door_override = FALSE

/obj/structure/closet/crate/secure/plasma
	desc = "Zabezpieczona skrzynia z plazmą."
	name = "skrzynia z plazmą"
	icon_state = "plasma_crate"
	icon_door = null
	icon_door_override = FALSE

/obj/structure/closet/crate/secure/gear
	desc = "Zabezpieczona skrzynia ze sprzętem."
	name = "skrzynia ze sprzętem"
	icon_state = "secgear_crate"
	icon_door = null
	icon_door_override = FALSE

/obj/structure/closet/crate/secure/hydroponics
	desc = "Zamykana skrzynia pomalowana w barwach stacyjnych botaników."
	name = "zabezpieczona skrzynia hydroponiczna"
	icon_state = "hydro_secure_crate"
	icon_door = null
	icon_door_override = FALSE

/obj/structure/closet/crate/secure/freezer //for consistency with other "freezer" closets/crates
	desc = "Izolowana, zamykana skrzynia do zabezpieczania łatwo psującej się żywności."
	name = "zabezpieczona skrzynia kuchenna"
	icon_state = "kitchen_secure_crate"
	icon_door_override = TRUE

/obj/structure/closet/crate/secure/freezer/pizza
	name = "zabezpieczona skrzynia na pizzę"
	desc = "Izolowana, zamykana skrzynia do zabezpieczania pizzy."
	req_access = list(28)
	tamperproof = 10

/obj/structure/closet/crate/secure/freezer/pizza/PopulateContents()
	. = ..()
	new /obj/effect/spawner/lootdrop/pizzaparty(src)

/obj/structure/closet/crate/secure/engineering
	desc = "Zamykana skrzynia pomalowana w barwach stacyjnych inżynierów."
	name = "zabezpieczona skrzynia inżynieryjna"
	icon_state = "engi_secure_crate"
	icon_door = "engi_secure_crate"

/obj/structure/closet/crate/secure/science
	name = "zabezpieczona skrzynia naukowa"
	desc = "Zamykana skrzynia pomalowana w barwach stacyjnych naukowców."
	icon_state = "sci_secure_crate"
	icon_door = "sci_secure_crate"

/obj/structure/closet/crate/secure/owned
	name = "prywatna skrzynia"
	desc = "Pokrywa skrzyni, która otwiera się tylko przed tym, kto kupił jej zawartość."
	icon_state = "private_crate"
	icon_door = null
	icon_door_override = FALSE
	//Account of the person buying the crate if private purchasing.
	var/datum/bank_account/buyer_account
	//Department of the person buying the crate if buying via the NIRN app.
	var/datum/bank_account/department/department_account
	//Is the secure crate opened or closed?
	var/privacy_lock = TRUE
	//Is the crate being bought by a person, or a budget card?
	var/department_purchase = FALSE

/obj/structure/closet/crate/secure/owned/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Jest zamknięta na zamek prywatności i można ją otworzyć tylko kartą ID kupującego z wymaganym dostępem.</span>"

/obj/structure/closet/crate/secure/owned/Initialize(mapload, datum/bank_account/_buyer_account)
	. = ..()
	buyer_account = _buyer_account
	if(istype(buyer_account, /datum/bank_account/department))
		department_purchase = TRUE
		department_account = buyer_account

/obj/structure/closet/crate/secure/owned/togglelock(mob/living/user, silent)
	if(privacy_lock)
		if(!broken)
			var/obj/item/card/id/id_card = user.get_idcard(TRUE)
			if(id_card)
				if(id_card.registered_account)
					if(id_card.registered_account == buyer_account || (department_purchase && (id_card.registered_account?.account_job?.paycheck_department) == (department_account.department_id)))
						if(allowed(user))
							if(iscarbon(user))
								add_fingerprint(user)
							locked = !locked
							user.visible_message("<span class='notice'>[user] otwiera zamek prywatności [src].</span>",
											"<span class='notice'>Otwierasz zamek prywatności [src].</span>")
							privacy_lock = FALSE
							update_icon()
						else if(!silent)
							to_chat(user, "<span class='notice'>Odmowa dostępu, karta ID ma niewystarczający dostęp.</span>")
					else if(!silent)
						to_chat(user, "<span class='notice'>Konto bankowe nie zgadza się z kupującym!</span>")
				else if(!silent)
					to_chat(user, "<span class='notice'>Nie wykryto połączonego konta bankowego!</span>")
			else if(!silent)
				to_chat(user, "<span class='notice'>Nie wykryto karty ID!</span>")
		else if(!silent)
			to_chat(user, "<span class='warning'>[src] jest zepsuta!</span>")
	else ..()
