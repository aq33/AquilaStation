/obj/item/ammo_casing/syringegun
	name = "sprężyna wyrzutni strzykawek"
	desc = "Mocna sprężyna, która wyrzuca strzykawki."
	projectile_type = /obj/item/projectile/bullet/dart/syringe
	firing_effect_type = null

/obj/item/ammo_casing/syringegun/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	if(!BB)
		return
	if(istype(loc, /obj/item/gun/syringe))
		var/obj/item/gun/syringe/SG = loc
		if(!SG.syringes.len)
			return

		var/obj/item/reagent_containers/syringe/S = SG.syringes[1]
		BB.name = S.name
		var/obj/item/projectile/bullet/dart/D = BB
		D.piercing = S.proj_piercing
		SG.syringes.Remove(S)
		S.forceMove(BB)
		D.syringe = S
	..()

/obj/item/ammo_casing/chemgun
	name = "syntezator strzałek"
	desc = "Mocna sprężyna połączona z energetycznym syntezatorem strzałek."
	projectile_type = /obj/item/projectile/bullet/dart
	firing_effect_type = null

/obj/item/ammo_casing/chemgun/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	if(!BB)
		return
	if(istype(loc, /obj/item/gun/chem))
		var/obj/item/gun/chem/CG = loc
		if(CG.syringes_left <= 0)
			return
		CG.reagents.trans_to(BB, 15, transfered_by = user)
		BB.name = "strzałka chemiczna"
		CG.syringes_left--
	..()

/obj/item/ammo_casing/bee
	name = "syntezator pszczół"
	desc = "Ul wciśnięty w broń."
	projectile_type = /obj/item/projectile/bullet/dart/bee
	firing_effect_type = null

/obj/item/ammo_casing/bee/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	if(!BB)
		return
	if(istype(loc, /obj/item/gun/chem))
		var/obj/item/gun/chem/CG = loc
		if(CG.syringes_left <= 0)
			return
		CG.reagents.trans_to(BB, 5, transfered_by = user)
		BB.name = "pszczoła"
		CG.syringes_left--
	..()

/obj/item/ammo_casing/dnainjector
	name = "przerobiona sprężyna wyrzutni strzykawek"
	desc = "Mocna sprężyna, która wyrzuca iniektory DNA."
	projectile_type = /obj/item/projectile/bullet/dnainjector
	firing_effect_type = null

/obj/item/ammo_casing/dnainjector/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	if(!BB)
		return
	if(istype(loc, /obj/item/gun/syringe/dna))
		var/obj/item/gun/syringe/dna/SG = loc
		if(!SG.syringes.len)
			return

		var/obj/item/dnainjector/S = popleft(SG.syringes)
		var/obj/item/projectile/bullet/dnainjector/D = BB
		S.forceMove(D)
		D.injector = S
	..()

