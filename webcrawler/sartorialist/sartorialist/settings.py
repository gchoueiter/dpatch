# Scrapy settings for sartorialist project

SPIDER_MODULES = ['sartorialist.spiders']
NEWSPIDER_MODULE = 'sartorialist.spiders'
DEFAULT_ITEM_CLASS = 'dirbot.items.BlogPost'

# ['dirbot.pipelines.FilterWordsPipeline']
ITEM_PIPELINES = ['scrapy.contrib.pipeline.images.ImagesPipeline']
IMAGES_STORE = '/Users/gen/sartorialist_images'
