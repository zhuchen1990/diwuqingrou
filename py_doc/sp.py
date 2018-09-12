s = 'http://www.baidu.com/page/1/'

t = s.split("/")[-1]

print(t)

print(type(t))

for quote in response.css("div.quote"):
    text = quote.css("span.text::text").extract_first()
    author = quote.css("small.author::text").extract_first()
    tags = quote.css("div.tags a.tag::text").extract()
    print(dict(text=text, author=author, tags=tags))
