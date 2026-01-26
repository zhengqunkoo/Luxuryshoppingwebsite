# Architecture & UML Diagrams

This directory contains the auto-generated UML diagrams for the Luxury Shopping Website.

## Class Relationships (Manual Analysis)

Based on `app.py`, the following core relationships exist:

### Users & Authentication
- **User**: The central actor.
  - Attributes: `id`, `username`, `email`, `password_hash`, `is_admin`.
  - Relationships:
    - One-to-Many with **Cart** items.
    - One-to-Many with **Order**s.

### Products & Catalog
- **Product**: Represents items for sale.
  - Attributes: `id`, `name`, `description`, `price`, `category`, `stock`.
  - Relationships:
    - Referenced by **Cart** items (Many-to-One from Cart to Product).
    - Referenced by **OrderItem**s (Many-to-One from OrderItem to Product).

### Shopping Cart
- **Cart**: Represents items currently in a user's basket.
  - Attributes: `id`, `quantity`.
  - Relationships:
    - Belongs to **User**.
    - Belongs to **Product**.

### Orders
- **Order**: Represents a finalized purchase.
  - Attributes: `id`, `total_amount`, `status`.
  - Relationships:
    - Belongs to **User**.
    - One-to-Many with **OrderItem**s.

- **OrderItem**: Represents a specific product within an order.
  - Attributes: `id`, `quantity`, `price`.
  - Relationships:
    - Belongs to **Order**.
    - Belongs to **Product**.

## Diagrams

The diagrams are generated automatically via GitHub Actions using `pyreverse`.

- `classes_LuxuryShoppingArchitecture.png`: Class diagram showing attributes and methods.
- `packages_LuxuryShoppingArchitecture.png`: Package dependencies (if applicable).
