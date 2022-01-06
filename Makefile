code_coverage:
	fvm flutter pub run code_coverage \
	-m 80 -u \
	-e domain \
	-e core \
	-e database \
	-e main.dart \
	-e presenter\\\\app_widget.dart \
	-e presenter\\\\constants.dart \
	-e presenter\\\\presenter.dart \
	-e presenter\\\\utils\\\\utils.dart \
	-e presenter\\\\widgets\\\\widgets.dart \
	-e presenter\\\\screens\\\\screens.dart \
	-e database\\\\sqlite\\\\sqlite.dart \
	-e domain\\\\usecases\\\\usecases.dart \
	-e domain\\\\usecases\\\\ingredient\\\\ingredient.dart \
	-e domain\\\\usecases\\\\recipe\\\\recipe.dart \
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
	-e presenter\\\\presenter.dart \
	-e presenter\\\\utils\\\\utils.dart \
	-e presenter\\\\widgets\\\\widgets.dart \
	-e presenter\\\\screens\\\\screens.dart \
	-e database\\\\sqlite\\\\sqlite.dart \
	-e domain\\\\usecases\\\\usecases.dart \
	-e domain\\\\usecases\\\\ingredient\\\\ingredient.dart \
	-e domain\\\\usecases\\\\recipe\\\\recipe.dart \
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