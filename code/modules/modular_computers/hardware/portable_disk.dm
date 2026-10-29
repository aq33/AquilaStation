/obj/item/computer_hardware/hard_drive/portable
	name = "dysk z danymi"
	desc = "Wymienny dysk do przechowywania danych."
	power_usage = 10
	icon_state = "datadisk6"
	w_class = WEIGHT_CLASS_TINY
	critical = 0
	max_capacity = 16
	device_type = MC_SDD

/obj/item/computer_hardware/hard_drive/portable/on_remove(obj/item/modular_computer/remove_from, mob/user)
	return //this is a floppy disk, let's not shut the computer down when it gets pulled out.

/obj/item/computer_hardware/hard_drive/portable/install_default_programs()
	return // Empty by default

/obj/item/computer_hardware/hard_drive/portable/advanced
	name = "zaawansowany dysk z danymi"
	power_usage = 20
	icon_state = "datadisk5"
	max_capacity = 64

/obj/item/computer_hardware/hard_drive/portable/super
	name = "superdysk z danymi"
	desc = "Wymienny dysk do przechowywania dużych ilości danych."
	power_usage = 40
	icon_state = "datadisk3"
	max_capacity = 256
