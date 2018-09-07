## Welcome to diwuqingrou workspace!!

# 第五轻柔
## Email: 291394199@qq.com
### QQ: 291394199
> 长风破浪会有时,直挂云帆济沧海！

* developer
* devops
1. java
2. python
3. php
* 小目标
 > shell res

---
###链接
[gitee](https://gitee.com/diwuqingrou404/)

[blog]: http://www.diwuqingrou.cn/article/4 "博客"
[home]: http://www.diwuqingrou.cn/admin "后台"

### 是谁在轻轻敲打我的窗

![图片](https://ws2.sinaimg.cn/large/9150e4e5ly1fhx5kcor4xg207y05mmy4.gif)

`print ("pip install scrapy")`

```python
import scrapy

class BlogSpider(scrapy.Spider):
    name = 'blogspider'
    start_urls = ['https://blog.scrapinghub.com']

    def parse(self, response):
        for title in response.css('.post-header>h2'):
            yield {'title': title.css('a ::text').extract_first()}

        for next_page in response.css('div.prev-post > a'):
            yield response.follow(next_page, self.parse)
```
###

*more and more*

_any and any_

~~这是大佬的博客,我错了，我不是！~~