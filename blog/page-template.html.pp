#lang pollen
@(local-require pollen/template)
@;{ attr->string : (List Attr Value) -> String }
@(define (attr->string attr)
   (string-append
    (symbol->string (first attr))
    "="
    "\"" (second attr) "\""))

@(define rest-headline
   (cond [(string-ci=? uri-path "/index.html") " / Blog"]
         [else ""]))

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>@|title|</title>
    <meta name="description" content="@|description|">
    <meta name="author"      content="@|author|">
    <meta name="keywords"    content="@|keywords|">
    <meta name="viewport"    content="width=device-width, initial-scale=1">
    <link rel="icon"      href="@|uri-prefix|/favicon.ico">
    <link rel="canonical" href="@|full-uri|">

    @(when rel-next @list{<link rel="next" href="@|rel-next|">})
    @(when rel-prev @list{<link rel="prev" href="@|rel-prev|">})

    <!-- CSS -->
    <link rel="stylesheet" type="text/css" href="@|uri-prefix|/css/normalize.css">
    <link rel="stylesheet" type="text/css" href="@|uri-prefix|/css/skeleton.css">
    <link rel="stylesheet" type="text/css" href="@|uri-prefix|/css/monokai.css">
    <link rel="stylesheet" type="text/css" href="@|uri-prefix|/css/scribble.css">
    <link rel="stylesheet" type="text/css" href="@|uri-prefix|/css/custom.css">
    <!-- Feeds -->
    <link rel="alternate" type="application/atom+xml"
          href="@|atom-feed-uri|" title="Atom Feed">
    <!-- <link rel="alternate" type="application/rss+xml" -->
    <!--       href="@|rss-feed-uri|" title="RSS Feed"> -->
    <!-- JS -->
    <script src="https://use.fontawesome.com/f9f3cd1f14.js"></script>
    @google-universal-analytics["UA-xxxxx"]
  </head>
  <body>

    <header id="topheader" class="container">
      <div class="logo">
        <img src="@|uri-prefix|/images/avatar.png" height="40px"/>
        <a href="/">如月.飛羽@|rest-headline|</a>
      </div>
      <nav>
        <ul>
          <li><a href="@|uri-prefix|/about">About</a></li>
          <li><a href="@|uri-prefix|/writing">Writing</a></li>
        </ul>
      </nav>
    </header>

    <div class="container">
      <div class="row">
        <div id="content" class="one-half column">
          @(when (string-ci=? uri-path
                              (string-append uri-prefix
                                             "/index.html"))
            @list{
              <h1>Welcome</h1>
              <p></p> })
          @;{ Index pages for posts have @tag that's not #f }
          @(when tag
            @list{<h1>@"@"<em>@|tag|</em></h1>})
          @|contents|
        </div>
      </div>
      <footer>
        <hr />
  <a rel="license"
     href="http://creativecommons.org/licenses/by/4.0/">
    <img alt="Creative Commons License"
         style="border-width:0"
         src="https://i.creativecommons.org/l/by/4.0/88x31.png" />
  </a>
  <br />
  <p>© Kisaragi Hiu 2017. Posts are licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">CC-BY-NC 4.0 International license</a>.</p>
        <div>
    <a href="@|atom-feed-uri|">
      ◊font-awesome["fa-rss-square"]
    </a>
    ◊twitter["flyin1501"]{
      ◊font-awesome["fa-twitter-square" #:txexpr #t]
    }
  </div>
        <p>Site generated
        by <a href="https://github.com/greghendershott/frog">Frog</a>,
        the <strong>fr</strong>ozen bl<strong>og</strong> tool.</p>
      </footer>
    </div>
    <!-- </body> JS -->
    <script type="text/javascript" src="//code.jquery.com/jquery.min.js"></script>
  </body>
</html>