import random

data = []

print 'col0,col1,col2,col3,col4,col5,col6,col7,col8,is_centroid'
for i in xrange(1000):
  line = []
  for j in xrange(9):
    line.append("%.5f" % random.uniform(0, 50))
  line += '1' if (random.randint(0,120) == 0) else '0'
  data.append(','.join(line))

random.shuffle(data)
for line in data:
  print line
