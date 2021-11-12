code_coverage:
	fvm flutter pub run code_coverage -m 80 -u

test_watch:
	dart scripts/watcher.dart fvm flutter test