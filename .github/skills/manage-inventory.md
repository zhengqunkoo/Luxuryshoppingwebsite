# Inventory Management Skill

This skill guides you through managing the product inventory for the Luxury Shopping Website, including stock tracking, restocks, and product updates (AW-04).

## Overview
The inventory system allows admins to view stock levels, identify low-stock items, process inbound shipments, and maintain the product catalog.

## Tasks

### 1. View Inventory Dashboard
- **Action**: Navigate to `/admin/inventory` (requires admin login).
- **Metrics**:
  - `Total Value`: Sum of `price * stock` for all items.
  - `Low Stock`: Count of items with ≤5 units (including pending restocks).
  - `Out of Stock`: Items with 0 units.

### 2. Manage Restocks
- **Trigger**: System alerts when stock + pending restocks ≤ 5.
- **Action**: Restock orders are tracked via the `RestockOrder` model.
- **Automated Process**: visiting `/admin/inventory` automatically processes delivered restocks (where `delivery_date <= now`).

### 3. Add/Edit Products
- **Add**: Use the "Add Product" button on the inventory page (`/admin/inventory/add_product`).
- **Edit**: Click "Edit" on any product row (`/admin/inventory/edit_product/<id>`).
- **Fields**: Ensure `category`, `price`, `stock`, and `image_url` are accurate.

## Relevant Files
- `app.py` (Inventory routes: `inventory`, `add_product`, `edit_product`)
- `templates/inventory.html` (Dashboard UI)
- `templates/add_product.html` (Form for add/edit)
