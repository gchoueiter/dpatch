from scrapy.http import Request
from scrapy.spider import BaseSpider
from scrapy.selector import HtmlXPathSelector

from sartorialist.items import ArchivePage, BlogPost

class SartSpider(BaseSpider):
    name = "sart"
    allowed_domains = ["thesartorialist.com"]
    base_url = "http://www.thesartorialist.com/archives/page/"
    start_urls = []
    for y in range(2005, 2014):
        for m in range(1, 13):
            if y == 2005 and m < 9:
                continue
            if  y == 2013 and m > 6:
                continue
            start_urls.append(base_url + str(y) + str(m).zfill(2) + '/')


# this catches the archive pages
    def parse(self, response):
        item = ArchivePage()
        requests = []
        item['main_url'] = response.url
        hxs = HtmlXPathSelector(response)
        item['title'] = hxs.select('//title/text()').extract()
        item['post_links'] = hxs.select('//h3//a[contains(@href, "/photos/")]/@href').extract()
        #print item['post_links']
        for link in item['post_links']:
            new_req = Request(link, callback=self.parse_blog)
            requests.append(new_req)
        return requests
        

    def parse_blog(self, response):
        item = BlogPost()
        item['main_url'] = response.url
        hxs = HtmlXPathSelector(response)
        item['title'] = hxs.select('//title/text()').extract()

# div class="article-content" p
        item['post'] = hxs.select('//div[@class="article-content"]/p/text()').extract()
# div class="content-comment" p 
        item['comments'] = hxs.select('//div[@class="content-comment"]/p/text()').extract()
        item['raw_html'] = hxs.select('//html').extract()
# div class="article-content" img src
        item['image_urls'] = hxs.select('//div[@class="article-content"]//a[contains(@href, "/photos/")]/@href').extract()
        

        return item
