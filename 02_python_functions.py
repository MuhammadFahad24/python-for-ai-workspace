## FUNCTIONS:
def greet():
    print("Hello!")
    print("Hello again!")

greet()

def say_goodbye():
    print("Goodbye!")
    print("See you later!")

say_goodbye()
say_goodbye()
say_goodbye()

def check_weather():
    temperature = 55
    if temperature > 25:
        print("It's Hot!")
    else:
        print("It's Nice Weather!")

check_weather()



## FUNCTIONS WITH PARAMETERS:
def greet(name):
    print(f"Hello, {name}") # This is called an f-string, which allows you to embed expressions inside string literals.

greet("Fahad")

def greet(first_name="Muhammad", last_name="Fahad"):
    print(f"Hello, {first_name} {last_name}")

greet()

discount = 10 # This is called Global Variable, which is accessible throughout the entire program.
def calculate_total(price):
    tax_rate = 0.08 # This is called Local Variable, which is only accessible within the function it is defined in.
    tax = price * tax_rate # multiplying price by tax_rate to get the tax amount
    final_price = price + tax - discount # subtracting discount from the total price after adding tax
    print(f"Total ${final_price}")

calculate_total(price = 100)



## FUNTIONS WITH RETURN STATEMENTS:
def calculate_area(width, height):
    area = width * height
    area = area * 1.05
    return area
room_area = calculate_area(10, 12)
print(f"Room Area: {room_area} square feet")

def double(number):
    return number * 2

result = double(5)
result = double(5) + double(3)
result = double(10)

if double(7) > 10:
    print("It' a Big Number!")

def simple_function():
    number = [1, 2, 3, 4, 5]
    first_number = number[0] # Indexing
    last_number = number[-1]
    return first_number, last_number
f, l = simple_function()
print(f)
print(l)