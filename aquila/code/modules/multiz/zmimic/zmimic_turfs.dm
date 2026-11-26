// Z-Mimic: które kafle pokazują piętro niżej i hooki światła (w Bee wpisane w core)

/turf/open/openspace
	z_flags = Z_MIMIC_BELOW | Z_MIMIC_OVERWRITE

/// Szklana podłoga NSV: szkło na wierzchu, piętro niżej pod nim (dawniej element turf_z_transparency)
/turf/open/floor/glass
	z_flags = Z_MIMIC_BELOW

/// Po przeliczeniu światła kafla pod otwartą przestrzenią kopia światła wyżej musi się odświeżyć
/atom/movable/lighting_object/update()
	. = ..()
	if (QDELETED(src))
		return
	var/turf/above = myturf?.above
	if (!above)
		return
	if (above.shadower)
		above.shadower.copy_lighting(src)
	else
		above.update_mimic()

/atom/movable/lighting_object/Destroy(force)
	var/turf/above = myturf?.above
	. = ..()
	if (force && above)
		above.update_mimic()
