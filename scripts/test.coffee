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
json = {}

handleFileSelect = (evt) ->
  files = evt.target.files
  f = files[0]
  reader = new FileReader()
  reader.onload = (evt) ->
    parseAndRender(evt.target.result)

  reader.readAsText f

parseAndRender = (csvFile) ->
  c = new NaiveClusterer
  csvArray = CSV.csvToArray(csvFile)    
  output = c.findFirstClusters(csvArray)
  colArray = ''
  colArray += "<option value=" + i + ">" + csvArray[0][i] + '</option>' for i in [0...csvArray[0].length-1]
  document.getElementById('col1').innerHTML = colArray.toString()
  document.getElementById('col2').innerHTML = colArray.toString()

  clusters = c.separateByCluster(csvArray)
  fc = c.findFirstClusters(csvArray)

  #document.getElementById('rawout').innerHTML = c.tracker(csvArray)
  threshold = 11
  json = c.tracker(csvArray)
  console.log(json)
  window.makeForceChart(json, threshold)

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

document.getElementById('files').addEventListener('change', handleFileSelect, false)

zip = (arr1, arr2) ->
  basic_zip = (el1, el2) -> [el1, el2]
  return zipWith basic_zip, arr1, arr2

zipWith = (func, arr1, arr2) ->
  min = Math.min arr1.length, arr2.length
  ret = []

  for i in [0...min]
    ret.push func(arr1[i], arr2[i])

  return ret

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

  $('#submitTextButton').click ->
    csv = $('#csvText').val()
    parseAndRender(csv)

  $('#thresholdSlider').slider({
            max: 50,
            min: 0,
            value: 12,
            slide: (e, ui) ->
              makeForceChart(json, ui.value)
          }) 
