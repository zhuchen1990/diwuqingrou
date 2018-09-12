# -*- coding: utf-8 -*-


import scrapy


# CNBlogs Item
class CnblogItem(scrapy.Item):
    title = scrapy.Field()
    link = scrapy.Field()
