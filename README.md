# Kitchen Helper

A mobile app intended to help independent kitchen workers calculate the cost and
profit of their products, and manage their orders.

# Code Structure

The project's code structure is based
on [Clean Archicture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
principles, represented in layers as follows:

- *Domain Layer*: Contains business models, as well as interfaces for their 
  repositories and Use Cases to execute business logic;
- *Core Layer*: Common classes used throughout the whole application, 
  extensions, abstract classes, and database connection 