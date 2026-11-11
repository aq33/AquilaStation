// AQUILA - płytki, podłogi i ściany z materiału, port BeeStation/BeeStation-Hornet#10703 (tgstation/tgstation#49402).
// Ściana z materiału to nasza ściana Paradise 32x40 barwiona kolorem materiału, bez tekstury
// (Bee ma 32x32 materialwall.dmi ze smoothingiem po grupach, którego nie mamy).

/obj/item/stack/tile/material
	name = "płytka podłogowa"
	singular_name = "płytka podłogowa"
	desc = "Grunt, po którym chodzisz."
	icon = 'aquila/icons/obj/material_tile.dmi'
	icon_state = "material_tile"
	item_state = "tile"
	throwforce = 10
	turf_type = /turf/open/floor/material
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	material_name_gender = FEMALE
	merge_type = /obj/item/stack/tile/material
	mats_per_unit = list(/datum/material/iron = 500) // w Bee bez materiału; z menu craftingu i z mapy wychodzi żelazna, która coś oddaje

/turf/open/floor/material
	name = "podłoga"
	icon_state = "materialfloor"
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	material_name_gender = FEMALE
	floor_tile = /obj/item/stack/tile/material

/turf/open/floor/material/has_tile()
	return LAZYLEN(custom_materials)

/turf/open/floor/material/spawn_tile()
	. = ..()
	if(.)
		var/obj/item/stack/tile = .
		tile.set_mats_per_unit(custom_materials, 1)

/turf/closed/wall/material
	name = "ściana"
	desc = "Ogromny blok materiału oddzielający pomieszczenia."
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	material_name_gender = FEMALE

// Bez ..(): zamiast żelaza ściana oddaje swój materiał. Hooki rozbiórki wraków (shipbreaking/hooks.dm) jej nie dotyczą,
// bo w klatce magnesu nie ma ścian z materiału.
// Arkusze przez drop_material_sheets(): kamień z gorgium nie ma arkusza, a materiał z metalgenu nic nie oddaje.
/turf/closed/wall/material/break_wall()
	drop_material_sheets(src)
	if(girder_type)
		return new girder_type(src)

/turf/closed/wall/material/devastate_wall()
	drop_material_sheets(src)

/turf/closed/wall/material/mat_update_desc(datum/material/mat)
	desc = "Ogromny blok materiału ([mat.get_polish_name()]) oddzielający pomieszczenia."
