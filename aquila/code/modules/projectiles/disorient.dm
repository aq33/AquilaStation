// Port BeeStation/BeeStation-Hornet#14750: pociski obezwładniające dezorientują (hak w /mob/living/bullet_act).
// Zabierają staminę i spowalniają, a paraliżują dopiero wyczerpany cel.
// Różnice: nie mamy tasera-wiązki z Bee, więc dezorientację dostają nasze elektrody (zwykła i hitscan NSV13).

/obj/item/projectile
	///Czas dezorientacji
	var/disorient_length = 0 SECONDS
	///Stamina zabierana przez dezorientację
	var/disorient_damage = 0
	///Paraliż, jeśli cel jest wyczerpany
	var/disorient_status_length = 0 SECONDS
	///FALSE: kolejne trafienia odświeżają paraliż zamiast go dokładać (śrut, serie)
	var/disorient_stack_status = TRUE

/obj/item/projectile/beam/disabler
	disorient_length = 2 SECONDS
	disorient_damage = 50
	disorient_status_length = 4 SECONDS
	disorient_stack_status = FALSE

/obj/item/projectile/energy/electrode
	disorient_length = 3 SECONDS
	disorient_damage = 90
	disorient_status_length = 4 SECONDS
	disorient_stack_status = FALSE

/obj/item/projectile/energy/electrode/hitscan
	disorient_damage = 105
	disorient_status_length = 5.5 SECONDS
