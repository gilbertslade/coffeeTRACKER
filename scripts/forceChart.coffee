START = {}
END = {}

window.makeForceChart = (json, threshold = 15, drawEdgesToSelf = false) ->
  document.getElementById('trackerChart').innerHTML=''
  vis = d3.select('#trackerChart').append('svg:svg')
    .attr('width', 600)
    .attr('height', 600)

  vis.append('svg:defs').selectAll('marker')
      .data(['arrow'])
    .enter().append('svg:marker')
      .attr('id', String)
      .attr('viewBox', '0 -5 10 10')
      .attr('refX', 15)
      .attr('refY', -1.5)
      .attr('markerWidth', 6)
      .attr('markerHeight', 6)
      .attr('orient', 'auto')
    .append('svg:path')
      .attr('d', 'M0,-5L10,0L0,5')

  START = json.nodes[json.nodes.length - 2]
  END = json.nodes[json.nodes.length - 1]
  
  fill = d3.scale.category10()
  force = d3.layout.force()
    .charge(-1000)
    .linkDistance(150)
    .nodes(json.nodes)
    .links(json.links)
    .size([600, 600])
    .start()
  
  edges = []
  edges.push edge for edge in json.links when ((edge.source isnt edge.target) and (edge.value > threshold)) or (edge.source is START or edge.target is END)
  console.log(edges)
  path = vis.append('svg:g').selectAll('path')
      .data(edges)
    .enter().append('svg:path')
      #.attr('class', (d) -> 'url(#' + d.val + ')')
      .attr('x', fixPosX)
      .attr('y', fixPosY)
      .attr('fill', 'none')
      .attr('stroke', '#666')
      .attr('stroke-width', (d) -> return Math.sqrt(d.value - threshold))
      .attr('marker-end', 'url(#arrow)')

  #link = vis.selectAll('line.link')
  #  .data(json.links)
  #  .enter().append('line')
  #  .attr('class', 'link')
  #  .style('stroke-width', (d) ->  return Math.sqrt(d.value) )
  #  .attr('x1', (d) ->  return fixPosX d.source )
  #  .attr('y1', (d) ->  return fixPosY d.source )
  #  .attr('x2', (d) ->  return fixPosX d.target )
  #  .attr('y2', (d) ->  return fixPosY d.target )
  #  .attr('stroke', 'rgb(0,0,0)')

  node = vis.selectAll('circle.node')
    .data(json.nodes)
    .enter().append('circle')
    .attr('class', 'node')
    .attr('cx', fixPosX )
    .attr('cy', fixPosY )
    .attr('stroke', '#666')
    .attr('stroke-width', '1.5px')
    .attr('fill', (d,i) -> return fill(i))
    .attr('r', 5)
    .call(force.drag)


  nodeLabel = vis.selectAll("text")
    .data(json.nodes, (d) -> d.name)
    .enter()
    .insert("text")
    .text((d) -> d.name )
    .attr("x", fixPosX )
    .attr("y", fixPosY )
    .attr("text-anchor", "middle")
    .style("fill", (d) -> fill(d.group) )
    .call(force.drag)
    .attr('transform', (d) -> return 'translate(' + 0 + ',' + -30 + ')' )

  pathLabel = vis.selectAll('text')
    .data(edges, (d) -> d.value)
    .enter()
    .insert('text')
    .text((d) -> d.value)
    .attr('x', edgeLabelX)
    .attr('y', edgeLabelY)
    .attr('text-anchor', 'middle')
    .attr('fill', 'none')
    .attr('stroke', '#666')
  
  
  node.append('title')
    .text((d) -> return d.name)
  
  force.on 'tick', ->

    
    #link.attr("x1", (d) -> fixPosX d.source )
    #  .attr("y1", (d) -> fixPosY d.source )
    #  .attr("x2", (d) -> fixPosX d.target )
    #  .attr("y2", (d) -> fixPosY d.target )


    node.attr("cx", fixPosX)
        .attr("cy", fixPosY)

    path.attr 'd', (d) ->
        x1 = fixPosX d.source
        x2 = fixPosX d.target
        y1 = fixPosY d.source
        y2 = fixPosY d.target
        dx = x2 - x1
        dy = y2 - y1
        dr = Math.sqrt(dx * dx + dy * dy)
        return 'M' + x1 + ',' + y1 + 'A' + dr + ',' + dr + ' 0 0,1 ' + x2 + ',' + y2

    nodeLabel.attr("x", fixPosX )
      .attr("y", fixPosY )

    pathLabel.attr('x', edgeLabelX)# (d) -> fixPosX d.source)
      .attr('y', edgeLabelY)# (d) -> fixPosY d.source)
    
fixPosX = (d) ->
  if d is START
    return 27
  else if d is END
    return 573
  else
    return d.x

fixPosY = (d, offset = 0) ->
  if d is START
    return 50 + offset
  else if d is END
    return 550 + offset
  else
    return d.y + offset

edgeLabelX = (d) ->
  if fixPosX(d.source) > fixPosX(d.target) 
    offset = 7
  else 
    offset =-7
  maxX = Math.max(fixPosX(d.source), fixPosX(d.target))
  minX = Math.min(fixPosX(d.source), fixPosX(d.target))
  return (maxX - minX) /2.0 + minX

edgeLabelY = (d) ->
  if fixPosY(d.source) > fixPosY(d.target) 
    offset = 7
  else 
    offset =-7
  maxY = Math.max(fixPosY(d.source), fixPosY(d.target))
  minY = Math.min(fixPosY(d.source), fixPosY(d.target))
  return (maxY - minY) /2.0 + minY + offset
