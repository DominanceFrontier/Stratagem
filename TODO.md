# TODO
List of things needing getting around to. Grouped by priority, sorted by ease.

Recently Finished Tasks
-----------------------
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
* Switched back to using instance-specific v8 context.
    - Call stack was running out when a static instance was used.
    - Consider using a pool of contexts for better performance. When time permits.


Top Priority
------------

1. Research scalability issues for database connections and v8 contexts with therubyracer.
2. Integrate Checkers.
    * Need to make the match take into account the game type.
    * This will probably break the views for lots of things.
        - How do we store game neutral results for instance?  
          Probably best to say something like "Player X Victory", "Tie" etc.
3. What else??

Medium Priority
---------------

1. Let users control their settings.
2. Email users for account creation confirmation.
3. I am missing something here that I can't quite recall right now.

Low Priority
---------------

1. Allow users to upload avatars for themselves and Ais.
2. List live matches and finished matches in the homepage.
3. Add a profile card that display stats etc. better.
4. Let users sort matches, users, ais etc. based on different stas.
5. Logo, landing page, other design stuff.
6. Friends yada yada.
