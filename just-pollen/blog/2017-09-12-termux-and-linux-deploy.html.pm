#lang pollen

◊define-meta[title]{在Android上用Frog}
◊define-meta[date]{2017-09-12T16:46:00}
◊define-meta[category]{Meta}
◊define-meta[language]{zh-TW}

Linux Deploy是個很不錯的Android app。這個網站前幾天改成了用Frog建置，但是Termux裡沒有racket的套件(如果我是用Jekyll還是Hugo之類的Termux裡面有需要的套件，但那些我還弄不懂)。用Linux Deploy我可以建構一個Debian Sid的(類似Container)的環境出來，啟用ssh，然後把/sdcard bind到那裡面，再裝好Racket和Frog，就可以在手機上建構這個網站了。

能在Termux直接有Racket的話會更好就是。現在啟動這個Container(?)的時候電池總是燒很快。
