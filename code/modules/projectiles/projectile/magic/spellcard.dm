/obj/item/projectile/spellcard
	name = "zaklęta karta"
	desc = "Kawałek papieru zaklęty tak, by był niezwykle wytrzymały i sztywny, a jego krawędzie dość ostre, by pociąć każdego, kogo trafi naładowana karta."
	icon_state = "spellcard"
	damage_type = BRUTE
	damage = 2

/obj/item/projectile/spellcard/New(loc, spell_level)
	. = ..()
	damage += spell_level
