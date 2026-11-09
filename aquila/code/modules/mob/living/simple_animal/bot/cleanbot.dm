// Sprzątacz zbiera też odchody (aquila/code/game/objects/effects/decals/cleanable/feces.dm), których core nie zna
/mob/living/simple_animal/bot/cleanbot/get_targets()
	. = ..()
	target_types[/obj/effect/decal/cleanable/feces] = TRUE
