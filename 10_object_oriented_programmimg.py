class Chatbot:
    def __init__(self, name, language):
        self.name = name
        self.language = language

    def greet(self):
        print(f"Hello! I'm {self.name} your AI Assistant & My Language is {self.language}.")

bot = Chatbot("Botly", "English")
print(bot)

bot.greet()

# class Dog:
#     def __init__(self, name):
#         self.name = name

#     def bark(self):
#         print("Bark!!!")

# jerry = Dog(name="Jerry")

# jerry.name
# jerry.bark()

#-----------------------------

# Parent Class - General Animal
class Animal:
    def __init__(self, name):
        self.name = name

    def eat(self):
        return f"{self.name} is Eating!"

    def sleep(self):
        return f"{self.name} is Sleeping!"

# Child Class - Specific Animal
class Dog(Animal):
    def bark(self):
        return f"{self.name} says Woof!"

# Create a Dog - using positional argument
my_dog = Dog("Buddy")
# or with named argument
my_dog2 = Dog(name="Max")

# Dog can do Animal Things (inherited)
print(my_dog.eat())
print(my_dog.sleep())
print(my_dog.bark())