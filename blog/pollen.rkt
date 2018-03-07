#lang at-exp racket/base
(require pollen/core
         pollen/decode
         pollen/tag
         pollen/template
         pollen/unstable/pygments
         racket/date
         racket/dict
         racket/file
         racket/format
         racket/function
         racket/list
         racket/match
         racket/string
         threading
         txexpr
         (only-in xml string->xexpr)
         (for-syntax racket/base))

(provide (all-defined-out)
         (all-from-out pollen/template))

(module setup racket/base
  (provide (all-defined-out))
  (require pollen/setup)
  (define block-tags (append '(subsection subsubsection label img pre) default-block-tags)))

(define current-return-txexpr? (make-parameter #f))

(define-syntax (define/txexpr stx)
  (syntax-case stx ()
    [(_ (name args ... . rest) body ... last-body)
     #'(begin
         (define (name #:return-txexpr? [return-txexpr? (current-return-txexpr?)] args ... . rest)
           body ...
           ((if return-txexpr? identity ->html) last-body)))]))

(define import file->string)

(define/txexpr (diff-old . elements) `(span ([class "diff-old"]) ,@elements))
(define/txexpr (diff-new . elements) `(span ([class "diff-new"]) ,@elements))

;; I'm naming the arguments so calls would be a little more readable
;; tag processing is done in special-tags-(ry .template
(define/txexpr (article-header #:date date ; :: string? ex: "@|date|"
                               #:tags tags ; :: string? ex: "@|tags|"
                               #:category category ; string? ex: "@|category|"
                               #:title title ; :: string? ex: "@|title|"
                               #:uri uri ; :: string? ex: "@|full-uri|"
                               #:class class) ; :: string? ex: "post-header"
  `(header ([class ,class])
           (p ([class "date-and-category"])
              (span ,date)
              (span " :: ")
              (span ,category))
           (p ([class "title"])
              (a ([href ,uri])
                 ,title))
           (p ([class "tags"])
              (span "Tags: ")
              (span ,tags))))

(define/txexpr (strike . text)
  `(s ,@text))

(define/txexpr (image src [caption #f] #:width [width #f])
    `(div (img ([src ,src]))
          ,(if caption
             `(p ([class "image-caption"]) ,caption)
             "")))

(define/txexpr (R text ruby) `(ruby ,text (rt ,ruby)))

(define/txexpr (table . elements)
  `(table ,@elements))

(define (newline-decode . elements)
  (string-join
   (map (λ (x) (cond
                  [(not (string? x)) x]
                  [(regexp-match #rx"\n\n+" x)
                   (string-replace x #rx"\n\n+" "\n\n")]
                  [(regexp-match #rx">\n+" x) ">\n"
                   (string-replace x #rx">\n+" ">\n")]
                  [(regexp-match #rx"\n" x) "<br>\n"
                   (string-replace x #rx"\n" "<br>\n")]
                  [else x]))
        elements)
   ""))

(define (quotation . lines)
  ;; lines :: (listof string?)
  (~> (string-join lines)
      (string-replace _ "\n" "\n> ")
      (string-append "> " _) ; first line has no ">" from above. add it
      (newline-decode _)))

(define (quotation-html . lines)
  ;; lines :: (listof string?)
  (~> (apply newline-decode lines)
      (string-append "<blockquote><p>" _ "</p></blockquote>")))

(define (highlight language . stuff)
  (define lang-string
    (if (symbol? language)
      (symbol->string language)
      language))
  (string-append "```" lang-string "\n"
                 (string-join stuff "")
                 "\n```\n"))

(define pagebreak (->html '(div ([class "page-break"]))))

(define/txexpr (year . text)
  `(p ([class "year-in-page"]) ,@text))

(define ie "i.e.")

(define/txexpr (font-awesome fa-icon
                      #:aria [hidden #t])
  `(i ([class ,(string-append "fa "
                              fa-icon)]
       [aria-hidden "true"])))

#| link functions |#

(define/txexpr (link url [text url]
                     #:class [class ""]
                     #:target [target "_blank"])
  `(a ([href ,url]
       [target ,target]
       [class ,class])
      ,text))

(define/txexpr (image/link url src caption)
  `(div
     ,(link #:return-txexpr? #t url
            (image src #:return-txexpr? #t))
     (p ([class "image-caption"]) ,caption)))

(define/txexpr (link/date url date . text)
  `(p ,(string-append date " ")
      ,(link #:return-txexpr? #t url (string-join text))))

(define-syntax (define-link stx)
  (syntax-case stx ()
    [(_ linkname url-prefix)
     #'(begin
         (define/txexpr (linkname suburl [text suburl] #:class [class ""])
           (link (string-append url-prefix suburl)
                 text
                 #:class class
                 #:return-txexpr? #t)))]))

(define-link github "https://github.com/")
(define-link twitter "https://twitter.com/")
(define-link youtube "https://youtube.com/")
(define-link pixiv "https://pixiv.net/")
(define-link niconico "http://www.nicovideo.jp/")
(define-link osuwiki "http://osu.ppy.sh/help/wiki/")
(define-link transifex "https://www.transifex.com/user/profile/")
(define-link noichigo "https://www.no-ichigo.jp/read/book/book_id/")
(define-link site-crossref "https://kisaragi-hiu.com/")

(define site-url "http://kisaragi-hiu.com")

(define/txexpr (video/gif-esque path)
  `(video ([autoplay "autoplay"]
           [style "max-width: 100%;"]
           [muted "muted"]
           [loop "loop"]
           [src ,path])))

(define/txexpr (youtube/embed video-id)
  `(div ([style "padding-bottom: 50%;
                position: relative;
                overflow: hidden;"])
        (iframe ([id "ytplayer"]
                 [type "text/html"]
                 [width "640"]
                 [height "360"]
                 [style "position: absolute;
                        top: 0;
                        left: 0;
                        width: 100%;
                        height: 100%;"]
                 [src ,(string-append
                        "http://www.youtube.com/embed/"
                        video-id
                        "?autoplay=0"
                        "&origin="
                        site-url)]
                 [frameborder "0"]))))

(define (google-adsense/page-level id)
  (string-append
    "<script async src=\"//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js\"></script>\n"
    "<script>\n"
    "(adsbygoogle = window.adsbygoogle || []).push({\n"
    "  google_ad_client: " id ",\n"
    "  enable_page_level_ads: true\n"
    "});\n"
    "</script>"))

(define google-adsense/banner
  (->html
   '((script ([async "async"]
              [src "//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"]))
     (ins ([class "adsbygoogle"]
           [data-ad-client "ca-pub-6215394828182929"]
           [data-ad-slot "7498976067"]
           [style "display:inline-block;width:728px;height:90px"]))
     (script "(adsbygoogle = window.adsbygoogle || []).push({});"))))

(define google-adsense/in-article
  (->html
   '((script ([async "async"]
              [src "//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"]))
     (ins ([class "adsbygoogle"]
           [style "display:block;text-align:center"]
           [data-ad-layout "in-article"]
           [data-ad-format "fluid"]
           [data-ad-client "ca-pub-6215394828182929"]
           [data-ad-slot "5614709443"]))
     (script "(adsbygoogle = window.adsbygoogle || []).push({});"))))

(define google-adsense/responsive
  (->html
   '((script ([async "async"]
              [src "//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"]))
     (ins ([class "adsbygoogle"]
           [style "display:block"]
           [data-ad-client "ca-pub-6215394828182929"]
           [data-ad-slot "5733348692"]
           [data-ad-format "auto"]))
     (script "(adsbygoogle = window.adsbygoogle || []).push({});"))))

(define (google-universal-analytics account)
  ;; copied from https://github.com/greghendershott/frog/blob/master/frog/widgets.rkt
  ;; to avoid 'type="text/javascript"'
  (->html
    `(script ,(string-append
                "(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){"
                "(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),"
                "m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)"
                "})(window,document,'script','//www.google-analytics.com/analytics.js','ga');"

                "ga('create', '" account "', 'auto');"
                "ga('send', 'pageview');"))))
