# TODO
List of things needing getting around to. Grouped by priority, sorted by ease.

Ongoing Tasks
-------------
* Clean up the visual design.
* Add framework for supporting multiple games.

Recently Finished Tasks
-----------------------
* Add support for Checkers.
    - Rather haphazard way of switching between the games, try true OO sometime.
    - Results and such take the game type into account, but not very neatly.
* Many user interface and layout changes.
    - Still in dire need of a good profile design.
* List live matches and finished matches in the homepage.
    - Not exactly sure if they should be put in the homepage yet but the
      functionality has been implemented in a matches page.
* Remove channels once the match is done. Don't need to communicate over websocket.
* Run the worker for a match only once.
    - Easiest way to achieve this seems to be to add more types for match status.  
      Perhaps "running" to denote a match is live?
    - Sidekiq can (should) retry once this is set on error.  
      This should allow people to be able to watch games live just like that.  
      We can then add live matches and finished matches to the home page!!
      
  Post-completion note:
    - Ended up using "open" to denote live matches.
    - Match is passed to sidekiq upon creation so everyone's an observer.
    - Since sidekiq will retry upon failure, a match is guranteed to happen.
    - Some weird bugs with v8 contexts and DB Pools here and there still.
* Switch back to using instance-specific v8 context.  
  Post-completion note:
    - Call stack was running out when a static instance was used.
    - Consider using a pool of contexts for better performance. When time permits.
* Add actual functionality to upload_ai on the navbar.
* Add a user-specific ais page to list ais owned by a particular user.
* Update worker logic to restore match state when the match is not new.

Top Priority
------------

1. Research scalability issues for database connections and v8 contexts with
   therubyracer.
     * v8 interpreter crashes with a segfault. Could call JS through shell, but
       perhaps better to just go for Ruby instead.
2. The design promised an administrator dash board to run batch of matches. ...
3. Player vs. Player???
4. What else??

Medium Priority
---------------

1. Let users control their account-specific settings.
2. Email users for account creation confirmation. (Unsure if this is desirable!)
3. Add index page and controller for matches and add links to those on the navbar.
4. I am missing something here that I can't quite recall right now.

Low Priority
---------------

1. Allow users to upload avatars for themselves and Ais.
3. Add a profile card that display stats etc. better.
4. Let users sort matches, users, ais etc. based on different stas.
5. Logo, landing page, other design stuff.
6. Friends yada yada.
7. Performance optimizations, use nested resources, partials where applicable etc.
