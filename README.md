
VALID LICENSE FOR THIS PLUGIN IS AGPL Version 3.0
This KOreader plugin organizes ALL your eBooks of type epub, pdf, awz3, mobi, docx into a single collection!
Many people asked for such solution on Reddit and other

It works independent on how you have organized the structure (all books in one folder or like the structure that Calibre by default creates on your reader.

It works as a normal KOreader Collection at is standard called 'All Books'
You can click on the 'hamburger - or three horizontal stripes at left upper corner' menu in the collection view to sort the collection list.

More than 10.000 ebooks in a few hundred folders of Authors is created very fast is a few seconds. After a restart the Collection is visible.

Under menu Tools (wrench/screwdriver icon) go to next page (page 2) and click on More Tools > Click on All eBooks Collection
This will start the function.

That function can be coupled to a gesture that you like. I use swipe-up movement on right edge of my reader screen and that starts the creation of the collection.  Always restart KOreader after a new creation process to make the collection and its changes visible.  
You can repeat this function without any problem.

HOW TO USE GESTURES (> means click)
Menu Settings (wheel icon) > Taps and gestures > Gesture manager > One finger swipe > Right Edge Up > General > Page 2 (scroll) > CreateAllMyBooks Collection

HOW TO INSTALL
Copy the folder AllMyeBooks.koplugin  under KOreaders plugin folder (search where KOreader is installed)
Unzip when needed if downloaded as zip file 

AllMyeBooks.koplugin folder looks like:

AllMyeBooks.koplugin
 - main lua
 - _meta.lua
 - readme.txt (this file)


Have FUN.

PS: I used inspiration from a similar solution that was created as a patch but that was always using Favorites and it had severe issues with large collections..only a few hundred books otherwise it crashed. Only epub and pdf were processed.
If you have other types like .txt that you want to make visible look into the source code and and that looks like this (find it around lines 160-165):

    local pfile = popen('find "'..directory..'" -maxdepth 10 -type f  -name "*.epub" -o -name "*.pdf" -o -name "*.azw3" -o -name "*.mobi" -o -name "*.DOCX"  | sort ')   
    
  So if you want .txt then it will look like this  
    
        local pfile = popen('find "'..directory..'" -maxdepth 10 -type f  -name "*.epub" -o -name "*.pdf" -o -name "*.azw3" -o -name "*.mobi" -o -name "*.DOCX" -o -name "*.txt" | sort ')   
        
Note: I have tested it on Ubuntu and Android. i expect it will also work on Kobo as I use standard functions of KOreader.



