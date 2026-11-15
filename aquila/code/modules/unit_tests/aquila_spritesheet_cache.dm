// The upstream assert macros are #undef'd at the end of code/modules/unit_tests/_unit_tests.dm, so this modular test carries its own copies
#define TEST_ASSERT(assertion, reason) if (!(assertion)) { return Fail("Assertion failed: [reason || "No reason"]") }

#define AQ_CACHE_TEST_FOLDER "tmp/aq_spritesheet_cache_test/"

/// Sheet with two icon sizes, cached in its own folder (independent of CACHE_ASSETS); abstract so SSassets skips it
/datum/asset/spritesheet/aq_cache_test
	_abstract = /datum/asset/spritesheet/aq_cache_test
	name = "aq_cache_test"

/datum/asset/spritesheet/aq_cache_test/aq_cache_file(suffix)
	return "[AQ_CACHE_TEST_FOLDER]spritesheet.[name][suffix]"

/datum/asset/spritesheet/aq_cache_test/register()
	InsertAll("stack", 'icons/obj/stack_objects.dmi')
	Insert("big", 'icons/effects/96x96.dmi', "explosion") // second size: 96x96
	return ..()

/// AQUILA: a spritesheet read from the cross-round cache has the same sprites, files and CSS as the built one,
/// and a damaged cache is refused without registering anything (the sheet is then built normally)
/datum/unit_test/aquila_spritesheet_cache
	var/list/png_names

/datum/unit_test/aquila_spritesheet_cache/Run()
	fdel(AQ_CACHE_TEST_FOLDER)
	var/datum/asset/spritesheet/aq_cache_test/built = new
	TEST_ASSERT(!built.aq_cached_files, "The sheet was read from a cache that does not exist")
	TEST_ASSERT(length(built.sizes) == 2, "The test sheet should have two sizes, has [length(built.sizes)]")
	png_names = list()
	for(var/size_id in built.sizes)
		png_names += "[built.name]_[size_id].png"
	var/datum/asset_cache_item/built_css = SSassets.cache["spritesheet_[built.name].css"]
	var/list/built_sprites = built.sprites.Copy()
	var/list/built_mappings = built.get_url_mappings()
	built.aq_write_cache()

	GLOB.asset_datums -= built.type
	var/datum/asset/spritesheet/aq_cache_test/cached = new
	TEST_ASSERT(length(cached.aq_cached_files) == 2, "The sheet was not read from the cache ([length(cached.aq_cached_files)] files)")
	TEST_ASSERT(!length(cached.sizes), "The cached sheet was built again")
	for(var/sprite_name in built_sprites)
		var/list/a = built_sprites[sprite_name]
		var/list/b = cached.sprites[sprite_name]
		TEST_ASSERT(islist(b) && a[1] == b[1] && a[2] == b[2], "Sprite [sprite_name] differs after the cache: [json_encode(a)] vs [json_encode(b)]")
	TEST_ASSERT(length(cached.sprites) == length(built_sprites), "The cached sheet has [length(cached.sprites)] sprites, the built one [length(built_sprites)]")
	var/list/cached_mappings = cached.get_url_mappings()
	for(var/asset_name in built_mappings)
		TEST_ASSERT(cached_mappings[asset_name] == built_mappings[asset_name], "Asset [asset_name] has another URL after the cache")
	var/datum/asset_cache_item/cached_css = SSassets.cache["spritesheet_[cached.name].css"]
	TEST_ASSERT(cached_css.hash == built_css.hash, "The CSS read from the cache differs from the built one")

	// A damaged cache: refused, no runtime, and none of its PNGs left in the asset cache
	var/css_path = cached.aq_cache_file(".css")
	var/json_path = cached.aq_cache_file(".json")
	var/png_path = cached.aq_cache_file("_32x32.png")
	var/good_css = file2text(css_path)
	var/good_json = file2text(json_path)
	forget_test_pngs()
	text2file("/* przerwany zapis */", css_path)
	TEST_ASSERT(!cached.aq_read_cache(), "A cache with a changed CSS was read")
	TEST_ASSERT(!test_pngs_registered(), "A refused cache registered its PNGs")
	fdel(css_path)
	text2file(good_css, css_path)
	text2file("x", png_path)
	TEST_ASSERT(!cached.aq_read_cache(), "A cache with a changed PNG was read")
	TEST_ASSERT(!test_pngs_registered(), "A refused cache registered its PNGs")
	fdel(json_path)
	text2file(copytext(good_json, 1, length(good_json) / 2), json_path)
	TEST_ASSERT(!cached.aq_read_cache(), "A cache with a cut JSON was read")
	TEST_ASSERT(!test_pngs_registered(), "A refused cache registered its PNGs")

	// md5asfile: a file on disk is hashed directly, a file compiled into the rsc the old way, both like a copy
	var/disk_file = file("tgui/public/tgui.html")
	var/copy_path = "[AQ_CACHE_TEST_FOLDER]copy.html"
	fcopy(disk_file, copy_path)
	TEST_ASSERT(md5asfile(disk_file) == rustg_hash_file(RUSTG_HASH_MD5, copy_path), "md5asfile of a file on disk differs from the hash of its copy")
	var/rsc_file = 'icons/effects/96x96.dmi'
	var/rsc_copy = "[AQ_CACHE_TEST_FOLDER]copy.dmi"
	fcopy(rsc_file, rsc_copy)
	TEST_ASSERT(md5asfile(rsc_file) == rustg_hash_file(RUSTG_HASH_MD5, rsc_copy), "md5asfile of a file from the rsc differs from the hash of its copy")
	TEST_ASSERT(isnull(md5filepath("[AQ_CACHE_TEST_FOLDER]missing.png")), "md5filepath of a missing file is not null")

/datum/unit_test/aquila_spritesheet_cache/proc/forget_test_pngs()
	for(var/asset_name in png_names)
		SSassets.cache -= asset_name

/datum/unit_test/aquila_spritesheet_cache/proc/test_pngs_registered()
	for(var/asset_name in png_names)
		if(SSassets.cache[asset_name])
			return TRUE
	return FALSE

/datum/unit_test/aquila_spritesheet_cache/Destroy()
	fdel(AQ_CACHE_TEST_FOLDER)
	GLOB.asset_datums -= /datum/asset/spritesheet/aq_cache_test
	forget_test_pngs()
	SSassets.cache -= "spritesheet_aq_cache_test.css"
	return ..()

#undef AQ_CACHE_TEST_FOLDER
#undef TEST_ASSERT
