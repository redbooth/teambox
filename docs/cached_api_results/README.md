These files can be copied or symlinked into public/api for faster development
on the frontend.

    $ ln -s ../docs/cached_api_results/ public/api

This way, API requests will be server statically instead of going through
the Rails stack.
