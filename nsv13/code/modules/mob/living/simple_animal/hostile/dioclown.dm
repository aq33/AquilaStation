/mob/living/simple_animal/hostile/dio_clown
	name = "Honkferatu"
	desc = "Pradawna, przeklęta istota skazana na życie w zupełnej samotności."
	icon = 'nsv13/icons/mob/animal.dmi'
	icon_state = "dioclown"
	icon_living = "dioclown"
	icon_dead = "clown_dead"
	icon_gib = "clown_gib"
	turns_per_move = 5
	speak = list("JOJO!", "HJONK!", "Pozwól mi napić się twojej krwi!", "Tak bardzo chce mi się pić!", "Ucieczka jest niemożliwa!", "MWAHAHAHAH")
	emote_see = list("trąbi", "piszczy")
	speak_chance = 1
	combat_mode = TRUE
	maxHealth = 200
	health = 200
	speed = 3
	melee_damage = 10
	attack_sound = 'sound/hallucinations/growl1.ogg'
	obj_damage = 10
	del_on_death = TRUE
	loot = list(/obj/item/clothing/mask/gas/pillarmen)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 5, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 370
	unsuitable_atmos_damage = 10

/obj/structure/closet/crate/coffin/dio_clown
	name = "pradawna trumna"
	desc = "Pradawna trumna obrośnięta pąklami, z wypisanym na niej imieniem. Imię jest nieczytelne, ale chyba składa się z 3 liter."
	var/clown_spawned = FALSE

/obj/structure/closet/crate/coffin/dio_clown/open(mob/living/user)
	. = ..()
	if(!clown_spawned)
		playsound(src.loc, 'sound/hallucinations/wail.ogg', 100, TRUE)
		playsound(src.loc, 'sound/hallucinations/i_see_you1.ogg', 100, TRUE)
		new /mob/living/simple_animal/hostile/dio_clown(get_turf(src))
		clown_spawned = TRUE

/mob/living/simple_animal/hostile/dio_clown/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(move_react))

/mob/living/simple_animal/hostile/dio_clown/proc/move_react()
	if(isspaceturf(get_turf(src)))
		emote("scream")
		playsound(src.loc, 'sound/hallucinations/far_noise.ogg', 100, TRUE)
		visible_message("<span class='warning'>[src] w mgnieniu oka obraca się w proch!</span>")
		dust()

/mob/living/simple_animal/hostile/dio_clown/attack_hand(mob/living/carbon/human/M)
	..()
	playsound(src.loc, 'sound/items/bikehorn.ogg', 50, TRUE)

/obj/item/clothing/mask/gas/pillarmen
	name = "wampirza maska"
	desc = "Dziwna kamienna maska, z której wystają jakby kolce. Kolce wyglądają na spiłowane."
	icon = 'nsv13/icons/obj/clothing/masks.dmi' //Placeholder subtype for our own iconsets
	worn_icon = 'nsv13/icons/mob/mask.dmi'
	icon_state = "pillarmen"
	item_state = "pillarmen"
	actions_types = list(/datum/action/item_action/menacing_pose)
