// NSV13: woda w basenie (basen na zużyte paliwo) mocno tłumi promieniowanie.
// Po porcie BeeStation/BeeStation-Hornet#13442 robi to izolacja kafelka basenu zamiast wyjątków w radiation_pulse() i rad_act().
// Kto stoi w basenie albo jest za nim, jest bezpieczny od impulsów z progiem 0,5 i wyższym (pręty paliwowe, RBMK, stormdrive).
/turf/open/indestructible/sound/pool
	rad_insulation = RAD_EXTREME_INSULATION
