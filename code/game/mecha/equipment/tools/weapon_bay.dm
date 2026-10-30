/obj/item/mecha_parts/concealed_weapon_bay
	name = "ukryta komora uzbrojenia"
	desc = "Schowek, który pozwala niebojowemu mechowi przenosić jedną broń, ukrytą przed wzrokiem."
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_weapon_bay"

/obj/item/mecha_parts/concealed_weapon_bay/try_attach_part(mob/user, obj/mecha/M)
	if(istype(M, /obj/mecha/combat))
		to_chat(user, "<span class='warning'>[M] może już przenosić broń!</span>")
		return
	if(locate(/obj/item/mecha_parts/concealed_weapon_bay) in M.contents)
		to_chat(user, "<span class='warning'>[M] ma już ukrytą komorę na broń!</span>")
		return
	..()
