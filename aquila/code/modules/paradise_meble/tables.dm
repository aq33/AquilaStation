// Stoły z Paradise (ParadiseSS13/Paradise, grafiki CC BY-SA 3.0). Paradise rysuje każdy z 47 układów sąsiadów osobno,
// więc stoły idą przez bitmask_smooth z paradise_struktury/smoothing.dm zamiast starych narożników.
// Łączenie zostaje takie jak w canSmoothWith/SMOOTH_MORE, żeby kolory obrusów i blaty dalej łączyły się jak wcześniej.

/obj/structure/table
	icon = 'aquila/icons/paradise/tables/table.dmi'
	icon_state = "table-0"
	base_icon_state = "table"
	bitmask_smooth = TRUE

/obj/structure/table/bitmask_connects_to(turf/T)
	if(!T)
		return FALSE
	for(var/obj/structure/table/other in T)
		if(other == src || !other.bitmask_smooth)
			continue
		if(!canSmoothWith)
			if(other.type == type)
				return TRUE
			continue
		if(smooth & SMOOTH_MORE)
			if(is_type_in_list(other, canSmoothWith))
				return TRUE
		else if(other.type in canSmoothWith)
			return TRUE
	return FALSE

/obj/structure/table/glass
	icon = 'aquila/icons/paradise/tables/glass_table.dmi'
	icon_state = "glass_table-0"
	base_icon_state = "glass_table"

/obj/structure/table/glass/plasma
	icon = 'aquila/icons/paradise/tables/plasmaglass_table.dmi'
	icon_state = "plasmaglass_table-0"
	base_icon_state = "plasmaglass_table"

/obj/structure/table/wood
	icon = 'aquila/icons/paradise/tables/wood_table.dmi'
	icon_state = "wood_table-0"
	base_icon_state = "wood_table"

/obj/structure/table/wood/poker
	icon = 'aquila/icons/paradise/tables/poker_table.dmi'
	icon_state = "poker_table-0"
	base_icon_state = "poker_table"

/obj/structure/table/reinforced
	icon = 'aquila/icons/paradise/tables/reinforced_table.dmi'
	icon_state = "reinforced_table-0"
	base_icon_state = "reinforced_table"

/obj/structure/table/brass
	icon = 'aquila/icons/paradise/tables/brass_table.dmi'
	icon_state = "brass_table-0"
	base_icon_state = "brass_table"

/obj/structure/table/bronze
	icon = 'aquila/icons/paradise/tables/brass_table.dmi'
	icon_state = "brass_table-0"
	base_icon_state = "brass_table"

/obj/structure/table/abductor
	icon = 'aquila/icons/paradise/tables/alien_table.dmi'
	icon_state = "alien_table-0"
	base_icon_state = "alien_table"

// Obrusy mają 32x34, więc w edytorze zostaje stary sprite 32x32, a ikona Paradise wchodzi w Initialize() przez smooth_icon
/obj/structure/table/wood/fancy
	base_icon_state = "fancy_table"
	smooth_icon = 'aquila/icons/paradise/tables/fancy_table.dmi'

/obj/structure/table/wood/fancy/black
	base_icon_state = "fancy_table_black"
	smooth_icon = 'aquila/icons/paradise/tables/fancy_table_black.dmi'

/obj/structure/table/wood/fancy/blue
	base_icon_state = "fancy_table_blue"
	smooth_icon = 'aquila/icons/paradise/tables/fancy_table_blue.dmi'

/obj/structure/table/wood/fancy/cyan
	base_icon_state = "fancy_table_cyan"
	smooth_icon = 'aquila/icons/paradise/tables/fancy_table_cyan.dmi'

/obj/structure/table/wood/fancy/green
	base_icon_state = "fancy_table_green"
	smooth_icon = 'aquila/icons/paradise/tables/fancy_table_green.dmi'

/obj/structure/table/wood/fancy/orange
	base_icon_state = "fancy_table_orange"
	smooth_icon = 'aquila/icons/paradise/tables/fancy_table_orange.dmi'

/obj/structure/table/wood/fancy/purple
	base_icon_state = "fancy_table_purple"
	smooth_icon = 'aquila/icons/paradise/tables/fancy_table_purple.dmi'

/obj/structure/table/wood/fancy/red
	base_icon_state = "fancy_table_red"
	smooth_icon = 'aquila/icons/paradise/tables/fancy_table_red.dmi'

/obj/structure/table/wood/fancy/royalblack
	base_icon_state = "fancy_table_royalblack"
	smooth_icon = 'aquila/icons/paradise/tables/fancy_table_royalblack.dmi'

/obj/structure/table/wood/fancy/royalblue
	base_icon_state = "fancy_table_royalblue"
	smooth_icon = 'aquila/icons/paradise/tables/fancy_table_royalblue.dmi'

// Stoły bez odpowiednika w Paradise zostają na starych narożnikach
/obj/structure/table/survival_pod
	bitmask_smooth = FALSE

/obj/structure/table/optable
	bitmask_smooth = FALSE
