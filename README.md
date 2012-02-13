It can be used to cache html files using the ASIWebpageView mechanism. After one time's cache, then you can load files<br/> directly from local file path without start a new request every time you need to load this certain page,<br/> so that the time for loading is shortened and it may help when there's no internet connection.<br/>
The precondition to use it is that every time a certain html file for loading is changed on the server,<br/> then *the file name (url) should be different every time*, and only with this condition could UICacheWebViewController know that you have update for a certain page.<br/>
Like:<br/>
http://myhost/file29/1/2012.html<br/>
http://myhost/file30/1/2012.html<br/>
The difference in name is to show that this new file is updated and different from the old one.
