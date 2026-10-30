/obj/effect/decal/remains
	name = "szczątki"
	gender = PLURAL
	icon = 'icons/effects/blood.dmi'

/obj/effect/decal/remains/acid_act()
	visible_message("<span class='warning'>[src] rozpuszcza się w kałużę skwierczącej mazi!</span>")
	playsound(src, 'sound/items/welder.ogg', 150, 1)
	new /obj/effect/decal/cleanable/greenglow(drop_location())
	qdel(src)

/obj/effect/decal/remains/human
	desc = "Wyglądają jak ludzkie szczątki. Otacza je dziwna aura."
	icon_state = "remains"

/obj/effect/decal/remains/plasma
	icon_state = "remainsplasma"

/obj/effect/decal/remains/xeno
	desc = "Wyglądają jak szczątki czegoś... obcego. Otacza je dziwna aura."
	icon_state = "remainsxeno"

/obj/effect/decal/remains/xeno/larva
	icon_state = "remainslarva"

/obj/effect/decal/remains/robot
	desc = "Wyglądają jak szczątki czegoś mechanicznego. Otacza je dziwna aura."
	icon = 'icons/mob/robots.dmi'
	icon_state = "remainsrobot"

/obj/effect/decal/cleanable/robot_debris/old
	name = "zakurzone szczątki robota"
	desc = "Wygląda na to, że od dawna nikt tego nie ruszał."
