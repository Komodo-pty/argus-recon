#!/usr/bin/env python3

#Ignore if value is None / Null

import requests
import os
from bs4 import BeautifulSoup

#url = input("Enter URL: ")

url = os.environ["site"]
attr = ["href", "src"]

def url_scraper(url):
    page = requests.get(url)
    soup = BeautifulSoup(page.content,'html.parser')

    for item in attr:
        for t in soup.find_all():
            value = t.get(item)
            if value is not None:
                print(value + "\n")

url_scraper(url)
