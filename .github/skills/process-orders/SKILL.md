---
name: process-orders
description: Manage customer order processing from placement to completion.
---

# Order Processing Skill

This skill outlines the workflow for managing customer orders from placement to completion (AW-02).

## Overview
Orders transition through the following states: `Pending` -> `Completed` (or cancelled). Admins manage this flow to ensure timely fulfillment.

## Workflow

### 1. Review Pending Orders
- **Action**: Navigate to `/admin/orders` or click "Pending Orders" in the admin dashboard.
- **Goal**: Verify payment (simulated) and stock allocation.
- **Reference**: `orders = Order.query.filter_by(status='pending')`

### 2. Update Order Status
- **Action**: Click the "Complete" button next to a pending order.
- **Effect**: Updates status to `completed` in the database.
- **Note**: Marking as complete assumes the item has been shipped/collected.

### 3. View Order Details
- **Action**: Click "View" on any order.
- **Details**: Shows customer info, order date, and list of items with prices.
- **Technical**: Uses `joinedload` to efficiently fetch `Order.items` and `OrderItem.product`.

## Relevant Files
- `app.py` (Order routes: `admin_orders`, `update_order_status`)
- `templates/admin_orders.html` (Order management list)
- `templates/orders.html` (Customer-facing view)
