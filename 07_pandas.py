import pandas as pd

data = {
    "Name" : ["Chris", "Mitchell", "Andrew"],
    "Age" : [20, 22, 21]
}

df = pd.DataFrame(data)

df.loc[2, "Name"] ="Anderson"
print(df)
print(df) # USe for Print Whole Dictionary
print(df["Name"]) # Use for Print Columns by Columns according to the name
print(df.iloc[0]) # USe for Print Rows according to Indexing