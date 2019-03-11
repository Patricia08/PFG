#!/usr/bin/python3


import os


block_list=["https://www.marca.com/futbol/sevilla.html?intcmp=MENUESCU&s_kw=sevilla","https://elpais.com/elpais/2017/06/09/fotorrelato/1497018821_433369.html"]

for item in block_list:

  item2 = item.split("/", 3)
  item2.pop()
  print(item2)
  
  item3 = "/".join(item2)
  #item3 = " ".join(item2[1])
  #item3 = " ".join(item2[2])
  print(item3) 