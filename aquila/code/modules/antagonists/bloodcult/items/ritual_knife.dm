// AQUILA - tg/Monke: /obj/item/knife/ritual. U nas noże to /obj/item/kitchen/knife.
/obj/item/kitchen/knife/ritual
	name = "rytualny sztylet"
	desc = "Dziwny sztylet, którym podobno złowrogie grupy „przygotowują” zwłoki przed złożeniem ich w ofierze swoim mrocznym bogom."
	icon = 'aquila/icons/bloodcult/monke/obj/cult/items_and_weapons.dmi'
	icon_state = "render"
	item_state = "cultdagger"
	worn_icon_state = "render"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	w_class = WEIGHT_CLASS_SMALL
	force = 15
	throwforce = 25
	/// AQUILA - szansa bloku jak w tg (u nas Bee blokuje poziomami)
	var/block_chance = 25
	armour_penetration = 35
	block_sound = 'sound/weapons/parry.ogg'

/obj/item/kitchen/knife/ritual/Initialize(mapload)
	. = ..()
	var/image/silicon_image = image(icon = 'icons/effects/blood.dmi' , icon_state = null, loc = src)
	silicon_image.override = TRUE
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/silicons, "cult_dagger", silicon_image)

	var/examine_text = {"Dźwigary kultu niszczy jednym ciosem.
Uderzenie innego kultysty usuwa z niego całą wodę święconą i zmienia ją w nieświętą.
Uderzenie niekultysty rozrywa za to jego ciało."}

	AddComponent(/datum/component/cult_ritual_item, span_cult(examine_text))


/obj/item/kitchen/knife/ritual/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	var/final_block_chance = block_chance
	var/block_message = "[owner] paruje [attack_text] za pomocą [src]"
	if(owner.get_active_held_item() != src)
		block_message = "[owner] paruje [attack_text] za pomocą [src] trzymanego w drugiej ręce"

	if(IS_CULTIST(owner) && prob(final_block_chance) && attack_type != PROJECTILE_ATTACK)
		new /obj/effect/temp_visual/cult/sparks(get_turf(owner))
		owner.visible_message(span_danger("[block_message]"))
		return TRUE
	else
		return FALSE
