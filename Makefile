code_coverage:
	fvm flutter pub run code_coverage -m 80 -u -e domain -e core -e main.dart -i domain\\\\usecases

test_watch:
	dart scripts/watcher.dart fvm flutter test --reporter expanded

build_runner:
	fvm flutter pub run build_runner build --delete-conflicting-outputs