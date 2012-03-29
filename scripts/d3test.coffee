w = 960
h = 500
fill = d3.scale.category10()

#nodes = ?
centroids = [0,1,2,3,4,5]
first   =   [0,0,1,1,2,2,3,3,3,4,5,5]
second  =   [1,2,2,3,0,3,4,2,0,5,3,2]
third   =   [2,1,3,4,5,1,0,0,2,1,4,4]

force = d3.layout.force()
  .nodes(centroids)
  .links([])
  .size([w,h])
  .start()

vis = d3.select('#fdgraph').append('svg:svg')
  .attr('width', w)
  .attr('height', h)

nodes = vis.selectAll('node')
  .data(centroids)
enter = nodes.enter().append('node')
  .attr('r', 15)
nodes.append('svg:text')
  .attr('class', 'nodetext')
  .text((d,i) -> i)


