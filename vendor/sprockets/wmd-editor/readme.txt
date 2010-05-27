Installing WMD
--------------

To install the editor, include wmd.js right before your closing `<body>` tag:

    <script type="text/javascript" src="wmd/wmd.js"></script>

Example:

    <!DOCTYPE html>
    <html>
      <head>
        <title>My Page</title>
      </head>
      <body>
        <textarea></textarea>
        <script type="text/javascript" src="wmd/wmd.js"></script>
      </body>
    </html>

By default, WMD will turn the first textarea on your page into an editor.  You can modify this behavior with the `wmd-ignore` class, described below.  (It's also possible to disable autostart and instantiate the editor through JavaScript, as shown in `apiExample.html`.  But be warned that the current API will change a lot in the upcoming open-source release; it was never actually meant for public consumption.)


Adding live preview
-------------------

Paste this code wherever you want your live preview to appear:

    <div class="wmd-preview"></div>

You can mix "wmd-preview" with your own class names to make applying CSS easier.

Example:

    <div class="myClass <span class="highlight">wmd-preview</span>" id="myId"></div>


Special class names
-------------------

You can use the following class names to control WMD's auto-start behavior:

`wmd-ignore` - Add to a textarea to prevent WMD from turning it into an editor.

`wmd-preview` - Add to a div to turn show a live preview.

`wmd-output` - Add to a textarea or div to turn show the HTML output.


Support
-------

If you're having trouble getting WMD up and running, feel free to email me: <support@attacklab.net>
