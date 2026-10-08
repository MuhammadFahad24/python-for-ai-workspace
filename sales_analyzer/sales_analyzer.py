sales = [
    {"product": "Laptop", "quantity": 3, "price": 800},
    {"product": "Mouse", "quantity": 10, "price": 25},
    {"product": "Keyboard", "quantity": 5, "price": 50},
    {"product": "Monitor", "quantity": 4, "price": 200}
]

garnd_total = 0

for sale in sales:
    total = sale["price"] * sale["quantity"]
    garnd_total = garnd_total + total
    print(f"Total: {sale["product"]} - ${total}")
print(f"Grand Total: ${garnd_total}")