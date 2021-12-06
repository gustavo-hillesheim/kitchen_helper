code_coverage:
	fvm flutter pub run code_coverage \
	-m 80 -u \
	-e domain \
	-e core \
	-e main.dart \
	-e data\\\\repository\\\\sqlite_ingredient_repository.dart \
	-e presenter\\\\app_widget.dart \
	-e presenter\\\\constants.dart \
	-e app_guard.dart \
	-e app_module.dart \
	-i domain\\\\usecases \
	-i core\\\\sqlite\\\\sqlite_repository.dart

code_coverage_ci:
	flutter pub run code_coverage \
	-m 80 -u \
	-e domain \
	-e core \
	-e main.dart \
	-e data\\\\repository\\\\sqlite_ingredient_repository.dart \
	-e presenter\\\\app_widget.dart \
	-e presenter\\\\constants.dart \
	-e app_guard.dart \
	-e app_module.dart \
	-i domain\\\\usecases \
	-i core\\\\sqlite\\\\sqlite_repository.dart

test_run:
	fvm flutter test --reporter expanded

test_watch:
	fvm dart scripts/watcher.dart fvm flutter test --reporter expanded

watch_test_file:
	fvm dart scripts/watch_test_file.dart $(filter-out $@, $(MAKECMDGOALS))

build_runner:
	fvm flutter pub run build_runner build --delete-conflicting-outputs

build_runner_ci:
	flutter pub run build_runner build --delete-conflicting-outputs