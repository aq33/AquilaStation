/obj/item/shrapnel // frag grenades
	name = "odłamek szrapnela"
	embedding = list(embed_chance=70, ignore_throwspeed_threshold=TRUE, fall_chance=4)
	custom_materials = list(/datum/material/iron=50)
	armour_penetration = -20
	icon = 'icons/obj/shards.dmi'
	icon_state = "large"
	w_class = WEIGHT_CLASS_TINY
	item_flags = DROPDEL

/obj/item/shrapnel/stingball // stingbang grenades
	name = "kulka gumowa"
	embedding = list(embed_chance=90, fall_chance=3, jostle_chance=7, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.7, pain_mult=5, jostle_pain_mult=6, rip_time=15)
	icon_state = "tiny"

/obj/item/shrapnel/bullet // bullets
	name = "pocisk"
	icon = 'icons/obj/ammo.dmi'
	icon_state = "s-casing"
	item_flags = NONE

/obj/item/shrapnel/bullet/c38 // .38 round
	name = "\improper pocisk .38"

/obj/item/shrapnel/bullet/c38/dumdum // .38 DumDum round
	name = "\improper pocisk .38 DumDum"
	embedding = list(embed_chance=70, fall_chance=7, jostle_chance=7, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.4, pain_mult=5, jostle_pain_mult=6, rip_time=10)

/obj/item/projectile/bullet/shrapnel
	bleed_force = BLEED_SURFACE
	name = "lecący odłamek szrapnela"
	damage = 9
	range = 10
	armour_penetration = -30
	dismemberment = 5
	ricochets_max = 2
	ricochet_chance = 40
	shrapnel_type = /obj/item/shrapnel
	ricochet_incidence_leeway = 60
	hit_stunned_targets = TRUE

/obj/item/projectile/bullet/shrapnel/mega
	bleed_force = BLEED_CUT
	name = "lecący kawał szrapnela"
	range = 25
	dismemberment = 10
	ricochets_max = 4
	ricochet_chance = 90
	ricochet_decay_chance = 0.9

/obj/item/projectile/bullet/pellet/stingball
	name = "śrucina kulki gumowej"
	damage = 3
	stamina = 8
	ricochets_max = 4
	ricochet_chance = 66
	ricochet_decay_chance = 1
	ricochet_decay_damage = 0.9
	ricochet_auto_aim_angle = 10
	ricochet_auto_aim_range = 2
	ricochet_incidence_leeway = 0
	shrapnel_type = /obj/item/shrapnel/stingball

/obj/item/projectile/bullet/pellet/stingball/mega
	name = "śrucina megakulki gumowej"
	ricochets_max = 6
	ricochet_chance = 110

/obj/item/projectile/bullet/pellet/stingball/on_ricochet(atom/A)
	hit_stunned_targets = TRUE // ducking will save you from the first wave, but not the rebounds
