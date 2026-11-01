/obj/effect/proc_holder/spell/aoe_turf/conjure/summon_greedslots
	name = "Przywołaj jednorękiego bandytę"
	desc = "Przywołuje na chwilę automat chciwości. Możesz zaproponować graczom śmiertelną grę: stawką jest ich życie (i trochę pieniędzy, jeśli chcesz), a nagrodą jednorazowa kość przeznaczenia."
	invocation = "Tylko jedna gra?"
	invocation_type = "whisper"
	clothes_req = FALSE
	charge_max = 600
	cooldown_min = 200
	summon_type = list(/obj/structure/cursed_slot_machine/betterchance)
	summon_lifespan = 60 SECONDS
	summon_amt = 1
	range = 1
	action_icon = 'aquila/icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "slots"
	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/aoe_turf/conjure/cursed_item //conjure a random unique cursed item, which can impart various benefits, but always at a cost...
	name = "Przywołaj przeklęty przedmiot"
	desc = "Sprowadza z piekła pod twoje stopy losowy przeklęty przedmiot. Ma potężne zastosowania, ale często z niezamierzonymi skutkami. Idealny na sprzedaż, a w potrzebie nawet do własnego użytku. Uważaj: wiele z tych efektów może zaszkodzić także tobie."
	invocation = "Potęga ponad miarę"
	invocation_type = "whisper"
	clothes_req = FALSE
	charge_max = 180 SECONDS //no farming a bunch of items
	cooldown_min = 180 SECONDS
	range = 0 //spawns on top of us
	summon_amt = 1
	summon_type = list(
		/obj/item/katana/greedcursed,
		/obj/item/reagent_containers/pill/greedcursed,
		/obj/item/book_of_babel/greedcursed,
		/obj/item/book/granter/spell/sacredflame/weak, //this one isnt actually 'cursed', but its also way weaker than the normal spell, and you're still setting yourself on fire
		/obj/item/greedcursed_bottle,
	)
	action_icon = 'aquila/icons/mob/actions/actions_minor_antag.dmi'
	action_icon_state = "moneybag"
	action_background_icon_state = "bg_demon"

/obj/item/katana/greedcursed //quite a bit weaker katana, still deals good damage, but also siphons part of your health every hit.
	name = "osobliwa katana"
	desc = "Kiedy nią machasz, rękojeść jakby wgryza ci się w ciało..."
	force = 20
	block_power = 10
	armour_penetration = 15

/obj/item/katana/greedcursed/attack(mob/target, mob/living/carbon/human/user)
	to_chat(user, span_warning("[src] wbija ci się w dłonie..."))
	user.apply_damage(rand(force/4, force/2), BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)) //5-10 damage to one of your arms
	return ..()

/obj/item/reagent_containers/pill/greedcursed //has a good amount of healing chems, you just have to deal with being set on fire first
	name = "dziwna pigułka"
	desc = "Pachnie siarką. Samo patrzenie na nią podpowiada ci, że mogłaby cię uleczyć w zamian za coś innego..."
	volume = 25
	list_reagents = list(/datum/reagent/medicine/omnizine = 20, /datum/reagent/hellwater = 3, /datum/reagent/medicine/lavaland_extract = 2)

/obj/item/book_of_babel/greedcursed
	desc = "Pradawna księga spisana w niezliczonych językach. Bije od niej przytłaczający smród siarki. Lektura może dać ci wiedzę, jeśli udźwigniesz jej cenę."

/obj/item/book_of_babel/greedcursed/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(!user.can_read(src))
		return FALSE
	to_chat(user, span_notice("Kartkujesz strony najszybciej, jak się da, a przytłaczający smród zdaje się wysysać z ciebie samą istotę. Gdy kończysz, księga nagle zajmuje się piekielnym ogniem i obraca w proch."))
	user.grant_all_languages()
	user.health -= 20
	user.maxHealth -= 20
	new /obj/effect/decal/cleanable/ash(get_turf(user))
	qdel(src)

/obj/item/greedcursed_bottle //recovers a portion of your max health, at the cost of being cursed into a shadowperson
	name = "butelka ciemnej krwi"
	desc = "Zawartość bez przerwy wiruje i kurczy się w jasnym świetle. Jeśli to wypijesz, może odzyskasz część siebie, choć być może za straszliwą cenę..."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/greedcursed_bottle/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		return
	to_chat(user, span_danger("Przez chwilę czujesz się lepiej, jakby twoja siła życiowa urosła. Potem nagle twoje ciało złazi płatami i ciemnieje, odsłaniając nową, straszliwą postać..."))
	user.set_species(/datum/species/shadow)
	if(user.maxHealth < 100) //cannot bring you above standard max health
		user.maxHealth += 20
	playsound(user.loc,'sound/items/drink.ogg', rand(10,50), 1)
	qdel(src)

/obj/item/book/granter/spell/sacredflame/weak //grants the far weaker version
	spell = /obj/effect/proc_holder/spell/targeted/sacred_flame/weak

/obj/effect/proc_holder/spell/targeted/sacred_flame/weak //far weaker version, primarily for the greed cursed item
	charge_max = 15 SECONDS
	range = 2
	///Fire stacks given to everyone around, the normal spell gives 20
	var/firestacks_to_give = 5

/obj/effect/proc_holder/spell/targeted/sacred_flame/weak/cast(list/targets, mob/user = usr)
	for(var/mob/living/L in targets)
		if(L.anti_magic_check(TRUE, TRUE))
			continue
		L.adjust_fire_stacks(firestacks_to_give)
	if(isliving(user))
		var/mob/living/U = user
		if(!U.anti_magic_check(TRUE, TRUE))
			U.IgniteMob()
