# TODO
List of things needing getting around to. Grouped by priority sorted by ease.

Top Priority
============

1. Remove channels once the match is done. Don't need to communicate over websocket.
2. Run the worker for a match only once. Easiest way to achieve this seems to be to add more types for match status. Perhaps "running" to denote a match is live? Sidekiq can (should) retry once this is set on error. This should allow people to be able to watch games live just like that. We can then add live matches and finished matches to the home page!!
3. Integrate Checkers. Need to make the match taken into account the game type. This will probably break the views for lots of things. How do we store game neutral results for instance. Probably best to say something like "Player 1 Victory", "Player 2 Victory" or "Tie."

Medium Priority
===============

1. Let users control their settings.
2. Email users for account creation confirmation.
3. I am missing something here that I can't quite recall right now.

Low Priority
===============

1. Allow users to upload avatars for themselves and Ais.
2. List live matches and finished matches in the homepage.
3. Add a profile card that display stats etc. better.
4. Let users sort matches, users, ais etc. based on different stas.
5. Logo, landing page, other design stuff.
6. Friends yada yada.
