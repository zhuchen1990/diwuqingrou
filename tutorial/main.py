from scrapy import cmdline

# 爬取CNBlogs入口
cmdline.execute("scrapy crawl cnblog".split())
# author
# cmdline.execute("scrapy crawl author".split())
# quotes
# cmdline.execute("scrapy crawl quotes".split())
# example.com
# cmdline.execute("scrapy crawl example.com".split())
