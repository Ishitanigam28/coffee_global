# ------------------------------
# STEP 2: LOAD & INSPECT DATA
# ------------------------------

# Import libraries
import pandas as pd

# Load CSV files
customers = pd.read_csv("customers.csv")
products = pd.read_csv("products.csv")
stores = pd.read_csv("stores.csv")
orders = pd.read_csv("orders.csv")
order_items = pd.read_csv("order_items.csv")

# Quick look at data
print("✅ Data Loaded Successfully!\n")

print("Customers:", customers.shape)
print("Products:", products.shape)
print("Stores:", stores.shape)
print("Orders:", orders.shape)
print("Order Items:", order_items.shape)

# Display first few rows of each dataset
print("\n--- Customers ---")
print(customers.head())

print("\n--- Orders ---")
print(orders.head())

print("\n--- Order Items ---")
print(order_items.head())

# Check data types and missing values
print("\n📋 Data Info:")
print(orders.info())

print("\n🔍 Missing Values:")
for name, df in {"customers":customers,"products":products,"stores":stores,"orders":orders,"order_items":order_items}.items():
    print(f"{name}: {df.isnull().sum().sum()} missing values")

# -------------------------------------------------
# STEP 3: DATA CLEANING & PREPARATION
# -------------------------------------------------

print("\n=======================")
print("STEP 3: DATA CLEANING")
print("=======================\n")

# ✅ 1. Convert date & time columns to proper formats
orders['order_date'] = pd.to_datetime(orders['order_date'], errors='coerce')
orders['order_time'] = pd.to_datetime(orders['order_time'], format='%H:%M:%S', errors='coerce').dt.time

customers['signup_date'] = pd.to_datetime(customers['signup_date'], errors='coerce')
stores['opened_date'] = pd.to_datetime(stores['opened_date'], errors='coerce')

print("✔️ Converted date and time columns.\n")

# ✅ 2. Ensure numeric columns are numeric
order_items['quantity'] = pd.to_numeric(order_items['quantity'], errors='coerce')
order_items['unit_price'] = pd.to_numeric(order_items['unit_price'], errors='coerce')
order_items['total_price'] = pd.to_numeric(order_items['total_price'], errors='coerce')

print("✔️ Numeric columns cleaned.\n")

# ✅ 3. Remove cancelled or returned orders
orders_cleaned = orders[orders['order_status'] == 'Completed'].copy()
print(f"✔️ Kept only completed orders: {orders_cleaned.shape[0]} rows remain.\n")

# ✅ 4. Drop duplicate rows (if any)
for name, df in {"customers":customers, "products":products, "stores":stores, "orders":orders_cleaned, "order_items":order_items}.items():
    before = df.shape[0]
    df.drop_duplicates(inplace=True)
    print(f"✔️ {name}: {before - df.shape[0]} duplicates removed.")

# ✅ 5. Merge order_items with orders for detailed transactions
merged_orders = pd.merge(order_items, orders_cleaned, on='order_id', how='inner')
print(f"\n✔️ Merged order_items + orders: {merged_orders.shape}\n")

# ✅ 6. Merge with products, customers, and stores
merged_orders = merged_orders.merge(products[['product_id', 'product_name', 'category', 'unit_price']],
                                    on='product_id', how='left')
merged_orders = merged_orders.merge(customers[['customer_id', 'country', 'city', 'loyalty_member']],
                                    on='customer_id', how='left')
merged_orders = merged_orders.merge(stores[['store_id', 'store_name', 'store_type', 'country']],
                                    on='store_id', how='left', suffixes=('_cust_country', '_store_country'))

print(f"✔️ Final merged data shape: {merged_orders.shape}\n")

# ✅ 7. Create order totals summary
order_totals = order_items.groupby('order_id', as_index=False)['total_price'].sum()
order_totals.rename(columns={'total_price':'order_total'}, inplace=True)
orders_cleaned = orders_cleaned.merge(order_totals, on='order_id', how='left')

# ✅ 8. Fill missing values
merged_orders.fillna({'shipping_delay_days':0, 'payment_method':'Unknown'}, inplace=True)

print("✔️ Missing values handled.\n")

# ✅ 9. Save cleaned datasets for next steps
orders_cleaned.to_csv("cleaned_orders.csv", index=False)
merged_orders.to_csv("coffee_sales_master.csv", index=False)

print("🎉 Data cleaning completed successfully!")
print("📁 Saved files:")
print("   → cleaned_orders.csv")
print("   → coffee_sales_master.csv\n")

# ✅ 10. Quick check
print("🔍 Sample of cleaned merged data:")
print(merged_orders.head())
