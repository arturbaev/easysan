#!/usr/bin/env python3

print("Content-type: text/html")
print()
print("<h1>Hello world!</h1>")
import cgi

form = cgi.FieldStorage()

servername = form.getvalue("servername")
print("servername")
