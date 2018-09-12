# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://doc.scrapy.org/en/latest/topics/item-pipeline.html


class TutorialPipeline(object):
    def process_item(self, item, spider):
        return item


# CNBlogs
class FilePipeline(object):

    def process_item(self, item, spider):
        data = ''
        with open('cnblog.txt', 'w', encoding='utf-8') as f:
            titles = item['title']
            links = item['link']
            for i, j in zip(titles, links):
                data += i + ':' + j + '\n'
            f.write(data)
            f.close()
        return item
