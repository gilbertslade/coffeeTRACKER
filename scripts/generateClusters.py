import random

centroids = []
data = []

for i in xrange(5):
  centroids.append([random.uniform(0, 50) for j in xrange(5)])

for c in centroids:
  for i in xrange(50):
    line = ["%.5f" % (random.uniform (-7, 7) + c[j]) for j in xrange(5)]
    line.append('0')
    data.append(line)

print 'col1,col2,col3,col4,col5,is_centroid'

for c in centroids:
    print ','.join(["%.5f" % c[i] for i in xrange(len(c))]) + ',' + str(1) 

for d in data:
  print ','.join(d)
