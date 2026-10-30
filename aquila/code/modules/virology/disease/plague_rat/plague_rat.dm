/mob/living/simple_animal/mouse/plague
	name = "plague rat"

	icon = 'aquila/icons/virology/animal.dmi'
	icon_state = "mouse_plague"
	icon_living = "mouse_plague"
	icon_dead = "mouse_plague_dead"

	maxHealth = 50
	health = 50

	// AQ: nasze /mob/living/simple_animal/mouse nie ma melee_damage_lower/upper (to pola mobow hostile),
	// wiec szczur zarazy zaraza przez dotyk, a nie przez obrazenia
	// AQ: nasze myszy nie losuja koloru przez chooses_bodycolor
	pass_flags = PASSTABLE|PASSGRILLE|PASSMOB
	// AQ: nasze myszy nie maja pola hungry

/mob/living/simple_animal/mouse/plague/Initialize(mapload, tame, new_body_color)
	. = ..()
	speed = -1 // AQ: szybszy od zwyklej myszy (w Monke robi to movespeed_modifier)


/mob/living/simple_animal/mouse/plague/attack_hand(mob/living/carbon/human/user, list/modifiers)
	. = ..()
	if (ishuman(user)||ismonkey(user))
		var/block = user.check_contact_sterility(HANDS)
		var/bleeding = user.check_bodypart_bleeding(HANDS)
		share_contact_diseases(user ,block,bleeding)

/mob/living/simple_animal/mouse/plague/UnarmedAttack(atom/target, proximity, list/modifiers)
	. = ..()
	if (ishuman(target)||ismonkey(target))
		var/mob/living/user = target
		var/block = user.check_contact_sterility(HANDS)
		var/bleeding = user.check_bodypart_bleeding(HANDS)
		share_contact_diseases(target ,block,bleeding)

// AQ: kontakt przedmiotu z mysza siedzi w jednej definicji attackby w living/mouse.dm

// AQ: nie portujemy /datum/movespeed_modifier/plague_rat — nasze simple_animal maja pole `speed`
