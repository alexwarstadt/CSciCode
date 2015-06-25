SPARKZILLA


MAIN CLASS
The name of our main class is Browser.java. 



OVERVIEW

The program begins in Browser.java class. The user is welcomed and prompted to input a number 1-3. Upon receiving this input, the Browser will do one of three things: attempt to move backward in the cache (which will be empty until the user visits a page), prompt the user to input a URL, or quit. These three options are available to the user at all times except when the user inputs invalid url, then it prompts them again. 


When the program receives a new URL, it begins to interact with the client. The client class opens a socket, using the host as given in the URL, and attempts to interact with the server in order to receive information about the page the user wants to go to. When the client gets a response from the server, it begins to parse this information. 


This is done in the HTMLParse class. An object of HTMLParse includes a tokenizer, two counters, a parsed HTMLPage, and two arrayLists, one to hold all fields (input, link, or submit) and another to hold all forms that are found as it parses the html string. However, it is important to note that fields are all of type Clickable, meaning they can be called upon by the user. The arrayList of fields has type Clickable. While parsing, there is a succession of calls made as the program begins to parse the string returned from the server. First, the program removes the header and begins to look at each tag of html in this string. The first method called creates a new HTMLPage. As the program moves through each tag, the program calls the corresponding parse method. For example, after moving beyond the openhtml tag, it sees a body tag and calls parseBody. parseBody instantiates an object of Body and takes all of the following tags along with it in order to parse the information in order. Next, it could see a paragraph or a link or a form, whichever tag is next in the html string. Thus, these parse methods are called accordingly. When a parse method is called, it instantiates an object and returns it to the the constructor in the method that called it, depending on the token that matches the tag.


It is here that our program makes use of our LL1 grammar. It is important to note that these elements are nested according to our LL1 grammar. Each methods holds information based on what the grammar requires or what the grammar expects the next possible elements to be. In this way, our classes are called and objects are created accordingly. Also, when the program arrives at a form tag, it will call this class, thus creating a Form object, while also adding this form to the form arrayList. When the program arrives at a link, input, or submit tag, it will call that class, instantiating the object, and adding the object to the arrayList of fields (of type Clickable). When each active element is parsed, the attribute assigned to this element is saved as an attribute of the new object that is instantiated. For example, the url associated with a link is saved as an attribute of the object that represents this link. After the entire html string has been parsed, the entire HTMLPage is then rendered. Each object has it’s own render method in order to be presented to the user properly. 

After the page is rendered, the Browser class prompts the user to input another number. Now that the user is at a page, they may input 1, causing the Browser to move backward in the cache and return to the previous page. However, this input number may also correspond to active elements on the page (links, input fields, or submit buttons). The number inputed by the user corresponds to a position of the active element in the fields arrayList. 


When a link is “clicked”, it will send the associated url to the browser to request this page from the server. Upon receiving a response, the program will collect the new information, parse it into a new HTMLPage, and render this page. Each page is added to the cache after it is parsed and rendered. 


When an input field is “clicked”, the user will be prompted to input a phrase to be inputed into the form. The input data will be saved into the form and can be seen in this input field. 


When a submit button is “clicked”, all input elements corresponding to this form will be collected and the associated form will be submitted to the server using the client’s POST commands. When the server responds, this information will then be parsed into a new page. This page will be rendered and presented to the reader.


These processes are continued as the user interacts with the program. When the user inputs an invalid URL, they will be notified and returned to the action line, allowing them to input another URL, go back, or quit. When the user does not input a number, they are asked to do so.






BUGS

Our back method had some weird behavior even after many attempts to fix it. We think it's all good now, but we thought that before and it wasn't.





COLLABORATORS
This project was co-programmed by Alexander Warstadt and Kamille Johnson.





DESCRIPTION OF TESTING
We began testing our program by considering all possible user inputs. These test cases can be found below. Each time we tested an aspect of the program, we pasted the result into this txt file.

First, we tested the URLs. We tested how the program would react if given a new URL, a new URL with a new host, a new URL with the same host, a bad host, a good host with a bad path, a string that was not a URL, or a URL that is too short to be valid. 

Next, we tested the back command (whenever a user inputs the number 1). We tested that the program would not go back when the user initially enters the program. We also tested the back command after the user has visited just one page, or after they have visited multiple pages.

Next, we tested forms, namely form input fields and submit buttons. We tested that a form could be parsed and rendered. We tested that the input fields would retain information after they are filled. We tested that the field could be submitted without any information and that multiple input could be submitted the same field and the field would be updated. We also tested submitted a form with ampersands in the input fields as these strings would need to be encoded in order to be read by the server. Lastly, we tested that a user could submit a form and view this submitted information upon navigating back to the form. However, when the user calls a page with a form, submits, navigates back and away from this page, then attempts to return to the page, the page is received from the server again and parsed and rendered as a new page. As a result, the information submitted to the page when the user first navigated will not be saved because the user has returned to a new instance of this page.

Another element of the program that we tested were the links. The url assigned to the link is collected and the url is instantiated such that the client uses the url to interact with the server and receive the page that corresponds to the url. We tested that this process occurs when a link is “clicked.”

Lastly, we tested quit. These test cases demonstrate that the user may quit from any page. They may quit from initially entering the program, from a form, or from a new page.

In terms of testing html inputs as received from the server, we created a new method in Browser called fileTest. This is called when the user inputs -100, allowing the user to then input a file name to be read from. Each file contains html for the program to read and parse. We created multiple files to be read, all of which test unique aspects of the program. For example, we have a file that is empty. These files test the program’s ability  to react to differing and problematic html inputs.























TESTING


BACK
cannot go back on upon entering program - 
	/gpfs/main/home/awarstad/course/cs018/workspace/javaproject/src $ java spark1.Browser
	Welcome to Sparkzilla.
	Action: (1) Back, (2) New URL, (3) Quit: 1
	This is the first page in the cache. You can't go back.
	Action: (1) Back, (2) New URL, (3) Quit: 2





back after first page -
/gpfs/main/home/awarstad/course/cs018/workspace/javaproject/src $ java spark1.Browser
Welcome to Sparkzilla.
Action: (1) Back, (2) New URL, (3) Quit: 2
Please enter a URL: http://rna/Index
Parsing page...
Welcome to the Server on rna!
<The Forums!> [4]
<The Pizza Parlor!> [5]
<Nim> [6]
<Fight in the Coliseum!> [7]
Action: (1) Back, (2) New URL, (3) Quit, (4-7) Select Page Element: 1
Welcome back to the SparkZilla home page!
Action: (1) Back, (2) New URL, (3) Quit: 



back after traversing multiple pages
Please enter a URL: http://rna/Index
Parsing page...
Welcome to the Server on rna!
<The Forums!> [4]
<The Pizza Parlor!> [5]
<Nim> [6]
<Fight in the Coliseum!> [7]
Action: (1) Back, (2) New URL, (3) Quit, (4-7) Select Page Element: 6
Parsing page...
Welcome to Nim!
There are currently 21 matches.  How many would you like to remove?
<One> [4]
<Two> [5]
<Three> [6]
Action: (1) Back, (2) New URL, (3) Quit, (4-6) Select Page Element: 5
Parsing page...
You removed 2 matches.
The computer removed 2 matches.
There are currently 17 matches.  How many would you like to remove?
<One> [4]
<Two> [5]
<Three> [6]
Action: (1) Back, (2) New URL, (3) Quit, (4-6) Select Page Element: 1
Welcome to Nim!
There are currently 21 matches.  How many would you like to remove?
<One> [4]
<Two> [5]
<Three> [6]
Action: (1) Back, (2) New URL, (3) Quit, (4-6) Select Page Element: 1
Welcome to the Server on rna!
<The Forums!> [4]
<The Pizza Parlor!> [5]
<Nim> [6]
<Fight in the Coliseum!> [7]
Action: (1) Back, (2) New URL, (3) Quit, (4-7) Select Page Element: 1
Welcome back to the SparkZilla home page!
Action: (1) Back, (2) New URL, (3) Quit:




back after submitting
Action: (1) Back, (2) New URL, (3) Quit, (4-6) Select Page Element: 4
Input value for field size:small
You have just put small in the field size

Action: (1) Back, (2) New URL, (3) Quit, (4-6) Select Page Element: 5
Parsing page...
This is your order. Size: SMALL
 Change size (Small, Medium, Large)_______[4]
 Add topping_______[5]
 Remove topping_______[6]
[Submit][7]
<Order the pizza. > [8]
<Go Home > [9]

Action: (1) Back, (2) New URL, (3) Quit, (4-9) Select Page Element: 1
Welcome to the pizza parlor!
 What size pizza do you want? (Small, Medium, Large)small[4]
[Submit][5]
<Go Home > [6]

Action: (1) Back, (2) New URL, (3) Quit, (4-6) Select Page Element: 



























URL
Enter new URL
/gpfs/main/home/awarstad/course/cs018/workspace/javaproject/src $ java spark1.Browser
Welcome to Sparkzilla.
Action: (1) Back, (2) New URL, (3) Quit: 2
Please enter a URL: http://rna/Index
Parsing page...
Welcome to the Server on rna!<The Forums!> [4]
<The Pizza Parlor!> [5]
<Nim> [6]
<Fight in the Coliseum!> [7]
Action: (1) Back, (2) New URL, (3) Quit, (4-7) Select Page Element: 

Enter new URL with new host
Action: (1) Back, (2) New URL, (3) Quit, (4-8) Select Page Element: 2
Please enter a URL: http://peptide/Index
Parsing page...

Welcome to the Server on peptide!
<The Forums!> [4]
<The Pizza Parlor!> [5]
<Nim> [6]
<Fight in the Coliseum!> [7]


Action: (1) Back, (2) New URL, (3) Quit, (4-7) Select Page Element:


Enter an invalid URL
/gpfsk1.Browser/awarstad/course/cs018/workspace/javaproject/src $ java spark
Welcome to Sparkzilla.
Action: (1) Back, (2) New URL, (3) Quit: 2
Please enter a URL: asfdyigfasdln
Not a valid URL. Please try again.
hajfd/hjozvc/
Not a valid URL. Please try again.




URL is too short
/gpfs/main/home/awarstad/course/cs018/workspace/javaproject/src $ java spark1.Browser
Welcome to Sparkzilla.
Action: (1) Back, (2) New URL, (3) Quit: 2
Please enter a URL: shd
Not a valid URL. Please try again.
http:/
Not a valid URL. Please try again.




/gpfs/main/home/awarstad/course/cs018/workspace/javaproject/src $ java spark1.Browser
Welcome to Sparkzilla.
Action: (1) Back, (2) New URL, (3) Quit: 2
Please enter a URL: http://a
host not found.
Action: (1) Back, (2) New URL, (3) Quit: 





Good host, bad path.
/gpfs/main/home/awarstad/course/cs018/workspace/javaproject/src $ java spark1.Browser
Welcome to Sparkzilla.
Action: (1) Back, (2) New URL, (3) Quit: 2
Please enter a URL: http://rna/adsuhofqlrew
Path cannot be found
Action: (1) Back, (2) New URL, (3) Quit: 





Bad host, good path.
/gpfs/main/home/awarstad/course/cs018/workspace/javaproject/src $ java spark1.Browser
Welcome to Sparkzilla.
Action: (1) Back, (2) New URL, (3) Quit: 2
Please enter a URL: http://aufdsho/Index
host not found.
Action: (1) Back, (2) New URL, (3) Quit: 





Action: (1) Back, (2) New URL, (3) Quit, (4-8) Select Page Element: 2
Please enter a URL: http://thufir/Index
host not found.


Action: (1) Back, (2) New URL, (3) Quit, (4-8) Select Page Element:


























FORM
Enter a form

Parsing page...
Welcome to the Server on rna!<The Forums!> [4]
<The Pizza Parlor!> [5]
<Nim> [6]
<Fight in the Coliseum!> [7]
Action: (1) Back, (2) New URL, (3) Quit, (4-7) Select Page Element: 5
Parsing page...
Welcome to the pizza parlor!
 What size pizza do you want? (Small, Medium, Large)_______[4]
[Submit][5]
<Go Home > [6]






Input
Action: (1) Back, (2) New URL, (3) Quit, (4-6) Select Page Element: 4
Input value for field size:Medium
You have just put Medium in the field size



input nothing into a form and submit.
Parsing page...

This is your order.
 Size: SMALL

 Change size (Small, Medium, Large)_______[4]
 Add topping_______[5]
 Remove topping_______[6]
[Submit][7]
<Order the pizza. > [8]
<Go Home > [9]
Action: (1) Back, (2) New URL, (3) Quit, (4-9) Select Page Element: 5
Input value for field addTopping:
You have just put  in the field addTopping


Action: (1) Back, (2) New URL, (3) Quit, (4-9) Select Page Element: 7
Parsing page...

This is your order.
 Size: SMALL
 Change size (Small, Medium, Large)_______[4]
 Add topping_______[5]
 Remove topping_______[6]
[Submit][7]
<Order the pizza. > [8]
<Go Home > [9]

Action: (1) Back, (2) New URL, (3) Quit, (4-9) Select Page Element:









submit multiple inputs to same field
You have just put mushroom in the field addTopping
Action: (1) Back, (2) New URL, (3) Quit, (4-9) Select Page Element: 7
Parsing page...
This is your order.
 Size: MEDIUM
Topping: mushroom

 Change size (Small, Medium, Large)
_______[4]
 Add topping
_______[5]
 Remove topping
_______[6]
[Submit][7]

<Order the pizza. > [8]
<Go Home > [9]
Action: (1) Back, (2) New URL, (3) Quit, (4-9) Select Page Element: 5 onion
That's not a number. Please input a number 1-9: 5
Input value for field addTopping:onion
You have just put onion in the field addTopping
Action: (1) Back, (2) New URL, (3) Quit, (4-9) Select Page Element: 7
Parsing page...
This is your order.
 Size: MEDIUM
Topping: mushroom
Topping: onion

 Change size (Small, Medium, Large)
_______[4]
 Add topping
_______[5]
 Remove topping
_______[6]
[Submit][7]






submit twice
Action: (1) Back, (2) New URL, (3) Quit, (4-6) Select Page Element: 4
Input value for field size:Medium
You have just put Medium in the field size
Action: (1) Back, (2) New URL, (3) Quit, (4-6) Select Page Element: 5
Parsing page...
This is your order.
 Size: MEDIUM

 Change size (Small, Medium, Large)
_______[4]
 Add topping
_______[5]
 Remove topping
_______[6]
[Submit][7]

<Order the pizza. > [8]
<Go Home > [9]
Action: (1) Back, (2) New URL, (3) Quit, (4-9) Select Page Element: 4
Input value for field size:Small
You have just put Small in the field size
Action: (1) Back, (2) New URL, (3) Quit, (4-9) Select Page Element: 5
Input value for field addTopping:mushrooms
You have just put mushrooms in the field addTopping
Action: (1) Back, (2) New URL, (3) Quit, (4-9) Select Page Element: 7
Parsing page...
This is your order.
 Size: SMALL
Topping: mushrooms

 Change size (Small, Medium, Large)
_______[4]
 Add topping
_______[5]
 Remove topping
_______[6]
[Submit][7]

<Order the pizza. > [8]
<Go Home > [9]






submit different input values for same field - update input
Action: (1) Back, (2) New URL, (3) Quit, (4-9) Select Page Element: 4
Input value for field size:Large
You have just put Large in the field size
Action: (1) Back, (2) New URL, (3) Quit, (4-9) Select Page Element: 4
Input value for field size:Medium
You have just put Medium in the field size
Action: (1) Back, (2) New URL, (3) Quit, (4-9) Select Page Element: 7
Parsing page...
This is your order.
 Size: MEDIUM
Topping: mushrooms

 Change size (Small, Medium, Large)
_______[4]
 Add topping
_______[5]
 Remove topping
_______[6]
[Submit][7]

<Order the pizza. > [8]
<Go Home > [9]
Action: (1) Back, (2) New URL, (3) Quit, (4-9) Select Page Element:





submit with ampersands in input fields
Parsing page...
Welcome to the pizza parlor!

 What size pizza do you want? (Small, Medium, Large)
_______[4]
[Submit][5]
<Go Home > [6]
Action: (1) Back, (2) New URL, (3) Quit, (4-6) Select Page Element: 4
Input value for field size:Small
You have just put Small in the field size
Action: (1) Back, (2) New URL, (3) Quit, (4-6) Select Page Element: 5
Parsing page...
This is your order.
 Size: SMALL
 Change size (Small, Medium, Large)
_______[4]
 Add topping
_______[5]
 Remove topping
_______[6]
[Submit][7]
<Order the pizza. > [8]
<Go Home > [9]
Action: (1) Back, (2) New URL, (3) Quit, (4-9) Select Page Element: 5
Input value for field addTopping:mushrooms & olives
You have just put mushrooms & olives in the field addTopping
Action: (1) Back, (2) New URL, (3) Quit, (4-9) Select Page Element: 7
Parsing page...
This is your order.
 Size: SMALL
Topping: mushrooms & olives

 Change size (Small, Medium, Large)
_______[4]
 Add topping
_______[5]
 Remove topping
_______[6]
[Submit][7]
<Order the pizza. > [8]
<Go Home > [9]
Action: (1) Back, (2) New URL, (3) Quit, (4-9) Select Page Element: 





Submit and then display input when going back
Action: (1) Back, (2) New URL, (3) Quit, (4-6) Select Page Element: 4
Input value for field size:small
You have just put small in the field size

Action: (1) Back, (2) New URL, (3) Quit, (4-6) Select Page Element: 5
Parsing page...
This is your order. Size: SMALL
 Change size (Small, Medium, Large)_______[4]
 Add topping_______[5]
 Remove topping_______[6]
[Submit][7]
<Order the pizza. > [8]
<Go Home > [9]

Action: (1) Back, (2) New URL, (3) Quit, (4-9) Select Page Element: 1
Welcome to the pizza parlor!
 What size pizza do you want? (Small, Medium, Large)small[4]
[Submit][5]
<Go Home > [6]

Action: (1) Back, (2) New URL, (3) Quit, (4-6) Select Page Element: 



























QUIT
quit upon entering
/gpfs/main/home/awarstad/course/cs018/workspace/javaproject/src $ java spark1.Browser
Welcome to Sparkzilla.
Action: (1) Back, (2) New URL, (3) Quit: 3
Farewell!
/gpfs/main/home/awarstad/course/cs018/workspace/javaproject/src $ 



quit while in page
Input value for field addTopping:mushrooms & olives
You have just put mushrooms & olives in the field addTopping
Action: (1) Back, (2) New URL, (3) Quit, (4-9) Select Page Element: 7
Parsing page...
This is your order.
 Size: SMALL
Topping: mushrooms & olives

 Change size (Small, Medium, Large)
_______[4]
 Add topping
_______[5]
 Remove topping
_______[6]
[Submit][7]
<Order the pizza. > [8]
<Go Home > [9]
Action: (1) Back, (2) New URL, (3) Quit, (4-9) Select Page Element: 3
Farewell!
/gpfs/main/home/awarstad/course/cs018/workspace/javaproject/src $ 





















Welcome to Sparkzilla.

Action: (1) Back, (2) New URL, (3) Quit: -100
Enter a file: 
testhtml.txt
HTTP/1.0 200 OKServer: Sparkserver/1.0Connection: closeContent-Type: text/html<html><body><p>This is a stupid page for testing.<a href="/Test/page2">This</a> is a link.</p><p>Here is a form:</p><form method="post" action="/id:6adf96775832d5/formsubmit"><p>Favorite food:</p><input type="text" name="food" /><p>Favorite ice cream flavor:</p><input type="text" name="icecream" /><p>Favorite drink:</p><input type="text" name="drink" /><input type="submit" value="submit" /></form></body></html>
Parsing page...

This is a stupid page for testing.<This> [4] is a link.
Here is a form:

Favorite food:: _______[5]
Favorite ice cream flavor:: _______[6]
Favorite drink:: _______[7]
[Submit][8]





parsing empty html
cslab5e ~/course/cs018/workspace/javaproject/src $ java spark1.Browser
Welcome to Sparkzilla.

Action: (1) Back, (2) New URL, (3) Quit: -100
Enter a file: 
testhtmlempty.txt

Parsing page...

There was a problem parsing the response from the server.

That's not a number. Please input a number 1-3: 





parsing screwy html
That's not a number. Please input a number 1-3: -100
Enter a file: 
testhtmltypo.txt
HTTP/1.0 200 OKServer: Sparkserver/1.0Connection: closeContent-Type: text/html<html><body><p>This is a stupid page for testing.<a href="/Test/page2">This</a> is a link.</p><p>Here is a form:</p>jdkflsjflskdjfksdfjsklfjsldk<form method="post" action="/id:6adf96775832d5/formsubmit"><p>Favorite food:</p><input type="text" name="food" /><p>Favorite ice cream flavor:</p><input type="text" name="icecream" /><p>Favorite drink:</p><input type="text" name="drink" /><input type="submit" value="submit" /></form></body></html>
Parsing page...

There was a problem parsing the response from the server.





parse empty form
Action: (1) Back, (2) New URL, (3) Quit: -100
Enter a file: 
htmltestemptyform.txt
HTTP/1.0 200 OKServer: Sparkserver/1.0Connection: closeContent-Type: text/html<html><body><p>This is a stupid page for testing.<a href="/Test/page2">This</a> is a link.</p><p>Here is a form:</p><form method="post" action="/id:6adf96775832d5/formsubmit"></form></body></html>
Parsing page...

This is a stupid page for testing.<This> [4] is a link.
Here is a form:























LINK

select a link
Action: (1) Back, (2) New URL, (3) Quit: 2
Please enter a URL: http://rna/Index
Parsing page...

Welcome to the Server on rna!
<The Forums!> [4]
<The Pizza Parlor!> [5]
<Nim> [6]
<Fight in the Coliseum!> [7]

Action: (1) Back, (2) New URL, (3) Quit, (4-7) Select Page Element: 5
Parsing page...
Welcome to the pizza parlor!
 What size pizza do you want? (Small, Medium, Large): _______[4]
[Submit][5]
<Go Home > [6]
Action: (1) Back, (2) New URL, (3) Quit, (4-6) Select Page Element: 





select a different link
 What size pizza do you want? (Small, Medium, Large): _______[4]
[Submit][5]
<Go Home > [6]


Action: (1) Back, (2) New URL, (3) Quit, (4-6) Select Page Element: 6
Parsing page...

Welcome to the Server on rna!
<The Forums!> [4]
<The Pizza Parlor!> [5]
<Nim> [6]
<Fight in the Coliseum!> [7]


Action: (1) Back, (2) New URL, (3) Quit, (4-7) Select Page Element: 
