// AQUILA - IFF drużyn i inteligentna amunicja.
// IFF (wzór: TGMC iff_signal, CM bullet_trait_iff): kula wystrzelona przez członka drużyny przelatuje przez osoby,
// które noszą smycz tej samej drużyny (/obj/item/clothing/neck/squad, wydawana z konsoli drużyn). Kliknięta bezpośrednio
// osoba zostaje trafiona (odwrotnie niż w Novie, gdzie IFF przepuszcza nawet klikniętego sojusznika).
// Inteligentna amunicja (wzór: /vg/ pociski śledzące, tg homing): kula namierza moba klikniętego przy strzale i skręca
// do niego, dopóki go widzi. Badania: węzeł „Zaawansowana technologia rozwoju broni”.

/obj/item/projectile
	/// Drużyna strzelca: kula nie trafia osób ze smyczą tej drużyny, chyba że to kliknięty cel
	var/datum/squad/iff_squad

/obj/item/projectile/Destroy()
	iff_squad = null
	return ..()

/obj/item/gun/setup_fired_projectile(obj/item/projectile/projectile)
	. = ..()
	if(ishuman(projectile.firer))
		var/mob/living/carbon/human/shooter = projectile.firer
		if(shooter.squad)
			projectile.iff_squad = shooter.squad

/// Czy ta osoba nosi smycz drużyny strzelca
/obj/item/projectile/proc/is_iff_friend(atom/target)
	if(!iff_squad || !ishuman(target))
		return FALSE
	var/mob/living/carbon/human/H = target
	var/obj/item/clothing/neck/squad/lanyard = H.wear_neck
	return istype(lanyard) && lanyard.squad == iff_squad

/obj/item/projectile/can_hit_target(atom/target, direct_target = FALSE, ignore_loc = FALSE, cross_failed = FALSE)
	. = ..()
	if(. && !direct_target && target != original && is_iff_friend(target))
		return FALSE

/obj/item/clothing/neck/squad/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Działa też jako znacznik IFF: kule członków tej drużyny omijają noszącego, chyba że ktoś celuje prosto w niego.</span>"

// --- Inteligentna amunicja 9mm ---

/obj/item/projectile/bullet/c9mm/smart
	name = "pocisk 9mm inteligentny"
	damage = 15
	homing_turn_speed = 9
	homing_delay = 0

/obj/item/projectile/bullet/c9mm/smart/fire(angle, atom/direct_target)
	if(isliving(original) && original != firer)
		set_homing_target(original)
	return ..()

/obj/item/projectile/bullet/c9mm/smart/process_homing()
	// Gubi cel, którego nie widzi (za ścianą, za rogiem poza zasięgiem wzroku)
	// can_see() idzie linią i patrzy tylko na nieprzezroczyste kafle: view() z kafla nie widział celu w ciemności,
	// a liczone co odcinek lotu kosztowało widok 15×15 kafli
	if(QDELETED(homing_target) || homing_target.z != z || get_dist(src, homing_target) > 7 || !can_see(get_turf(src), homing_target, 7))
		homing = FALSE
		homing_target = null
		return FALSE
	return ..()

/obj/item/ammo_casing/c9mm/smart
	name = "łuska 9mm inteligentna"
	desc = "Nabój 9mm z mikroprocesorem i lotkami w pocisku. Kula skręca do celu, który kliknięto przy strzale."
	projectile_type = /obj/item/projectile/bullet/c9mm/smart

/obj/item/ammo_box/magazine/glock/smart
	name = "magazynek P99 na amunicję inteligentną"
	desc = "Magazynek z nabojami 9mm z naprowadzaniem. Pociski skręcają do celu, w który mierzyłeś, dopóki go widzą."
	icon_state = "Glock-lethal"
	ammo_type = /obj/item/ammo_casing/c9mm/smart

/datum/design/aq_smart_9mm
	name = "Magazynek P99 (9mm inteligentne)"
	desc = "Pociski skręcają do celu klikniętego przy strzale, dopóki go widzą."
	id = "aq_smart_9mm"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 6000, /datum/material/silver = 2000, /datum/material/gold = 1000, /datum/material/glass = 1000)
	build_path = /obj/item/ammo_box/magazine/glock/smart
	category = list("Ammo")
	departmental_flags = DEPARTMENTAL_FLAG_SECURITY

/datum/techweb_node/adv_weaponry/New()
	. = ..()
	design_ids += "aq_smart_9mm"
