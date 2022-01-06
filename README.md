# Kitchen Helper

A mobile app intended to help independent kitchen workers calculate the cost and profit of their products, and manage their orders.

# Code Structure

The project's code structure is based on [Clean Archicture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) principles, represented in layers as follows:

- **Core Layer**: Common classes used throughout the whole application;
- **Domain Layer**: Business models, as well as interfaces for their repositories
  and Use Cases to execute business logic;
- **Data Layer**: Implementations of repository interfaces defined in the Domain
  Layer;
- **Presenter Layer**: UI related classes, app screens, common widgets used
  throughout multiple screen, constant values, parsing/formatting and
  validations classes;
- **Database Layer**: Base database classes and implementations.

All these layers are put together inside [app_module](./lib/app_module.dart), which defines the AppModule using [flutter_modular](https://pub.dev/packages/flutter_modular) to define routes to each screen and register services in the Dependency Injection system.

# Testing

Testing is done mainly using [Test Driven Development](https://wikipedia.org/wiki/Test-driven_development), using the [code_coverage](https://pub.dev/packages/code_coverage) package to point what parts of the code are not tested yet.<br>
The minimum coverage accepted is 80%, but I seek to achieve at least 95%, although files that don't have useful code are ignored (ex.: barrel files, files without runnable code).

# Commands

Some commands were create using [Makefile](https://en.wikipedia.org/wiki/Make_(software)#Makefile) to simplify and store complex commands, they are:

- **run_tests**: Runs all tests;
- **watch_tests**: Runs all tests on file changes;
- **watch_test**: Runs a specific test file on file changes;
- **build_runner**: Runs the build_runner build command;
- **build_runner_ci**: Runs the build_runner build command but is only used in Github Actions;
- **code_coverage**: Runs tests and reports the project's code coverage;
- **code_coverage_ci**: Runs tests and reports the project's code coverage but is only used in Github Actions;

# Scripts

There are some custom scripts to fill gaps commands cannot, they are listed here:

- **watch_test_file**: Finds the absolute path of a test file by its name (with or without _test suffixed) and runs it every time a file change is detected (from both `lib` and `test` directories). Example usage: `dart scripts/watch_test_file.dart delete_ingredient_usecase`;
- **watcher**: Watches file changes from `lib` and `test` directories, and runs a command on each change. Example usage: `dart scripts/watcher.dart flutter test`.
