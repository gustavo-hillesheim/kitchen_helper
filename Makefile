icons:
	fvm flutter pub run flutter_launcher_icons:main

splash_screen:
	fvm flutter pub run flutter_native_splash:create

build_app:
	fvm flutter build appbundle --obfuscate --split-debug-info=symbols

read_stacktrace:
	fvm flutter symbolize -i stacktraces/$(filter-out $@, $(MAKECMDGOALS)) -d symbols/app.android-arm64.symbols

code_coverage:
	fvm flutter pub run code_coverage \
	-m 80 -u --ignoreBarrelFiles \
	-e core \
	-e database \
	-e main.dart \
	-e presenter \
	-e app_guard.dart \
	-e app_module.dart \
	-i usecases

code_coverage_ci:
	flutter pub run code_coverage \
	-m 80 -u \
	-e core \
	-e database \
	-e main.dart \
	-e presenter \
	-e app_guard.dart \
	-e app_module.dart \
	-i usecases

run_tests:
	fvm flutter test --reporter expanded

watch_tests:
	fvm dart scripts/watcher.dart fvm flutter test --reporter expanded

watch_test:
	fvm dart scripts/watch_test_file.dart $(filter-out $@, $(MAKECMDGOALS))

build_runner:
	fvm flutter pub run build_runner build --delete-conflicting-outputs

build_runner_ci:
	flutter pub run build_runner build --delete-conflicting-outputs