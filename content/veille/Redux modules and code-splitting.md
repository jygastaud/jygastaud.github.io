+++
Categories = ["Veille"]
Tags = ["Veille"]
date = "2018-02-02 21:49:39"
title = "Redux modules and code-splitting"
link = "http://nicolasgallagher.com/redux-modules-and-code-splitting/"
+++
Twitter Lite uses Redux for state management and relies on code-splitting. However, Redux’s default API is not designed for applications that are incrementally-loaded during a user session.  This post describes how I added support for incrementally loading the Redux modules in Twitter Lite.