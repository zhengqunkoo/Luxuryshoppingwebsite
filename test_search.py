#!/usr/bin/env python3
"""Test script for search functionality"""

from app import app, db, Product, User

def init_db():
    """Initialize database with test data"""
    with app.app_context():
        # Create tables
        db.create_all()
        
        # Check if we already have products
        if Product.query.count() > 0:
            print("Database already initialized")
            return
        
        # Add test products
        products = [
            Product(
                name="Luxury Watch",
                description="A premium Swiss-made timepiece",
                price=5999.99,
                category="Watches",
                stock=10,
                image_url="https://via.placeholder.com/300"
            ),
            Product(
                name="Designer Handbag",
                description="Elegant leather handbag",
                price=2499.99,
                category="Bags",
                stock=5,
                image_url="https://via.placeholder.com/300"
            ),
            Product(
                name="Diamond Necklace",
                description="Stunning diamond jewelry piece",
                price=15999.99,
                category="Jewelry",
                stock=3,
                image_url="https://via.placeholder.com/300"
            ),
            Product(
                name="Silk Scarf",
                description="Premium silk designer scarf",
                price=299.99,
                category="Accessories",
                stock=20,
                image_url="https://via.placeholder.com/300"
            )
        ]
        
        for product in products:
            db.session.add(product)
        
        db.session.commit()
        print(f"Added {len(products)} test products")

def test_search():
    """Test search functionality"""
    with app.app_context():
        # Test search for "watch"
        print("\n--- Testing search for 'watch' ---")
        products = Product.query.filter(
            db.or_(
                Product.name.ilike('%watch%'),
                Product.description.ilike('%watch%'),
                Product.category.ilike('%watch%')
            )
        ).all()
        print(f"Found {len(products)} products:")
        for p in products:
            print(f"  - {p.name} ({p.category})")
        
        # Test search for "diamond"
        print("\n--- Testing search for 'diamond' ---")
        products = Product.query.filter(
            db.or_(
                Product.name.ilike('%diamond%'),
                Product.description.ilike('%diamond%'),
                Product.category.ilike('%diamond%')
            )
        ).all()
        print(f"Found {len(products)} products:")
        for p in products:
            print(f"  - {p.name} ({p.category})")
        
        # Test search for "luxury"
        print("\n--- Testing search for 'luxury' ---")
        products = Product.query.filter(
            db.or_(
                Product.name.ilike('%luxury%'),
                Product.description.ilike('%luxury%'),
                Product.category.ilike('%luxury%')
            )
        ).all()
        print(f"Found {len(products)} products:")
        for p in products:
            print(f"  - {p.name} ({p.category})")
        
        # Test empty search
        print("\n--- Testing empty search ---")
        products = Product.query.all()
        print(f"Found {len(products)} products (all products)")

if __name__ == '__main__':
    print("Initializing database...")
    init_db()
    print("\nTesting search functionality...")
    test_search()
    print("\nSearch tests completed successfully!")
