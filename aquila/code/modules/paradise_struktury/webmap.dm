// Dane wygładzania tylko dla renderów map (SpacemanDMM: webmapa, mapy w PR). Gra ich nie czyta, liczy bitmaskę po swojemu
// w smoothing.dm. Renderer zna tylko smoothing z tg z 2020 roku: atom z SMOOTH_BITMASK w smoothing_flags dostaje stan
// "[base_icon_state]-[układ]", a sąsiad się liczy, gdy jego smoothing_groups ma coś wspólnego z naszym canSmoothWith.
// Bez tego każda ściana Paradise na webmapie jest osobnym klockiem (stan "-0").

#define MAP_RENDER_SMOOTH_BITMASK (1<<1)

/// Wszystko, co jakakolwiek ściana, okno albo fałszywa ściana ma w canSmoothWith. Konstrukcje Paradise łączą się w grze
/// niezależnie od materiału, więc na mapie każda z nich należy do całej tej grupy.
#define PARADISE_MAP_SMOOTHING_GROUP list(\
	/turf/closed/wall, /turf/closed/wall/r_wall, /turf/closed/wall/rust, /turf/closed/wall/r_wall/rust, /turf/closed/wall/r_wall/syndicate,\
	/turf/closed/wall/clockwork, /turf/closed/wall/mineral/abductor, /turf/closed/wall/mineral/bamboo, /turf/closed/wall/mineral/bananium,\
	/turf/closed/wall/mineral/copper, /turf/closed/wall/mineral/diamond, /turf/closed/wall/mineral/gold, /turf/closed/wall/mineral/iron,\
	/turf/closed/wall/mineral/plasma, /turf/closed/wall/mineral/plastitanium, /turf/closed/wall/mineral/sandstone, /turf/closed/wall/mineral/silver,\
	/turf/closed/wall/mineral/titanium, /turf/closed/wall/mineral/titanium/survival, /turf/closed/wall/mineral/uranium,\
	/turf/closed/wall/mineral/wood, /turf/closed/wall/mineral/wood/nonmetal, /turf/closed/indestructible/riveted/boss,\
	/turf/closed/indestructible/riveted/boss/see_through, /obj/structure/falsewall, /obj/structure/falsewall/abductor,\
	/obj/structure/falsewall/bamboo, /obj/structure/falsewall/bananium, /obj/structure/falsewall/brass, /obj/structure/falsewall/copper,\
	/obj/structure/falsewall/diamond, /obj/structure/falsewall/gold, /obj/structure/falsewall/iron, /obj/structure/falsewall/plasma,\
	/obj/structure/falsewall/plastitanium, /obj/structure/falsewall/reinforced, /obj/structure/falsewall/sandstone, /obj/structure/falsewall/silver,\
	/obj/structure/falsewall/titanium, /obj/structure/falsewall/uranium, /obj/structure/falsewall/wood, /obj/structure/window/fulltile,\
	/obj/structure/window/reinforced/fulltile, /obj/structure/window/reinforced/tinted/fulltile, /obj/structure/window/plasma/fulltile,\
	/obj/structure/window/plasma/reinforced/fulltile, /obj/structure/window/depleteduranium/fulltile, /obj/structure/window/shuttle,\
	/obj/structure/window/shuttle/survival_pod, /obj/structure/window/plastitanium, /obj/machinery/door, /obj/machinery/door/airlock,\
	/obj/machinery/door/airlock/shuttle, /obj/machinery/door/airlock/survival_pod)

/atom
	/// AQUILA - tylko dla renderów map (SpacemanDMM), gra używa bitmask_smooth
	var/smoothing_flags = 0
	/// AQUILA - tylko dla renderów map (SpacemanDMM)
	var/list/smoothing_groups

// Ściany, okna i drzwi Paradise
/turf/closed/wall
	smoothing_flags = MAP_RENDER_SMOOTH_BITMASK
	smoothing_groups = PARADISE_MAP_SMOOTHING_GROUP

/turf/closed/indestructible/riveted
	smoothing_flags = MAP_RENDER_SMOOTH_BITMASK
	smoothing_groups = PARADISE_MAP_SMOOTHING_GROUP
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/falsewall
	smoothing_flags = MAP_RENDER_SMOOTH_BITMASK
	smoothing_groups = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/window/fulltile
	smoothing_flags = MAP_RENDER_SMOOTH_BITMASK
	smoothing_groups = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/window/reinforced/fulltile
	smoothing_flags = MAP_RENDER_SMOOTH_BITMASK
	smoothing_groups = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/window/plasma/fulltile
	smoothing_flags = MAP_RENDER_SMOOTH_BITMASK
	smoothing_groups = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/window/plasma/reinforced/fulltile
	smoothing_flags = MAP_RENDER_SMOOTH_BITMASK
	smoothing_groups = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/window/reinforced/tinted/fulltile
	smoothing_flags = MAP_RENDER_SMOOTH_BITMASK
	smoothing_groups = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/window/shuttle
	smoothing_flags = MAP_RENDER_SMOOTH_BITMASK
	smoothing_groups = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/window/plastitanium
	smoothing_flags = MAP_RENDER_SMOOTH_BITMASK
	smoothing_groups = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/window/bronze/fulltile
	smoothing_flags = MAP_RENDER_SMOOTH_BITMASK
	smoothing_groups = PARADISE_MAP_SMOOTHING_GROUP

/obj/machinery/door/airlock
	smoothing_groups = PARADISE_MAP_SMOOTHING_GROUP

/obj/machinery/door/firedoor
	smoothing_groups = PARADISE_MAP_SMOOTHING_GROUP

/obj/machinery/door/firedoor/border_only
	smoothing_groups = null

/obj/machinery/door/firedoor/window
	smoothing_groups = null

// Bez sprite'ów Paradise: zostają na stanie z mapy
/turf/closed/wall/mineral/copper
	smoothing_flags = 0

/turf/closed/wall/mineral/snow
	smoothing_flags = 0

/turf/closed/wall/ice
	smoothing_flags = 0

/turf/closed/wall/mineral/bamboo
	smoothing_flags = 0

/turf/closed/wall/smooth
	smoothing_flags = 0

/turf/closed/wall/vault
	smoothing_flags = 0

/turf/closed/indestructible/riveted/hierophant
	smoothing_flags = 0

/turf/closed/wall/mineral/titanium/nosmooth
	smoothing_flags = 0

/turf/closed/wall/mineral/plastitanium/nosmooth
	smoothing_flags = 0

/turf/closed/wall/r_wall/syndicate/nosmooth
	smoothing_flags = 0

/obj/structure/window/reinforced/fulltile/ice
	smoothing_flags = 0

// Stoły (paradise_meble/tables.dm): grupy takie same jak canSmoothWith
/obj/structure/table
	smoothing_flags = MAP_RENDER_SMOOTH_BITMASK
	smoothing_groups = list(/obj/structure/table, /obj/structure/table/reinforced)

/obj/structure/table/wood
	smoothing_groups = list(/obj/structure/table/wood, /obj/structure/table/wood/poker, /obj/structure/table/wood/bar)

/obj/structure/table/wood/fancy
	smoothing_groups = list(/obj/structure/table/wood/fancy, /obj/structure/table/wood/fancy/black, /obj/structure/table/wood/fancy/blue,\
		/obj/structure/table/wood/fancy/cyan, /obj/structure/table/wood/fancy/green, /obj/structure/table/wood/fancy/orange,\
		/obj/structure/table/wood/fancy/purple, /obj/structure/table/wood/fancy/red, /obj/structure/table/wood/fancy/royalblack,\
		/obj/structure/table/wood/fancy/royalblue)

/obj/structure/table/brass
	smoothing_groups = list(/obj/structure/table/brass, /obj/structure/table/bronze)

/obj/structure/table/bronze
	smoothing_groups = list(/obj/structure/table/brass, /obj/structure/table/bronze)

/obj/structure/table/survival_pod
	smoothing_flags = 0

/obj/structure/table/optable
	smoothing_flags = 0

// Dywany Bee: każdy kolor tylko ze sobą
/turf/open/floor/carpet
	smoothing_flags = MAP_RENDER_SMOOTH_BITMASK
	smoothing_groups = list(/turf/open/floor/carpet)

/turf/open/floor/carpet/black
	smoothing_groups = list(/turf/open/floor/carpet/black)

/turf/open/floor/carpet/blue
	smoothing_groups = list(/turf/open/floor/carpet/blue)

/turf/open/floor/carpet/cyan
	smoothing_groups = list(/turf/open/floor/carpet/cyan)

/turf/open/floor/carpet/green
	smoothing_groups = list(/turf/open/floor/carpet/green)

/turf/open/floor/carpet/orange
	smoothing_groups = list(/turf/open/floor/carpet/orange)

/turf/open/floor/carpet/purple
	smoothing_groups = list(/turf/open/floor/carpet/purple)

/turf/open/floor/carpet/red
	smoothing_groups = list(/turf/open/floor/carpet/red)

/turf/open/floor/carpet/royalblack
	smoothing_groups = list(/turf/open/floor/carpet/royalblack)

/turf/open/floor/carpet/royalblue
	smoothing_groups = list(/turf/open/floor/carpet/royalblue)

/turf/open/floor/carpet/grimy
	smoothing_groups = list(/turf/open/floor/carpet/grimy)

// Dywany statku nie mają własnego canSmoothWith, więc na mapie zostają pełnym kaflem
/turf/open/floor/carpet/ship
	smoothing_flags = 0

// Sąsiedzi na mapie: w grze konstrukcje Paradise łączą się ze wszystkimi ścianami, oknami i drzwiami (paradise_structure_connects),
// a canSmoothWith tych typów i tak nie jest używane przy bitmasce, więc dostają całą grupę
/obj/structure/falsewall
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/falsewall/abductor
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/falsewall/bananium
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/falsewall/brass
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/falsewall/diamond
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/falsewall/gold
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/falsewall/iron
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/falsewall/plasma
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/falsewall/plastitanium
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/falsewall/sandstone
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/falsewall/silver
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/falsewall/titanium
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/falsewall/uranium
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/falsewall/wood
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/window/bronze/fulltile
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/window/depleteduranium/fulltile
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/window/fulltile
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/window/plasma/fulltile
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/window/plasma/reinforced/fulltile
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/window/plastitanium
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/window/reinforced/fulltile
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/window/reinforced/fulltile/ship
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/window/reinforced/tinted/fulltile
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/window/shuttle
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/obj/structure/window/shuttle/survival_pod
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/turf/closed/indestructible/riveted/boss
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/turf/closed/wall
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/turf/closed/wall/mineral/abductor
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/turf/closed/wall/mineral/bananium
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/turf/closed/wall/mineral/diamond
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/turf/closed/wall/mineral/gold
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/turf/closed/wall/mineral/iron
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/turf/closed/wall/mineral/plasma
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/turf/closed/wall/mineral/plastitanium
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/turf/closed/wall/mineral/sandstone
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/turf/closed/wall/mineral/silver
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/turf/closed/wall/mineral/titanium
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/turf/closed/wall/mineral/titanium/survival
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/turf/closed/wall/mineral/titanium/survival/pod
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/turf/closed/wall/mineral/uranium
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/turf/closed/wall/mineral/wood
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/turf/closed/wall/mineral/wood/nonmetal
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

/turf/closed/wall/r_wall/syndicate
	canSmoothWith = PARADISE_MAP_SMOOTHING_GROUP

// Skarbiec zostaje na starych narożnikach i dziedziczyłby grupę po ścianie, więc dostaje dawną listę
/turf/closed/wall/vault
	canSmoothWith = list(/turf/closed/wall, /turf/closed/wall/r_wall, /obj/structure/falsewall, /obj/structure/falsewall/brass,		/obj/structure/falsewall/reinforced, /turf/closed/wall/rust, /turf/closed/wall/r_wall/rust, /turf/closed/wall/clockwork)

#undef PARADISE_MAP_SMOOTHING_GROUP
#undef MAP_RENDER_SMOOTH_BITMASK
