/obj/item/gun/magic/staff
	slot_flags = ITEM_SLOT_BACK
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	item_flags = NEEDS_PERMIT | NO_MAT_REDEMPTION
	weapon_weight = WEAPON_MEDIUM
	fire_rate = 1.5
	block_power = 20 //staffs can block shit if you're walking
	block_upgrade_walk = 1

/obj/item/gun/magic/staff/change
	name = "laska przemiany"
	desc = "Artefakt plujący pociskami migoczącej energii, które przekształcają samą postać celu."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/change
	icon_state = "staffofchange"
	item_state = "staffofchange"

/obj/item/gun/magic/staff/animate
	name = "laska ożywienia"
	desc = "Artefakt plujący pociskami siły życiowej, które ożywiają trafione przedmioty! Ta magia nie działa na maszyny."
	fire_sound = 'sound/magic/staff_animation.ogg'
	ammo_type = /obj/item/ammo_casing/magic/animate
	icon_state = "staffofanimation"
	item_state = "staffofanimation"

/obj/item/gun/magic/staff/healing
	name = "laska uzdrowienia"
	desc = "Artefakt plujący pociskami odnawiającej magii, które leczą wszelkie dolegliwości, a nawet wskrzeszają zmarłych."
	fire_sound = 'sound/magic/staff_healing.ogg'
	ammo_type = /obj/item/ammo_casing/magic/heal
	icon_state = "staffofhealing"
	item_state = "staffofhealing"

/obj/item/gun/magic/staff/healing/handle_suicide() //Stops people trying to commit suicide to heal themselves
	return

/obj/item/gun/magic/staff/chaos
	name = "laska chaosu"
	desc = "Artefakt plujący pociskami chaotycznej magii, które mogą zrobić właściwie wszystko."
	fire_sound = 'sound/magic/staff_chaos.ogg'
	ammo_type = /obj/item/ammo_casing/magic/chaos
	icon_state = "staffofchaos"
	item_state = "staffofchaos"
	max_charges = 10
	recharge_rate = 2
	no_den_usage = 1
	var/allowed_projectile_types = list(/obj/item/projectile/magic/change, /obj/item/projectile/magic/animate, /obj/item/projectile/magic/resurrection,
	/obj/item/projectile/magic/death, /obj/item/projectile/magic/teleport, /obj/item/projectile/magic/door, /obj/item/projectile/magic/fireball,
	/obj/item/projectile/magic/spellblade, /obj/item/projectile/magic/arcane_barrage, /obj/item/projectile/magic/locker, /obj/item/projectile/magic/flying,
	/obj/item/projectile/magic/bounty, /obj/item/projectile/magic/antimagic, /obj/item/projectile/magic/fetch, /obj/item/projectile/magic/sapping,
	/obj/item/projectile/magic/necropotence, /obj/item/projectile/magic, /obj/item/projectile/temp/chill, /obj/item/projectile/magic/wipe)

/obj/item/gun/magic/staff/chaos/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	chambered.projectile_type = pick(allowed_projectile_types)
	. = ..()

/obj/item/gun/magic/staff/door
	name = "laska tworzenia drzwi"
	desc = "Artefakt plujący pociskami przemieniającej magii, które tworzą drzwi w ścianach."
	fire_sound = 'sound/magic/staff_door.ogg'
	ammo_type = /obj/item/ammo_casing/magic/door
	icon_state = "staffofdoor"
	item_state = "staffofdoor"
	max_charges = 10
	recharge_rate = 2
	no_den_usage = 1

/obj/item/gun/magic/staff/honk
	name = "laska Honkmatki"
	desc = "Honk."
	fire_sound = 'sound/items/airhorn.ogg'
	ammo_type = /obj/item/ammo_casing/magic/honk
	icon_state = "honker"
	item_state = "honker"
	max_charges = 4
	recharge_rate = 8

/obj/item/gun/magic/staff/spellblade
	name = "zaklęte ostrze"
	desc = "Zabójcze połączenie lenistwa i żądzy krwi. To ostrze pozwala ćwiartować wrogów bez całej tej ciężkiej pracy z wymachiwaniem mieczem."
	fire_sound = 'sound/magic/fireball.ogg'
	ammo_type = /obj/item/ammo_casing/magic/spellblade
	icon_state = "spellblade"
	item_state = "spellblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	hitsound = 'sound/weapons/rapierhit.ogg'
	force = 20
	bleed_force = BLEED_DEEP_WOUND
	armour_penetration = 75
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY | BLOCKING_PROJECTILE
	sharpness = IS_SHARP
	max_charges = 4

/obj/item/gun/magic/staff/spellblade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 15, 125, 0, hitsound)

/obj/item/gun/magic/staff/spellblade/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "atak", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == PROJECTILE_ATTACK)
		final_block_chance = 0
	return ..()

/obj/item/gun/magic/staff/locker
	name = "laska szafki"
	desc = "Artefakt wyrzucający zamykające pociski, by unieszkodliwić twego wroga."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/locker
	icon_state = "locker"
	item_state = "locker"
	max_charges = 6
	recharge_rate = 4

//yes, they don't have sounds. they're admin staves, and their projectiles will play the chaos bolt sound anyway so why bother?

/obj/item/gun/magic/staff/flying
	name = "laska lotu"
	desc = "Artefakt plujący pociskami pełnej gracji magii, które potrafią sprawić, że coś poleci."
	fire_sound = 'sound/magic/staff_healing.ogg'
	ammo_type = /obj/item/ammo_casing/magic/flying
	icon_state = "staffofflight"
	item_state = "staffofflight"

/obj/item/gun/magic/staff/sapping
	name = "laska wysysania"
	desc = "Artefakt plujący pociskami wysysającej magii, które potrafią coś zasmucić."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/sapping
	icon_state = "staffofsapping"
	item_state = "staffofsapping"

/obj/item/gun/magic/staff/necropotence
	name = "laska nekropotencji"
	desc = "Artefakt plujący pociskami magii śmierci, które potrafią nadać duszy nowe przeznaczenie."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/necropotence
	icon_state = "staffofnecropotence"
	item_state = "staffofnecropotence"

/obj/item/gun/magic/staff/wipe
	name = "laska opętania"
	desc = "Artefakt plujący pociskami otwierającej umysł magii, przez które duchy mogą wtargnąć do umysłu ofiary."
	fire_sound = 'sound/magic/staff_change.ogg'
	ammo_type = /obj/item/ammo_casing/magic/wipe
	icon_state = "staffofwipe"
	item_state = "staffofwipe"
