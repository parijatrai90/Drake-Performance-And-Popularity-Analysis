# -*- coding: utf-8 -*-
"""
Created on Sun Oct 08 22:50:48 2017

@author: Uma
"""
#import the necessary libs
import requests
import pandas as pd
import time
import csv

#read in the file and make it a list
files = pd.read_csv("D:\MS-BAIM\Big Data\songids.csv",index_col=False,header=None)
songs = files.iloc[:,0].tolist()
#songs = list(song)
#songs = ["6mICuAdrwEjh6Y6lroV2Kg","7DM4BPaS7uofFul3ywMe46","3AEZUABDXNtecAOSC1qTfo"]
#songs = 
var=list()
atts = list()
#iterate thru the songs
for song in songs:
    att = list()
    url = "https://api.spotify.com/v1/audio-features/%s" %(song)
    data = requests.get(url, headers={"Authorization": "Bearer BQCcVqBUb0Gab6LtQMH6AM2mcuINA9WiDtmFJXvBOFBB16A0BECRRRH4o0re4uuZD578i0Gz1ImWZ8jiuPsd15PDQIJvQvodh1PPB7FmjBOhkKjjzHbNhv4Rt8gOzf962c3VsETVqiUEdOU31VwPFsGQqLYbET8gUtOY-2yxoiAIoCiZ2EwjscHWw8WOarTF9V0kfwlZErxwsKvI4_uQIojn8g71e1EWNwX8okkXp7mZ3xoLFu57ZHw895nu20puEZ3IzBxMAGfAsiDZo6Nj2ynZDPgiOv96R9p9HRBJrIhFoaW98qUO88kmMCqPEqpDihOQOkWV03fmXUIT5tsesA"})
    #leaving a sleep here to make sure the API doesnt break
    time.sleep(5)
    #cleaning the datalist to get the attributes
    #accessing the vars and attributes here
    songdata = data.content
    #creating a list of it
    songatts = songdata.split("\n")
    for items in songatts:
        if len(items)<2: continue
        var.append(items.split('"')[1])
        att.append(items.split('"')[2:])
    #making sure the attributes are in a clean list
    for num in att:
        if len(num)==1:
            #this actually happens in a few nodes, where theres only numeric data
            if (len(str(num))-3 > 5): 
                atts.append(str(num)[5:len(str(num))-3])
            #there's only one datapoint here, but making sure it works
            else:
                atts.append(str(num)[4:len(str(num))-2])
        #when i have the more char data to deal with
        else:
            atts.append(str(num[1]))

#i need onli 18 vars, so i can subset it
var = var[0:18]
            
#creating a dataframe to be exported
df1 = pd.DataFrame(var)
nsong = len(atts)/len(var)
#splittin the list into the songs
def split_list(alist, wanted_parts=1):
    length = len(alist)
    #this part makes sure that i split it into nsong #of songs
    return [ alist[i*length // wanted_parts: (i+1)*length // wanted_parts] 
             for i in range(wanted_parts) ]
songsdata = split_list(atts,nsong)
#creating a cbind on the dataframes
for i in range(nsong):
    df1 = pd.concat([df1.reset_index(drop=True),pd.DataFrame(songsdata[i])], axis=1)

#creating a final output file
#creating column names

numsongs = [""]*nsong
colnames = ["vars"]
colnames = colnames+numsongs
df1.columns = colnames
#transposing it to create one row per song
returning = df1.set_index('vars').T

returning.to_csv("EUbottom381-500.csv")