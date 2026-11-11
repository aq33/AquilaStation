// Rzeczy leżące na podłodze po obniżeniu warstw pod ściany 3/4 (code/__DEFINES/layers.dm, AQ EDIT).
// Kratownica, kładka i poszycie kadłuba miały FLOOR_PLANE z warstwą 2.2, czyli nad turfem (TURF_LAYER 2) na tej samej płaszczyźnie.
// Z warstwą poniżej TURF_LAYER podłoga zakrywała je w całości (widać je było tylko nad kosmosem, który ma własną płaszczyznę).
// Na GAME_PLANE leżą nad każdą podłogą i pod rurami, kablami i ścianami, tak jak kable i rury.

/obj/structure/lattice
	plane = GAME_PLANE

/obj/structure/hull_plate
	plane = GAME_PLANE
