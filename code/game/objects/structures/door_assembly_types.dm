/obj/structure/door_assembly/door_assembly_public
	name = "zespół: śluza"
	icon = 'icons/obj/doors/airlocks/station2/glass.dmi'
	overlays_file = 'icons/obj/doors/airlocks/station2/overlays.dmi'
	glass_type = /obj/machinery/door/airlock/public/glass
	airlock_type = /obj/machinery/door/airlock/public

/obj/structure/door_assembly/door_assembly_com
	name = "zespół: śluza dowództwa"
	icon = 'icons/obj/doors/airlocks/station/command.dmi'
	base_name = "śluza dowództwa"
	glass_type = /obj/machinery/door/airlock/command/glass
	airlock_type = /obj/machinery/door/airlock/command

/obj/structure/door_assembly/door_assembly_sec
	name = "zespół: śluza ochrony"
	icon = 'icons/obj/doors/airlocks/station/security.dmi'
	base_name = "śluza ochrony"
	glass_type = /obj/machinery/door/airlock/security/glass
	airlock_type = /obj/machinery/door/airlock/security

/obj/structure/door_assembly/door_assembly_eng
	name = "zespół: śluza inżynierii"
	icon = 'icons/obj/doors/airlocks/station/engineering.dmi'
	base_name = "śluza inżynierii"
	glass_type = /obj/machinery/door/airlock/engineering/glass
	airlock_type = /obj/machinery/door/airlock/engineering

/obj/structure/door_assembly/door_assembly_min
	name = "zespół: śluza górnicza"
	icon = 'icons/obj/doors/airlocks/station/mining.dmi'
	base_name = "śluza górnicza"
	glass_type = /obj/machinery/door/airlock/mining/glass
	airlock_type = /obj/machinery/door/airlock/mining

/obj/structure/door_assembly/door_assembly_atmo
	name = "zespół: śluza atmosferyki"
	icon = 'icons/obj/doors/airlocks/station/atmos.dmi'
	base_name = "śluza atmosferyki"
	glass_type = /obj/machinery/door/airlock/atmos/glass
	airlock_type = /obj/machinery/door/airlock/atmos

/obj/structure/door_assembly/door_assembly_research
	name = "zespół: śluza badawcza"
	icon = 'icons/obj/doors/airlocks/station/research.dmi'
	base_name = "śluza badawcza"
	glass_type = /obj/machinery/door/airlock/research/glass
	airlock_type = /obj/machinery/door/airlock/research

/obj/structure/door_assembly/door_assembly_science
	name = "zespół: śluza naukowa"
	icon = 'icons/obj/doors/airlocks/station/science.dmi'
	base_name = "śluza naukowa"
	glass_type = /obj/machinery/door/airlock/science/glass
	airlock_type = /obj/machinery/door/airlock/science

/obj/structure/door_assembly/door_assembly_med
	name = "zespół: śluza medyczna"
	icon = 'icons/obj/doors/airlocks/station/medical.dmi'
	base_name = "śluza medyczna"
	glass_type = /obj/machinery/door/airlock/medical/glass
	airlock_type = /obj/machinery/door/airlock/medical

/obj/structure/door_assembly/door_assembly_mai
	name = "zespół: wejście do tuneli technicznych"
	icon = 'icons/obj/doors/airlocks/station/maintenance.dmi'
	base_name = "wejście do tuneli technicznych"
	glass_type = /obj/machinery/door/airlock/maintenance/glass
	airlock_type = /obj/machinery/door/airlock/maintenance

/obj/structure/door_assembly/door_assembly_extmai
	name = "zespół: zewnętrzne wejście do śluzy"
	icon = 'icons/obj/doors/airlocks/station/maintenanceexternal.dmi'
	base_name = "zewnętrzne wejście do śluzy"
	glass_type = /obj/machinery/door/airlock/maintenance/external/glass
	airlock_type = /obj/machinery/door/airlock/maintenance/external

/obj/structure/door_assembly/door_assembly_ext
	name = "zespół: zewnętrzna śluza"
	icon = 'icons/obj/doors/airlocks/external/external.dmi'
	base_name = "zewnętrzna śluza"
	overlays_file = 'icons/obj/doors/airlocks/external/overlays.dmi'
	glass_type = /obj/machinery/door/airlock/external/glass
	airlock_type = /obj/machinery/door/airlock/external

/obj/structure/door_assembly/door_assembly_fre
	name = "zespół: śluza chłodni"
	icon = 'icons/obj/doors/airlocks/station/freezer.dmi'
	base_name = "śluza chłodni"
	airlock_type = /obj/machinery/door/airlock/freezer
	noglass = TRUE

/obj/structure/door_assembly/door_assembly_hatch
	name = "zespół: hermetyczny właz"
	icon = 'icons/obj/doors/airlocks/hatch/centcom.dmi'
	base_name = "hermetyczny właz"
	overlays_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/hatch
	noglass = TRUE

/obj/structure/door_assembly/door_assembly_mhatch
	name = "zespół: właz techniczny"
	icon = 'icons/obj/doors/airlocks/hatch/maintenance.dmi'
	base_name = "właz techniczny"
	overlays_file = 'icons/obj/doors/airlocks/hatch/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/maintenance_hatch
	noglass = TRUE

/obj/structure/door_assembly/door_assembly_highsecurity
	name = "zespół: zaawansowana śluza ochrony"
	icon = 'icons/obj/doors/airlocks/highsec/highsec.dmi'
	base_name = "zaawansowana śluza ochrony"
	overlays_file = 'icons/obj/doors/airlocks/highsec/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/highsecurity
	noglass = TRUE
	material_type = /obj/item/stack/sheet/plasteel
	material_amt = 4

/obj/structure/door_assembly/door_assembly_vault
	name = "zespół: drzwi skarbca"
	icon = 'icons/obj/doors/airlocks/vault/vault.dmi'
	base_name = "drzwi skarbca"
	overlays_file = 'icons/obj/doors/airlocks/vault/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/vault
	noglass = TRUE
	material_type = /obj/item/stack/sheet/plasteel
	material_amt = 6

/obj/structure/door_assembly/door_assembly_shuttle
	name = "zespół: śluza promu"
	icon = 'icons/obj/doors/airlocks/shuttle/shuttle.dmi'
	base_name = "śluza promu"
	overlays_file = 'icons/obj/doors/airlocks/shuttle/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/shuttle
	glass_type = /obj/machinery/door/airlock/shuttle/glass

/obj/structure/door_assembly/door_assembly_cult
	name = "zespół: śluza kultu"
	icon = 'icons/obj/doors/airlocks/cult/runed/cult.dmi'
	base_name = "śluza kultu"
	overlays_file = 'icons/obj/doors/airlocks/cult/runed/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/cult
	glass_type = /obj/machinery/door/airlock/cult/glass

/obj/structure/door_assembly/door_assembly_cult/unruned
	icon = 'icons/obj/doors/airlocks/cult/unruned/cult.dmi'
	overlays_file = 'icons/obj/doors/airlocks/cult/unruned/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/cult/unruned
	glass_type = /obj/machinery/door/airlock/cult/unruned/glass

/obj/structure/door_assembly/door_assembly_viro
	name = "zespół: śluza wirusologii"
	icon = 'icons/obj/doors/airlocks/station/virology.dmi'
	base_name = "śluza wirusologii"
	glass_type = /obj/machinery/door/airlock/virology/glass
	airlock_type = /obj/machinery/door/airlock/virology

/obj/structure/door_assembly/door_assembly_centcom
	icon = 'icons/obj/doors/airlocks/centcom/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/centcom/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/centcom
	noglass = TRUE

/obj/structure/door_assembly/door_assembly_grunge
	icon = 'icons/obj/doors/airlocks/centcom/centcom.dmi'
	overlays_file = 'icons/obj/doors/airlocks/centcom/overlays.dmi'
	airlock_type = /obj/machinery/door/airlock/grunge
	noglass = TRUE

/obj/structure/door_assembly/door_assembly_copper
	name = "zespół: miedziana śluza"
	icon = 'icons/obj/doors/airlocks/station/copper.dmi'
	base_name = "miedziana śluza"
	airlock_type = /obj/machinery/door/airlock/copper
	mineral = "copper"
	glass_type = /obj/machinery/door/airlock/copper/glass

/obj/structure/door_assembly/door_assembly_gold
	name = "zespół: złota śluza"
	icon = 'icons/obj/doors/airlocks/station/gold.dmi'
	base_name = "złota śluza"
	airlock_type = /obj/machinery/door/airlock/gold
	mineral = "gold"
	glass_type = /obj/machinery/door/airlock/gold/glass

/obj/structure/door_assembly/door_assembly_silver
	name = "zespół: srebrna śluza"
	icon = 'icons/obj/doors/airlocks/station/silver.dmi'
	base_name = "srebrna śluza"
	airlock_type = /obj/machinery/door/airlock/silver
	mineral = "silver"
	glass_type = /obj/machinery/door/airlock/silver/glass

/obj/structure/door_assembly/door_assembly_diamond
	name = "zespół: diamentowa śluza"
	icon = 'icons/obj/doors/airlocks/station/diamond.dmi'
	base_name = "diamentowa śluza"
	airlock_type = /obj/machinery/door/airlock/diamond
	mineral = "diamond"
	glass_type = /obj/machinery/door/airlock/diamond/glass

/obj/structure/door_assembly/door_assembly_uranium
	name = "zespół: uranowa śluza"
	icon = 'icons/obj/doors/airlocks/station/uranium.dmi'
	base_name = "uranowa śluza"
	airlock_type = /obj/machinery/door/airlock/uranium
	mineral = "uranium"
	glass_type = /obj/machinery/door/airlock/uranium/glass

/obj/structure/door_assembly/door_assembly_plasma
	name = "zespół: plazmowa śluza"
	icon = 'icons/obj/doors/airlocks/station/plasma.dmi'
	base_name = "plazmowa śluza"
	airlock_type = /obj/machinery/door/airlock/plasma
	mineral = "plasma"
	glass_type = /obj/machinery/door/airlock/plasma/glass

/obj/structure/door_assembly/door_assembly_bananium
	name = "zespół: śluza z bananium"
	desc = "Honk."
	icon = 'icons/obj/doors/airlocks/station/bananium.dmi'
	base_name = "śluza z bananium"
	airlock_type = /obj/machinery/door/airlock/bananium
	mineral = "bananium"
	glass_type = /obj/machinery/door/airlock/bananium/glass

/obj/structure/door_assembly/door_assembly_sandstone
	name = "zespół: śluza z piaskowca"
	icon = 'icons/obj/doors/airlocks/station/sandstone.dmi'
	base_name = "śluza z piaskowca"
	airlock_type = /obj/machinery/door/airlock/sandstone
	mineral = "sandstone"
	glass_type = /obj/machinery/door/airlock/sandstone/glass

/obj/structure/door_assembly/door_assembly_titanium
	name = "zespół: śluza promu"
	icon = 'icons/obj/doors/airlocks/shuttle/shuttle.dmi'
	base_name = "śluza promu"
	overlays_file = 'icons/obj/doors/airlocks/shuttle/overlays.dmi'
	glass_type = /obj/machinery/door/airlock/titanium/glass
	airlock_type = /obj/machinery/door/airlock/titanium
	mineral = "titanium"

/obj/structure/door_assembly/door_assembly_wood
	name = "zespół: drewniana śluza"
	icon = 'icons/obj/doors/airlocks/station/wood.dmi'
	base_name = "drewniana śluza"
	airlock_type = /obj/machinery/door/airlock/wood
	mineral = "wood"
	glass_type = /obj/machinery/door/airlock/wood/glass

/obj/structure/door_assembly/door_assembly_bronze
	name = "zespół: brązowa śluza"
	icon = 'icons/obj/doors/airlocks/clockwork/pinion_airlock.dmi'
	base_name = "brązowa śluza"
	airlock_type = /obj/machinery/door/airlock/bronze
	noglass = TRUE
	material_type = /obj/item/stack/tile/bronze

/obj/structure/door_assembly/door_assembly_bronze/seethru
	name = "zespół: brązowa śluza"
	airlock_type = /obj/machinery/door/airlock/bronze/seethru
