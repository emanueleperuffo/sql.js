# Note: Last built with version 2.0.15 of Emscripten

# TODO: Emit a file showing which version of emcc and SQLite was used to compile the emitted output.
# TODO: Create a release on Github with these compiled assets rather than checking them in
# TODO: Consider creating different files based on browser vs module usage: https://github.com/vuejs/vue/tree/dev/dist

# I got this handy makefile syntax from : https://github.com/mandel59/sqlite-wasm (MIT License) Credited in LICENSE
# To use another version of Sqlite, visit https://www.sqlite.org/download.html and copy the appropriate values here:
SQLITE_AMALGAMATION = sqlite-amalgamation-3450200
SQLITE_AMALGAMATION_ZIP_URL = https://www.sqlite.org/2024/sqlite-amalgamation-3450200.zip
SQLITE_AMALGAMATION_ZIP_SHA3 = 8d9c553b52c7b1656a97fec7907cb00fd1419ac45104e45c76b7c2b81ffe0a9d

# Note that extension-functions.c hasn't been updated since 2010-02-06, so likely doesn't need to be updated
EXTENSION_FUNCTIONS = extension-functions.c
EXTENSION_FUNCTIONS_URL = https://www.sqlite.org/contrib/download/extension-functions.c?get=25
EXTENSION_FUNCTIONS_SHA1 = c68fa706d6d9ff98608044c00212473f9c14892f

EMCC=emcc

SQLITE_COMPILATION_FLAGS = \
	-Oz \
	-DSQLITE_OMIT_LOAD_EXTENSION \
	-DSQLITE_DISABLE_LFS \
	-DSQLITE_ENABLE_FTS5 \
	-DSQLITE_THREADSAFE=0 \
	-DSQLITE_ENABLE_NORMALIZE \
	-DSQLITE_OMIT_DEPRECATED \
	-DSQLITE_OMIT_DESERIALIZE \
	-DSQLITE_OMIT_TCL_VARIABLE \
	-DSQLITE_OMIT_UTF16 \
	-DSQLITE_DQS=0 \
	-DSQLITE_DEFAULT_MEMSTATUS=0 \
	-DSQLITE_LIKE_DOESNT_MATCH_BLOBS \
	-DSQLITE_MAX_EXPR_DEPTH=0 \
	-DSQLITE_OMIT_SHARED_CACHE \
	-DSQLITE_USE_ALLOCA \
	-DSQLITE_STRICT_SUBTYPE=1 \
	-DSQLITE_DEFAULT_WAL_SYNCHRONOUS=1

# When compiling to WASM, enabling memory-growth is not expected to make much of an impact, so we enable it for all builds
# Since tihs is a library and not a standalone executable, we don't want to catch unhandled Node process exceptions
# So, we do : `NODEJS_CATCH_EXIT=0`, which fixes issue: https://github.com/sql-js/sql.js/issues/173 and https://github.com/sql-js/sql.js/issues/262
EMFLAGS = \
	-s ALLOW_TABLE_GROWTH=1 \
	-s EXPORTED_FUNCTIONS=@src/exported_functions.json \
	-s EXPORTED_RUNTIME_METHODS=@src/exported_runtime_methods.json \
	-s SINGLE_FILE=0 \
	-s NODEJS_CATCH_EXIT=0 \
	-s NODEJS_CATCH_REJECTION=0 \
	-s STACK_SIZE=5MB

EMFLAGS_WASM = \
	-s WASM=1 \
	-s ALLOW_MEMORY_GROWTH=1

EMFLAGS_WEB= \
	-s ENVIRONMENT=web \
	-s DYNAMIC_EXECUTION=0

EMFLAGS_OPTIMIZED= \
	-Oz \
	-flto \
	--closure 0 # closure removes too much code and was breaking bind parameters

EMFLAGS_DEBUG = \
	-s ASSERTIONS=2 \
	-O1

BITCODE_FILES = out/sqlite3.o out/extension-functions.o

SOURCE_API_FILES = src/api.js

EMFLAGS_PRE_JS_FILES = \
	--pre-js src/api.js

EXPORTED_METHODS_JSON_FILES = src/exported_functions.json src/exported_runtime_methods.json

all: optimized debug worker

.PHONY: debug
debug: dist/sql-wasm-debug.js dist/sql-wasm-debug.mjs dist/sql-web-wasm-debug.js dist/sql-web-wasm-debug.mjs

dist/sql-wasm-debug.mjs: $(BITCODE_FILES) $(SOURCE_API_FILES) $(EXPORTED_METHODS_JSON_FILES)
	$(EMCC) $(EMFLAGS) $(EMFLAGS_DEBUG) $(EMFLAGS_WASM) -s MODULARIZE=1 $(BITCODE_FILES) $(EMFLAGS_PRE_JS_FILES) -o $@

dist/sql-wasm-debug.js: $(BITCODE_FILES) $(SOURCE_API_FILES) $(EXPORTED_METHODS_JSON_FILES)
	$(EMCC) $(EMFLAGS) $(EMFLAGS_DEBUG) $(EMFLAGS_WASM) $(BITCODE_FILES) $(EMFLAGS_PRE_JS_FILES) -o $@

dist/sql-web-wasm-debug.js: $(BITCODE_FILES) $(SOURCE_API_FILES) $(EXPORTED_METHODS_JSON_FILES)
	$(EMCC) $(EMFLAGS) $(EMFLAGS_DEBUG) $(EMFLAGS_WASM) $(EMFLAGS_WEB) $(BITCODE_FILES) $(EMFLAGS_PRE_JS_FILES) -o $@

dist/sql-web-wasm-debug.mjs: $(BITCODE_FILES) $(SOURCE_API_FILES) $(EXPORTED_METHODS_JSON_FILES)
	$(EMCC) $(EMFLAGS) $(EMFLAGS_DEBUG) $(EMFLAGS_WASM) $(EMFLAGS_WEB) -s MODULARIZE=1 $(BITCODE_FILES) $(EMFLAGS_PRE_JS_FILES) -o $@

.PHONY: optimized
optimized: dist/sql-wasm.js dist/sql-wasm.mjs dist/sql-web-wasm.js dist/sql-web-wasm.mjs

dist/sql-wasm.js: $(BITCODE_FILES) $(SOURCE_API_FILES) $(EXPORTED_METHODS_JSON_FILES)
	$(EMCC) $(EMFLAGS) $(EMFLAGS_OPTIMIZED) $(EMFLAGS_WASM) $(BITCODE_FILES) $(EMFLAGS_PRE_JS_FILES) -o $@

dist/sql-wasm.mjs: $(BITCODE_FILES) $(SOURCE_API_FILES) $(EXPORTED_METHODS_JSON_FILES)
	$(EMCC) $(EMFLAGS) $(EMFLAGS_OPTIMIZED) $(EMFLAGS_WASM) -s MODULARIZE=1 $(BITCODE_FILES) $(EMFLAGS_PRE_JS_FILES) -o $@

dist/sql-web-wasm.js: $(BITCODE_FILES) $(SOURCE_API_FILES) $(EXPORTED_METHODS_JSON_FILES)
	$(EMCC) $(EMFLAGS) $(EMFLAGS_OPTIMIZED) $(EMFLAGS_WASM) $(EMFLAGS_WEB) $(BITCODE_FILES) $(EMFLAGS_PRE_JS_FILES) -o $@

dist/sql-web-wasm.mjs: $(BITCODE_FILES) $(SOURCE_API_FILES) $(EXPORTED_METHODS_JSON_FILES)
	$(EMCC) $(EMFLAGS) $(EMFLAGS_OPTIMIZED) $(EMFLAGS_WASM) $(EMFLAGS_WEB) -s MODULARIZE=1 $(BITCODE_FILES) $(EMFLAGS_PRE_JS_FILES) -o $@

# Web worker API
.PHONY: worker
worker: dist/worker.sql-wasm.js dist/worker.sql-wasm-debug.js

dist/worker.sql-wasm.js: dist/sql-wasm.js src/worker.js
	cat $^ > $@

dist/worker.sql-wasm-debug.js: dist/sql-wasm-debug.js src/worker.js
	cat $^ > $@

out/sqlite3.o: sqlite-src/$(SQLITE_AMALGAMATION)
	mkdir -p out
	# Generate llvm bitcode
	$(EMCC) $(SQLITE_COMPILATION_FLAGS) -c sqlite-src/$(SQLITE_AMALGAMATION)/sqlite3.c -o $@

# Since the extension-functions.c includes other headers in the sqlite_amalgamation, we declare that this depends on more than just extension-functions.c
out/extension-functions.o: sqlite-src/$(SQLITE_AMALGAMATION)
	mkdir -p out
	# Generate llvm bitcode
	$(EMCC) $(SQLITE_COMPILATION_FLAGS) -c sqlite-src/$(SQLITE_AMALGAMATION)/extension-functions.c -o $@

# TODO: This target appears to be unused. If we re-instatate it, we'll need to add more files inside of the JS folder
# module.tar.gz: test package.json AUTHORS README.md dist/sql-asm.js
# 	tar --create --gzip $^ > $@

## cache
cache/$(SQLITE_AMALGAMATION).zip:
	mkdir -p cache
	curl -LsSf '$(SQLITE_AMALGAMATION_ZIP_URL)' -o $@

cache/$(EXTENSION_FUNCTIONS):
	mkdir -p cache
	curl -LsSf '$(EXTENSION_FUNCTIONS_URL)' -o $@

## sqlite-src
.PHONY: sqlite-src
sqlite-src: sqlite-src/$(SQLITE_AMALGAMATION) sqlite-src/$(SQLITE_AMALGAMATION)/$(EXTENSION_FUNCTIONS)

sqlite-src/$(SQLITE_AMALGAMATION): cache/$(SQLITE_AMALGAMATION).zip sqlite-src/$(SQLITE_AMALGAMATION)/$(EXTENSION_FUNCTIONS)
	mkdir -p sqlite-src/$(SQLITE_AMALGAMATION)
	echo '$(SQLITE_AMALGAMATION_ZIP_SHA3)  ./cache/$(SQLITE_AMALGAMATION).zip' > cache/check.txt
	sha3sum -a 256 -c cache/check.txt
	# We don't delete the sqlite_amalgamation folder. That's a job for clean
	# Also, the extension functions get copied here, and if we get the order of these steps wrong,
	# this step could remove the extension functions, and that's not what we want
	unzip -u 'cache/$(SQLITE_AMALGAMATION).zip' -d sqlite-src/
	touch $@

sqlite-src/$(SQLITE_AMALGAMATION)/$(EXTENSION_FUNCTIONS): cache/$(EXTENSION_FUNCTIONS)
	mkdir -p sqlite-src/$(SQLITE_AMALGAMATION)
	echo '$(EXTENSION_FUNCTIONS_SHA1)  ./cache/$(EXTENSION_FUNCTIONS)' > cache/check.txt
	sha1sum -c cache/check.txt
	cp 'cache/$(EXTENSION_FUNCTIONS)' $@


.PHONY: clean
clean:
	rm -f out/* dist/* cache/*
	rm -rf sqlite-src/

.PHONY: clean-nocache
clean-nocache:
	rm -f out/* dist/*
