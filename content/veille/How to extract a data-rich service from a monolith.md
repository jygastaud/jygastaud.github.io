+++
Categories = ["Veille"]
Tags = ["Veille"]
date = "2018-08-30 18:22:03"
title = "How to extract a data-rich service from a monolith"
link = "https://martinfowler.com/articles/extract-data-rich-service.html"
+++
When breaking monoliths into smaller services, the hardest part is   actually breaking up the data that lives in the database of the monolith. To   extract a such a service, it is useful to follow a series of steps which   retain a single write-copy of the data at all times.