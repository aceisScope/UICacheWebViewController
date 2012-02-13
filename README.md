It can be used to cache html files using the ASIWebpageView mechanism. After one time's cache, then you can load files directly from local file path without start a new request every time you need to load this certain page, so that the time for loading is shortened and it may help when there's no internet connection.
The precondition to use it is that every time a certain html file for loading is changed on the server, then *the file name (url) should be different every time*, and only with this condition could UICacheWebViewController know that you have update for a certain page.
Like:
http://myhost/file29/1/2012.html
http://myhost/file30/1/2012.html
The difference in name is to show that this new file is updated and different from the old one.
