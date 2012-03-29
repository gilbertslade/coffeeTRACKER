Array::remove = (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1 #from http://stackoverflow.com/questions/4825812/clean-way-to-remove-element-from-javascript-array-with-jquery-coffeescript

$ = jQuery

class NaiveClusterer
  minDist: (point, centroids) -> #returns a list of length 2 of the form [minimum distance, index of cluster]
    distances = []
    distances.push @dist(point, centroid) for centroid in centroids
    m = Math.min.apply @, distances
    c = distances.indexOf(m)
    return [m,c]

  dist: (point, centroid) ->
    sum = 0.0
    sum += Math.pow(centroid[i] - point[i], 2) for i in [0 ... point.length - 1]
    d = Math.sqrt(sum)

  getCentroids: (csv) =>
    centroids = []
    centroids.push line for line in csv[1...csv.length] when line[line.length - 1] isnt 0
    return centroids

  findFirstClusters: (csv) =>
    firstClusters = []
    centroids = @getCentroids(csv)
    firstClusters.push @minDist(line, centroids) for line in csv[1...csv.length]
    return firstClusters

  separateByCluster: (csv, func = this.findFirstClusters) ->
    firstClusters = func(csv)
    centroids = @getCentroids(csv)
    i = centroids.length + 1
    cs = []
    cs = while i -=1
      #need to pull row from csv based on distances[1]
      csv[j + 1] for j in [0...firstClusters.length] when firstClusters[j][1] == i - 1
    return cs

  #tracker: takes clustered lists, returns a list of objects
  #tracker takes findFirstClusters, returns list of lists matching clusters to clusters
  tracker: (csv) ->
    clusterList = @findFirstClusters(csv)
    centroids = @getCentroids(csv)
    list = []
    list.push [] for c in centroids
    list[i].push 0 for c in centroids for i in [0...list.length]
    list[clusterList[j-1][1]][clusterList[j][1]]++ for j in [1...clusterList.length]
    names = []
    names.push c[c.length - 1] for c in centroids
    return @makeJSON(list, names, clusterList[0], clusterList[clusterList.length - 1])

  makeJSON: (adjList, names, first, last, threshold = 15) ->
    json = { 'nodes':[], 'links':[] }
    json.nodes.push({'name':name}) for name in names
    json.nodes.push({'name':'START'})
    json.nodes.push({'name':'END'})

    i = -1
    while i++ < adjList.length - 1
      json.links.push({'source':i, 'target':j, 'value':adjList[i][j]}) for j in [0 ... adjList[i].length] #when adjList[i][j] > threshold and i isnt j
      #move checks into makeForceChart to make it interactive

    json.links.push({'source':json.nodes[json.nodes.length - 2], 'target':first[first.length - 1], 'value':1})
    json.links.push({'source':last[last.length - 1], 'target':json.nodes[json.nodes.length - 1], 'value':1})

    return json

csvArray = []
output = []
clusters = []
c = null
csvArray = []
START = {}
END = {}

handleFileSelect = (evt) ->
  files = evt.target.files
  f = files[0]
  reader = new FileReader()
  reader.onload = (evt) ->
    c = new NaiveClusterer
    csvArray = CSV.csvToArray(evt.target.result)    
    output = c.findFirstClusters(csvArray)

    colArray += "<option value=" + i + ">" + csvArray[0][i] + '</option>' for i in [0...csvArray[0].length-1]
    document.getElementById('col1').innerHTML = colArray.toString()
    document.getElementById('col2').innerHTML = colArray.toString()

    clusters = c.separateByCluster(csvArray)
    fc = c.findFirstClusters(csvArray)

    #document.getElementById('rawout').innerHTML = c.tracker(csvArray)
    threshold = 11
    json = c.tracker(csvArray)
    console.log(json)
    makeForceChart(json, threshold)

    $ ->
      sets = []
      i = -1  #that's annoying
      sets.push(
        {
          points: {show: true}, 
          lines: {show: false}, 
          data: zip(row[0] for row in clusters[i], row[1] for row in clusters[i])
        }
      ) while ++i < clusters.length
      
      $.plot($('#clusterPlot'), sets)

  reader.readAsText f


  makeForceChart = (json, threshold = 15, drawEdgesToSelf = false) ->
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
    lse 
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

zip = (arr1, arr2) ->
  basic_zip = (el1, el2) -> [el1, el2]
  return zipWith basic_zip, arr1, arr2

zipWith = (func, arr1, arr2) ->
  min = Math.min arr1.length, arr2.length
  ret = []

  for i in [0...min]
    ret.push func(arr1[i], arr2[i])

  return ret



document.getElementById('files').addEventListener('change', handleFileSelect, false)


$ ->
  $('#plotButton').click ->
    x = $('#col1').val()
    y = $('#col2').val()
#    console.log($("#col1").val())
#    console.log($("#col2").val())
    
    #make a list of k objects where object.data = xs.push row[x] for row in clusters[i] for i in [0...k]
    sets = []
    i = -1  #that's annoying
    sets.push(
      {
        points: {show: true}, 
        lines: {show: false}, 
        data: zip(row[x] for row in clusters[i], row[y] for row in clusters[i])
      }
    ) while ++i < clusters.length
    
    $.plot($('#clusterPlot'), sets)
