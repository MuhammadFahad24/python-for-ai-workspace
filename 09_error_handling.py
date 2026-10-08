try:
    age = int(input("Enter your Age: "))
    print(age)
except:
    print("Invalid Input")
else:
    print("Age Accepted")
finally:
    print("Program Finished")