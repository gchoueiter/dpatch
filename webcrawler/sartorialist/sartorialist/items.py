from scrapy.item import Item, Field

class ArchivePage(Item):

    title = Field()
    post_links = Field()
    main_url = Field()

class BlogPost(Item):

    title = Field()
    comments = Field()
    post = Field()
    raw_html = Field()
    main_url = Field()
    image_urls = Field()
    images = Field()
