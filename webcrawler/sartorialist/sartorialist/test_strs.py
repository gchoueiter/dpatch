base_url = "http://www.thesartorialist.com/archives/page/"
start_urls = []
for y in range(2005, 2014):
    for m in range(1, 13):
        if y == 2005 and m < 9:
            continue
        if  y == 2013 and m > 6:
            continue
        print base_url + str(y) + str(m).zfill(2) + '/'
        start_urls.append(base_url + str(y) + str(m).zfill(2) + '/')
print 'done '+str(len(start_urls))
