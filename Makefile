icons:
	fvm flutter pub run flutter_launcher_icons:main

splash_screen:
	fvm flutter pub run flutter_native_splash:create

code_coverage:
	fvm flutter pub run code_coverage \
	-m 80 -u --ignoreBarrelFiles \
	-e domain \
	-e core \
	-e database \
	-e main.dart \
	-e presenter\\\\app_widget.dart \
	-e presenter\\\\constants.dart \
	-e app_guard.dart \
	-e app_module.dart \
	-i domain\\\\usecases \
	-i database\\\\sqlite

code_coverage_ci:
	flutter pub run code_coverage \
	-m 80 -u \
	-e domain \
	-e core \
	-e database \
	-e main.dart \
	-e presenter\\\\app_widget.dart \
	-e presenter\\\\constants.dart \
	-e app_guard.dart \
	-e app_module.dart \
	-i domain\\\\usecases \
	-i database\\\\sqlite

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