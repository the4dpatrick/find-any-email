**NOTE: Rapportive recently changed their API which has broken the functionality of this script. If you already know where the bug is or have time to fix it, send a pull request.**

**This script has been made into a Ruby Gem [PossibleEmail](https://github.com/the4dpatrick/possible-email)**

----

Find Anyone's Email
===================
Ruby script to find anyone's email using their first name, last name, and domain.

More information in my [blog post](http://patrickperey.com/find-anyones-email-a-ruby-script "blog post") at [PatrickPerey.com](http://patrickperey.com "Patrick Perey Blog")



Usage
-----
Enter target's first name, last name, and possible domain into the terminal

```
ruby ./find_email.rb first_name last_name domain
```

Not sure about the domain? Use the `--domains` option

```
ruby ./find_email.rb first_name last_name --domains gmail.com,yahoo.com,live.com
```

Just want to Confirm a single email? Use the `-e` option

```
ruby ./find_email.rb -e example@example.com
```

Example
-------
Input
```
ruby ./find_email.rb kevin rose gmail.com
```
Output
```
.......
kevinrose@gmail.com
Name: Kevin Rose
Position: General Partner
Company: Google Ventures
Position: Board Member
Company: Tony Hawk Foundation
Twitter - http://twitter.com/kevinrose
Facebook - http://www.facebook.com/kevinrose
Facebook - http://www.facebook.com/profile.php?id=6162642477
LinkedIn - http://www.linkedin.com/in/kevinrose
About.me - http://about.me/kevinrose
AngelList - http://angel.co/kevin
Delicious - http://delicious.com/kevinrose
Digg - http://digg.com/kevinrose
Flickr - http://www.flickr.com/photos/kevinrose/
Foursquare - http://foursquare.com/kevinrose
FriendFeed - http://friendfeed.com/kevinrose
Google+ - https://plus.google.com/110318982509514011806/posts
Google+ - https://plus.google.com/115676926487344928572/posts
Google Profile - https://profiles.google.com/kevinrose
Gowalla - http://gowalla.com/krose
Quora - http://quora.com/kevin-rose
Vimeo - http://vimeo.com/kevinrose
YouTube - http://youtube.com/kevinrose
```

Notes
-----
* With great power, comes great responsibly
* Wrapper around the undocument Rapportive API.
* Valid results may be hidden due to API's limitations
* The script will print other emails, even the ones you're not looking for.
* Send Bitcoin `18fZ6muNmBrtENMZhnAjUw8eEsytmY8mZJ`


Contributing
------------

1. Fork it ( http://github.com/the4dpatrick/find-any-email )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
