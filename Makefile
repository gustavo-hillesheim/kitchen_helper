code_coverage:
	fvm flutter pub run code_coverage \
	-m 80 -u \
	-e domain \
	-e core \
	-e main.dart \
	-e data\\\\repository\\\\sqlite_ingredient_repository.dart \
	-e presenter\\\\app_widget.dart \
	-e presenter\\\\constants.dart \
	-i domain\\\\usecases \
	-i core\\\\sqlite\\\\sqlite_repository.dart

test_run:
	fvm flutter test --reporter expanded

test_watch:
	dart scripts/watcher.dart fvm flutter test --reporter expanded

build_runner:
	fvm flutter pub run build_runner build --delete-conflicting-outputs