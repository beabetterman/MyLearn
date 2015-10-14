#coding=UTF-8 
#!/usr/bin/python
'''
Created on 2015.4.16

@author: zhiming.wang
'''
import urllib2  
import urllib
import requests

data = {}

data['name'] = 'WHY'  
data['location'] = 'SDU'  
data['language'] = 'Python'

url_values = urllib.urlencode(data)  
print url_values

#name=Somebody+Here&language=Python&location=Northampton  
url = 'http://www.baidu.com/'
url = 'http://wsbm.sdzk.gov.cn'  
full_url = url + '?' + url_values
response = urllib2.urlopen(full_url)  
print response.read()
