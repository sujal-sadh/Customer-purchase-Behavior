"""
Project: Customer Purchase Behavior Analysis
Author: Sujal Sadh
Description:
This script performs data cleaning, feature engineering,
and loads the processed dataset into PostgreSQL
for further SQL-based analytics.
"""

# ---------------------------------------------------------
# 1️⃣ Import Required Libraries
# ---------------------------------------------------------
import pandas as pd
from sqlalchemy import create_engine
from urllib.parse import quote_plus


# ---------------------------------------------------------
# 2️⃣ Load Dataset
# ---------------------------------------------------------
try:
    df = pd.read_csv(r"C:\projects\customer behavior project\data\Customer_Purchase_Behavior.csv")
    print("✅ Dataset loaded successfully.")
except FileNotFoundError:
    print("❌ File not found. Please check the file path.")
    raise


# ---------------------------------------------------------
# 3️⃣ Initial Data Inspection
# ---------------------------------------------------------
print("\n🔎 Dataset Preview:")
print(df.head())

print("\n📊 Dataset Info:")
print(df.info())

print("\n📈 Statistical Summary:")
print(df.describe(include='all'))


# ---------------------------------------------------------
# 4️⃣ Standardize Column Names
# ---------------------------------------------------------
df.columns = (
    df.columns
    .str.strip()
    .str.lower()
    .str.replace(' ', '_')
)

# Rename specific column
df = df.rename(columns={'purchase_amount_(usd)': 'purchase_amount'})


# ---------------------------------------------------------
# 5️⃣ Check Missing Values
# ---------------------------------------------------------
print("\n🧹 Missing Values:")
print(df.isnull().sum())


# ---------------------------------------------------------
# 6️⃣ Handle Missing Review Ratings (Category Median Imputation)
# ---------------------------------------------------------
df['review_rating'] = df.groupby('category')['review_rating'].transform(
    lambda x: x.fillna(x.median())
)


# ---------------------------------------------------------
# 7️⃣ Feature Engineering
# ---------------------------------------------------------

# 🔹 Age Segmentation (Quartile-Based)
age_labels = ['Young', 'Adult', 'Middle_Aged', 'Senior']
df['age_group'] = pd.qcut(df['age'], q=4, labels=age_labels)


# 🔹 Map Purchase Frequency to Numeric Days
frequency_mapping = {
    'Fortnighty': 14,
    'Bi-Weekly': 14,
    'Weekly': 7,
    'Monthly': 30,
    'Quarterly': 90,
    'Every 3 Months': 90,
    'Annually': 365
}

df['purchase_frequency_days'] = df['frequency_of_purchases'].map(frequency_mapping)


# ---------------------------------------------------------
# 8️⃣ Validate Redundant Columns
# ---------------------------------------------------------
columns_match = (df['discount_applied'] == df['promo_code_used']).all()

print(f"\n🔍 Discount column matches Promo Code column: {columns_match}")

# Drop redundant column if logically identical
df = df.drop(columns=['promo_code_used'])


# ---------------------------------------------------------
# 9️⃣ Connect to PostgreSQL & Load Data
# ---------------------------------------------------------

# 🔐 Database Credentials (Modify as needed)
username = "postgres"
password = quote_plus("YOUR_PASSWORD")   # Replace securely
host = "localhost"
port = "5432"
database = "customer_behavior"

# Create SQLAlchemy Engine
engine = create_engine(
    f"postgresql+psycopg2://{username}:{password}@{host}:{port}/{database}"
)

# Load DataFrame into PostgreSQL
try:
    df.to_sql("customer", engine, if_exists="replace", index=False)
    print("✅ Data successfully loaded into PostgreSQL.")
except Exception as e:
    print("❌ Failed to load data into PostgreSQL.")
    print(e)


# ---------------------------------------------------------
# 🔟 Script Completed
# ---------------------------------------------------------
print("\n🚀 Data preprocessing and database loading completed successfully!")
