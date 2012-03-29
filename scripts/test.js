(function() {
  var $, NaiveClusterer, c, clusters, csvArray, handleFileSelect, output, zip, zipWith,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Array.prototype.remove = function(e) {
    var t, _ref;
    if ((t = this.indexOf(e)) > -1) {
      return ([].splice.apply(this, [t, t - t + 1].concat(_ref = [])), _ref);
    }
  };

  NaiveClusterer = (function() {

    function NaiveClusterer() {
      this.findFirstClusters = __bind(this.findFirstClusters, this);
      this.getCentroids = __bind(this.getCentroids, this);
    }

    NaiveClusterer.prototype.minDist = function(point, centroids) {
      var c, centroid, distances, m, _i, _len;
      distances = [];
      for (_i = 0, _len = centroids.length; _i < _len; _i++) {
        centroid = centroids[_i];
        distances.push(this.dist(point, centroid));
      }
      m = Math.min.apply(this, distances);
      c = distances.indexOf(m);
      return [m, c];
    };

    NaiveClusterer.prototype.dist = function(point, centroid) {
      var d, i, sum, _ref;
      sum = 0.0;
      for (i = 0, _ref = point.length - 1; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
        sum += Math.pow(centroid[i] - point[i], 2);
      }
      return d = Math.sqrt(sum);
    };

    NaiveClusterer.prototype.getCentroids = function(csv) {
      var centroids, line, _i, _len, _ref;
      centroids = [];
      _ref = csv.slice(1, csv.length);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        if (line[line.length - 1] !== 0) centroids.push(line);
      }
      return centroids;
    };

    NaiveClusterer.prototype.findFirstClusters = function(csv) {
      var centroids, firstClusters, line, _i, _len, _ref;
      firstClusters = [];
      centroids = this.getCentroids(csv);
      _ref = csv.slice(1, csv.length);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        line = _ref[_i];
        firstClusters.push(this.minDist(line, centroids));
      }
      return firstClusters;
    };

    NaiveClusterer.prototype.separateByCluster = function(csv, func) {
      var centroids, cs, firstClusters, i, j;
      if (func == null) func = this.findFirstClusters;
      firstClusters = func(csv);
      centroids = this.getCentroids(csv);
      i = centroids.length + 1;
      cs = [];
      cs = (function() {
        var _results;
        _results = [];
        while (i -= 1) {
          _results.push((function() {
            var _ref, _results2;
            _results2 = [];
            for (j = 0, _ref = firstClusters.length; 0 <= _ref ? j < _ref : j > _ref; 0 <= _ref ? j++ : j--) {
              if (firstClusters[j][1] === i - 1) _results2.push(csv[j + 1]);
            }
            return _results2;
          })());
        }
        return _results;
      })();
      return cs;
    };

    NaiveClusterer.prototype.tracker = function(csv) {
      var c, centroids, clusterList, i, j, list, names, _i, _j, _k, _len, _len2, _len3, _ref, _ref2;
      clusterList = this.findFirstClusters(csv);
      centroids = this.getCentroids(csv);
      list = [];
      for (_i = 0, _len = centroids.length; _i < _len; _i++) {
        c = centroids[_i];
        list.push([]);
      }
      for (i = 0, _ref = list.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
        for (_j = 0, _len2 = centroids.length; _j < _len2; _j++) {
          c = centroids[_j];
          list[i].push(0);
        }
      }
      for (j = 1, _ref2 = clusterList.length; 1 <= _ref2 ? j < _ref2 : j > _ref2; 1 <= _ref2 ? j++ : j--) {
        list[clusterList[j - 1][1]][clusterList[j][1]]++;
      }
      names = [];
      for (_k = 0, _len3 = centroids.length; _k < _len3; _k++) {
        c = centroids[_k];
        names.push(c[c.length - 1]);
      }
      return this.makeJSON(list, names);
    };

    NaiveClusterer.prototype.makeJSON = function(adjList, names, threshold) {
      var i, j, json, name, _i, _len, _ref;
      if (threshold == null) threshold = 15;
      json = {
        'nodes': [],
        'links': []
      };
      for (_i = 0, _len = names.length; _i < _len; _i++) {
        name = names[_i];
        json.nodes.push({
          'name': name
        });
      }
      i = -1;
      while (i++ < adjList.length - 1) {
        for (j = 0, _ref = adjList[i].length; 0 <= _ref ? j < _ref : j > _ref; 0 <= _ref ? j++ : j--) {
          if (adjList[i][j] > threshold) {
            json.links.push({
              'source': i,
              'target': j,
              'value': adjList[i][j]
            });
          }
        }
      }
      return json;
    };

    return NaiveClusterer;

  })();

  csvArray = [];

  output = [];

  clusters = [];

  c = null;

  csvArray = [];

  handleFileSelect = function(evt) {
    var f, files, makeForceChart, reader, testForceChart, tickFunc;
    files = evt.target.files;
    f = files[0];
    reader = new FileReader();
    reader.onload = function(evt) {
      var fc, i, json, _ref;
      c = new NaiveClusterer;
      csvArray = CSV.csvToArray(evt.target.result);
      output = c.findFirstClusters(csvArray);
      for (i = 0, _ref = csvArray[0].length - 1; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
        colArray += "<option value='' + i + ''>" + csvArray[0][i] + '</option>';
      }
      document.getElementById('col1').innerHTML = colArray.toString();
      document.getElementById('col2').innerHTML = colArray.toString();
      clusters = c.separateByCluster(csvArray);
      fc = c.findFirstClusters(csvArray);
      json = c.tracker(csvArray);
      return makeForceChart(json);
    };
    reader.readAsText(f);
    /*
      Force directed deal from ... for testing purposes
    */
    testForceChart = function() {
      var fill, force, h, node, nodes, vis, w;
      w = 960;
      h = 500;
      fill = d3.scale.category10();
      nodes = d3.range(100).map(Object);
      vis = d3.select("#trackerChart").append("svg:svg").attr("width", w).attr("height", h);
      force = d3.layout.force().nodes(nodes).links([]).size([w, h]).start();
      node = vis.selectAll("circle.node").data(nodes).enter().append("svg:circle").attr("class", "node").attr("cx", function(d) {
        return d.x;
      }).attr("cy", function(d) {
        return d.y;
      }).attr("r", 8).style("fill", function(d, i) {
        return fill(i & 3);
      }).style("stroke", function(d, i) {
        return d3.rgb(fill(i & 3)).darker(2);
      }).style("stroke-width", 1.5).call(force.drag);
      vis.style("opacity", 1e-6).transition().duration(1000).style("opacity", 1);
      force.on("tick", function(e) {
        var k;
        k = 6 * e.alpha;
        nodes.forEach(function(o, i) {
          o.x += i & 2 ? k : -k;
          return o.y += i & 1 ? k : -k;
        });
        return node.attr("cx", function(d) {
          return d.x;
        }).attr("cy", function(d) {
          return d.y;
        });
      });
      return d3.select("body").on("click", function() {
        nodes.forEach(function(o, i) {
          o.x += (Math.random() - 0.5) * 40;
          return o.y += (Math.random() - 0.5) * 40;
        });
        return force.resume();
      });
    };
    makeForceChart = function(json) {
      var force, link, node, vis;
      vis = d3.select('#trackerChart').append('svg').attr('width', 300).attr('height', 300);
      force = d3.layout.force().charge(-120).linkDistance(30).nodes(json.nodes).links(json.links).size([300, 300]).start();
      link = vis.selectAll('line.link').data(json.links).enter().append('line').attr('class', 'link').style('stroke-width', d(function() {
        return Math.sqrt(d.value);
      })).attr('x1', function(d) {
        return d.source.x;
      }).attr('y1', function(d) {
        return d.source.y;
      }).attr('x2', function(d) {
        return d.target.x;
      }).attr('y2', function(d) {
        return d.target.y;
      });
      node = vis.selectAll('circle.node').data(json.nodes).enter().append('circle').attr('class', 'node').attr('cx', function(d) {
        return d.x;
      }).attr('cy', function(d) {
        return d.y;
      }).attr('r', 20).call(force.drag);
      node.append('title').text(function(d) {
        return d.name;
      });
      return force.on('tick', tickFunc(link, node));
    };
    return tickFunc = function(link, node) {
      link.attr('x1', function(d) {
        return d.source.x;
      }).attr('y1', function(d) {
        return d.source.y;
      }).attr('x2', function(d) {
        return d.target.x;
      }).attr('y2', function(d) {
        return d.target.y;
      });
      return node.attr('cx', function(d) {
        return d.x;
      }).attr('cy', function(d) {
        return d.y;
      });
    };
  };

  zip = function(arr1, arr2) {
    var basic_zip;
    basic_zip = function(el1, el2) {
      return [el1, el2];
    };
    return zipWith(basic_zip, arr1, arr2);
  };

  zipWith = function(func, arr1, arr2) {
    var i, min, ret;
    min = Math.min(arr1.length, arr2.length);
    ret = [];
    for (i = 0; 0 <= min ? i < min : i > min; 0 <= min ? i++ : i--) {
      ret.push(func(arr1[i], arr2[i]));
    }
    return ret;
  };

  document.getElementById('files').addEventListener('change', handleFileSelect, false);

  $ = jQuery;

  $(function() {
    return $('#plotButton').click(function() {
      var i, row, sets, x, y;
      x = $('#col1').val();
      y = $('#col2').val();
      console.log($('#col1').val());
      console.log($('#col2').val());
      sets = [];
      i = -1;
      while (++i < clusters.length) {
        sets.push({
          points: {
            show: true
          },
          lines: {
            show: false
          },
          data: zip((function() {
            var _i, _len, _ref, _results;
            _ref = clusters[i];
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              row = _ref[_i];
              _results.push(row[x]);
            }
            return _results;
          })(), (function() {
            var _i, _len, _ref, _results;
            _ref = clusters[i];
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              row = _ref[_i];
              _results.push(row[y]);
            }
            return _results;
          })())
        });
      }
      return $.plot($('#clusterPlot'), sets);
    });
  });

}).call(this);
